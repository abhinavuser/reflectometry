// pages/api/sas/realtime-data.js
// Real-time data API endpoint

import tdrDataReader from '../../../models/csv_data_reader.js';
import smsService from '../../../lib/sms-service.js';
import { isOpenCircuit } from '../../../lib/sms-config.js';

export default async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ message: 'Method not allowed' });
  }

  // Generate real-time data using CSV TDR measurements
  const generateRealtimeData = async () => {
    const timestamp = new Date().toISOString();
    
    // Get real TDR measurement from CSV
    const tdrMeasurement = tdrDataReader.getNextMeasurement();
    
    if (!tdrMeasurement) {
      // Fallback to simulated data if CSV not available
      return generateSimulatedData();
    }

    // Extract electrical measurements from TDR data
    const measurements = {
      voltage: tdrMeasurement.voltage_rms,
      current: tdrMeasurement.current_rms,
      frequency: 50 + (Math.random() - 0.5) * 0.5, // TDR doesn't measure frequency
      impedance: tdrMeasurement.impedance_magnitude,
      powerFactor: tdrMeasurement.power_factor,
      temperature: 25 + (Math.sin(new Date().getHours() / 12 * Math.PI) * 10) + (Math.random() - 0.5) * 5,
      humidity: 60 + (Math.sin((new Date().getHours() + 6) / 12 * Math.PI) * 20) + (Math.random() - 0.5) * 10
    };

    return {
      timestamp,
      dataSource: 'LIVE_TDR_CSV',
      measurements,
      tdrData: {
        reflection_coeff: tdrMeasurement.reflection_coeff,
        time_delay: tdrMeasurement.time_delay,
        peak_ratio: tdrMeasurement.peak_ratio,
        impedance_magnitude: tdrMeasurement.impedance_magnitude,
        power_factor: tdrMeasurement.power_factor,
        voltage_rms: tdrMeasurement.voltage_rms,
        current_rms: tdrMeasurement.current_rms,
        active_power: tdrMeasurement.active_power,
        energy_ratio: tdrMeasurement.energy_ratio,
        spectral_centroid: tdrMeasurement.spectral_centroid,
        load_classification_score: tdrMeasurement.load_classification_score,
        impedance_ratio: tdrMeasurement.impedance_ratio,
        actualLabel: tdrMeasurement.label // 0 = no fence, 1 = fence (ground truth)
      },
      iec61850: {
        gooseMessages: Math.floor(Math.random() * 100) + 800,
        sampledValues: Math.floor(Math.random() * 50) + 200,
        mmsServices: Math.random() > 0.95 ? 'ERROR' : 'ACTIVE',
        dataObjects: Math.floor(Math.random() * 20) + 840
      },
      alerts: generateAlerts(tdrMeasurement),
      systemHealth: {
        cpu: Math.random() * 30 + 20,
        memory: Math.random() * 40 + 30,
        network: Math.random() > 0.9 ? 'DEGRADED' : 'NORMAL',
        storage: Math.random() * 20 + 60
      },
      datasetStats: tdrDataReader.getDatasetStats(),
      smsNotifications: await checkAndSendSMSAlerts(measurements, tdrMeasurement)
    };
  };

  // Fallback simulated data
  const generateSimulatedData = () => {
    const timestamp = new Date().toISOString();
    const baseVoltage = 230;
    const baseCurrent = 15;
    const baseFrequency = 50;
    
    const timeOfDay = new Date().getHours();
    const loadFactor = Math.sin((timeOfDay / 24) * 2 * Math.PI) * 0.1;
    
    return {
      timestamp,
      dataSource: 'SIMULATED',
      measurements: {
        voltage: baseVoltage + (loadFactor * 20) + (Math.random() - 0.5) * 5,
        current: baseCurrent + (loadFactor * 5) + (Math.random() - 0.5) * 2,
        frequency: baseFrequency + (Math.random() - 0.5) * 0.5,
        impedance: 75 + (Math.random() - 0.5) * 10,
        powerFactor: 0.85 + (Math.random() - 0.5) * 0.1,
        temperature: 25 + (Math.sin(timeOfDay / 12 * Math.PI) * 10) + (Math.random() - 0.5) * 5,
        humidity: 60 + (Math.sin((timeOfDay + 6) / 12 * Math.PI) * 20) + (Math.random() - 0.5) * 10
      },
      iec61850: {
        gooseMessages: Math.floor(Math.random() * 100) + 800,
        sampledValues: Math.floor(Math.random() * 50) + 200,
        mmsServices: Math.random() > 0.95 ? 'ERROR' : 'ACTIVE',
        dataObjects: Math.floor(Math.random() * 20) + 840
      },
      alerts: generateAlerts(),
      systemHealth: {
        cpu: Math.random() * 30 + 20,
        memory: Math.random() * 40 + 30,
        network: Math.random() > 0.9 ? 'DEGRADED' : 'NORMAL',
        storage: Math.random() * 20 + 60
      }
    };
  };

  const generateAlerts = (tdrMeasurement = null) => {
    const alerts = [];
    const alertTypes = [
      'VOLTAGE_SPIKE', 'FREQUENCY_DEVIATION', 'ILLEGAL_FENCE_DETECTED', 
      'RCD_TRIGGERED', 'COMMUNICATION_LOSS', 'IMPEDANCE_ANOMALY'
    ];
    
    // If we have real TDR data, generate alerts based on actual measurements
    if (tdrMeasurement) {
      // Check for fence detection (ground truth from CSV)
      if (tdrMeasurement.label === 1) {
        alerts.push({
          id: Date.now(),
          type: 'ILLEGAL_FENCE_DETECTED',
          severity: 'CRITICAL',
          message: `TDR analysis confirms illegal fence connection detected`,
          location: `TDR_Measurement_${tdrMeasurement.id}`,
          timestamp: new Date().toISOString(),
          dataSource: 'LIVE_TDR_CSV',
          confidence: 95.0,
          tdrData: {
            reflection_coeff: tdrMeasurement.reflection_coeff,
            impedance_magnitude: tdrMeasurement.impedance_magnitude,
            actualLabel: tdrMeasurement.label
          }
        });
      }
      
      // Check for voltage anomalies
      if (tdrMeasurement.voltage_rms > 250 || tdrMeasurement.voltage_rms < 200) {
        alerts.push({
          id: Date.now() + 1,
          type: 'VOLTAGE_SPIKE',
          severity: tdrMeasurement.voltage_rms > 250 ? 'CRITICAL' : 'HIGH',
          message: `Voltage ${tdrMeasurement.voltage_rms.toFixed(1)}V exceeds normal range`,
          location: `TDR_Measurement_${tdrMeasurement.id}`,
          timestamp: new Date().toISOString(),
          dataSource: 'LIVE_TDR_CSV'
        });
      }
      
      // Check for impedance anomalies
      if (tdrMeasurement.impedance_magnitude < 50 || tdrMeasurement.impedance_magnitude > 500) {
        alerts.push({
          id: Date.now() + 2,
          type: 'IMPEDANCE_ANOMALY',
          severity: 'HIGH',
          message: `Impedance ${tdrMeasurement.impedance_magnitude.toFixed(1)}Ω outside normal range`,
          location: `TDR_Measurement_${tdrMeasurement.id}`,
          timestamp: new Date().toISOString(),
          dataSource: 'LIVE_TDR_CSV'
        });
      }
    } else {
      // Fallback to random alerts for simulated data
      if (Math.random() < 0.1) {
        const alertType = alertTypes[Math.floor(Math.random() * alertTypes.length)];
        alerts.push({
          id: Date.now(),
          type: alertType,
          severity: Math.random() > 0.7 ? 'CRITICAL' : Math.random() > 0.4 ? 'HIGH' : 'MEDIUM',
          message: getAlertMessage(alertType),
          location: `Sector-${Math.floor(Math.random() * 10) + 1}`,
          timestamp: new Date().toISOString(),
          dataSource: 'SIMULATED'
        });
      }
    }
    
    return alerts;
  };

  const getAlertMessage = (alertType) => {
    const messages = {
      'VOLTAGE_SPIKE': 'Voltage exceeded 250V threshold',
      'FREQUENCY_DEVIATION': 'Frequency deviation beyond ±0.5Hz',
      'ILLEGAL_FENCE_DETECTED': 'TDR analysis indicates illegal connection',
      'RCD_TRIGGERED': 'RCD activation - potential human contact',
      'COMMUNICATION_LOSS': 'IEC 61850 communication interrupted',
      'IMPEDANCE_ANOMALY': 'Significant impedance change detected'
    };
    return messages[alertType] || 'Unknown alert';
  };

  // Check for open circuit conditions and send SMS alerts
  const checkAndSendSMSAlerts = async (measurements, tdrMeasurement) => {
    const smsResults = {
      checked: false,
      openCircuitDetected: false,
      smsSent: false,
      error: null
    };

    try {
      // Only check if SMS service is available
      if (!smsService.isAvailable()) {
        smsResults.error = 'SMS service not available';
        return smsResults;
      }

      smsResults.checked = true;

      // Prepare readings for open circuit detection
      const readings = {
        impedance: measurements.impedance || tdrMeasurement?.impedance_magnitude,
        voltage: measurements.voltage || tdrMeasurement?.voltage_rms,
        current: measurements.current || tdrMeasurement?.current_rms,
        reflectionCoeff: tdrMeasurement?.reflection_coeff,
        confidence: tdrMeasurement?.load_classification_score || 85.0
      };

      // Check for open circuit conditions
      const openCircuitDetected = isOpenCircuit(readings);
      smsResults.openCircuitDetected = openCircuitDetected;

      if (openCircuitDetected) {
        console.log('🚨 Illegal fence tapping detected, sending SMS alert...');
        
        // Generate location with coordinates (you can replace this with actual GPS coordinates from your hardware)
        const location = `Sector-${Math.floor(Math.random() * 10) + 1}`;
        const coordinates = `${(10.8505 + (Math.random() - 0.5) * 0.1).toFixed(6)}, ${(76.2711 + (Math.random() - 0.5) * 0.1).toFixed(6)}`; // Kerala coordinates
        
        const smsResponse = await smsService.sendOpenCircuitAlert(readings, location, coordinates);
        
        smsResults.smsSent = true;
        smsResults.smsResponse = smsResponse;
        
        console.log('📱 SMS alert sent:', smsResults);
      }

    } catch (error) {
      console.error('❌ SMS alert error:', error);
      smsResults.error = error.message;
    }

    return smsResults;
  };

  try {
    // Add 3-second delay between notifications
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    const data = await generateRealtimeData();
    res.status(200).json(data);
  } catch (error) {
    res.status(500).json({ error: 'Failed to generate real-time data' });
  }
}
