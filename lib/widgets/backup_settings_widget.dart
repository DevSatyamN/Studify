import 'package:flutter/material.dart';
import '../services/simple_backup_service.dart';

class BackupSettingsWidget extends StatefulWidget {
  const BackupSettingsWidget({super.key});

  @override
  State<BackupSettingsWidget> createState() => _BackupSettingsWidgetState();
}

class _BackupSettingsWidgetState extends State<BackupSettingsWidget> {
  final SimpleBackupService _backupService = SimpleBackupService();
  bool _isLoading = false;

  Future<void> _createManualBackup() async {
    setState(() => _isLoading = true);
    await _backupService.exportBackup(context);
    setState(() => _isLoading = false);
  }

  Future<void> _importBackup() async {
    setState(() => _isLoading = true);
    final success = await _backupService.importBackup(context);
    setState(() => _isLoading = false);

    if (success) {
      // Show dialog to restart app for changes to take effect
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF0A0A0A),
          title: const Text(
            'Import Successful',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Your data has been imported successfully. Please restart the app to see all changes.',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.backup,
                  color: Colors.blue,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Backup & Restore',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _createManualBackup,
                    icon: const Icon(Icons.download,
                        size: 18, color: Colors.white),
                    label: const Text('Export Backup',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _importBackup,
                    icon:
                        const Icon(Icons.upload, size: 18, color: Colors.white),
                    label: const Text('Import Backup',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Info Text
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Backup Information',
                        style: TextStyle(
                          color: Colors.blue.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Complete backup of ALL your data\n• Includes: Study sessions, goals, subjects, syllabus, achievements, XP, streaks, calendar data\n• Works completely offline without internet\n• Use Share to save backup file anywhere',
                    style: TextStyle(
                      color: Colors.blue.withOpacity(0.8),
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
