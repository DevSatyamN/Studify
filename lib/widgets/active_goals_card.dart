import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/goal.dart';
import '../models/subject.dart';

class ActiveGoalsCard extends StatelessWidget {
  const ActiveGoalsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Goal>('goals').listenable(),
      builder: (context, Box<Goal> box, _) {
        final activeGoals = box.values
            .where((goal) => !goal.isCompleted)
            .toList()
          ..sort((a, b) => a.targetDate.compareTo(b.targetDate));

        if (activeGoals.isEmpty) {
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
                      Icons.flag,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Active Goals',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...activeGoals.take(3).map((goal) => _GoalItem(goal: goal)),
                if (activeGoals.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '+${activeGoals.length - 3} more goals',
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

class _GoalItem extends StatelessWidget {
  final Goal goal;

  const _GoalItem({required this.goal});

  @override
  Widget build(BuildContext context) {
    final subjectsBox = Hive.box<Subject>('subjects');
    final subject = subjectsBox.get(goal.subjectId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                child: Text(
                  goal.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Text(
                '${(goal.progressPercentage * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: goal.progressPercentage,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    subject?.color ?? Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${goal.currentHours}/${goal.targetHours} hours • ${goal.daysLeft} days left',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
