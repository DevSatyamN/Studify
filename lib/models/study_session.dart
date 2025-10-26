import 'package:hive/hive.dart';

part 'study_session.g.dart';

@HiveType(typeId: 0)
class StudySession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String subjectId;

  @HiveField(2)
  DateTime startTime;

  @HiveField(3)
  DateTime endTime;

  @HiveField(4)
  int duration; // in minutes

  @HiveField(5)
  String type; // 'pomodoro', 'regular', 'break'

  @HiveField(6)
  String? notes;

  @HiveField(7)
  int xpEarned;

  @HiveField(8)
  bool isCompleted;

  StudySession({
    required this.id,
    required this.subjectId,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.type,
    this.notes,
    this.xpEarned = 0,
    this.isCompleted = false,
  });

  factory StudySession.create({
    required String subjectId,
    required DateTime startTime,
    required DateTime endTime,
    required String type,
    String? notes,
  }) {
    final duration = endTime.difference(startTime).inMinutes;
    final xp = type == 'pomodoro' ? 10 : (duration / 10).round();

    return StudySession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subjectId: subjectId,
      startTime: startTime,
      endTime: endTime,
      duration: duration,
      type: type,
      notes: notes,
      xpEarned: xp,
      isCompleted: true,
    );
  }
}
