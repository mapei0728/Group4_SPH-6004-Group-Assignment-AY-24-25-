# Automated Multi-Label Classification of Chest X-Rays & Report Extraction  

**Group 4, SPH6004 Advanced Statistical Learning**  
Ma Pei (A0305342R), Janhavi A (A0205165M), He Yichen (A0236326H), Guan Tong (A0177881M)  

---

## 📖 Project Overview

This repository implements a two-part system for detecting 13 lung conditions from the MIMIC-CXR dataset:

1. **Task 1: Image-Only Classification**  
   - **Input:** 1,376-D embeddings from a pretrained CXR model  
   - **Pipeline:**  
     - *Dimensionality reduction:* UMAP-Regularized Autoencoder → 100-D codes  
     - *Classifiers:* LightGBM, MLP, TabTransformer  
     - *Imbalance handling:* SMOTE, weighted loss, Focal Loss, Asymmetric Loss  
   - **Metrics:** Average Precision (AP), precision, recall, F1, accuracy (per label)  

2. **Task 2: Text-Only Classification**  
   - **Input:** Free-text radiology reports  
   - **Pipeline:** TF-IDF → Logistic Regression (one model per label, 5-fold CV optimized for AP)  

3. **Task 3: Multimodal Fusion**  
   - **Inputs:** 100-D image codes + 768-D ClinicalBERT embeddings  
   - **Architecture:** Cross-modal TransformerEncoder → classification head  
   - **Loss:** Masked Asymmetric Loss (ignores missing labels)  

Full methods, experiments, and discussion are detailed in our [final report](SPH6004%20Report.docx) SPH6004 Report.docx](file-service://file-SsJACspvNNczpCd2nfTqBu).

---

## 📂 Repository Structure

Will update later

---

## 🚀 Quickstart

1. **Clone & install dependencies**  
   ```bash
   git clone https://github.com/mapei0728/Group4_SPH-6004_Group-Assignment_AY24-25.git
   cd Group4_SPH-6004_Group-Assignment_AY24-25
   conda env create -f environment.yml
   conda activate sph6004
