function freq_features = calculate_frequency_features(signal, time_vector)
%CALCULATE_FREQUENCY_FEATURES GPU-accelerated frequency domain features
%
% Inputs:
%   signal        - Input signal
%   time_vector   - Time vector for signal
%
% Outputs:
%   freq_features - Structure with frequency domain features

    freq_features = struct();
    
    % Check if inputs are GPU arrays
    gpu_available = isa(signal, 'gpuArray') || isa(time_vector, 'gpuArray');
    
    % Reduce data size to first 1024 samples for FFT efficiency
    max_samples = 1024;
    N0 = min(length(signal), max_samples);
    
    if gpu_available
        signal = signal(1:N0);
        time_vector = time_vector(1:N0);
        
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
        
        % Bandwidth calculation on GPU
        if total_power > 0
            max_power = max(power_spectrum);
            half_power = max_power / 2;
            half_power_mask = power_spectrum >= half_power;
            idx = find(gather(half_power_mask));
            
            if numel(idx) >= 2
                freq_pos_cpu = gather(freq_pos);
                freq_features.bandwidth = freq_pos_cpu(idx(end)) - freq_pos_cpu(idx(1));
            else
                freq_features.bandwidth = 0;
            end
        else
            freq_features.bandwidth = 0;
        end
        
        % Spectral flatness calculation
        power_cpu = gather(power_spectrum);
        non_zero = power_cpu(power_cpu > eps);
        if numel(non_zero) > 1
            geom_mean = exp(mean(log(non_zero)));
            arith_mean = mean(non_zero);
            freq_features.flatness = geom_mean / arith_mean;
        else
            freq_features.flatness = 0;
        end
        
        % Dominant frequency
        [~, max_idx] = max(power_spectrum);
        max_idx = gather(max_idx);
        freq_pos_cpu = gather(freq_pos);
        freq_features.dominant_frequency = freq_pos_cpu(max_idx);
        
        % Spectral rolloff (85%)
        if total_power > 0
            cum_power = cumsum(power_spectrum);
            rolloff_threshold = 0.85 * total_power;
            roll_mask = cum_power >= rolloff_threshold;
            roll_idx = find(gather(roll_mask), 1);
            
            if ~isempty(roll_idx)
                freq_features.spectral_rolloff = freq_pos_cpu(roll_idx);
            else
                freq_features.spectral_rolloff = freq_pos_cpu(end);
            end
        else
            freq_features.spectral_rolloff = 0;
        end
        
    else
        % CPU-only calculation
        signal = signal(1:N0);
        time_vector = time_vector(1:N0);
        
        % Perform CPU FFT
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
        
        % Bandwidth (3dB bandwidth)
        if total_power > 0
            max_power = max(power_spectrum);
            half_power = max_power / 2;
            idx = find(power_spectrum >= half_power);
            if numel(idx) >= 2
                freq_features.bandwidth = freq_pos(idx(end)) - freq_pos(idx(1));
            else
                freq_features.bandwidth = 0;
            end
        else
            freq_features.bandwidth = 0;
        end
        
        % Spectral flatness
        non_zero = power_spectrum(power_spectrum > eps);
        if numel(non_zero) > 1
            geom_mean = exp(mean(log(non_zero)));
            arith_mean = mean(non_zero);
            freq_features.flatness = geom_mean / arith_mean;
        else
            freq_features.flatness = 0;
        end
        
        % Dominant frequency
        [~, max_idx] = max(power_spectrum);
        freq_features.dominant_frequency = freq_pos(max_idx);
        
        % Spectral rolloff (85%)
        if total_power > 0
            cum_power = cumsum(power_spectrum);
            roll_idx = find(cum_power >= 0.85 * total_power, 1);
            if ~isempty(roll_idx)
                freq_features.spectral_rolloff = freq_pos(roll_idx);
            else
                freq_features.spectral_rolloff = freq_pos(end);
            end
        else
            freq_features.spectral_rolloff = 0;
        end
    end
    
    % Validate fields
    fields = fieldnames(freq_features);
    for i = 1:length(fields)
        val = freq_features.(fields{i});
        if ~isfinite(val) || isnan(val)
            freq_features.(fields{i}) = 0;
        end
    end
end