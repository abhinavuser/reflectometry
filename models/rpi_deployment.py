#!/usr/bin/env python3
# RPi TDR Fence Detection - Deployment Script
# Copy this to your Raspberry Pi 3B for real-time detection

import numpy as np
import joblib
import json
import time
from datetime import datetime
import logging

class RPiFenceDetector:
    def __init__(self, model_path='rpi_models'):
        print("Loading RPi TDR Fence Detector...")
        
        # Load model and scaler
        self.model = joblib.load(f'{model_path}/rpi_fence_detector.pkl')
        self.scaler = joblib.load(f'{model_path}/rpi_scaler.pkl')
        
        # Load configuration
        with open(f'{model_path}/rpi_config.json', 'r') as f:
            self.config = json.load(f)
        
        self.essential_features = self.config['essential_features']
        print(f"Model loaded successfully!")
        print(f"Features: {', '.join(self.essential_features)}")
        
        # Setup logging
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('rpi_fence_detection.log'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
    
    def predict_fence(self, tdr_features):
        """
        Predict if measurement indicates fence
        
        Args:
            tdr_features: dict with keys matching essential_features
            
        Returns:
            dict with prediction results
        """
        try:
            # Extract features in correct order
            feature_vector = np.array([tdr_features[feat] for feat in self.essential_features])
            feature_vector = feature_vector.reshape(1, -1).astype(np.float32)
            
            # Normalize
            feature_vector_scaled = self.scaler.transform(feature_vector)
            
            # Predict
            start_time = time.time()
            prediction = self.model.predict(feature_vector_scaled)[0]
            probability = self.model.predict_proba(feature_vector_scaled)[0][1]
            inference_time = (time.time() - start_time) * 1000
            
            result = {
                'is_fence': bool(prediction == 1),
                'confidence': float(probability),
                'inference_time_ms': inference_time,
                'timestamp': datetime.now().isoformat()
            }
            
            # Log if fence detected
            if result['is_fence']:
                self.logger.warning(f"FENCE DETECTED! Confidence: {probability:.3f}")
            
            return result
            
        except Exception as e:
            self.logger.error(f"Prediction error: {str(e)}")
            return {'error': str(e)}

# Example usage
if __name__ == "__main__":
    # Initialize detector
    detector = RPiFenceDetector()
    
    # Example TDR measurement (replace with actual sensor data)
    example_measurement = {
        'active_power': 150.5,
        'current_rms': 0.68,
        'impedance_magnitude': 220.0,
        'power_factor': 0.85,
        'load_classification_score': 0.65,
        'impedance_ratio': 4.4
    }
    
    # Make prediction
    result = detector.predict_fence(example_measurement)
    print(f"Result: {result}")
    
    print("RPi TDR Fence Detector ready for deployment!")
