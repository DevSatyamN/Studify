import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/study_session.dart';
import '../models/subject.dart';
import '../models/syllabus_group.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<StudySession>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<StudySession> _getEventsForDay(DateTime day) {
    final sessionsBox = Hive.box<StudySession>('study_sessions');
    return sessionsBox.values.where((session) {
      return isSameDay(session.startTime, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Calendar'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<StudySession>('study_sessions').listenable(),
        builder: (context, Box<StudySession> box, _) {
          return Column(
            children: [
              TableCalendar<StudySession>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                eventLoader: _getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  markerDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                onDaySelected: _onDaySelected,
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: ValueListenableBuilder<List<StudySession>>(
                  valueListenable: _selectedEvents,
                  builder: (context, value, _) {
                    if (value.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No study sessions',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'on ${DateFormat('MMM dd, yyyy').format(_selectedDay!)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        return _SessionCard(session: value[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }
}

class _SessionCard extends StatelessWidget {
  final StudySession session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    // Try to find syllabus information first
    final syllabusBox = Hive.box<SyllabusGroup>('syllabus_groups');
    String subjectName = 'Unknown Subject';
    String? chapterName;
    Color subjectColor = Colors.grey;

    // Search through syllabus groups to find the subject
    for (final group in syllabusBox.values) {
      for (final subject in group.subjects) {
        if (subject.id == session.subjectId) {
          subjectName = subject.name;
          subjectColor =
              Color(int.parse(group.color.replaceFirst('#', '0xFF')));

          // Extract chapter information from session notes
          if (session.notes != null && session.notes!.startsWith('Chapter: ')) {
            chapterName =
                session.notes!.substring(9); // Remove "Chapter: " prefix
          }
          break;
        }
      }
      if (subjectName != 'Unknown Subject') break;
    }

    // Fallback to old subject system if not found in syllabus
    if (subjectName == 'Unknown Subject') {
      final subjectsBox = Hive.box<Subject>('subjects');
      final subject = subjectsBox.get(session.subjectId);
      subjectName = subject?.name ?? 'Unknown Subject';
      subjectColor = subject?.color ?? Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: subjectColor,
          child: Icon(
            session.type == 'pomodoro' ? Icons.timer : Icons.play_circle,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          subjectName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateFormat('HH:mm').format(session.startTime)} - ${DateFormat('HH:mm').format(session.endTime)}',
            ),
            Text(
              '${session.duration} minutes',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            if (session.notes != null &&
                session.notes!.isNotEmpty &&
                !session.notes!.startsWith('Chapter: '))
              Text(
                session.notes!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: chapterName != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  chapterName,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
