import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/study_session.dart';
import 'models/subject.dart';
import 'models/goal.dart';
import 'models/exam.dart';
import 'models/user_stats.dart';
import 'models/achievement.dart';
import 'models/syllabus_group.dart';
import 'models/xp_transaction.dart';
import 'models/daily_study_report.dart';
import 'screens/splash_screen.dart';
import 'services/data_service.dart';
import 'services/app_lifecycle_manager.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(StudySessionAdapter());
  Hive.registerAdapter(SubjectAdapter());
  Hive.registerAdapter(GoalAdapter());
  Hive.registerAdapter(ExamAdapter());
  Hive.registerAdapter(UserStatsAdapter());
  Hive.registerAdapter(AchievementAdapter());
  Hive.registerAdapter(SyllabusGroupAdapter());
  Hive.registerAdapter(SyllabusSubjectAdapter());
  Hive.registerAdapter(SyllabusChapterAdapter());
  Hive.registerAdapter(XPTransactionAdapter());
  Hive.registerAdapter(DailyStudyReportAdapter());
  Hive.registerAdapter(SubjectStudyDataAdapter());
  Hive.registerAdapter(StudySessionDataAdapter());

  // Open Hive boxes
  await Hive.openBox<StudySession>('study_sessions');
  await Hive.openBox<Subject>('subjects');
  await Hive.openBox<Goal>('goals');
  await Hive.openBox<Exam>('exams');
  await Hive.openBox<UserStats>('user_stats');
  await Hive.openBox<Achievement>('achievements');
  await Hive.openBox<SyllabusGroup>('syllabus_groups');
  await Hive.openBox<XPTransaction>('xp_transactions');
  await Hive.openBox<DailyStudyReport>('daily_reports');
  await Hive.openBox('settings');

  // Initialize default achievements
  await DataService.initializeDefaultAchievements();

  // Initialize app lifecycle manager
  AppLifecycleManager().initialize();

  runApp(const ProviderScope(child: StudifyApp()));
}

class StudifyApp extends ConsumerWidget {
  const StudifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Studify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
