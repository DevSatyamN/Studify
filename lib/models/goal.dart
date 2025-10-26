import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 2)
class Goal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String subjectId;

  @HiveField(4)
  DateTime targetDate;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  int targetHours;

  @HiveField(7)
  int currentHours;

  @HiveField(8)
  bool isCompleted;

  @HiveField(9)
  String type; // 'time_based', 'chapter_based', 'custom'

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectId,
    required this.targetDate,
    required this.createdAt,
    required this.targetHours,
    this.currentHours = 0,
    this.isCompleted = false,
    this.type = 'time_based',
  });

  factory Goal.create({
    required String title,
    required String description,
    required String subjectId,
    required DateTime targetDate,
    required int targetHours,
    String type = 'time_based',
  }) {
    return Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      subjectId: subjectId,
      targetDate: targetDate,
      createdAt: DateTime.now(),
      targetHours: targetHours,
      type: type,
    );
  }

  double get progressPercentage {
    if (targetHours == 0) return 0.0;
    return (currentHours / targetHours).clamp(0.0, 1.0);
  }

  int get daysLeft {
    final now = DateTime.now();
    final difference = targetDate.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  void updateProgress(int studyMinutes) {
    currentHours += (studyMinutes / 60).round();
    if (currentHours >= targetHours) {
      isCompleted = true;
    }
    save();
  }
}
