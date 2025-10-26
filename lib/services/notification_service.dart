import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationService {
  static const MethodChannel _channel = MethodChannel('studify/notifications');

  static Future<bool> requestPermission() async {
    try {
      final bool granted = await _channel.invokeMethod('requestPermission');
      return granted;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  static Future<void> showPomodoroNotification({
    required String title,
    required String body,
    required int timeRemaining,
  }) async {
    try {
      await _channel.invokeMethod('showPomodoroNotification', {
        'title': title,
        'body': body,
        'timeRemaining': timeRemaining,
      });
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  static Future<void> cancelNotification() async {
    try {
      await _channel.invokeMethod('cancelNotification');
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }

  static Future<void> showCompletionNotification({
    required String title,
    required String body,
  }) async {
    try {
      await _channel.invokeMethod('showCompletionNotification', {
        'title': title,
        'body': body,
      });
    } catch (e) {
      debugPrint('Error showing completion notification: $e');
    }
  }
}
