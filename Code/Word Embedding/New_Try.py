# -*- coding: utf-8 -*-
"""
Created on Wed Jun 21 21:07:38 2023

@author: Ja-ba
"""

from gensim.models import Word2Vec
import nltk
import pandas as pd
from tqdm import tqdm
import pickle
tqdm.pandas()

len1 = 1050493

# Load the first half of the data
data = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\dpa\dpa_prepro_final.csv', encoding = 'utf-8', index_col = None,  keep_default_na=False, usecols=['texts'], sep = ";", nrows=len1) # adjust nrows to your needs

# Tokenize the first half
tokens1 = data['texts'].progress_apply(nltk.word_tokenize).tolist()

# Save the first half
with open('D:\\Studium\\PhD\\Single Author\\Data\dpa\\dpa_prepro_final_tokens1.pkl', 'wb') as f:
    pickle.dump(tokens1, f)

# Clear the memory
del data
del tokens1

# Load the second half of the data
data = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\dpa\dpa_prepro_final.csv', encoding = 'utf-8', index_col = None,  keep_default_na=False, usecols=['texts'], sep = ";", skiprows = range(1, len1)) # adjust skiprows to your needs

# Tokenize the second half
tokens2 = data['texts'].progress_apply(nltk.word_tokenize).tolist()

# Save the second half
with open('D:\\Studium\\PhD\\Single Author\\Data\\dpa\\dpa_prepro_final_tokens2.pkl', 'wb') as f:
    pickle.dump(tokens2, f)

# Clear the memory
del data
del tokens2

# Load both halves
with open('D:\\Studium\\PhD\\Single Author\\Data\dpa\\dpa_prepro_final_tokens1.pkl', 'rb') as f:
    tokens1 = pickle.load(f)

with open('D:\\Studium\\PhD\\Single Author\\Data\\dpa\\dpa_prepro_final_tokens2.pkl', 'rb') as f:
    tokens2 = pickle.load(f)
    
tokens = tokens1 + tokens2

# Save the combined tokens
with open('D:\\Studium\\PhD\\Single Author\\Data\\dpa\\dpa_prepro_final_tokens.pkl', 'wb') as f:
    pickle.dump(tokens, f)

import logging

logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)

model = Word2Vec(tokens1, vector_size=100, window=5, min_count=1, workers=4)

model.save("D:\\Studium\\PhD\\Single Author\\Data\dpa\\word2vec_V1.model")

model.train(tokens2, total_examples=model.corpus_count, epochs=model.epochs)

model.wv.most_similar("inflation")