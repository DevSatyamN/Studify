import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/achievement.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Achievement>('achievements').listenable(),
        builder: (context, Box<Achievement> box, _) {
          final achievements = box.values.toList();
          final unlockedCount = achievements.where((a) => a.isUnlocked).length;

          return Column(
            children: [
              // Progress header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '$unlockedCount / ${achievements.length}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Achievements Unlocked',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: unlockedCount / achievements.length,
                      backgroundColor: Colors.white30,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ],
                ),
              ),

              // Achievements list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    return _AchievementCard(achievement: achievements[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: achievement.isUnlocked
              ? _getCategoryColor(achievement.category)
              : Colors.grey,
          child: Icon(
            _getCategoryIcon(achievement.category),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          achievement.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: achievement.isUnlocked
                ? null
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement.description,
              style: TextStyle(
                color: achievement.isUnlocked
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  size: 14,
                  color: Colors.amber,
                ),
                const SizedBox(width: 4),
                Text(
                  '${achievement.xpReward} XP',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(achievement.category)
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    achievement.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getCategoryColor(achievement.category),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: achievement.isUnlocked
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
                  if (achievement.unlockedAt != null)
                    Text(
                      _formatDate(achievement.unlockedAt!),
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              )
            : const Icon(
                Icons.lock,
                color: Colors.grey,
                size: 24,
              ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'streak':
        return Colors.orange;
      case 'pomodoro':
        return Colors.red;
      case 'time':
        return Colors.blue;
      case 'general':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'streak':
        return Icons.local_fire_department;
      case 'pomodoro':
        return Icons.timer;
      case 'time':
        return Icons.access_time;
      case 'general':
        return Icons.star;
      default:
        return Icons.emoji_events;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference}d ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
