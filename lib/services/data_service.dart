import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/study_session.dart';
import '../models/subject.dart';
import '../models/goal.dart';
import '../models/exam.dart';
import '../models/user_stats.dart';
import '../models/achievement.dart';
import '../models/syllabus_group.dart';
import '../models/xp_transaction.dart';
import '../models/daily_study_report.dart';

class DataService {
  static const String _backupFileName = 'brostud_backup.json';

  // Export all data to JSON
  static Future<Map<String, dynamic>> exportData() async {
    final studySessionsBox = Hive.box<StudySession>('study_sessions');
    final subjectsBox = Hive.box<Subject>('subjects');
    final goalsBox = Hive.box<Goal>('goals');
    final examsBox = Hive.box<Exam>('exams');
    final userStatsBox = Hive.box<UserStats>('user_stats');
    final achievementsBox = Hive.box<Achievement>('achievements');
    final syllabusGroupsBox = Hive.box<SyllabusGroup>('syllabus_groups');
    final xpTransactionsBox = Hive.box<XPTransaction>('xp_transactions');
    final dailyReportsBox = Hive.box<DailyStudyReport>('daily_reports');
    final settingsBox = Hive.box('settings');

    return {
      'version': '1.0.0',
      'exportDate': DateTime.now().toIso8601String(),
      'studySessions': studySessionsBox.values
          .map((session) => {
                'id': session.id,
                'subjectId': session.subjectId,
                'startTime': session.startTime.toIso8601String(),
                'endTime': session.endTime.toIso8601String(),
                'duration': session.duration,
                'type': session.type,
                'notes': session.notes,
                'xpEarned': session.xpEarned,
                'isCompleted': session.isCompleted,
              })
          .toList(),
      'subjects': subjectsBox.values
          .map((subject) => {
                'id': subject.id,
                'name': subject.name,
                'description': subject.description,
                'colorValue': subject.colorValue,
                'createdAt': subject.createdAt.toIso8601String(),
                'totalStudyTime': subject.totalStudyTime,
                'totalSessions': subject.totalSessions,
                'isActive': subject.isActive,
              })
          .toList(),
      'goals': goalsBox.values
          .map((goal) => {
                'id': goal.id,
                'title': goal.title,
                'description': goal.description,
                'subjectId': goal.subjectId,
                'targetDate': goal.targetDate.toIso8601String(),
                'createdAt': goal.createdAt.toIso8601String(),
                'targetHours': goal.targetHours,
                'currentHours': goal.currentHours,
                'isCompleted': goal.isCompleted,
                'type': goal.type,
              })
          .toList(),
      'exams': examsBox.values
          .map((exam) => {
                'id': exam.id,
                'title': exam.title,
                'subjectId': exam.subjectId,
                'examDate': exam.examDate.toIso8601String(),
                'createdAt': exam.createdAt.toIso8601String(),
                'description': exam.description,
                'location': exam.location,
                'isCompleted': exam.isCompleted,
                'result': exam.result,
              })
          .toList(),
      'userStats': userStatsBox.isNotEmpty
          ? {
              'totalXP': userStatsBox.getAt(0)?.totalXP ?? 0,
              'currentLevel': userStatsBox.getAt(0)?.currentLevel ?? 1,
              'currentStreak': userStatsBox.getAt(0)?.currentStreak ?? 0,
              'longestStreak': userStatsBox.getAt(0)?.longestStreak ?? 0,
              'lastStudyDate':
                  userStatsBox.getAt(0)?.lastStudyDate?.toIso8601String(),
              'totalStudyTime': userStatsBox.getAt(0)?.totalStudyTime ?? 0,
              'totalSessions': userStatsBox.getAt(0)?.totalSessions ?? 0,
              'pomodoroSessions': userStatsBox.getAt(0)?.pomodoroSessions ?? 0,
              'createdAt': userStatsBox.getAt(0)?.createdAt.toIso8601String() ??
                  DateTime.now().toIso8601String(),
              'unlockedAchievements':
                  userStatsBox.getAt(0)?.unlockedAchievements ?? [],
              'userName': userStatsBox.getAt(0)?.userName ?? 'Student',
              'freezeTokens': userStatsBox.getAt(0)?.freezeTokens ?? 0,
              'studyDates': userStatsBox.getAt(0)?.studyDates ?? [],
            }
          : null,
      'achievements': achievementsBox.values
          .map((achievement) => {
                'id': achievement.id,
                'title': achievement.title,
                'description': achievement.description,
                'iconName': achievement.iconName,
                'xpReward': achievement.xpReward,
                'category': achievement.category,
                'isUnlocked': achievement.isUnlocked,
                'unlockedAt': achievement.unlockedAt?.toIso8601String(),
                'requirements': achievement.requirements,
              })
          .toList(),
      'syllabusGroups': syllabusGroupsBox.values
          .map((group) => {
                'id': group.id,
                'name': group.name,
                'description': group.description,
                'color': group.color,
                'createdAt': group.createdAt.toIso8601String(),
                'subjects': group.subjects
                    .map((subject) => {
                          'id': subject.id,
                          'name': subject.name,
                          'description': subject.description,
                          'completedChapters': subject.completedChapters,
                          'chapters': subject.chapters
                              .map((chapter) => {
                                    'id': chapter.id,
                                    'name': chapter.name,
                                    'description': chapter.description,
                                  })
                              .toList(),
                        })
                    .toList(),
              })
          .toList(),
      'xpTransactions': xpTransactionsBox.values
          .map((transaction) => {
                'id': transaction.id,
                'amount': transaction.amount,
                'reason': transaction.reason,
                'type': transaction.type,
                'timestamp': transaction.timestamp.toIso8601String(),
                'relatedId': transaction.relatedId,
              })
          .toList(),
      'dailyReports': dailyReportsBox.values
          .map((report) => {
                'id': report.id,
                'date': report.date.toIso8601String(),
                'totalStudyTime': report.totalStudyTime,
                'totalSessions': report.totalSessions,
                'createdAt': report.createdAt.toIso8601String(),
                'subjectData': report.subjectData.map((key, value) => MapEntry(
                      key,
                      {
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
                      },
                    )),
              })
          .toList(),
      'settings': Map<String, dynamic>.from(settingsBox.toMap()),
    };
  }

