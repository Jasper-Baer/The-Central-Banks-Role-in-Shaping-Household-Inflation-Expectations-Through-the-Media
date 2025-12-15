# -*- coding: utf-8 -*-
"""
Created on Wed Aug 27 21:30:08 2025

@author: Jasper Bär

This module contains the TextLemmatizer class for advanced NLP preprocessing,
including cleaning, tokenizing, and stemming of German text.
This logic is adapted from the original prepare_text class in PR_index_supp.py.
"""

import re
import string as st
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from nltk.stem.snowball import SnowballStemmer
from tqdm import tqdm

class TextStemmer:
    
    def __init__(self, text_series, language='german'):
        self.text_series = text_series
        self.language = language

    def _clean_sentence(self, sentence):
        sentence = re.sub(r'\d+', '', sentence)
        punct = st.punctuation + '“”–€–’'
        sentence = "".join([char.lower() for char in sentence if char not in punct]) 
        sentence = re.sub('\s+', ' ', sentence).strip()
        return sentence

    def preprocess_and_stem(self):
        """
        Processes text by cleaning, tokenizing, removing stopwords, and stemming.
        This version is robust against non-string/NaN inputs.
        """
        snowball_stemmer = SnowballStemmer(self.language)
        
        preprocessed_text = []
        token_mapping = {}

        stop_words = set(stopwords.words(self.language))
        if self.language == 'german':
            negation_words = ['kein', 'keine', 'nicht', 'nichts', 'ohne']
        else:
            negation_words = []
        stop_words = stop_words.difference(negation_words)

        for sentence in tqdm(self.text_series, desc="Stemming Sentences"):
            
            cleaned_sentence = self._clean_sentence(str(sentence))
            
            tokens = word_tokenize(cleaned_sentence)
            
            stem_sentence = []
            for w in tokens:
                 stem_w = snowball_stemmer.stem(w)
                 if w not in stop_words:
                     stem_sentence.append(stem_w)
                     if w not in token_mapping:
                        token_mapping[w] = stem_w
     
            preprocessed_text.append(stem_sentence)

        return preprocessed_text, token_mapping