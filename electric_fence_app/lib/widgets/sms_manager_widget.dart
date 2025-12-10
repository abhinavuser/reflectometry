// lib/widgets/sms_manager_widget.dart
// SMS Manager Widget for Flutter App

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/sms_service.dart';

class SMSManagerWidget extends StatefulWidget {
  const SMSManagerWidget({super.key});

  @override
  State<SMSManagerWidget> createState() => _SMSManagerWidgetState();
}

class _SMSManagerWidgetState extends State<SMSManagerWidget> {
  bool _isLoading = false;
  bool _smsAvailable = false;
  Map<String, dynamic> _smsStatus = {};
  String _error = '';

  @override
  void initState() {
    super.initState();
    _checkSMSStatus();
  }

  Future<void> _checkSMSStatus() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final status = await SMSService.getSMSStatus();
      setState(() {
        _smsStatus = status;
        _smsAvailable = status['smsService']?['available'] == true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _sendTestSMS() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final success = await SMSService.sendTestSMS();

      if (success) {
        _showSuccessDialog(
          'Test SMS sent successfully to all configured recipients!',
        );
      } else {
        setState(() {
          _error = 'Failed to send test SMS. Check your Twilio configuration.';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendIllegalFenceTest() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final success = await SMSService.sendIllegalFenceAlert(
        location: 'Test Location - Sector 1',
        coordinates: '10.850516, 76.271083',
      );

      if (success) {
        _showSuccessDialog(
          'Illegal fence alert sent successfully to all configured recipients!',
        );
      } else {
        setState(() {
          _error =
              'Failed to send illegal fence alert. Check your Twilio configuration.';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(LucideIcons.checkCircle, color: Colors.green),
                SizedBox(width: 8),
                Text('Success'),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  LucideIcons.messageSquare,
                  size: 24,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                const Text(
                  'SMS Alert Management',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _checkSMSStatus,
                  icon: const Icon(LucideIcons.refreshCw),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Loading State
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              _buildSMSStatus(),

            const SizedBox(height: 16),

            // Error Display
            if (_error.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.alertTriangle, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            // Connection Status
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color:
                    _smsAvailable
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                border: Border.all(
                  color:
                      _smsAvailable
                          ? Colors.green.shade200
                          : Colors.orange.shade200,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _smsAvailable
                        ? LucideIcons.checkCircle
                        : LucideIcons.wifiOff,
                    color: _smsAvailable ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _smsAvailable
                          ? 'Twilio SMS Service Ready ✅'
                          : 'SMS Service Not Available',
                      style: TextStyle(
                        color:
                            _smsAvailable
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Test Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _smsAvailable && !_isLoading ? _sendTestSMS : null,
                    icon: const Icon(LucideIcons.send),
                    label: const Text('Send Test SMS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _smsAvailable && !_isLoading
                            ? _sendIllegalFenceTest
                            : null,
                    icon: const Icon(LucideIcons.alertTriangle),
                    label: const Text('Test Alert'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Configuration Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SMS Configuration',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Verified Number: +919003287671'),
                  const Text('• Method: Direct Twilio SMS API'),
                  const SizedBox(height: 8),
                  const Text(
                    'Note: SMS will be sent automatically via Twilio to all configured recipients.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
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

  Widget _buildSMSStatus() {
    final smsService = _smsStatus['smsService'] ?? {};
    final available = smsService['available'] ?? false;
    final recipients = smsService['recipients'] ?? 0;
    final twilioConfigured = smsService['twilioConfigured'] ?? false;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SMS Service Status',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Status: ${available ? "Available" : "Not Available"}'),
          Text('Service Type: ${smsService['serviceType'] ?? 'Unknown'}'),
          Text('Recipients: $recipients'),
          Text('Twilio Configured: ${twilioConfigured ? "Yes" : "No"}'),
          if (smsService['accountSid'] != null)
            Text('Account SID: ${smsService['accountSid']}'),
          if (smsService['phoneNumber'] != null)
            Text('Twilio Number: ${smsService['phoneNumber']}'),
        ],
      ),
    );
  }
}
