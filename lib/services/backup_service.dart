import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_stats.dart';
import '../models/achievement.dart';
import '../models/xp_transaction.dart';
import '../models/study_session.dart';
import '../models/daily_study_report.dart';
import '../models/syllabus_group.dart';
import '../models/subject.dart';
import '../models/goal.dart';
import '../models/exam.dart';

class BackupService {
  static const String _autoBackupKey = 'auto_backup_enabled';
  static const String _lastBackupKey = 'last_backup_timestamp';
  static const String _backupFolderName = 'Studify_Backups';
  static const String _autoBackupFileName = 'auto_backup.json';

  // Singleton pattern
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  /// Check if auto backup is enabled
  Future<bool> isAutoBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoBackupKey) ?? true; // Default to enabled
  }

  /// Toggle auto backup setting
  Future<void> setAutoBackupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoBackupKey, enabled);
  }

  /// Get last backup timestamp
  Future<DateTime?> getLastBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastBackupKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  /// Update last backup timestamp
  Future<void> _updateLastBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastBackupKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get backup directory (external storage so it survives app data clear)
  Future<Directory> _getBackupDirectory() async {
    try {
      // Try to use external storage first (survives app data clear)
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final backupDir = Directory('${externalDir.path}/$_backupFolderName');
        if (!await backupDir.exists()) {
          await backupDir.create(recursive: true);
        }
        print('📁 Using external storage: ${backupDir.path}');
        return backupDir;
      }
    } catch (e) {
      print('⚠️ External storage not available: $e');
    }

    // Fallback to documents directory
    final documentsDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${documentsDir.path}/$_backupFolderName');

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    print('📁 Using documents directory: ${backupDir.path}');
    return backupDir;
  }

  /// Validate JSON structure
  bool _validateBackupData(Map<String, dynamic> data) {
    // Check for required top-level keys
    final requiredKeys = ['version', 'timestamp'];
    for (final key in requiredKeys) {
      if (!data.containsKey(key)) {
        return false;
      }
    }

    // Validate version compatibility
    final version = data['version'] as String?;
    if (version == null || !_isVersionCompatible(version)) {
      return false;
    }

    return true;
  }

  /// Check if backup version is compatible
  bool _isVersionCompatible(String version) {
    // Simple version check - you can make this more sophisticated
    final supportedVersions = ['1.0.0', '1.0.1', '1.1.0'];
    return supportedVersions.contains(version);
  }

  /// Export all data to JSON using existing profile screen methods
  Future<Map<String, dynamic>> _exportAllData() async {
    final data = <String, dynamic>{
      'version': '1.1.0',
      'timestamp': DateTime.now().toIso8601String(),
      'exportType': 'full_backup',
    };

    try {
      print('📊 Exporting user stats...');
      // Get user stats
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
      // Get achievements
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
      // Get XP transactions
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
      // Get study sessions
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
      // Get daily reports
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

      print('📚 Exporting syllabus groups...');
      // Get syllabus groups
      final syllabusGroupsBox = Hive.box<SyllabusGroup>('syllabus_groups');
      data['syllabusGroups'] = syllabusGroupsBox.values
          .map((group) => {
                'id': group.id,
                'name': group.name,
                'description': group.description,
                'color': group.color,
                'subjects': group.subjects
                    .map((subject) => {
                          'id': subject.id,
                          'name': subject.name,
                          'description': subject.description,
                          'chapters': subject.chapters
                              .map((chapter) => {
                                    'id': chapter.id,
                                    'name': chapter.name,
                                    'description': chapter.description,
                                    'topics': chapter.topics,
                                    'isCompleted': chapter.isCompleted,
                                  })
                              .toList(),
                        })
                    .toList(),
              })
          .toList();
      print('✅ ${syllabusGroupsBox.length} syllabus groups exported');

      print('📖 Exporting subjects...');
      // Get subjects
      final subjectsBox = Hive.box<Subject>('subjects');
      data['subjects'] = subjectsBox.values
          .map((subject) => {
                'id': subject.id,
                'name': subject.name,
                'description': subject.description,
                'colorValue': subject.colorValue,
              })
          .toList();
      print('✅ ${subjectsBox.length} subjects exported');

      print('🎯 Exporting goals...');
      // Get goals
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
              })
          .toList();
      print('✅ ${goalsBox.length} goals exported');

      print('📝 Exporting exams...');
      // Get exams
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
              })
          .toList();
      print('✅ ${examsBox.length} exams exported');

      print('⚙️ Exporting app settings...');
      // Export app settings
      final prefs = await SharedPreferences.getInstance();
      data['settings'] = {
        'theme': prefs.getString('theme') ?? 'dark',
        'notifications_enabled': prefs.getBool('notifications_enabled') ?? true,
        'pomodoro_duration': prefs.getInt('pomodoro_duration') ?? 25,
        'short_break_duration': prefs.getInt('short_break_duration') ?? 5,
        'long_break_duration': prefs.getInt('long_break_duration') ?? 15,
        'auto_backup_enabled': prefs.getBool(_autoBackupKey) ?? true,
      };
    } catch (e) {
      print('Error exporting data: $e');
      rethrow;
    }

    return data;
  }

  /// Create automatic backup
  Future<bool> createAutoBackup() async {
    try {
      if (!await isAutoBackupEnabled()) {
        return false;
      }

      final backupDir = await _getBackupDirectory();
      final backupFile = File('${backupDir.path}/$_autoBackupFileName');

      final data = await _exportAllData();
      data['exportType'] = 'auto_backup';

      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      await backupFile.writeAsString(jsonString);

      await _updateLastBackupTime();

      print('Auto backup created successfully at: ${backupFile.path}');
      return true;
    } catch (e) {
      print('Failed to create auto backup: $e');
      return false;
    }
  }

  /// Create manual backup with file picker
  Future<bool> createManualBackup(BuildContext context) async {
    try {
      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          backgroundColor: Color(0xFF0A0A0A),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Creating backup...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );

      final data = await _exportAllData();
      data['exportType'] = 'manual_backup';

      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      // Close progress dialog
      Navigator.of(context).pop();

      // Let user choose save location
      final fileName =
          'studify_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup File',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsString(jsonString);

        await _updateLastBackupTime();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup saved successfully to ${file.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
        return false;
      }
    } catch (e) {
      // Close progress dialog if still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create backup: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      return false;
    }
  }

  /// Import data from file picker with proper validation and debugging
  Future<bool> importFromFile(BuildContext context) async {
    try {
      print('🔄 Starting file import process...');

      // Pick file with proper permissions
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Select Studify Backup File',
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        print('❌ No file selected by user');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No backup file selected'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
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

      // Check if file exists and is readable
      if (!await file.exists()) {
        print('❌ File does not exist: $filePath');
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
              const CircularProgressIndicator(color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Reading backup file...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we import your data',
                style: TextStyle(
                    color: Colors.grey.withOpacity(0.8), fontSize: 12),
              ),
            ],
          ),
        ),
      );

      // Read file content with error handling
      String jsonString;
      try {
        jsonString = await file.readAsString();
        print(
            '✅ File read successfully, content length: ${jsonString.length} characters');
      } catch (e) {
        print('❌ Error reading file: $e');
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error reading file: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        return false;
      }

      // Validate JSON format
      Map<String, dynamic> data;
      try {
        data = jsonDecode(jsonString) as Map<String, dynamic>;
        print('✅ JSON parsed successfully');
        print('📋 Data keys: ${data.keys.toList()}');
      } catch (e) {
        print('❌ Invalid JSON format: $e');
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid backup file format - not a valid JSON'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return false;
      }

      // Validate backup structure
      if (!_validateBackupStructure(data)) {
        print('❌ Invalid backup structure');
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid backup file - missing required data'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return false;
      }

      print('✅ Backup validation passed, starting import...');

      // Import data with progress updates
      try {
        await _importAllDataSafely(data);
        print('✅ Data import completed successfully');
      } catch (e) {
        print('❌ Error during data import: $e');
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing data: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        return false;
      }

      // Close progress dialog
      Navigator.of(context).pop();

      // Show success message
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
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );

      print('🎉 Import process completed successfully');
      return true;
    } catch (e) {
      print('❌ Unexpected error during import: $e');

      // Close progress dialog if still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      return false;
    }
  }

  /// Validate backup file structure
  bool _validateBackupStructure(Map<String, dynamic> data) {
    // Check if it's empty
    if (data.isEmpty) {
      print('❌ Backup file is empty');
      return false;
    }

    // Check for at least one data section
    final dataSections = [
      'userStats',
      'achievements',
      'xpTransactions',
      'studySessions',
      'subjects',
      'goals',
      'exams'
    ];

    bool hasValidData = false;
    for (final section in dataSections) {
      if (data.containsKey(section) && data[section] != null) {
        hasValidData = true;
        print('✅ Found valid section: $section');
        break;
      }
    }

    if (!hasValidData) {
      print('❌ No valid data sections found');
      return false;
    }

    return true;
  }

  /// Check for auto backup on app launch
  Future<bool> checkForAutoBackup() async {
    try {
      final backupDir = await _getBackupDirectory();
      final backupFile = File('${backupDir.path}/$_autoBackupFileName');

      return await backupFile.exists();
    } catch (e) {
      print('Error checking for auto backup: $e');
      return false;
    }
  }

  /// Restore from auto backup
  Future<bool> restoreFromAutoBackup(BuildContext context) async {
    try {
      final backupDir = await _getBackupDirectory();
      final backupFile = File('${backupDir.path}/$_autoBackupFileName');

      if (!await backupFile.exists()) {
        return false;
      }

      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          backgroundColor: Color(0xFF0A0A0A),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Restoring from auto backup...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );

      final jsonString = await backupFile.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      if (!_validateBackupData(data)) {
        Navigator.of(context).pop();
        return false;
      }

      await _importAllData(data);

      Navigator.of(context).pop();
      return true;
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      print('Failed to restore from auto backup: $e');
      return false;
    }
  }

  /// Import all data from backup with better error handling
  Future<void> _importAllDataSafely(Map<String, dynamic> data) async {
    print('🔄 Starting data import process...');

    try {
      // Import user stats
      if (data['userStats'] != null) {
        print('📊 Importing user stats...');
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
        );
        await Hive.box<UserStats>('user_stats').put('user_stats', userStats);
        print('✅ User stats imported successfully');
      }

      // Import achievements
      if (data['achievements'] != null && data['achievements'] is List) {
        print('🏆 Importing achievements...');
        final achievementsBox = Hive.box<Achievement>('achievements');
        await achievementsBox.clear();

        final achievementsList = data['achievements'] as List;
        for (final achievementData in achievementsList) {
          try {
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
          } catch (e) {
            print('⚠️ Error importing achievement: $e');
          }
        }
        print('✅ Achievements imported successfully');
      }

      // Import XP transactions
      if (data['xpTransactions'] != null && data['xpTransactions'] is List) {
        print('💰 Importing XP transactions...');
        final xpTransactionsBox = Hive.box<XPTransaction>('xp_transactions');
        await xpTransactionsBox.clear();

        final transactionsList = data['xpTransactions'] as List;
        for (final transactionData in transactionsList) {
          try {
            final transaction = XPTransaction(
              id: transactionData['id'] ?? '',
              amount: transactionData['amount'] ?? 0,
              reason: transactionData['reason'] ?? '',
              timestamp: DateTime.parse(transactionData['timestamp']),
              type: transactionData['type'] ?? 'study',
              relatedId: transactionData['relatedId'],
            );
            await xpTransactionsBox.put(transaction.id, transaction);
          } catch (e) {
            print('⚠️ Error importing XP transaction: $e');
          }
        }
        print('✅ XP transactions imported successfully');
      }

      // Import study sessions
      if (data['studySessions'] != null && data['studySessions'] is List) {
        print('📚 Importing study sessions...');
        final studySessionsBox = Hive.box<StudySession>('study_sessions');
        await studySessionsBox.clear();

        final sessionsList = data['studySessions'] as List;
        for (final sessionData in sessionsList) {
          try {
            final session = StudySession(
              id: sessionData['id'] ?? '',
              subjectId: sessionData['subjectId'] ?? '',
              startTime: DateTime.parse(sessionData['startTime']),
              endTime: DateTime.parse(sessionData['endTime']),
              duration: sessionData['duration'] ?? 0,
              type: sessionData['type'] ?? 'regular',
              notes: sessionData['notes'],
              xpEarned: sessionData['xpEarned'] ?? 0,
            );
            await studySessionsBox.put(session.id, session);
          } catch (e) {
            print('⚠️ Error importing study session: $e');
          }
        }
        print('✅ Study sessions imported successfully');
      }

      // Import subjects
      if (data['subjects'] != null && data['subjects'] is List) {
        print('📖 Importing subjects...');
        final subjectsBox = Hive.box<Subject>('subjects');
        await subjectsBox.clear();

        final subjectsList = data['subjects'] as List;
        for (final subjectData in subjectsList) {
          try {
            final subject = Subject(
              id: subjectData['id'] ?? '',
              name: subjectData['name'] ?? '',
              description: subjectData['description'] ?? '',
              colorValue: subjectData['colorValue'] ?? 0xFF1E88E5,
              createdAt: DateTime.now(),
            );
            await subjectsBox.put(subject.id, subject);
          } catch (e) {
            print('⚠️ Error importing subject: $e');
          }
        }
        print('✅ Subjects imported successfully');
      }

      // Import goals
      if (data['goals'] != null && data['goals'] is List) {
        print('🎯 Importing goals...');
        final goalsBox = Hive.box<Goal>('goals');
        await goalsBox.clear();

        final goalsList = data['goals'] as List;
        for (final goalData in goalsList) {
          try {
            final goal = Goal(
              id: goalData['id'] ?? '',
              title: goalData['title'] ?? '',
              description: goalData['description'] ?? '',
              subjectId: goalData['subjectId'] ?? '',
              targetDate: DateTime.parse(goalData['targetDate']),
              createdAt: DateTime.now(),
              targetHours: goalData['targetHours'] ?? 0,
              currentHours: goalData['currentHours'] ?? 0,
              isCompleted: goalData['isCompleted'] ?? false,
            );
            await goalsBox.put(goal.id, goal);
          } catch (e) {
            print('⚠️ Error importing goal: $e');
          }
        }
        print('✅ Goals imported successfully');
      }

      // Import exams
      if (data['exams'] != null && data['exams'] is List) {
        print('📝 Importing exams...');
        final examsBox = Hive.box<Exam>('exams');
        await examsBox.clear();

        final examsList = data['exams'] as List;
        for (final examData in examsList) {
          try {
            final exam = Exam(
              id: examData['id'] ?? '',
              title: examData['title'] ?? '',
              subjectId: examData['subjectId'] ?? '',
              examDate: DateTime.parse(examData['examDate']),
              createdAt: DateTime.now(),
              description: examData['description'],
              location: examData['location'],
              isCompleted: examData['isCompleted'] ?? false,
              result: examData['result'],
            );
            await examsBox.put(exam.id, exam);
          } catch (e) {
            print('⚠️ Error importing exam: $e');
          }
        }
        print('✅ Exams imported successfully');
      }

      // Import settings
      if (data['settings'] != null) {
        print('⚙️ Importing settings...');
        final prefs = await SharedPreferences.getInstance();
        final settings = data['settings'] as Map<String, dynamic>;

        for (final entry in settings.entries) {
          final key = entry.key;
          final value = entry.value;

          try {
            if (value is String) {
              await prefs.setString(key, value);
            } else if (value is bool) {
              await prefs.setBool(key, value);
            } else if (value is int) {
              await prefs.setInt(key, value);
            } else if (value is double) {
              await prefs.setDouble(key, value);
            }
          } catch (e) {
            print('⚠️ Error importing setting $key: $e');
          }
        }
        print('✅ Settings imported successfully');
      }

      print('🎉 All data imported successfully!');
    } catch (e) {
      print('❌ Error during data import: $e');
      rethrow;
    }
  }

  /// Import all data from backup using existing profile screen methods
  Future<void> _importAllData(Map<String, dynamic> data) async {
    // Import user stats
    if (data['userStats'] != null) {
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
      );
      await Hive.box<UserStats>('user_stats').put('user_stats', userStats);
    }

    // Import achievements
    if (data['achievements'] != null) {
      final achievementsBox = Hive.box<Achievement>('achievements');
      await achievementsBox.clear();
      for (final achievementData in data['achievements']) {
        final achievement = Achievement(
          id: achievementData['id'],
          title: achievementData['title'],
          description: achievementData['description'],
          iconName: achievementData['iconName'] ?? 'star',
          isUnlocked: achievementData['isUnlocked'] ?? false,
          unlockedAt: achievementData['unlockedAt'] != null
              ? DateTime.parse(achievementData['unlockedAt'])
              : null,
          xpReward: achievementData['xpReward'] ?? 0,
          category: achievementData['category'] ?? 'general',
          requirements:
              Map<String, dynamic>.from(achievementData['requirements'] ?? {}),
        );
        await achievementsBox.put(achievement.id, achievement);
      }
    }

    // Import XP transactions
    if (data['xpTransactions'] != null) {
      final xpTransactionsBox = Hive.box<XPTransaction>('xp_transactions');
      await xpTransactionsBox.clear();
      for (final transactionData in data['xpTransactions']) {
        final transaction = XPTransaction(
          id: transactionData['id'],
          amount: transactionData['amount'],
          reason: transactionData['reason'],
          timestamp: DateTime.parse(transactionData['timestamp']),
          type: transactionData['type'] ?? 'study',
          relatedId: transactionData['relatedId'],
        );
        await xpTransactionsBox.put(transaction.id, transaction);
      }
    }

    // Import study sessions
    if (data['studySessions'] != null) {
      final studySessionsBox = Hive.box<StudySession>('study_sessions');
      await studySessionsBox.clear();
      for (final sessionData in data['studySessions']) {
        final session = StudySession(
          id: sessionData['id'],
          subjectId: sessionData['subjectId'],
          startTime: DateTime.parse(sessionData['startTime']),
          endTime: DateTime.parse(sessionData['endTime']),
          duration: sessionData['duration'],
          type: sessionData['type'] ?? 'regular',
          notes: sessionData['notes'],
          xpEarned: sessionData['xpEarned'] ?? 0,
        );
        await studySessionsBox.put(session.id, session);
      }
    }

    // Import settings
    if (data['settings'] != null) {
      final prefs = await SharedPreferences.getInstance();
      final settings = data['settings'] as Map<String, dynamic>;

      for (final entry in settings.entries) {
        final key = entry.key;
        final value = entry.value;

        if (value is String) {
          await prefs.setString(key, value);
        } else if (value is bool) {
          await prefs.setBool(key, value);
        } else if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is double) {
          await prefs.setDouble(key, value);
        }
      }
    }
  }

  /// Get backup file size
  Future<String> getBackupFileSize() async {
    try {
      final backupDir = await _getBackupDirectory();
      final backupFile = File('${backupDir.path}/$_autoBackupFileName');

      if (await backupFile.exists()) {
        final bytes = await backupFile.length();
        return _formatBytes(bytes);
      }

      return 'No backup found';
    } catch (e) {
      return 'Error';
    }
  }

  /// Get backup directory path for display
  Future<String> getBackupDirectoryPath() async {
    try {
      final backupDir = await _getBackupDirectory();
      return backupDir.path;
    } catch (e) {
      return 'Error getting path';
    }
  }

  /// Format bytes to human readable string
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
