import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/exam.dart';
import '../models/subject.dart';

class UpcomingExamsCard extends StatelessWidget {
  const UpcomingExamsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Exam>('exams').listenable(),
      builder: (context, Box<Exam> box, _) {
        final upcomingExams = box.values
            .where((exam) => exam.isUpcoming)
            .toList()
          ..sort((a, b) => a.examDate.compareTo(b.examDate));

        if (upcomingExams.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.school,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Upcoming Exams',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...upcomingExams.take(3).map((exam) => _ExamItem(exam: exam)),
                if (upcomingExams.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '+${upcomingExams.length - 3} more exams',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ExamItem extends StatelessWidget {
  final Exam exam;

  const _ExamItem({required this.exam});

  @override
  Widget build(BuildContext context) {
    final subjectsBox = Hive.box<Subject>('subjects');
    final subject = subjectsBox.get(exam.subjectId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: subject?.color ?? Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  '${subject?.name ?? 'Unknown'} • ${_formatDate(exam.examDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getDaysLeftColor(exam.daysLeft, context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${exam.daysLeft}d',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  Color _getDaysLeftColor(int daysLeft, BuildContext context) {
    if (daysLeft <= 3) {
      return Colors.red;
    } else if (daysLeft <= 7) {
      return Colors.orange;
    } else {
      return Theme.of(context).colorScheme.primary;
    }
  }
}
