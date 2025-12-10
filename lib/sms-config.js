// lib/sms-config.js
// SMS Service Configuration for Electric Fence Monitoring

export const SMS_CONFIG = {
  // Twilio Configuration
  twilio: {
    accountSid: process.env.TWILIO_ACCOUNT_SID,
    authToken: process.env.TWILIO_AUTH_TOKEN,
    fromNumber: process.env.TWILIO_PHONE_NUMBER, // Your Twilio phone number
  },
  
  // Notification Settings
  notifications: {
    // Phone numbers to receive SMS alerts
    recipients: [
      process.env.ALERT_PHONE_NUMBER_1, // Primary contact
      process.env.ALERT_PHONE_NUMBER_2, // Secondary contact (optional)
    ].filter(Boolean), // Remove undefined values
    
    // SMS Templates
    templates: {
      openCircuit: {
        subject: "🚨 ILLEGAL FENCE TAPPING DETECTED",
        message: `🚨 ILLEGAL FENCE TAPPING DETECTED

Location: {location}
Coordinates: {coordinates}
Time: {timestamp}

Immediate inspection required.

SAS Electric Fence Monitor`
      },
      
      illegalFence: {
        subject: "🚨 ILLEGAL FENCE TAPPING DETECTED",
        message: `🚨 ILLEGAL FENCE TAPPING DETECTED

Location: {location}
Coordinates: {coordinates}
Time: {timestamp}

Immediate inspection required.

SAS Electric Fence Monitor`
      },
      
      systemError: {
        subject: "🔧 SYSTEM ERROR",
        message: `🔧 SYSTEM ALERT: Monitoring System Error
        
Error: {error}
Time: {timestamp}
Location: {location}

System requires immediate attention.

SAS Electric Fence Monitor`
      }
    },
    
    // Rate limiting to prevent spam
    rateLimit: {
      maxMessagesPerHour: 10,
      maxMessagesPerDay: 50,
      cooldownMinutes: 5 // Minimum time between same type alerts
    }
  },
  
  // Open Circuit Detection Thresholds
  openCircuitThresholds: {
    impedance: {
      min: 1000, // Ω - Very high impedance indicates open circuit
      max: 10000 // Ω - Upper limit for open circuit detection
    },
    voltage: {
      min: 0, // V - No voltage indicates open circuit
      max: 50 // V - Very low voltage threshold
    },
    current: {
      min: 0, // A - No current indicates open circuit
      max: 0.1 // A - Very low current threshold
    },
    reflectionCoeff: {
      min: 0.8, // High reflection coefficient indicates open circuit
      max: 1.0
    }
  }
};

// Helper function to check if readings indicate open circuit
export function isOpenCircuit(readings) {
  const { impedance, voltage, current, reflectionCoeff } = readings;
  const thresholds = SMS_CONFIG.openCircuitThresholds;
  
  return (
    (impedance >= thresholds.impedance.min && impedance <= thresholds.impedance.max) ||
    (voltage >= thresholds.voltage.min && voltage <= thresholds.voltage.max) ||
    (current >= thresholds.current.min && current <= thresholds.current.max) ||
    (reflectionCoeff >= thresholds.reflectionCoeff.min && reflectionCoeff <= thresholds.reflectionCoeff.max)
  );
}

// Helper function to format SMS message
export function formatSMSMessage(template, data) {
  let message = template.message;
  
  // Replace placeholders with actual data
  Object.keys(data).forEach(key => {
    const placeholder = `{${key}}`;
    message = message.replace(new RegExp(placeholder, 'g'), data[key]);
  });
  
  return message;
}

export default SMS_CONFIG;
