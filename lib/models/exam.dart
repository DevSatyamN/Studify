import 'package:hive/hive.dart';

part 'exam.g.dart';

@HiveType(typeId: 3)
class Exam extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String subjectId;

  @HiveField(3)
  DateTime examDate;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  String? description;

  @HiveField(6)
  String? location;

  @HiveField(7)
  bool isCompleted;

  @HiveField(8)
  String? result; // 'passed', 'failed', null if not taken yet

  Exam({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.examDate,
    required this.createdAt,
    this.description,
    this.location,
    this.isCompleted = false,
    this.result,
  });

  factory Exam.create({
    required String title,
    required String subjectId,
    required DateTime examDate,
    String? description,
    String? location,
  }) {
    return Exam(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      subjectId: subjectId,
      examDate: examDate,
      createdAt: DateTime.now(),
      description: description,
      location: location,
    );
  }

  int get daysLeft {
    final now = DateTime.now();
    final difference = examDate.difference(now).inDays;
    return difference;
  }

  bool get isUpcoming {
    return daysLeft >= 0 && !isCompleted;
  }

  bool get isOverdue {
    return daysLeft < 0 && !isCompleted;
  }
}
