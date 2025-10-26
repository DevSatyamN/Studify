import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_stats.dart';
import '../widgets/streak_card.dart';
import '../widgets/quick_stats_card.dart';
import '../widgets/upcoming_exams_card.dart';
import '../widgets/active_goals_card.dart';
import '../widgets/animated_welcome_widget.dart';
import '../widgets/syllabus_groups_card.dart';
import '../widgets/smart_recommendations_card.dart';
import '../models/subject.dart';
import '../models/study_session.dart';
import '../models/syllabus_group.dart';
import 'goals_screen.dart';
import 'exams_screen.dart';
import 'syllabus_screen.dart';
import 'daily_reports_screen.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback? onSwitchToPomodoro;

  const HomeScreen({super.key, this.onSwitchToPomodoro});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'Studify',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DailyReportsScreen(),
                ),
              );
            },
            tooltip: 'Daily Reports',
          ),
          ValueListenableBuilder(
            valueListenable: Hive.box<UserStats>('user_stats').listenable(),
            builder: (context, Box<UserStats> box, _) {
              final userStats = box.get('user_stats') ?? UserStats.initial();
              return Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: userStats.currentStreak > 0
                          ? Colors.orange
                          : Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${userStats.currentStreak}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated welcome message
            ValueListenableBuilder(
              valueListenable: Hive.box<UserStats>('user_stats').listenable(),
              builder: (context, Box<UserStats> box, _) {
                final userStats = box.get('user_stats') ?? UserStats.initial();
                return AnimatedWelcomeWidget(userStats: userStats);
              },
            ),

            const SizedBox(height: 16),

            // Stats row
            // Full-width streak card
            const StreakCard(),

            const SizedBox(height: 16),

            // Quick stats
            const QuickStatsCard(),

            const SizedBox(height: 24),

            // Quick actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.library_books,
                    title: 'Syllabus',
                    subtitle: 'Study roadmap',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SyllabusScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.flag,
                    title: 'Goals',
                    subtitle: 'Track progress',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GoalsScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.school,
                    title: 'Exams',
                    subtitle: 'Upcoming tests',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ExamsScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.timer,
                    title: 'Study Now',
                    subtitle: 'Start session',
                    onTap: () {
                      onSwitchToPomodoro?.call();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Upcoming exams
            const UpcomingExamsCard(),

            const SizedBox(height: 16),

            // Active goals
            const ActiveGoalsCard(),

            const SizedBox(height: 16),

            // Smart recommendations
            ValueListenableBuilder(
              valueListenable: Hive.box<Subject>('subjects').listenable(),
              builder: (context, Box<Subject> subjectsBox, _) {
                return ValueListenableBuilder(
                  valueListenable:
                      Hive.box<StudySession>('study_sessions').listenable(),
                  builder: (context, Box<StudySession> sessionsBox, _) {
                    final subjects = subjectsBox.values.toList();
                    final sessions = sessionsBox.values.toList();
                    return SmartRecommendationsCard(
                      subjects: subjects,
                      recentSessions: sessions,
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            // Syllabus groups
            ValueListenableBuilder(
              valueListenable:
                  Hive.box<SyllabusGroup>('syllabus_groups').listenable(),
              builder: (context, Box<SyllabusGroup> box, _) {
                final groups = box.values.toList();
                return SyllabusGroupsCard(
                  groups: groups,
                  onViewAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SyllabusScreen(),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Define colors for different action types
    final Map<String, List<Color>> actionColors = {
      'Syllabus': [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      'Goals': [const Color(0xFF10B981), const Color(0xFF059669)],
      'Exams': [const Color(0xFFEF4444), const Color(0xFFDC2626)],
      'Study Now': [const Color(0xFFF59E0B), const Color(0xFFD97706)],
    };

    final colors = actionColors[title] ??
        [
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.secondary
        ];

    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
