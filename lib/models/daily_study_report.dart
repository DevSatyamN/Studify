import 'package:hive/hive.dart';

part 'daily_study_report.g.dart';

@HiveType(typeId: 11)
class DailyStudyReport extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date; // Date of the report (without time)

  @HiveField(2)
  Map<String, SubjectStudyData> subjectData; // Subject ID -> Study data

  @HiveField(3)
  int totalStudyTime; // Total minutes studied that day

  @HiveField(4)
  int totalSessions; // Total study sessions

  @HiveField(5)
  DateTime createdAt;

  DailyStudyReport({
    required this.id,
    required this.date,
    required this.subjectData,
    required this.totalStudyTime,
    required this.totalSessions,
    required this.createdAt,
  });

  factory DailyStudyReport.create(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return DailyStudyReport(
      id: '${dateOnly.year}-${dateOnly.month.toString().padLeft(2, '0')}-${dateOnly.day.toString().padLeft(2, '0')}',
      date: dateOnly,
      subjectData: {},
      totalStudyTime: 0,
      totalSessions: 0,
      createdAt: DateTime.now(),
    );
  }

  void addStudySession({
    required String subjectId,
    required String subjectName,
    required String? chapterName,
    required int duration,
    required DateTime sessionTime,
  }) {
    if (!subjectData.containsKey(subjectId)) {
      subjectData[subjectId] = SubjectStudyData(
        subjectId: subjectId,
        subjectName: subjectName,
        totalTime: 0,
        sessions: [],
        chaptersStudied: {},
      );
    }

    final subject = subjectData[subjectId]!;
    subject.totalTime += duration;
    subject.sessions.add(StudySessionData(
      startTime: sessionTime,
      duration: duration,
      chapterName: chapterName,
    ));

    if (chapterName != null) {
      subject.chaptersStudied[chapterName] =
          (subject.chaptersStudied[chapterName] ?? 0) + duration;
    }

    totalStudyTime += duration;
    totalSessions += 1;
    save();
  }

  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String get formattedTotalTime {
    final hours = totalStudyTime ~/ 60;
    final minutes = totalStudyTime % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

@HiveType(typeId: 12)
class SubjectStudyData {
  @HiveField(0)
  String subjectId;

  @HiveField(1)
  String subjectName;

  @HiveField(2)
  int totalTime; // Total minutes studied for this subject

  @HiveField(3)
  List<StudySessionData> sessions;

  @HiveField(4)
  Map<String, int> chaptersStudied; // Chapter name -> minutes studied

  SubjectStudyData({
    required this.subjectId,
    required this.subjectName,
    required this.totalTime,
    required this.sessions,
    required this.chaptersStudied,
  });

  String get formattedTime {
    final hours = totalTime ~/ 60;
    final minutes = totalTime % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

@HiveType(typeId: 13)
class StudySessionData {
  @HiveField(0)
  DateTime startTime;

  @HiveField(1)
  int duration; // Duration in minutes

  @HiveField(2)
  String? chapterName;

  StudySessionData({
    required this.startTime,
    required this.duration,
    this.chapterName,
  });

  String get formattedTime {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }
}
