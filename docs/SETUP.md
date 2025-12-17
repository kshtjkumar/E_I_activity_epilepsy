# Setup Guide for EEG Analysis Pipeline

## Authors

Garima Chauhan¹, Kshitij Kumar¹, Deepti Chugh¹, Subramaniam Ganesh¹, Arjun Ramakrishnan¹,²

**Affiliations:**
- ¹Department of Biological Sciences & Bioengineering, IIT Kanpur
- ²Mehta Family Centre for Engineering in Medicine, IIT Kanpur
- Uttar Pradesh, India, 208016

**Corresponding Author:** Arjun Ramakrishnan

---

## Table of Contents

1. [System Requirements](#system-requirements)
2. [Software Installation](#software-installation)
3. [Directory Structure Setup](#directory-structure-setup)
4. [Configuration](#configuration)
5. [Data Preparation](#data-preparation)
6. [Running the Pipeline](#running-the-pipeline)
7. [Troubleshooting](#troubleshooting)
8. [Advanced Configuration](#advanced-configuration)

---

## System Requirements

### Minimum Requirements
- **Operating System:** Windows 10/11, macOS 10.14+, or Linux (Ubuntu 18.04+)
- **RAM:** 8 GB (16 GB recommended for large datasets)
- **Disk Space:** 10 GB free space (more for large datasets)
- **MATLAB:** R2019b or later

### Recommended Requirements
- **RAM:** 16 GB or more
- **Processor:** Multi-core processor (4+ cores)
- **Disk Space:** 50 GB+ for extensive datasets
- **MATLAB:** R2023a or later with all recommended toolboxes

---

## Software Installation

### 1. Install MATLAB

Download and install MATLAB from [MathWorks](https://www.mathworks.com/products/matlab.html).

**Required Toolboxes:**
- Signal Processing Toolbox
- Statistics and Machine Learning Toolbox
- Curve Fitting Toolbox

**To check installed toolboxes in MATLAB:**
```matlab
ver
```

**To install missing toolboxes:**
1. Open MATLAB
2. Go to Home → Add-Ons → Get Add-Ons
3. Search for and install required toolboxes

### 2. Install Brainstorm Toolbox

Brainstorm is required for EDF file import and preprocessing.

**Installation Steps:**

1. **Download Brainstorm:**
   - Visit: https://neuroimage.usc.edu/brainstorm/
   - Click "Download" and select your platform
   - Extract to a permanent location (e.g., `~/brainstorm3` or `C:\brainstorm3`)

2. **Add to MATLAB Path:**
   ```matlab
   % In MATLAB, run:
   addpath('/path/to/brainstorm3');
   savepath;  % Save path for future sessions
   ```

3. **Start Brainstorm:**
   ```matlab
   brainstorm  % GUI mode
   % OR
   brainstorm nogui  % No GUI for batch processing
   ```

4. **Configure Brainstorm:**
   - On first launch, set your Brainstorm database location
   - Recommended: Create a folder like `~/brainstorm_db` or `C:\brainstorm_db`

### 3. Clone This Repository

```bash
# Using HTTPS
git clone https://github.com/kshtjkumar/E_I_activity_epilepsy.git

# Using SSH
git clone git@github.com:kshtjkumar/E_I_activity_epilepsy.git

# Navigate to repository
cd E_I_activity_epilepsy
```

---

## Directory Structure Setup

### 1. Create Required Directories

The analysis pipeline expects the following directory structure:

```
E_I_activity_epilepsy/
├── data/                    # Raw and processed data
│   ├── Subject01/           # One folder per subject
│   │   ├── raw/            # (optional) Raw EDF files
│   │   ├── processed/      # (optional) Processed MAT files
│   │   └── results/        # (optional) Analysis results
│   ├── Subject02/
│   └── ...
├── results/                 # Analysis outputs
│   ├── spectral_params/    # Spectral parameterization results
│   ├── figures/            # Generated plots
│   └── summaries/          # Summary statistics
├── brainstorm_db/          # Brainstorm database (if using)
│   ├── protocols/
│   └── data/
├── temp/                   # Temporary files
├── src/                    # Source code (already exists)
├── docs/                   # Documentation (already exists)
└── notebooks/              # Jupyter notebooks (if using)
```

### 2. Create Directories Programmatically

**In MATLAB:**
```matlab
% Navigate to repository root
cd /path/to/E_I_activity_epilepsy

% Create directory structure
dirs = {'data', 'results', 'results/spectral_params', ...
        'results/figures', 'results/summaries', 'temp', 'brainstorm_db'};

for i = 1:length(dirs)
    if ~exist(dirs{i}, 'dir')
        mkdir(dirs{i});
        fprintf('Created: %s\n', dirs{i});
    end
end
```

**In Terminal/Command Prompt:**
```bash
# Navigate to repository
cd /path/to/E_I_activity_epilepsy

# Create directories
mkdir -p data results/spectral_params results/figures results/summaries temp brainstorm_db
```

---

## Configuration

### 1. Create Your Configuration File

```matlab
% In MATLAB, navigate to src directory
cd src

% Copy the template
copyfile('config_template.m', 'config.m');

% Open for editing
edit config.m
```

### 2. Edit Configuration Settings

**Modify `config.m` with your local paths:**

```matlab
function config = config()
    %% Path Configuration
    % Set to your actual data location
    config.dataPath = '/path/to/your/data';  % MODIFY THIS
    
    % Set Brainstorm database path
    config.brainstormPath = '/path/to/brainstorm_db';  % MODIFY THIS
    
    % Set output directory
    config.outputPath = '/path/to/results';  % MODIFY THIS
    
    % Temporary directory
    config.tempPath = '/path/to/temp';  % MODIFY THIS
    
    %% Analysis Parameters (usually keep defaults)
    config.windowLengthSec = 30;
    config.timePeriodSec = 599;
    config.startFrequencyHz = 0.5;
    config.endFrequencyHz = 30;
    config.samplingRate = 256;
    
    %% File Patterns
    config.edfPattern = '*.edf';
    config.matPattern = '*.mat';
    config.subjectPattern = 'Subject*';
    
    %% Processing Options
    config.verbose = true;
    config.saveIntermediateResults = true;
    config.overwriteExisting = false;
    
    %% Create directories if needed
    if ~exist(config.outputPath, 'dir')
        mkdir(config.outputPath);
    end
    if ~exist(config.tempPath, 'dir')
        mkdir(config.tempPath);
    end
end
```

### 3. Add config.m to .gitignore

To prevent committing your local paths:

```bash
# Add to .gitignore
echo "src/config.m" >> .gitignore
```

Or manually add this line to `.gitignore`:
```
src/config.m
```

### 4. Test Configuration

```matlab
% Load configuration
config = config();

% Verify paths exist
assert(exist(config.dataPath, 'dir') > 0, 'Data path does not exist');
assert(exist(config.outputPath, 'dir') > 0, 'Output path does not exist');

fprintf('Configuration loaded successfully!\n');
fprintf('Data path: %s\n', config.dataPath);
fprintf('Output path: %s\n', config.outputPath);
```

---

## Data Preparation

### 1. Organize Your Data

**Expected organization:**

```
data/
├── Subject01/
│   ├── recording1.edf
│   ├── recording2.edf
│   └── ...
├── Subject02/
│   ├── recording1.edf
│   └── ...
└── ...
```

### 2. Data Format Requirements

**EDF Files:**
- Standard EDF format (European Data Format)
- Continuous recordings preferred
- Sampling rate: 256 Hz or higher (will be resampled if needed)
- Channel labels should follow standard 10-20 system for EEG

**MAT Files (if using preprocessed data):**
- Should contain:
  - `power` or `TF`: Power spectral density values
  - `frequencies` or `Freqs`: Frequency bins (Hz)
  - Optional: `channels`, `time`, `samplingRate`

### 3. Subject Naming Convention

**Recommended naming:**
- Use consistent subject identifiers (e.g., Subject01, Subject02)
- Avoid spaces in folder/file names
- Use leading zeros for numeric IDs (Subject01 vs Subject1)

### 4. Validate Data Files

```matlab
% Check if data files exist
dataPath = '/path/to/your/data';
subjects = dir(dataPath);
subjects = subjects([subjects.isdir] & ~ismember({subjects.name}, {'.', '..'}));

fprintf('Found %d subject folders:\n', length(subjects));
for i = 1:length(subjects)
    subjectPath = fullfile(dataPath, subjects(i).name);
    edfFiles = dir(fullfile(subjectPath, '*.edf'));
    matFiles = dir(fullfile(subjectPath, '*.mat'));
    fprintf('  %s: %d EDF files, %d MAT files\n', ...
            subjects(i).name, length(edfFiles), length(matFiles));
end
```

---

## Running the Pipeline

### Quick Start

```matlab
% 1. Load configuration
cd /path/to/E_I_activity_epilepsy/src
config = config();

% 2. Add src directory to path
addpath(genpath(pwd));

% 3. Process a single subject
subjectID = 'Subject01';
subjectPath = fullfile(config.dataPath, subjectID);

% If starting from EDF files
edf_load(subjectPath, subjectID);

% After Brainstorm processing, run spectral parameterization
specparam_to_csv_brainstorm_loaded(subjectPath, ...
    fullfile(config.outputPath, 'spectral_params'));

% Extract central frequencies
central_frequency_csv(subjectPath);

% Merge with quality metrics
mergeR2_central_Frequency(config.dataPath);
```

### Batch Processing Multiple Subjects

```matlab
% Load configuration
config = config();

% Get list of subjects
subjects = dir(config.dataPath);
subjects = subjects([subjects.isdir] & ~ismember({subjects.name}, {'.', '..'}));

% Process each subject
for i = 1:length(subjects)
    subjectID = subjects(i).name;
    fprintf('\n=== Processing %s (%d/%d) ===\n', subjectID, i, length(subjects));
    
    try
        % Define paths
        subjectPath = fullfile(config.dataPath, subjectID);
        outputPath = fullfile(config.outputPath, subjectID);
        
        % Create subject output directory
        if ~exist(outputPath, 'dir')
            mkdir(outputPath);
        end
        
        % Run analysis pipeline
        % 1. Spectral parameterization
        specparam_to_csv_brainstorm_loaded(subjectPath, outputPath);
        
        % 2. Central frequency extraction
        central_frequency_csv(subjectPath);
        
        fprintf('✓ Completed %s\n', subjectID);
        
    catch ME
        fprintf('✗ Error processing %s: %s\n', subjectID, ME.message);
        continue;
    end
end

% Final step: Merge all results
fprintf('\n=== Merging all results ===\n');
mergeR2_central_Frequency(config.dataPath);
fprintf('Pipeline complete!\n');
```

### Save Processing Script

Save the batch processing code as `run_pipeline.m`:

```matlab
function run_pipeline()
    % Complete analysis pipeline for all subjects
    
    % Load configuration
    config = config();
    
    % Add source directory to path
    addpath(genpath(fileparts(mfilename('fullpath'))));
    
    % Get subjects
    subjects = dir(config.dataPath);
    subjects = subjects([subjects.isdir] & ~ismember({subjects.name}, {'.', '..'}));
    
    % Process each subject
    for i = 1:length(subjects)
        processSubject(subjects(i).name, config);
    end
    
    % Merge results
    mergeR2_central_Frequency(config.dataPath);
end

function processSubject(subjectID, config)
    fprintf('\n=== Processing %s ===\n', subjectID);
    
    subjectPath = fullfile(config.dataPath, subjectID);
    outputPath = fullfile(config.outputPath, subjectID);
    
    if ~exist(outputPath, 'dir')
        mkdir(outputPath);
    end
    
    try
        specparam_to_csv_brainstorm_loaded(subjectPath, outputPath);
        central_frequency_csv(subjectPath);
        fprintf('✓ Completed %s\n', subjectID);
    catch ME
        fprintf('✗ Error: %s\n', ME.message);
    end
end
```

Then run:
```matlab
run_pipeline();
```

---

## Troubleshooting

### Issue: "Brainstorm not found"

**Solution:**
```matlab
% Check if Brainstorm is in path
which brainstorm

% If empty, add Brainstorm to path
addpath('/path/to/brainstorm3');
savepath;

% Test
brainstorm nogui
```

### Issue: "No such file or directory"

**Cause:** Incorrect paths in configuration

**Solution:**
```matlab
% Verify paths exist
config = config();
exist(config.dataPath, 'dir')      % Should return 7
exist(config.outputPath, 'dir')    % Should return 7

% If returns 0, create directory or fix path
```

### Issue: "Expected fields not found in MAT file"

**Cause:** MAT file structure doesn't match expected format

**Solution:**
```matlab
% Inspect MAT file structure
filename = 'path/to/file.mat';
data = load(filename);
disp(fieldnames(data))  % Show all fields

% Adapt script to use your field names
```

### Issue: "Out of memory"

**Solutions:**
1. **Process fewer subjects at once:**
   ```matlab
   % Process subjects 1-10
   for i = 1:10
       processSubject(subjects(i).name, config);
   end
   clear  % Clear workspace
   
   % Then process 11-20, etc.
   ```

2. **Reduce data size:**
   - Use shorter time windows
   - Reduce frequency resolution
   - Process channels separately

3. **Increase memory:**
   ```matlab
   % Check memory
   memory
   
   % Clear workspace frequently
   clear all
   close all
   clc
   ```

### Issue: "Permission denied"

**Cause:** Cannot write to output directory

**Solution:**
```matlab
% Check write permissions
[status, msg] = fileattrib('/path/to/output');
if status
    disp(msg)
end

% Change output path to writable location
config.outputPath = fullfile(pwd, 'results');
```

---

## Advanced Configuration

### Custom Frequency Bands

Edit `config.m` to define custom frequency bands:

```matlab
%% Frequency Bands
config.bands.delta = [0.5, 4];
config.bands.theta = [4, 8];
config.bands.alpha = [8, 13];
config.bands.beta = [13, 30];
config.bands.gamma = [30, 100];
```

### Parallel Processing

For faster processing with multiple subjects:

```matlab
% Enable parallel processing
pool = parpool('local', 4);  % Use 4 cores

% Process subjects in parallel
parfor i = 1:length(subjects)
    processSubject(subjects(i).name, config);
end

% Close pool
delete(pool);
```

### Custom Preprocessing

Add custom preprocessing steps:

```matlab
function customPreprocess(subjectPath, config)
    % Load data
    data = load(fullfile(subjectPath, 'raw_data.mat'));
    
    % Apply bandpass filter
    [b, a] = butter(4, [config.startFrequencyHz, config.endFrequencyHz] / ...
                    (config.samplingRate/2), 'bandpass');
    filtered = filtfilt(b, a, data.signal);
    
    % Remove artifacts
    % ... your artifact removal code ...
    
    % Save preprocessed data
    save(fullfile(subjectPath, 'preprocessed_data.mat'), 'filtered');
end
```

---

## Next Steps

After completing setup:

1. **Run test analysis** on one subject to verify everything works
2. **Review results** in the output directory
3. **Adjust parameters** in `config.m` if needed
4. **Process all subjects** using batch processing script
5. **Analyze results** using statistical software (R, Python, etc.)

---

## Additional Resources

- [Main README](../README.md)
- [Source Code Documentation](../src/README.md)
- [Brainstorm Documentation](https://neuroimage.usc.edu/brainstorm/Introduction)
- [MATLAB Documentation](https://www.mathworks.com/help/matlab/)

---

## Support

For issues or questions:
- Open an issue on GitHub
- Contact the corresponding author
- Check the troubleshooting section above

---

*Last updated: December 2024*
