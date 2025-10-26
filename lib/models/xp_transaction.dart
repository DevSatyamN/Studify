import 'package:hive/hive.dart';

part 'xp_transaction.g.dart';

@HiveType(typeId: 10)
class XPTransaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  int amount; // Positive for gain, negative for loss

  @HiveField(2)
  String reason;

  @HiveField(3)
  String
      type; // 'study', 'achievement', 'streak_bonus', 'streak_penalty', 'goal_completion'

  @HiveField(4)
  DateTime timestamp;

  @HiveField(5)
  String? relatedId; // ID of related entity (session, achievement, etc.)

  XPTransaction({
    required this.id,
    required this.amount,
    required this.reason,
    required this.type,
    required this.timestamp,
    this.relatedId,
  });

  factory XPTransaction.studySession({
    required int xp,
    required int minutes,
    required String sessionId,
  }) {
    return XPTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: xp,
      reason: 'Study session completed ($minutes minutes)',
      type: 'study',
      timestamp: DateTime.now(),
      relatedId: sessionId,
    );
  }

  factory XPTransaction.achievement({
    required int xp,
    required String achievementName,
    required String achievementId,
  }) {
    return XPTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: xp,
      reason: 'Achievement unlocked: $achievementName',
      type: 'achievement',
      timestamp: DateTime.now(),
      relatedId: achievementId,
    );
  }

  factory XPTransaction.streakBonus({
    required int xp,
    required int streakDays,
  }) {
    return XPTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: xp,
      reason: 'Streak bonus ($streakDays days)',
      type: 'streak_bonus',
      timestamp: DateTime.now(),
    );
  }

  factory XPTransaction.streakPenalty({
    required int xp,
  }) {
    return XPTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: -xp,
      reason: 'Streak broken penalty',
      type: 'streak_penalty',
      timestamp: DateTime.now(),
    );
  }

  factory XPTransaction.goalCompletion({
    required int xp,
    required String goalName,
    required String goalId,
  }) {
    return XPTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: xp,
      reason: 'Goal completed: $goalName',
      type: 'goal_completion',
      timestamp: DateTime.now(),
      relatedId: goalId,
    );
  }

  String get formattedAmount {
    return amount >= 0 ? '+$amount XP' : '$amount XP';
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
