# -*- coding: utf-8 -*-
"""
Created on Mon Aug 25 21:49:58 2025

@author: Jasper Bär
"""

import yaml
import os
import pandas as pd
import json
from nltk.tokenize import sent_tokenize
from src.text_stemmer import TextStemmer

def main():
    """Orchestrates the sentence splitting and stemming process."""
    print("--- STAGE 5: Stemming ---")

    # Load config
    try:
        with open('config/dpa_config.yaml', 'r', encoding='utf-8') as f:
            config = yaml.safe_load(f)
    except FileNotFoundError:
        print("Error: config/dpa_config.yaml not found. Please ensure it exists.")
        return

    # Define file paths
    data_root = config['data_root']
    input_dir = os.path.join(data_root, config['final_cleaned_output_dir'])
    input_csv_path = os.path.join(input_dir, config['final_cleaned_csv'])
    
    output_dir = os.path.join(data_root, config['lemmatized_output_dir'])
    os.makedirs(output_dir, exist_ok=True)
    output_csv_path = os.path.join(output_dir, config['lemmatized_data_csv'])
    output_stem_map_path = os.path.join(output_dir, config['stem_map_json'])

    # Load the cleaned articles from Stage 4
    print(f"Loading cleaned articles from: {input_csv_path}")
    try:
        df_articles = pd.read_csv(input_csv_path)
    except FileNotFoundError:
        print(f"Error: Input file not found at '{input_csv_path}'.")
        print("Please ensure Stage 4 (04_run_final_cleaning.py) has been run successfully.")
        return

    if 'version_created' in df_articles.columns:
        df_articles.rename(columns={'version_created': 'date'}, inplace=True)

    # Split articles into sentences
    print("Splitting articles into sentences...")
    df_articles['sentence'] = df_articles['texts'].apply(lambda x: sent_tokenize(str(x), language='german'))
    df_sentences = df_articles.explode('sentence').reset_index(drop=True)
    
    if 'texts' in df_sentences.columns:
        df_sentences = df_sentences.drop(columns=['texts'])
    
    initial_count = len(df_sentences)
    df_sentences.dropna(subset=['sentence'], inplace=True)
    removed_count = initial_count - len(df_sentences)
    if removed_count > 0:
        print(f"-> Removed {removed_count} rows with missing sentence data after splitting.")
    
    print(f"-> Created {len(df_sentences)} valid sentences.")

    # Process the valid sentences in chunks to manage memory
    num_chunks = config.get('lemmatization_chunks', 10)
    chunk_size = len(df_sentences) // num_chunks + (1 if len(df_sentences) % num_chunks != 0 else 0)
    
    all_processed_chunks = []
    final_stem_map = {}
    
    for i in range(num_chunks):
        start_row = i * chunk_size
        end_row = start_row + chunk_size
        df_chunk = df_sentences.iloc[start_row:end_row].copy()
        
        if df_chunk.empty:
            continue
            
        print(f"\nProcessing chunk {i+1}/{num_chunks}...")
        
        stemmer = TextStemmer(df_chunk['sentence'])
        tokens, stem_map = stemmer.preprocess_and_stem()
        
        df_chunk['tokens'] = tokens
        all_processed_chunks.append(df_chunk)
        final_stem_map.update(stem_map)

    # Concatenate results and save
    final_df = pd.concat(all_processed_chunks).reset_index(drop=True)
    
    print(f"\nSaving lemmatized data to: {output_csv_path}")
    final_df.to_csv(output_csv_path, index=False)
    
    print(f"Saving stem map to: {output_stem_map_path}")
    with open(output_stem_map_path, 'w', encoding='utf-8') as f:
        json.dump(final_stem_map, f, indent=4)
        
    print("--- STAGE 5 COMPLETE ---")

if __name__ == "__main__":
    main()