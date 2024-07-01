# Automated Blood Cell Detection and Classification Using YOLOv7

## Overview
This project focuses on automating the detection and classification of blood cells using an improved version of the YOLOv7 model. The goal is to enhance clinical diagnostics by providing a fast, accurate, and user-friendly system for analyzing blood smear images.

## Features
- **Detection Classes:** Reduced to three main blood cell types: Platelets, Red Blood Cells (RBCs), and White Blood Cells (WBCs).
- **Model Architecture:** Improved YOLOv7 with modifications for robustness and high accuracy.
- **User Interface:** Web-based interface for uploading blood smear images and receiving analysis reports in PDF format.
- **Performance:** High Mean Average Precision (mAP) and fast processing time (under 10 seconds per image).

## Methodology
### Model Architecture
- **Backbone:** CSPDarknet53 for feature extraction.
- **Neck:** Combines Feature Pyramid Network (FPN) and Path Aggregation Network (PAN) for multi-scale feature representation.
- **Head:** Predicts bounding boxes, class probabilities, and objectness scores.

### Dataset
- **Source:** Publicly available dataset.
- **Content:** Blood smear images annotated with bounding boxes and class labels.
- **Preprocessing:** Data augmentation, normalization, and batching using custom data loaders.

### Training
- **Initial Weights:** Pre-trained YOLOv7 weights.
- **Hyperparameters:**
  - Batch Size: 4
  - Epochs: 20
  - Learning Rate: 0.01
  - Weight Decay: 0.0005
- **Environment:** CUDA (NVIDIA GeForce MX250), PyTorch 2.3.1+cu118.

## Results
- **Metrics:** Precision, Recall, F1-Score, and Confusion Matrix.
- **Performance:** High accuracy in detecting and classifying WBCs, with some areas for improvement in RBC and Platelet detection.

## Usage
### Prerequisites
- Python 3.8 or higher
- PyTorch 2.3.1 or higher
- CUDA-compatible GPU (optional but recommended)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/blood-cell-detection.git
   cd blood-cell-detection

2. Install the required packages:

   ```bash
    pip install -r requirements.txt

### Running the Model

 1.   Prepare the dataset:
        Download the dataset from the provided link.
        Place the images and annotation files in the dataset directory.

 2.   Train the model:
       ```bash
        python train.py --data dataset.yaml --cfg yolov7.yaml --weights yolov7.pt --epochs 100

 3.   Test the model:
       ```bash
        python test.py --data dataset.yaml --weights best.pt

### Web Interface

  1. Start the web server:
       ```bash
        python app.py
       
   2. Open your browser and navigate to http://localhost:5000.

   3. Upload a blood smear image and receive the analysis report.

Future Work

    Expand the dataset for better model training.
    Address class imbalance issues.
    Optimize hyperparameters for improved performance.
    Integrate the system with clinical workflows for real-world application.

Contributions

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.



