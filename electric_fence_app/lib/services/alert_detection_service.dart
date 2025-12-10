// lib/services/alert_detection_service.dart
// Alert Detection Service for Flutter App

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'sms_service.dart';

class AlertDetectionService {
  static const String _baseUrl = 'http://localhost:3000';
  static Timer? _monitoringTimer;
  static bool _isMonitoring = false;

  // Callback for when alerts are detected
  static Function(String location, String coordinates)? onAlertDetected;

  /// Start monitoring for illegal fence tapping
  static void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _monitoringTimer = Timer.periodic(
      const Duration(seconds: 30), // Check every 30 seconds
      (timer) => _checkForAlerts(),
    );

    print('🚨 Alert monitoring started');
  }

  /// Stop monitoring
  static void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    _isMonitoring = false;

    print('🛑 Alert monitoring stopped');
  }

  /// Check if monitoring is active
  static bool get isMonitoring => _isMonitoring;

  /// Check for alerts from the API
  static Future<void> _checkForAlerts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/sas/realtime-data'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _processAlertData(data);
      }
    } catch (e) {
      print('Alert check error: $e');
    }
  }

  /// Process alert data and send SMS if needed
  static Future<void> _processAlertData(Map<String, dynamic> data) async {
    try {
      // Check for open circuit detection (illegal fence tapping)
      final smsNotifications = data['smsNotifications'];
      if (smsNotifications != null) {
        final openCircuitDetected =
            smsNotifications['openCircuitDetected'] ?? false;
        final smsSent = smsNotifications['smsSent'] ?? false;

        if (openCircuitDetected && !smsSent) {
          // Generate location and coordinates
          final location = 'Sector-${DateTime.now().millisecond % 10 + 1}';
          final coordinates = _generateCoordinates();

          // Send SMS alert
          final success = await SMSService.sendIllegalFenceAlert(
            location: location,
            coordinates: coordinates,
          );

          if (success) {
            print('🚨 SMS alert sent for illegal fence tapping at $location');

            // Notify callback if set
            onAlertDetected?.call(location, coordinates);
          }
        }
      }

      // Check for other alerts
      final alerts = data['alerts'] as List<dynamic>?;
      if (alerts != null) {
        for (final alert in alerts) {
          final alertType = alert['type'] as String?;
          final severity = alert['severity'] as String?;

          if (alertType == 'ILLEGAL_FENCE_DETECTED' && severity == 'CRITICAL') {
            final location = alert['location'] as String? ?? 'Unknown Location';
            final coordinates = _generateCoordinates();

            // Send SMS alert
            final success = await SMSService.sendIllegalFenceAlert(
              location: location,
              coordinates: coordinates,
            );

            if (success) {
              print(
                '🚨 SMS alert sent for illegal fence detection at $location',
              );
              onAlertDetected?.call(location, coordinates);
            }
          }
        }
      }
    } catch (e) {
      print('Alert processing error: $e');
    }
  }

  /// Generate random coordinates (replace with actual GPS coordinates from your hardware)
  static String _generateCoordinates() {
    // Kerala coordinates with some randomness
    final lat = 10.8505 + (DateTime.now().millisecond % 100 - 50) / 1000;
    final lng = 76.2711 + (DateTime.now().millisecond % 100 - 50) / 1000;

    return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
  }

  /// Manually trigger an alert (for testing)
  static Future<bool> triggerTestAlert() async {
    try {
      final location =
          'Test Location - Sector ${DateTime.now().millisecond % 10 + 1}';
      final coordinates = _generateCoordinates();

      final success = await SMSService.sendIllegalFenceAlert(
        location: location,
        coordinates: coordinates,
      );

      if (success) {
        onAlertDetected?.call(location, coordinates);
      }

      return success;
    } catch (e) {
      print('Test alert error: $e');
      return false;
    }
  }

  /// Get current monitoring status
  static Map<String, dynamic> getStatus() {
    return {
      'isMonitoring': _isMonitoring,
      'lastCheck': DateTime.now().toIso8601String(),
      'baseUrl': _baseUrl,
    };
  }
}

