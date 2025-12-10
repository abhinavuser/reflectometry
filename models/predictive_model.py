# predictive_model.py
# Advanced AI Model for Electric Fence Voltage Spike Prediction

import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor, IsolationForest
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, r2_score
import joblib
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import json
from datetime import datetime, timedelta

class VoltageSpikePredictionModel:
    def __init__(self):
        self.rf_model = None
        self.lstm_model = None
        self.anomaly_detector = None
        self.scaler = StandardScaler()
        self.feature_columns = [
            'voltage', 'current', 'frequency', 'impedance', 
            'power_factor', 'temperature', 'humidity', 
            'time_hour', 'time_minute', 'day_of_week'
        ]
        
    def generate_training_data(self, samples=10000):
        """Generate realistic training data for the model"""
        np.random.seed(42)
        
        data = []
        base_date = datetime.now() - timedelta(days=365)
        
        for i in range(samples):
            # Time features
            current_time = base_date + timedelta(minutes=i*10)
            hour = current_time.hour
            minute = current_time.minute
            day_of_week = current_time.weekday()
            
            # Base electrical parameters
            base_voltage = 230
            base_current = 15
            base_frequency = 50
            
            # Seasonal and daily variations
            daily_factor = np.sin(2 * np.pi * hour / 24)
            weekly_factor = np.sin(2 * np.pi * day_of_week / 7)
            
            # Normal variations
            voltage = base_voltage + daily_factor * 10 + weekly_factor * 5 + np.random.normal(0, 3)
            current = base_current + daily_factor * 3 + weekly_factor * 2 + np.random.normal(0, 1)
            frequency = base_frequency + np.random.normal(0, 0.1)
            
            # Environmental factors
            temperature = 25 + daily_factor * 10 + np.random.normal(0, 5)
            humidity = 60 + np.sin(2 * np.pi * (hour + 6) / 24) * 20 + np.random.normal(0, 10)
            
            # Impedance and power factor
            impedance = 75 + np.random.normal(0, 5)
            power_factor = 0.85 + np.random.normal(0, 0.05)
            
            # Illegal fence simulation (5% of data)
            if np.random.random() < 0.05:
                # Illegal fence causes voltage spikes and impedance drops
                voltage += np.random.uniform(20, 50)  # Voltage spike
                impedance -= np.random.uniform(15, 35)  # Impedance drop
                current += np.random.uniform(5, 15)  # Current increase
                is_illegal_fence = 1
            else:
                is_illegal_fence = 0
                
            # TDR reflection coefficient
            if is_illegal_fence:
                tdr_reflection = np.random.uniform(40, 80)  # Strong reflection
            else:
                tdr_reflection = np.random.uniform(0, 20)   # Normal reflection
            
            data.append({
                'timestamp': current_time,
                'voltage': voltage,
                'current': current,
                'frequency': frequency,
                'impedance': impedance,
                'power_factor': power_factor,
                'temperature': temperature,
                'humidity': humidity,
                'time_hour': hour,
                'time_minute': minute,
                'day_of_week': day_of_week,
                'tdr_reflection': tdr_reflection,
                'is_illegal_fence': is_illegal_fence,
                'voltage_spike_risk': 1 if voltage > 250 else 0
            })
            
        return pd.DataFrame(data)
    
    def prepare_features(self, df):
        """Prepare features for model training"""
        # Create additional engineered features
        df['voltage_current_ratio'] = df['voltage'] / df['current']
        df['impedance_change'] = df['impedance'].rolling(window=5).std().fillna(0)
        df['frequency_deviation'] = abs(df['frequency'] - 50)
        df['power_quality_index'] = df['power_factor'] * (1 - df['frequency_deviation'] / 50)
        
        # Lag features
        for col in ['voltage', 'current', 'frequency']:
            df[f'{col}_lag1'] = df[col].shift(1).fillna(df[col].mean())
            df[f'{col}_lag5'] = df[col].shift(5).fillna(df[col].mean())
        
        return df
    
    def train_random_forest_model(self, df):
        """Train Random Forest model for voltage spike prediction"""
        print("Training Random Forest model...")
        
        # Prepare features
        df = self.prepare_features(df)
        
        feature_cols = self.feature_columns + [
            'voltage_current_ratio', 'impedance_change', 'frequency_deviation',
            'power_quality_index', 'voltage_lag1', 'current_lag1', 'frequency_lag1',
            'voltage_lag5', 'current_lag5', 'frequency_lag5'
        ]
        
        X = df[feature_cols].fillna(0)
        y = df['voltage_spike_risk']
        
        # Scale features
        X_scaled = self.scaler.fit_transform(X)
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X_scaled, y, test_size=0.2, random_state=42
        )
        
        # Train model
        self.rf_model = RandomForestRegressor(
            n_estimators=100,
            max_depth=10,
            random_state=42,
            n_jobs=-1
        )
        
        self.rf_model.fit(X_train, y_train)
        
        # Evaluate
        y_pred = self.rf_model.predict(X_test)
        mse = mean_squared_error(y_test, y_pred)
        r2 = r2_score(y_test, y_pred)
        
        print(f"Random Forest - MSE: {mse:.4f}, R2: {r2:.4f}")
        
        # Feature importance
        feature_importance = pd.DataFrame({
            'feature': feature_cols,
            'importance': self.rf_model.feature_importances_
        }).sort_values('importance', ascending=False)
        
        print("Top 10 most important features:")
        print(feature_importance.head(10))
        
    def train_lstm_model(self, df):
        """Train LSTM model for time series prediction"""
        print("Training LSTM model...")
        
        # Prepare time series data
        df = self.prepare_features(df)
        
        # Create sequences
        def create_sequences(data, seq_length=24):
            sequences = []
            targets = []
            
            for i in range(len(data) - seq_length):
                seq = data[i:i+seq_length]
                target = data[i+seq_length]
                sequences.append(seq)
                targets.append(target)
            
            return np.array(sequences), np.array(targets)
        
        # Use voltage as main target
        voltage_data = df['voltage'].values
        voltage_scaled = self.scaler.fit_transform(voltage_data.reshape(-1, 1)).flatten()
        
        X_seq, y_seq = create_sequences(voltage_scaled, seq_length=24)
        
        # Split data
        split_idx = int(len(X_seq) * 0.8)
        X_train, X_test = X_seq[:split_idx], X_seq[split_idx:]
        y_train, y_test = y_seq[:split_idx], y_seq[split_idx:]
        
        # Build LSTM model
        self.lstm_model = keras.Sequential([
            layers.LSTM(64, return_sequences=True, input_shape=(24, 1)),
            layers.Dropout(0.2),
            layers.LSTM(32, return_sequences=False),
            layers.Dropout(0.2),
            layers.Dense(16, activation='relu'),
            layers.Dense(1)
        ])
        
        self.lstm_model.compile(
            optimizer='adam',
            loss='mse',
            metrics=['mae']
        )
        
        # Train model
        history = self.lstm_model.fit(
            X_train.reshape(X_train.shape[0], X_train.shape[1], 1),
            y_train,
            epochs=50,
            batch_size=32,
            validation_split=0.1,
            verbose=1
        )
        
        # Evaluate
        test_loss = self.lstm_model.evaluate(
            X_test.reshape(X_test.shape[0], X_test.shape[1], 1),
            y_test,
            verbose=0
        )
        
        print(f"LSTM - Test Loss: {test_loss[0]:.4f}")
    
    def train_anomaly_detector(self, df):
        """Train Isolation Forest for anomaly detection"""
        print("Training Anomaly Detection model...")
        
        # Features for anomaly detection
        features = ['voltage', 'current', 'frequency', 'impedance', 'tdr_reflection']
        X = df[features].fillna(0)
        
        # Scale features
        X_scaled = StandardScaler().fit_transform(X)
        
        # Train Isolation Forest
        self.anomaly_detector = IsolationForest(
            contamination=0.1,  # 10% anomalies expected
            random_state=42,
            n_jobs=-1
        )
        
        self.anomaly_detector.fit(X_scaled)
        
        # Evaluate anomaly detection
        anomaly_scores = self.anomaly_detector.decision_function(X_scaled)
        anomaly_predictions = self.anomaly_detector.predict(X_scaled)
        
        print(f"Anomalies detected: {np.sum(anomaly_predictions == -1)} out of {len(X_scaled)}")
        
    def predict_voltage_spike(self, current_data):
        """Predict voltage spike probability"""
        if self.rf_model is None:
            return {"error": "Model not trained"}
        
        # Prepare features
        features = []
        for col in self.feature_columns:
            features.append(current_data.get(col, 0))
        
        # Add engineered features (simplified)
        features.extend([
            current_data.get('voltage', 230) / current_data.get('current', 15),  # voltage_current_ratio
            0,  # impedance_change (simplified)
            abs(current_data.get('frequency', 50) - 50),  # frequency_deviation
            current_data.get('power_factor', 0.85) * (1 - abs(current_data.get('frequency', 50) - 50) / 50),  # power_quality_index
            current_data.get('voltage', 230),  # voltage_lag1 (simplified)
            current_data.get('current', 15),   # current_lag1 (simplified)
            current_data.get('frequency', 50), # frequency_lag1 (simplified)
            current_data.get('voltage', 230),  # voltage_lag5 (simplified)
            current_data.get('current', 15),   # current_lag5 (simplified)
            current_data.get('frequency', 50)  # frequency_lag5 (simplified)
        ])
        
        # Scale and predict
        features_scaled = self.scaler.transform([features])
        spike_probability = self.rf_model.predict(features_scaled)[0]
        
        # Anomaly detection
        anomaly_score = self.anomaly_detector.decision_function(features_scaled[:, :5])[0]
        is_anomaly = self.anomaly_detector.predict(features_scaled[:, :5])[0] == -1
        
        return {
            "spike_probability": float(spike_probability),
            "anomaly_score": float(anomaly_score),
            "is_anomaly": bool(is_anomaly),
            "risk_level": "HIGH" if spike_probability > 0.7 or is_anomaly else "MEDIUM" if spike_probability > 0.3 else "LOW",
            "confidence": 0.95 if not is_anomaly else 0.85
        }
    
    def predict_next_24_hours(self, historical_data):
        """Predict voltage behavior for next 24 hours using LSTM"""
        if self.lstm_model is None:
            return {"error": "LSTM model not trained"}
        
        # Prepare last 24 data points
        if len(historical_data) < 24:
            return {"error": "Need at least 24 historical data points"}
        
        last_24 = np.array([d['voltage'] for d in historical_data[-24:]])
        last_24_scaled = self.scaler.transform(last_24.reshape(-1, 1)).flatten()
        
        predictions = []
        current_sequence = last_24_scaled.copy()
        
        for hour in range(24):
            # Predict next value
            input_seq = current_sequence[-24:].reshape(1, 24, 1)
            next_pred = self.lstm_model.predict(input_seq, verbose=0)[0][0]
            
            # Update sequence
            current_sequence = np.append(current_sequence, next_pred)
            
            # Convert back to original scale
            pred_voltage = self.scaler.inverse_transform([[next_pred]])[0][0]
            
            predictions.append({
                "hour": hour + 1,
                "predicted_voltage": float(pred_voltage),
                "spike_risk": "HIGH" if pred_voltage > 250 else "MEDIUM" if pred_voltage > 240 else "LOW"
            })
        
        return {
            "predictions": predictions,
            "model_confidence": 0.92,
            "forecast_horizon": "24 hours"
        }
    
    def tdr_analysis(self, tdr_data):
        """Analyze TDR reflection data for illegal fence detection"""
        reflection_values = np.array([d['reflection'] for d in tdr_data])
        distances = np.array([d['distance'] for d in tdr_data])
        
        # Detect anomalous reflections
        mean_reflection = np.mean(reflection_values)
        std_reflection = np.std(reflection_values)
        threshold = mean_reflection + 3 * std_reflection
        
        anomalies = []
        for i, (distance, reflection) in enumerate(zip(distances, reflection_values)):
            if reflection > threshold:
                # Calculate impedance change
                impedance_change = -reflection * 0.5  # Simplified calculation
                
                anomalies.append({
                    "distance_meters": float(distance),
                    "reflection_db": float(reflection),
                    "impedance_change_ohms": float(impedance_change),
                    "confidence": min(0.99, 0.7 + (reflection - threshold) / threshold),
                    "severity": "CRITICAL" if reflection > threshold * 1.5 else "HIGH"
                })
        
        return {
            "anomalies_detected": len(anomalies),
            "anomaly_locations": anomalies,
            "analysis_summary": {
                "total_distance_analyzed": float(max(distances)),
                "average_reflection": float(mean_reflection),
                "detection_threshold": float(threshold)
            }
        }
    
    def save_models(self, model_dir="models/"):
        """Save trained models"""
        import os
        os.makedirs(model_dir, exist_ok=True)
        
        if self.rf_model:
            joblib.dump(self.rf_model, f"{model_dir}/rf_model.pkl")
        if self.lstm_model:
            self.lstm_model.save(f"{model_dir}/lstm_model.h5")
        if self.anomaly_detector:
            joblib.dump(self.anomaly_detector, f"{model_dir}/anomaly_detector.pkl")
        
        joblib.dump(self.scaler, f"{model_dir}/scaler.pkl")
        
        print(f"Models saved to {model_dir}")
    
    def load_models(self, model_dir="models/"):
        """Load pre-trained models"""
        try:
            self.rf_model = joblib.load(f"{model_dir}/rf_model.pkl")
            self.lstm_model = keras.models.load_model(f"{model_dir}/lstm_model.h5")
            self.anomaly_detector = joblib.load(f"{model_dir}/anomaly_detector.pkl")
            self.scaler = joblib.load(f"{model_dir}/scaler.pkl")
            print(f"Models loaded from {model_dir}")
        except Exception as e:
            print(f"Error loading models: {e}")
    
    def generate_report(self, data):
        """Generate comprehensive analysis report"""
        spike_pred = self.predict_voltage_spike(data)
        
        report = {
            "timestamp": datetime.now().isoformat(),
            "system_status": "OPERATIONAL",
            "current_readings": {
                "voltage": data.get('voltage', 0),
                "current": data.get('current', 0),
                "frequency": data.get('frequency', 0),
                "impedance": data.get('impedance', 0),
                "power_factor": data.get('power_factor', 0)
            },
            "ai_analysis": spike_pred,
            "recommendations": []
        }
        
        # Generate recommendations based on analysis
        if spike_pred.get("risk_level") == "HIGH":
            report["recommendations"].extend([
                "Immediate inspection of power lines recommended",
                "Deploy field team to investigate potential illegal connections",
                "Activate emergency response protocols"
            ])
        elif spike_pred.get("risk_level") == "MEDIUM":
            report["recommendations"].extend([
                "Schedule routine inspection within 24 hours",
                "Monitor voltage patterns closely",
                "Check historical data for pattern confirmation"
            ])
        
        if spike_pred.get("is_anomaly"):
            report["recommendations"].append("Anomalous behavior detected - requires expert analysis")
        
        return report

