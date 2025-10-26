import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_stats.dart';
import '../models/study_session.dart';
import '../utils/theme.dart';
import 'streak_calendar_dialog.dart';

class StreakCard extends StatefulWidget {
  const StreakCard({super.key});

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard> {
  double _getTodayStudyHours() {
    final sessionsBox = Hive.box<StudySession>('study_sessions');
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final todaySessions = sessionsBox.values.where((session) {
      return session.startTime.isAfter(todayStart) &&
          session.startTime.isBefore(todayEnd);
    }).toList();

    final totalMinutes = todaySessions.fold<int>(
      0,
      (sum, session) => sum + session.duration,
    );

    return totalMinutes / 60.0;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<UserStats>('user_stats').listenable(),
      builder: (context, Box<UserStats> box, _) {
        final userStats = box.get('user_stats') ?? UserStats.initial();
        final todayHours = _getTodayStudyHours();
        const dailyGoalHours = 4.0;
        final progressPercentage =
            (todayHours / dailyGoalHours).clamp(0.0, 1.0);

        return Card(
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) =>
                    StreakCalendarDialog(userStats: userStats),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Header with fire icon and title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: userStats.currentStreak > 0
                              ? Colors.orange.withValues(alpha: 0.2)
                              : Colors.grey.withValues(alpha: 0.2),
                        ),
                        child: Icon(
                          Icons.local_fire_department,
                          color: userStats.currentStreak > 0
                              ? Colors.orange
                              : Colors.grey,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Study Streak',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Big streak number
                  Text(
                    '${userStats.currentStreak}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 48,
                        ),
                  ),

                  Text(
                    userStats.currentStreak == 1 ? 'day' : 'days',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                  ),

                  const SizedBox(height: 20),

                  // Today's progress section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: progressPercentage >= 1.0
                          ? AppTheme.studyDayColor.withValues(alpha: 0.1)
                          : Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: progressPercentage >= 1.0
                            ? AppTheme.studyDayColor.withValues(alpha: 0.3)
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Today',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              '${todayHours.toStringAsFixed(1)}h / ${dailyGoalHours.toInt()}h',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: progressPercentage >= 1.0
                                        ? AppTheme.studyDayColor
                                        : Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progressPercentage,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progressPercentage >= 1.0
                                ? AppTheme.studyDayColor
                                : Theme.of(context).colorScheme.primary,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Tap to view calendar',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
