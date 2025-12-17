% 04 - Merge Quality Metrics
%
% Authors: Garima Chauhan¹, Kshitij Kumar¹, Deepti Chugh¹, 
%          Subramaniam Ganesh¹, Arjun Ramakrishnan¹,²,#
%
% Affiliations:
%   ¹Department of Biological Sciences & Bioengineering, IIT Kanpur
%   ²Mehta Family Centre for Engineering in Medicine, IIT Kanpur
%   Uttar Pradesh, India, 208016
%   # Corresponding Author: Arjun Ramakrishnan
%
% Description:
%   Merges goodness-of-fit (R²) values from spectral parameterization
%   with central frequency measures. Combines aperiodic fitting metrics
%   with periodic component characteristics for comprehensive quality
%   assessment.
%
% Usage:
%   mergeR2_central_Frequency();
%   % Or with custom data path:
%   mergeR2_central_Frequency('/path/to/data');
%
% Dependencies:
%   - MATLAB Statistics and Machine Learning Toolbox

function mergeR2_central_Frequency(dataPath)
    % Analysis parameters
    R2_THRESHOLD = 0.8;         % Minimum R² value for good fit
    MIN_CENTRAL_FREQ = 0.5;     % Minimum central frequency (Hz)
    MAX_CENTRAL_FREQ = 30;      % Maximum central frequency (Hz)
    
    % Default data path if not provided
    if nargin < 1
        dataPath = fullfile(pwd, 'data');
    end
    
    % Validate input path
    if ~exist(dataPath, 'dir')
        error('Data path does not exist: %s', dataPath);
    end
    
    fprintf('Merging R² and central frequency data from: %s\n', dataPath);
    
    % Get list of subject folders
    subjectFolders = dir(dataPath);
    subjectFolders = subjectFolders([subjectFolders.isdir]);
    % Remove '.' and '..' directories
    subjectFolders = subjectFolders(~ismember({subjectFolders.name}, {'.', '..'}));
    
    if isempty(subjectFolders)
        error('No subject folders found in: %s', dataPath);
    end
    
    fprintf('Found %d subject folder(s) to process\n', length(subjectFolders));
    
    % Initialize storage for merged data across all subjects
    allMergedData = [];
    
    % Process each subject
    for i = 1:length(subjectFolders)
        subjectName = subjectFolders(i).name;
        subjectPath = fullfile(dataPath, subjectName);
        
        fprintf('\n--- Processing Subject: %s ---\n', subjectName);
        
        % Look for R² files
        r2Files = [dir(fullfile(subjectPath, '*r2*.mat')); ...
                   dir(fullfile(subjectPath, '*r2*.csv'))];
        
        % Look for central frequency files
        cfFiles = [dir(fullfile(subjectPath, '*central_freq*.mat')); ...
                   dir(fullfile(subjectPath, '*central_freq*.csv'))];
        
        if isempty(r2Files)
            warning('No R² files found for subject: %s', subjectName);
            continue;
        end
        
        if isempty(cfFiles)
            warning('No central frequency files found for subject: %s', subjectName);
            continue;
        end
        
        % Load R² data
        r2Data = load_data_file(fullfile(subjectPath, r2Files(1).name));
        if isempty(r2Data)
            warning('Failed to load R² data for subject: %s', subjectName);
            continue;
        end
        
        % Load central frequency data
        cfData = load_data_file(fullfile(subjectPath, cfFiles(1).name));
        if isempty(cfData)
            warning('Failed to load central frequency data for subject: %s', subjectName);
            continue;
        end
        
        fprintf('  Loaded R² data: %d entries\n', height(r2Data));
        fprintf('  Loaded central frequency data: %d entries\n', height(cfData));
        
        % Merge data based on common identifier (e.g., filename or time window)
        % Adapt merge key based on your data structure
        if istable(r2Data) && istable(cfData)
            % Try to merge on common column (filename, window_id, etc.)
            commonCols = intersect(r2Data.Properties.VariableNames, ...
                                  cfData.Properties.VariableNames);
            
            if ~isempty(commonCols)
                mergeKey = commonCols{1};
                mergedData = outerjoin(r2Data, cfData, ...
                                      'Keys', mergeKey, ...
                                      'MergeKeys', true);
            else
                % If no common column, assume same order and concatenate
                warning('No common merge key found. Concatenating by row order.');
                mergedData = [r2Data, cfData];
            end
        else
            warning('Data not in table format. Skipping merge for subject: %s', subjectName);
            continue;
        end
        
        % Add subject identifier
        mergedData.subject = repmat({subjectName}, height(mergedData), 1);
        
        % Apply quality filters
        if ismember('r2', mergedData.Properties.VariableNames)
            validIdx = mergedData.r2 >= R2_THRESHOLD;
            fprintf('  Quality filter: %d/%d entries pass R² threshold (%.2f)\n', ...
                    sum(validIdx), height(mergedData), R2_THRESHOLD);
            mergedData = mergedData(validIdx, :);
        end
        
        if ismember('central_frequency', mergedData.Properties.VariableNames)
            validIdx = mergedData.central_frequency >= MIN_CENTRAL_FREQ & ...
                      mergedData.central_frequency <= MAX_CENTRAL_FREQ;
            fprintf('  Frequency filter: %d/%d entries in valid range (%.1f-%.1f Hz)\n', ...
                    sum(validIdx), height(mergedData), MIN_CENTRAL_FREQ, MAX_CENTRAL_FREQ);
            mergedData = mergedData(validIdx, :);
        end
        
        % Save merged data for this subject
        if ~isempty(mergedData)
            outputFileName = sprintf('%s_merged_r2_cf.csv', subjectName);
            outputPath = fullfile(subjectPath, outputFileName);
            writetable(mergedData, outputPath);
            fprintf('  Saved merged data: %s (%d entries)\n', outputFileName, height(mergedData));
            
            % Accumulate for cross-subject analysis
            allMergedData = [allMergedData; mergedData];
        else
            warning('No valid data remaining after filtering for subject: %s', subjectName);
        end
    end
    
    % Save combined data across all subjects
    if ~isempty(allMergedData)
        outputFileName = 'all_subjects_merged_r2_cf.csv';
        outputPath = fullfile(dataPath, outputFileName);
        writetable(allMergedData, outputPath);
        fprintf('\n=== Saved combined data: %s (%d total entries) ===\n', ...
                outputFileName, height(allMergedData));
        
        % Generate summary statistics
        generate_merge_summary(allMergedData);
    else
        warning('No data was successfully merged');
    end
    
    fprintf('\nMerge complete!\n');
