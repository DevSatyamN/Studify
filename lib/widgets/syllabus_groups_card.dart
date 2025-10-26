import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/syllabus_group.dart';
import '../utils/theme.dart';

class SyllabusGroupsCard extends ConsumerWidget {
  final List<SyllabusGroup> groups;
  final VoidCallback? onViewAll;

  const SyllabusGroupsCard({
    super.key,
    required this.groups,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Syllabus Progress',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (groups.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.library_books_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No syllabus groups yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...groups.take(3).map((group) => _buildGroupItem(context, group)),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupItem(BuildContext context, SyllabusGroup group) {
    final theme = Theme.of(context);
    final progress = group.progressPercentage;
    final color = Color(int.parse(group.color.replaceFirst('#', '0xFF')));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.05),
            color.withValues(alpha: 0.02),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  group.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: group.isCompleted
                      ? AppTheme.studyDayColor.withValues(alpha: 0.1)
                      : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  group.isCompleted
                      ? 'Complete'
                      : '${group.completedChapters}/${group.totalChapters}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: group.isCompleted ? AppTheme.studyDayColor : color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              group.isCompleted ? AppTheme.studyDayColor : color,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.topic_outlined,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                group.nextRecommendedSubject != null
                    ? 'Next: ${group.nextRecommendedSubject!.name}'
                    : 'All subjects completed!',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
