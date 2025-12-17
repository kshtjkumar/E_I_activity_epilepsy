% Configuration Template for EEG Analysis Pipeline
%
% Author: Kshitij Kumar
% Department of Biological Sciences & Bioengineering, IIT Kanpur
% Uttar Pradesh, India, 208016
%
% Description:
%   Configuration template for setting up the EEG analysis pipeline.
%   Copy this file to 'config.m' and modify the paths and parameters
%   according to your local setup.
%
% Usage:
%   1. Copy this file: cp config_template.m config.m
%   2. Edit config.m with your local paths
%   3. Run: config = config_template(); % or your renamed config.m
%
% Note: Add 'config.m' to .gitignore to avoid committing local paths

function config = config_template()
    %% Path Configuration
    % Base directory for data (modify to your data location)
    % Example: '/path/to/your/data' or 'C:\Users\YourName\Data'
    config.dataPath = fullfile(pwd, 'data');
    
    % Brainstorm database path (if using Brainstorm toolbox)
    % Example: '/path/to/brainstorm_db' or 'C:\Users\YourName\brainstorm_db'
    config.brainstormPath = fullfile(pwd, 'brainstorm_db');
    
    % Output directory for results
    config.outputPath = fullfile(pwd, 'results');
    
    % Temporary directory for intermediate files
    config.tempPath = fullfile(pwd, 'temp');
    
    %% Analysis Parameters
    % Time window parameters
    config.windowLengthSec = 30;        % Window length in seconds
    config.timePeriodSec = 599;         % Total time period in seconds
    config.overlapSec = 0;              % Overlap between windows in seconds
    
    % Frequency parameters
    config.startFrequencyHz = 0.5;      % Starting frequency in Hz
    config.endFrequencyHz = 30;         % Ending frequency in Hz
    config.frequencyResolution = 0.5;   % Frequency resolution in Hz
    
    % EDF processing parameters
    config.samplingRate = 256;          % Sampling rate in Hz
    config.channelSelection = 'all';    % 'all' or list of channel names
    
    % Spectral analysis parameters
    config.fftWindowLength = 2048;      % FFT window length
    config.spectralMethod = 'welch';    % 'welch', 'periodogram', or 'multitaper'
    
    %% File Pattern Configuration
    % File naming patterns (modify based on your file naming convention)
    config.edfPattern = '*.edf';           % EDF file pattern
    config.matPattern = '*.mat';           % MAT file pattern
    config.subjectPattern = 'Subject*';    % Subject folder pattern
    
    %% Brainstorm Configuration (if applicable)
    config.brainstormProtocol = 'MyProtocol';      % Brainstorm protocol name
    config.brainstormStudy = 'MyStudy';            % Brainstorm study name
    config.brainstormCondition = 'spontaneous';    % Condition name
    
    %% Processing Options
    config.verbose = true;                  % Display progress messages
    config.saveIntermediateResults = true;  % Save intermediate processing results
    config.overwriteExisting = false;       % Overwrite existing output files
    
    %% Validation
    % Create output directories if they don't exist
    if ~exist(config.outputPath, 'dir')
        mkdir(config.outputPath);
    end
    
    if ~exist(config.tempPath, 'dir')
        mkdir(config.tempPath);
    end
    
    % Display configuration summary
    if config.verbose
        fprintf('Configuration loaded successfully\n');
        fprintf('Data path: %s\n', config.dataPath);
        fprintf('Output path: %s\n', config.outputPath);
        fprintf('Window length: %d seconds\n', config.windowLengthSec);
        fprintf('Frequency range: %.1f - %.1f Hz\n', ...
                config.startFrequencyHz, config.endFrequencyHz);
    end
end
