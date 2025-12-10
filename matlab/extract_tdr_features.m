function features = extract_tdr_features(incident_pulse, reflected_pulse, electrical_params, time_vector, line_params)
%EXTRACT_TDR_FEATURES_OPTIMIZED Extract only essential features for fence detection
%
% Inputs:
%   incident_pulse    - Incident TDR pulse waveform
%   reflected_pulse   - Reflected TDR pulse waveform
%   electrical_params - Structure with electrical measurements
%   time_vector       - Time vector for waveforms
%   line_params       - Transmission line parameters
%
% Outputs:
%   features - Structure containing 12 essential features for fence detection

    features = struct();
    
    % Check if inputs are GPU arrays
    gpu_available = isa(incident_pulse, 'gpuArray') || isa(reflected_pulse, 'gpuArray') || isa(time_vector, 'gpuArray');
    
    % Ensure inputs are column vectors
    incident_pulse = incident_pulse(:);
    reflected_pulse = reflected_pulse(:);
    time_vector = time_vector(:);
    
    %% 1. PRIMARY TDR FEATURES (Most Important for Physics-Based Detection)
    
    % Reflection coefficient - THE most important TDR parameter
    [rho, delay_time] = calculate_reflection_coefficient(incident_pulse, reflected_pulse, time_vector);
    features.reflection_coeff = rho;
    features.time_delay = delay_time;
    
    % Peak amplitude ratio - Simple but effective
    if gpu_available
        max_inc = gather(max(abs(incident_pulse)));
        max_ref = gather(max(abs(reflected_pulse)));
    else
        max_inc = max(abs(incident_pulse));
        max_ref = max(abs(reflected_pulse));
    end
    features.peak_ratio = max_ref / (max_inc + eps);
    
    %% 2. ELECTRICAL PARAMETERS (Direct Physics Measurements)
    
    % Load impedance - Direct indicator of fence vs house
    if electrical_params.I_rms > 0
        Z_magnitude = abs(electrical_params.V_rms / electrical_params.I_rms);
    else
        Z_magnitude = 1000; % Default reasonable value
    end
    features.impedance_magnitude = Z_magnitude;
    
    % Power factor - Key discriminator (fences ≈1.0, houses 0.7-0.95)
    features.power_factor = electrical_params.power_factor;
    
    % Basic electrical measurements
    features.voltage_rms = electrical_params.V_rms;
    features.current_rms = electrical_params.I_rms;
    features.active_power = electrical_params.P_active;
    
    %% 3. SIGNAL ENERGY METRICS (Simple but Effective)
    
    % Energy ratio - Indicates strength of reflection
    if gpu_available
        inc_energy = gather(sum(incident_pulse.^2));
        ref_energy = gather(sum(reflected_pulse.^2));
    else
        inc_energy = sum(incident_pulse.^2);
        ref_energy = sum(reflected_pulse.^2);
    end
    features.energy_ratio = ref_energy / (inc_energy + eps);
    
    %% 4. FREQUENCY DOMAIN (Only Essential One)
    
    % Spectral centroid - Indicates signal distortion
    freq_features = calculate_frequency_features_simple(reflected_pulse, time_vector);
    features.spectral_centroid = freq_features.centroid;
    
    %% 5. PHYSICS-INFORMED COMBINED METRICS
    
    % Load classification score - Combines multiple physics indicators
    features.load_classification_score = calculate_load_score_simple(features);
    
    % Impedance ratio - Compares to characteristic impedance
    features.impedance_ratio = Z_magnitude / line_params.Z0;
    
    %% Validate all features are finite numbers
    field_names = fieldnames(features);
    for i = 1:length(field_names)
        field_val = features.(field_names{i});
        if ~isfinite(field_val) || isnan(field_val)
            features.(field_names{i}) = 0; % Replace invalid values with 0
        end
    end
end

%% Helper function for simplified frequency features
function freq_features = calculate_frequency_features_simple(signal, time_vector)
    freq_features = struct();
    
    % Check if inputs are GPU arrays
    gpu_available = isa(signal, 'gpuArray') || isa(time_vector, 'gpuArray');
    
    % Use only first 512 samples for efficiency
    max_samples = min(512, length(signal));
    signal = signal(1:max_samples);
    time_vector = time_vector(1:max_samples);
    
    if gpu_available
        % Perform GPU FFT
        N = length(signal);
        dt = gather(time_vector(2) - time_vector(1));
        
        signal_fft = fft(signal);
        power_spectrum = abs(signal_fft(1:floor(N/2)+1)).^2;
        
        % Convert frequency vector to GPU
        freq_pos = gpuArray(single((0:floor(N/2))' / (N*dt)));
        
        % Spectral centroid on GPU
        total_power = sum(power_spectrum);
        if total_power > 0
            freq_features.centroid = gather(sum(freq_pos .* power_spectrum) / total_power);
        else
            freq_features.centroid = 0;
        end
        
    else
        % CPU-only calculation
        N = length(signal);
        dt = time_vector(2) - time_vector(1);
        signal_fft = fft(signal);
        power_spectrum = abs(signal_fft(1:floor(N/2)+1)).^2;
        freq_pos = (0:floor(N/2))' / (N*dt);
        
        % Spectral centroid
        total_power = sum(power_spectrum);
        if total_power > 0
            freq_features.centroid = sum(freq_pos .* power_spectrum) / total_power;
        else
            freq_features.centroid = 0;
        end
    end
    
    % Validate
    if ~isfinite(freq_features.centroid) || isnan(freq_features.centroid)
        freq_features.centroid = 0;
    end
end

%% Simplified load classification score
function score = calculate_load_score_simple(features)
    % Physics-informed load classification using only key parameters
    
    % Impedance scoring (higher impedance more likely legitimate)
    if features.impedance_magnitude > 0
        impedance_score = 1 / (1 + exp(-(features.impedance_magnitude - 1000) / 500));
    else
        impedance_score = 0;
    end
    
    % Power factor scoring (moderate PF more likely legitimate)
    if features.power_factor >= 0.7 && features.power_factor <= 0.95
        pf_score = features.power_factor;
    elseif features.power_factor > 0.95
        pf_score = 0.3; % Very high PF indicates fence
    else
        pf_score = 0.2; % Very low PF unusual
    end
    
    % Reflection coefficient scoring (lower reflection more likely legitimate)
    reflection_magnitude = abs(features.reflection_coeff);
    if reflection_magnitude < 1
        reflection_score = 1 - reflection_magnitude;
    else
        reflection_score = 0;
    end
    
    % Weighted combination (simplified)
    score = 0.4 * impedance_score + 0.35 * pf_score + 0.25 * reflection_score;
    
    % Ensure score is between 0 and 1
    score = max(0, min(1, score));
    
    % Handle edge cases
    if isnan(score) || isinf(score)
        score = 0.5; % Neutral score if calculation fails
    end
end