# -*- coding: utf-8 -*-
"""
Created on Sun Aug 10 14:03:32 2025

@author: Ja-ba
"""

import pandas as pd
import json

def load_scraped_data(path: str) -> pd.DataFrame:
    """
    Loads the doubly-encoded JSON data from the scraper into a pandas DataFrame.

    Args:
        path (str): The file path to the press_conferences.json file.

    Returns:
        pd.DataFrame: A DataFrame containing the scraped conference data.
    """
    print(f"Loading data from {path}...")
    with open(path, 'r', encoding='utf-8') as f:
        json_string = json.load(f)
        
    df = pd.read_json(json_string)
    print("Data loaded successfully.")
    return df