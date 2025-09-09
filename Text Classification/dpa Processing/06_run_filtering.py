# -*- coding: utf-8 -*-
"""
Created on Mon Aug 25 21:59:38 2025

@author: Jasper Bär
"""

import yaml
import os
import pandas as pd
from src.sentence_filter import SentenceFilter 
from tqdm import tqdm

def main():
    """
    Main function to orchestrate the keyword-based filtering of lemmatized sentences.
    """
    print("--- STAGE 6: Keyword-Based Sentence Filtering ---")

    # Load config
    try:
        with open('config/dpa_config.yaml', 'r', encoding='utf-8') as f:
            config = yaml.safe_load(f)
        with open('config/dpa_rules.yaml', 'r', encoding='utf-8') as f:
            rules = yaml.safe_load(f)
    except FileNotFoundError as e:
        print(f"Error: Configuration file not found. {e}")
        return

    #  Define file paths 
    data_root = config['data_root']
    
    # Input from the previous stage
    input_dir = os.path.join(data_root, config['lemmatized_output_dir'])
    input_csv_path = os.path.join(input_dir, config['lemmatized_data_csv'])
    
    output_dir = os.path.join(data_root, config['subset_output_dir'])
    os.makedirs(output_dir, exist_ok=True)
    output_inflation_path = os.path.join(output_dir, config['inflation_subset_csv'])
    output_ecb_path = os.path.join(output_dir, config['ecb_subset_csv'])

    # Load the lemmatized data from Stage 5
    print(f"Loading lemmatized data from: {input_csv_path}")
    try:
        df = pd.read_csv(input_csv_path)
    except FileNotFoundError:
        print(f"Error: Input file not found at '{input_csv_path}'.")
        print("Please ensure Stage 5 (05_run_lemmatization.py) has been run successfully.")
        return

    #  Instantiate the sentence filter
    sentence_filter = SentenceFilter(rules) 
    inflation_df, ecb_df = sentence_filter.find_subsets(df)

    # Save the final, filtered datasets
    print(f"\nSaving inflation subset to: {output_inflation_path}")
    inflation_df.to_csv(output_inflation_path, index=False)
    
    print(f"Saving ECB subset to: {output_ecb_path}")
    ecb_df.to_csv(output_ecb_path, index=False)
    
    print("\n--- DPA NEWS PIPELINE COMPLETE ---")
    print(f"Final subsets saved successfully in '{output_dir}'.")

if __name__ == "__main__":
    main()