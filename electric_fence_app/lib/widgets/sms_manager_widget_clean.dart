// lib/widgets/sms_manager_widget.dart
// SMS Manager Widget for Flutter App

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/simple_sms_service.dart';

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
      // Check simple SMS service status
      final status = await SimpleSMSService.getStatus();
      setState(() {
        _smsStatus = status;
        _smsAvailable = status['available'] == true;
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
      final results = await SimpleSMSService.sendTestSMS();
      final successful = results.where((r) => r['success'] == true).length;
      final total = results.length;

      if (successful > 0) {
        _showSuccessDialog(
          'Test SMS sent to $successful out of $total recipients!',
        );
      } else {
        // Show fallback dialog with message content
        _showMessageDialog(
          'SMS Send Failed',
          'Could not send SMS directly. Here is the message content to copy and send manually:',
          SimpleSMSService.getTestMessage(),
        );
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
      final results = await SimpleSMSService.sendIllegalFenceAlert(
        location: 'Test Location - Sector 1',
        coordinates: '10.850516, 76.271083',
      );

      final successful = results.where((r) => r['success'] == true).length;
      final total = results.length;

      if (successful > 0) {
        _showSuccessDialog(
          'Illegal fence alert sent to $successful out of $total recipients!',
        );
      } else {
        // Show fallback dialog with message content
        _showMessageDialog(
          'SMS Send Failed',
          'Could not send SMS directly. Here is the alert message to copy and send manually:',
          SimpleSMSService.getIllegalFenceMessage(
            'Test Location - Sector 1',
            '10.850516, 76.271083',
          ),
        );
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

  Future<void> _requestSMSPermission() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final granted = await SimpleSMSService.requestSMSPermission();
      if (granted) {
        _showSuccessDialog(
          'SMS permission granted! You can now send SMS alerts directly.',
        );
        _checkSMSStatus(); // Refresh status
      } else {
        setState(() {
          _error = 'SMS permission denied. Please enable it in device settings.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to request SMS permission: $e';
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
      builder: (context) => AlertDialog(
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

  void _showMessageDialog(String title, String description, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(LucideIcons.messageSquare, color: Colors.blue),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                message,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap and hold to select all text, then copy and paste into your SMS app.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDebugInfo() {
    final status = _smsStatus;
    final debugInfo = '''
SMS Service Debug Information:

Status: ${status['available'] ? 'Available' : 'Not Available'}
Service Type: ${status['serviceType'] ?? 'Unknown'}
Recipients: ${status['recipients'] ?? 0}
Message: ${status['message'] ?? 'No message'}

Default Recipients:
• +919003287691
• +916380541751

Test Message:
${SimpleSMSService.getTestMessage()}

Note: Direct SMS sending requires SMS permission. If sending fails, message content will be shown for manual copying.
''';

    _showMessageDialog(
      'SMS Debug Information',
      'Here is the current SMS service status and configuration:',
      debugInfo,
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
            GestureDetector(
              onTap: _smsAvailable ? null : _requestSMSPermission,
              child: Container(
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
                            ? 'Simple SMS Service Ready ✅'
                            : 'SMS Service Ready - Tap to test',
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

            const SizedBox(height: 12),

            // Debug Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _smsAvailable && !_isLoading ? _showDebugInfo : null,
                icon: const Icon(LucideIcons.bug),
                label: const Text('Debug SMS Info'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
              ),
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
                  const Text('• Primary Number: +919003287691'),
                  const Text('• Secondary Number: +916380541751'),
                  const Text('• Method: Simple SMS via device app'),
                  const SizedBox(height: 8),
                  const Text(
                    'Note: SMS will be sent via your device\'s SMS app.',
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
          Text('Status: ${_smsAvailable ? "Available" : "Not Available"}'),
          Text('Service Type: ${_smsStatus['serviceType'] ?? 'Unknown'}'),
          Text('Recipients: ${_smsStatus['recipients'] ?? 0}'),
          Text('Message: ${_smsStatus['message'] ?? 'No message'}'),
        ],
      ),
    );
  }
}
