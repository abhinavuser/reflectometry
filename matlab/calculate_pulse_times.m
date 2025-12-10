function [rise_time, fall_time] = calculate_pulse_times(pulse, time_vector)
%CALCULATE_PULSE_TIMES GPU-accelerated pulse rise/fall time calculation
%
% Inputs:
%   pulse         - Input pulse waveform
%   time_vector   - Time vector for waveform
%
% Outputs:
%   rise_time - 10%-90% rise time
%   fall_time - 90%-10% fall time

    % Check if inputs are GPU arrays
    gpu_available = isa(pulse, 'gpuArray') || isa(time_vector, 'gpuArray');
    
    if gpu_available
        [peak_val, peak_idx] = max(abs(pulse));
        peak_idx = gather(peak_idx);
        peak_val = gather(peak_val);
        
        % Convert to CPU for efficient searching
        pulse_cpu = gather(abs(pulse));
        time_cpu = gather(time_vector);
    else
        [peak_val, peak_idx] = max(abs(pulse));
        pulse_cpu = abs(pulse);
        time_cpu = time_vector;
    end
    
    if peak_val == 0
        rise_time = 0;
        fall_time = 0;
        return;
    end
    
    % Find 10% and 90% levels
    level_10 = 0.1 * peak_val;
    level_90 = 0.9 * peak_val;
    
    % Find rise time (10% to 90%)
    rise_start = find(pulse_cpu(1:peak_idx) >= level_10, 1, 'first');
    rise_end = find(pulse_cpu(1:peak_idx) >= level_90, 1, 'first');
    
    if ~isempty(rise_start) && ~isempty(rise_end) && rise_end > rise_start
        rise_time = time_cpu(rise_end) - time_cpu(rise_start);
    else
        rise_time = 0;
    end
    
    % Find fall time (90% to 10%)
    if peak_idx < length(pulse_cpu)
        fall_start = find(pulse_cpu(peak_idx:end) <= level_90, 1, 'first');
        fall_end = find(pulse_cpu(peak_idx:end) <= level_10, 1, 'first');
        
        if ~isempty(fall_start) && ~isempty(fall_end) && fall_end > fall_start
            fall_start_idx = fall_start + peak_idx - 1;
            fall_end_idx = fall_end + peak_idx - 1;
            
            if fall_end_idx <= length(time_cpu)
                fall_time = time_cpu(fall_end_idx) - time_cpu(fall_start_idx);
            else
                fall_time = 0;
            end
        else
            fall_time = 0;
        end
    else
        fall_time = 0;
    end
    
    % Handle edge cases
    if isnan(rise_time) || isinf(rise_time) || rise_time < 0
        rise_time = 0;
    end
    
    if isnan(fall_time) || isinf(fall_time) || fall_time < 0
        fall_time = 0;
    end
end