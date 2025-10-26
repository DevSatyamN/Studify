import 'package:hive/hive.dart';

part 'syllabus_group.g.dart';

@HiveType(typeId: 7)
class SyllabusGroup extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  List<SyllabusSubject> subjects;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? targetDate;

  @HiveField(6)
  int priority; // 1-5, 5 being highest

  @HiveField(7)
  String color;

  @HiveField(8)
  String icon;

  @HiveField(9)
  int totalTimeSpent; // in minutes

  SyllabusGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.subjects,
    required this.createdAt,
    this.targetDate,
    this.priority = 3,
    this.color = '#1E88E5',
    this.icon = 'library_books',
    this.totalTimeSpent = 0,
  });

  double get progressPercentage {
    if (subjects.isEmpty) return 0.0;
    final totalChapters =
        subjects.fold(0, (sum, subject) => sum + subject.chapters.length);
    final completedChapters = subjects.fold(
        0, (sum, subject) => sum + subject.completedChapters.length);
    return totalChapters > 0 ? completedChapters / totalChapters : 0.0;
  }

  int get totalChapters =>
      subjects.fold(0, (sum, subject) => sum + subject.chapters.length);
  int get completedChapters => subjects.fold(
      0, (sum, subject) => sum + subject.completedChapters.length);
  int get remainingChapters => totalChapters - completedChapters;

  bool get isCompleted =>
      subjects.isNotEmpty && subjects.every((subject) => subject.isCompleted);

  List<SyllabusSubject> get completedSubjects =>
      subjects.where((s) => s.isCompleted).toList();
  List<SyllabusSubject> get pendingSubjects =>
      subjects.where((s) => !s.isCompleted).toList();

  SyllabusSubject? get nextRecommendedSubject {
    final pending = pendingSubjects;
    return pending.isNotEmpty ? pending.first : null;
  }

  void updateTotalTime() {
    totalTimeSpent =
        subjects.fold(0, (sum, subject) => sum + subject.totalTimeSpent);
    save();
  }
}

@HiveType(typeId: 8)
class SyllabusSubject extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  List<SyllabusChapter> chapters;

  @HiveField(4)
  List<String> completedChapters;

  @HiveField(5)
  int totalTimeSpent; // in minutes

  @HiveField(6)
  DateTime createdAt;

  SyllabusSubject({
    required this.id,
    required this.name,
    required this.description,
    required this.chapters,
    required this.createdAt,
    List<String>? completedChapters,
    this.totalTimeSpent = 0,
  }) : completedChapters = completedChapters ?? [];

  double get progressPercentage {
    if (chapters.isEmpty) return 0.0;
    return completedChapters.length / chapters.length;
  }

  bool get isCompleted =>
      chapters.isNotEmpty && completedChapters.length == chapters.length;

  List<SyllabusChapter> get pendingChapters {
    return chapters
        .where((chapter) => !completedChapters.contains(chapter.id))
        .toList();
  }

  SyllabusChapter? get nextRecommendedChapter {
    final pending = pendingChapters;
    return pending.isNotEmpty ? pending.first : null;
  }

  void markChapterCompleted(String chapterId) {
    if (!completedChapters.contains(chapterId)) {
      completedChapters.add(chapterId);
      save();
    }
  }

  void markChapterIncomplete(String chapterId) {
    completedChapters.remove(chapterId);
    save();
  }

  void updateTotalTime() {
    totalTimeSpent =
        chapters.fold(0, (sum, chapter) => sum + chapter.timeSpent);
    save();
  }
}

@HiveType(typeId: 9)
class SyllabusChapter extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  List<String> topics;

  @HiveField(4)
  List<String> completedTopics;

  @HiveField(5)
  int timeSpent; // in minutes

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  bool isCompleted;

  SyllabusChapter({
    required this.id,
    required this.name,
    required this.description,
    required this.topics,
    required this.createdAt,
    List<String>? completedTopics,
    this.timeSpent = 0,
    this.isCompleted = false,
  }) : completedTopics = completedTopics ?? [];

  double get progressPercentage {
    if (topics.isEmpty) return 0.0;
    return completedTopics.length / topics.length;
  }

  List<String> get pendingTopics {
    return topics.where((topic) => !completedTopics.contains(topic)).toList();
  }

  void markTopicCompleted(String topic) {
    if (topics.contains(topic) && !completedTopics.contains(topic)) {
      completedTopics.add(topic);
      save();
    }
  }

  void markTopicIncomplete(String topic) {
    completedTopics.remove(topic);
    save();
  }

  void addStudyTime(int minutes) {
    timeSpent += minutes;
    save();
  }

  void markAsCompleted() {
    isCompleted = true;
    save();
  }
}
