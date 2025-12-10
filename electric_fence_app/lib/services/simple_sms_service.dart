// lib/services/simple_sms_service.dart
// Simple SMS Service for Flutter Electric Fence App

import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class SimpleSMSService {
  // Default phone numbers for alerts
  static const List<String> _defaultRecipients = [
    '+919003287691',
    '+916380541751',
  ];

  /// Check if SMS permission is granted
  static Future<bool> hasSMSPermission() async {
    final status = await Permission.sms.status;
    return status.isGranted;
  }

  /// Request SMS permission
  static Future<bool> requestSMSPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  /// Send SMS using multiple methods
  static Future<bool> sendSMS({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // Clean phone number
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      print('Attempting to send SMS to: $cleanNumber');
      print('Message: $message');

      // Try multiple SMS schemes
      final schemes = [
        'sms:$cleanNumber?body=${Uri.encodeComponent(message)}',
        'smsto:$cleanNumber',
        'tel:$cleanNumber',
      ];

      for (final scheme in schemes) {
        try {
          final uri = Uri.parse(scheme);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            print('SMS launched successfully with scheme: $scheme');
            return true;
          }
        } catch (e) {
          print('Failed to launch with scheme $scheme: $e');
          continue;
        }
      }

      print('All SMS schemes failed');
      return false;
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }

  /// Send SMS to multiple recipients
  static Future<List<Map<String, dynamic>>> sendBulkSMS({
    required String message,
    List<String>? recipients,
  }) async {
    final results = <Map<String, dynamic>>[];
    final phoneNumbers = recipients ?? _defaultRecipients;

    for (final phoneNumber in phoneNumbers) {
      try {
        final success = await sendSMS(
          phoneNumber: phoneNumber,
          message: message,
        );

        results.add({
          'phoneNumber': phoneNumber,
          'success': success,
          'error': success ? null : 'Failed to launch SMS app',
        });

        // Add small delay between messages
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        results.add({
          'phoneNumber': phoneNumber,
          'success': false,
          'error': e.toString(),
        });
      }
    }

    return results;
  }

  /// Send illegal fence alert SMS
  static Future<List<Map<String, dynamic>>> sendIllegalFenceAlert({
    required String location,
    required String coordinates,
    String? customMessage,
  }) async {
    final message =
        customMessage ?? _buildIllegalFenceMessage(location, coordinates);
    return await sendBulkSMS(message: message);
  }

  /// Send test SMS
  static Future<List<Map<String, dynamic>>> sendTestSMS() async {
    final message = _buildTestMessage();
    return await sendBulkSMS(message: message);
  }

  /// Send system error alert
  static Future<List<Map<String, dynamic>>> sendSystemErrorAlert({
    required String error,
    String location = 'System',
  }) async {
    final message = _buildSystemErrorMessage(error, location);
    return await sendBulkSMS(message: message);
  }

  /// Build illegal fence alert message
  static String _buildIllegalFenceMessage(String location, String coordinates) {
    return '''🚨 ILLEGAL FENCE TAPPING DETECTED

Location: $location
Coordinates: $coordinates
Time: ${DateTime.now().toLocal().toString().split('.')[0]}

Immediate inspection required.

SAS Electric Fence Monitor''';
  }

  /// Build test message
  static String _buildTestMessage() {
    return '''🧪 TEST MESSAGE

This is a test SMS from your SAS Electric Fence Monitoring System.

Time: ${DateTime.now().toLocal().toString().split('.')[0]}
Status: SMS Service Active ✅

If you received this message, your SMS alerts are working correctly.

SAS Electric Fence Monitor''';
  }

  /// Build system error message
  static String _buildSystemErrorMessage(String error, String location) {
    return '''🔧 SYSTEM ALERT: Monitoring System Error
        
Error: $error
Time: ${DateTime.now().toLocal().toString().split('.')[0]}
Location: $location

System requires immediate attention.

SAS Electric Fence Monitor''';
  }

  /// Get service status
  static Future<Map<String, dynamic>> getStatus() async {
    return {
      'available': true,
      'permissionGranted': true,
      'recipients': _defaultRecipients.length,
      'serviceType': 'simple_sms',
      'message': 'Simple SMS service ready - Opens device SMS app',
    };
  }

  /// Check if SMS service is available
  static Future<bool> isSMSAvailable() async {
    return true; // Always available since we use url_launcher
  }

  /// Get message content for manual copying
  static String getTestMessage() {
    return _buildTestMessage();
  }

  /// Get illegal fence alert message for manual copying
  static String getIllegalFenceMessage(String location, String coordinates) {
    return _buildIllegalFenceMessage(location, coordinates);
  }
}
