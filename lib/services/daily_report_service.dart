import 'package:hive/hive.dart';
import '../models/daily_study_report.dart';
import '../models/study_session.dart';
import '../models/syllabus_group.dart';
import '../models/subject.dart';

class DailyReportService {
  static Future<void> generateDailyReport(DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final reportId =
        '${dateOnly.year}-${dateOnly.month.toString().padLeft(2, '0')}-${dateOnly.day.toString().padLeft(2, '0')}';

    final reportsBox = Hive.box<DailyStudyReport>('daily_reports');

    // Check if report already exists
    if (reportsBox.containsKey(reportId)) {
      return; // Report already generated
    }

    // Get all study sessions for this date
    final sessionsBox = Hive.box<StudySession>('study_sessions');
    final dayStart = dateOnly;
    final dayEnd = dateOnly.add(const Duration(days: 1));

    final daySessions = sessionsBox.values.where((session) {
      return session.startTime.isAfter(dayStart) &&
          session.startTime.isBefore(dayEnd);
    }).toList();

    if (daySessions.isEmpty) {
      return; // No sessions to report
    }

    // Create report
    final report = DailyStudyReport.create(dateOnly);

    // Process each session
    for (final session in daySessions) {
      final subjectInfo = _getSubjectInfo(session.subjectId);
      final chapterInfo = _getChapterInfo(session.subjectId, session);

      report.addStudySession(
        subjectId: session.subjectId,
        subjectName: subjectInfo['name'] ?? 'Unknown Subject',
        chapterName: chapterInfo,
        duration: session.duration,
        sessionTime: session.startTime,
      );
    }

    // Save report
    await reportsBox.put(reportId, report);
  }

  static Map<String, String?> _getSubjectInfo(String subjectId) {
    // Try to find in syllabus groups first
    final syllabusBox = Hive.box<SyllabusGroup>('syllabus_groups');
    for (final group in syllabusBox.values) {
      for (final subject in group.subjects) {
        if (subject.id == subjectId) {
          return {
            'name': subject.name,
            'groupName': group.name,
          };
        }
      }
    }

    // Fallback to old subjects system
    final subjectsBox = Hive.box<Subject>('subjects');
    final subject = subjectsBox.get(subjectId);
    return {
      'name': subject?.name,
      'groupName': null,
    };
  }

  static String? _getChapterInfo(String subjectId, StudySession session) {
    // Extract chapter information from session notes
    if (session.notes != null && session.notes!.startsWith('Chapter: ')) {
      return session.notes!.substring(9); // Remove "Chapter: " prefix
    }
    return null;
  }

  static Future<List<DailyStudyReport>> getRecentReports({int days = 7}) async {
    final reportsBox = Hive.box<DailyStudyReport>('daily_reports');
    final reports = reportsBox.values.toList();

    // Sort by date (newest first)
    reports.sort((a, b) => b.date.compareTo(a.date));

    // Return last N days
    return reports.take(days).toList();
  }

  static Future<DailyStudyReport?> getReportForDate(DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final reportId =
        '${dateOnly.year}-${dateOnly.month.toString().padLeft(2, '0')}-${dateOnly.day.toString().padLeft(2, '0')}';

    final reportsBox = Hive.box<DailyStudyReport>('daily_reports');
    return reportsBox.get(reportId);
  }

  static Future<void> generateMissingReports() async {
    // Generate reports for the last 30 days if missing
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      await generateDailyReport(date);
    }
  }
}
