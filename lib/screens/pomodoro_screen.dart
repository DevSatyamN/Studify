import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/study_session.dart';
import '../models/subject.dart';
import '../models/user_stats.dart';
import '../models/syllabus_group.dart';
import '../models/xp_transaction.dart';
import '../services/achievement_service.dart';
import '../services/daily_report_service.dart';
import '../services/app_lifecycle_manager.dart';
import '../widgets/modern_timer_widget.dart';
import '../widgets/curved_dropdown.dart';

// Providers for Pomodoro state
final pomodoroStateProvider =
    StateNotifierProvider<PomodoroNotifier, PomodoroState>((ref) {
  return PomodoroNotifier();
});

class PomodoroState {
  final int workDuration;
  final int shortBreakDuration;
  final int longBreakDuration;
  final int currentMinutes;
  final int currentSeconds;
  final bool isRunning;
  final bool isBreak;
  final int completedPomodoros;
  final String? selectedSubjectId;
  final String? selectedGroupId;
  final String? selectedChapterId;

  PomodoroState({
    this.workDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.currentMinutes = 25,
    this.currentSeconds = 0,
    this.isRunning = false,
    this.isBreak = false,
    this.completedPomodoros = 0,
    this.selectedSubjectId,
    this.selectedGroupId,
    this.selectedChapterId,
  });

  PomodoroState copyWith({
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? currentMinutes,
    int? currentSeconds,
    bool? isRunning,
    bool? isBreak,
    int? completedPomodoros,
    String? selectedSubjectId,
    String? selectedGroupId,
    String? selectedChapterId,
  }) {
    return PomodoroState(
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      currentMinutes: currentMinutes ?? this.currentMinutes,
      currentSeconds: currentSeconds ?? this.currentSeconds,
      isRunning: isRunning ?? this.isRunning,
      isBreak: isBreak ?? this.isBreak,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      selectedSubjectId: selectedSubjectId ?? this.selectedSubjectId,
      selectedGroupId: selectedGroupId ?? this.selectedGroupId,
      selectedChapterId: selectedChapterId ?? this.selectedChapterId,
    );
  }
}

class PomodoroNotifier extends StateNotifier<PomodoroState> {
  Timer? _timer;
  DateTime? _sessionStartTime;

  PomodoroNotifier() : super(PomodoroState());

  void setSubject(String subjectId) {
    state = state.copyWith(selectedSubjectId: subjectId);
  }

  void setSyllabusSelection({
    String? groupId,
    String? subjectId,
    String? chapterId,
  }) {
    state = state.copyWith(
      selectedGroupId: groupId,
      selectedSubjectId: subjectId,
      selectedChapterId: chapterId,
    );
  }

  void updateSettings({
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
  }) {
    state = state.copyWith(
      workDuration: workDuration,
      shortBreakDuration: shortBreakDuration,
      longBreakDuration: longBreakDuration,
    );

    if (!state.isRunning) {
      _resetTimer();
    }
  }

