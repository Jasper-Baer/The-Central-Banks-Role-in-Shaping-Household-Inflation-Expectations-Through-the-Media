# -*- coding: utf-8 -*-
"""
Created on Thu May 18 11:01:28 2023

@author: Ja-ba
"""

## CITE treetaggerwrapper??

import pandas as pd

import multiprocessing as mp
from concurrent.futures import ProcessPoolExecutor

import time
import os

from ast import literal_eval

os.chdir(r'D:\Studium\PhD\Github\Single-Author\Code\News')

#import sys
#sys.path.append(r"D:\Studium\PhD\Github\Single-Author\Code\News")

from dataprep import tokenizer_articles, tokenize_sentences, lemmatize_sentences
from dataprep_mp import  process_data_tokenizer_articles 

data = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\dpa\dpa_prepro_final.csv', encoding = 'utf-8', index_col = 0,  keep_default_na=False,
                   dtype = {'rubrics': 'str', 
                            'source': 'str',
                            'keywords': 'str',
                            'title': 'str',
                            'city': 'str',
                            'genre': 'str',
                            'wordcount': 'str'},
                  converters = {'paragraphs': literal_eval})

data = data.drop(columns=['Unnamed: 0', 'Unnamed: 0.1', 'Unnamed: 0.1.1', 'Unnamed: 0.1.1.1'])

data = data[0:10000]

start_time = time.time()

data = tokenizer_articles(data, 'german')

end_time = time.time()

execution_time = end_time - start_time

print(f"The function took {execution_time} seconds to run.")

start_time = time.time()

tokens = [tokenize_sentences(sentence, 'german')[0] for sentence in sentences['texts']]

end_time = time.time()

execution_time = end_time - start_time

print(f"The function took {execution_time} seconds to run.")

start_time = time.time()

lemmas = lemmatize_sentences(sentences['texts'], 'german', 'all')

end_time = time.time()

execution_time = end_time - start_time

print(f"The function took {execution_time} seconds to run.")

####

NUM_CORE = mp.cpu_count()

# Calculate chunk size
chunk_size = int(data.shape[0] / NUM_CORE)

# Split data into chunks
chunks = [data.iloc[data.index[i:i + chunk_size]] for i in range(0, data.shape[0], chunk_size)]

# Tokenize articles in parallel
start_time = time.time()

if __name__ == "__main__":
    with ProcessPoolExecutor(max_workers=NUM_CORE) as executor:
        sentences = list(executor.map(process_data_tokenizer_articles, chunks))

sentences = pd.concat(sentences)

sentences.to_csv(r'D:\Studium\PhD\Single Author\Data\dpa\dpa_prepro_final_sentences.csv')

tokens = [tokenize_sentences(sentence, 'german')[0] for sentence in sentences['texts']]

lemmas = lemmatize_sentences(sentences['texts'], 'german', 'all')

end_time = time.time()
execution_time = end_time - start_time
print(f"The lemmatize_sentences function took {execution_time} seconds to run.")
