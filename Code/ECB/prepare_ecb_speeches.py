# -*- coding: utf-8 -*-
"""
Created on Wed Apr  6 23:10:18 2022

@author: jbaer
"""

import pandas as pd
import nltk.data

import os
import multiprocessing as mp
import identify_eng_2

# Set the number of cores to use
NUM_CORE = mp.cpu_count()

PATH = r"D:\Studium\PhD\Fischerei\Code"
os.chdir(PATH)

import count_words

data = pd.read_csv('D:\\Studium\\PhD\\Single Author\\Data\\ECB\\Speeches\\all_ECB_speeches_repaired.csv', encoding = 'cp1252', index_col=0)

col_names = ('date', 'speaker', 'heading', 'description', 'speech')

data.columns = col_names

data.dropna(subset = ['speech'], inplace = True)

data['speech'] = data['speech'].str.replace(r'(^\s+Speech\s+|^\s+SPEECH\s+)', '', regex=True)
data['speech'] = data['speech'].str.replace(r'\s*;{2,}', '', regex=True)
data['speech'] = data['speech'].str.replace(r'\[\d{1,2}\]', '', regex=True)

data.reset_index(inplace = True, drop = True)

from datetime import datetime
startTime = datetime.now()

if __name__ == "__main__":
    pool = mp.Pool(NUM_CORE)
    count_results = pool.map(count_words.count_words, [speech for speech in data['speech']]) 
    pool.close()
    pool.join()
    
print(datetime.now()-startTime)

data['word_count'] = count_results
data = data[data['word_count']>=150]
data.reset_index(inplace = True, drop = True)

# Delete all English articles from the data  
startTime = datetime.now()

if __name__ == "__main__":
    pool = mp.Pool(NUM_CORE)
    eng_results = pool.map(identify_eng_2.identify_eng_2, [text for text in data['speech']]) 
    pool.close()
    pool.join()

print(datetime.now()-startTime)

data['language'] = eng_results
data = data[data.language==1]
data.reset_index(inplace=True, drop=True)
print(len(data))

tokenizer = nltk.data.load('tokenizers/punkt/english.pickle')

data['article ID'] = data.index + 1

sentences_df = pd.DataFrame()

startTime = datetime.now()

for idx in data.index:
    
    sentences = tokenizer.tokenize(data['speech'].iloc[idx])
    
    for sentence in sentences:
        
        sentence_data = {'article ID': data['article ID'].iloc[idx], 'sentence': sentence}
        
        sentences_df = sentences_df.append(sentence_data, ignore_index=True)
        
print(datetime.now()-startTime)
        
from datetime import datetime
startTime = datetime.now()

if __name__ == "__main__":
    pool = mp.Pool(NUM_CORE)
    count_results = pool.map(count_words.count_words, [speech for speech in sentences_df['sentence']]) 
    pool.close()
    pool.join()
    
print(datetime.now()-startTime)

sentences_df['word_count'] = count_results
sentences_df = sentences_df[sentences_df['word_count']>=3]        
sentences_df.reset_index(inplace = True, drop = True)

sentences_df.to_csv('D:/Studium/PhD/Single Author/Data/ECB/Speeches/ecb_speeches_sentences.csv')
sentences_df.to_excel('D:/Studium/PhD/Single Author/Data/ECB/Speeches/ecb_speeches_sentences.xlsx')