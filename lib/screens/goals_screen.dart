import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/goal.dart';
import '../models/subject.dart';
import '../models/syllabus_group.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildActiveGoals() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Goal>('goals').listenable(),
      builder: (context, Box<Goal> box, _) {
        final activeGoals = box.values
            .where((goal) =>
                !goal.isCompleted && goal.targetDate.isAfter(DateTime.now()))
            .toList()
          ..sort((a, b) => a.targetDate.compareTo(b.targetDate));

        if (activeGoals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No active goals',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Set your first goal to track progress',
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
          itemCount: activeGoals.length,
          itemBuilder: (context, index) {
            final goal = activeGoals[index];
            return _GoalCard(goal: goal, isActive: true);
          },
        );
      },
    );
  }

  Widget _buildCompletedGoals() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Goal>('goals').listenable(),
      builder: (context, Box<Goal> box, _) {
        final completedGoals = box.values
            .where((goal) =>
                goal.isCompleted || goal.targetDate.isBefore(DateTime.now()))
            .toList()
          ..sort((a, b) => b.targetDate.compareTo(a.targetDate));

        if (completedGoals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No completed goals',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete some goals to see them here',
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
          itemCount: completedGoals.length,
          itemBuilder: (context, index) {
            final goal = completedGoals[index];
            return _GoalCard(goal: goal, isActive: false);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active', icon: Icon(Icons.flag)),
            Tab(text: 'Completed', icon: Icon(Icons.check_circle)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveGoals(),
          _buildCompletedGoals(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.orange,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Important Notice',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Once you create a goal, you cannot edit or delete it. If you fail to complete it by the due date, you will lose XP.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (context) => const _AddGoalDialog(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('I Understand'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final bool isActive;

  const _GoalCard({required this.goal, this.isActive = true});

  @override
  Widget build(BuildContext context) {
    final subjectsBox = Hive.box<Subject>('subjects');
    final subject = subjectsBox.get(goal.subjectId);

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
                    color: subject?.color ?? Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    goal.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (goal.isCompleted)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              goal.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),

            const SizedBox(height: 12),

            // Progress bar
            LinearProgressIndicator(
              value: goal.progressPercentage,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                goal.isCompleted
                    ? Colors.green
                    : subject?.color ?? Theme.of(context).colorScheme.primary,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${goal.currentHours}/${goal.targetHours} hours',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  '${(goal.progressPercentage * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Due: ${DateFormat('MMM dd, yyyy').format(goal.targetDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const Spacer(),
                if (!goal.isCompleted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDaysLeftColor(goal.daysLeft, context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${goal.daysLeft} days left',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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

  Color _getDaysLeftColor(int daysLeft, BuildContext context) {
    if (daysLeft <= 3) {
      return Colors.red;
    } else if (daysLeft <= 7) {
      return Colors.orange;
    } else {
      return Theme.of(context).colorScheme.primary;
    }
  }
}

class _AddGoalDialog extends StatefulWidget {
  final Goal? goal;

  const _AddGoalDialog({super.key, this.goal});

  @override
  State<_AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<_AddGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetHoursController = TextEditingController();

  String? _selectedSubjectId;
  String? _selectedGroupId;
  DateTime _targetDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _titleController.text = widget.goal!.title;
      _descriptionController.text = widget.goal!.description;
      _targetHoursController.text = widget.goal!.targetHours.toString();
      _selectedSubjectId = widget.goal!.subjectId;
      _targetDate = widget.goal!.targetDate;
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
                widget.goal == null ? 'Add Goal' : 'Edit Goal',
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
                        labelText: 'Goal Title',
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
                          return 'Please enter a goal title';
                        }
                        return null;
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
                      controller: _targetHoursController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Target Hours',
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
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter target hours';
                        }
                        final hours = int.tryParse(value);
                        if (hours == null || hours <= 0) {
                          return 'Please enter a valid number of hours';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Date picker
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Target Date',
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
                          DateFormat('MMM dd, yyyy').format(_targetDate),
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
                    onPressed: _saveGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(widget.goal == null ? 'Add' : 'Save'),
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
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null) {
      setState(() {
        _targetDate = date;
      });
    }
  }

  void _saveGoal() {
    if (!_formKey.currentState!.validate()) return;

    final goalsBox = Hive.box<Goal>('goals');

    if (widget.goal == null) {
      // Add new goal
      final goal = Goal.create(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        subjectId: _selectedSubjectId!,
        targetDate: _targetDate,
        targetHours: int.parse(_targetHoursController.text),
      );
      goalsBox.put(goal.id, goal);
    } else {
      // Edit existing goal
      widget.goal!.title = _titleController.text.trim();
      widget.goal!.description = _descriptionController.text.trim();
      widget.goal!.subjectId = _selectedSubjectId!;
      widget.goal!.targetDate = _targetDate;
      widget.goal!.targetHours = int.parse(_targetHoursController.text);
      widget.goal!.save();
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetHoursController.dispose();
    super.dispose();
  }
}
