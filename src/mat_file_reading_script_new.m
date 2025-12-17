% MAT File Reading and Processing Script
%
% Author: Kshitij Kumar
% Department of Biological Sciences & Bioengineering, IIT Kanpur
% Uttar Pradesh, India, 208016
%
% Description:
%   Reads MAT files containing processed EEG data and extracts relevant
%   features for further analysis. Handles multiple subjects and conditions,
%   organizing data for statistical analysis and visualization.
%
% Input:
%   - dataPath: Path to directory containing subject folders with MAT files
%   - outputPath: Path where processed results will be saved
%
% Output:
%   - Consolidated MAT file with extracted features
%   - CSV files with summary statistics
%   - Processed data structure for downstream analysis
%
% Usage:
%   mat_file_reading_script_new();
%   % Or with custom paths:
%   mat_file_reading_script_new('/path/to/data', '/path/to/output');
%
% File Organization:
%   Expected directory structure:
%   dataPath/
%     ├── Subject01/
%     │   ├── data_file1.mat
%     │   └── data_file2.mat
%     ├── Subject02/
%     │   ├── data_file1.mat
%     │   └── data_file2.mat
%     └── ...
%
% Dependencies:
%   - MATLAB base installation
%   - Statistics and Machine Learning Toolbox (optional, for advanced stats)

function mat_file_reading_script_new(dataPath, outputPath)
    % Analysis parameters
    EXPECTED_CHANNELS = 19;     % Expected number of EEG channels
    WINDOW_LENGTH_SEC = 30;     % Time window length in seconds
    
    % Default parameters if not provided
    if nargin < 1
        dataPath = fullfile(pwd, 'data');
    end
    
    if nargin < 2
        outputPath = fullfile(pwd, 'results');
    end
    
    % Validate input directory exists
    if ~exist(dataPath, 'dir')
        error('Data path does not exist: %s', dataPath);
    end
    
    % Create output directory if it doesn't exist
    if ~exist(outputPath, 'dir')
        mkdir(outputPath);
        fprintf('Created output directory: %s\n', outputPath);
    end
    
    fprintf('Reading MAT files from: %s\n', dataPath);
    fprintf('Output will be saved to: %s\n', outputPath);
    
    % Get list of subject folders
    subjectFolders = dir(dataPath);
    subjectFolders = subjectFolders([subjectFolders.isdir]);
    % Remove '.' and '..' directories
    subjectFolders = subjectFolders(~ismember({subjectFolders.name}, {'.', '..'}));
    
    if isempty(subjectFolders)
        error('No subject folders found in: %s', dataPath);
    end
    
    fprintf('Found %d subject folder(s)\n', length(subjectFolders));
    
    % Initialize data storage structure
    allSubjectsData = struct();
    
    % Process each subject folder
    for i = 1:length(subjectFolders)
        subjectName = subjectFolders(i).name;
        subjectFolder = fullfile(dataPath, subjectName);
        
        fprintf('\n--- Processing Subject: %s ---\n', subjectName);
        
        % Get all MAT files in the subject folder
        matFiles = dir(fullfile(subjectFolder, '*.mat'));
        
        if isempty(matFiles)
            warning('No MAT files found for subject: %s', subjectName);
            continue;
        end
        
        fprintf('Found %d MAT file(s)\n', length(matFiles));
        
        % Initialize subject data structure
        subjectData = struct();
        subjectData.name = subjectName;
        subjectData.numFiles = length(matFiles);
        subjectData.files = cell(length(matFiles), 1);
        
        % Process each MAT file
        for j = 1:length(matFiles)
            matFileName = matFiles(j).name;
            matFilePath = fullfile(subjectFolder, matFileName);
            
            fprintf('  Reading file %d/%d: %s\n', j, length(matFiles), matFileName);
            
            try
                % Load the MAT file
                loadedData = load(matFilePath);
                
                % Extract relevant fields (adapt based on your data structure)
                fileData = struct();
                fileData.filename = matFileName;
                
                % Common field names to look for
                % Adapt these based on your actual MAT file structure
                if isfield(loadedData, 'data')
                    fileData.data = loadedData.data;
                end
                
                if isfield(loadedData, 'time')
                    fileData.time = loadedData.time;
                end
                
                if isfield(loadedData, 'channels')
                    fileData.channels = loadedData.channels;
                    fileData.numChannels = length(loadedData.channels);
                else
                    fileData.numChannels = 0;
                end
                
                if isfield(loadedData, 'samplingRate')
                    fileData.samplingRate = loadedData.samplingRate;
                end
                
                if isfield(loadedData, 'power_spectrum')
                    fileData.powerSpectrum = loadedData.power_spectrum;
                end
                
                if isfield(loadedData, 'frequencies')
                    fileData.frequencies = loadedData.frequencies;
                end
                
                % Store file information
                subjectData.files{j} = fileData;
                
                fprintf('    Successfully loaded\n');
                
            catch ME
                warning('Error loading file %s: %s', matFileName, ME.message);
                subjectData.files{j} = struct('filename', matFileName, 'error', ME.message);
            end
        end
        
        % Store subject data
        allSubjectsData.(matlab.lang.makeValidName(subjectName)) = subjectData;
        
        fprintf('Completed processing for subject: %s\n', subjectName);
    end
    
    % Save consolidated results
    outputFileName = 'all_subjects_data.mat';
    outputFilePath = fullfile(outputPath, outputFileName);
    save(outputFilePath, 'allSubjectsData', '-v7.3');
    fprintf('\nSaved consolidated data to: %s\n', outputFilePath);
    
    % Generate summary report
    generate_summary_report(allSubjectsData, outputPath);
    
    fprintf('\nProcessing complete!\n');
end

% Helper function: Generate summary report
function generate_summary_report(allSubjectsData, outputPath)
    fprintf('\n=== Summary Report ===\n');
    
    subjectNames = fieldnames(allSubjectsData);
    numSubjects = length(subjectNames);
    
    fprintf('Total subjects processed: %d\n', numSubjects);
    
    % Create summary table
    summaryData = cell(numSubjects, 3);
    
    for i = 1:numSubjects
        subjectData = allSubjectsData.(subjectNames{i});
        summaryData{i, 1} = subjectData.name;
        summaryData{i, 2} = subjectData.numFiles;
        
        % Count successfully loaded files
        successCount = 0;
        for j = 1:length(subjectData.files)
            if isfield(subjectData.files{j}, 'data') || ...
               isfield(subjectData.files{j}, 'powerSpectrum')
                successCount = successCount + 1;
            end
        end
        summaryData{i, 3} = successCount;
        
        fprintf('  %s: %d files total, %d loaded successfully\n', ...
                subjectData.name, subjectData.numFiles, successCount);
    end
    
    % Save summary to CSV
    summaryTable = cell2table(summaryData, ...
                              'VariableNames', {'Subject', 'TotalFiles', 'SuccessfullyLoaded'});
    summaryCSVPath = fullfile(outputPath, 'processing_summary.csv');
    writetable(summaryTable, summaryCSVPath);
    fprintf('\nSummary saved to: %s\n', summaryCSVPath);
end
