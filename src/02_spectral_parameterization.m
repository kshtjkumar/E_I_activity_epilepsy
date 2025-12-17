% 02 - Spectral Parameterization
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
%   Processes spectral parameterization results from Brainstorm-loaded data
%   and exports them to CSV format. Separates aperiodic (1/f background) and
%   periodic (oscillatory) components of the power spectrum for further analysis.
%
% Usage:
%   specparam_to_csv_brainstorm_loaded();
%   % Or with custom paths:
%   specparam_to_csv_brainstorm_loaded('/path/to/brainstorm/data', '/path/to/output');
%
% Dependencies:
%   - Brainstorm toolbox (https://neuroimage.usc.edu/brainstorm/)
%   - MATLAB Curve Fitting Toolbox
%   - MATLAB Signal Processing Toolbox

function specparam_to_csv_brainstorm_loaded(baseFolder, outputFolder)
    % Analysis constants
    WINDOW_LENGTH_SEC = 30;         % Time window length in seconds
    END_FREQUENCY_HZ = 30;          % Maximum frequency for analysis (Hz)
    START_FREQUENCY_HZ = 0.5;       % Minimum frequency for analysis (Hz)
    PEAK_THRESHOLD = 2;             % Threshold for peak detection (std above fitted line)
    MIN_PEAK_HEIGHT = 0.1;          % Minimum peak height for detection
    
    % Default parameters if not provided
    if nargin < 1
        baseFolder = fullfile(pwd, 'data');
    end
    
    if nargin < 2
        outputFolder = fullfile(pwd, 'results', 'spectral_params');
    end
    
    % Validate base folder
    if ~exist(baseFolder, 'dir')
        error('Base folder does not exist: %s', baseFolder);
    end
    
    % Create output folder if needed
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
        fprintf('Created output folder: %s\n', outputFolder);
    end
    
    fprintf('Processing Brainstorm data from: %s\n', baseFolder);
    fprintf('Results will be saved to: %s\n', outputFolder);
    
    % Get list of subject folders or data files
    dataFiles = dir(fullfile(baseFolder, '**', '*.mat'));
    
    if isempty(dataFiles)
        error('No MAT files found in: %s', baseFolder);
    end
    
    fprintf('Found %d data file(s) to process\n', length(dataFiles));
    
    % Initialize storage for all parameters
    allAperiodicParams = [];
    allPeriodicParams = [];
    
    % Process each data file
    for i = 1:length(dataFiles)
        filePath = fullfile(dataFiles(i).folder, dataFiles(i).name);
        fileName = dataFiles(i).name;
        
        fprintf('\nProcessing file %d/%d: %s\n', i, length(dataFiles), fileName);
        
        try
            % Load Brainstorm data
            data = load(filePath);
            
            % Extract spectral information
            % Note: Field names may vary based on Brainstorm version and processing
            if isfield(data, 'TF') && isfield(data, 'Freqs')
                % Time-frequency data
                powerSpectrum = data.TF;
                frequencies = data.Freqs;
            elseif isfield(data, 'power') && isfield(data, 'frequencies')
                % Direct power spectrum
                powerSpectrum = data.power;
                frequencies = data.frequencies;
            else
                warning('Expected spectral fields not found in: %s', fileName);
                continue;
            end
            
            % Filter to frequency range of interest
            freqMask = (frequencies >= START_FREQUENCY_HZ) & (frequencies <= END_FREQUENCY_HZ);
            frequencies = frequencies(freqMask);
            
            % Handle multi-dimensional data (channels x frequencies)
            if ndims(powerSpectrum) > 1
                % Average across channels if needed
                powerSpectrum = mean(powerSpectrum(:, freqMask), 1);
            else
                powerSpectrum = powerSpectrum(freqMask);
            end
            
            % Convert to log scale for fitting
            logFreqs = log10(frequencies);
            logPower = log10(powerSpectrum);
            
            % Fit aperiodic component (1/f background)
            % Linear fit in log-log space: log(P) = offset - exponent * log(f)
            aperiodicFit = polyfit(logFreqs, logPower, 1);
            aperiodicExponent = -aperiodicFit(1);  % Slope (negated)
            aperiodicOffset = aperiodicFit(2);     % Intercept
            
            % Calculate fitted aperiodic component
            aperiodicComponent = polyval(aperiodicFit, logFreqs);
            
            % Remove aperiodic component to isolate periodic peaks
            flattenedSpectrum = logPower - aperiodicComponent;
            
            % Find periodic peaks
            [peakPowers, peakLocs] = findpeaks(flattenedSpectrum, ...
                                              'MinPeakHeight', MIN_PEAK_HEIGHT, ...
                                              'MinPeakProminence', PEAK_THRESHOLD * std(flattenedSpectrum));
            
            peakFrequencies = frequencies(peakLocs);
            
            % Calculate goodness of fit (R²)
            residuals = logPower - aperiodicComponent;
            ssResidual = sum(residuals.^2);
            ssTotal = sum((logPower - mean(logPower)).^2);
            rSquared = 1 - (ssResidual / ssTotal);
            
            % Store aperiodic parameters
            aperiodicParams = struct();
            aperiodicParams.filename = fileName;
            aperiodicParams.exponent = aperiodicExponent;
            aperiodicParams.offset = aperiodicOffset;
            aperiodicParams.r_squared = rSquared;
            aperiodicParams.window_length = WINDOW_LENGTH_SEC;
            
            allAperiodicParams = [allAperiodicParams; aperiodicParams];
            
            % Store periodic parameters (peaks)
            for p = 1:length(peakFrequencies)
                periodicParams = struct();
                periodicParams.filename = fileName;
                periodicParams.peak_frequency = peakFrequencies(p);
                periodicParams.peak_power = peakPowers(p);
                periodicParams.peak_index = p;
                
                allPeriodicParams = [allPeriodicParams; periodicParams];
            end
            
            fprintf('  Fitted - Exponent: %.3f, Offset: %.3f, R²: %.3f, Peaks: %d\n', ...
                    aperiodicExponent, aperiodicOffset, rSquared, length(peakFrequencies));
            
        catch ME
            warning('Error processing file %s: %s', fileName, ME.message);
        end
    end
    
    % Export aperiodic parameters to CSV
    if ~isempty(allAperiodicParams)
        aperiodicTable = struct2table(allAperiodicParams);
        aperiodicCSVPath = fullfile(outputFolder, 'aperiodic_parameters.csv');
        writetable(aperiodicTable, aperiodicCSVPath);
        fprintf('\nExported aperiodic parameters to: %s\n', aperiodicCSVPath);
    end
    
    % Export periodic parameters to CSV
    if ~isempty(allPeriodicParams)
        periodicTable = struct2table(allPeriodicParams);
        periodicCSVPath = fullfile(outputFolder, 'periodic_parameters.csv');
        writetable(periodicTable, periodicCSVPath);
        fprintf('Exported periodic parameters to: %s\n', periodicCSVPath);
    end
    
    % Generate summary statistics
    if ~isempty(allAperiodicParams)
        generate_spectral_summary(allAperiodicParams, allPeriodicParams, outputFolder);
    end
    
    fprintf('\nSpectral parameterization complete!\n');
end

% Helper function: Generate summary statistics
function generate_spectral_summary(aperiodicParams, periodicParams, outputFolder)
    fprintf('\n=== Spectral Parameterization Summary ===\n');
    
    % Aperiodic statistics
    exponents = [aperiodicParams.exponent];
    offsets = [aperiodicParams.offset];
    rSquared = [aperiodicParams.r_squared];
    
    fprintf('\nAperiodic Component:\n');
    fprintf('  Exponent - Mean: %.3f, Std: %.3f, Range: [%.3f, %.3f]\n', ...
            mean(exponents), std(exponents), min(exponents), max(exponents));
    fprintf('  Offset - Mean: %.3f, Std: %.3f, Range: [%.3f, %.3f]\n', ...
            mean(offsets), std(offsets), min(offsets), max(offsets));
    fprintf('  R² - Mean: %.3f, Std: %.3f, Range: [%.3f, %.3f]\n', ...
            mean(rSquared), std(rSquared), min(rSquared), max(rSquared));
    
    % Periodic statistics
    if ~isempty(periodicParams)
        peakFreqs = [periodicParams.peak_frequency];
        peakPowers = [periodicParams.peak_power];
        
        fprintf('\nPeriodic Components:\n');
        fprintf('  Total peaks detected: %d\n', length(peakFreqs));
        fprintf('  Peak frequency - Mean: %.2f Hz, Std: %.2f Hz\n', ...
                mean(peakFreqs), std(peakFreqs));
        fprintf('  Peak power - Mean: %.3f, Std: %.3f\n', ...
                mean(peakPowers), std(peakPowers));
    end
    
    % Save summary to file
    summaryFile = fullfile(outputFolder, 'spectral_summary.txt');
    fid = fopen(summaryFile, 'w');
    fprintf(fid, 'Spectral Parameterization Summary\n');
    fprintf(fid, '==================================\n\n');
    fprintf(fid, 'Files processed: %d\n\n', length(aperiodicParams));
    fprintf(fid, 'Aperiodic Component:\n');
    fprintf(fid, '  Exponent - Mean: %.3f, Std: %.3f\n', mean(exponents), std(exponents));
    fprintf(fid, '  Offset - Mean: %.3f, Std: %.3f\n', mean(offsets), std(offsets));
    fprintf(fid, '  R² - Mean: %.3f, Std: %.3f\n', mean(rSquared), std(rSquared));
    if ~isempty(periodicParams)
        fprintf(fid, '\nPeriodic Components:\n');
        fprintf(fid, '  Total peaks: %d\n', length(peakFreqs));
        fprintf(fid, '  Peak frequency - Mean: %.2f Hz, Std: %.2f Hz\n', ...
                mean(peakFreqs), std(peakFreqs));
    end
    fclose(fid);
    
    fprintf('\nSummary saved to: %s\n', summaryFile);
end
