import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../widgets/backup_settings_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settingsBox = Hive.box('settings');

  bool _notificationsEnabled = true;
  bool _streakReminders = true;
  bool _examReminders = true;
  bool _achievementNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _notificationsEnabled =
          _settingsBox.get('notifications_enabled', defaultValue: true);
      _streakReminders =
          _settingsBox.get('streak_reminders', defaultValue: true);
      _examReminders = _settingsBox.get('exam_reminders', defaultValue: true);
      _achievementNotifications =
          _settingsBox.get('achievement_notifications', defaultValue: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notifications section
          const _SectionHeader(title: 'Notifications'),
          _SettingsTile(
            title: 'Enable Notifications',
            subtitle: 'Receive study reminders and updates',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _settingsBox.put('notifications_enabled', value);
              },
            ),
          ),

          _SettingsTile(
            title: 'Streak Reminders',
            subtitle: 'Daily reminders to maintain your streak',
            trailing: Switch(
              value: _streakReminders && _notificationsEnabled,
              onChanged: _notificationsEnabled
                  ? (value) {
                      setState(() {
                        _streakReminders = value;
                      });
                      _settingsBox.put('streak_reminders', value);
                    }
                  : null,
            ),
          ),

          _SettingsTile(
            title: 'Exam Reminders',
            subtitle: 'Notifications for upcoming exams',
            trailing: Switch(
              value: _examReminders && _notificationsEnabled,
              onChanged: _notificationsEnabled
                  ? (value) {
                      setState(() {
                        _examReminders = value;
                      });
                      _settingsBox.put('exam_reminders', value);
                    }
                  : null,
            ),
          ),

          _SettingsTile(
            title: 'Achievement Notifications',
            subtitle: 'Celebrate when you unlock achievements',
            trailing: Switch(
              value: _achievementNotifications && _notificationsEnabled,
              onChanged: _notificationsEnabled
                  ? (value) {
                      setState(() {
                        _achievementNotifications = value;
                      });
                      _settingsBox.put('achievement_notifications', value);
                    }
                  : null,
            ),
          ),

          const SizedBox(height: 24),

          // Backup & Restore section
          const BackupSettingsWidget(),

          const SizedBox(height: 24),

          // About section
          const _SectionHeader(title: 'About'),
          const _SettingsTile(
            title: 'Version',
            subtitle: '1.0.0',
            trailing: Icon(Icons.info_outline),
          ),

          const _SettingsTile(
            title: 'Developer',
            subtitle: 'Made with 💖 by Satyam',
            trailing: Icon(Icons.favorite, color: Colors.red),
          ),

          const _SettingsTile(
            title: 'Privacy Policy',
            subtitle: 'All data is stored locally on your device',
            trailing: Icon(Icons.privacy_tip),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
