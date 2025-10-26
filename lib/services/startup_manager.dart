import 'package:flutter/material.dart';
import 'backup_service.dart';

class StartupManager {
  static final StartupManager _instance = StartupManager._internal();
  factory StartupManager() => _instance;
  StartupManager._internal();

  final BackupService _backupService = BackupService();

  /// Check for auto backup and offer restoration on app startup
  Future<void> checkForAutoBackupOnStartup(BuildContext context) async {
    try {
      // Check if auto backup exists
      final hasAutoBackup = await _backupService.checkForAutoBackup();

      if (!hasAutoBackup) {
        return;
      }

      // Get last backup time to show in dialog
      final lastBackupTime = await _backupService.getLastBackupTime();
      final backupFileSize = await _backupService.getBackupFileSize();

      // Show restoration dialog
      if (context.mounted) {
        _showAutoBackupDialog(context, lastBackupTime, backupFileSize);
      }
    } catch (e) {
      print('Error checking for auto backup on startup: $e');
    }
  }

  void _showAutoBackupDialog(
      BuildContext context, DateTime? lastBackupTime, String backupFileSize) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.backup,
                color: Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Auto Backup Found',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'We found an automatic backup of your data. Would you like to restore it?',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
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
                      const Icon(
                        Icons.schedule,
                        color: Colors.blue,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Last backup: ${_formatBackupTime(lastBackupTime)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.storage,
                        color: Colors.blue,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Size: $backupFileSize',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: Colors.orange.withOpacity(0.8),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will replace your current data',
                      style: TextStyle(
                        color: Colors.orange.withOpacity(0.8),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Skip',
              style: TextStyle(
                color: Colors.grey.withOpacity(0.8),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              await _restoreAutoBackup(context);
            },
            icon: const Icon(Icons.restore, size: 16),
            label: const Text('Restore'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreAutoBackup(BuildContext context) async {
    try {
      final success = await _backupService.restoreFromAutoBackup(context);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Auto backup restored successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Show restart dialog
        _showRestartDialog(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to restore auto backup'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error restoring backup: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRestartDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        title: const Text(
          'Restore Complete',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Your data has been restored successfully. Please restart the app to see all changes.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // You might want to add app restart logic here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatBackupTime(DateTime? backupTime) {
    if (backupTime == null) {
      return 'Unknown';
    }

    final now = DateTime.now();
    final difference = now.difference(backupTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${backupTime.day}/${backupTime.month}/${backupTime.year}';
    }
  }

  /// Initialize startup checks
  Future<void> initialize(BuildContext context) async {
    // Add a small delay to ensure the app is fully loaded
    await Future.delayed(const Duration(milliseconds: 1500));

    if (context.mounted) {
      await checkForAutoBackupOnStartup(context);
    }
  }
}
