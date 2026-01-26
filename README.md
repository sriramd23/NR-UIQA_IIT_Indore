# No-Reference Underwater Image Quality Assessment (NR-UIQA)

This repository contains the complete codebase, reports, and experimental
results developed as part of a **CEA Research Internship** on
**No-Reference Underwater Image Quality Assessment (NR-UIQA)**.

The work focuses on a feature-based NR-UIQA framework designed to predict
perceptual image quality in underwater environments without access to a
reference image.

---

## Repository Structure

The repository is organized to reflect the stages of the proposed framework:

- **Feature_Extraction/**  
  MATLAB implementations for handcrafted feature extraction, including:
  - Gradient-domain structural features
  - HSV-based color moments and entropy features
  - Luminance-based Gabor (frequency-domain) features

- **Model_Development/**  
  Python notebooks and scripts for:
  - Training base regression models
  - Building a Super Stack (stacked generalization) ensemble
  - Model evaluation using correlation-based metrics

- **Results/**  
  Plots, tables, and spreadsheets corresponding to the experimental results
  reported in the internship report.

- **Docs/**  
  Internship-related documents, including task reports and the CEA midterm
  report.

- **Sample_Dataset/**  
  A small subset of images is provided only for testing and demonstration.
  Full datasets are not included.

---

## Methodology Overview

The NR-UIQA framework follows a feature-based pipeline:

1. Handcrafted features are extracted to capture perceptually relevant
   distortions related to color degradation, structural loss, and
   mid-frequency texture attenuation.
2. Multiple regression models are trained independently on the extracted
   features and corresponding subjective quality scores.
3. A Super Stack Ensemble is employed to combine complementary predictors
   and improve robustness and consistency.

Model performance is evaluated using PLCC, SRCC, and RMSE.

---

## Datasets

Experiments are conducted on publicly available underwater image quality
datasets such as **UID2021** and **SAUD**.  
Due to size and licensing constraints, full datasets are not included in
this repository.

---

## Internship Context

This repository serves as the consolidated code and results archive for the
CEA Research Internship supports the analysis presented in the midterm
report. All contents are intended strictly for academic and research use.

---

## License

This repository is intended for academic use only.  
Copyright of datasets, reference papers, and external resources remains with
their respective authors.
