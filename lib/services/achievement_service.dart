import 'package:hive/hive.dart';
import '../models/achievement.dart';
import '../models/user_stats.dart';
import '../models/syllabus_group.dart';
import '../models/goal.dart';

class AchievementService {
  static Future<List<Achievement>> checkAndUnlockAchievements() async {
    final achievementsBox = Hive.box<Achievement>('achievements');
    final userStatsBox = Hive.box<UserStats>('user_stats');
    final userStats = userStatsBox.get('user_stats') ?? UserStats.initial();

    final unlockedAchievements = <Achievement>[];

    // Get current time for time-based achievements
    final now = DateTime.now();
    final currentHour = now.hour;

    // Check all achievements
    for (final achievement in achievementsBox.values) {
      if (achievement.isUnlocked) continue;

      bool shouldUnlock = false;

      switch (achievement.id) {
        // Study achievements
        case 'first_session':
          shouldUnlock = userStats.totalSessions >= 1;
          break;
        case 'study_10h':
          shouldUnlock = (userStats.totalStudyTime / 60) >= 10;
          break;
        case 'study_50h':
          shouldUnlock = (userStats.totalStudyTime / 60) >= 50;
          break;

        // Streak achievements
        case 'streak_3':
          shouldUnlock = userStats.currentStreak >= 3;
          break;
        case 'streak_7':
          shouldUnlock = userStats.currentStreak >= 7;
          break;
        case 'streak_30':
          shouldUnlock = userStats.currentStreak >= 30;
          break;

        // Pomodoro achievements
        case 'pomodoro_10':
          shouldUnlock = userStats.pomodoroSessions >= 10;
          break;
        case 'pomodoro_50':
          shouldUnlock = userStats.pomodoroSessions >= 50;
          break;

        // Level achievements
        case 'level_5':
          shouldUnlock = userStats.currentLevel >= 5;
          break;
        case 'level_10':
          shouldUnlock = userStats.currentLevel >= 10;
          break;

        // Time-based achievements
        case 'early_bird':
          if (currentHour < 8) {
            shouldUnlock = true;
          }
          break;
        case 'night_owl':
          if (currentHour >= 22) {
            shouldUnlock = true;
          }
          break;

        // Syllabus achievements
        case 'first_syllabus':
          final syllabusBox = Hive.box<SyllabusGroup>('syllabus_groups');
          shouldUnlock = syllabusBox.length >= 1;
          break;
        case 'syllabus_complete':
          final syllabusBox = Hive.box<SyllabusGroup>('syllabus_groups');
          final completedGroups =
              syllabusBox.values.where((group) => group.isCompleted).length;
          shouldUnlock = completedGroups >= 1;
          break;
        case 'chapter_10':
          final syllabusBox = Hive.box<SyllabusGroup>('syllabus_groups');
          int totalCompletedChapters = 0;
          for (final group in syllabusBox.values) {
            totalCompletedChapters += group.completedChapters;
          }
          shouldUnlock = totalCompletedChapters >= 10;
          break;
        case 'subject_master':
          final syllabusBox = Hive.box<SyllabusGroup>('syllabus_groups');
          int completedSubjects = 0;
          for (final group in syllabusBox.values) {
            completedSubjects += group.completedSubjects.length;
          }
          shouldUnlock = completedSubjects >= 1;
          break;

        // Goal achievements
        case 'goal_setter':
          final goalsBox = Hive.box<Goal>('goals');
          shouldUnlock = goalsBox.length >= 1;
          break;
        case 'goal_achiever':
          final goalsBox = Hive.box<Goal>('goals');
          final completedGoals =
              goalsBox.values.where((goal) => goal.isCompleted).length;
          shouldUnlock = completedGoals >= 5;
          break;

        // XP achievements
        case 'xp_1000':
          shouldUnlock = userStats.totalXP >= 1000;
          break;
        case 'xp_5000':
          shouldUnlock = userStats.totalXP >= 5000;
          break;
      }

      if (shouldUnlock) {
        achievement.unlock();
        userStats.addXP(achievement.xpReward);
        userStats.unlockAchievement(achievement.id);
        unlockedAchievements.add(achievement);
      }
    }

    if (unlockedAchievements.isNotEmpty) {
      await userStatsBox.put('user_stats', userStats);
    }

    return unlockedAchievements;
  }

  static Future<void> checkFirstSession() async {
    await checkAndUnlockAchievements();
  }

  static Future<void> checkPomodoroAchievements() async {
    await checkAndUnlockAchievements();
  }

  static Future<void> checkStreakAchievements() async {
    await checkAndUnlockAchievements();
  }

  static Future<void> checkTimeBasedAchievements() async {
    await checkAndUnlockAchievements();
  }
}
