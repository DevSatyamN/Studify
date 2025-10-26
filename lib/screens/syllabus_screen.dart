import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/syllabus_group.dart';
import '../utils/theme.dart';

class SyllabusScreen extends StatefulWidget {
  const SyllabusScreen({super.key});

  @override
  State<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends State<SyllabusScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _sortBy = 'recent'; // recent, most_studied, least_studied, pending

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syllabus Groups'),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'recent',
                child: Row(
                  children: [
                    Icon(Icons.access_time),
                    SizedBox(width: 8),
                    Text('Recent'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'most_studied',
                child: Row(
                  children: [
                    Icon(Icons.trending_up),
                    SizedBox(width: 8),
                    Text('Most Studied'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'least_studied',
                child: Row(
                  children: [
                    Icon(Icons.trending_down),
                    SizedBox(width: 8),
                    Text('Least Studied'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'pending',
                child: Row(
                  children: [
                    Icon(Icons.pending_actions),
                    SizedBox(width: 8),
                    Text('Pending Chapters'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSyllabusDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Groups', icon: Icon(Icons.library_books)),
            Tab(text: 'In Progress', icon: Icon(Icons.play_circle)),
            Tab(text: 'Completed', icon: Icon(Icons.check_circle)),
          ],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable:
            Hive.box<SyllabusGroup>('syllabus_groups').listenable(),
        builder: (context, Box<SyllabusGroup> box, _) {
          final syllabusGroups = box.values.toList();

          if (syllabusGroups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No syllabus groups yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first syllabus group',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _showAddSyllabusDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Syllabus Group'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // All Groups
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: syllabusGroups.length,
                itemBuilder: (context, index) {
                  final group = syllabusGroups[index];
                  return _SyllabusGroupCard(group: group);
                },
              ),

              // In Progress (at least 1% progress but not completed)
              Builder(
                builder: (context) {
                  final inProgressGroups = syllabusGroups.where((group) {
                    final progress = group.progressPercentage;
                    return progress > 0.0 && progress < 1.0;
                  }).toList();

                  if (inProgressGroups.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_circle_outline,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No groups in progress',
                              style: TextStyle(fontSize: 18)),
                          SizedBox(height: 8),
                          Text('Start studying to see progress here',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: inProgressGroups.length,
                    itemBuilder: (context, index) {
                      final group = inProgressGroups[index];
                      return _SyllabusGroupCard(group: group);
                    },
                  );
                },
              ),

              // Completed (100% progress)
              Builder(
                builder: (context) {
                  final completedGroups = syllabusGroups.where((group) {
                    return group.progressPercentage >= 1.0;
                  }).toList();

                  if (completedGroups.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No completed groups',
                              style: TextStyle(fontSize: 18)),
                          SizedBox(height: 8),
                          Text('Complete a syllabus group to see it here',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: completedGroups.length,
                    itemBuilder: (context, index) {
                      final group = completedGroups[index];
                      return _SyllabusGroupCard(group: group);
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddSyllabusDialog() {
    showDialog(
      context: context,
      builder: (context) => const _AddSyllabusDialog(),
    );
  }
}

class _SyllabusGroupCard extends StatelessWidget {
  final SyllabusGroup group;

  const _SyllabusGroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final progress = group.progressPercentage;
    final color = Color(int.parse(group.color.replaceFirst('#', '0xFF')));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showTopicsDialog(context),
        borderRadius: BorderRadius.circular(12),
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
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      group.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: group.isCompleted
                          ? AppTheme.studyDayColor.withValues(alpha: 0.1)
                          : color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      group.isCompleted
                          ? 'Complete'
                          : '${group.completedChapters}/${group.totalChapters}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: group.isCompleted
                                ? AppTheme.studyDayColor
                                : color,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditDialog(context);
                      } else if (value == 'delete') {
                        _showDeleteDialog(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                group.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  group.isCompleted ? AppTheme.studyDayColor : color,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.topic_outlined,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    group.nextRecommendedSubject != null
                        ? 'Next: ${group.nextRecommendedSubject!.name}'
                        : 'All subjects completed!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
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

  void _showTopicsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _TopicsDialog(group: group),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _EditSyllabusDialog(group: group),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Syllabus Group'),
        content: Text(
            'Are you sure you want to delete "${group.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final box = Hive.box<SyllabusGroup>('syllabus_groups');
              box.delete(group.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _TopicsDialog extends StatefulWidget {
  final SyllabusGroup group;

  const _TopicsDialog({required this.group});

  @override
  State<_TopicsDialog> createState() => _TopicsDialogState();
}

class _TopicsDialogState extends State<_TopicsDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.group.name),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.group.subjects.length,
          itemBuilder: (context, index) {
            final subject = widget.group.subjects[index];

            return ExpansionTile(
              title: Text(subject.name),
              subtitle: Text(
                  '${subject.completedChapters.length}/${subject.chapters.length} chapters'),
              children: subject.chapters.map((chapter) {
                final isCompleted =
                    subject.completedChapters.contains(chapter.id);
                return CheckboxListTile(
                  title: Text(chapter.name),
                  value: isCompleted,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        subject.markChapterCompleted(chapter.id);
                      } else {
                        subject.markChapterIncomplete(chapter.id);
                      }
                    });
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _AddSyllabusDialog extends StatefulWidget {
  const _AddSyllabusDialog();

  @override
  State<_AddSyllabusDialog> createState() => _AddSyllabusDialogState();
}

class _AddSyllabusDialogState extends State<_AddSyllabusDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedColor = '#1E88E5';
  String _selectedIcon = 'library_books';

  List<SyllabusSubject> subjects = [];

  final List<String> _colors = [
    '#1E88E5',
    '#43A047',
    '#FB8C00',
    '#E53935',
    '#8E24AA',
    '#00ACC1',
    '#FFB300',
    '#5E35B1',
  ];

  final List<Map<String, dynamic>> _icons = [
    {'icon': Icons.library_books, 'name': 'library_books'},
    {'icon': Icons.school, 'name': 'school'},
    {'icon': Icons.science, 'name': 'science'},
    {'icon': Icons.computer, 'name': 'computer'},
    {'icon': Icons.calculate, 'name': 'calculate'},
    {'icon': Icons.language, 'name': 'language'},
    {'icon': Icons.psychology, 'name': 'psychology'},
    {'icon': Icons.business, 'name': 'business'},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Syllabus Group'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                  hintText: 'e.g., CSE 5th Semester, Python Mastery',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Brief description of this group',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Color selection
              Text(
                'Color',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _colors.map((color) {
                  final isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            Color(int.parse(color.replaceFirst('#', '0xFF'))),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Icon selection
              Text(
                'Icon',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _icons.map((iconData) {
                  final isSelected = iconData['name'] == _selectedIcon;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = iconData['name'];
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        iconData['icon'],
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Subjects section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subjects/Courses',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: _addSubject,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Subject'),
                  ),
                ],
              ),

              if (subjects.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'No subjects added yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                )
              else
                ...subjects.asMap().entries.map((entry) {
                  final index = entry.key;
                  final subject = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(subject.name),
                      subtitle: Text('${subject.chapters.length} chapters'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editSubject(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeSubject(index),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: subjects.isNotEmpty ? _saveSyllabusGroup : null,
          child: const Text('Create Group'),
        ),
      ],
    );
  }

  void _addSubject() {
    showDialog(
      context: context,
      builder: (context) => _SubjectDialog(
        onSave: (subject) {
          setState(() {
            subjects.add(subject);
          });
        },
      ),
    );
  }

  void _editSubject(int index) {
    showDialog(
      context: context,
      builder: (context) => _SubjectDialog(
        subject: subjects[index],
        onSave: (subject) {
          setState(() {
            subjects[index] = subject;
          });
        },
      ),
    );
  }

  void _removeSubject(int index) {
    setState(() {
      subjects.removeAt(index);
    });
  }

  void _saveSyllabusGroup() {
    if (_formKey.currentState!.validate()) {
      final syllabusGroup = SyllabusGroup(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        subjects: subjects,
        createdAt: DateTime.now(),
        color: _selectedColor,
        icon: _selectedIcon,
      );

      final box = Hive.box<SyllabusGroup>('syllabus_groups');
      box.put(syllabusGroup.id, syllabusGroup);

      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class _SubjectDialog extends StatefulWidget {
  final SyllabusSubject? subject;
  final Function(SyllabusSubject) onSave;

  const _SubjectDialog({
    this.subject,
    required this.onSave,
  });

  @override
  State<_SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<_SubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<SyllabusChapter> chapters = [];

  @override
  void initState() {
    super.initState();
    if (widget.subject != null) {
      _nameController.text = widget.subject!.name;
      _descriptionController.text = widget.subject!.description;
      chapters = List.from(widget.subject!.chapters);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.subject == null ? 'Add Subject' : 'Edit Subject'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Subject Name',
                  hintText: 'e.g., Data Structures, Machine Learning',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a subject name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Brief description of this subject',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Chapters section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chapters/Topics',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: _addChapter,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Chapter'),
                  ),
                ],
              ),

              if (chapters.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'No chapters added yet',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                )
              else
                ...chapters.asMap().entries.map((entry) {
                  final index = entry.key;
                  final chapter = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 4),
                    child: ListTile(
                      dense: true,
                      title: Text(chapter.name),
                      subtitle: Text('${chapter.topics.length} topics'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () => _editChapter(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18),
                            onPressed: () => _removeChapter(index),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: chapters.isNotEmpty ? _saveSubject : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _addChapter() {
    showDialog(
      context: context,
      builder: (context) => _ChapterDialog(
        onSave: (chapter) {
          setState(() {
            chapters.add(chapter);
          });
        },
      ),
    );
  }

  void _editChapter(int index) {
    showDialog(
      context: context,
      builder: (context) => _ChapterDialog(
        chapter: chapters[index],
        onSave: (chapter) {
          setState(() {
            chapters[index] = chapter;
          });
        },
      ),
    );
  }

  void _removeChapter(int index) {
    setState(() {
      chapters.removeAt(index);
    });
  }

  void _saveSubject() {
    if (_formKey.currentState!.validate()) {
      final subject = SyllabusSubject(
        id: widget.subject?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        chapters: chapters,
        createdAt: widget.subject?.createdAt ?? DateTime.now(),
      );

      widget.onSave(subject);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class _ChapterDialog extends StatefulWidget {
  final SyllabusChapter? chapter;
  final Function(SyllabusChapter) onSave;

  const _ChapterDialog({
    this.chapter,
    required this.onSave,
  });

  @override
  State<_ChapterDialog> createState() => _ChapterDialogState();
}

class _ChapterDialogState extends State<_ChapterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.chapter != null) {
      _nameController.text = widget.chapter!.name;
      _descriptionController.text = widget.chapter!.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.chapter == null ? 'Add Chapter' : 'Edit Chapter'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Chapter Name',
                hintText: 'e.g., Arrays and Strings, Introduction to ML',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a chapter name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Brief description of this chapter',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveChapter,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveChapter() {
    if (_formKey.currentState!.validate()) {
      final chapter = SyllabusChapter(
        id: widget.chapter?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        topics: [_nameController.text], // Use chapter name as single topic
        createdAt: widget.chapter?.createdAt ?? DateTime.now(),
        completedTopics: widget.chapter?.completedTopics ?? [],
        timeSpent: widget.chapter?.timeSpent ?? 0,
        isCompleted: widget.chapter?.isCompleted ?? false,
      );

      widget.onSave(chapter);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class _EditSyllabusDialog extends StatefulWidget {
  final SyllabusGroup group;

  const _EditSyllabusDialog({required this.group});

  @override
  State<_EditSyllabusDialog> createState() => _EditSyllabusDialogState();
}

class _EditSyllabusDialogState extends State<_EditSyllabusDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedColor = '#1E88E5';
  String _selectedIcon = 'library_books';

  List<SyllabusSubject> subjects = [];

  final List<String> _colors = [
    '#1E88E5',
    '#43A047',
    '#FB8C00',
    '#E53935',
    '#8E24AA',
    '#00ACC1',
    '#FFB300',
    '#5E35B1',
  ];

  final List<Map<String, dynamic>> _icons = [
    {'icon': Icons.library_books, 'name': 'library_books'},
    {'icon': Icons.school, 'name': 'school'},
    {'icon': Icons.science, 'name': 'science'},
    {'icon': Icons.computer, 'name': 'computer'},
    {'icon': Icons.calculate, 'name': 'calculate'},
    {'icon': Icons.language, 'name': 'language'},
    {'icon': Icons.psychology, 'name': 'psychology'},
    {'icon': Icons.business, 'name': 'business'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.group.name;
    _descriptionController.text = widget.group.description;
    _selectedColor = widget.group.color;
    _selectedIcon = widget.group.icon;
    subjects = List.from(widget.group.subjects);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Syllabus Group'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                  hintText: 'e.g., CSE 5th Semester, Python Mastery',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Brief description of this group',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Color selection
              Text(
                'Color',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _colors.map((color) {
                  final isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            Color(int.parse(color.replaceFirst('#', '0xFF'))),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Icon selection
              Text(
                'Icon',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _icons.map((iconData) {
                  final isSelected = iconData['name'] == _selectedIcon;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = iconData['name'];
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        iconData['icon'],
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Subjects section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subjects/Courses',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: _addSubject,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Subject'),
                  ),
                ],
              ),

              if (subjects.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'No subjects added yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                )
              else
                ...subjects.asMap().entries.map((entry) {
                  final index = entry.key;
                  final subject = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(subject.name),
                      subtitle: Text('${subject.chapters.length} chapters'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editSubject(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeSubject(index),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: subjects.isNotEmpty ? _saveSyllabusGroup : null,
          child: const Text('Save Changes'),
        ),
      ],
    );
  }

  void _addSubject() {
    showDialog(
      context: context,
      builder: (context) => _SubjectDialog(
        onSave: (subject) {
          setState(() {
            subjects.add(subject);
          });
        },
      ),
    );
  }

  void _editSubject(int index) {
    showDialog(
      context: context,
      builder: (context) => _SubjectDialog(
        subject: subjects[index],
        onSave: (subject) {
          setState(() {
            subjects[index] = subject;
          });
        },
      ),
    );
  }

  void _removeSubject(int index) {
    setState(() {
      subjects.removeAt(index);
    });
  }

  void _saveSyllabusGroup() {
    if (_formKey.currentState!.validate()) {
      final updatedGroup = SyllabusGroup(
        id: widget.group.id,
        name: _nameController.text,
        description: _descriptionController.text,
        subjects: subjects,
        createdAt: widget.group.createdAt,
        color: _selectedColor,
        icon: _selectedIcon,
        priority: widget.group.priority,
        targetDate: widget.group.targetDate,
        totalTimeSpent: widget.group.totalTimeSpent,
      );

      final box = Hive.box<SyllabusGroup>('syllabus_groups');
      box.put(updatedGroup.id, updatedGroup);

      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
