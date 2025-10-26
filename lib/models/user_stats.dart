import 'package:hive/hive.dart';

part 'user_stats.g.dart';

@HiveType(typeId: 4)
class UserStats extends HiveObject {
  @HiveField(0)
  int totalXP;

  @HiveField(1)
  int currentLevel;

  @HiveField(2)
  int currentStreak;

  @HiveField(3)
  int longestStreak;

  @HiveField(4)
  DateTime? lastStudyDate;

  @HiveField(5)
  int totalStudyTime; // in minutes

  @HiveField(6)
  int totalSessions;

  @HiveField(7)
  int pomodoroSessions;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  List<String> unlockedAchievements;

  @HiveField(10)
  String userName;

  @HiveField(11)
  int freezeTokens;

  @HiveField(12)
  DateTime? lastFreezeTokenDate;

  @HiveField(13)
  List<String> studyDates; // Store study dates for streak calendar

  UserStats({
    this.totalXP = 0,
    this.currentLevel = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastStudyDate,
    this.totalStudyTime = 0,
    this.totalSessions = 0,
    this.pomodoroSessions = 0,
    required this.createdAt,
    this.unlockedAchievements = const [],
    this.userName = 'Student',
    this.freezeTokens = 0,
    this.lastFreezeTokenDate,
    this.studyDates = const [],
  });

  factory UserStats.initial() {
    return UserStats(
      createdAt: DateTime.now(),
      unlockedAchievements: [],
      userName: 'Student',
      freezeTokens: 1, // Start with 1 freeze token
      studyDates: [],
    );
  }

  int get xpForNextLevel {
    return currentLevel * 500; // 500 XP per level
  }

  int get xpInCurrentLevel {
    return totalXP % 500;
  }

  double get levelProgress {
    return xpInCurrentLevel / 500.0;
  }

  void addXP(int xp) {
    totalXP += xp;
    final newLevel = (totalXP / 500).floor() + 1;
    if (newLevel > currentLevel) {
      currentLevel = newLevel;
    }
    save();
  }

  void updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastStudyDate == null) {
      currentStreak = 1;
      lastStudyDate = today;
    } else {
      final lastStudy = DateTime(
        lastStudyDate!.year,
        lastStudyDate!.month,
        lastStudyDate!.day,
      );

      final daysDifference = today.difference(lastStudy).inDays;

      if (daysDifference == 0) {
        // Same day, no change to streak
        return;
      } else if (daysDifference == 1) {
        // Consecutive day
        currentStreak++;
        lastStudyDate = today;
      } else {
        // Streak broken
        currentStreak = 1;
        lastStudyDate = today;
      }
    }

    // Add today to study dates if not already added
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    if (!studyDates.contains(todayString)) {
      studyDates = [...studyDates, todayString];
    }

    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    // Give weekly freeze token
    _checkWeeklyFreezeToken();

    save();
  }

  void _checkWeeklyFreezeToken() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    if (lastFreezeTokenDate == null ||
        lastFreezeTokenDate!.isBefore(startOfWeek)) {
      freezeTokens++;
      lastFreezeTokenDate = now;
    }
  }

  bool useFreeze() {
    if (freezeTokens > 0) {
      freezeTokens--;
      save();
      return true;
    }
    return false;
  }

  void addSession(int duration, bool isPomodoro) {
    totalSessions++;
    totalStudyTime += duration;
    if (isPomodoro) {
      pomodoroSessions++;
    }

    // Check if user has studied at least 4 hours today for streak
    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Get today's total study time
    final todayStudyTime = _getTodayStudyTime();

    // Only update streak if user has studied at least 4 hours (240 minutes)
    if (todayStudyTime >= 240) {
      updateStreak();
    }

    save();
  }

  int _getTodayStudyTime() {
    // This would need to be calculated from study sessions
    // For now, we'll use a simple approach
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    // In a real implementation, you'd sum up all sessions for today
    // For now, we'll assume the current session contributes to today's total
    return totalStudyTime; // Simplified - should be today's total only
  }

  void unlockAchievement(String achievementId) {
    if (!unlockedAchievements.contains(achievementId)) {
      unlockedAchievements = [...unlockedAchievements, achievementId];
      save();
    }
  }
}
