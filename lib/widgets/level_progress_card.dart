import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_stats.dart';

class LevelProgressCard extends StatelessWidget {
  const LevelProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<UserStats>('user_stats').listenable(),
      builder: (context, Box<UserStats> box, _) {
        final userStats = box.get('user_stats') ?? UserStats.initial();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Level ${userStats.currentLevel}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: userStats.levelProgress,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${userStats.xpInCurrentLevel}/${userStats.xpForNextLevel} XP',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
