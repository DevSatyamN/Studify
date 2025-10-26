import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/syllabus_group.dart';
import '../utils/theme.dart';

class SyllabusPomodoroSelector extends StatefulWidget {
  final Function(String groupId, String subjectId, String chapterId)?
      onSelectionChanged;
  final String? selectedGroupId;
  final String? selectedSubjectId;
  final String? selectedChapterId;

  const SyllabusPomodoroSelector({
    super.key,
    this.onSelectionChanged,
    this.selectedGroupId,
    this.selectedSubjectId,
    this.selectedChapterId,
  });

  @override
  State<SyllabusPomodoroSelector> createState() =>
      _SyllabusPomodoroSelectorState();
}

class _SyllabusPomodoroSelectorState extends State<SyllabusPomodoroSelector> {
  String? _selectedGroupId;
  String? _selectedSubjectId;
  String? _selectedChapterId;

  @override
  void initState() {
    super.initState();
    _selectedGroupId = widget.selectedGroupId;
    _selectedSubjectId = widget.selectedSubjectId;
    _selectedChapterId = widget.selectedChapterId;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<SyllabusGroup>('syllabus_groups').listenable(),
      builder: (context, Box<SyllabusGroup> box, _) {
        final groups = box.values.toList();

        if (groups.isEmpty) {
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
                    'No Syllabus Groups',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create a syllabus group to track your study progress',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.school,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Select Study Focus',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Group Selection
                _buildDropdown<String>(
                  label: 'Syllabus Group',
                  value: _selectedGroupId,
                  items: groups.map((group) {
                    return DropdownMenuItem(
                      value: group.id,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Color(int.parse(
                                  group.color.replaceFirst('#', '0xFF'))),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              group.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGroupId = value;
                      _selectedSubjectId = null;
                      _selectedChapterId = null;
                    });
                    _notifySelectionChanged();
                  },
                ),

                const SizedBox(height: 12),

                // Subject Selection
                if (_selectedGroupId != null) ...[
                  _buildSubjectDropdown(groups),
                  const SizedBox(height: 12),
                ],

                // Chapter Selection
                if (_selectedSubjectId != null) ...[
                  _buildChapterDropdown(groups),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: items,
          onChanged: onChanged,
          hint: Text('Select $label'),
        ),
      ],
    );
  }

  Widget _buildSubjectDropdown(List<SyllabusGroup> groups) {
    final selectedGroup = groups.firstWhere((g) => g.id == _selectedGroupId);

    return _buildDropdown<String>(
      label: 'Subject',
      value: _selectedSubjectId,
      items: selectedGroup.subjects.map((subject) {
        return DropdownMenuItem(
          value: subject.id,
          child: Row(
            children: [
              Icon(
                Icons.book,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subject.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${subject.completedChapters.length}/${subject.chapters.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSubjectId = value;
          _selectedChapterId = null;
        });
        _notifySelectionChanged();
      },
    );
  }

  Widget _buildChapterDropdown(List<SyllabusGroup> groups) {
    final selectedGroup = groups.firstWhere((g) => g.id == _selectedGroupId);
    final selectedSubject =
        selectedGroup.subjects.firstWhere((s) => s.id == _selectedSubjectId);

    return _buildDropdown<String>(
      label: 'Chapter',
      value: _selectedChapterId,
      items: selectedSubject.chapters.map((chapter) {
        final isCompleted =
            selectedSubject.completedChapters.contains(chapter.id);

        return DropdownMenuItem(
          value: chapter.id,
          child: Row(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 16,
                color: isCompleted
                    ? AppTheme.studyDayColor
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  chapter.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : null,
                  ),
                ),
              ),
              if (chapter.timeSpent > 0)
                Text(
                  '${(chapter.timeSpent / 60).toStringAsFixed(1)}h',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedChapterId = value;
        });
        _notifySelectionChanged();
      },
    );
  }

  void _notifySelectionChanged() {
    if (_selectedGroupId != null &&
        _selectedSubjectId != null &&
        _selectedChapterId != null) {
      widget.onSelectionChanged?.call(
        _selectedGroupId!,
        _selectedSubjectId!,
        _selectedChapterId!,
      );
    }
  }
}
