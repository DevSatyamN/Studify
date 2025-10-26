import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/exam.dart';
import '../models/subject.dart';
import '../models/syllabus_group.dart';

class ExamsScreen extends StatelessWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exams'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Exam>('exams').listenable(),
        builder: (context, Box<Exam> box, _) {
          final exams = box.values.toList()
            ..sort((a, b) => a.examDate.compareTo(b.examDate));

          if (exams.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No exams scheduled',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first exam to track countdown',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exams.length,
            itemBuilder: (context, index) {
              return _ExamCard(exam: exams[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExamDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddExamDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddExamDialog(),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final Exam exam;

  const _ExamCard({required this.exam});

  @override
  Widget build(BuildContext context) {
    // Try to find syllabus information first
    final syllabusBox = Hive.box<SyllabusGroup>('syllabus_groups');
    String subjectName = 'Unknown Subject';
    Color subjectColor = Colors.grey;

    // Search through syllabus groups to find the subject
    for (final group in syllabusBox.values) {
      for (final subject in group.subjects) {
        if (subject.id == exam.subjectId) {
          subjectName = subject.name;
          subjectColor =
              Color(int.parse(group.color.replaceFirst('#', '0xFF')));
          break;
        }
      }
      if (subjectName != 'Unknown Subject') break;
    }

    // Fallback to old subject system if not found in syllabus
    if (subjectName == 'Unknown Subject') {
      final subjectsBox = Hive.box<Subject>('subjects');
      final subject = subjectsBox.get(exam.subjectId);
      subjectName = subject?.name ?? 'Unknown Subject';
      subjectColor = subject?.color ?? Colors.grey;
    }

    final now = DateTime.now();
    final daysUntil = exam.examDate.difference(now).inDays;
    final isPast = exam.examDate.isBefore(now);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: subjectColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    exam.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPast
                        ? Colors.grey.withValues(alpha: 0.1)
                        : (daysUntil <= 7
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.blue.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isPast
                        ? 'Past'
                        : daysUntil == 0
                            ? 'Today'
                            : daysUntil == 1
                                ? 'Tomorrow'
                                : '$daysUntil days',
                    style: TextStyle(
                      color: isPast
                          ? Colors.grey
                          : (daysUntil <= 7 ? Colors.red : Colors.blue),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subjectName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: subjectColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, yyyy • HH:mm').format(exam.examDate),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (exam.description != null && exam.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                exam.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            if (exam.location != null && exam.location!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    exam.location!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddExamDialog extends StatefulWidget {
  final Exam? exam;

  const _AddExamDialog({super.key, this.exam});

  @override
  State<_AddExamDialog> createState() => _AddExamDialogState();
}

class _AddExamDialogState extends State<_AddExamDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedSubjectId;
  String? _selectedGroupId;
  DateTime _examDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _examTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    if (widget.exam != null) {
      _titleController.text = widget.exam!.title;
      _descriptionController.text = widget.exam!.description ?? '';
      _locationController.text = widget.exam!.location ?? '';
      _selectedSubjectId = widget.exam!.subjectId;
      _examDate = widget.exam!.examDate;
      _examTime = TimeOfDay.fromDateTime(widget.exam!.examDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.exam == null ? 'Add Exam' : 'Edit Exam',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Exam Title',
                        labelStyle:
                            TextStyle(color: Colors.grey.withOpacity(0.8)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.1),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an exam title';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Syllabus Group selector
                    ValueListenableBuilder(
                      valueListenable:
                          Hive.box<SyllabusGroup>('syllabus_groups')
                              .listenable(),
                      builder: (context, Box<SyllabusGroup> box, _) {
                        final syllabusGroups = box.values.toList();

                        return Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: _selectedGroupId,
                              style: const TextStyle(color: Colors.white),
                              dropdownColor: const Color(0xFF0A0A0A),
                              decoration: InputDecoration(
                                labelText: 'Syllabus Group',
                                labelStyle: TextStyle(
                                    color: Colors.grey.withOpacity(0.8)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Colors.grey.withOpacity(0.3)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Colors.grey.withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                                filled: true,
                                fillColor: Colors.grey.withOpacity(0.1),
                              ),
                              items: syllabusGroups.map((group) {
                                return DropdownMenuItem(
                                  value: group.id,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: Color(int.parse(group.color
                                              .replaceFirst('#', '0xFF'))),
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
                                setState(() {
                                  _selectedGroupId = value;
                                  _selectedSubjectId =
                                      null; // Reset subject selection
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a syllabus group';
                                }
                                return null;
                              },
                            ),
                            if (_selectedGroupId != null) ...[
                              const SizedBox(height: 16),
                              Builder(
                                builder: (context) {
                                  final selectedGroup =
                                      syllabusGroups.firstWhere(
                                          (g) => g.id == _selectedGroupId);
                                  return DropdownButtonFormField<String>(
                                    value: _selectedSubjectId,
                                    style: const TextStyle(color: Colors.white),
                                    dropdownColor: const Color(0xFF0A0A0A),
                                    decoration: InputDecoration(
                                      labelText: 'Subject',
                                      labelStyle: TextStyle(
                                          color: Colors.grey.withOpacity(0.8)),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color:
                                                Colors.grey.withOpacity(0.3)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color:
                                                Colors.grey.withOpacity(0.3)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.withOpacity(0.1),
                                    ),
                                    items:
                                        selectedGroup.subjects.map((subject) {
                                      return DropdownMenuItem(
                                        value: subject.id,
                                        child: Text(subject.name),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedSubjectId = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Please select a subject';
                                      }
                                      return null;
                                    },
                                  );
                                },
                              ),
                            ],
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle:
                            TextStyle(color: Colors.grey.withOpacity(0.8)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.1),
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _locationController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Location',
                        labelStyle:
                            TextStyle(color: Colors.grey.withOpacity(0.8)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.1),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Date picker
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Exam Date',
                          labelStyle:
                              TextStyle(color: Colors.grey.withOpacity(0.8)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.grey.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.grey.withOpacity(0.3)),
                          ),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.1),
                        ),
                        child: Text(
                          DateFormat('MMM dd, yyyy').format(_examDate),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Time picker
                    InkWell(
                      onTap: _selectTime,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Exam Time',
                          labelStyle:
                              TextStyle(color: Colors.grey.withOpacity(0.8)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.grey.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.grey.withOpacity(0.3)),
                          ),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.1),
                        ),
                        child: Text(
                          _examTime.format(context),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey.withOpacity(0.8)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveExam,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(widget.exam == null ? 'Add' : 'Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _examDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _examDate = date;
      });
    }
  }

  void _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _examTime,
    );
    if (time != null) {
      setState(() {
        _examTime = time;
      });
    }
  }

  void _saveExam() {
    if (!_formKey.currentState!.validate()) return;

    final examDateTime = DateTime(
      _examDate.year,
      _examDate.month,
      _examDate.day,
      _examTime.hour,
      _examTime.minute,
    );

    if (widget.exam == null) {
      final exam = Exam(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        subjectId: _selectedSubjectId!,
        examDate: examDateTime,
        createdAt: DateTime.now(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
      );

      final box = Hive.box<Exam>('exams');
      box.put(exam.id, exam);
    } else {
      widget.exam!.title = _titleController.text.trim();
      widget.exam!.subjectId = _selectedSubjectId!;
      widget.exam!.examDate = examDateTime;
      widget.exam!.description = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim();
      widget.exam!.location = _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim();
      widget.exam!.save();
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