# Example usage and testing
if __name__ == "__main__":
    # Initialize model
    model = VoltageSpikePredictionModel()
    
    # Generate training data
    print("Generating training data...")
    df = model.generate_training_data(samples=5000)
    
    # Train all models
    model.train_random_forest_model(df)
    model.train_lstm_model(df)
    model.train_anomaly_detector(df)
    
    # Test prediction
    test_data = {
        'voltage': 245,
        'current': 18,
        'frequency': 49.8,
        'impedance': 65,
        'power_factor': 0.82,
        'temperature': 30,
        'humidity': 70,
        'time_hour': 14,
        'time_minute': 30,
        'day_of_week': 2
    }
    
    print("\nTesting voltage spike prediction:")
    result = model.predict_voltage_spike(test_data)
    print(json.dumps(result, indent=2))
    
    # Test TDR analysis
    tdr_test_data = [
        {"distance": i*100, "reflection": 10 + np.random.normal(0, 5)} 
        for i in range(100)
    ]
    # Add anomaly
    tdr_test_data[32]['reflection'] = 55  # Strong reflection at 3.2km
    
    print("\nTesting TDR analysis:")
    tdr_result = model.tdr_analysis(tdr_test_data)
    print(json.dumps(tdr_result, indent=2))
    
    # Generate report
    print("\nGenerating comprehensive report:")
    report = model.generate_report(test_data)
    print(json.dumps(report, indent=2))
    
    # Save models
    model.save_models()