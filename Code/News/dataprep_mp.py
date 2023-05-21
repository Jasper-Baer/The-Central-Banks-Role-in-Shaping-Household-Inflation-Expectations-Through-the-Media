# -*- coding: utf-8 -*-
"""
Created on Thu May 18 15:50:13 2023

@author: jbaer
"""

from dataprep import tokenizer_articles

def process_data_tokenizer_articles(chunk):
    return tokenizer_articles(chunk, 'german')