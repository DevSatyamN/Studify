import 'package:hive/hive.dart';
import '../models/user_stats.dart';
import '../models/study_session.dart';

class StreakService {
  static const int STREAK_BREAK_XP_PENALTY = 100;
  static const double DAILY_GOAL_HOURS = 4.0;

  static Future<void> checkAndUpdateStreak() async {
    final userStatsBox = Hive.box<UserStats>('user_stats');
    final userStats = userStatsBox.get('user_stats') ?? UserStats.initial();

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    // Check if user studied yesterday (4+ hours)
    final yesterdayHours = _getStudyHoursForDate(yesterday);

    if (yesterdayHours >= DAILY_GOAL_HOURS) {
      // Streak continues or increases
      if (_isConsecutiveDay(userStats.lastStudyDate, yesterday)) {
        // Continue streak
        userStats.currentStreak += 1;
      } else {
        // Start new streak
        userStats.currentStreak = 1;
      }
      userStats.lastStudyDate = yesterday;
    } else {
      // Streak broken - apply penalty if user had a streak
      if (userStats.currentStreak > 0) {
        _applyStreakBreakPenalty(userStats);
        userStats.currentStreak = 0;
      }
    }

    // Update longest streak
    if (userStats.currentStreak > userStats.longestStreak) {
      userStats.longestStreak = userStats.currentStreak;
    }

    await userStatsBox.put('user_stats', userStats);
  }

  static Future<void> updateTodayProgress() async {
    final userStatsBox = Hive.box<UserStats>('user_stats');
    final userStats = userStatsBox.get('user_stats') ?? UserStats.initial();

    final today = DateTime.now();
    final todayHours = _getStudyHoursForDate(today);

    // If user completes 4+ hours today, update streak
    if (todayHours >= DAILY_GOAL_HOURS) {
      if (_isConsecutiveDay(userStats.lastStudyDate, today) ||
          userStats.lastStudyDate == null) {
        userStats.currentStreak += 1;
        userStats.lastStudyDate = today;

        // Update longest streak
        if (userStats.currentStreak > userStats.longestStreak) {
          userStats.longestStreak = userStats.currentStreak;
        }

        await userStatsBox.put('user_stats', userStats);
      }
    }
  }

  static double _getStudyHoursForDate(DateTime date) {
    final sessionsBox = Hive.box<StudySession>('study_sessions');
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final daySessions = sessionsBox.values.where((session) {
      return session.startTime.isAfter(dayStart) &&
          session.startTime.isBefore(dayEnd);
    }).toList();

    final totalMinutes = daySessions.fold<int>(
      0,
      (sum, session) => sum + session.duration,
    );

    return totalMinutes / 60.0;
  }

  static bool _isConsecutiveDay(DateTime? lastDate, DateTime currentDate) {
    if (lastDate == null) return false;

    final difference = currentDate.difference(lastDate).inDays;
    return difference == 1;
  }

  static void _applyStreakBreakPenalty(UserStats userStats) {
    // Reduce XP by 100 for breaking streak
    userStats.totalXP = (userStats.totalXP - STREAK_BREAK_XP_PENALTY)
        .clamp(0, double.infinity)
        .toInt();

    // Recalculate level based on new XP
    final newLevel = _calculateLevelFromXP(userStats.totalXP);
    userStats.currentLevel = newLevel;

    // Reset streak
    userStats.currentStreak = 0;
  }

  static int _calculateLevelFromXP(int xp) {
    // Level calculation: Level = sqrt(XP / 100) + 1
    return (xp / 500).floor() + 1;
  }

  static Map<String, dynamic> getStreakStats() {
    final userStatsBox = Hive.box<UserStats>('user_stats');
    final userStats = userStatsBox.get('user_stats') ?? UserStats.initial();

    final today = DateTime.now();
    final todayHours = _getStudyHoursForDate(today);
    final progressPercentage = (todayHours / DAILY_GOAL_HOURS).clamp(0.0, 1.0);

    return {
      'currentStreak': userStats.currentStreak,
      'longestStreak': userStats.longestStreak,
      'todayHours': todayHours,
      'dailyGoal': DAILY_GOAL_HOURS,
      'progressPercentage': progressPercentage,
      'isGoalComplete': progressPercentage >= 1.0,
      'hoursLeft': (DAILY_GOAL_HOURS - todayHours).clamp(0.0, DAILY_GOAL_HOURS),
    };
  }
}