end

% Helper function: Load data from MAT or CSV file
function data = load_data_file(filePath)
    data = [];
    
    try
        [~, ~, ext] = fileparts(filePath);
        
        if strcmp(ext, '.mat')
            % Load MAT file
            loadedData = load(filePath);
            % Try to extract table or convert struct to table
            fields = fieldnames(loadedData);
            if istable(loadedData.(fields{1}))
                data = loadedData.(fields{1});
            elseif isstruct(loadedData.(fields{1}))
                data = struct2table(loadedData.(fields{1}));
            end
        elseif strcmp(ext, '.csv')
            % Load CSV file
            data = readtable(filePath);
        else
            warning('Unsupported file format: %s', ext);
        end
    catch ME
        warning('Error loading file %s: %s', filePath, ME.message);
    end
end

% Helper function: Generate summary statistics
function generate_merge_summary(data)
    fprintf('\n=== Summary Statistics ===\n');
    
    if istable(data)
        fprintf('Total entries: %d\n', height(data));
        
        % R² statistics
        if ismember('r2', data.Properties.VariableNames)
            fprintf('\nR² Statistics:\n');
            fprintf('  Mean: %.3f\n', mean(data.r2, 'omitnan'));
            fprintf('  Median: %.3f\n', median(data.r2, 'omitnan'));
            fprintf('  Std: %.3f\n', std(data.r2, 'omitnan'));
            fprintf('  Range: [%.3f, %.3f]\n', min(data.r2), max(data.r2));
        end
        
        % Central frequency statistics
        if ismember('central_frequency', data.Properties.VariableNames)
            fprintf('\nCentral Frequency Statistics:\n');
            fprintf('  Mean: %.2f Hz\n', mean(data.central_frequency, 'omitnan'));
            fprintf('  Median: %.2f Hz\n', median(data.central_frequency, 'omitnan'));
            fprintf('  Std: %.2f Hz\n', std(data.central_frequency, 'omitnan'));
            fprintf('  Range: [%.2f, %.2f] Hz\n', ...
                    min(data.central_frequency), max(data.central_frequency));
        end
        
        % Subject count
        if ismember('subject', data.Properties.VariableNames)
            uniqueSubjects = unique(data.subject);
            fprintf('\nNumber of subjects: %d\n', length(uniqueSubjects));
        end
    end
end
