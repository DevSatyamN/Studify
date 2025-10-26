import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/study_session.dart';

class QuickStatsCard extends StatelessWidget {
  const QuickStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<StudySession>('study_sessions').listenable(),
      builder: (context, Box<StudySession> sessionsBox, _) {
        final todayStats = _getTodayStats(sessionsBox);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.today,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Today\'s Stats',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      icon: Icons.school,
                      label: 'Study Time',
                      value: _formatTime(todayStats['studyTime']!),
                      color: Colors.blue,
                    ),
                    _StatItem(
                      icon: Icons.coffee,
                      label: 'Break Time',
                      value: _formatTime(todayStats['breakTime']!),
                      color: Colors.orange,
                    ),
                    _StatItem(
                      icon: Icons.play_circle,
                      label: 'Sessions',
                      value: '${todayStats['sessions']}',
                      color: Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, int> _getTodayStats(Box<StudySession> sessionsBox) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final todaySessions = sessionsBox.values.where((session) {
      return session.startTime.isAfter(todayStart) &&
          session.startTime.isBefore(todayEnd);
    }).toList();

    int totalStudyTime = 0;
    int totalBreakTime = 0;
    int sessionCount = todaySessions.length;

    for (final session in todaySessions) {
      if (session.type == 'break') {
        totalBreakTime += session.duration;
      } else {
        totalStudyTime += session.duration;
      }
    }

    return {
      'studyTime': totalStudyTime,
      'breakTime': totalBreakTime,
      'sessions': sessionCount,
    };
  }

  String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? Theme.of(context).colorScheme.primary)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color ?? Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
