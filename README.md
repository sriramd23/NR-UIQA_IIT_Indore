# No-Reference Underwater Image Quality Assessment (NR-UIQA)

This repository contains the code, reports, and experimental results developed
as part of a CEA Research Internship on **No-Reference Underwater Image Quality
Assessment (NR-UIQA)**.

The objective of this work is to design and analyze a feature-based NR-UIQA
framework that predicts perceptual image quality without access to a reference
image, with a specific focus on underwater imaging scenarios.

---

## Repository Structure

The repository is organized to reflect the methodology adopted in the study:

- **feature_extraction/**  
  MATLAB implementations for handcrafted feature extraction, including:
  - Structural features in the gradient domain  
  - Color features in the HSV color space  
  - Luminance-based Gabor (frequency-domain) features  

- **model_development/**  
  Python scripts and notebooks for training regression models and a Super Stack
  (stacked generalization) ensemble.

- **results/**  
  Plots, tables, and experiment logs corresponding to the reported evaluations.

- **docs/**  
  Internship reports and supporting documents submitted under the CEA framework.

---

## Methodology Overview

The NR-UIQA framework follows a feature-based pipeline:

1. Handcrafted features are extracted to capture perceptually relevant
   degradations related to color distortion, structural degradation, and
   mid-frequency texture loss.
2. Multiple regression models are trained independently to learn the mapping
   between extracted features and subjective quality scores.
3. A Super Stack Ensemble is employed to combine complementary predictors and
   improve robustness and consistency.

Model performance is evaluated using PLCC, SRCC, and RMSE.

---

## How to Reproduce Results

The experimental pipeline is modular and can be reproduced in the following
stages.

### 1. Dataset Preparation
- Download the required underwater image quality datasets (e.g., UID2021,
  SAUD) from their official sources.
- Organize images and corresponding MOS files according to the dataset-specific
  structure expected by the feature extraction scripts.

Dataset files are not included in this repository.

---

### 2. Feature Extraction (MATLAB)
- Navigate to the `feature_extraction/` directory.
- Run the main feature extraction script to compute handcrafted features for
  each image:
  - Structural features (gradient-domain statistics)
  - HSV-based color features
  - Luminance-based Gabor features (optional, for auxiliary analysis)

The output of this stage is a set of feature matrices stored in `.mat` files.

---

### 3. Model Training and Evaluation (Python)
- Navigate to the `model_development/` directory.
- Load the extracted feature files and corresponding MOS values.
- Train individual regression models (e.g., SVR, tree-based models).
- Train the Super Stack Ensemble using predictions from selected base models.

Performance metrics (PLCC, SRCC, RMSE) are computed over multiple random splits
to ensure statistical stability.

---

### 4. Result Analysis
- Generated plots and tables are saved in the `results/` directory.
- These outputs correspond directly to figures and numerical results reported
  in the internship report.

---

## Notes on Reproducibility

- Due to random train–test splits, numerical values may vary slightly across
  runs.
- Reported results are obtained by averaging performance over multiple
  independent trials.
- Computational cost varies depending on the number of repetitions and feature
  configurations used.

---

## Internship Context

This repository serves as the consolidated code and results archive for the CEA
Research Internship supports the analysis presented in the midterm report.
All contents are intended strictly for academic and research purposes.

---

## License and Disclaimer

This repository is provided for academic use only.  
Copyright of datasets, referenced papers, and external resources remains with
their respective authors.
