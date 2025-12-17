# Source Code Directory

This directory contains MATLAB analysis scripts for EEG/ECoG spectral analysis and the spectral parameterization pipeline.

## Author

Kshitij Kumar

**Affiliation:**
- Department of Biological Sciences & Bioengineering, IIT Kanpur
- Uttar Pradesh, India, 208016

---

## Overview

This directory contains MATLAB scripts for analyzing EEG/ECoG data with a focus on spectral parameterization to separate aperiodic (1/f background) and periodic (oscillatory) components. The pipeline processes raw EDF files through spectral analysis and exports results for further statistical analysis.

## Scripts Description

### 1. `config_template.m`
**Purpose:** Configuration template for setting up analysis paths and parameters.

**Description:** Provides a template configuration file with all necessary paths and analysis parameters. Users should copy this to `config.m` and modify for their local setup.

**Key Settings:**
- Data paths (input/output directories)
- Time window parameters (window length, overlap)
- Frequency range specifications
- Brainstorm toolbox paths
- Processing options

**Usage:**
```matlab
% Copy template to config.m and modify paths
config = config_template();
```

### 2. `central_frequency_csv.m`
**Purpose:** Extract central frequency measures from spectral data and export to CSV.

**Description:** Processes MAT files containing spectral analysis results, identifies central (peak) frequencies in power spectra, and exports measures to CSV format for statistical analysis.

**Inputs:**
- Base folder containing subject subdirectories with MAT files
- Each MAT file should contain power spectrum and frequency data

**Outputs:**
- CSV files (one per subject) with central frequency measures
- Includes peak frequency, peak power, and analysis parameters

**Usage:**
```matlab
% Use default path (./data)
central_frequency_csv();

% Or specify custom path
central_frequency_csv('/path/to/your/data');
```

### 3. `edf_load.m`
**Purpose:** Load and process EDF (European Data Format) files using Brainstorm.

**Description:** Imports EDF files containing EEG/ECoG recordings into Brainstorm for preprocessing and analysis. Handles time segmentation and prepares data for spectral analysis.

**Inputs:**
- Data folder containing EDF files
- Subject ID (optional)

**Outputs:**
- Brainstorm database entries with imported raw data
- Segmented data ready for spectral analysis

**Usage:**
```matlab
% Use defaults
edf_load();

% Specify data folder and subject ID
edf_load('/path/to/edf/files', 'SubjectID');
```

**Note:** Requires Brainstorm toolbox to be installed and in MATLAB path.

### 4. `mat_file_reading_script_new.m`
**Purpose:** Batch read and consolidate MAT files from multiple subjects.

**Description:** Reads processed MAT files from subject folders, extracts relevant features and metadata, and consolidates into a single data structure for cross-subject analysis.

**Inputs:**
- Data path with subject subdirectories
- Each subject folder contains MAT files with processed data

**Outputs:**
- Consolidated MAT file with all subjects' data
- CSV summary report with processing statistics

**Usage:**
```matlab
% Use default paths
mat_file_reading_script_new();

% Specify custom paths
mat_file_reading_script_new('/path/to/data', '/path/to/output');
```

### 5. `mergeR2_central_Frequency.m`
**Purpose:** Merge spectral fitting R² values with central frequency measures.

**Description:** Combines goodness-of-fit metrics (R²) from aperiodic spectral fitting with central frequency measures for comprehensive quality assessment and analysis.

**Inputs:**
- Data path containing subject folders
- Each folder should have R² values and central frequency files

**Outputs:**
- Merged CSV files per subject
- Combined CSV across all subjects
- Summary statistics

**Usage:**
```matlab
% Use default path
mergeR2_central_Frequency();

% Specify custom path
mergeR2_central_Frequency('/path/to/data');
```

### 6. `specparam_to_csv_brainstorm_loaded.m`
**Purpose:** Perform spectral parameterization and export to CSV.

**Description:** Implements spectral parameterization to separate power spectra into aperiodic (1/f background) and periodic (oscillatory peaks) components. Fits aperiodic component and identifies oscillatory peaks.

**Inputs:**
- Base folder with Brainstorm-processed spectral data (MAT files)
- Output folder for CSV results (optional)

**Outputs:**
- `aperiodic_parameters.csv`: Exponent, offset, R² for each recording
- `periodic_parameters.csv`: Peak frequencies, powers, and bandwidths
- Summary statistics file

**Usage:**
```matlab
% Use default paths
specparam_to_csv_brainstorm_loaded();

% Specify custom paths
specparam_to_csv_brainstorm_loaded('/path/to/brainstorm/data', '/path/to/output');
```

---

## Prerequisites

### Required Software
- **MATLAB** R2019b or later (tested on R2024a)
- **MATLAB Toolboxes:**
  - Signal Processing Toolbox
  - Statistics and Machine Learning Toolbox
  - Curve Fitting Toolbox (for spectral parameterization)

### Optional Dependencies
- **Brainstorm Toolbox** (required for `edf_load.m`)
  - Download: https://neuroimage.usc.edu/brainstorm/
  - Version: Latest stable release recommended
  - Installation: Follow Brainstorm installation guide

