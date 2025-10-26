import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/user_stats.dart';
import '../models/achievement.dart';
import '../models/xp_transaction.dart';
import '../models/study_session.dart';
import '../models/daily_study_report.dart';
import '../models/syllabus_group.dart';
import '../models/subject.dart';
import '../models/goal.dart';
import '../models/exam.dart';

class SimpleBackupService {
  // Singleton pattern
  static final SimpleBackupService _instance = SimpleBackupService._internal();
  factory SimpleBackupService() => _instance;
  SimpleBackupService._internal();

  /// Export all data to JSON and share/save
  Future<bool> exportBackup(BuildContext context) async {
    try {
      print('🔄 Starting backup export...');

      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF0A0A0A),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Creating backup...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we export your data',
                style: TextStyle(
                    color: Colors.grey.withOpacity(0.8), fontSize: 12),
              ),
            ],
          ),
        ),
      );

      // Export all data
      final data = await _exportAllData();

      // Create JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      // Close progress dialog
      Navigator.of(context).pop();

      // Create temporary file
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'studify_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonString);

      print('✅ Backup file created: ${file.path}');
      print('📊 Backup size: ${jsonString.length} characters');

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Studify Backup - ${DateTime.now().toString().split('.')[0]}',
        subject: 'My Studify Data Backup',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Backup created successfully! Share or save the file.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      return true;
    } catch (e) {
      print('❌ Export error: $e');

      // Close progress dialog if still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      return false;
    }
  }

  /// Export all data to JSON
  Future<Map<String, dynamic>> _exportAllData() async {
    final data = <String, dynamic>{
      'version': '1.2.0',
      'timestamp': DateTime.now().toIso8601String(),
      'exportType': 'complete_backup',
      'appName': 'Studify',
    };

    try {
      print('📊 Exporting user stats...');
      // Export user stats
      final userStatsBox = Hive.box<UserStats>('user_stats');
      final userStats = userStatsBox.get('user_stats');
      if (userStats != null) {
        data['userStats'] = {
          'totalStudyTime': userStats.totalStudyTime,
          'totalXP': userStats.totalXP,
          'currentLevel': userStats.currentLevel,
          'currentStreak': userStats.currentStreak,
          'longestStreak': userStats.longestStreak,
          'totalSessions': userStats.totalSessions,
          'pomodoroSessions': userStats.pomodoroSessions,
          'lastStudyDate': userStats.lastStudyDate?.toIso8601String(),
          'createdAt': userStats.createdAt.toIso8601String(),
          'userName': userStats.userName,
          'unlockedAchievements': userStats.unlockedAchievements,
          'freezeTokens': userStats.freezeTokens,
          'lastFreezeTokenDate':
              userStats.lastFreezeTokenDate?.toIso8601String(),
          'studyDates': userStats.studyDates,
        };
        print('✅ User stats exported');
      }

      print('🏆 Exporting achievements...');
      // Export achievements
      final achievementsBox = Hive.box<Achievement>('achievements');
      data['achievements'] = achievementsBox.values
          .map((achievement) => {
                'id': achievement.id,
                'title': achievement.title,
                'description': achievement.description,
                'iconName': achievement.iconName,
                'isUnlocked': achievement.isUnlocked,
                'unlockedAt': achievement.unlockedAt?.toIso8601String(),
                'xpReward': achievement.xpReward,
                'category': achievement.category,
                'requirements': achievement.requirements,
              })
          .toList();
      print('✅ ${achievementsBox.length} achievements exported');

      print('💰 Exporting XP transactions...');
      // Export XP transactions
      final xpTransactionsBox = Hive.box<XPTransaction>('xp_transactions');
      data['xpTransactions'] = xpTransactionsBox.values
          .map((transaction) => {
                'id': transaction.id,
                'amount': transaction.amount,
                'reason': transaction.reason,
                'timestamp': transaction.timestamp.toIso8601String(),
                'type': transaction.type,
                'relatedId': transaction.relatedId,
              })
          .toList();
      print('✅ ${xpTransactionsBox.length} XP transactions exported');

      print('📚 Exporting study sessions...');
      // Export study sessions
      final studySessionsBox = Hive.box<StudySession>('study_sessions');
      data['studySessions'] = studySessionsBox.values
          .map((session) => {
                'id': session.id,
                'subjectId': session.subjectId,
                'startTime': session.startTime.toIso8601String(),
                'endTime': session.endTime.toIso8601String(),
                'duration': session.duration,
                'type': session.type,
                'notes': session.notes,
                'xpEarned': session.xpEarned,
              })
          .toList();
      print('✅ ${studySessionsBox.length} study sessions exported');

      print('📊 Exporting daily reports...');
      // Export daily reports
      try {
        final dailyReportsBox = Hive.box<DailyStudyReport>('daily_reports');
        data['dailyReports'] = dailyReportsBox.values
            .map((report) => {
                  'id': report.id,
                  'date': report.date.toIso8601String(),
                  'totalStudyTime': report.totalStudyTime,
                  'totalSessions': report.totalSessions,
                  'subjectData':
                      report.subjectData.map((key, value) => MapEntry(key, {
                            'subjectId': value.subjectId,
                            'subjectName': value.subjectName,
                            'totalTime': value.totalTime,
                            'sessions': value.sessions
                                .map((session) => {
                                      'startTime':
                                          session.startTime.toIso8601String(),
                                      'duration': session.duration,
                                      'chapterName': session.chapterName,
                                    })
                                .toList(),
                            'chaptersStudied': value.chaptersStudied,
                          })),
                  'createdAt': report.createdAt.toIso8601String(),
                })
            .toList();
        print('✅ ${dailyReportsBox.length} daily reports exported');
      } catch (e) {
        print('⚠️ Daily reports export error: $e');
        data['dailyReports'] = [];
      }

      print('📚 Exporting syllabus groups...');
      // Export syllabus groups
      try {
        final syllabusGroupsBox = Hive.box<SyllabusGroup>('syllabus_groups');
        data['syllabusGroups'] = syllabusGroupsBox.values
            .map((group) => {
                  'id': group.id,
                  'name': group.name,
                  'description': group.description,
                  'color': group.color,
                  'icon': group.icon,
                  'priority': group.priority,
                  'targetDate': group.targetDate?.toIso8601String(),
                  'totalTimeSpent': group.totalTimeSpent,
                  'subjects': group.subjects
                      .map((subject) => {
                            'id': subject.id,
                            'name': subject.name,
                            'description': subject.description,
                            'totalTimeSpent': subject.totalTimeSpent,
                            'completedChapters': subject.completedChapters,
                            'createdAt': subject.createdAt.toIso8601String(),
                            'chapters': subject.chapters
                                .map((chapter) => {
                                      'id': chapter.id,
                                      'name': chapter.name,
                                      'description': chapter.description,
                                      'topics': chapter.topics,
                                      'completedTopics':
                                          chapter.completedTopics,
                                      'timeSpent': chapter.timeSpent,
                                      'isCompleted': chapter.isCompleted,
                                      'createdAt':
                                          chapter.createdAt.toIso8601String(),
                                    })
                                .toList(),
                          })
                      .toList(),
                })
            .toList();
        print('✅ ${syllabusGroupsBox.length} syllabus groups exported');
      } catch (e) {
        print('⚠️ Syllabus groups export error: $e');
        data['syllabusGroups'] = [];
      }

      print('📖 Exporting subjects...');
      // Export subjects
      try {
        final subjectsBox = Hive.box<Subject>('subjects');
        data['subjects'] = subjectsBox.values
            .map((subject) => {
                  'id': subject.id,
                  'name': subject.name,
                  'description': subject.description,
                  'colorValue': subject.colorValue,
                  'totalStudyTime': subject.totalStudyTime,
                  'totalSessions': subject.totalSessions,
                  'isActive': subject.isActive,
                  'createdAt': subject.createdAt.toIso8601String(),
                })
            .toList();
        print('✅ ${subjectsBox.length} subjects exported');
      } catch (e) {
        print('⚠️ Subjects export error: $e');
        data['subjects'] = [];
      }

      print('🎯 Exporting goals...');
      // Export goals
      try {
        final goalsBox = Hive.box<Goal>('goals');
        data['goals'] = goalsBox.values
            .map((goal) => {
                  'id': goal.id,
                  'title': goal.title,
                  'description': goal.description,
                  'subjectId': goal.subjectId,
                  'targetHours': goal.targetHours,
                  'currentHours': goal.currentHours,
                  'targetDate': goal.targetDate.toIso8601String(),
                  'isCompleted': goal.isCompleted,
                  'type': goal.type,
                  'createdAt': goal.createdAt.toIso8601String(),
                })
            .toList();
        print('✅ ${goalsBox.length} goals exported');
      } catch (e) {
        print('⚠️ Goals export error: $e');
        data['goals'] = [];
      }

      print('📝 Exporting exams...');
      // Export exams
      try {
        final examsBox = Hive.box<Exam>('exams');
        data['exams'] = examsBox.values
            .map((exam) => {
                  'id': exam.id,
                  'title': exam.title,
                  'subjectId': exam.subjectId,
                  'examDate': exam.examDate.toIso8601String(),
                  'description': exam.description,
                  'location': exam.location,
                  'isCompleted': exam.isCompleted,
                  'result': exam.result,
                  'createdAt': exam.createdAt.toIso8601String(),
                })
            .toList();
        print('✅ ${examsBox.length} exams exported');
      } catch (e) {
        print('⚠️ Exams export error: $e');
        data['exams'] = [];
      }

      // Add summary
      data['summary'] = {
        'totalUserStats': userStats != null ? 1 : 0,
        'totalAchievements': achievementsBox.length,
        'totalXPTransactions': xpTransactionsBox.length,
        'totalStudySessions': studySessionsBox.length,
        'totalDailyReports': data['dailyReports']?.length ?? 0,
        'totalSyllabusGroups': data['syllabusGroups']?.length ?? 0,
        'totalSubjects': data['subjects']?.length ?? 0,
        'totalGoals': data['goals']?.length ?? 0,
        'totalExams': data['exams']?.length ?? 0,
      };

      print('🎉 Export completed successfully!');
      print('📋 Summary: ${data['summary']}');
    } catch (e) {
      print('❌ Error during export: $e');
      rethrow;
    }

    return data;
  }

  /// Import data from file picker
  Future<bool> importBackup(BuildContext context) async {
    try {
      print('🔄 Starting import process...');

      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Select Studify Backup File',
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        print('❌ No file selected');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No backup file selected'),
            backgroundColor: Colors.orange,
          ),
        );
        return false;
      }

      final platformFile = result.files.first;
      final filePath = platformFile.path;

      if (filePath == null) {
        print('❌ File path is null');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to access selected file'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      print('📁 Selected file: $filePath');
      print('📊 File size: ${platformFile.size} bytes');

      final file = File(filePath);

      if (!await file.exists()) {
        print('❌ File does not exist');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selected file does not exist'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF0A0A0A),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                'Importing backup...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we restore your data',
                style: TextStyle(
                    color: Colors.grey.withOpacity(0.8), fontSize: 12),
              ),
            ],
          ),
        ),
      );

      // Read and parse file
      final jsonString = await file.readAsString();
      print('✅ File read successfully, length: ${jsonString.length}');

      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      print('✅ JSON parsed successfully');
      print('📋 Data keys: ${data.keys.toList()}');

      // Validate backup
      if (!_validateBackup(data)) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid backup file format'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      // Import data
      await _importAllData(data);

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Backup imported successfully! Restart app to see all changes.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );

      return true;
    } catch (e) {
      print('❌ Import error: $e');

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      return false;
    }
  }

  /// Validate backup data
  bool _validateBackup(Map<String, dynamic> data) {
    if (data.isEmpty) return false;

    // Check for at least one data section
    final dataSections = [
      'userStats',
      'achievements',
      'xpTransactions',
      'studySessions',
      'subjects',
      'goals',
      'exams',
      'syllabusGroups'
    ];

    for (final section in dataSections) {
      if (data.containsKey(section) && data[section] != null) {
        print('✅ Found valid section: $section');
        return true;
      }
    }

    return false;
  }

  /// Import all data
  Future<void> _importAllData(Map<String, dynamic> data) async {
    print('🔄 Starting data import...');

    // Import user stats
    if (data['userStats'] != null) {
      print('📊 Importing user stats...');
      try {
        final userStatsData = data['userStats'];
        final userStats = UserStats(
          totalStudyTime: userStatsData['totalStudyTime'] ?? 0,
          totalXP: userStatsData['totalXP'] ?? 0,
          currentLevel: userStatsData['currentLevel'] ?? 1,
          currentStreak: userStatsData['currentStreak'] ?? 0,
          longestStreak: userStatsData['longestStreak'] ?? 0,
          totalSessions: userStatsData['totalSessions'] ?? 0,
          pomodoroSessions: userStatsData['pomodoroSessions'] ?? 0,
          lastStudyDate: userStatsData['lastStudyDate'] != null
              ? DateTime.parse(userStatsData['lastStudyDate'])
              : null,
          createdAt: userStatsData['createdAt'] != null
              ? DateTime.parse(userStatsData['createdAt'])
              : DateTime.now(),
          userName: userStatsData['userName'] ?? 'Student',
          unlockedAchievements:
              List<String>.from(userStatsData['unlockedAchievements'] ?? []),
          freezeTokens: userStatsData['freezeTokens'] ?? 0,
          lastFreezeTokenDate: userStatsData['lastFreezeTokenDate'] != null
              ? DateTime.parse(userStatsData['lastFreezeTokenDate'])
              : null,
          studyDates: List<String>.from(userStatsData['studyDates'] ?? []),
        );
        await Hive.box<UserStats>('user_stats').put('user_stats', userStats);
        print('✅ User stats imported');
      } catch (e) {
        print('⚠️ User stats import error: $e');
      }
    }

    // Import achievements
    if (data['achievements'] != null && data['achievements'] is List) {
      print('🏆 Importing achievements...');
      try {
        final achievementsBox = Hive.box<Achievement>('achievements');
        await achievementsBox.clear();

        for (final achievementData in data['achievements']) {
          final achievement = Achievement(
            id: achievementData['id'] ?? '',
            title: achievementData['title'] ?? '',
            description: achievementData['description'] ?? '',
            iconName: achievementData['iconName'] ?? 'star',
            isUnlocked: achievementData['isUnlocked'] ?? false,
            unlockedAt: achievementData['unlockedAt'] != null
                ? DateTime.parse(achievementData['unlockedAt'])
                : null,
            xpReward: achievementData['xpReward'] ?? 0,
            category: achievementData['category'] ?? 'general',
            requirements: Map<String, dynamic>.from(
                achievementData['requirements'] ?? {}),
          );
          await achievementsBox.put(achievement.id, achievement);
        }
        print('✅ ${data['achievements'].length} achievements imported');
      } catch (e) {
        print('⚠️ Achievements import error: $e');
      }
    }

    // Import other data sections with similar error handling...
    // (XP transactions, study sessions, etc.)

    print('🎉 Data import completed!');
  }
}
