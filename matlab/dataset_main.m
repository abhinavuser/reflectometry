%% Synthetic TDR Dataset Generation - Main Script (Optimized for Essential Features)
% Purpose: Generate physics-accurate synthetic TDR dataset with only essential features
% Author: Your Name
% Date: September 23, 2025

clear all; close all; clc;

%% GPU and Parallel Setup
fprintf('Setting up GPU and Parallel Computing...\n');
try
    % Initialize parallel pool if not already running
    if isempty(gcp('nocreate'))
        parpool('local');
        fprintf('Parallel pool initialized.\n');
    end
    
    % Initialize GPU
    gpu_device = gpuDevice(1);
    fprintf('GPU Device: %s\n', gpu_device.Name);
    fprintf('GPU Memory: %.1f GB\n', gpu_device.TotalMemory/1e9);
    
    gpu_available = true;
catch ME
    fprintf('Warning: GPU/Parallel setup failed: %s\n', ME.message);
    fprintf('Continuing with CPU-only computation...\n');
    gpu_available = false;
end

%% Add function files to path (ensure all .m files are in same directory)
fprintf('Starting Synthetic TDR Dataset Generation...\n');

%% Step 1: Initialize Parameters
fprintf('Step 1: Initializing parameters...\n');

% Dataset Parameters
dataset_params = struct();
dataset_params.total_samples = 60000;
dataset_params.legitimate_ratio = 0.85;  % 85% legitimate loads
dataset_params.train_ratio = 0.70;       % 70% training data
dataset_params.val_ratio = 0.15;         % 15% validation data
dataset_params.test_ratio = 0.15;        % 15% test data

% TDR System Parameters - REALISTIC FOR 440V SUBSTATION
tdr_params = struct();
tdr_params.pulse_freq = 20000;           % 20 kHz pulse repetition rate
tdr_params.pulse_interval = 1/tdr_params.pulse_freq;  % 50 μs
tdr_params.sampling_freq = 1e9;          % 1 GHz sampling rate
tdr_params.samples_per_pulse = 1024;     % Samples per TDR pulse
tdr_params.pulse_width = 100e-9;         % 100 ns Gaussian pulse width
tdr_params.pulse_amplitude = 1.0;        % 1V pulse amplitude (LOW VOLTAGE)
tdr_params.total_duration = 5e-6;        % 5 μs total signal duration

% Transmission Line Parameters - REALISTIC FOR POWER DISTRIBUTION
line_params = struct();
line_params.Z0 = 50;                     % Characteristic impedance (Ohms)
line_params.velocity_factor = 0.67;      % Velocity factor for power cables
line_params.c = 3e8;                     % Speed of light
line_params.v_prop = line_params.velocity_factor * line_params.c;  % Propagation velocity
line_params.min_length = 100;            % Minimum cable length (m) - More realistic
line_params.max_length = 5000;           % Maximum cable length (m) - Typical distribution

% Load Parameters - PHYSICS-ACCURATE FOR 440V SYSTEM
load_params = struct();
% Legitimate loads (houses/commercial at 440V)
load_params.house.R_min = 800;           % Minimum house resistance at 440V
load_params.house.R_max = 2000;          % Maximum house resistance at 440V  
load_params.house.pf_min = 0.70;         % Minimum power factor
load_params.house.pf_max = 0.95;         % Maximum power factor

% Illegal fence loads (direct taps at 440V)
load_params.fence.R_min = 20;            % Minimum fence resistance (direct tap)
load_params.fence.R_max = 150;           % Maximum fence resistance
load_params.fence.pf_min = 0.95;         % Minimum power factor (resistive)
load_params.fence.pf_max = 1.0;          % Maximum power factor

% Environmental Parameters - REALISTIC FOR SUBSTATION
env_params = struct();
env_params.temperature_range = [-10, 50]; % Temperature range (°C) - Typical substation
env_params.snr_range = [35, 55];          % SNR range (dB) - More realistic with EMI
env_params.humidity_effect = 0.01;        % ±1% humidity variation

fprintf('Parameters initialized successfully.\n');
fprintf('System configured for 440V distribution with physics-accurate load ranges.\n');

%% Step 2: Initialize Dataset Storage
fprintf('Step 2: Initializing dataset storage...\n');

% Calculate number of samples for each class
num_legitimate = round(dataset_params.total_samples * dataset_params.legitimate_ratio);
num_fence = dataset_params.total_samples - num_legitimate;

fprintf('Generating %d legitimate samples and %d fence samples...\n', ...
    num_legitimate, num_fence);

% Pre-allocate arrays for better performance
total_samples = dataset_params.total_samples;
samples_per_pulse = tdr_params.samples_per_pulse;

