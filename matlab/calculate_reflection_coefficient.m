function [rho, delay_time] = calculate_reflection_coefficient(incident_pulse, reflected_pulse, time_vector)
%CALCULATE_REFLECTION_COEFFICIENT GPU-accelerated reflection coefficient calculation
%
% Inputs:
%   incident_pulse  - Incident TDR pulse waveform
%   reflected_pulse - Reflected TDR pulse waveform
%   time_vector     - Time vector for waveforms
%
% Outputs:
%   rho        - Reflection coefficient
%   delay_time - Time delay of reflection

    % Check if inputs are GPU arrays
    gpu_available = isa(incident_pulse, 'gpuArray') || isa(reflected_pulse, 'gpuArray') || isa(time_vector, 'gpuArray');
    
    if gpu_available
        % Find peak locations using GPU
        [~, inc_peak_loc] = max(abs(incident_pulse));
        [~, ref_peak_loc] = max(abs(reflected_pulse));
        
        % Convert indices to scalar values for indexing
        inc_peak_loc = gather(inc_peak_loc);
        ref_peak_loc = gather(ref_peak_loc);
        
        % Calculate reflection coefficient
        if incident_pulse(inc_peak_loc) ~= 0
            rho = gather(reflected_pulse(ref_peak_loc) / incident_pulse(inc_peak_loc));
        else
            rho = 0;
        end
        
        % Calculate delay time
        if ref_peak_loc > inc_peak_loc
            delay_time = gather(time_vector(ref_peak_loc) - time_vector(inc_peak_loc));
        else
            delay_time = 0;
        end
        
    else
        % Find peak locations
        [~, inc_peak_loc] = max(abs(incident_pulse));
        [~, ref_peak_loc] = max(abs(reflected_pulse));
        
        % Calculate reflection coefficient
        if incident_pulse(inc_peak_loc) ~= 0
            rho = reflected_pulse(ref_peak_loc) / incident_pulse(inc_peak_loc);
        else
            rho = 0;
        end
        
        % Calculate delay time
        if ref_peak_loc > inc_peak_loc
            delay_time = time_vector(ref_peak_loc) - time_vector(inc_peak_loc);
        else
            delay_time = 0;
        end
    end
    
    % Handle edge cases
    if isnan(rho) || isinf(rho)
        rho = 0;
    end
    
    if isnan(delay_time) || isinf(delay_time) || delay_time < 0
        delay_time = 0;
    end
end