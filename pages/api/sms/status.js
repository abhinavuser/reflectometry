// pages/api/sms/status.js
// SMS Service Status API

import smsService from '../../../lib/sms-service.js';

export default async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ message: 'Method not allowed' });
  }

  try {
    const status = smsService.getStatus();
    
    res.status(200).json({
      success: true,
      timestamp: new Date().toISOString(),
      smsService: status,
      configuration: {
        recipientsConfigured: status.recipients > 0,
        twilioConfigured: status.twilioConfigured,
        serviceAvailable: status.available
      }
    });

  } catch (error) {
    console.error('SMS Status API Error:', error);
    res.status(500).json({
      success: false,
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
}

