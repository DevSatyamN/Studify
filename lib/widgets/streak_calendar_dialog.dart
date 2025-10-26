import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_stats.dart';
import '../utils/theme.dart';

class StreakCalendarDialog extends StatefulWidget {
  final UserStats userStats;

  const StreakCalendarDialog({super.key, required this.userStats});

  @override
  State<StreakCalendarDialog> createState() => _StreakCalendarDialogState();
}

class _StreakCalendarDialogState extends State<StreakCalendarDialog> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Widget _buildCalendarDay(DateTime day, bool isToday, bool isSelected) {
    final dayString =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final hasStudied = widget.userStats.studyDates.contains(dayString);
    final isInWeekStreak = _isInWeekStreak(day);
    final isPast =
        day.isBefore(DateTime.now().subtract(const Duration(days: 1)));
    final isFuture = day.isAfter(DateTime.now());

    Color backgroundColor = Colors.transparent;
    Color textColor = Theme.of(context).colorScheme.onSurface;
    Widget? icon;

    if (hasStudied) {
      backgroundColor = AppTheme.studyDayColor;
      textColor = Colors.white;
    } else if (isPast && !hasStudied) {
      // Check if freeze token was used (placeholder logic)
      final wasFreezed = _wasDayFreezed(day);
      if (wasFreezed) {
        backgroundColor = Colors.blue.withValues(alpha: 0.7);
        textColor = Colors.white;
        icon = const Icon(Icons.ac_unit, color: Colors.white, size: 12);
      } else {
        backgroundColor = Colors.red.withValues(alpha: 0.3);
        textColor = Colors.red.shade700;
      }
    } else if (isFuture) {
      textColor =
          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4);
    }

    if (isToday) {
      backgroundColor = backgroundColor == Colors.transparent
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
          : backgroundColor;
    }

    if (isSelected) {
      backgroundColor = backgroundColor == Colors.transparent
          ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5)
          : backgroundColor;
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: isInWeekStreak && hasStudied
            ? Border.all(color: Colors.yellow, width: 2)
            : null,
        boxShadow: isInWeekStreak && hasStudied
            ? [
                BoxShadow(
                  color: Colors.yellow.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: hasStudied ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (icon != null)
              Positioned(
                top: 2,
                right: 2,
                child: icon,
              ),
          ],
        ),
      ),
    );
  }

  bool _isInWeekStreak(DateTime day) {
    // Check if this day is part of a 7-day streak
    final dayString =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    int consecutiveDays = 0;

    for (int i = 0; i < 7; i++) {
      final checkDay = day.subtract(Duration(days: i));
      final checkDayString =
          '${checkDay.year}-${checkDay.month.toString().padLeft(2, '0')}-${checkDay.day.toString().padLeft(2, '0')}';
      if (widget.userStats.studyDates.contains(checkDayString)) {
        consecutiveDays++;
      } else {
        break;
      }
    }

    return consecutiveDays >= 7;
  }

  bool _wasDayFreezed(DateTime day) {
    // Placeholder logic - in a real app, you'd track freeze token usage
    // For now, we'll assume some days were freezed based on patterns
    return false; // This would be enhanced with actual freeze token tracking
  }

  void _showFreezeTokenInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.ac_unit,
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Freeze Tokens',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Reward',
              style: TextStyle(
                color: Colors.grey.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'If you maintain 7 days streak continuously, you will earn 1 freeze token as a weekly reward.',
              style: TextStyle(
                color: Colors.grey.withOpacity(0.9),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Use freeze tokens to protect your streak when you miss a day!',
                      style: TextStyle(
                        color: Colors.blue.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it!',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Streak Calendar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Current: ${widget.userStats.currentStreak} days',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Freeze Tokens with click functionality
                        GestureDetector(
                          onTap: () => _showFreezeTokenInfo(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.ac_unit,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Freeze: ${widget.userStats.freezeTokens}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.2),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Calendar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TableCalendar<String>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: (day) {
                    final dayString =
                        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                    return widget.userStats.studyDates.contains(dayString)
                        ? ['studied']
                        : [];
                  },
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return _buildCalendarDay(day, false, false);
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return _buildCalendarDay(day, true, false);
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      return _buildCalendarDay(day, false, true);
                    },
                  ),
                  calendarStyle: const CalendarStyle(
                    outsideDaysVisible: false,
                    markerDecoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final IconData? icon;

  const _LegendItem(
      {super.key, required this.color, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: icon != null
              ? Icon(
                  icon,
                  size: 8,
                  color: Colors.white,
                )
              : null,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
