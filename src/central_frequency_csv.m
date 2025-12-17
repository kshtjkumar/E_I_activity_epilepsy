% Central Frequency CSV Export
%
% Authors: Garima Chauhan¹, Kshitij Kumar¹, Deepti Chugh¹, Subramaniam Ganesh¹, Arjun Ramakrishnan¹,²
% Affiliations:
%   ¹Department of Biological Sciences & Bioengineering, IIT Kanpur
%   ²Mehta Family Centre for Engineering in Medicine, IIT Kanpur
%   Uttar Pradesh, India, 208016
% Corresponding Author: Arjun Ramakrishnan
%
% Description:
%   Processes spectral analysis results from subject folders and exports
%   central frequency measures to CSV files. Extracts aperiodic and periodic
%   components from power spectral density data.
%
% Input:
%   - baseFolder: Path to directory containing subject folders
%   - Each subject folder should contain MAT files with spectral data
%
% Output:
%   - CSV files with central frequency measures for each subject
%   - One CSV per subject containing frequency band characteristics
%
% Usage:
%   central_frequency_csv();
%   % Or with custom base folder:
%   central_frequency_csv('/path/to/data');
%
% Dependencies:
%   - MATLAB Statistics and Machine Learning Toolbox

function central_frequency_csv(baseFolder)
    % Analysis parameters
    WINDOW_LENGTH_SEC = 30;
    END_FREQUENCY_HZ = 30;
    
    % Default base folder if not provided
    if nargin < 1
        % Use configurable path - modify this or load from config
        baseFolder = fullfile(pwd, 'data');
    end
    
    % Validate base folder exists
    if ~exist(baseFolder, 'dir')
        error('Base folder does not exist: %s', baseFolder);
    end
    
    fprintf('Processing data from: %s\n', baseFolder);
    
    % Get list of subject folders
    subjectFolders = dir(baseFolder);
    subjectFolders = subjectFolders([subjectFolders.isdir]);
    % Remove '.' and '..' directories
    subjectFolders = subjectFolders(~ismember({subjectFolders.name}, {'.', '..'}));
    
    if isempty(subjectFolders)
        error('No subject folders found in: %s', baseFolder);
    end
    
    fprintf('Found %d subject folder(s)\n', length(subjectFolders));
    
    % Process each subject folder
    for i = 1:length(subjectFolders)
        subjectName = subjectFolders(i).name;
        subjectPath = fullfile(baseFolder, subjectName);
        
        fprintf('\nProcessing subject: %s\n', subjectName);
        
        % Get all MAT files in subject folder
        matFiles = dir(fullfile(subjectPath, '*.mat'));
        
        if isempty(matFiles)
            warning('No MAT files found for subject: %s', subjectName);
            continue;
        end
        
        fprintf('  Found %d MAT file(s)\n', length(matFiles));
        
        % Initialize storage for central frequency data
        centralFreqData = [];
        
        % Process each MAT file
        for j = 1:length(matFiles)
            matFilePath = fullfile(subjectPath, matFiles(j).name);
            
            try
                % Load spectral data
                data = load(matFilePath);
                
                % Extract central frequency measures
                % Note: Adapt field names based on your data structure
                if isfield(data, 'power_spectrum') && isfield(data, 'frequencies')
                    freqs = data.frequencies;
                    power = data.power_spectrum;
                    
                    % Filter to frequency range of interest
                    freqMask = freqs <= END_FREQUENCY_HZ;
                    freqs = freqs(freqMask);
                    power = power(freqMask);
                    
                    % Calculate central frequency (peak frequency)
                    [~, peakIdx] = max(power);
                    centralFreq = freqs(peakIdx);
                    
                    % Store results
                    result = struct();
                    result.filename = matFiles(j).name;
                    result.central_frequency = centralFreq;
                    result.peak_power = power(peakIdx);
                    result.window_length = WINDOW_LENGTH_SEC;
                    
                    centralFreqData = [centralFreqData; result];
                else
                    warning('Expected fields not found in: %s', matFiles(j).name);
                end
                
            catch ME
                warning('Error processing file %s: %s', matFiles(j).name, ME.message);
            end
        end
        
        % Export to CSV if data was collected
        if ~isempty(centralFreqData)
            outputFileName = sprintf('%s_central_frequency.csv', subjectName);
            outputPath = fullfile(subjectPath, outputFileName);
            
            % Convert struct array to table and save
            dataTable = struct2table(centralFreqData);
            writetable(dataTable, outputPath);
            
            fprintf('  Exported results to: %s\n', outputFileName);
        else
            warning('No data collected for subject: %s', subjectName);
        end
    end
    
    fprintf('\nProcessing complete!\n');
end
