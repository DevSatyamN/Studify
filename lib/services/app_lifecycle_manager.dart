import 'package:flutter/material.dart';
import 'backup_service.dart';

class AppLifecycleManager extends WidgetsBindingObserver {
  static final AppLifecycleManager _instance = AppLifecycleManager._internal();
  factory AppLifecycleManager() => _instance;
  AppLifecycleManager._internal();

  final BackupService _backupService = BackupService();
  bool _isInitialized = false;

  /// Initialize the lifecycle manager
  void initialize() {
    if (!_isInitialized) {
      WidgetsBinding.instance.addObserver(this);
      _isInitialized = true;
      print('AppLifecycleManager initialized');
    }
  }

  /// Dispose the lifecycle manager
  void dispose() {
    if (_isInitialized) {
      WidgetsBinding.instance.removeObserver(this);
      _isInitialized = false;
      print('AppLifecycleManager disposed');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        print('App resumed');
        _onAppResumed();
        break;
      case AppLifecycleState.inactive:
        print('App inactive');
        break;
      case AppLifecycleState.paused:
        print('App paused');
        _onAppPaused();
        break;
      case AppLifecycleState.detached:
        print('App detached');
        _onAppDetached();
        break;
      case AppLifecycleState.hidden:
        print('App hidden');
        break;
    }
  }

  /// Called when app is resumed
  void _onAppResumed() {
    // You can add logic here if needed when app resumes
  }

  /// Called when app is paused (going to background)
  void _onAppPaused() {
    _createAutoBackup();
  }

  /// Called when app is detached (closing)
  void _onAppDetached() {
    _createAutoBackup();
  }

  /// Create automatic backup
  void _createAutoBackup() {
    _backupService.createAutoBackup().then((success) {
      if (success) {
        print('Auto backup created successfully');
      } else {
        print('Auto backup failed or disabled');
      }
    }).catchError((error) {
      print('Auto backup error: $error');
    });
  }

  /// Trigger backup after study session completion
  Future<void> onStudySessionCompleted() async {
    try {
      final success = await _backupService.createAutoBackup();
      if (success) {
        print('Auto backup created after study session');
      }
    } catch (e) {
      print('Failed to create backup after study session: $e');
    }
  }

  /// Trigger backup after important data changes
  Future<void> onDataChanged() async {
    try {
      // Add a small delay to avoid too frequent backups
      await Future.delayed(const Duration(seconds: 2));
      final success = await _backupService.createAutoBackup();
      if (success) {
        print('Auto backup created after data change');
      }
    } catch (e) {
      print('Failed to create backup after data change: $e');
    }
  }
}
