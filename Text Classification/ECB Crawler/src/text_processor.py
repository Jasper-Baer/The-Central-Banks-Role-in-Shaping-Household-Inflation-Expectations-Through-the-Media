# -*- coding: utf-8 -*-
"""
Created on Sun Aug 10 14:08:24 2025

@author: Ja-ba
"""

import pandas as pd
import re
import nltk
from tqdm import tqdm
import string as st
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from nltk.stem import PorterStemmer

class TextProcessor:
    """
    A class to handle the cleaning, processing, and splitting of ECB press conference texts.
    """
    def __init__(self, rules: dict):
        """
        Initializes the processor with a dictionary of rules.
        
        Args:
            rules (dict): A dictionary loaded from processing_rules.yaml.
        """
        self.rules = rules
        self._ensure_nltk_downloads()

    def _ensure_nltk_downloads(self):
        """Checks for and downloads required NLTK data files."""
        required_data = ['punkt', 'stopwords']
        for item in required_data:
            try:
                nltk.data.find(f'tokenizers/{item}' if item == 'punkt' else f'corpora/{item}')
            except nltk.downloader.DownloadError:
                print(f"NLTK '{item}' model not found. Downloading...")
                nltk.download(item)

    def _clean_initial_text(self, text: str) -> str:
        """Performs the first pass of cleaning on the raw text."""
        for string_to_replace in self.rules['initial_cleaning']['strings_to_replace']:
            text = text.replace(string_to_replace, '')
        
        for pattern in self.rules['initial_cleaning']['patterns_to_remove']:
            text = re.sub(pattern, '', text, flags=re.IGNORECASE)
            
        return text.strip()

    def _split_speech_and_qa(self, sentences: list, index: int) -> tuple[list, list]:
        """Splits a list of sentences into speech and Q&A based on rules."""
        qa_start_strings = self.rules['qa_splitting']['start_strings']
        special_cases = self.rules['qa_splitting']['special_cases']

        if index in special_cases:
            delimiter = special_cases[index]
            split_indices = [i for i, s in enumerate(sentences) if delimiter in s]
        else:
            split_indices = [i for i, s in enumerate(sentences) if s in qa_start_strings]
        
        if not split_indices:
            return sentences, []

        split_point = split_indices[0]
        speech = sentences[:split_point]
        qa = sentences[split_point:]
        return speech, qa

    def _clean_and_tokenize_speeches(self, speeches_list: list) -> list:
        """
        Applies the full cleaning, tokenizing, and stemming pipeline from your original script.
        This method replaces the placeholder.
        """
        print("Applying custom cleaning and tokenization pipeline...")
        
        port_stemmer = PorterStemmer()
        stop_words = set(stopwords.words('english'))
        punct = st.punctuation + '“”–€–’' 
        
        final_tokenized_speeches = []
        
        for speech_sentences in tqdm(speeches_list, desc="Cleaning and Tokenizing"):
            # Join the list of sentences into a single block of text for this speech
            full_speech_text = ' '.join(speech_sentences)
            
            # Remove numbers
            text_no_numbers = re.sub(r'\d+', '', full_speech_text)
            
            # Remove punctuations and convert to lower case
            text_no_punct = "".join([char.lower() for char in text_no_numbers if char not in punct])
            
            # Replace multiple whitespace
            cleaned_text = re.sub('\s+', ' ', text_no_punct).strip()
            
            # Tokenize the fully cleaned text
            tokens = word_tokenize(cleaned_text)
            
            # Stem and remove stop words
            stemmed_tokens = [port_stemmer.stem(w) for w in tokens]
            filtered_tokens = [w for w in stemmed_tokens if w not in stop_words]
            
            final_tokenized_speeches.append(filtered_tokens)
            
        return final_tokenized_speeches

    def process_dataframe(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Applies the processing pipeline to the DataFrame.
        """
        print("Starting text processing pipeline...")
        
        df['clean press cons'] = df['Texts'].apply(lambda x: self._clean_initial_text(' '.join(x)))
        df['press sent'] = df['clean press cons'].apply(nltk.sent_tokenize)
        df['press sent'] = df['press sent'].apply(lambda sents: sents[1:] if sents else [])

        speeches = []
        qas = []

        for idx, row in tqdm(df.iterrows(), total=df.shape[0], desc="Splitting Speech/QA"):
            speech, qa = self._split_speech_and_qa(row['press sent'], row.name)
            speeches.append(speech)
            qas.append(qa)
        df['speeches'] = speeches
        df['QA'] = qas

        df['tokens'] = self._clean_and_tokenize_speeches(df['speeches'])

        print("Processing pipeline complete.")
        return df