// lib/services/native_sms_service.dart
// Native SMS Service for Flutter Electric Fence App

import 'package:url_launcher/url_launcher.dart';

class NativeSMSService {
  // Default phone numbers for alerts
  static const List<String> _defaultRecipients = [
    '+919003287691',
    '+916380541751',
  ];

  /// Check if SMS permission is granted (not needed for url_launcher)
  static Future<bool> hasSMSPermission() async {
    // url_launcher doesn't require SMS permissions
    return true;
  }

  /// Request SMS permission (not needed for url_launcher)
  static Future<bool> requestSMSPermission() async {
    // url_launcher doesn't require SMS permissions
    return true;
  }

  /// Send SMS to a single number
  static Future<bool> sendSMS({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // Clean phone number (remove spaces, dashes, etc.)
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Create SMS URL with different schemes for better compatibility
      final smsUri = Uri.parse(
        'sms:$cleanNumber?body=${Uri.encodeComponent(message)}',
      );

      print('Attempting to launch SMS for: $cleanNumber');
      print('Message: $message');

      // Launch SMS app
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri, mode: LaunchMode.externalApplication);
        print('SMS app launched successfully for $cleanNumber');
        return true;
      } else {
        // Try alternative SMS scheme
        final altSmsUri = Uri.parse('smsto:$cleanNumber');
        if (await canLaunchUrl(altSmsUri)) {
          await launchUrl(altSmsUri, mode: LaunchMode.externalApplication);
          print('SMS app launched with alternative scheme for $cleanNumber');
          return true;
        } else {
          print('Cannot launch SMS app with any scheme');
          return false;
        }
      }
    } catch (e) {
      print('Error launching SMS: $e');
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
      'serviceType': 'native_sms_app',
      'message': 'Native SMS service ready - Opens device SMS app',
    };
  }

  /// Check if SMS service is available
  static Future<bool> isSMSAvailable() async {
    return await hasSMSPermission();
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
