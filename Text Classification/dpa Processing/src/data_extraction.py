# -*- coding: utf-8 -*-
"""
Created on Mon Aug 11 11:59:47 2025

@author: Jasper Bär
"""

import gzip
import shutil
import pandas as pd
import json
import os
import re
from tqdm import tqdm

def decompress_files(raw_path: str, extracted_path: str):
    """Decompresses all .gz files from the raw directory structure."""
    print(f"Decompressing files from '{raw_path}' to '{extracted_path}'...")
    for root, dirs, files in os.walk(raw_path):
        for name in files:
            if not name.endswith('.gz'):
                continue
            
            file_name = os.path.join(root, name)
            
            year_match = re.search(r'(\d{4})', os.path.basename(root))
            if not year_match:
                continue
            year = year_match.group(1)
            
            output_dir = os.path.join(extracted_path, f"year={year}")
            os.makedirs(output_dir, exist_ok=True)
            
            output_file_name = os.path.join(output_dir, name.replace('.gz', '.txt'))

            with gzip.open(file_name, 'rb') as f_in:
                with open(output_file_name, 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
    print("Decompression complete.")

def load_articles_to_dataframe(extracted_path: str) -> pd.DataFrame:
    """Loads all extracted .txt files into a single pandas DataFrame."""
    articles = []
    print("Loading extracted articles into DataFrame...")
    
    file_list = [os.path.join(root, name) for root, _, files in os.walk(extracted_path) for name in files if name.endswith('.txt')]

    for file_name in tqdm(file_list, desc="Reading JSONL files"):
        with open(file_name, 'r', encoding='utf-8') as file:
            for line in file:
                try:
                    article = json.loads(line.strip())
                    articles.append(article)
                except json.JSONDecodeError:
                    print(f"Warning: Could not decode line in file {file_name}")
                    continue
    
    return pd.DataFrame(articles)