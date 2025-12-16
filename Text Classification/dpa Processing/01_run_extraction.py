# -*- coding: utf-8 -*-
"""
Created on Mon Aug 11 12:03:33 2024

@author: Jasper Bär
"""

"""
This script reads the input and output paths from the YAML config, decompresses 
the raw DPA .gz archives into extracted text files, loads the extracted article 
records into a single DataFrame, and saves them as one CSV that serves as the 
input for the next processing step.
"""

import yaml
import os
from src.data_extraction import decompress_files, load_articles_to_dataframe

def main():
    print("--- STAGE 1: Data Extraction ---")

    # Load config
    with open('config/dpa_config.yaml', 'r', encoding='utf-8') as f:
        config = yaml.safe_load(f)

    raw_path = os.path.join(config['data_root'], config['raw_data_input_dir'])
    extracted_path = os.path.join(config['data_root'], config['extracted_output_dir'])
    os.makedirs(extracted_path, exist_ok=True)
    output_csv_path = os.path.join(extracted_path, config['raw_articles_csv'])
    
    decompress_files(raw_path, extracted_path)
    df = load_articles_to_dataframe(extracted_path)
    
    if not df.empty:
        print(f"{len(df)}")
        print(f"Saving data to {output_csv_path}...")
        df.to_csv(output_csv_path, index=False)
        print(f"--- STAGE 1 COMPLETE: {len(df)} articles extracted. ---")
    else:
        print("--- STAGE 1 FAILED: No articles were extracted. ---")

if __name__ == "__main__":
    main()