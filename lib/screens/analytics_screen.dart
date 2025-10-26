import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/study_session.dart';
import '../models/subject.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        title: const Text('Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'Subjects'),
          ],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<StudySession>('study_sessions').listenable(),
        builder: (context, Box<StudySession> box, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _DailyAnalytics(sessions: box.values.toList()),
              _WeeklyAnalytics(sessions: box.values.toList()),
              _SubjectAnalytics(sessions: box.values.toList()),
            ],
          );
        },
      ),
    );
  }
}

class _DailyAnalytics extends StatelessWidget {
  final List<StudySession> sessions;

  const _DailyAnalytics({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final dailyData = _getDailyData();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last 7 Days',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Daily chart
          SizedBox(
            height: 200,
            child: dailyData.isEmpty
                ? Center(
                    child: Text(
                      'No data available',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: dailyData.values.isNotEmpty
                          ? dailyData.values.reduce((a, b) => a > b ? a : b) *
                              1.2
                          : 100,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              final date = DateTime.now()
                                  .subtract(Duration(days: 6 - value.toInt()));
                              return Text(
                                DateFormat('E').format(date),
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return Text(
                                '${value.toInt()}m',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: dailyData.entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value,
                              color: Theme.of(context).colorScheme.primary,
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),

          const SizedBox(height: 24),

          // Daily stats
          _buildStatsCards(),
        ],
      ),
    );
  }

  Map<int, double> _getDailyData() {
    final Map<int, double> data = {};
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayMinutes = sessions
          .where((session) =>
              session.startTime.isAfter(dayStart) &&
              session.startTime.isBefore(dayEnd))
          .fold(0.0, (sum, session) => sum + session.duration);

      data[i] = dayMinutes;
    }

    return data;
  }

  Widget _buildStatsCards() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final todaySessions = sessions
        .where((session) =>
            session.startTime.isAfter(todayStart) &&
            session.startTime.isBefore(todayEnd))
        .toList();

    final todayMinutes =
        todaySessions.fold(0, (sum, session) => sum + session.duration);
    final todayPomodoros =
        todaySessions.where((s) => s.type == 'pomodoro').length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Today',
            value: '${todayMinutes}m',
            subtitle: '${todaySessions.length} sessions',
            icon: Icons.today,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Pomodoros',
            value: '$todayPomodoros',
            subtitle: 'completed today',
            icon: Icons.timer,
          ),
        ),
      ],
    );
  }
}

class _WeeklyAnalytics extends StatelessWidget {
  final List<StudySession> sessions;

  const _WeeklyAnalytics({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final weeklyData = _getWeeklyData();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last 4 Weeks',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: weeklyData.isEmpty
                ? Center(
                    child: Text(
                      'No data available',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return Text(
                                'W${value.toInt() + 1}',
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return Text(
                                '${(value / 60).toStringAsFixed(0)}h',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: weeklyData.entries.map((entry) {
                            return FlSpot(entry.key.toDouble(), entry.value);
                          }).toList(),
                          isCurved: true,
                          color: Theme.of(context).colorScheme.primary,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Map<int, double> _getWeeklyData() {
    final Map<int, double> data = {};
    final now = DateTime.now();

    for (int i = 0; i < 4; i++) {
      final weekStart =
          now.subtract(Duration(days: (3 - i) * 7 + now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 7));

      final weekMinutes = sessions
          .where((session) =>
              session.startTime.isAfter(weekStart) &&
              session.startTime.isBefore(weekEnd))
          .fold(0.0, (sum, session) => sum + session.duration);

      data[i] = weekMinutes;
    }

    return data;
  }
}

class _SubjectAnalytics extends StatelessWidget {
  final List<StudySession> sessions;

  const _SubjectAnalytics({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final subjectData = _getSubjectData();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Study Time by Subject',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          if (subjectData.isEmpty)
            Center(
              child: Text(
                'No data available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            )
          else ...[
            // Pie chart
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: subjectData.entries.map((entry) {
                    final subject = entry.key;
                    final minutes = entry.value;
                    final percentage = minutes /
                        subjectData.values.fold(0.0, (a, b) => a + b) *
                        100;

                    return PieChartSectionData(
                      color: subject.color,
                      value: minutes,
                      title: '${percentage.toStringAsFixed(1)}%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Subject list
            ...subjectData.entries.map((entry) {
              final subject = entry.key;
              final minutes = entry.value;
              final hours = minutes / 60;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: subject.color,
                    child: Text(
                      subject.name.isNotEmpty
                          ? subject.name[0].toUpperCase()
                          : 'S',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(subject.name),
                  trailing: Text(
                    '${hours.toStringAsFixed(1)}h',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Map<Subject, double> _getSubjectData() {
    final Map<Subject, double> data = {};
    final subjectsBox = Hive.box<Subject>('subjects');

    for (final session in sessions) {
      final subject = subjectsBox.get(session.subjectId);
      if (subject != null) {
        data[subject] = (data[subject] ?? 0) + session.duration;
      }
    }

    return data;
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
