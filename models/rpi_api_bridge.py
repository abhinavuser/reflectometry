#!/usr/bin/env python3
# Fence Detection API Bridge - Connects trained fence detection models to Next.js API
# This script is called from the Next.js API to run fence detection predictions

import sys
import json
import numpy as np
import joblib
from datetime import datetime
import os

class FenceDetectionBridge:
    def __init__(self):
        self.model = None
        self.scaler = None
        self.config = None
        self.essential_features = None
        self.load_models()
    
    def load_models(self):
        """Load the trained fence detection models"""
        try:
            # Get the directory where this script is located
            script_dir = os.path.dirname(os.path.abspath(__file__))
            
            # Load model and scaler
            self.model = joblib.load(os.path.join(script_dir, 'rpi_fence_detector.pkl'))
            self.scaler = joblib.load(os.path.join(script_dir, 'rpi_scaler.pkl'))
            
            # Load configuration
            with open(os.path.join(script_dir, 'rpi_config.json'), 'r') as f:
                self.config = json.load(f)
            
            self.essential_features = self.config['essential_features']
            
        except Exception as e:
            print(f"Error loading models: {e}", file=sys.stderr)
            self.model = None
            self.scaler = None
    
    def predict_fence(self, tdr_features):
        """
        Predict if measurement indicates fence
        
        Args:
            tdr_features: dict with keys matching essential_features
            
        Returns:
            dict with prediction results
        """
        if self.model is None or self.scaler is None:
            return {
                'error': 'Models not loaded',
                'is_fence': False,
                'confidence': 0.0,
                'inference_time_ms': 0,
                'timestamp': datetime.now().isoformat()
            }
        
        try:
            # Extract features in correct order
            feature_vector = np.array([tdr_features.get(feat, 0) for feat in self.essential_features])
            feature_vector = feature_vector.reshape(1, -1).astype(np.float32)
            
            # Normalize
            feature_vector_scaled = self.scaler.transform(feature_vector)
            
            # Predict
            import time
            start_time = time.time()
            prediction = self.model.predict(feature_vector_scaled)[0]
            probability = self.model.predict_proba(feature_vector_scaled)[0][1]
            inference_time = (time.time() - start_time) * 1000
            
            result = {
                'is_fence': bool(prediction == 1),
                'confidence': float(probability),
                'inference_time_ms': inference_time,
                'timestamp': datetime.now().isoformat(),
                'features_used': self.essential_features,
                'model_version': self.config.get('model_info', {}).get('version', '1.0.0')
            }
            
            return result
            
        except Exception as e:
            return {
                'error': str(e),
                'is_fence': False,
                'confidence': 0.0,
                'inference_time_ms': 0,
                'timestamp': datetime.now().isoformat()
            }

def main():
    """Main function to handle API calls"""
    try:
        # Read input from stdin (sent from Next.js API)
        input_data = sys.stdin.read()
        
        if not input_data:
            # Generate example data if no input
            input_data = json.dumps({
                'active_power': 150.5,
                'current_rms': 0.68,
                'impedance_magnitude': 220.0,
                'power_factor': 0.85,
                'load_classification_score': 0.65,
                'impedance_ratio': 4.4
            })
        
        # Parse input
        tdr_features = json.loads(input_data)
        
        # Initialize bridge and make prediction
        bridge = FenceDetectionBridge()
        result = bridge.predict_fence(tdr_features)
        
        # Output result as JSON
        print(json.dumps(result))
        
    except Exception as e:
        error_result = {
            'error': str(e),
            'is_fence': False,
            'confidence': 0.0,
            'inference_time_ms': 0,
            'timestamp': datetime.now().isoformat()
        }
        print(json.dumps(error_result))

if __name__ == "__main__":
    main()
