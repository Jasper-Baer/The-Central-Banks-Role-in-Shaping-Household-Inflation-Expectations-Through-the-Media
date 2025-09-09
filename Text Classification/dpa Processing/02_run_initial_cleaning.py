# -*- coding: utf-8 -*-
"""
Created on Mon Aug 11 12:10:32 2025

@author: Jasper Bär
"""

import yaml
import os
import pandas as pd
from src.data_cleaning import DpaCleaner

def main():
    """Orchestrates the initial data cleaning stage of the DPA pipeline."""
    print("--- STAGE 2: Initial Data Cleaning ---")


    # Load config
    with open('config/dpa_config.yaml', 'r', encoding='utf-8') as f:
        config = yaml.safe_load(f)
    with open('config/dpa_rules.yaml', 'r', encoding='utf-8') as f:
        rules = yaml.safe_load(f)
    
    # Define file paths
    data_root = config['data_root']
    input_dir = os.path.join(data_root, config['extracted_output_dir'])
    input_csv_path = os.path.join(input_dir, config['raw_articles_csv'])
    output_dir = os.path.join(data_root, config['preprocessed_output_dir'])
    os.makedirs(output_dir, exist_ok=True)
    output_csv_path = os.path.join(output_dir, config['cleaned_articles_csv'])

    # Load the data from Stage 1
    print(f"Loading raw data from {input_csv_path}...")
    df = pd.read_csv(input_csv_path, dtype={'urn': str}, keep_default_na=False)
    
    df_to_sort = df.copy()
    df_to_sort['version_created_utc'] = pd.to_datetime(df_to_sort['version_created'], utc=True)
    

    df = df_to_sort.sort_values(by=['version_created_utc', 'urn'], ascending=True)
    df = df.drop(columns=['version_created_utc'])
    df = df.reset_index(drop=True)

    cleaner = DpaCleaner(rules, config)
    cleaned_df = cleaner.clean_dataframe(df)

    print(f"\nSaving cleaned data to {output_csv_path}...")
    cleaned_df.to_csv(output_csv_path, index=False)
    
    print(f"--- STAGE 2 COMPLETE: {len(cleaned_df)} articles ready for final processing. ---")

if __name__ == "__main__":
    main()