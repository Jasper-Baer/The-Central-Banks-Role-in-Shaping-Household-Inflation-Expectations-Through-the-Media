# -*- coding: utf-8 -*-
"""
Created on Mon Aug 11 12:28:28 2025

@author: Jasper Bär
"""

import yaml
import os
import pandas as pd
from src.data_processing import DpaProcessor

def main():
    """Orchestrates the heavy data processing stage of the DPA pipeline."""
    print("--- STAGE 3: Heavy Data Processing ---")

    # Load config
    try:
        with open('config/dpa_config.yaml', 'r', encoding='utf-8') as f:
            config = yaml.safe_load(f)
        with open('config/dpa_rules.yaml', 'r', encoding='utf-8') as f:
            rules = yaml.safe_load(f)
    except FileNotFoundError as e:
        print(f"Error: Configuration file not found. {e}")
        return

    # Define file paths
    data_root = config['data_root']
    
    input_dir = os.path.join(data_root, config['preprocessed_output_dir'])
    input_csv_path = os.path.join(input_dir, config['cleaned_articles_csv'])
    
    output_dir = os.path.join(data_root, config['final_candidates_output_dir'])
    os.makedirs(output_dir, exist_ok=True)
    output_csv_path = os.path.join(output_dir, config['final_candidates_csv'])

    # Load the cleaned data from Stage 2
    print(f"Loading cleaned data from {input_csv_path}...")
    try:
        df = pd.read_csv(input_csv_path, dtype={'urn': str}, keep_default_na=False)
        df['version_created'] = pd.to_datetime(df['version_created'])
    except FileNotFoundError:
        print(f"Error: Input file not found at {input_csv_path}.")
        print("Please run Stage 2 (02_run_initial_cleaning.py) first.")
        return

    # Instantiate the processor and run the heavy processing
    processor = DpaProcessor(rules, config)
    processed_df = processor.process(df)

    # Save the result for the final stage
    print(f"\nSaving final candidate data to {output_csv_path}...")
    processed_df.to_csv(output_csv_path, index=False)
    
    print(f"--- STAGE 3 COMPLETE: {len(processed_df)} articles ready for final polishing. ---")

if __name__ == "__main__":

    main()