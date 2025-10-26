import 'package:hive/hive.dart';

part 'achievement.g.dart';

@HiveType(typeId: 5)
class Achievement extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String iconName;

  @HiveField(4)
  int xpReward;

  @HiveField(5)
  String category; // 'streak', 'pomodoro', 'time', 'general'

  @HiveField(6)
  bool isUnlocked;

  @HiveField(7)
  DateTime? unlockedAt;

  @HiveField(8)
  Map<String, dynamic> requirements; // Flexible requirements

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.xpReward,
    required this.category,
    this.isUnlocked = false,
    this.unlockedAt,
    this.requirements = const {},
  });

  static List<Achievement> getDefaultAchievements() {
    return [
      Achievement(
        id: 'first_session',
        title: 'Getting Started',
        description: 'Complete your first study session',
        iconName: 'play_circle',
        xpReward: 25,
        category: 'general',
        requirements: {'sessions': 1},
      ),
      Achievement(
        id: 'early_bird',
        title: 'Early Bird',
        description: 'Study before 8 AM',
        iconName: 'wb_sunny',
        xpReward: 50,
        category: 'time',
        requirements: {'hour_before': 8},
      ),
      Achievement(
        id: 'night_owl',
        title: 'Night Owl',
        description: 'Study after 10 PM',
        iconName: 'nights_stay',
        xpReward: 50,
        category: 'time',
        requirements: {'hour_after': 22},
      ),
      Achievement(
        id: 'streak_3',
        title: 'Consistent Learner',
        description: 'Maintain a 3-day study streak',
        iconName: 'local_fire_department',
        xpReward: 75,
        category: 'streak',
        requirements: {'streak': 3},
      ),
      Achievement(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Maintain a 7-day study streak',
        iconName: 'local_fire_department',
        xpReward: 150,
        category: 'streak',
        requirements: {'streak': 7},
      ),
      Achievement(
        id: 'pomodoro_10',
        title: 'Pomodoro Master',
        description: 'Complete 10 Pomodoro sessions',
        iconName: 'timer',
        xpReward: 100,
        category: 'pomodoro',
        requirements: {'pomodoro_sessions': 10},
      ),
      Achievement(
        id: 'study_10h',
        title: 'Dedicated Student',
        description: 'Study for 10 hours total',
        iconName: 'school',
        xpReward: 200,
        category: 'time',
        requirements: {'total_hours': 10},
      ),
      Achievement(
        id: 'level_5',
        title: 'Rising Star',
        description: 'Reach level 5',
        iconName: 'star',
        xpReward: 250,
        category: 'general',
        requirements: {'level': 5},
      ),
      Achievement(
        id: 'streak_14',
        title: 'Two Week Champion',
        description: 'Maintain a 14-day study streak',
        iconName: 'local_fire_department',
        xpReward: 300,
        category: 'streak',
        requirements: {'streak': 14},
      ),
      Achievement(
        id: 'streak_30',
        title: 'Monthly Master',
        description: 'Maintain a 30-day study streak',
        iconName: 'local_fire_department',
        xpReward: 500,
        category: 'streak',
        requirements: {'streak': 30},
      ),
      Achievement(
        id: 'pomodoro_25',
        title: 'Pomodoro Pro',
        description: 'Complete 25 Pomodoro sessions',
        iconName: 'timer',
        xpReward: 200,
        category: 'pomodoro',
        requirements: {'pomodoro_sessions': 25},
      ),
      Achievement(
        id: 'pomodoro_50',
        title: 'Pomodoro Legend',
        description: 'Complete 50 Pomodoro sessions',
        iconName: 'timer',
        xpReward: 400,
        category: 'pomodoro',
        requirements: {'pomodoro_sessions': 50},
      ),
      Achievement(
        id: 'study_25h',
        title: 'Study Warrior',
        description: 'Study for 25 hours total',
        iconName: 'school',
        xpReward: 350,
        category: 'time',
        requirements: {'total_hours': 25},
      ),
      Achievement(
        id: 'study_50h',
        title: 'Study Champion',
        description: 'Study for 50 hours total',
        iconName: 'school',
        xpReward: 600,
        category: 'time',
        requirements: {'total_hours': 50},
      ),
      Achievement(
        id: 'level_10',
        title: 'Expert Scholar',
        description: 'Reach level 10',
        iconName: 'star',
        xpReward: 500,
        category: 'general',
        requirements: {'level': 10},
      ),
      Achievement(
        id: 'weekend_warrior',
        title: 'Weekend Warrior',
        description: 'Study on both Saturday and Sunday',
        iconName: 'weekend',
        xpReward: 100,
        category: 'general',
        requirements: {'weekend_study': 1},
      ),
      Achievement(
        id: 'freeze_master',
        title: 'Freeze Master',
        description: 'Collect 5 freeze tokens',
        iconName: 'ac_unit',
        xpReward: 150,
        category: 'general',
        requirements: {'freeze_tokens': 5},
      ),
    ];
  }

  bool checkRequirements(Map<String, dynamic> userStats) {
    for (final entry in requirements.entries) {
      final key = entry.key;
      final requiredValue = entry.value;
      final userValue = userStats[key] ?? 0;

      if (userValue < requiredValue) {
        return false;
      }
    }
    return true;
  }

  void unlock() {
    isUnlocked = true;
    unlockedAt = DateTime.now();
    save();
  }
}
