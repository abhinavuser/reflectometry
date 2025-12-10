// lib/sms-service.js
// SMS Service for Electric Fence Monitoring Alerts

import twilio from 'twilio';
import { SMS_CONFIG, formatSMSMessage } from './sms-config.js';

class SMSService {
  constructor() {
    this.client = null;
    this.messageHistory = new Map(); // For rate limiting
    this.initializeTwilio();
  }

  initializeTwilio() {
    try {
      if (SMS_CONFIG.twilio.accountSid && SMS_CONFIG.twilio.authToken) {
        this.client = twilio(
          SMS_CONFIG.twilio.accountSid,
          SMS_CONFIG.twilio.authToken
        );
        console.log('✅ Twilio SMS service initialized');
      } else {
        console.warn('⚠️ Twilio credentials not found. SMS service disabled.');
      }
    } catch (error) {
      console.error('❌ Failed to initialize Twilio:', error);
    }
  }

  // Check if SMS service is available
  isAvailable() {
    return this.client !== null && SMS_CONFIG.notifications.recipients.length > 0;
  }

  // Rate limiting check
  isRateLimited(phoneNumber, alertType) {
    const now = Date.now();
    const key = `${phoneNumber}_${alertType}`;
    
    if (!this.messageHistory.has(key)) {
      this.messageHistory.set(key, []);
    }
    
    const messages = this.messageHistory.get(key);
    const oneHourAgo = now - (60 * 60 * 1000);
    const oneDayAgo = now - (24 * 60 * 60 * 1000);
    const cooldownTime = now - (SMS_CONFIG.notifications.rateLimit.cooldownMinutes * 60 * 1000);
    
    // Check cooldown period
    const lastMessage = messages[messages.length - 1];
    if (lastMessage && lastMessage.timestamp > cooldownTime) {
      return true;
    }
    
    // Check hourly limit
    const hourlyMessages = messages.filter(msg => msg.timestamp > oneHourAgo);
    if (hourlyMessages.length >= SMS_CONFIG.notifications.rateLimit.maxMessagesPerHour) {
      return true;
    }
    
    // Check daily limit
    const dailyMessages = messages.filter(msg => msg.timestamp > oneDayAgo);
    if (dailyMessages.length >= SMS_CONFIG.notifications.rateLimit.maxMessagesPerDay) {
      return true;
    }
    
    return false;
  }

  // Record message for rate limiting
  recordMessage(phoneNumber, alertType) {
    const key = `${phoneNumber}_${alertType}`;
    if (!this.messageHistory.has(key)) {
      this.messageHistory.set(key, []);
    }
    
    this.messageHistory.get(key).push({
      timestamp: Date.now(),
      type: alertType
    });
  }

  // Send SMS to a single number
  async sendSMS(phoneNumber, message, alertType = 'general') {
    if (!this.isAvailable()) {
      throw new Error('SMS service not available');
    }

    if (this.isRateLimited(phoneNumber, alertType)) {
      console.log(`⏰ Rate limited: ${phoneNumber} for ${alertType}`);
      return { success: false, reason: 'rate_limited' };
    }

    try {
      const result = await this.client.messages.create({
        body: message,
        from: SMS_CONFIG.twilio.fromNumber,
        to: phoneNumber
      });

      this.recordMessage(phoneNumber, alertType);
      
      console.log(`✅ SMS sent to ${phoneNumber}: ${result.sid}`);
      return { 
        success: true, 
        messageId: result.sid,
        phoneNumber,
        alertType
      };
    } catch (error) {
      console.error(`❌ Failed to send SMS to ${phoneNumber}:`, error);
      return { 
        success: false, 
        error: error.message,
        phoneNumber,
        alertType
      };
    }
  }

  // Send SMS to all configured recipients
  async sendBulkSMS(message, alertType = 'general') {
    if (!this.isAvailable()) {
      throw new Error('SMS service not available');
    }

    const results = [];
    
    for (const phoneNumber of SMS_CONFIG.notifications.recipients) {
      try {
        const result = await this.sendSMS(phoneNumber, message, alertType);
        results.push(result);
        
        // Add small delay between messages to avoid rate limiting
        await new Promise(resolve => setTimeout(resolve, 1000));
      } catch (error) {
        results.push({
          success: false,
          error: error.message,
          phoneNumber,
          alertType
        });
      }
    }

    return results;
  }

  // Send open circuit alert (now treated as illegal fence tapping)
  async sendOpenCircuitAlert(readings, location = 'Unknown Location', coordinates = null) {
    const template = SMS_CONFIG.notifications.templates.openCircuit;
    const data = {
      location,
      coordinates: coordinates || 'Coordinates not available',
      timestamp: new Date().toLocaleString()
    };

    const message = formatSMSMessage(template, data);
    return await this.sendBulkSMS(message, 'openCircuit');
  }

  // Send illegal fence alert
  async sendIllegalFenceAlert(readings, location = 'Unknown Location', coordinates = null) {
    const template = SMS_CONFIG.notifications.templates.illegalFence;
    const data = {
      location,
      coordinates: coordinates || 'Coordinates not available',
      timestamp: new Date().toLocaleString()
    };

    const message = formatSMSMessage(template, data);
    return await this.sendBulkSMS(message, 'illegalFence');
  }

  // Send system error alert
  async sendSystemErrorAlert(error, location = 'System') {
    const template = SMS_CONFIG.notifications.templates.systemError;
    const data = {
      error: error.message || error,
      timestamp: new Date().toLocaleString(),
      location
    };

    const message = formatSMSMessage(template, data);
    return await this.sendBulkSMS(message, 'systemError');
  }

  // Test SMS functionality
  async sendTestSMS(phoneNumber) {
    const testMessage = `🧪 TEST MESSAGE

This is a test SMS from your SAS Electric Fence Monitoring System.

Time: ${new Date().toLocaleString()}
Status: SMS Service Active ✅

If you received this message, your SMS alerts are working correctly.

SAS Electric Fence Monitor`;

    return await this.sendSMS(phoneNumber, testMessage, 'test');
  }

  // Get service status
  getStatus() {
    return {
      available: this.isAvailable(),
      recipients: SMS_CONFIG.notifications.recipients.length,
      twilioConfigured: !!(SMS_CONFIG.twilio.accountSid && SMS_CONFIG.twilio.authToken),
      messageHistory: Array.from(this.messageHistory.entries()).map(([key, messages]) => ({
        key,
        count: messages.length,
        lastMessage: messages[messages.length - 1]?.timestamp
      }))
    };
  }
}

// Create singleton instance
const smsService = new SMSService();

export default smsService;