% Pre-generate all random parameters for better GPU utilization
rng(42); % Set seed for reproducibility

cable_lengths = rand(total_samples, 1) * (line_params.max_length - line_params.min_length) + line_params.min_length;
is_fence_array = false(total_samples, 1);
is_fence_array((num_legitimate+1):end) = true;

% Shuffle to mix fence and legitimate samples
shuffle_idx = randperm(total_samples);
is_fence_array = is_fence_array(shuffle_idx);
cable_lengths = cable_lengths(shuffle_idx);

%% Step 3: Main Dataset Generation Loop (Optimized)
fprintf('Step 3: Starting optimized dataset generation (12 essential features only)...\n');

% Pre-allocate storage
if gpu_available
    waveforms_incident = zeros(total_samples, samples_per_pulse, 'single');
    waveforms_reflected = zeros(total_samples, samples_per_pulse, 'single');
else
    waveforms_incident = zeros(total_samples, samples_per_pulse);
    waveforms_reflected = zeros(total_samples, samples_per_pulse);
end

labels = zeros(total_samples, 1);
metadata_struct = struct('cable_length', cell(total_samples, 1), ...
                        'load_type', cell(total_samples, 1), ...
                        'load_impedance', cell(total_samples, 1));

% Store feature data in cell array for parfor compatibility
features_cell = cell(total_samples, 1);

% Use sequential processing for ordered progress (change to parfor for speed)
progress_interval = round(total_samples / 100);  % Update every 1%

for sample_idx = 1:total_samples
    % Generate load scenario
    [load_impedance, electrical_params, load_type] = generate_load_scenario(...
        is_fence_array(sample_idx), load_params, tdr_params);
    
    % Simulate TDR response
    [incident_pulse, reflected_pulse, time_vector] = simulate_tdr_response(...
        cable_lengths(sample_idx), load_impedance, tdr_params, line_params, env_params);
    
    % Extract ONLY essential features (12 instead of 35)
    features = extract_tdr_features(incident_pulse, reflected_pulse, ...
        electrical_params, time_vector, line_params);
    
    % Store features
    features_cell{sample_idx} = features;
    
    % Store waveforms (ensure proper size)
    if length(incident_pulse) >= samples_per_pulse
        waveforms_incident(sample_idx, :) = single(incident_pulse(1:samples_per_pulse));
        waveforms_reflected(sample_idx, :) = single(reflected_pulse(1:samples_per_pulse));
    else
        padded_incident = [incident_pulse; zeros(samples_per_pulse - length(incident_pulse), 1)];
        padded_reflected = [reflected_pulse; zeros(samples_per_pulse - length(reflected_pulse), 1)];
        waveforms_incident(sample_idx, :) = single(padded_incident);
        waveforms_reflected(sample_idx, :) = single(padded_reflected);
    end
    
    % Store labels and metadata
    labels(sample_idx) = double(is_fence_array(sample_idx));
    metadata_struct(sample_idx).cable_length = cable_lengths(sample_idx);
    metadata_struct(sample_idx).load_type = load_type;
    metadata_struct(sample_idx).load_impedance = load_impedance;
    
    % Sequential progress update
    if mod(sample_idx, progress_interval) == 0
        fprintf('Progress: %d%% (%d/%d samples)\n', ...
            round(100 * sample_idx / total_samples), sample_idx, total_samples);
    end
end

%% Step 4: Convert Features Cell Array to Matrix
fprintf('Step 4: Converting features to matrix format...\n');

% Get feature names from first sample
if ~isempty(features_cell{1})
    feature_names = fieldnames(features_cell{1});
    num_features = length(feature_names);
    
    fprintf('Generated %d essential features: ', num_features);
    fprintf('%s ', feature_names{:});
    fprintf('\n');
    
    % Pre-allocate features matrix
    features_matrix = zeros(total_samples, num_features);
    
    % Fill features matrix
    for sample_idx = 1:total_samples
        if ~isempty(features_cell{sample_idx})
            for feat_idx = 1:num_features
                features_matrix(sample_idx, feat_idx) = features_cell{sample_idx}.(feature_names{feat_idx});
            end
        end
    end
else
    error('Feature extraction failed for all samples');
end

% Create dataset structure
dataset = struct();
dataset.features = features_matrix;
dataset.labels = labels;
dataset.feature_names = feature_names;
dataset.waveforms = struct();
dataset.waveforms.incident = waveforms_incident;
dataset.waveforms.reflected = waveforms_reflected;
dataset.metadata = metadata_struct;

fprintf('Dataset generation completed!\n');

%% Step 5: Split Dataset
fprintf('Step 5: Splitting dataset...\n');

% Create stratified split
legitimate_idx = find(dataset.labels == 0);
fence_idx = find(dataset.labels == 1);

