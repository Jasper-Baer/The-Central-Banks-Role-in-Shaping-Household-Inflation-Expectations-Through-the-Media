# -*- coding: utf-8 -*-
"""
Created on Sun Aug 10 14:20:31 2025

@author: Jasper Bär
"""

import pandas as pd
import yaml
from tqdm import tqdm
from src.data_loader import load_scraped_data
from src.text_processor import TextProcessor

def main():
    """
    Main function to run the data processing pipeline.
    """
    print("--- Running Data Processing Pipeline ---")

    # Load Config
    try:
        with open('config/processing_rules.yaml', 'r') as f:

            config = yaml.safe_load(f)
            input_path = config.get('output_path', 'data/press_conferences.json') # Use scraper output as input
            processed_output_path = 'data/ECB_sents_prepared.xlsx'

        with open('config/processing_rules.yaml', 'r') as f:
            rules = yaml.safe_load(f)
    except FileNotFoundError as e:
        print(f"Error: Configuration file not found. {e}")
        return

    # Load the raw data
    df = load_scraped_data(input_path)

    # Process data
    processor = TextProcessor(rules)
    processed_df = processor.process_dataframe(df)

    # Filtering and preparation
    print("Performing final filtering and formatting...")

    processed_df['years'] = pd.to_numeric(processed_df['years'])
    final_df = processed_df[(processed_df['years'] >= 2002) & (processed_df['years'] <= 2024)].copy()

    # Split speeches into single sentences
    press_sents = []
    for idx, row in tqdm(final_df.iterrows(), total=final_df.shape[0], desc="Formatting for Excel"):
        for sent in row['speeches']:
            press_sents.append({
                'original_index': row.name,
                'sentence': sent,
                'date': row['Date']
            })
    press_sents_df = pd.DataFrame(press_sents)

    print(f"Saving processed data to {processed_output_path}...")
    press_sents_df.to_excel(processed_output_path, index=False)
    
    print("--- Pipeline Finished Successfully ---")


if __name__ == "__main__":
    main()