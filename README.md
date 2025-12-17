# Network Level Shifts in E/I Balance During Chronic Epilepsy Revealed by Aperiodic EEG Dynamics

[![MATLAB](https://img.shields.io/badge/MATLAB-R2019b%2B-orange.svg)](https://www.mathworks.com/products/matlab.html)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Brainstorm](https://img.shields.io/badge/Brainstorm-Required-blue.svg)](https://neuroimage.usc.edu/brainstorm/)

This repository contains MATLAB-based code and analysis scripts for the paper "Network level shifts in E/I balance during chronic epilepsy revealed by aperiodic EEG dynamics".

## Overview

This repository hosts the computational analysis code and tools used in our research investigating network level shifts in the balance between excitatory and inhibitory (E/I) neural activity during chronic epilepsy, revealed through aperiodic EEG dynamics. The analysis pipeline is implemented in MATLAB and uses spectral parameterization techniques to separate aperiodic (1/f background) and periodic (oscillatory) components of EEG/ECoG signals.

## Repository Structure

```
.
├── data/                        # Data files and datasets (add your own)
├── src/                         # MATLAB source code and analysis scripts
│   ├── 01_edf_import_and_preprocess.m         # Import and preprocess EDF files
│   ├── 02_spectral_parameterization.m         # Separate aperiodic/periodic components
│   ├── 03_extract_central_frequencies.m       # Extract peak frequencies
│   ├── 04_merge_quality_metrics.m             # Merge R² with frequency data
│   ├── 05_batch_process_subjects.m            # Batch processing script
│   └── config_template.m                      # Configuration template
├── notebooks/                   # Jupyter notebooks for visualization
├── figures/                     # Generated figures and plots
├── docs/                        # Documentation
│   └── SETUP.md                # Detailed setup instructions
└── requirements.txt            # Python dependencies (for notebooks)
```

## Prerequisites

- **MATLAB** R2019b or later
- **MATLAB Toolboxes:**
  - Signal Processing Toolbox
  - Statistics and Machine Learning Toolbox
  - Curve Fitting Toolbox
- **Brainstorm Toolbox** (https://neuroimage.usc.edu/brainstorm/)

## Installation

1. Clone this repository:
```bash
git clone https://github.com/kshtjkumar/E_I_activity_epilepsy.git
cd E_I_activity_epilepsy
```

2. Install Brainstorm toolbox (see [docs/SETUP.md](docs/SETUP.md) for detailed instructions)

3. Configure MATLAB paths:
```matlab
cd src
copyfile('config_template.m', 'config.m');
edit config.m  % Update paths for your system
```

4. For detailed setup instructions, see [docs/SETUP.md](docs/SETUP.md)

## Usage

### Quick Start

```matlab
% 1. Load configuration
cd src
config = config();

% 2. Process EDF files
edf_load('/path/to/edf/files', 'SubjectID');

% 3. Run spectral parameterization
specparam_to_csv_brainstorm_loaded('/path/to/data');

% 4. Extract central frequencies
central_frequency_csv('/path/to/data');

% 5. Merge results with quality metrics
mergeR2_central_Frequency('/path/to/data');
```

### Analysis Scripts

The `src/` directory contains MATLAB scripts for the complete analysis pipeline:

- **`01_edf_import_and_preprocess.m`** - Import and preprocess EDF files using Brainstorm
- **`02_spectral_parameterization.m`** - Separate aperiodic (1/f) and periodic components
- **`03_extract_central_frequencies.m`** - Identify peak frequencies and band characteristics
- **`04_merge_quality_metrics.m`** - Combine spectral parameters with goodness-of-fit measures
- **`05_batch_process_subjects.m`** - Batch processing for multiple subjects
- **`config_template.m`** - Configuration template (copy to config.m)

For detailed documentation of each script, see [src/README.md](src/README.md).

For step-by-step setup and usage instructions, see [docs/SETUP.md](docs/SETUP.md).

## Data

### Input Data Format
- **EDF files** (European Data Format) containing EEG/ECoG recordings
- Standard 10-20 electrode placement recommended
- Sampling rate: 256 Hz or higher

### Directory Structure
```
data/
├── Subject01/
│   ├── recording1.edf
│   └── recording2.edf
├── Subject02/
│   └── recording1.edf
└── ...
```

### Output Files
- CSV files with spectral parameters (exponent, offset, R²)
- CSV files with peak frequencies and band power
- MAT files with processed spectra

For detailed data format specifications, see [src/README.md](src/README.md).

## Citation

If you use this code in your research, please cite our paper:

```
Network level shifts in E/I balance during chronic epilepsy revealed by aperiodic EEG dynamics

Garima Chauhan¹, Kshitij Kumar¹, Deepti Chugh¹, Subramaniam Ganesh¹, Arjun Ramakrishnan¹,²,#

¹Department of Biological Sciences & Bioengineering, IIT Kanpur
²Mehta Family Centre for Engineering in Medicine, IIT Kanpur
Uttar Pradesh, India, 208016
# Corresponding Author: Arjun Ramakrishnan
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For questions or issues:
- Open an issue on GitHub
- Contact the corresponding author: Arjun Ramakrishnan (IIT Kanpur)

## Authors

- Garima Chauhan (IIT Kanpur)
- Kshitij Kumar (IIT Kanpur)
- Deepti Chugh (IIT Kanpur)
- Subramaniam Ganesh (IIT Kanpur)
- Arjun Ramakrishnan (IIT Kanpur) - *Corresponding Author*

## Acknowledgments

This work was conducted at the Department of Biological Sciences & Bioengineering and the Mehta Family Centre for Engineering in Medicine at the Indian Institute of Technology Kanpur.

We acknowledge the developers of the Brainstorm toolbox and the spectral parameterization methods that form the foundation of this analysis pipeline.
