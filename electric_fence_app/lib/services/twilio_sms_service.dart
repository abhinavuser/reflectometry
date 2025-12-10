// lib/services/twilio_sms_service.dart
// Twilio SMS Service for Flutter Electric Fence App

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class TwilioSMSService {
  // Twilio Configuration - Replace with your actual credentials
  static const String _accountSid = 'AC00d304eb1eae6e35b9a92dfaaa56b10c';
  static const String _authToken = '9d18aacec3a43260c1c26b1162b5a458';
  static const String _twilioPhoneNumber = '+16084133051';

  // Default phone numbers for alerts
  static const List<String> _defaultRecipients = [
    '+919003287691',
    '+916380541751',
  ];

  // Twilio API base URL
  static const String _baseUrl = 'https://api.twilio.com/2010-04-01';

  /// Send SMS via Twilio API
  static Future<bool> sendSMS({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // Clean phone number
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      print('Sending SMS via Twilio to: $cleanNumber');
      print('Message: $message');

      // Twilio API endpoint
      final url = '$_baseUrl/Accounts/$_accountSid/Messages.json';

      // Basic authentication
      final credentials = base64Encode(utf8.encode('$_accountSid:$_authToken'));

      // Request body
      final body = {
        'From': _twilioPhoneNumber,
        'To': cleanNumber,
        'Body': message,
      };

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
      print('Twilio API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('SMS sent successfully. SID: ${responseData['sid']}');
        return true;
      } else {
        print(
          'Failed to send SMS. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error sending SMS via Twilio: $e');
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
          'error': success ? null : 'Failed to send SMS via Twilio',
        });

        // Add small delay between messages to avoid rate limiting
        await Future.delayed(const Duration(seconds: 1));
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

  /// Send open circuit detection alert
  static Future<List<Map<String, dynamic>>> sendOpenCircuitAlert({
    required Map<String, dynamic> readings,
    required String location,
    required String coordinates,
  }) async {
    final message = _buildOpenCircuitMessage(readings, location, coordinates);
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
Status: Twilio SMS Service Active ✅

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

  /// Build open circuit detection message
  static String _buildOpenCircuitMessage(
    Map<String, dynamic> readings,
    String location,
    String coordinates,
  ) {
    final impedance = readings['impedance'] ?? 'N/A';
    final voltage = readings['voltage'] ?? 'N/A';
    final current = readings['current'] ?? 'N/A';
    final reflectionCoeff = readings['reflectionCoeff'] ?? 'N/A';

    return '''⚡ OPEN CIRCUIT DETECTED

Location: $location
Coordinates: $coordinates
Time: ${DateTime.now().toLocal().toString().split('.')[0]}

Readings:
• Impedance: ${impedance}Ω
• Voltage: ${voltage}V
• Current: ${current}A
• Reflection Coeff: $reflectionCoeff

Possible illegal fence tapping detected.

SAS Electric Fence Monitor''';
  }

  /// Get service status
  static Future<Map<String, dynamic>> getStatus() async {
    try {
      // Test Twilio API connectivity
      final url = '$_baseUrl/Accounts/$_accountSid.json';
      final credentials = base64Encode(utf8.encode('$_accountSid:$_authToken'));

      final response = await http
          .get(Uri.parse(url), headers: {'Authorization': 'Basic $credentials'})
          .timeout(const Duration(seconds: 10));

      final isConnected = response.statusCode == 200;

      return {
        'available': isConnected,
        'permissionGranted': true,
        'recipients': _defaultRecipients.length,
        'serviceType': 'twilio_sms',
        'message':
            isConnected
                ? 'Twilio SMS service ready'
                : 'Twilio API connection failed',
        'twilioConfigured': isConnected,
        'accountSid': _accountSid,
        'phoneNumber': _twilioPhoneNumber,
      };
    } catch (e) {
      return {
        'available': false,
        'permissionGranted': true,
        'recipients': _defaultRecipients.length,
        'serviceType': 'twilio_sms',
        'message': 'Twilio API error: $e',
        'twilioConfigured': false,
        'accountSid': _accountSid,
        'phoneNumber': _twilioPhoneNumber,
      };
    }
  }

  /// Check if SMS service is available
  static Future<bool> isSMSAvailable() async {
    final status = await getStatus();
    return status['available'] == true;
  }

  /// Get message content for manual copying
  static String getTestMessage() {
    return _buildTestMessage();
  }

  /// Get illegal fence alert message for manual copying
  static String getIllegalFenceMessage(String location, String coordinates) {
    return _buildIllegalFenceMessage(location, coordinates);
  }

  /// Get open circuit alert message for manual copying
  static String getOpenCircuitMessage(
    Map<String, dynamic> readings,
    String location,
    String coordinates,
  ) {
    return _buildOpenCircuitMessage(readings, location, coordinates);
  }
}
