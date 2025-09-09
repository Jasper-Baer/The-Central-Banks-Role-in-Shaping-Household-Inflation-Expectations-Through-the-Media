# -*- coding: utf-8 -*-
"""
Created on Mon Aug 25 21:55:25 2025

@author: Jasper Bär
"""

import pandas as pd
from tqdm import tqdm
from nltk.stem.snowball import SnowballStemmer
from ast import literal_eval

class SentenceFilter:
    """
    Identifies and extracts subsets of sentences based on keyword lists and rules.
    """
    def __init__(self, rules: dict):
        """
        Initializes the subset creator with stemmed keyword lists from the config.
        """
        tqdm.pandas(desc="Evaluating Tokens")
        
        self.rules = rules
        self._prepare_keyword_lists()
        self.ecb_tenure = {k.lower(): (pd.to_datetime(v[0]), pd.to_datetime(v[1])) 
                           for k, v in rules['ecb_tenure'].items()}

    def _prepare_keyword_lists(self):
        """Stems all keyword lists for efficient matching."""
        stemmer = SnowballStemmer('german')
        self.inflation_stems = {stemmer.stem(w.lower()) for w in self.rules['inflation_word_list']}
        self.ecb_stems_no_names = {stemmer.stem(w.lower()) for w in self.rules['ecb_word_list_no_names']}
        self.ecb_stems_full = {stemmer.stem(w.lower()) for w in self.rules['ecb_word_list_full']}
        self.ecb_names_stems = self.ecb_stems_full - self.ecb_stems_no_names

    def _was_in_office(self, name_stem: str, date: pd.Timestamp) -> bool:
        """Checks if an ECB member was in office on a given date."""

        start_date, end_date = self.ecb_tenure.get(name_stem, (None, None))
        return pd.notna(start_date) and (start_date <= date <= end_date)

    def find_subsets(self, df: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame]:
        """
        Processes the main DataFrame to find inflation and ECB-related sentences.
        """
        print("Finding subsets based on keywords...")
        inflation_indices = []
        ecb_indices = []


        df['date'] = pd.to_datetime(df['date']).dt.tz_localize(None)
        
        df['tokens'] = df['tokens'].progress_apply(literal_eval)

        for idx, row in tqdm(df.iterrows(), total=df.shape[0], desc="Filtering Sentences"):
            sent_stems = set(row['tokens'])
            pub_date = row['date']
            
            # Check for Inflation-related sentences 
            if not sent_stems.isdisjoint(self.inflation_stems):
                inflation_indices.append(idx)
            
            # Check for ECB-related sentences 
            ecb_keyword_match = not sent_stems.isdisjoint(self.ecb_stems_no_names)
            
            # Check for special phrases
            special_phrase_found = False
            tokens = row['tokens']
            if any(tokens[i] == "europa" and tokens[i+1] == "zentralbank" for i in range(len(tokens)-1)):
                special_phrase_found = True
            elif any(tokens[i] == "jurg" and tokens[i+1] == "stark" for i in range(len(tokens)-1)):
                if self._was_in_office("stark", pub_date):
                    special_phrase_found = True
            
            # Check for names of members who were in office at the time
            active_member_found = any(self._was_in_office(stem, pub_date) for stem in sent_stems.intersection(self.ecb_names_stems))
                                                   
            if ecb_keyword_match or special_phrase_found or active_member_found:
                ecb_indices.append(idx)

        inflation_df = df.loc[list(set(inflation_indices))].copy()
        ecb_df = df.loc[list(set(ecb_indices))].copy()
        
        print(f"-> Found {len(inflation_df)} inflation-related sentences.")
        print(f"-> Found {len(ecb_df)} ECB-related sentences.")

        return inflation_df, ecb_df