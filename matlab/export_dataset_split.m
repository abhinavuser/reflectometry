function export_dataset_split(dataset, indices, split_name)
%EXPORT_DATASET_SPLIT Export dataset split to files
%
% Inputs:
%   dataset    - Complete dataset structure
%   indices    - Indices for this split
%   split_name - Name of split ('train', 'validation', 'test')

    % Extract data for this split
    features = dataset.features(indices, :);
    labels = dataset.labels(indices);
    incident_waveforms = dataset.waveforms.incident(indices, :);
    reflected_waveforms = dataset.waveforms.reflected(indices, :);
    
    % Ensure labels is a column vector and matches feature table size
    labels = labels(:);  % Convert to column vector
    
    % Create feature table with proper dimensions
    feature_table = array2table(features, 'VariableNames', dataset.feature_names);
    
    % Check dimensions before assignment
    if length(labels) == height(feature_table)
        feature_table.label = labels;
    else
        error('Dimension mismatch: labels length (%d) != feature table height (%d)', ...
            length(labels), height(feature_table));
    end
    
    % Export features and labels
    filename = sprintf('synthetic_tdr_dataset/%s/%s_features.csv', split_name, split_name);
    writetable(feature_table, filename);
    
    % Export waveforms as MAT files
    waveforms = struct();
    waveforms.incident = incident_waveforms;
    waveforms.reflected = reflected_waveforms;
    waveforms.labels = labels;
    waveforms.sample_indices = indices; % Keep track of original indices
    
    waveform_filename = sprintf('synthetic_tdr_dataset/%s/%s_waveforms.mat', split_name, split_name);
    save(waveform_filename, 'waveforms');
    
    % Export metadata for this split
    split_metadata = struct();
    split_metadata.num_samples = length(indices);
    split_metadata.num_legitimate = sum(labels == 0);
    split_metadata.num_fence = sum(labels == 1);
    split_metadata.legitimate_ratio = sum(labels == 0) / length(labels);
    split_metadata.fence_ratio = sum(labels == 1) / length(labels);
    
    % Calculate feature statistics for this split
    split_metadata.feature_stats = struct();
    for i = 1:length(dataset.feature_names)
        feat_name = dataset.feature_names{i};
        split_metadata.feature_stats.(feat_name).mean = mean(features(:, i));
        split_metadata.feature_stats.(feat_name).std = std(features(:, i));
        split_metadata.feature_stats.(feat_name).min = min(features(:, i));
        split_metadata.feature_stats.(feat_name).max = max(features(:, i));
    end
    
    metadata_filename = sprintf('synthetic_tdr_dataset/%s/%s_metadata.mat', split_name, split_name);
    save(metadata_filename, 'split_metadata');
    
    fprintf('Exported %s split: %d samples (%d legitimate, %d fence)\n', ...
        split_name, length(indices), sum(labels == 0), sum(labels == 1));
end