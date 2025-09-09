# The Central Bank's Role in Shaping Household Inflation Expectations Through the Media

This repository contains the code for the paper:

**“The Central Bank’s Role in Shaping Household Inflation Expectations Through the Media” (Jasper Bär, 2025).**

---

## Overview

The paper investigates how **ECB press conferences** influence **German news coverage** and, in turn, how this media coverage shapes **household inflation expectations**.  

⚠️ **Work in Progress (WIP):** Code and documentation are still WIP.  

⚠️ **Data Access:** Due to copyright restrictions, **original dpa news articles cannot be shared** in this repository. Only the code and derived indices are provided.

## Repository Structure

### 1. Data Processing  
- **`config/`** – YAML configs (paths, debug flags).  
- **`src/data_extraction/`** – decompressing archives, parsing articles, loading into DataFrames.  
- **`src/preprocessing/`** – filtering, text cleaning, keyword-based selection for inflation and monetary policy subsets.  

### 2. Text Classification  
- **`src/classification/`** – BERT classifiers 
- **Models**: Based on GBERT pretrained on German corpora.  
- **Outputs**: Sentence-level labels saved for aggregation.  

### 3. Index Construction  
- **`src/index_construction/`** – Aggregation of sentence classifications into **monthly indices**, e.g.:  
  - `News Inflation_t^{Increasing}`, `News Inflation_t^{Decreasing}`,  
  - `News MP_t^{Quote,Dovish}`, `News MP_t^{NoQuote,Hawkish}`, etc.  
- Indices created for both **news coverage** and **ECB press conferences**.  

### 4. Econometric Analysis  
- **`src/regression/`** – Scripts replicating regression results from the paper.  
  - **Part 1 (Section 5, “Analysis of News Drivers”):**  
    - Drivers of inflation coverage.  
    - Drivers of monetary policy coverage.  
  - **Part 2 (Section 6, “Inflation Expectations Drivers”):**  
    - Bayesian learning framework estimation.  
    - Includes robustness checks (education subsamples, excluding recessions, etc.).  