---

## Setup Instructions

### 1. Clone Repository
```bash
git clone https://github.com/kshtjkumar/E_I_activity_epilepsy.git
cd E_I_activity_epilepsy
```

### 2. Configure Paths
```matlab
% Copy configuration template
copyfile('src/config_template.m', 'src/config.m');

% Edit config.m with your local paths
edit src/config.m

% Load configuration
config = config();
```

### 3. Set Up Directory Structure
```
project_root/
├── data/              # Raw and processed data
│   ├── Subject01/     # One folder per subject
│   ├── Subject02/
│   └── ...
├── results/           # Analysis outputs
│   └── spectral_params/
├── brainstorm_db/     # Brainstorm database (if using)
└── temp/              # Temporary files
```

### 4. Install Brainstorm (if needed)
```matlab
% Download Brainstorm from https://neuroimage.usc.edu/brainstorm/
% Add to MATLAB path:
addpath('/path/to/brainstorm3');

% Start Brainstorm (GUI mode)
brainstorm

% Or for batch processing (no GUI)
brainstorm nogui
```

---

## Processing Pipeline

### Standard Workflow

1. **Import EDF Files** (if starting from raw data)
   ```matlab
   edf_load('/path/to/edf/files', 'SubjectID');
   ```

2. **Process Spectral Data** (after Brainstorm preprocessing)
   ```matlab
   specparam_to_csv_brainstorm_loaded('/path/to/brainstorm/data');
   ```

3. **Extract Central Frequencies**
   ```matlab
   central_frequency_csv('/path/to/data');
   ```

4. **Merge Quality Metrics**
   ```matlab
   mergeR2_central_Frequency('/path/to/data');
   ```

5. **Consolidate Results**
   ```matlab
   mat_file_reading_script_new('/path/to/data', '/path/to/results');
   ```

### Batch Processing Example
```matlab
% Load configuration
config = config_template();

% Process all subjects
subjects = {'Subject01', 'Subject02', 'Subject03'};

for i = 1:length(subjects)
    subjectID = subjects{i};
    subjectPath = fullfile(config.dataPath, subjectID);
    
    % Run analysis pipeline
    fprintf('Processing %s...\n', subjectID);
    
    % Step 1: Spectral parameterization
    specparam_to_csv_brainstorm_loaded(subjectPath, ...
        fullfile(config.outputPath, subjectID));
    
    % Step 2: Extract central frequencies
    central_frequency_csv(subjectPath);
    
    fprintf('Completed %s\n\n', subjectID);
end

% Merge all results
mergeR2_central_Frequency(config.dataPath);
```

---

## Input/Output File Formats

### Input Files

**EDF Files** (`*.edf`)
- Standard EDF format for EEG/ECoG recordings
- Should contain continuous recording data
- Sampling rate: Typically 256-512 Hz

**MAT Files** (Brainstorm processed)
- Required fields:
  - `TF` or `power`: Power spectral density values
  - `Freqs` or `frequencies`: Frequency bins (Hz)
  - Optional: Channel information, time stamps

### Output Files

**CSV Files**
- Comma-separated values for easy import to R, Python, Excel
- Column headers included
- One row per analysis window or subject

**Aperiodic Parameters**
- `exponent`: 1/f slope (spectral exponent)
- `offset`: y-intercept in log-log space
- `r_squared`: Goodness of fit (R²)

**Periodic Parameters**
- `peak_frequency`: Frequency of oscillatory peak (Hz)
- `peak_power`: Power at peak (log scale)
- `peak_bandwidth`: Width of peak (Hz)

---

## Troubleshooting

### Common Issues

**Issue:** "Brainstorm toolbox not found"
```matlab
% Solution: Add Brainstorm to path
addpath('/path/to/brainstorm3');
brainstorm nogui;
```

**Issue:** "No MAT files found"
- Check that file paths are correct
- Ensure subject folders contain expected data files
- Verify file extensions match pattern (e.g., `*.mat`)

**Issue:** "Expected fields not found in MAT file"
- Verify MAT files were created by compatible processing pipeline
- Check field names using: `load('file.mat'); whos`
- Adapt field names in scripts if using different data structure

**Issue:** "Out of memory"
- Process subjects one at a time
- Reduce data size or time windows
- Use `clear` between processing steps
- Consider using `matfile` for large files

### Getting Help

- Check script headers for detailed usage information
- Review setup guide in `docs/SETUP.md`
- Open an issue on GitHub for bugs or feature requests

---

## References

**Spectral Parameterization Method:**
- Donoghue, T., et al. (2020). "Parameterizing neural power spectra into periodic and aperiodic components." Nature Neuroscience.

**Brainstorm Toolbox:**
- Tadel, F., et al. (2011). "Brainstorm: A user-friendly application for MEG/EEG analysis." Computational Intelligence and Neuroscience.

---

## License

See the [LICENSE](../LICENSE) file in the repository root for licensing information.

## Contact

For questions about the analysis pipeline, please contact the corresponding author or open an issue on GitHub.
