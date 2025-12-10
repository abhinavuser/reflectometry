function score = calculate_load_score(features)
%CALCULATE_LOAD_SCORE Physics-informed load classification score
%
% Inputs:
%   features - Structure containing extracted features
%
% Outputs:
%   score - Load classification score (0-1, higher = more likely legitimate load)

    % Initialize score components
    impedance_score = 0;
    pf_score = 0;
    reflection_score = 0;
    energy_score = 0;
    
    % Impedance magnitude scoring (higher impedance more likely legitimate)
    if features.impedance_magnitude > 0
        impedance_score = 1 / (1 + exp(-(features.impedance_magnitude - 1000) / 500));
    end
    
    % Power factor scoring (moderate power factor more likely legitimate)
    if features.power_factor >= 0.7 && features.power_factor <= 0.95
        pf_score = features.power_factor;
    elseif features.power_factor > 0.95
        pf_score = 0.5; % Very high PF might indicate fence
    else
        pf_score = 0.3; % Very low PF unusual
    end
    
    % Reflection coefficient scoring (lower reflection more likely legitimate)
    reflection_magnitude = abs(features.reflection_coeff);
    if reflection_magnitude < 1
        reflection_score = 1 - reflection_magnitude;
    else
        reflection_score = 0;
    end
    
    % Energy ratio scoring
    if features.incident_energy > 0
        energy_ratio = features.reflected_energy / features.incident_energy;
        if energy_ratio < 0.5
            energy_score = 1 - energy_ratio;
        else
            energy_score = 0.3; % High reflection might indicate fence
        end
    end
    
    % Time delay scoring (reasonable delay more likely legitimate)
    time_delay_score = 0;
    if features.time_delay > 1e-6 && features.time_delay < 100e-6 % 1-100 μs reasonable range
        time_delay_score = 0.8;
    elseif features.time_delay > 0
        time_delay_score = 0.5;
    end
    
    % Frequency content scoring
    freq_score = 0;
    if features.spectral_flatness > 0.1 && features.spectral_flatness < 0.9
        freq_score = 0.7; % Moderate flatness indicates normal load
    else
        freq_score = 0.3;
    end
    
    % Weighted combination of scores
    weights = [0.25, 0.20, 0.20, 0.15, 0.10, 0.10]; % Must sum to 1
    scores = [impedance_score, pf_score, reflection_score, energy_score, time_delay_score, freq_score];
    
    score = sum(weights .* scores);
    
    % Ensure score is between 0 and 1
    score = max(0, min(1, score));
    
    % Handle edge cases
    if isnan(score) || isinf(score)
        score = 0.5; % Neutral score if calculation fails
    end
end