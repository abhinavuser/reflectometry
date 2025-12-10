// lib/services/sms_service.dart
// SMS Service for Flutter Electric Fence App

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'notification_service.dart';

class SMSService {
  // Twilio Configuration - Your actual credentials
  static const String _accountSid = 'AC00d304eb1eae6e35b9a92dfaaa56b10c';
  static const String _authToken = '9d18aacec3a43260c1c26b1162b5a458';
  static const String _twilioPhoneNumber = '+16084133051';

  // Default phone numbers for alerts
  static const List<String> _defaultRecipients = ['+919003287671'];

  // Twilio API base URL
  static const String _baseUrl = 'https://api.twilio.com/2010-04-01';

  /// Send SMS alert for illegal fence tapping detection
  static Future<bool> sendIllegalFenceAlert({
    required String location,
    required String coordinates,
    String? customMessage,
  }) async {
    try {
      final message =
          customMessage ?? _buildIllegalFenceMessage(location, coordinates);
      return await _sendBulkSMS(message);
    } catch (e) {
      print('SMS Error: $e');
      return false;
    }
  }

  /// Send SMS via Twilio API directly
  static Future<bool> _sendSMS({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // Clean phone number
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      print('Sending SMS via Twilio to: $cleanNumber');
      print('Message: $message');
      print('From: $_twilioPhoneNumber');
      print('Account SID: $_accountSid');

      // Twilio API endpoint
      final url = '$_baseUrl/Accounts/$_accountSid/Messages.json';

      // Basic authentication
      final credentials = base64Encode(utf8.encode('$_accountSid:$_authToken'));
      print('Auth credentials: Basic $credentials');

      // Request body as form data
      final body = {
        'From': _twilioPhoneNumber,
        'To': cleanNumber,
        'Body': message,
      };

      print('Request body: $body');

      // Send HTTP POST request
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Basic $credentials',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      print('Twilio API Response Status: ${response.statusCode}');
      print('Twilio API Response Headers: ${response.headers}');
      print('Twilio API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('✅ SMS sent successfully. SID: ${responseData['sid']}');

        // Add notification for successful SMS
        await NotificationService.addSMSSentNotification(
          phoneNumber: cleanNumber,
          message: message,
          success: true,
        );

        return true;
      } else {
        print('❌ Failed to send SMS. Status: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');

        // Add notification for failed SMS
        await NotificationService.addSMSSentNotification(
          phoneNumber: cleanNumber,
          message: 'Status: ${response.statusCode} - ${response.body}',
          success: false,
        );

        return false;
      }
    } catch (e) {
      print('❌ Error sending SMS via Twilio: $e');
      return false;
    }
  }

  /// Send SMS to multiple recipients
  static Future<bool> _sendBulkSMS(String message) async {
    bool allSuccessful = true;

    for (final phoneNumber in _defaultRecipients) {
      try {
        final success = await _sendSMS(
          phoneNumber: phoneNumber,
          message: message,
        );

        if (!success) {
          allSuccessful = false;
        }

        // Add small delay between messages to avoid rate limiting
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        print('Error sending SMS to $phoneNumber: $e');
        allSuccessful = false;
      }
    }

    return allSuccessful;
  }

  /// Send test SMS
  static Future<bool> sendTestSMS() async {
    try {
      print('🧪 Starting test SMS...');

      // First test connection
      final isConnected = await isSMSAvailable();
      print('Connection test: $isConnected');

      if (!isConnected) {
        print('❌ Twilio connection failed');
        return false;
      }

      final message = _buildTestMessage();
      print('Test message: $message');

      return await _sendBulkSMS(message);
    } catch (e) {
      print('Test SMS Error: $e');
      return false;
    }
  }

  /// Check if SMS service is available
  static Future<bool> isSMSAvailable() async {
    try {
      // Test Twilio API connectivity
      final url = '$_baseUrl/Accounts/$_accountSid.json';
      final credentials = base64Encode(utf8.encode('$_accountSid:$_authToken'));

      final response = await http
          .get(Uri.parse(url), headers: {'Authorization': 'Basic $credentials'})
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('SMS Service check failed: $e');
      return false;
    }
  }

  /// Get SMS service status
  static Future<Map<String, dynamic>> getSMSStatus() async {
    try {
      final isAvailable = await isSMSAvailable();

      return {
        'success': true,
        'smsService': {
          'available': isAvailable,
          'recipients': _defaultRecipients.length,
          'twilioConfigured': isAvailable,
          'serviceType': 'twilio_direct',
          'accountSid': _accountSid,
          'phoneNumber': _twilioPhoneNumber,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'smsService': {
          'available': false,
          'recipients': 0,
          'twilioConfigured': false,
        },
      };
    }
  }

  /// Build illegal fence alert message
  static String _buildIllegalFenceMessage(String location, String coordinates) {
    return '''ALERT: Open Circuit Detected at $location. Coordinates: $coordinates. Time: ${DateTime.now().toLocal().toString().split('.')[0]}. Immediate inspection required.''';
  }

  /// Build test message
  static String _buildTestMessage() {
    return '''Test SMS from Flutter App - ${DateTime.now().toLocal().toString().split('.')[0]}''';
  }

  /// Check message delivery status
  static Future<Map<String, dynamic>> checkMessageStatus(
    String messageSid,
  ) async {
    try {
      final url = '$_baseUrl/Accounts/$_accountSid/Messages/$messageSid.json';
      final credentials = base64Encode(utf8.encode('$_accountSid:$_authToken'));

      final response = await http
          .get(Uri.parse(url), headers: {'Authorization': 'Basic $credentials'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'status': data['status'],
          'dateSent': data['date_sent'],
          'errorCode': data['error_code'],
          'errorMessage': data['error_message'],
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to check status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
