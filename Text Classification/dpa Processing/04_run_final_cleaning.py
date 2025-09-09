# -*- coding: utf-8 -*-
"""
Created on Mon Aug 11 16:10:46 2025

@author: Jasper Bär
"""

import yaml
import os
import pandas as pd
import multiprocessing as mp
import itertools
from src.data_processing import FinalCleaner
from src.utils import count_names 

def main():
    """Orchestrates the final data cleaning and polishing stage."""
    print("--- STAGE 4: Final Text Polishing ---")

    # Load config
    with open('config/dpa_config.yaml', 'r') as f:
        config = yaml.safe_load(f)

    # Define file paths
    data_root = config['data_root']
    input_dir = os.path.join(data_root, config['final_candidates_output_dir'])
    input_csv_path = os.path.join(input_dir, config['final_candidates_csv'])
    
    output_dir = os.path.join(data_root, config['final_cleaned_output_dir']) 
    os.makedirs(output_dir, exist_ok=True)
    output_csv_path = os.path.join(output_dir, config['final_cleaned_csv'])

    # Load the candidate data from Stage 3
    print(f"Loading final candidate data from {input_csv_path}...")
    try:
        df = pd.read_csv(input_csv_path, dtype={'urn': str}, keep_default_na=False)
    except FileNotFoundError:
        print(f"Error: Input file not found at {input_csv_path}.")
        print("Please run Stage 3 (03_run_heavy_processing.py) first.")
        return

    # Instantiate the cleaner and polish the articles
    cleaner = FinalCleaner(config)
    polished_df = cleaner.polish_articles(df)
    
    # Handle the multiprocessing steps for count_names 
    print("Performing final filtering based on name counts (using multiprocessing)...")
    try:
        with open("names.txt", "r", encoding="utf-8-sig") as f:
            names_list = f.read().splitlines()
    except FileNotFoundError:
        print("Warning: names.txt not found. Skipping name count filtering.")
        names_list = []

    if names_list:
        # Prepare inputs for starmap
        inputs = zip(polished_df['texts'], polished_df['word_count'], itertools.repeat(names_list))
        
        with mp.Pool(mp.cpu_count()) as pool:
            names_result = pool.starmap(count_names.count_names, inputs)
        
        polished_df['names'] = names_result
        
        names_threshold = config.get('names_ratio_threshold', 0.15)
        initial_len = len(polished_df)
        polished_df = polished_df[polished_df['names'] < names_threshold].copy()
        polished_df = polished_df.drop(columns=['names'])
        print(f"-> Removed {initial_len - len(polished_df)} articles with high name counts.")

    # Save the final, analysis-ready dataset
    final_df = polished_df.reset_index(drop=True)
    print(f"\nSaving final dataset to {output_csv_path}...")
    final_df.to_csv(output_csv_path, index=False)
    
    print(f"--- STAGE 4 COMPLETE: Project finished. {len(final_df)} articles in final dataset. ---")

if __name__ == "__main__":
    main()