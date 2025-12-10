// pages/api/sms/send-alert.js
// SMS Alert API Endpoint

import smsService from '../../../lib/sms-service.js';
import { isOpenCircuit, SMS_CONFIG } from '../../../lib/sms-config.js';

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Method not allowed' });
  }

  try {
    const { alertType, readings, location, coordinates, testMode } = req.body;

    // Validate required fields
    if (!alertType) {
      return res.status(400).json({ 
        error: 'Missing required field: alertType',
        validTypes: ['openCircuit', 'illegalFence', 'systemError', 'test']
      });
    }

    let results = [];

    switch (alertType) {
      case 'openCircuit':
        if (!readings) {
          return res.status(400).json({ error: 'Missing readings data for openCircuit alert' });
        }
        
        // Check if readings actually indicate open circuit
        if (isOpenCircuit(readings) || testMode) {
          const coords = coordinates || `${(10.8505 + (Math.random() - 0.5) * 0.1).toFixed(6)}, ${(76.2711 + (Math.random() - 0.5) * 0.1).toFixed(6)}`;
          results = await smsService.sendOpenCircuitAlert(readings, location, coords);
        } else {
          return res.status(400).json({ 
            error: 'Readings do not indicate open circuit condition',
            readings,
            thresholds: smsService.SMS_CONFIG?.openCircuitThresholds
          });
        }
        break;

      case 'illegalFence':
        if (!readings) {
          return res.status(400).json({ error: 'Missing readings data for illegalFence alert' });
        }
        const coords = coordinates || `${(10.8505 + (Math.random() - 0.5) * 0.1).toFixed(6)}, ${(76.2711 + (Math.random() - 0.5) * 0.1).toFixed(6)}`;
        results = await smsService.sendIllegalFenceAlert(readings, location, coords);
        break;

      case 'systemError':
        const error = req.body.error || 'Unknown system error';
        results = await smsService.sendSystemErrorAlert(error, location);
        break;

      case 'test':
        const testPhoneNumber = req.body.phoneNumber;
        if (!testPhoneNumber) {
          return res.status(400).json({ error: 'Missing phoneNumber for test SMS' });
        }
        // Send test SMS to the specified number AND all configured recipients
        const testResult = await smsService.sendTestSMS(testPhoneNumber);
        results = [testResult];
        
        // Also send to all configured recipients if they're different from the test number
        const allRecipients = SMS_CONFIG.notifications.recipients;
        for (const recipient of allRecipients) {
          if (recipient !== testPhoneNumber) {
            const recipientResult = await smsService.sendTestSMS(recipient);
            results.push(recipientResult);
          }
        }
        break;

      default:
        return res.status(400).json({ 
          error: 'Invalid alertType',
          validTypes: ['openCircuit', 'illegalFence', 'systemError', 'test']
        });
    }

    // Count successful vs failed messages
    const successful = results.filter(r => r.success).length;
    const failed = results.filter(r => !r.success).length;

    res.status(200).json({
      success: true,
      alertType,
      timestamp: new Date().toISOString(),
      results: {
        total: results.length,
        successful,
        failed,
        details: results
      },
      serviceStatus: smsService.getStatus()
    });

  } catch (error) {
    console.error('SMS Alert API Error:', error);
    res.status(500).json({
      success: false,
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
}