  void startTimer() {
    if (state.selectedChapterId == null) return;

    _sessionStartTime = DateTime.now();
    state = state.copyWith(isRunning: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.currentSeconds > 0) {
        state = state.copyWith(currentSeconds: state.currentSeconds - 1);
      } else if (state.currentMinutes > 0) {
        state = state.copyWith(
          currentMinutes: state.currentMinutes - 1,
          currentSeconds: 59,
        );
      } else {
        _completeSession();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void resetTimer() {
    _timer?.cancel();
    _resetTimer();
    state = state.copyWith(isRunning: false);
  }

  void _resetTimer() {
    final duration = state.isBreak
        ? (state.completedPomodoros % 4 == 0 && state.completedPomodoros > 0
            ? state.longBreakDuration
            : state.shortBreakDuration)
        : state.workDuration;

    state = state.copyWith(
      currentMinutes: duration,
      currentSeconds: 0,
    );
  }

  void _completeSession() {
    _timer?.cancel();

    if (!state.isBreak) {
      // Work session completed
      _saveStudySession();
      _updateUserStats();

      state = state.copyWith(
        completedPomodoros: state.completedPomodoros + 1,
        isBreak: true,
        isRunning: false,
      );

      // Play completion sound
      _playCompletionSound();
    } else {
      // Break completed
      state = state.copyWith(
        isBreak: false,
        isRunning: false,
      );
    }

    _resetTimer();
  }

  void _saveStudySession() {
    if (state.selectedSubjectId == null || _sessionStartTime == null) return;

    final session = StudySession.create(
      subjectId: state.selectedSubjectId!,
      startTime: _sessionStartTime!,
      endTime: DateTime.now(),
      type: 'pomodoro',
    );

    // Add chapter information to session notes if available
    if (state.selectedChapterId != null) {
      final chapterName = _getChapterName();
      session.notes = 'Chapter: $chapterName';
    }

    final sessionsBox = Hive.box<StudySession>('study_sessions');
    sessionsBox.put(session.id, session);

    // Update subject stats
    final subjectsBox = Hive.box<Subject>('subjects');
    final subject = subjectsBox.get(state.selectedSubjectId!);
    subject?.updateStats(state.workDuration);

    // Generate daily report
    _generateDailyReport();

    // Trigger auto backup after study session completion
    AppLifecycleManager().onStudySessionCompleted();
  }

  String _getChapterName() {
    if (state.selectedGroupId == null ||
        state.selectedSubjectId == null ||
        state.selectedChapterId == null) {
      return 'Unknown Chapter';
    }

    final syllabusBox = Hive.box<SyllabusGroup>('syllabus_groups');
    try {
      final group =
          syllabusBox.values.firstWhere((g) => g.id == state.selectedGroupId);
      final subject =
          group.subjects.firstWhere((s) => s.id == state.selectedSubjectId);
      final chapter =
          subject.chapters.firstWhere((c) => c.id == state.selectedChapterId);
      return chapter.name;
    } catch (e) {
      return 'Unknown Chapter';
    }
  }

  void _generateDailyReport() async {
    await DailyReportService.generateDailyReport(DateTime.now());
  }

  void _updateUserStats() async {
    final userStatsBox = Hive.box<UserStats>('user_stats');
    final userStats = userStatsBox.get('user_stats') ?? UserStats.initial();
    final transactionsBox = Hive.box<XPTransaction>('xp_transactions');

    // Calculate XP based on study duration (minimum 25 minutes for XP)
    int xpToAdd = 0;
    if (state.workDuration >= 25) {
      xpToAdd = state.workDuration; // 1 XP per minute for 25+ minutes
    }
    // No XP for sessions less than 25 minutes

    if (xpToAdd > 0) {
      userStats.addXP(xpToAdd);

      // Create XP transaction only if XP was earned
      final transaction = XPTransaction.studySession(
        xp: xpToAdd,
        minutes: state.workDuration,
        sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      await transactionsBox.put(transaction.id, transaction);
    }

    userStats.addSession(state.workDuration, true);
    userStatsBox.put('user_stats', userStats);

    // Check for achievements after updating stats
    final unlockedAchievements =
        await AchievementService.checkAndUnlockAchievements();

    // Create XP transactions for achievements
    for (final achievement in unlockedAchievements) {
      final achievementTransaction = XPTransaction.achievement(
        xp: achievement.xpReward,
        achievementName: achievement.title,
        achievementId: achievement.id,
      );
      await transactionsBox.put(
          achievementTransaction.id, achievementTransaction);
    }
  }

  void _playCompletionSound() async {
    // Audio removed to reduce APK size
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoroState = ref.watch(pomodoroStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context, ref),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Syllabus selector (hide when timer is running)
            if (!pomodoroState.isRunning)
              ValueListenableBuilder(
                valueListenable:
                    Hive.box<SyllabusGroup>('syllabus_groups').listenable(),
                builder: (context, Box<SyllabusGroup> syllabusBox, _) {
                  final syllabusGroups = syllabusBox.values.toList();
                  return _SyllabusSelector(syllabusGroups: syllabusGroups);
                },
              ),

            // Show selected material when timer is running (only during work sessions)
            if (pomodoroState.isRunning &&
                pomodoroState.selectedChapterId != null &&
                !pomodoroState.isBreak)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
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
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Currently Studying',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getSelectedChapterName(pomodoroState),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            // Show break message during break time
            if (pomodoroState.isRunning && pomodoroState.isBreak)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withValues(alpha: 0.1),
                      Colors.teal.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Break Time',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Take a rest!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Timer display
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),

                    // Modern timer widget
                    ModernTimerWidget(
                      progress: _getProgress(pomodoroState),
                      timeText:
                          '${pomodoroState.currentMinutes.toString().padLeft(2, '0')}:${pomodoroState.currentSeconds.toString().padLeft(2, '0')}',
                      isBreak: pomodoroState.isBreak,
                      isRunning: pomodoroState.isRunning,
                    ),

                    const SizedBox(height: 20),

                    const SizedBox(height: 12),

                    // Pomodoro count
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Completed: ${pomodoroState.completedPomodoros}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Reset button
                Container(
                  width: 120,
                  height: 56,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade700, Colors.grey.shade800],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: pomodoroState.selectedSubjectId != null
                        ? () => ref
                            .read(pomodoroStateProvider.notifier)
                            .resetTimer()
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, size: 20, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Play/Pause button (larger)
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: pomodoroState.isRunning
                            ? [Colors.orange.shade400, Colors.orange.shade600]
                            : [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: (pomodoroState.isRunning
                                  ? Colors.orange
                                  : Theme.of(context).colorScheme.primary)
                              .withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: pomodoroState.selectedChapterId != null
                          ? () {
                              if (pomodoroState.isRunning) {
                                ref
                                    .read(pomodoroStateProvider.notifier)
                                    .pauseTimer();
                              } else {
                                ref
                                    .read(pomodoroStateProvider.notifier)
                                    .startTimer();
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            pomodoroState.isRunning
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 24,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            pomodoroState.isRunning ? 'Pause' : 'Start',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _getProgress(PomodoroState state) {
    final totalDuration = state.isBreak
        ? (state.completedPomodoros % 4 == 0 && state.completedPomodoros > 0
            ? state.longBreakDuration
            : state.shortBreakDuration)
        : state.workDuration;

    final currentTotal = state.currentMinutes * 60 + state.currentSeconds;
    final totalSeconds = totalDuration * 60;

    return 1.0 - (currentTotal / totalSeconds);
  }

  String _getSelectedChapterName(PomodoroState state) {
    if (state.selectedGroupId == null ||
        state.selectedSubjectId == null ||
        state.selectedChapterId == null) {
      return 'Selected Chapter';
    }

    final syllabusBox = Hive.box<SyllabusGroup>('syllabus_groups');
    final group = syllabusBox.values.firstWhere(
      (g) => g.id == state.selectedGroupId,
      orElse: () => syllabusBox.values.first,
    );

    final subject = group.subjects.firstWhere(
      (s) => s.id == state.selectedSubjectId,
      orElse: () => group.subjects.first,
    );

    final chapter = subject.chapters.firstWhere(
      (c) => c.id == state.selectedChapterId,
      orElse: () => subject.chapters.first,
    );

    return '${subject.name} - ${chapter.name}';
  }

  void _showSettingsDialog(BuildContext context, WidgetRef ref) {
    final state = ref.read(pomodoroStateProvider);

    showDialog(
      context: context,
      builder: (context) => _PomodoroSettingsDialog(
        workDuration: state.workDuration,
        shortBreakDuration: state.shortBreakDuration,
        longBreakDuration: state.longBreakDuration,
        onSave: (work, shortBreak, longBreak) {
          ref.read(pomodoroStateProvider.notifier).updateSettings(
                workDuration: work,
                shortBreakDuration: shortBreak,
                longBreakDuration: longBreak,
              );
        },
      ),
    );
  }
}

class _SyllabusSelector extends ConsumerStatefulWidget {
  final List<SyllabusGroup> syllabusGroups;

  const _SyllabusSelector({required this.syllabusGroups});

  @override
  ConsumerState<_SyllabusSelector> createState() => _SyllabusSelectorState();
}

class _SyllabusSelectorState extends ConsumerState<_SyllabusSelector> {
  @override
  Widget build(BuildContext context) {
    final pomodoroState = ref.watch(pomodoroStateProvider);

    if (widget.syllabusGroups.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.library_books_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                'No syllabus groups available',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Create a syllabus group first to track your study progress',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final selectedGroup = pomodoroState.selectedGroupId != null
        ? widget.syllabusGroups.firstWhere(
            (g) => g.id == pomodoroState.selectedGroupId,
            orElse: () => widget.syllabusGroups.first,
          )
        : null;

    final selectedSubject =
        selectedGroup != null && pomodoroState.selectedSubjectId != null
            ? selectedGroup.subjects.firstWhere(
                (s) => s.id == pomodoroState.selectedSubjectId,
                orElse: () => selectedGroup.subjects.first,
              )
            : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.library_books,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Select Study Material',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Group selection
            Text(
              'Syllabus Group',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            CurvedDropdown<String>(
              value: pomodoroState.selectedGroupId,
              hint: 'Choose a group',
              enabled: !pomodoroState.isRunning,
              items: widget.syllabusGroups.map((group) {
                return DropdownMenuItem(
                  value: group.id,
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Color(
                              int.parse(group.color.replaceFirst('#', '0xFF'))),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(group.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  ref.read(pomodoroStateProvider.notifier).setSyllabusSelection(
                        groupId: value,
                        subjectId: null,
                        chapterId: null,
                      );
                }
              },
            ),

            if (selectedGroup != null) ...[
              const SizedBox(height: 16),

              // Subject selection
              Text(
                'Subject',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              CurvedDropdown<String>(
                value: pomodoroState.selectedSubjectId,
                hint: 'Choose a subject',
                enabled: !pomodoroState.isRunning,
                items: selectedGroup.subjects.map((subject) {
                  return DropdownMenuItem(
                    value: subject.id,
                    child: Text(subject.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(pomodoroStateProvider.notifier)
                        .setSyllabusSelection(
                          groupId: pomodoroState.selectedGroupId,
                          subjectId: value,
                          chapterId: null,
                        );
                  }
                },
              ),
            ],

            if (selectedSubject != null) ...[
              const SizedBox(height: 16),

              // Chapter selection
              Text(
                'Chapter',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              CurvedDropdown<String>(
                value: pomodoroState.selectedChapterId,
                hint: 'Choose a chapter',
                enabled: !pomodoroState.isRunning,
                items: selectedSubject.chapters.map((chapter) {
                  final isCompleted =
                      selectedSubject.completedChapters.contains(chapter.id);
                  return DropdownMenuItem(
                    value: chapter.id,
                    child: Row(
                      children: [
                        Icon(
                          isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 16,
                          color: isCompleted ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(chapter.name)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(pomodoroStateProvider.notifier)
                        .setSyllabusSelection(
                          groupId: pomodoroState.selectedGroupId,
                          subjectId: pomodoroState.selectedSubjectId,
                          chapterId: value,
                        );
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PomodoroSettingsDialog extends StatefulWidget {
  final int workDuration;
  final int shortBreakDuration;
  final int longBreakDuration;
  final Function(int, int, int) onSave;

  const _PomodoroSettingsDialog({
    required this.workDuration,
    required this.shortBreakDuration,
    required this.longBreakDuration,
    required this.onSave,
  });

  @override
  State<_PomodoroSettingsDialog> createState() =>
      _PomodoroSettingsDialogState();
}

class _PomodoroSettingsDialogState extends State<_PomodoroSettingsDialog> {
  late int workDuration;
  late int shortBreakDuration;
  late int longBreakDuration;

  @override
  void initState() {
    super.initState();
    workDuration = widget.workDuration;
    shortBreakDuration = widget.shortBreakDuration;
    longBreakDuration = widget.longBreakDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Pomodoro Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ),

              // Settings content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _DurationSlider(
                      label: 'Work Duration',
                      value: workDuration,
                      min: 1,
                      max: 60,
                      onChanged: (value) =>
                          setState(() => workDuration = value),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    _DurationSlider(
                      label: 'Short Break',
                      value: shortBreakDuration,
                      min: 1,
                      max: 15,
                      onChanged: (value) =>
                          setState(() => shortBreakDuration = value),
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 20),
                    _DurationSlider(
                      label: 'Long Break',
                      value: longBreakDuration,
                      min: 1,
                      max: 30,
                      onChanged: (value) =>
                          setState(() => longBreakDuration = value),
                      color: Colors.green,
                    ),
                    const SizedBox(height: 24),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          widget.onSave(workDuration, shortBreakDuration,
                              longBreakDuration);
                          Navigator.pop(context);
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save Settings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationSlider extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final Color color;

  const _DurationSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$value min',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.3),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: max - min,
              onChanged: (value) => onChanged(value.round()),
            ),
          ),
        ],
      ),
    );
  }
}
