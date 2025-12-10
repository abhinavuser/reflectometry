// csv_data_reader.js
// Live CSV data reader for TDR measurements

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

class TDRDataReader {
  constructor() {
    this.csvData = [];
    this.currentIndex = 0;
    this.isLoaded = false;
    this.csvPath = path.join(__dirname, 'train_features.csv');
  }

  // Load CSV data into memory
  loadCSVData() {
    try {
      console.log('📊 Loading TDR CSV data...');
      const csvContent = fs.readFileSync(this.csvPath, 'utf8');
      const lines = csvContent.trim().split('\n');
      
      // Skip header row
      const dataLines = lines.slice(1);
      
      this.csvData = dataLines.map((line, index) => {
        const values = line.split(',');
        return {
          id: index + 1,
          reflection_coeff: parseFloat(values[0]),
          time_delay: parseFloat(values[1]),
          peak_ratio: parseFloat(values[2]),
          impedance_magnitude: parseFloat(values[3]),
          power_factor: parseFloat(values[4]),
          voltage_rms: parseFloat(values[5]),
          current_rms: parseFloat(values[6]),
          active_power: parseFloat(values[7]),
          energy_ratio: parseFloat(values[8]),
          spectral_centroid: parseFloat(values[9]),
          load_classification_score: parseFloat(values[10]),
          impedance_ratio: parseFloat(values[11]),
          label: parseInt(values[12]), // 0 = no fence, 1 = fence
          timestamp: new Date(Date.now() + (index * 1000)).toISOString() // Simulate timestamps
        };
      });

      this.isLoaded = true;
      console.log(`✅ Loaded ${this.csvData.length} TDR measurements from CSV`);
      return true;
    } catch (error) {
      console.error('❌ Error loading CSV data:', error.message);
      return false;
    }
  }

  // Get next TDR measurement (simulates live data)
  getNextMeasurement() {
    if (!this.isLoaded) {
      this.loadCSVData();
    }

    if (this.csvData.length === 0) {
      return null;
    }

    // Get current measurement
    const measurement = this.csvData[this.currentIndex];
    
    // Move to next measurement (cycle through data)
    this.currentIndex = (this.currentIndex + 1) % this.csvData.length;
    
    // Update timestamp to current time
    measurement.timestamp = new Date().toISOString();
    
    return measurement;
  }

  // Get random TDR measurement
  getRandomMeasurement() {
    if (!this.isLoaded) {
      this.loadCSVData();
    }

    if (this.csvData.length === 0) {
      return null;
    }

    const randomIndex = Math.floor(Math.random() * this.csvData.length);
    const measurement = { ...this.csvData[randomIndex] };
    measurement.timestamp = new Date().toISOString();
    
    return measurement;
  }

  // Get TDR data for model prediction (6 features your model needs)
  getModelInputData(measurement) {
    if (!measurement) return null;

    return {
      active_power: measurement.active_power,
      current_rms: measurement.current_rms,
      impedance_magnitude: measurement.impedance_magnitude,
      power_factor: measurement.power_factor,
      load_classification_score: measurement.load_classification_score,
      impedance_ratio: measurement.impedance_ratio
    };
  }

  // Get statistics about the dataset
  getDatasetStats() {
    if (!this.isLoaded) {
      this.loadCSVData();
    }

    const fenceCount = this.csvData.filter(m => m.label === 1).length;
    const noFenceCount = this.csvData.filter(m => m.label === 0).length;
    
    return {
      totalMeasurements: this.csvData.length,
      fenceDetections: fenceCount,
      noFenceDetections: noFenceCount,
      fencePercentage: ((fenceCount / this.csvData.length) * 100).toFixed(2),
      currentIndex: this.currentIndex,
      isLoaded: this.isLoaded
    };
  }

  // Get measurements by label (fence/no fence)
  getMeasurementsByLabel(label) {
    if (!this.isLoaded) {
      this.loadCSVData();
    }

    return this.csvData.filter(m => m.label === label);
  }

  // Reset to beginning of dataset
  reset() {
    this.currentIndex = 0;
    console.log('🔄 Reset TDR data reader to beginning');
  }
}

// Create singleton instance
const tdrDataReader = new TDRDataReader();

export default tdrDataReader;