  // Save backup to local storage
  static Future<String> createBackup() async {
    final data = await exportData();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_backupFileName');
    await file.writeAsString(jsonString);

    return file.path;
  }

  // Share backup file
  static Future<void> shareBackup() async {
    final filePath = await createBackup();
    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'BroStud App Backup - ${DateTime.now().toString().split(' ')[0]}',
    );
  }

  // Import data from JSON
  static Future<bool> importData(Map<String, dynamic> data) async {
    try {
      // Clear existing data
      await clearAllData();

      // Import subjects first (needed for foreign keys)
      if (data['subjects'] != null) {
        final subjectsBox = Hive.box<Subject>('subjects');
        for (final subjectData in data['subjects']) {
          final subject = Subject(
            id: subjectData['id'],
            name: subjectData['name'],
            description: subjectData['description'],
            colorValue: subjectData['colorValue'],
            createdAt: DateTime.parse(subjectData['createdAt']),
            totalStudyTime: subjectData['totalStudyTime'] ?? 0,
            totalSessions: subjectData['totalSessions'] ?? 0,
            isActive: subjectData['isActive'] ?? true,
          );
          await subjectsBox.put(subject.id, subject);
        }
      }

      // Import study sessions
      if (data['studySessions'] != null) {
        final sessionsBox = Hive.box<StudySession>('study_sessions');
        for (final sessionData in data['studySessions']) {
          final session = StudySession(
            id: sessionData['id'],
            subjectId: sessionData['subjectId'],
            startTime: DateTime.parse(sessionData['startTime']),
            endTime: DateTime.parse(sessionData['endTime']),
            duration: sessionData['duration'],
            type: sessionData['type'],
            notes: sessionData['notes'],
            xpEarned: sessionData['xpEarned'] ?? 0,
            isCompleted: sessionData['isCompleted'] ?? false,
          );
          await sessionsBox.put(session.id, session);
        }
      }

      // Import goals
      if (data['goals'] != null) {
        final goalsBox = Hive.box<Goal>('goals');
        for (final goalData in data['goals']) {
          final goal = Goal(
            id: goalData['id'],
            title: goalData['title'],
            description: goalData['description'],
            subjectId: goalData['subjectId'],
            targetDate: DateTime.parse(goalData['targetDate']),
            createdAt: DateTime.parse(goalData['createdAt']),
            targetHours: goalData['targetHours'],
            currentHours: goalData['currentHours'] ?? 0,
            isCompleted: goalData['isCompleted'] ?? false,
            type: goalData['type'] ?? 'time_based',
          );
          await goalsBox.put(goal.id, goal);
        }
      }

      // Import exams
      if (data['exams'] != null) {
        final examsBox = Hive.box<Exam>('exams');
        for (final examData in data['exams']) {
          final exam = Exam(
            id: examData['id'],
            title: examData['title'],
            subjectId: examData['subjectId'],
            examDate: DateTime.parse(examData['examDate']),
            createdAt: DateTime.parse(examData['createdAt']),
            description: examData['description'],
            location: examData['location'],
            isCompleted: examData['isCompleted'] ?? false,
            result: examData['result'],
          );
          await examsBox.put(exam.id, exam);
        }
      }

      // Import user stats
      if (data['userStats'] != null) {
        final userStatsBox = Hive.box<UserStats>('user_stats');
        final statsData = data['userStats'];
        final userStats = UserStats(
          totalXP: statsData['totalXP'] ?? 0,
          currentLevel: statsData['currentLevel'] ?? 1,
          currentStreak: statsData['currentStreak'] ?? 0,
          longestStreak: statsData['longestStreak'] ?? 0,
          lastStudyDate: statsData['lastStudyDate'] != null
              ? DateTime.parse(statsData['lastStudyDate'])
              : null,
          totalStudyTime: statsData['totalStudyTime'] ?? 0,
          totalSessions: statsData['totalSessions'] ?? 0,
          pomodoroSessions: statsData['pomodoroSessions'] ?? 0,
          createdAt: DateTime.parse(statsData['createdAt']),
          unlockedAchievements:
              List<String>.from(statsData['unlockedAchievements'] ?? []),
        );
        await userStatsBox.put('user_stats', userStats);
      }

      // Import achievements
      if (data['achievements'] != null) {
        final achievementsBox = Hive.box<Achievement>('achievements');
        for (final achievementData in data['achievements']) {
          final achievement = Achievement(
            id: achievementData['id'],
            title: achievementData['title'],
            description: achievementData['description'],
            iconName: achievementData['iconName'],
            xpReward: achievementData['xpReward'],
            category: achievementData['category'],
            isUnlocked: achievementData['isUnlocked'] ?? false,
            unlockedAt: achievementData['unlockedAt'] != null
                ? DateTime.parse(achievementData['unlockedAt'])
                : null,
            requirements: Map<String, dynamic>.from(
                achievementData['requirements'] ?? {}),
          );
          await achievementsBox.put(achievement.id, achievement);
        }
      }

      // Import settings
      if (data['settings'] != null) {
        final settingsBox = Hive.box('settings');
        final settings = Map<String, dynamic>.from(data['settings']);
        for (final entry in settings.entries) {
          await settingsBox.put(entry.key, entry.value);
        }
      }

      return true;
    } catch (e) {
      // Error importing data: $e
      return false;
    }
  }

  // Clear all data
  static Future<void> clearAllData() async {
    await Hive.box<StudySession>('study_sessions').clear();
    await Hive.box<Subject>('subjects').clear();
    await Hive.box<Goal>('goals').clear();
    await Hive.box<Exam>('exams').clear();
    await Hive.box<UserStats>('user_stats').clear();
    await Hive.box<Achievement>('achievements').clear();
    await Hive.box('settings').clear();
  }

  // Auto backup (called periodically)
  static Future<void> autoBackup() async {
    final settingsBox = Hive.box('settings');
    final lastBackup = settingsBox.get('last_backup_date');
    final now = DateTime.now();

    if (lastBackup == null ||
        now.difference(DateTime.parse(lastBackup)).inDays >= 7) {
      await createBackup();
      await settingsBox.put('last_backup_date', now.toIso8601String());
    }
  }

  // Initialize default achievements
  static Future<void> initializeDefaultAchievements() async {
    final achievementsBox = Hive.box<Achievement>('achievements');

    // Only initialize if box is empty
    if (achievementsBox.isNotEmpty) return;

    final defaultAchievements = [
      // Study achievements
      Achievement(
        id: 'first_session',
        title: 'First Steps',
        description: 'Complete your first study session',
        iconName: 'play_circle',
        xpReward: 50,
        category: 'study',
        requirements: {'sessions': 1},
      ),
      Achievement(
        id: 'study_10h',
        title: 'Study Marathon',
        description: 'Study for a total of 10 hours',
        iconName: 'timer',
        xpReward: 200,
        category: 'study',
        requirements: {'total_hours': 10},
      ),
      Achievement(
        id: 'study_50h',
        title: 'Dedicated Scholar',
        description: 'Study for a total of 50 hours',
        iconName: 'school',
        xpReward: 500,
        category: 'study',
        requirements: {'total_hours': 50},
      ),

      // Streak achievements
      Achievement(
        id: 'streak_3',
        title: 'Getting Started',
        description: 'Maintain a 3-day study streak',
        iconName: 'local_fire_department',
        xpReward: 100,
        category: 'streak',
        requirements: {'streak_days': 3},
      ),
      Achievement(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Maintain a 7-day study streak',
        iconName: 'local_fire_department',
        xpReward: 250,
        category: 'streak',
        requirements: {'streak_days': 7},
      ),
      Achievement(
        id: 'streak_30',
        title: 'Monthly Master',
        description: 'Maintain a 30-day study streak',
        iconName: 'local_fire_department',
        xpReward: 1000,
        category: 'streak',
        requirements: {'streak_days': 30},
      ),

      // Pomodoro achievements
      Achievement(
        id: 'pomodoro_10',
        title: 'Pomodoro Pro',
        description: 'Complete 10 Pomodoro sessions',
        iconName: 'timer',
        xpReward: 150,
        category: 'pomodoro',
        requirements: {'pomodoro_sessions': 10},
      ),
      Achievement(
        id: 'pomodoro_50',
        title: 'Focus Master',
        description: 'Complete 50 Pomodoro sessions',
        iconName: 'psychology',
        xpReward: 400,
        category: 'pomodoro',
        requirements: {'pomodoro_sessions': 50},
      ),

      // Level achievements
      Achievement(
        id: 'level_5',
        title: 'Rising Star',
        description: 'Reach level 5',
        iconName: 'star',
        xpReward: 200,
        category: 'level',
        requirements: {'level': 5},
      ),
      Achievement(
        id: 'level_10',
        title: 'Expert Learner',
        description: 'Reach level 10',
        iconName: 'star',
        xpReward: 500,
        category: 'level',
        requirements: {'level': 10},
      ),

      // Time-based achievements
      Achievement(
        id: 'early_bird',
        title: 'Early Bird',
        description: 'Study before 8 AM',
        iconName: 'wb_sunny',
        xpReward: 75,
        category: 'time',
        requirements: {'study_before': 8},
      ),
      Achievement(
        id: 'night_owl',
        title: 'Night Owl',
        description: 'Study after 10 PM',
        iconName: 'nightlight',
        xpReward: 75,
        category: 'time',
        requirements: {'study_after': 22},
      ),

      // Syllabus achievements
      Achievement(
        id: 'first_syllabus',
        title: 'Organized Mind',
        description: 'Create your first syllabus group',
        iconName: 'library_books',
        xpReward: 100,
        category: 'syllabus',
        requirements: {'syllabus_groups': 1},
      ),
      Achievement(
        id: 'syllabus_complete',
        title: 'Syllabus Master',
        description: 'Complete an entire syllabus group',
        iconName: 'check_circle',
        xpReward: 300,
        category: 'syllabus',
        requirements: {'completed_groups': 1},
      ),
      Achievement(
        id: 'chapter_10',
        title: 'Chapter Champion',
        description: 'Complete 10 chapters across all subjects',
        iconName: 'menu_book',
        xpReward: 250,
        category: 'syllabus',
        requirements: {'completed_chapters': 10},
      ),
      Achievement(
        id: 'subject_master',
        title: 'Subject Master',
        description: 'Complete all chapters in a subject',
        iconName: 'school',
        xpReward: 200,
        category: 'syllabus',
        requirements: {'completed_subjects': 1},
      ),

      // Goal achievements
      Achievement(
        id: 'goal_setter',
        title: 'Goal Setter',
        description: 'Create your first study goal',
        iconName: 'flag',
        xpReward: 50,
        category: 'goals',
        requirements: {'goals_created': 1},
      ),
      Achievement(
        id: 'goal_achiever',
        title: 'Goal Achiever',
        description: 'Complete 5 study goals',
        iconName: 'emoji_events',
        xpReward: 300,
        category: 'goals',
        requirements: {'goals_completed': 5},
      ),

      // XP achievements
      Achievement(
        id: 'xp_1000',
        title: 'XP Collector',
        description: 'Earn 1000 total XP',
        iconName: 'star',
        xpReward: 100,
        category: 'xp',
        requirements: {'total_xp': 1000},
      ),
      Achievement(
        id: 'xp_5000',
        title: 'XP Master',
        description: 'Earn 5000 total XP',
        iconName: 'star',
        xpReward: 500,
        category: 'xp',
        requirements: {'total_xp': 5000},
      ),
    ];

    // Save all achievements
    for (final achievement in defaultAchievements) {
      await achievementsBox.put(achievement.id, achievement);
    }
  }
}
