function [load_impedance, electrical_params, load_type] = generate_load_scenario(is_fence, load_params, tdr_params)
%GENERATE_LOAD_SCENARIO Generate realistic load scenarios for TDR dataset
%
% Inputs:
%   is_fence      - Boolean flag indicating if this is a fence load
%   load_params   - Load parameters structure
%   tdr_params    - TDR parameters structure
%
% Outputs:
%   load_impedance    - Complex load impedance
%   electrical_params - Structure with electrical measurements
%   load_type         - String describing load type

    if is_fence
        % Generate illegal fence load
        R_load = rand() * (load_params.fence.R_max - load_params.fence.R_min) + ...
            load_params.fence.R_min;
        pf = rand() * (load_params.fence.pf_max - load_params.fence.pf_min) + ...
            load_params.fence.pf_min;
        
        % Calculate reactive component for given power factor
        if pf < 1.0
            X_load = R_load * sqrt((1/pf^2) - 1);
        else
            X_load = 0;
        end
        
        load_impedance = R_load + 1j * X_load;
        load_type = 'fence';
        
    else
        % Generate legitimate load (house/commercial)
        load_category = rand();
        
        if load_category < 0.6  % 60% small residential
            R_load = rand() * (3000 - 2500) + 2500;
            pf_range = [0.85, 0.95];
            load_subtype = 'small_residential';
        elseif load_category < 0.9  % 30% medium residential  
            R_load = rand() * (2500 - 1800) + 1800;
            pf_range = [0.75, 0.90];
            load_subtype = 'medium_residential';
        else  % 10% large residential/commercial
            R_load = rand() * (2000 - 1500) + 1500;
            pf_range = [0.70, 0.85];
            load_subtype = 'large_residential';
        end
        
        pf = rand() * (pf_range(2) - pf_range(1)) + pf_range(1);
        X_load = R_load * sqrt((1/pf^2) - 1);
        load_impedance = R_load + 1j * X_load;
        load_type = load_subtype;
    end
    
    % Calculate electrical parameters
    V_rms = 220 + 10 * (rand() - 0.5);  % 220V ± 5V
    I_rms = V_rms / abs(load_impedance);
    P_active = V_rms * I_rms * pf;
    P_reactive = V_rms * I_rms * sqrt(1 - pf^2);
    frequency = 50 + 0.2 * (rand() - 0.5);  % 50Hz ± 0.1Hz
    
    % Add harmonic distortion (simplified)
    if is_fence
        thd = 0.02 + 0.03 * rand();  % 2-5% THD for fences
    else
        thd = 0.03 + 0.05 * rand();  % 3-8% THD for houses
    end
    
    % Add time-varying effects for realistic behavior
    time_variation = 1 + 0.1 * sin(2*pi*rand()); % ±10% variation
    I_rms = I_rms * time_variation;
    P_active = P_active * time_variation;
    
    electrical_params = struct();
    electrical_params.V_rms = V_rms;
    electrical_params.I_rms = I_rms;
    electrical_params.P_active = P_active;
    electrical_params.P_reactive = P_reactive;
    electrical_params.power_factor = pf;
    electrical_params.frequency = frequency;
    electrical_params.thd = thd;
end