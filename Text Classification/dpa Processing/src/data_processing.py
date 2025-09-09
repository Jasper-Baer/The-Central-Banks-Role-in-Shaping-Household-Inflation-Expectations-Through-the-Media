# -*- coding: utf-8 -*-
"""
Created on Mon Aug 11 12:23:21 2025

@author: Jasper Bär
"""

import pandas as pd
import itertools
from tqdm import tqdm

from src.utils import count_words_mp, numeric_articles, numeric_par
from src.processing import split_articles, fuzzy_duplicates_dpa, split_number_word
from src.cleaning import clean_tables, correct_url_dpa, clean_dpa_references, clean_dpa_articles

class DpaProcessor:
    """
    Handles the heavy processing stage: splitting articles, numeric analysis,
    and fuzzy deduplication.
    """
    def __init__(self, rules: dict, config: dict):
        self.rules = rules
        self.config = config
        tqdm.pandas()

    def _split_multi_articles(self, df: pd.DataFrame) -> pd.DataFrame:
        """Identifies, splits, and reintegrates multi-part articles."""
        print("Step 1/5: Splitting multi-part articles...")
        s_mult_art = '|'.join(self.rules['multi_article_split_titles'])
        
        mult_art_mask = df['title'].str.contains(s_mult_art, na=False, case=False)
        mult_art_df = df[mult_art_mask].copy()
        single_art_df = df[~mult_art_mask].copy()

        if mult_art_df.empty:
            print("-> No multi-part articles found to split.")
            return single_art_df


        mult_art_df.drop_duplicates(['title'], keep='first', inplace=True)
        
        print(f"-> Found and selected {len(mult_art_df)} unique multi-part articles to process.")
        
        from src.processing import split_articles 
        results = split_articles.split_articles(mult_art_df)
        
        min_words = self.config.get('min_word_count', 100)
        from src.utils import count_words_mp
        results['word_count'] = results['texts'].progress_apply(count_words_mp.count_words_mp)
        results = results[results['word_count'] >= min_words]
        
        final_df = pd.concat([single_art_df, results], ignore_index=True)
        final_df = final_df.sort_values(by='version_created').reset_index(drop=True)
        
        return final_df

    def _analyze_and_clean_numeric_content(self, df: pd.DataFrame) -> pd.DataFrame:
        """Analyzes numeric content and cleans tables."""
        print("Step 2/5: Analyzing numeric content...")
        
        num_threshold = self.config['numeric_article_threshold']
        inputs = zip(df['texts'], df['word_count'])
        df['numeric'] = [numeric_articles.numeric_articles(text, wc, num_threshold) for text, wc in inputs]
        
        par_threshold = self.config['numeric_paragraph_threshold']
        par_min_words = self.config['numeric_paragraph_min_words']
        df['paragraphs'] = df['texts'].apply(lambda x: x.split("\n"))
        inputs_par = zip(df['paragraphs'], itertools.repeat(par_threshold), itertools.repeat(par_min_words))
        df['numeric_par'] = [numeric_par.numeric_par(*par_input) for par_input in inputs_par]

        print("Step 3/5: Cleaning table-like structures...")
        df['texts'] = df['texts'].progress_apply(clean_tables.clean_tables)
        
        df = df.drop(columns=['numeric', 'numeric_par', 'paragraphs'])
        
        return df

    def _recalculate_word_count_and_filter(self, df: pd.DataFrame) -> pd.DataFrame:
        """After table cleaning, recalculates word counts and filters again."""
        print("Step 4/5: Recalculating word counts and re-filtering short articles...")
        df['word_count'] = df['texts'].progress_apply(count_words_mp.count_words_mp)
        
        min_words = self.config.get('min_word_count', 100)
        initial_len = len(df)
        df = df[df['word_count'] >= min_words].copy()
        df.reset_index(inplace=True, drop=True)
        print(f"-> Removed {initial_len - len(df)} articles after table cleaning. {len(df)} remaining.")
        
        return df

    def _perform_fuzzy_deduplication(self, df: pd.DataFrame) -> pd.DataFrame:
        """Finds and removes near-duplicates based on text similarity."""
        print("Step 5/5: Performing fuzzy deduplication")
        
        df['date'] = pd.to_datetime(df['version_created'], utc=True)
        df['year'] = df['date'].dt.year
        df['month'] = df['date'].dt.month
        df_to_process = df[['date', 'year', 'month', 'title', 'texts', 'word_count']].copy()
        
        delete_indices = []
        
        # 1. Get the unique year-month pairs as a DataFrame.
        year_month_df = df_to_process[['year', 'month']].drop_duplicates()
        
        # 2. Let pandas sort this DataFrame correctly.
        year_month_df_sorted = year_month_df.sort_values(by=['year', 'month'])
        
        # 3. Convert the now-sorted DataFrame to a list of tuples/records.
        year_month_pairs = year_month_df_sorted.to_records(index=False)
        
        total_chunks = len(year_month_pairs)
        
        for i, (year, month) in enumerate(year_month_pairs):
            print(f"  -> Processing chunk {i+1}/{total_chunks}: Year {year}, Month {month}...")
            data_month = df_to_process[(df_to_process['year'] == year) & (df_to_process['month'] == month)]
            input_tuple = (year, month, data_month)
            
            delete_intermediate = fuzzy_duplicates_dpa.fuzzy_duplicates(input_tuple)
            delete_indices.extend(delete_intermediate)

        flat_delete_indices = []
        for item in delete_indices:
            if isinstance(item, list):
                flat_delete_indices.extend(item)
            else:
                flat_delete_indices.append(item)

        final_delete_indices = list(set(flat_delete_indices))
     #   initial_len = len(df)
        if final_delete_indices: # Check if there is anything to drop
                df = df.drop(final_delete_indices).copy()
        df.reset_index(inplace=True, drop=True)
        
        print(f"-> Removed {len(final_delete_indices)} fuzzy duplicates. {len(df)} remaining.")
        df = df.drop(columns=['year', 'month', 'date'])
        
        return df
        
    def process(self, df: pd.DataFrame) -> pd.DataFrame:
        """Runs the full heavy processing pipeline."""
        df = self._split_multi_articles(df)
        df = self._analyze_and_clean_numeric_content(df)
        df = self._recalculate_word_count_and_filter(df)
        df = self._perform_fuzzy_deduplication(df)
        return df

class FinalCleaner:
    """
    Handles the final, fast, text-polishing stage of the pipeline.
    This includes URL correction, reference removal, and final text cleaning.
    """
    def __init__(self, config: dict):
        self.config = config
        tqdm.pandas()

    def polish_articles(self, df: pd.DataFrame) -> pd.DataFrame:
        """Applies the final cleaning functions to the texts column."""
        print("Starting final text polishing pipeline...")
        
        print("Step 1/4: Removing URLs...")
        df['texts'] = df['texts'].progress_apply(correct_url_dpa.correct_url_dpa)
        
        print("Step 2/4: Removing DPA references...")
        df['texts'] = df['texts'].progress_apply(clean_dpa_references.clean_dpa_references)
        
        print("Step 3/4: Splitting numbers from words...")
        df['texts'] = df['texts'].progress_apply(split_number_word.split_number_word)
        
        print("Step 4/4: Applying final article cleaning...")
        df['texts'] = df['texts'].progress_apply(clean_dpa_articles.clean_dpa_articles)

        print("\nFinal polishing complete.")
        return df

