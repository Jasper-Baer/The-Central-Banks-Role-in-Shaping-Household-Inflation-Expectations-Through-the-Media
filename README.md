# The Central Bank's Role in Shaping Household Inflation Expectations Through the Media

This repository contains the code for the paper:

**“The Central Bank’s Role in Shaping Household Inflation Expectations Through the Media” (Jasper Bär, 2025).**

---

## Overview

The paper investigates how **ECB press conferences** influence **German news coverage** and, in turn, how this media coverage shapes **household inflation expectations**.  

**Work in Progress (WIP):** Code and documentation are still WIP.  

**Data Access:** Due to copyright restrictions, **original DPA news articles cannot be shared** in this repository. Only the code and derived indices will be available.

## Repository Structure

The repository is organized into the following folders:

### 1. Text Classification/Data Processing: ### This folder contains the code that takes in raw, unprocessed newspaper articles from DPA and loads them into a dataframe, and cleans out all articles and article parts referring to non-economic news. Finally, all sentences referring to inflation and monetary news are extracted. 
- **`Text Classification/Data Processing/config/`** – YAML configs for paths, preprocessing options, and patterns for non-economic news to drop.  
- **`Text Classification/Data Processing/src/cleaning/`** – scripts for cleaning DPA articles from any information unrelated to sentiment analysis.  
- **`Text Classification/Data Processing/src/processing/`** – scripts for deleting duplicates and splitting combinations of articles into single articles.
- **`Text Classification/Data Processing/src/utils/`** – scripts for counting words and measuring the text to numbers relationship in articles.

- **`Text Classification/Data Processing/01_run_extraction.py`** – Loads dpa articles into dataframe.
- **`Text Classification/Data Processing/02_run_initial_cleaning.py`** – Delete non-economic articles.
- **`Text Classification/Data Processing/03_run_heavy_processing.py`** – Delete fuzzy duplicates, split combined articles into single articles, and clean articles..
- **`Text Classification/Data Processing/04_run_final_cleaning.py`** – Deletes dpa references, urls and simliar uneccsary text.
- **`Text Classification/Data Processing/05_run_lemmatization.py`** – Apply lemmatization to articles.
- **`Text Classification/Data Processing/06_run_filtering.py`** – Select all sentences referring to inflation and monetary news based on lemmas. 

### 2. Text Classification/BERT Classification  
- **`Text Classification/BERT Classification/config`** – YAML configs for paths and training parameters
- **`Text Classification/BERT Classification/src`** – Scripts for loading data, training and model initialization

- **`Text Classification/BERT Classification/run_training.py`** – Scripts for to training models and test them  


### 3. Text Classification/ECB Crawler  
- **`Text Classification/ECB Crawler/config/`** – YAML configs for paths and preprocessing options. 
- **`Text Classification/ECB Crawler/src/`**: Scripts for scraping, loading, and preprocessing of ECB press conferences.
- **`Text Classification/ECB Crawler/scraper.py`**: Main function for running the scraper for ECB press conferences.
- **`Text Classification/ECB Crawler/process_data.py`**: Script for preprocessing ECB press conferences.

### 4. Regression ### This folder contains the code for the regressions done in sections 5 and 6 in the paper.
- **`Regression/Data Transformation`** – Scripts for final data transformation of news and ECB press conference indicators for regressions.
- **`Regression/Education`** – Scripts for regressing inflation expectations of households with different educations (Section Appendix P.1).
- **`Regression/Inflation Expectations`** – Scripts for regressing household inflation expectations (Section 6).
- **`Regression/News - Inflation Direction and Sentiment`** – Scripts for regressing news indicators relating to inflation direction and inflation sentiment (Section 5).
- **`Regression/News - Quotes and Non_Quotes`** – Scripts for regressing news indicators relating to monetary stance and monetary sentiment (Section 5).
- **`Regression/Plots`** – Scripts creating plots for descriptive analyses (Section 4). 
- **`Regression/Tests`** – Scripts for stationarity tests (Section Appendix G). 


