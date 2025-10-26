import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/subject.dart';
import '../models/study_session.dart';
import '../models/syllabus_group.dart';
import '../utils/theme.dart';
import '../screens/main_screen.dart';

class SmartRecommendation {
  final String title;
  final String description;
  final String reason;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  SmartRecommendation({
    required this.title,
    required this.description,
    required this.reason,
    required this.icon,
    required this.color,
    this.onTap,
  });
}

class SmartRecommendationsCard extends ConsumerWidget {
  final List<Subject> subjects;
  final List<StudySession> recentSessions;

  const SmartRecommendationsCard({
    super.key,
    required this.subjects,
    required this.recentSessions,
  });

  void _startPomodoroWithSubject(BuildContext context, String subjectId) {
    // Navigate to main screen and switch to Pomodoro tab
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MainScreen(
          initialIndex: 1, // Pomodoro tab
          selectedSubjectId: subjectId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: Hive.box<SyllabusGroup>('syllabus_groups').listenable(),
      builder: (context, Box<SyllabusGroup> syllabusBox, _) {
        final recommendations =
            _generateSyllabusRecommendations(syllabusBox.values.toList());

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.psychology_outlined,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Smart Recommendations',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (recommendations.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 48,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create syllabus groups to get personalized recommendations',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...recommendations
                      .take(3)
                      .map((rec) => _buildRecommendationItem(context, rec)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendationItem(
      BuildContext context, SmartRecommendation recommendation) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: recommendation.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: recommendation.color.withValues(alpha: 0.2),
            ),
            gradient: LinearGradient(
              colors: [
                recommendation.color.withValues(alpha: 0.05),
                recommendation.color.withValues(alpha: 0.02),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: recommendation.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  recommendation.icon,
                  color: recommendation.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recommendation.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recommendation.reason,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: recommendation.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<SmartRecommendation> _generateSyllabusRecommendations(
      List<SyllabusGroup> syllabusGroups) {
    final recommendations = <SmartRecommendation>[];

    if (syllabusGroups.isEmpty) {
      return recommendations;
    }

    // Analyze study patterns
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));
    final recentStudySessions = recentSessions
        .where((session) => session.startTime.isAfter(lastWeek))
        .toList();

    // Find subjects not studied recently from syllabus
    final studiedSubjects = recentStudySessions.map((s) => s.subjectId).toSet();

    for (final group in syllabusGroups) {
      // Recommend incomplete groups
      if (!group.isCompleted && group.progressPercentage < 1.0) {
        final nextSubject = group.nextRecommendedSubject;
        if (nextSubject != null && !studiedSubjects.contains(nextSubject.id)) {
          recommendations.add(
            SmartRecommendation(
              title: 'Continue ${group.name}',
              description: 'Study ${nextSubject.name}',
              reason: 'You haven\'t studied this recently',
              icon: Icons.play_circle_outline,
              color: Color(int.parse(group.color.replaceFirst('#', '0xFF'))),
              onTap: () => _startPomodoroWithSyllabus(nextSubject.id),
            ),
          );
        }
      }

      // Recommend subjects with low progress
      for (final subject in group.subjects) {
        if (subject.progressPercentage < 0.5 &&
            !studiedSubjects.contains(subject.id)) {
          recommendations.add(
            SmartRecommendation(
              title: 'Focus on ${subject.name}',
              description:
                  'Only ${(subject.progressPercentage * 100).toInt()}% complete',
              reason: 'Low progress detected',
              icon: Icons.trending_up,
              color: Colors.orange,
              onTap: () => _startPomodoroWithSyllabus(subject.id),
            ),
          );
        }
      }
    }

    // Recommend based on upcoming deadlines
    for (final group in syllabusGroups) {
      if (group.targetDate != null &&
          group.targetDate!.difference(now).inDays <= 7 &&
          !group.isCompleted) {
        recommendations.add(
          SmartRecommendation(
            title: 'Urgent: ${group.name}',
            description:
                'Deadline in ${group.targetDate!.difference(now).inDays} days',
            reason: 'Approaching deadline',
            icon: Icons.warning_outlined,
            color: Colors.red,
            onTap: () => _startPomodoroWithSyllabus(
                group.nextRecommendedSubject?.id ?? ''),
          ),
        );
      }
    }

    return recommendations;
  }

  void _startPomodoroWithSyllabus(String subjectId) {
    // This would need to be implemented to start Pomodoro with specific syllabus subject
    // For now, just navigate to Pomodoro screen
  }
}
