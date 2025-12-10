function [incident_pulse, reflected_pulse] = add_transmission_effects(incident_pulse, reflected_pulse, line_length, line_params, env_params)
%ADD_TRANSMISSION_EFFECTS GPU-accelerated transmission line effects
%
% Inputs:
%   incident_pulse  - Original incident pulse
%   reflected_pulse - Original reflected pulse
%   line_length     - Cable length in meters
%   line_params     - Transmission line parameters structure
%   env_params      - Environmental parameters structure
%
% Outputs:
%   incident_pulse  - Modified incident pulse with transmission effects
%   reflected_pulse - Modified reflected pulse with transmission effects

    % Check if inputs are GPU arrays
    gpu_available = isa(incident_pulse, 'gpuArray') || isa(reflected_pulse, 'gpuArray');
    
    % Add attenuation due to cable resistance and dielectric losses
    
    % Create frequency vector for attenuation calculation
    N = length(incident_pulse);
    
    if gpu_available
        freq = gpuArray(single(linspace(0, 500e6, N)'));  % Frequency vector
        
        % Attenuation coefficient (simplified model)
        alpha = gpuArray(single(0.1 * sqrt(freq/1e6) * line_length / 1000));  % dB/km to linear
        alpha_linear = 10.^(-alpha/20);
        
        % Apply attenuation in frequency domain using GPU FFT
        incident_fft = fft(incident_pulse);
        reflected_fft = fft(reflected_pulse);
        
        % Apply frequency-dependent attenuation
        incident_fft = incident_fft .* alpha_linear;
        reflected_fft = reflected_fft .* alpha_linear;
        
        incident_pulse = real(ifft(incident_fft));
        reflected_pulse = real(ifft(reflected_fft));
        
    else
        freq = linspace(0, 500e6, N);  % Frequency vector
        
        % Attenuation coefficient (simplified model)
        alpha = 0.1 * sqrt(freq/1e6) * line_length / 1000;  % dB/km to linear
        alpha_linear = 10.^(-alpha/20);
        
        % Apply attenuation in frequency domain
        incident_fft = fft(incident_pulse);
        reflected_fft = fft(reflected_pulse);
        
        % Apply frequency-dependent attenuation
        if length(alpha_linear) == length(incident_fft)
            incident_fft = incident_fft .* alpha_linear';
            reflected_fft = reflected_fft .* alpha_linear';
        end
        
        incident_pulse = real(ifft(incident_fft));
        reflected_pulse = real(ifft(reflected_fft));
    end
    
    % Add temperature effects
    temp_variation = rand() * (env_params.temperature_range(2) - env_params.temperature_range(1)) + ...
        env_params.temperature_range(1);
    temp_factor = 1 + 0.02 * (temp_variation - 20) / 40;  % ±2% variation
    
    if gpu_available
        temp_factor = gpuArray(single(temp_factor));
    end
    
    incident_pulse = incident_pulse * temp_factor;
    reflected_pulse = reflected_pulse * temp_factor;
    
    % Add humidity effects
    humidity_factor = 1 + env_params.humidity_effect * (2*rand() - 1);
    
    if gpu_available
        humidity_factor = gpuArray(single(humidity_factor));
    end
    
    incident_pulse = incident_pulse * humidity_factor;
    reflected_pulse = reflected_pulse * humidity_factor;
end