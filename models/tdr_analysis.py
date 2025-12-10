# tdr_analysis.py
# Advanced Time Domain Reflectometry Analysis for Electric Fence Detection

import numpy as np
import scipy.signal as signal
from scipy.fft import fft, fftfreq
import matplotlib.pyplot as plt
from dataclasses import dataclass
from typing import List, Dict, Tuple, Optional
import json
from datetime import datetime

@dataclass
class TDRReflection:
    distance: float
    reflection_coefficient: float
    impedance: float
    timestamp: datetime
    confidence: float
    anomaly_type: str

@dataclass
class TDRConfiguration:
    pulse_width: float = 1e-9  # 1 nanosecond
    pulse_amplitude: float = 5.0  # 5V
    sampling_rate: float = 65e6  # 65 MSPS
    cable_velocity_factor: float = 0.67  # Typical for power cables
    cable_impedance: float = 75.0  # Ohms
    analysis_length: float = 10000.0  # 10km analysis range

class AdvancedTDRAnalyzer:
    def __init__(self, config: TDRConfiguration = None):
        self.config = config or TDRConfiguration()
        self.calibration_data = None
        self.baseline_impedance = self.config.cable_impedance
        
    def generate_tdr_pulse(self, duration: float = 2e-6) -> Tuple[np.ndarray, np.ndarray]:
        """Generate TDR test pulse with proper characteristics"""
        dt = 1 / self.config.sampling_rate
        t = np.arange(0, duration, dt)
        
        # Generate Schmitt trigger-like pulse
        pulse_samples = int(self.config.pulse_width * self.config.sampling_rate)
        pulse = np.zeros(len(t))
        pulse[:pulse_samples] = self.config.pulse_amplitude
        
        # Add realistic pulse shaping (rise/fall times)
        rise_samples = max(1, pulse_samples // 10)
        pulse[:rise_samples] = self.config.pulse_amplitude * np.linspace(0, 1, rise_samples)
        pulse[pulse_samples-rise_samples:pulse_samples] = self.config.pulse_amplitude * np.linspace(1, 0, rise_samples)
        
        return t, pulse
    
    def simulate_cable_response(self, distance_km: float, illegal_connections: List[Dict] = None) -> Tuple[np.ndarray, np.ndarray]:
        """Simulate TDR response from power cable with potential illegal connections"""
        t, pulse = self.generate_tdr_pulse()
        
        # Cable parameters
        velocity = 3e8 * self.config.cable_velocity_factor  # m/s
        
        # Initialize response
        response = pulse.copy()
        
        # Add cable attenuation (frequency dependent)
        freqs = fftfreq(len(pulse), 1/self.config.sampling_rate)
        pulse_fft = fft(pulse)
        
        # Attenuation increases with frequency and distance
        attenuation = np.exp(-0.1 * distance_km * 1000 * np.abs(freqs) / 1e6)  # dB/km/MHz
        attenuated_fft = pulse_fft * attenuation
        
        response = np.real(np.fft.ifft(attenuated_fft))
        
        # Add reflections from illegal connections
        if illegal_connections:
            for connection in illegal_connections:
                conn_distance = connection['distance']  # meters
                impedance_load = connection.get('impedance', 20)  # Fence impedance
                
                # Calculate reflection coefficient
                reflection_coeff = (impedance_load - self.baseline_impedance) / (impedance_load + self.baseline_impedance)
                
                # Calculate time delay for round trip
                round_trip_time = 2 * conn_distance / velocity
                delay_samples = int(round_trip_time * self.config.sampling_rate)
                
                if delay_samples < len(response):
                    # Add reflected pulse
                    reflection_pulse = pulse * reflection_coeff * 0.8  # Some loss
                    
                    # Ensure we don't exceed array bounds
                    end_idx = min(delay_samples + len(reflection_pulse), len(response))
                    pulse_end = end_idx - delay_samples
                    
                    response[delay_samples:end_idx] += reflection_pulse[:pulse_end]
        
        # Add noise
        noise_level = 0.01 * self.config.pulse_amplitude
        noise = np.random.normal(0, noise_level, len(response))
        response += noise
        
        return t, response
    
    def calculate_impedance_profile(self, tdr_response: np.ndarray, time_base: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
        """Calculate impedance profile from TDR response"""
        velocity = 3e8 * self.config.cable_velocity_factor
        
        # Convert time to distance (one-way)
        distance = time_base * velocity / 2
        
        # Calculate impedance using reflection coefficient
        # Z = Z0 * (1 + rho) / (1 - rho) where rho is reflection coefficient
        
        # Estimate reflection coefficient from response
        incident_pulse = tdr_response[:100]  # First part is incident
        incident_amplitude = np.max(incident_pulse)
        
        reflection_coefficient = (tdr_response - incident_amplitude) / incident_amplitude
        reflection_coefficient = np.clip(reflection_coefficient, -0.99, 0.99)  # Avoid division by zero
        
        impedance = self.baseline_impedance * (1 + reflection_coefficient) / (1 - reflection_coefficient)
        
        return distance, impedance
    
    def detect_anomalies(self, distance: np.ndarray, impedance: np.ndarray, 
                        reflection_response: np.ndarray) -> List[TDRReflection]:
        """Detect anomalies in TDR response indicating illegal connections"""
        anomalies = []
        
        # Apply smoothing filter to reduce noise
        smoothed_impedance = signal.savgol_filter(impedance, window_length=21, polyorder=3)
        smoothed_response = signal.savgol_filter(reflection_response, window_length=21, polyorder=3)
        
        # Calculate impedance gradient to find sharp changes
        impedance_gradient = np.gradient(smoothed_impedance)
        response_gradient = np.gradient(smoothed_response)
        
        # Define thresholds for anomaly detection
        impedance_threshold = 2 * np.std(impedance_gradient)
        response_threshold = 0.1 * np.max(smoothed_response)
        
        # Find peaks in reflection response
        peaks, properties = signal.find_peaks(
            np.abs(smoothed_response),
            height=response_threshold,
            distance=int(0.1 * len(smoothed_response))  # Minimum 100m separation
        )
        
        for peak_idx in peaks:
            if peak_idx < len(distance):
                peak_distance = distance[peak_idx]
                peak_reflection = smoothed_response[peak_idx]
                peak_impedance = smoothed_impedance[peak_idx]
                
                # Calculate confidence based on peak prominence and impedance change
                prominence = properties['peak_heights'][np.where(peaks == peak_idx)[0][0]]
                confidence = min(0.99, prominence / np.max(smoothed_response) * 2)
                
                # Determine anomaly type based on impedance change
                impedance_change = peak_impedance - self.baseline_impedance
                
                if impedance_change < -20:  # Significant impedance drop
                    anomaly_type = "ILLEGAL_FENCE_CONNECTION"
                elif impedance_change > 50:  # Impedance increase
                    anomaly_type = "OPEN_CIRCUIT"
                elif abs(impedance_change) > 30:
                    anomaly_type = "IMPEDANCE_MISMATCH"
                else:
                    anomaly_type = "MINOR_REFLECTION"
                
                # Only report significant anomalies
                if confidence > 0.7 and abs(impedance_change) > 15:
                    anomaly = TDRReflection(
                        distance=float(peak_distance),
                        reflection_coefficient=float(peak_reflection),
                        impedance=float(peak_impedance),
                        timestamp=datetime.now(),
                        confidence=float(confidence),
                        anomaly_type=anomaly_type
                    )
                    anomalies.append(anomaly)
        
        return anomalies
    
    def advanced_signal_processing(self, tdr_response: np.ndarray, time_base: np.ndarray) -> Dict:
        """Apply advanced signal processing techniques for better detection"""
        
        # 1. Frequency domain analysis
        freqs = fftfreq(len(tdr_response), time_base[1] - time_base[0])
        response_fft = fft(tdr_response)
        
        # 2. Wavelet analysis for transient detection
        from scipy import signal as sig
        try:
            coeffs = sig.cwt(tdr_response, sig.ricker, np.arange(1, 31))
            wavelet_energy = np.sum(np.abs(coeffs)**2, axis=0)
        except:
            wavelet_energy = np.ones(len(tdr_response))
        
        # 3. Correlation analysis with known fault signatures
        fault_template = self.create_fault_template()
        correlation = np.correlate(tdr_response, fault_template, mode='same')
        
        # 4. Statistical analysis
        response_stats = {
            'mean': float(np.mean(tdr_response)),
            'std': float(np.std(tdr_response)),
            'rms': float(np.sqrt(np.mean(tdr_response**2))),
            'peak_to_peak': float(np.ptp(tdr_response)),
            'crest_factor': float(np.max(np.abs(tdr_response)) / np.sqrt(np.mean(tdr_response**2)))
        }
        
        return {
            'frequency_spectrum': {
                'frequencies': freqs[:len(freqs)//2].tolist(),
                'magnitude': np.abs(response_fft[:len(response_fft)//2]).tolist()
            },
            'wavelet_energy': wavelet_energy.tolist(),
            'correlation': correlation.tolist(),
            'statistics': response_stats
        }
    
    def create_fault_template(self) -> np.ndarray:
        """Create template for fault signature matching"""
        # Simulate typical illegal fence connection signature
        template_length = 100
        template = np.zeros(template_length)
        
        # Sharp rise followed by exponential decay
        rise_time = 10
        template[:rise_time] = np.linspace(0, 1, rise_time)
        template[rise_time:] = np.exp(-np.arange(template_length - rise_time) / 20)
        
        return template
    
    def generate_comprehensive_report(self, tdr_data: np.ndarray, time_base: np.ndarray,
                                    cable_id: str = "Unknown") -> Dict:
        """Generate comprehensive TDR analysis report"""
        
        # Basic analysis
        distance, impedance = self.calculate_impedance_profile(tdr_data, time_base)
        anomalies = self.detect_anomalies(distance, impedance, tdr_data)
        
        # Advanced processing
        advanced_analysis = self.advanced_signal_processing(tdr_data, time_base)
        
        # Generate report
        report = {
            "report_id": f"TDR_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
            "timestamp": datetime.now().isoformat(),
            "cable_information": {
                "cable_id": cable_id,
                "analysis_range_km": float(np.max(distance) / 1000),
                "cable_impedance_nominal": self.baseline_impedance,
                "velocity_factor": self.config.cable_velocity_factor
            },
            "measurement_parameters": {
                "pulse_amplitude_v": self.config.pulse_amplitude,
                "pulse_width_ns": self.config.pulse_width * 1e9,
                "sampling_rate_msps": self.config.sampling_rate / 1e6,
                "measurement_duration_us": float((time_base[-1] - time_base[0]) * 1e6)
            },
            "analysis_results": {
                "anomalies_detected": len(anomalies),
                "illegal_connections_suspected": len([a for a in anomalies if a.anomaly_type == "ILLEGAL_FENCE_CONNECTION"]),
                "highest_confidence_detection": max([a.confidence for a in anomalies]) if anomalies else 0.0,
                "cable_health_status": "CRITICAL" if any(a.anomaly_type == "ILLEGAL_FENCE_CONNECTION" for a in anomalies) else "NORMAL"
            },
            "detected_anomalies": [
                {
                    "distance_m": anomaly.distance,
                    "impedance_ohm": anomaly.impedance,
                    "reflection_coefficient": anomaly.reflection_coefficient,
                    "confidence_percent": anomaly.confidence * 100,
                    "anomaly_type": anomaly.anomaly_type,
                    "severity": "CRITICAL" if anomaly.confidence > 0.9 else "HIGH" if anomaly.confidence > 0.7 else "MEDIUM",
                    "recommended_action": self.get_recommended_action(anomaly)
                }
                for anomaly in anomalies
            ],
            "impedance_profile": {
                "distances_m": distance[::10].tolist(),  # Subsample for JSON size
                "impedances_ohm": impedance[::10].tolist()
            },
            "advanced_analysis": advanced_analysis,
            "recommendations": self.generate_recommendations(anomalies)
        }
        
        return report
    
    def get_recommended_action(self, anomaly: TDRReflection) -> str:
        """Get recommended action based on anomaly type and confidence"""
        if anomaly.anomaly_type == "ILLEGAL_FENCE_CONNECTION":
            if anomaly.confidence > 0.9:
                return "IMMEDIATE_FIELD_INSPECTION_REQUIRED"
            else:
                return "SCHEDULE_INSPECTION_WITHIN_24_HOURS"
        elif anomaly.anomaly_type == "OPEN_CIRCUIT":
            return "CHECK_CABLE_CONTINUITY"
        elif anomaly.anomaly_type == "IMPEDANCE_MISMATCH":
            return "VERIFY_CABLE_SPECIFICATIONS"
        else:
            return "MONITOR_FOR_PATTERN_CHANGES"
    
    def generate_recommendations(self, anomalies: List[TDRReflection]) -> List[str]:
        """Generate actionable recommendations based on analysis"""
        recommendations = []
        
        illegal_connections = [a for a in anomalies if a.anomaly_type == "ILLEGAL_FENCE_CONNECTION"]
        
        if illegal_connections:
            high_conf_connections = [a for a in illegal_connections if a.confidence > 0.9]
            
            if high_conf_connections:
                recommendations.append("CRITICAL: High-confidence illegal fence connections detected - deploy emergency response team")
                for conn in high_conf_connections:
                    recommendations.append(f"Priority location: {conn.distance:.0f}m from monitoring point")
            
            recommendations.append("Coordinate with local authorities for illegal connection removal")
            recommendations.append("Implement enhanced monitoring at detected locations")
            recommendations.append("Consider legal action against property owners")
        
        if len(anomalies) > 3:
            recommendations.append("Multiple anomalies detected - comprehensive cable audit recommended")
        
        recommendations.append("Continue regular TDR monitoring to detect new installations")
        recommendations.append("Update GIS mapping with detected anomaly locations")
        
        return recommendations
    
    def export_data_for_gis(self, anomalies: List[TDRReflection], 
                           cable_route_gps: List[Tuple[float, float]]) -> Dict:
        """Export anomaly data in GIS-compatible format"""
        if not cable_route_gps:
            return {"error": "Cable GPS coordinates required for GIS export"}
        
        gis_data = {
            "type": "FeatureCollection",
            "features": []
        }
        
        for anomaly in anomalies:
            # Interpolate GPS coordinates based on distance along cable
            total_cable_length = max([a.distance for a in anomalies]) if anomalies else 1000
            gps_index = min(int(anomaly.distance / total_cable_length * len(cable_route_gps)), 
                          len(cable_route_gps) - 1)
            
            feature = {
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [cable_route_gps[gps_index][1], cable_route_gps[gps_index][0]]  # [lon, lat]
                },
                "properties": {
                    "anomaly_type": anomaly.anomaly_type,
                    "distance_m": anomaly.distance,
                    "impedance_ohm": anomaly.impedance,
                    "confidence": anomaly.confidence,
                    "timestamp": anomaly.timestamp.isoformat(),
                    "severity": "CRITICAL" if anomaly.confidence > 0.9 else "HIGH" if anomaly.confidence > 0.7 else "MEDIUM"
                }
            }
            gis_data["features"].append(feature)
        
        return gis_data

# Example usage and testing
if __name__ == "__main__":
    # Initialize TDR analyzer
    config = TDRConfiguration(
        pulse_amplitude=5.0,
        sampling_rate=65e6,
        cable_velocity_factor=0.67
    )
    
    analyzer = AdvancedTDRAnalyzer(config)
    
    # Simulate TDR measurement with illegal connections
    illegal_connections = [
        {"distance": 3200, "impedance": 20},  # Illegal fence at 3.2km
        {"distance": 7500, "impedance": 15}   # Another connection at 7.5km
    ]
    
    print("Simulating TDR measurement...")
    time_base, tdr_response = analyzer.simulate_cable_response(10.0, illegal_connections)
    
    # Perform analysis
    print("Analyzing TDR data...")
    report = analyzer.generate_comprehensive_report(tdr_response, time_base, "Line_Kerala_001")
    
    # Display results
    print("\n" + "="*50)
    print("TDR ANALYSIS REPORT")
    print("="*50)
    print(f"Cable ID: {report['cable_information']['cable_id']}")
    print(f"Analysis Range: {report['cable_information']['analysis_range_km']:.2f} km")
    print(f"Anomalies Detected: {report['analysis_results']['anomalies_detected']}")
    print(f"Illegal Connections Suspected: {report['analysis_results']['illegal_connections_suspected']}")
    print(f"Cable Health Status: {report['analysis_results']['cable_health_status']}")
    
    print("\nDETECTED ANOMALIES:")
    for i, anomaly in enumerate(report['detected_anomalies'], 1):
        print(f"{i}. Distance: {anomaly['distance_m']:.0f}m")
        print(f"   Type: {anomaly['anomaly_type']}")
        print(f"   Confidence: {anomaly['confidence_percent']:.1f}%")
        print(f"   Severity: {anomaly['severity']}")
        print(f"   Action: {anomaly['recommended_action']}")
        print()
    
    print("RECOMMENDATIONS:")
    for i, rec in enumerate(report['recommendations'], 1):
        print(f"{i}. {rec}")
    
    # Export sample GIS data
    sample_gps = [(10.8505, 76.2711), (10.8510, 76.2720), (10.8515, 76.2730)]  # Sample coordinates
    distance, impedance = analyzer.calculate_impedance_profile(tdr_response, time_base)
    anomalies = analyzer.detect_anomalies(distance, impedance, tdr_response)
    
    gis_data = analyzer.export_data_for_gis(anomalies, sample_gps)
    print(f"\nGIS Export: {len(gis_data['features'])} features exported")
    
    # Save full report
    with open('tdr_analysis_report.json', 'w') as f:
        json.dump(report, f, indent=2)
    
    print("\nFull report saved to 'tdr_analysis_report.json'")