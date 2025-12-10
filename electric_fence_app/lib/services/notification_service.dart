// lib/services/notification_service.dart
// Notification Service for Flutter Electric Fence App

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const String _notificationsKey = 'app_notifications';
  static List<Map<String, dynamic>> _notifications = [];

  /// Initialize notification service
  static Future<void> initialize() async {
    await _loadNotifications();
  }

  /// Add a new notification
  static Future<void> addNotification({
    required String title,
    required String message,
    required String type, // 'alert', 'info', 'warning', 'success'
    String? location,
    String? coordinates,
    Map<String, dynamic>? additionalData,
  }) async {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'message': message,
      'type': type,
      'location': location,
      'coordinates': coordinates,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
      'additionalData': additionalData ?? {},
    };

    _notifications.insert(0, notification); // Add to beginning
    await _saveNotifications();
  }

  /// Add open circuit alert notification
  static Future<void> addOpenCircuitAlert({
    required String location,
    required String coordinates,
    String? customMessage,
  }) async {
    final message = customMessage ?? 
        'Open circuit detected at $location. Coordinates: $coordinates. Immediate inspection required.';
    
    await addNotification(
      title: '🚨 Open Circuit Alert',
      message: message,
      type: 'alert',
      location: location,
      coordinates: coordinates,
      additionalData: {
        'alertType': 'open_circuit',
        'severity': 'critical',
        'actionRequired': true,
      },
    );
  }

  /// Add SMS sent notification
  static Future<void> addSMSSentNotification({
    required String phoneNumber,
    required String message,
    required bool success,
  }) async {
    await addNotification(
      title: success ? '✅ SMS Sent Successfully' : '❌ SMS Failed',
      message: success 
          ? 'Alert SMS sent to $phoneNumber'
          : 'Failed to send SMS to $phoneNumber: $message',
      type: success ? 'success' : 'warning',
      additionalData: {
        'phoneNumber': phoneNumber,
        'smsSuccess': success,
      },
    );
  }

  /// Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      await _saveNotifications();
    }
  }

  /// Mark all notifications as read
  static Future<void> markAllAsRead() async {
    for (var notification in _notifications) {
      notification['isRead'] = true;
    }
    await _saveNotifications();
  }

  /// Delete notification
  static Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n['id'] == notificationId);
    await _saveNotifications();
  }

  /// Clear all notifications
  static Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _saveNotifications();
  }

  /// Get all notifications
  static List<Map<String, dynamic>> getAllNotifications() {
    return List.from(_notifications);
  }

  /// Get unread notifications count
  static int getUnreadCount() {
    return _notifications.where((n) => !n['isRead']).length;
  }

  /// Get notifications by type
  static List<Map<String, dynamic>> getNotificationsByType(String type) {
    return _notifications.where((n) => n['type'] == type).toList();
  }

  /// Get recent notifications (last 10)
  static List<Map<String, dynamic>> getRecentNotifications({int limit = 10}) {
    return _notifications.take(limit).toList();
  }

  /// Load notifications from storage
  static Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);
      
      if (notificationsJson != null) {
        final List<dynamic> notificationsList = jsonDecode(notificationsJson);
        _notifications = notificationsList
            .map((n) => Map<String, dynamic>.from(n))
            .toList();
      }
    } catch (e) {
      print('Error loading notifications: $e');
      _notifications = [];
    }
  }

  /// Save notifications to storage
  static Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = jsonEncode(_notifications);
      await prefs.setString(_notificationsKey, notificationsJson);
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }

  /// Get notification icon based on type
  static String getNotificationIcon(String type) {
    switch (type) {
      case 'alert':
        return '🚨';
      case 'warning':
        return '⚠️';
      case 'success':
        return '✅';
      case 'info':
        return 'ℹ️';
      default:
        return '📢';
    }
  }

  /// Get notification color based on type
  static String getNotificationColor(String type) {
    switch (type) {
      case 'alert':
        return 'error';
      case 'warning':
        return 'warning';
      case 'success':
        return 'success';
      case 'info':
        return 'info';
      default:
        return 'primary';
    }
  }
}
