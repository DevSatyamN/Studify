# BroStud - Gamified Study Tracker

A fully offline Flutter app that gamifies your study sessions with streaks, XP, achievements, and comprehensive analytics.

## 🚀 Features

### 📱 Core Features
- **Study Streak Tracker** - Track consecutive study days with fire streaks
- **Pomodoro Timer** - Customizable work/break durations with XP rewards
- **Goals & Progress** - Create time-based goals and track completion percentage
- **Exam Countdown** - Add exam dates and see days remaining
- **Calendar View** - Visual study session history with detailed session info
- **Subject Management** - Organize studies by subjects with color coding
- **Analytics Dashboard** - Daily, weekly, and subject-wise study analytics

### 🎮 Gamification
- **XP System**: 
  - +10 XP per Pomodoro session
  - +50 XP per chapter completed
  - +100 XP per test aced
- **Leveling System** - Every 500 XP = next level
- **Achievements & Badges** - Early Bird, Night Owl, Consistent Learner, Pomodoro Master, etc.
- **Local Progress Tracking** - All gamification works completely offline

### 🧠 Smart Features
- **Smart Reminders** - Streak maintenance and exam notifications
- **Auto Backup** - Weekly local backups with manual export/import
- **Offline-First** - All features work without internet connection
- **Data Export** - JSON format for manual backup and sharing

### 🎨 UI & Design
- **Material 3 Design** - Modern, clean interface
- **Light/Dark Theme** - Automatic system theme detection
- **Smooth Animations** - XP gains, achievement unlocks, level ups
- **Responsive Layout** - Works on all screen sizes
- **Accessibility** - Full screen reader and navigation support

## 🛠️ Tech Stack

- **Flutter 3+** - Cross-platform mobile framework
- **Riverpod** - State management
- **Hive** - Local NoSQL database
- **fl_chart** - Beautiful charts and analytics
- **table_calendar** - Calendar widget
- **flutter_local_notifications** - Local notifications
- **Material 3** - Modern design system

## 📦 Installation

### Prerequisites
- Flutter SDK 3.10.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extensions

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd brostud
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Building for Release

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📊 Data Structure

### Export Format Example
```json
{
  "version": "1.0.0",
  "exportDate": "2024-01-15T10:30:00.000Z",
  "studySessions": [
    {
      "id": "1642234200000",
      "subjectId": "math_101",
      "startTime": "2024-01-15T09:00:00.000Z",
      "endTime": "2024-01-15T09:25:00.000Z",
      "duration": 25,
      "type": "pomodoro",
      "xpEarned": 10,
      "isCompleted": true
    }
  ],
  "subjects": [
    {
      "id": "math_101",
      "name": "Mathematics",
      "description": "Calculus and Algebra",
      "colorValue": 4280391411,
      "totalStudyTime": 150,
      "totalSessions": 6
    }
  ],
  "userStats": {
    "totalXP": 250,
    "currentLevel": 1,
    "currentStreak": 5,
    "longestStreak": 12,
    "totalStudyTime": 300,
    "totalSessions": 15,
    "pomodoroSessions": 10
  }
}
```

## 🏆 Achievement System

### Available Achievements
- **Getting Started** - Complete your first study session (25 XP)
- **Early Bird** - Study before 8 AM (50 XP)
- **Night Owl** - Study after 10 PM (50 XP)
- **Consistent Learner** - 3-day study streak (75 XP)
- **Week Warrior** - 7-day study streak (150 XP)
- **Pomodoro Master** - Complete 10 Pomodoro sessions (100 XP)
- **Dedicated Student** - Study for 10 hours total (200 XP)
- **Rising Star** - Reach level 5 (250 XP)

## 📱 App Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models with Hive annotations
│   ├── study_session.dart
│   ├── subject.dart
│   ├── goal.dart
│   ├── exam.dart
│   ├── user_stats.dart
│   └── achievement.dart
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── main_screen.dart
│   ├── home_screen.dart
│   ├── pomodoro_screen.dart
│   ├── calendar_screen.dart
│   ├── analytics_screen.dart
│   ├── profile_screen.dart
│   ├── subjects_screen.dart
│   ├── goals_screen.dart
│   ├── exams_screen.dart
│   ├── achievements_screen.dart
│   └── settings_screen.dart
├── widgets/                  # Reusable UI components
│   ├── streak_card.dart
│   ├── level_progress_card.dart
│   ├── quick_stats_card.dart
│   ├── upcoming_exams_card.dart
│   └── active_goals_card.dart
├── services/                 # Business logic services
│   ├── notification_service.dart
│   └── data_service.dart
└── utils/                    # Utilities and themes
    └── theme.dart
```

## 🔧 Configuration

### Notification Settings
The app uses local notifications for:
- Daily streak reminders (8 PM)
- Exam countdown alerts (1, 3, 7 days before)
- Achievement unlock celebrations
- Pomodoro session completions

### Backup Settings
- **Auto Backup**: Weekly automatic local backups
- **Manual Export**: JSON format via share functionality
- **Import**: Restore from exported JSON files

## 🎯 Usage Guide

### Getting Started
1. **Add Subjects** - Create subjects with names, descriptions, and colors
2. **Set Goals** - Define study goals with target hours and deadlines
3. **Schedule Exams** - Add upcoming exams for countdown tracking
4. **Start Studying** - Use Pomodoro timer or regular sessions
5. **Track Progress** - Monitor streaks, XP, and analytics

### Pomodoro Timer
1. Select a subject from the dropdown
2. Customize work/break durations in settings (default: 25/5/15 minutes)
3. Start timer and focus on studying
4. Take breaks when prompted
5. Earn XP and maintain streaks

### Analytics
- **Daily View**: Last 7 days study time with session breakdown
- **Weekly View**: 4-week trend analysis
- **Subject View**: Time distribution across subjects with pie charts

## 🤝 Contributing

This is a personal project, but suggestions and feedback are welcome!

## 📄 License

This project is created for educational purposes. All data is stored locally on your device.

## 💖 Credits

**Made with 💖 by Satyam**

Special thanks to the Flutter community and the amazing packages that made this app possible.

---

*BroStud - Level up your study game! 🚀*