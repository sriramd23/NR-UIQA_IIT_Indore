# UIQA-Feature-Extraction: No-Reference Underwater Image Quality Assessment

[![Project Status](https://img.shields.io/badge/Status-Ongoing-yellow)]()
[![Internship](https://img.shields.io/badge/Project-Research%20Internship-blue)]()
[![Institution](https://img.shields.io/badge/Institution-IIT%20Indore-red)]()
[![Performance](https://img.shields.io/badge/Best%20PLCC-0.9048-success)]()

> **⚠️ Project Status: Ongoing**
> This repository is currently under active development as part of a research internship at IIT Indore. Code structures and model parameters are subject to optimization.

## 📌 Project Overview
This project focuses on developing a **No-Reference Image Quality Assessment (NR-IQA)** framework specifically for underwater imagery. Unlike standard metrics (PSNR/SSIM) that require reference images, this approach predicts perceptual quality using a hybrid feature extraction methodology.

**Key Methodology:**
1.  **Feature Extraction (MATLAB):** Extracts 25 statistical features (10 Structural + 15 Color) to capture underwater-specific degradations like absorption, scattering, and low contrast.
2.  **Machine Learning (Python):** Utilizes a Super Stack Ensemble model to map these features to human perceptual scores (MOS).

## 📂 Repository Structure
```text
UIQA-Feature-Extraction-IIT-Indore/
│
├── feature_extraction/            # MATLAB scripts for feature generation
│   ├── generate_feature_files.m   # Main execution script
│   └── feature_extract.m          # Core function (25-feature vector logic)
│
├── model_development/             # Jupyter Notebooks for training
│   ├── 01_Base_Models_SVR.ipynb   # Baseline SVR implementation
│   └── 02_Super_Stack_Model.ipynb # High-performance Ensemble model
│
├── datasets/                      # Raw images and MOS Excel sheets
├── features/                      # Extracted .mat feature files
├── results/                       # Performance plots and metrics
└── reports/                       # Task documentation and theory
```
🚀 Usage & Reproduction GuidePhase 1: Feature Extraction (MATLAB)Prerequisite: MATLAB installed.Navigate to the feature_extraction/ folder.Open generate_feature_files.m.Set your dataset path (ensure datasets/SUAD and datasets/UID contain images).Run the script.Output: This will generate individual .mat files for every image in the features/ directory.Phase 2: Model Training (Python / Google Colab)Prerequisite: The Notebooks are designed to run in a cloud environment (like Google Colab) or local Jupyter lab.Step 1: Prepare your DataBefore running the notebooks, ensure you have these three specific files ready:features.zip: Compress the features/ folder (containing all .mat files) into a single zip file.mos_UID.xlsx: The ground truth Mean Opinion Scores for the UID dataset.SAUD_MOS.xlsx: The ground truth Mean Opinion Scores for the SUAD dataset.Step 2: Runtime SetupOpen model_development/02_Super_Stack_Model.ipynb.Upload to Runtime:If using Google Colab, drag and drop features.zip, mos_UID.xlsx, and SAUD_MOS.xlsx into the file browser on the left.Run the Notebook:Execute the first cell to unzip the features:Python!unzip features.zip
Run the remaining cells to train the regression models.🏆 Current ResultsWe have achieved state-of-the-art correlation with human perception using a stacking ensemble approach.ModelPLCC (Accuracy)SROCC (Monotonicity)Baseline (SVR)~0.7800-Super Stack Model0.90480.9098Note: The Super Stack model achieved this with limited iterations (20) due to computational constraints. Further tuning is expected to improve results.Performance VisualsSVR PerformanceStack Model PerformanceModerate correlation (PLCC ~0.78)High correlation (PLCC ~0.90)📄 Dataset DetailsThe framework is validated on a consolidated dataset of 1,960 images:SUAD: 1,000 Images (Diverse underwater scenes)UID: 960 Images (Reference-graded underwater database)📑 DocumentationDetailed reports on the internship tasks and theoretical background can be found in the reports/ directory:Task 1: UIQA BasicsTask 2: Feature LogicMaintained by Sriram Dhanasekaran | IIT Indore Internship | Dec 2025 - Present
