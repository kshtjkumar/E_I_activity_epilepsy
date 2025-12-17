# Data Directory

Place your EEG/ECoG data files in this directory following the structure described below.

## Data Organization

The expected directory structure for data processing:

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

- Each subject should have a separate subdirectory
- Use consistent naming conventions (e.g., Subject01, Subject02)
- Raw EDF files should be placed directly in the subject folders

## Data Format

### Input Files

**EDF Files** (`.edf`)
- Format: European Data Format (EDF) for electrophysiological recordings
- Content: Continuous EEG/ECoG data
- Sampling rate: 256 Hz or higher (recommended)
- Electrode configuration: Standard 10-20 system recommended
- Duration: Variable (analysis uses configurable time windows)

### Output Files

After processing, the following files will be generated in subject folders:

**Spectral Parameter Files** (`.csv`)
- `aperiodic_parameters.csv`: Contains spectral exponent, offset, and R² values
- `periodic_parameters.csv`: Contains peak frequencies, power, and bandwidth

**Central Frequency Files** (`.csv`)
- `*_central_frequency.csv`: Peak frequency measures per subject

**Merged Files** (`.csv`)
- `*_merged_r2_cf.csv`: Combined R² and central frequency data with quality metrics

**Processed Data Files** (`.mat`)
- Intermediate MAT files with spectral analysis results
- Consolidated data structures for batch analysis

## Data Requirements

- **File size:** EDF files can be large; ensure adequate storage space
- **Permissions:** Files should be readable by MATLAB
- **Quality:** Pre-screened recordings with minimal artifacts recommended
- **Privacy:** Ensure data is de-identified before processing

## Large Data Files

For datasets larger than 100 MB:
- Consider storing raw data externally (e.g., Zenodo, Figshare, institutional repository)
- Store only processed/summarized results in the repository
- Link to external data sources in the main README

## Data Sources

Document the source and characteristics of your data:
- Recording site and conditions
- Subject demographics (anonymized)
- Any preprocessing steps performed before EDF export
- Relevant metadata (electrode impedances, recording quality notes, etc.)
