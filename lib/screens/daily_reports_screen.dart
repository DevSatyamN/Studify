import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/daily_study_report.dart';
import '../services/daily_report_service.dart';

class DailyReportsScreen extends StatefulWidget {
  const DailyReportsScreen({super.key});

  @override
  State<DailyReportsScreen> createState() => _DailyReportsScreenState();
}

class _DailyReportsScreenState extends State<DailyReportsScreen> {
  @override
  void initState() {
    super.initState();
    _generateMissingReports();
  }

  Future<void> _generateMissingReports() async {
    await DailyReportService.generateMissingReports();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Study Reports'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder(
        valueListenable:
            Hive.box<DailyStudyReport>('daily_reports').listenable(),
        builder: (context, Box<DailyStudyReport> box, _) {
          final reports = box.values.toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          if (reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.analytics_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No study reports yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start studying to see your daily progress reports here!',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              return _DailyReportCard(report: reports[index]);
            },
          );
        },
      ),
    );
  }
}

class _DailyReportCard extends StatelessWidget {
  final DailyStudyReport report;

  const _DailyReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(report.date);
    final isYesterday = _isYesterday(report.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isToday ? 8 : 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isToday
              ? LinearGradient(
                  colors: [
                    Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.1),
                  ],
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isToday
                            ? [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ]
                            : [
                                Colors.grey.shade600,
                                Colors.grey.shade700,
                              ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isToday
                          ? 'Today'
                          : isYesterday
                              ? 'Yesterday'
                              : report.formattedDate,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      report.formattedTotalTime,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Subject breakdown
              if (report.subjectData.isNotEmpty) ...[
                Text(
                  'Subjects Studied',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...report.subjectData.values.map((subjectData) {
                  final percentage =
                      (subjectData.totalTime / report.totalStudyTime * 100)
                          .round();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                subjectData.subjectName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '${subjectData.formattedTime} ($percentage%)',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: subjectData.totalTime / report.totalStudyTime,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (subjectData.sessions.length > 1) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${subjectData.sessions.length} sessions: ${subjectData.sessions.map((s) => s.formattedTime).join(', ')}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                        ],
                        if (subjectData.chaptersStudied.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            children: subjectData.chaptersStudied.entries
                                .map((entry) {
                              return Chip(
                                label: Text(
                                  entry.key,
                                  style: const TextStyle(fontSize: 10),
                                ),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.1),
                                side: BorderSide.none,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],

              // Summary stats
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${report.totalSessions} sessions',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.book_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${report.subjectData.length} subjects',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }
}
