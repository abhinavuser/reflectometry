function [incident_pulse, reflected_pulse] = add_environmental_noise(incident_pulse, reflected_pulse, env_params)
%ADD_ENVIRONMENTAL_NOISE GPU-accelerated environmental noise addition
%
% Inputs:
%   incident_pulse  - Original incident pulse
%   reflected_pulse - Original reflected pulse
%   env_params      - Environmental parameters structure
%
% Outputs:
%   incident_pulse  - Noisy incident pulse
%   reflected_pulse - Noisy reflected pulse

    % Check if inputs are GPU arrays
    gpu_available = isa(incident_pulse, 'gpuArray') || isa(reflected_pulse, 'gpuArray');
    
    % Select random SNR within range
    snr_db = rand() * (env_params.snr_range(2) - env_params.snr_range(1)) + ...
        env_params.snr_range(1);
    
    % Calculate signal power and noise power for incident pulse
    if gpu_available
        signal_power_inc = mean(incident_pulse.^2);
        signal_power_ref = mean(reflected_pulse.^2);
    else
        signal_power_inc = mean(incident_pulse.^2);
        signal_power_ref = mean(reflected_pulse.^2);
    end
    
    noise_power_inc = signal_power_inc / (10^(snr_db/10));
    noise_power_ref = signal_power_ref / (10^(snr_db/10));
    
    % Add Gaussian noise
    if gpu_available
        noise_incident = sqrt(noise_power_inc) * gpuArray.randn(size(incident_pulse), 'single');
        noise_reflected = sqrt(noise_power_ref) * gpuArray.randn(size(reflected_pulse), 'single');
    else
        noise_incident = sqrt(noise_power_inc) * randn(size(incident_pulse));
        noise_reflected = sqrt(noise_power_ref) * randn(size(reflected_pulse));
    end
    
    incident_pulse = incident_pulse + noise_incident;
    reflected_pulse = reflected_pulse + noise_reflected;
    
    % Add EMI interference (substation environment)
    % 50 Hz power line interference
    N = length(incident_pulse);
    
    if gpu_available
        time_vector = gpuArray(single((0:N-1)' / 1e9));  % Assuming 1 GHz sampling
        emi_50hz = gpuArray(single(0.05 * sin(2*pi*50*time_vector)));   % 50 Hz interference
        emi_150hz = gpuArray(single(0.02 * sin(2*pi*150*time_vector))); % 3rd harmonic
    else
        time_vector = (0:N-1)' / 1e9;  % Assuming 1 GHz sampling
        emi_50hz = 0.05 * sin(2*pi*50*time_vector);   % 50 Hz interference
        emi_150hz = 0.02 * sin(2*pi*150*time_vector); % 3rd harmonic
    end
    
    incident_pulse = incident_pulse + emi_50hz + emi_150hz;
    reflected_pulse = reflected_pulse + emi_50hz + emi_150hz;
    
    % Add random switching noise spikes (typical in substations)
    if rand() < 0.1  % 10% chance of switching spike
        spike_location = randi(max(1, N-20)) + 10; % Ensure spike fits within array
        spike_amplitude = 0.1 * randn();
        
        if gpu_available
            spike_amplitude = gpuArray(single(spike_amplitude));
        end
        
        spike_end = min(spike_location + 10, N);
        spike_indices = spike_location:spike_end;
        incident_pulse(spike_indices) = incident_pulse(spike_indices) + spike_amplitude;
        reflected_pulse(spike_indices) = reflected_pulse(spike_indices) + spike_amplitude;
    end
end