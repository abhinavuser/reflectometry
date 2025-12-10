function [incident_pulse, reflected_pulse, time_vector] = simulate_tdr_response(line_length, load_impedance, tdr_params, line_params, env_params)
%SIMULATE_TDR_RESPONSE GPU-accelerated TDR pulse response simulation
%
% Inputs:
%   line_length     - Cable length in meters
%   load_impedance  - Load impedance (complex number)
%   tdr_params      - TDR system parameters structure
%   line_params     - Transmission line parameters structure
%   env_params      - Environmental parameters structure
%
% Outputs:
%   incident_pulse  - Incident TDR pulse waveform
%   reflected_pulse - Reflected TDR pulse waveform
%   time_vector     - Time vector for waveforms

    % Check if GPU is available
    try
        gpu_device = gpuDevice();
        gpu_available = gpu_device.DeviceSupported;
    catch
        gpu_available = false;
    end
    
    % Generate time vector
    dt = 1 / tdr_params.sampling_freq;
    time_vector = (0:dt:(tdr_params.total_duration - dt))';
    
    if gpu_available
        time_vector = gpuArray(single(time_vector));
    end
    
    % Generate incident Gaussian pulse
    t_center = tdr_params.pulse_width * 3;  % Center pulse at 3 sigma
    
    if gpu_available
        incident_pulse = gpuArray(single(tdr_params.pulse_amplitude * ...
            exp(-0.5 * ((time_vector - t_center) / tdr_params.pulse_width).^2)));
    else
        incident_pulse = tdr_params.pulse_amplitude * ...
            exp(-0.5 * ((time_vector - t_center) / tdr_params.pulse_width).^2);
    end
    
    % Calculate reflection coefficient
    rho = (load_impedance - line_params.Z0) / (load_impedance + line_params.Z0);
    
    % Calculate time delay for reflection
    time_delay = 2 * line_length / line_params.v_prop;
    delay_samples = round(time_delay / dt);
    
    % Initialize reflected pulse
    if gpu_available
        reflected_pulse = gpuArray.zeros(size(time_vector), 'single');
    else
        reflected_pulse = zeros(size(time_vector));
    end
    
    % Add reflected pulse with appropriate delay
    if delay_samples > 0 && delay_samples < length(time_vector)
        end_idx = min(length(incident_pulse), length(time_vector) - delay_samples);
        reflected_pulse((delay_samples+1):(delay_samples+end_idx)) = ...
            rho * incident_pulse(1:end_idx);
    end
    
    % Add transmission line effects
    [incident_pulse, reflected_pulse] = add_transmission_effects(...
        incident_pulse, reflected_pulse, line_length, line_params, env_params);
    
    % Add environmental noise
    [incident_pulse, reflected_pulse] = add_environmental_noise(...
        incident_pulse, reflected_pulse, env_params);
    
    % Convert back to CPU if needed
    if gpu_available
        incident_pulse = gather(incident_pulse);
        reflected_pulse = gather(reflected_pulse);
        time_vector = gather(time_vector);
    end
end