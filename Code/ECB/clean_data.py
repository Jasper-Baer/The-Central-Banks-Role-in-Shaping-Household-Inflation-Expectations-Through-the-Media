# -*- coding: utf-8 -*-
"""
Created on Fri Aug 19 15:35:22 2022

@author: jbaer
"""

import re

import string as st
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from nltk.stem import PorterStemmer

def clean_data(texts):
    
    def clean_text(text):
    
        # remove numbers
        text = re.sub(r'\d+', '', text)
        
        # define punctations
        punct = st.punctuation + ('“”–€–’')
        
        # remove punctuations and convert characters to lower case
        text = "".join([char.lower() for char in text if char not in punct]) 
        
        # replace multiple whitespace with single whitespace and remove leading and trailing whitespaces
        text = re.sub('\s+', ' ', text).strip()
    
        return (text)

    port_stemmer = PorterStemmer()
    
    tokens_speeches = []
    
    for text in texts:
        
        text = clean_text(text)
        tokens_speech = word_tokenize(text)
        
        stop_words = set(stopwords.words('english'))   
        
        filtered_speech = [port_stemmer.stem(w) for w in tokens_speech]
        filtered_speech = [w for w in filtered_speech if not w in stop_words]
        
        tokens_speeches.append(filtered_speech)
    
    return(tokens_speeches)