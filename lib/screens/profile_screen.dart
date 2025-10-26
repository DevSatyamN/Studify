import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import '../models/user_stats.dart';
import '../models/achievement.dart';
import '../models/xp_transaction.dart';
import '../models/study_session.dart';
import '../models/daily_study_report.dart';
import '../models/syllabus_group.dart';
import '../models/subject.dart';
import '../models/goal.dart';
import '../models/exam.dart';
import 'achievements_screen.dart';
import 'settings_screen.dart';
import 'xp_transactions_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _profileController;
  late AnimationController _statsController;
  late Animation<double> _profileAnimation;
  late Animation<double> _statsAnimation;

  @override
  void initState() {
    super.initState();
    _profileController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _statsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _profileAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _profileController,
      curve: Curves.easeOut,
    ));

    _statsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _statsController,
      curve: Curves.easeOut,
    ));

    _profileController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _statsController.forward();
    });
  }

  @override
  void dispose() {
    _profileController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<UserStats>('user_stats').listenable(),
        builder: (context, Box<UserStats> box, _) {
          final userStats = box.get('user_stats') ?? UserStats.initial();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
            child: Column(
              children: [
                // Profile header with blur effect
                AnimatedBuilder(
                  animation: _profileAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _profileAnimation.value,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 0.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                // Profile Avatar
                                GestureDetector(
                                  onTap: () =>
                                      _showEditNameDialog(context, userStats),
                                  child: CircleAvatar(
                                    radius: 40,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    child: Text(
                                      userStats.userName.isNotEmpty
                                          ? userStats.userName[0].toUpperCase()
                                          : 'S',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // User Name
                                GestureDetector(
                                  onTap: () =>
                                      _showEditNameDialog(context, userStats),
                                  child: Column(
                                    children: [
                                      Text(
                                        userStats.userName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Tap to edit name',
                                        style: TextStyle(
                                          color: Colors.grey.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Level and XP in one line
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Level ${userStats.currentLevel}',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${userStats.totalXP} / ${_getXPForNextLevel(userStats.currentLevel)} XP',
                                      style: TextStyle(
                                        color: Colors.grey.withOpacity(0.8),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // XP Progress bar
                                Container(
                                  width: double.infinity,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: _getXPProgress(userStats),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Stats grid with proper alignment
                AnimatedBuilder(
                  animation: _statsAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _statsAnimation.value,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _showXPTransactions(context),
                                  child: _StatCard(
                                    title: 'Total XP',
                                    value: '${userStats.totalXP}',
                                    icon: Icons.star,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  title: 'Current Streak',
                                  value: '${userStats.currentStreak}',
                                  icon: Icons.local_fire_department,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  title: 'Study Time',
                                  value: _formatTime(userStats.totalStudyTime),
                                  icon: Icons.access_time,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  title: 'Sessions',
                                  value: '${userStats.totalSessions}',
                                  icon: Icons.play_circle,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Recent achievements with date fix
                _RecentAchievements(),

                const SizedBox(height: 16),

                // Action buttons
                _ActionButton(
                  icon: Icons.emoji_events,
                  title: 'Achievements',
                  subtitle: 'View all achievements',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AchievementsScreen()),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // About section
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.1),
                      width: 0.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // App Icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.school,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // App Name
                        Text(
                          'Studify',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                        ),
                        const SizedBox(height: 4),

                        // App Description
                        Text(
                          'Gamified Study Tracker',
                          style: TextStyle(
                            color: Colors.grey.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Developer Info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Made with Love by Satyam',
                              style: TextStyle(
                                color: Colors.grey.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Version Info
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              color: Colors.grey.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _getXPForNextLevel(int currentLevel) {
    return currentLevel * 500; // 500 XP per level to match UserStats model
  }

  double _getXPProgress(UserStats userStats) {
    final currentLevelXP = (userStats.currentLevel - 1) * 500;
    final nextLevelXP = userStats.currentLevel * 500;
    final progress =
        (userStats.totalXP - currentLevelXP) / (nextLevelXP - currentLevelXP);
    return progress.clamp(0.0, 1.0);
  }

  String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  void _showEditNameDialog(BuildContext context, UserStats userStats) {
    final controller = TextEditingController(text: userStats.userName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        title: const Text('Edit Name', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Your Name',
            labelStyle: TextStyle(color: Colors.grey.withOpacity(0.8)),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                userStats.userName = newName;
                userStats.save();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showXPTransactions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const XPTransactionsScreen()),
    );
  }

  void _exportData(BuildContext context) async {
    try {
      // Create backup data
      final backupData = await _createBackupData();

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
          '${directory.path}/studify_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonEncode(backupData));

      // Share the file
      await Share.shareXFiles([XFile(file.path)], text: 'Studify Backup Data');

      if (context.mounted) {
        final backupData = await _createBackupData();
        final totalItems = backupData['totalItems'] as Map<String, dynamic>;
        final itemCount = totalItems.values
            .fold<int>(0, (sum, count) => sum + (count as int));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '✅ Complete backup exported successfully!\n$itemCount items backed up'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>> _createBackupData() async {
    try {
      // Get all Hive boxes safely
      final userStatsBox = Hive.box<UserStats>('user_stats');
      final achievementsBox = Hive.box<Achievement>('achievements');
      final xpTransactionsBox = Hive.box<XPTransaction>('xp_transactions');

      // Try to get other boxes, create empty data if not available
      Box? syllabusGroupsBox;
      Box? studySessionsBox;
      Box? goalsBox;
      Box? examsBox;
      Box? dailyReportsBox;
      Box? subjectsBox;
      Box? settingsBox;

      try {
        syllabusGroupsBox = Hive.box<SyllabusGroup>('syllabus_groups');
      } catch (e) {
        print('syllabus_groups box not available');
      }
      try {
        studySessionsBox = Hive.box<StudySession>('study_sessions');
      } catch (e) {
        print('study_sessions box not available');
      }
      try {
        goalsBox = Hive.box<Goal>('goals');
      } catch (e) {
        print('goals box not available');
      }
      try {
        examsBox = Hive.box<Exam>('exams');
      } catch (e) {
        print('exams box not available');
      }
      try {
        dailyReportsBox = Hive.box<DailyStudyReport>('daily_reports');
      } catch (e) {
        print('daily_reports box not available');
      }
      try {
        subjectsBox = Hive.box<Subject>('subjects');
      } catch (e) {
        print('subjects box not available');
      }
      try {
        settingsBox = Hive.box('settings');
      } catch (e) {
        print('settings box not available');
      }

      return {
        // User progress and stats
        'userStats': _userStatsToJson(userStatsBox.get('user_stats')),
        'achievements':
            achievementsBox.values.map((a) => _achievementToJson(a)).toList(),
        'xpTransactions': xpTransactionsBox.values
            .map((t) => _xpTransactionToJson(t))
            .toList(),

        // Study data
        'studySessions': studySessionsBox?.values
                .map((s) => _studySessionToJson(s))
                .toList() ??
            [],
        'dailyReports': dailyReportsBox?.values
                .map((r) => _dailyReportToJson(r))
                .toList() ??
            [],

        // Syllabus and subjects
        'syllabusGroups': syllabusGroupsBox?.values
                .map((g) => _syllabusGroupToJson(g))
                .toList() ??
            [],
        'subjects':
            subjectsBox?.values.map((s) => _subjectToJson(s)).toList() ?? [],

        // Goals and exams
        'goals': goalsBox?.values.map((g) => _goalToJson(g)).toList() ?? [],
        'exams': examsBox?.values.map((e) => _examToJson(e)).toList() ?? [],

        // App settings
        'settings': settingsBox != null ? _settingsToJson(settingsBox) : {},

        // Backup metadata
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'backupType': 'complete',
        'totalItems': {
          'userStats': 1,
          'achievements': achievementsBox.length,
          'xpTransactions': xpTransactionsBox.length,
          'studySessions': studySessionsBox?.length ?? 0,
          'dailyReports': dailyReportsBox?.length ?? 0,
          'syllabusGroups': syllabusGroupsBox?.length ?? 0,
          'subjects': subjectsBox?.length ?? 0,
          'goals': goalsBox?.length ?? 0,
          'exams': examsBox?.length ?? 0,
        },
      };
    } catch (e) {
      print('Backup error: $e');
      // Return minimal backup if there's an error
      final userStatsBox = Hive.box<UserStats>('user_stats');
      final achievementsBox = Hive.box<Achievement>('achievements');
      final xpTransactionsBox = Hive.box<XPTransaction>('xp_transactions');

      return {
        'userStats': _userStatsToJson(userStatsBox.get('user_stats')),
        'achievements':
            achievementsBox.values.map((a) => _achievementToJson(a)).toList(),
        'xpTransactions': xpTransactionsBox.values
            .map((t) => _xpTransactionToJson(t))
            .toList(),
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'backupType': 'minimal',
        'totalItems': {
          'userStats': 1,
          'achievements': achievementsBox.length,
          'xpTransactions': xpTransactionsBox.length,
        },
      };
    }
  }

  Map<String, dynamic> _userStatsToJson(UserStats? stats) {
    if (stats == null) return {};
    return {
      'totalXP': stats.totalXP,
      'currentLevel': stats.currentLevel,
      'currentStreak': stats.currentStreak,
      'longestStreak': stats.longestStreak,
      'lastStudyDate': stats.lastStudyDate?.toIso8601String(),
      'totalStudyTime': stats.totalStudyTime,
      'totalSessions': stats.totalSessions,
      'pomodoroSessions': stats.pomodoroSessions,
      'createdAt': stats.createdAt.toIso8601String(),
      'unlockedAchievements': stats.unlockedAchievements,
      'userName': stats.userName,
      'freezeTokens': stats.freezeTokens,
      'lastFreezeTokenDate': stats.lastFreezeTokenDate?.toIso8601String(),
      'studyDates': stats.studyDates,
    };
  }

  Map<String, dynamic> _achievementToJson(Achievement achievement) {
    return {
      'id': achievement.id,
      'title': achievement.title,
      'description': achievement.description,
      'iconName': achievement.iconName,
      'xpReward': achievement.xpReward,
      'category': achievement.category,
      'isUnlocked': achievement.isUnlocked,
      'unlockedAt': achievement.unlockedAt?.toIso8601String(),
      'requirements': achievement.requirements,
    };
  }

  Map<String, dynamic> _xpTransactionToJson(XPTransaction transaction) {
    return {
      'id': transaction.id,
      'amount': transaction.amount,
      'reason': transaction.reason,
      'type': transaction.type,
      'timestamp': transaction.timestamp.toIso8601String(),
      'relatedId': transaction.relatedId,
    };
  }

  Map<String, dynamic> _studySessionToJson(dynamic session) {
    return {
      'id': session.id,
      'subjectId': session.subjectId,
      'startTime': session.startTime.toIso8601String(),
      'endTime': session.endTime.toIso8601String(),
      'duration': session.duration,
      'type': session.type,
      'xpEarned': session.xpEarned,
      'notes': session.notes,
      'isPomodoro': session.type == 'pomodoro',
      'isCompleted': session.isCompleted,
    };
  }

  Map<String, dynamic> _dailyReportToJson(dynamic report) {
    return {
      'id': report.id,
      'date': report.date.toIso8601String(),
      'totalStudyTime': report.totalStudyTime,
      'totalXP': report.totalXP,
      'sessionsCount': report.sessionsCount,
      'subjectData': report.subjectData
          ?.map((data) => {
                'subjectId': data.subjectId,
                'studyTime': data.studyTime,
                'xpEarned': data.xpEarned,
                'sessions': data.sessions
                    ?.map((session) => {
                          'startTime': session.startTime.toIso8601String(),
                          'endTime': session.endTime.toIso8601String(),
                          'duration': session.duration,
                          'xpEarned': session.xpEarned,
                        })
                    .toList(),
              })
          .toList(),
      'createdAt': report.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _syllabusGroupToJson(dynamic group) {
    return {
      'id': group.id,
      'name': group.name,
      'color': group.color,
      'subjects': group.subjects
          ?.map((subject) => {
                'id': subject.id,
                'name': subject.name,
                'chapters': subject.chapters
                    ?.map((chapter) => {
                          'id': chapter.id,
                          'name': chapter.name,
                          'isCompleted': chapter.isCompleted,
                          'completedAt': chapter.completedAt?.toIso8601String(),
                        })
                    .toList(),
              })
          .toList(),
      'createdAt': group.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _subjectToJson(dynamic subject) {
    return {
      'id': subject.id,
      'name': subject.name,
      'color': subject.color,
      'createdAt': subject.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _goalToJson(dynamic goal) {
    return {
      'id': goal.id,
      'title': goal.title,
      'description': goal.description,
      'subjectId': goal.subjectId,
      'targetHours': goal.targetHours,
      'currentHours': goal.currentHours,
      'targetDate': goal.targetDate.toIso8601String(),
      'isCompleted': goal.isCompleted,
      'completedAt': goal.completedAt?.toIso8601String(),
      'createdAt': goal.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _examToJson(dynamic exam) {
    return {
      'id': exam.id,
      'title': exam.title,
      'subjectId': exam.subjectId,
      'examDate': exam.examDate.toIso8601String(),
      'description': exam.description,
      'location': exam.location,
      'createdAt': exam.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _settingsToJson(dynamic settingsBox) {
    final settings = <String, dynamic>{};
    for (final key in settingsBox.keys) {
      settings[key] = settingsBox.get(key);
    }
    return settings;
  }

  void _importData(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        title: const Text('Import Data', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose import method:',
              style: TextStyle(color: Colors.grey.withOpacity(0.8)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.maxFinite,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _pickBackupFile(context);
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Backup File'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.maxFinite,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showPasteJsonDialog(context);
                },
                icon: const Icon(Icons.paste),
                label: const Text('Paste JSON Data'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _pickBackupFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        await _processImportedData(context, jsonString);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No file selected'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to pick file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPasteJsonDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        title: const Text('Paste JSON Data',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Paste your exported JSON data below:',
              style: TextStyle(color: Colors.grey.withOpacity(0.8)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                hintText: 'Paste JSON data here...',
                hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final jsonData = controller.text.trim();
              if (jsonData.isNotEmpty) {
                Navigator.of(context).pop();
                await _processImportedData(context, jsonData);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please paste JSON data first'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  Future<void> _processImportedData(
      BuildContext context, String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF0A0A0A),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Importing data...',
                style: TextStyle(color: Colors.grey.withOpacity(0.8)),
              ),
            ],
          ),
        ),
      );

      // Import user stats
      if (data['userStats'] != null) {
        final userStats = _userStatsFromJson(data['userStats']);
        await Hive.box<UserStats>('user_stats').put('user_stats', userStats);
      }

      // Import achievements
      if (data['achievements'] != null) {
        final achievementsBox = Hive.box<Achievement>('achievements');
        await achievementsBox.clear();
        for (final achievementData in data['achievements']) {
          final achievement = _achievementFromJson(achievementData);
          await achievementsBox.put(achievement.id, achievement);
        }
      }

      // Import XP transactions
      if (data['xpTransactions'] != null) {
        final xpTransactionsBox = Hive.box<XPTransaction>('xp_transactions');
        await xpTransactionsBox.clear();
        for (final transactionData in data['xpTransactions']) {
          final transaction = _xpTransactionFromJson(transactionData);
          await xpTransactionsBox.put(transaction.id, transaction);
        }
      }

      // Import study sessions
      if (data['studySessions'] != null) {
        try {
          final studySessionsBox = Hive.box<StudySession>('study_sessions');
          await studySessionsBox.clear();
          for (final sessionData in data['studySessions']) {
            final session = _studySessionFromJson(sessionData);
            await studySessionsBox.put(session.id, session);
          }
        } catch (e) {
          print('Failed to import study sessions: $e');
        }
      }

      // Import daily reports
      if (data['dailyReports'] != null) {
        try {
          final dailyReportsBox = Hive.box<DailyStudyReport>('daily_reports');
          await dailyReportsBox.clear();
          for (final reportData in data['dailyReports']) {
            final report = _dailyReportFromJson(reportData);
            await dailyReportsBox.put(report.id, report);
          }
        } catch (e) {
          print('Failed to import daily reports: $e');
        }
      }

      // Import syllabus groups
      if (data['syllabusGroups'] != null) {
        try {
          final syllabusGroupsBox = Hive.box<SyllabusGroup>('syllabus_groups');
          await syllabusGroupsBox.clear();
          for (final groupData in data['syllabusGroups']) {
            final group = _syllabusGroupFromJson(groupData);
            await syllabusGroupsBox.put(group.id, group);
          }
        } catch (e) {
          print('Failed to import syllabus groups: $e');
        }
      }

      // Import subjects
      if (data['subjects'] != null) {
        try {
          final subjectsBox = Hive.box<Subject>('subjects');
          await subjectsBox.clear();
          for (final subjectData in data['subjects']) {
            final subject = _subjectFromJson(subjectData);
            await subjectsBox.put(subject.id, subject);
          }
        } catch (e) {
          print('Failed to import subjects: $e');
        }
      }

      // Import goals
      if (data['goals'] != null) {
        try {
          final goalsBox = Hive.box<Goal>('goals');
          await goalsBox.clear();
          for (final goalData in data['goals']) {
            final goal = _goalFromJson(goalData);
            await goalsBox.put(goal.id, goal);
          }
        } catch (e) {
          print('Failed to import goals: $e');
        }
      }

      // Import exams
      if (data['exams'] != null) {
        try {
          final examsBox = Hive.box<Exam>('exams');
          await examsBox.clear();
          for (final examData in data['exams']) {
            final exam = _examFromJson(examData);
            await examsBox.put(exam.id, exam);
          }
        } catch (e) {
          print('Failed to import exams: $e');
        }
      }

      // Import settings
      if (data['settings'] != null) {
        try {
          final settingsBox = Hive.box('settings');
          await settingsBox.clear();
          for (final entry
              in (data['settings'] as Map<String, dynamic>).entries) {
            await settingsBox.put(entry.key, entry.value);
          }
        } catch (e) {
          print('Failed to import settings: $e');
        }
      }

      // Close progress dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        final totalItems = data['totalItems'] as Map<String, dynamic>?;
        final itemCount = totalItems?.values
                .fold<int>(0, (sum, count) => sum + (count as int)) ??
            0;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '✅ Complete backup imported successfully!\n$itemCount items restored'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Close progress dialog if open
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Import failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  UserStats _userStatsFromJson(Map<String, dynamic> json) {
    return UserStats(
      totalXP: json['totalXP'] ?? 0,
      currentLevel: json['currentLevel'] ?? 1,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastStudyDate: json['lastStudyDate'] != null
          ? DateTime.parse(json['lastStudyDate'])
          : null,
      totalStudyTime: json['totalStudyTime'] ?? 0,
      totalSessions: json['totalSessions'] ?? 0,
      pomodoroSessions: json['pomodoroSessions'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      unlockedAchievements:
          List<String>.from(json['unlockedAchievements'] ?? []),
      userName: json['userName'] ?? 'Student',
      freezeTokens: json['freezeTokens'] ?? 0,
      lastFreezeTokenDate: json['lastFreezeTokenDate'] != null
          ? DateTime.parse(json['lastFreezeTokenDate'])
          : null,
      studyDates: List<String>.from(json['studyDates'] ?? []),
    );
  }

  Achievement _achievementFromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconName: json['iconName'] ?? 'emoji_events',
      xpReward: json['xpReward'],
      category: json['category'],
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
      requirements: Map<String, dynamic>.from(json['requirements'] ?? {}),
    );
  }

  XPTransaction _xpTransactionFromJson(Map<String, dynamic> json) {
    return XPTransaction(
      id: json['id'],
      amount: json['amount'],
      reason: json['reason'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
      relatedId: json['relatedId'],
    );
  }

  StudySession _studySessionFromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'],
      subjectId: json['subjectId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      duration: json['duration'],
      type: json['isPomodoro'] == true ? 'pomodoro' : 'regular',
      notes: json['notes'],
      xpEarned: json['xpEarned'] ?? 0,
    );
  }

  DailyStudyReport _dailyReportFromJson(Map<String, dynamic> json) {
    return DailyStudyReport(
      id: json['id'],
      date: DateTime.parse(json['date']),
      subjectData: () {
        final subjectDataMap = <String, SubjectStudyData>{};
        if (json['subjectData'] != null) {
          for (final data in json['subjectData']) {
            final subjectData = SubjectStudyData(
              subjectId: data['subjectId'],
              subjectName: data['subjectName'] ?? '',
              totalTime: data['studyTime'] ?? 0,
              sessions: (data['sessions'] as List?)
                      ?.map((session) => StudySessionData(
                            startTime: DateTime.parse(session['startTime']),
                            duration: session['duration'],
                            chapterName: session['chapterName'],
                          ))
                      .toList() ??
                  [],
              chaptersStudied:
                  Map<String, int>.from(data['chaptersStudied'] ?? {}),
            );
            subjectDataMap[data['subjectId']] = subjectData;
          }
        }
        return subjectDataMap;
      }(),
      totalStudyTime: json['totalStudyTime'] ?? 0,
      totalSessions: json['sessionsCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  SyllabusGroup _syllabusGroupFromJson(Map<String, dynamic> json) {
    return SyllabusGroup(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      subjects: (json['subjects'] as List?)
              ?.map((subject) => SyllabusSubject(
                    id: subject['id'],
                    name: subject['name'],
                    description: subject['description'] ?? '',
                    chapters: (subject['chapters'] as List?)
                            ?.map((chapter) => SyllabusChapter(
                                  id: chapter['id'],
                                  name: chapter['name'],
                                  description: chapter['description'] ?? '',
                                  topics: List<String>.from(
                                      chapter['topics'] ?? []),
                                  createdAt: DateTime.now(),
                                  isCompleted: chapter['isCompleted'] ?? false,
                                ))
                            .toList() ??
                        [],
                    createdAt: DateTime.now(),
                  ))
              .toList() ??
          [],
      createdAt: DateTime.now(),
    );
  }

  Subject _subjectFromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      colorValue: json['colorValue'] ?? 0xFF1E88E5,
      createdAt: DateTime.now(),
    );
  }

  Goal _goalFromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      subjectId: json['subjectId'],
      targetDate: DateTime.parse(json['targetDate']),
      createdAt: DateTime.now(),
      targetHours: json['targetHours'],
      currentHours: json['currentHours'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Exam _examFromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      title: json['title'],
      subjectId: json['subjectId'],
      examDate: DateTime.parse(json['examDate']),
      description: json['description'],
      location: json['location'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.withOpacity(0.8),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey.withOpacity(0.6),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _RecentAchievements extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Achievement>('achievements').listenable(),
      builder: (context, Box<Achievement> box, _) {
        final achievements = box.values
            .where((achievement) => achievement.isUnlocked)
            .toList()
          ..sort((a, b) => b.unlockedAt!.compareTo(a.unlockedAt!));

        final recentAchievements = achievements.take(3).toList();

        if (recentAchievements.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 40,
                  color: Colors.grey.withOpacity(0.6),
                ),
                const SizedBox(height: 12),
                Text(
                  'No achievements yet',
                  style: TextStyle(
                    color: Colors.grey.withOpacity(0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Start studying to unlock achievements!',
                  style: TextStyle(
                    color: Colors.grey.withOpacity(0.6),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Achievements',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AchievementsScreen()),
                        );
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
              ...recentAchievements.map((achievement) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                achievement.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                achievement.description,
                                style: TextStyle(
                                  color: Colors.grey.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _formatAchievementDate(achievement.unlockedAt!),
                                style: TextStyle(
                                  color: Colors.grey.withOpacity(0.6),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+${achievement.xpReward} XP',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 4),
            ],
          ),
        );
      },
    );
  }

  String _formatAchievementDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