% Shuffle indices
legitimate_idx = legitimate_idx(randperm(length(legitimate_idx)));
fence_idx = fence_idx(randperm(length(fence_idx)));

% Split legitimate samples
leg_train_size = round(length(legitimate_idx) * dataset_params.train_ratio);
leg_val_size = round(length(legitimate_idx) * dataset_params.val_ratio);

train_leg_idx = legitimate_idx(1:leg_train_size);
val_leg_idx = legitimate_idx(leg_train_size+1:leg_train_size+leg_val_size);
test_leg_idx = legitimate_idx(leg_train_size+leg_val_size+1:end);

% Split fence samples
fence_train_size = round(length(fence_idx) * dataset_params.train_ratio);
fence_val_size = round(length(fence_idx) * dataset_params.val_ratio);

train_fence_idx = fence_idx(1:fence_train_size);
val_fence_idx = fence_idx(fence_train_size+1:fence_train_size+fence_val_size);
test_fence_idx = fence_idx(fence_train_size+fence_val_size+1:end);

% Combine indices
train_idx = [train_leg_idx; train_fence_idx];
val_idx = [val_leg_idx; val_fence_idx];
test_idx = [test_leg_idx; test_fence_idx];

% Shuffle combined indices
train_idx = train_idx(randperm(length(train_idx)));
val_idx = val_idx(randperm(length(val_idx)));
test_idx = test_idx(randperm(length(test_idx)));

fprintf('Dataset split: Train=%d, Val=%d, Test=%d\n', ...
    length(train_idx), length(val_idx), length(test_idx));

%% Step 6: Export Dataset
fprintf('Step 6: Exporting dataset...\n');

% Create directory structure
if ~exist('synthetic_tdr_dataset', 'dir')
    mkdir('synthetic_tdr_dataset');
    mkdir('synthetic_tdr_dataset/train');
    mkdir('synthetic_tdr_dataset/validation');
    mkdir('synthetic_tdr_dataset/test');
    mkdir('synthetic_tdr_dataset/metadata');
end

% Export splits
export_dataset_split(dataset, train_idx, 'train');
export_dataset_split(dataset, val_idx, 'validation');
export_dataset_split(dataset, test_idx, 'test');

% Export metadata
metadata = struct();
metadata.dataset_params = dataset_params;
metadata.tdr_params = tdr_params;
metadata.line_params = line_params;
metadata.load_params = load_params;
metadata.env_params = env_params;
metadata.feature_names = dataset.feature_names;
metadata.generation_date = datestr(now);
metadata.gpu_used = gpu_available;
metadata.physics_accurate = true;
metadata.system_voltage = 440; % V
metadata.num_features = num_features;
if gpu_available
    metadata.gpu_info = gpu_device;
end

save('synthetic_tdr_dataset/metadata/generation_metadata.mat', 'metadata');

% Export summary statistics
summary_stats = struct();
summary_stats.total_samples = dataset_params.total_samples;
summary_stats.legitimate_samples = sum(dataset.labels == 0);
summary_stats.fence_samples = sum(dataset.labels == 1);
summary_stats.feature_statistics = array2table([mean(dataset.features); std(dataset.features); ...
    min(dataset.features); max(dataset.features)], ...
    'VariableNames', dataset.feature_names, ...
    'RowNames', {'Mean', 'Std', 'Min', 'Max'});

save('synthetic_tdr_dataset/metadata/summary_statistics.mat', 'summary_stats');
writetable(summary_stats.feature_statistics, 'synthetic_tdr_dataset/metadata/feature_statistics.csv');

%% Step 7: Generate Validation Plots
fprintf('Step 7: Generating validation plots...\n');
generate_validation_plots();

%% Cleanup
if gpu_available
    reset(gpuDevice);
    fprintf('GPU memory cleared.\n');
end

%% Final Summary
fprintf('\n=== OPTIMIZED DATASET GENERATION COMPLETE ===\n');
fprintf('Total samples generated: %d\n', dataset_params.total_samples);
fprintf('Legitimate loads: %d (%.1f%%)\n', sum(dataset.labels == 0), 100*sum(dataset.labels == 0)/dataset_params.total_samples);
fprintf('Fence loads: %d (%.1f%%)\n', sum(dataset.labels == 1), 100*sum(dataset.labels == 1)/dataset_params.total_samples);
fprintf('Essential features generated: %d (vs 35 previously)\n', num_features);
fprintf('System configured for 440V with physics-accurate parameters\n');
fprintf('GPU acceleration: %s\n', char("ENABLED" * gpu_available + "DISABLED" * ~gpu_available));
fprintf('Files exported to: ./synthetic_tdr_dataset/\n');
fprintf('Dataset generation completed successfully!\n');