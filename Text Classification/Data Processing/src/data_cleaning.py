# -*- coding: utf-8 -*-
"""
Created on Mon Aug 11 12:09:12 2025

@author: Jasper Bär
"""

import pandas as pd
from tqdm import tqdm

from src.utils import count_words_mp 

class DpaCleaner:
    """
    Handles the initial rule-based cleaning of the raw DPA articles DataFrame.
    """
    def __init__(self, rules: dict, config: dict):
        self.rules = rules
        self.config = config
        tqdm.pandas()

    def clean_dataframe(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Applies the full initial cleaning pipeline to the DataFrame with detailed progress logging.
        """
        print("Starting initial cleaning pipeline...")
        initial_total = len(df)
        print(f"Initial article count: {initial_total}")

        # Drop unnecessary columns 
        cols_to_drop = ['wire', 'language', 'usageterms_content', 'copyrightnotice_content', 'creditline_content']
        df = df.drop(columns=cols_to_drop, errors='ignore')

        # Standardize columns and dates 
        df['version_created'] = pd.to_datetime(df['version_created'], utc=True)
        df.rename(columns={'headline_content': 'title', 'article_content': 'texts'}, inplace=True)
        
        df = df.sort_values(by='version_created').reset_index(drop=True)

        # Calculate word count 
        print("\nCalculating word counts for each article...")
        df['word_count'] = df['texts'].progress_apply(count_words_mp.count_words_mp)
        print("-> Word counts calculated.")

        # Remove short articles
        min_words = self.config.get('min_word_count', 100)
        print(f"\nFiltering articles with fewer than {min_words} words...")
        articles_before_filter = len(df)
        df = df[df['word_count'] >= min_words].copy()
        print(f"-> Removed {articles_before_filter - len(df)} short articles.")
        print(f"Articles remaining: {len(df)}")

        # Remove exact duplicates 
        print("\nRemoving exact duplicate articles...")
        articles_before_filter = len(df)
        df.drop_duplicates(['texts'], keep='first', inplace=True)
        df.reset_index(inplace=True, drop=True)
        print(f"-> Removed {articles_before_filter - len(df)} exact duplicates.")
        print(f"Articles remaining: {len(df)}")

        # Apply title-based filters 
        print("\nApplying title-based regex filters...")
        articles_before_filter = len(df)
        
        drop_patterns_regex = '|'.join(self.rules['title_filters']['drop_patterns'])
        keep_exceptions_regex = '|'.join(self.rules['title_filters']['keep_exceptions'])

        mask_to_drop = (
            df['title'].str.contains(drop_patterns_regex, na=False, case=False) &
            ~df['title'].str.contains(keep_exceptions_regex, na=False, case=False)
        )
        
        mask_presseschau = (
            df['title'].str.contains('Presseschau', na=False, case=False) &
            ~df['title'].str.contains('zu', na=False, case=False)
        )
        
        final_mask = mask_to_drop | mask_presseschau
        
        df = df[~final_mask].copy()
        
        df.reset_index(inplace=True, drop=True)
        print(f"-> Removed {articles_before_filter - len(df)} articles via title filters.")
        print(f"Articles remaining: {len(df)}")
        
        print("\n-----------------------------------------")
        print("Initial cleaning pipeline complete.")
        print(f"Total articles removed: {initial_total - len(df)}")
        print(f"Final article count for Stage 2: {len(df)}")
        print("-----------------------------------------")
        return df