# -*- coding: utf-8 -*-
"""
Created on Thu May 18 11:01:28 2023

@author: Ja-ba
"""

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
                  converters = {'paragraphs': literal_eval}, sep = ";")

data.drop(columns = ['day', 'month', 'year', 'source', 'paragraphs', 'word_count', 'wordcount', 'language', 'topic'], inplace = True)

start_time = time.time()

data = tokenizer_articles(data, 'german')

end_time = time.time()

execution_time = end_time - start_time

print(f"The function took {execution_time} seconds to run.")

data = data.explode('texts')
data.reset_index(drop = True, inplace = True)

data.to_csv(r'D:\Studium\PhD\Single Author\Data\dpa\dpa_prepro_final_sentences_no_lemmas_no_tokens.csv')

data = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\dpa\dpa_prepro_final_sentences_no_lemmas_no_tokens.csv', encoding = 'utf-8', index_col = 0,  keep_default_na=False,
                   dtype = {'rubrics': 'str', 
                            'source': 'str',
                            'keywords': 'str',
                            'title': 'str',
                            'city': 'str',
                            'genre': 'str',
                            'texts': 'str'})

def check_entry(entry):
    if pd.isnull(entry): # Check if entry is null
        return True
    if not isinstance(entry, str): # Check if entry is not a string
        return True
    if entry.strip() == "": # Check if entry is an empty string
        return True
    return False

a = data
print(a[a['texts'].apply(check_entry)])


data.dropna(subset=['texts'], inplace=True)
non_empty = data['texts'].apply(lambda x: isinstance(x, str) and x.strip() != "")

data = data.loc[non_empty]

###############################################################################

# half_data = data[:len(data)//2]

# start_time = time.time()

# tokens = [tokenize_sentences(sentence, 'german')[0] for sentence in half_data['texts']]

# end_time = time.time()

# execution_time = end_time - start_time

# print(f"The function took {execution_time} seconds to run.")


# half_data['tokens'] = tokens

# half_data.to_csv(r'D:\Studium\PhD\Single Author\Data\dpa\dpa_prepro_final_sentences_no_lemmas_half.csv')

# start_time = time.time()

# # slice the list to get the second half
# second_half_data = data[len(data)//2:]

# tokens = [tokenize_sentences(sentence, 'german')[0] for sentence in second_half_data['texts']]

# end_time = time.time()

# execution_time = end_time - start_time

# print(f"The function took {execution_time} seconds to run.")

# second_half_data['tokens'] = tokens

# second_half_data.to_csv(r'D:\Studium\PhD\Single Author\Data\dpa\dpa_prepro_final_sentences_no_lemmas_half_2.csv')

# first_half = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\dpa\dpa_prepro_final_sentences_no_lemmas_half_2.csv', encoding = 'utf-8', index_col = 0,  keep_default_na=False,
#                    dtype = {'rubrics': 'str', 
#                             'source': 'str',
#                             'keywords': 'str',
#                             'title': 'str',
#                             'city': 'str',
#                             'genre': 'str'},
#                            converters={'tokens': literal_eval})

#data['tokens'] = tokens
# data = pd.concat([first_half, second_half_data])

# data.to_csv(r'D:\Studium\PhD\Single Author\Data\dpa\dpa_prepro_final_sentences_no_lemmas_full.csv')

###############################################################################

import pandas as pd
from ast import literal_eval

# Determine number of rows in the file
total_rows = sum(1 for line in open(r'D:\Studium\PhD\Single Author\Data\dpa\dpa_prepro_final_sentences_no_lemmas_no_tokens.csv', encoding="utf8")) - 1

# Set chunk size
chunk_size = total_rows // 10  # We'll process the data in 10 chunks

# Counter for naming the chunks
chunk_count = 1

for chunk in pd.read_csv(
        r'D:\Studium\PhD\Single Author\Data\dpa\dpa_prepro_final_sentences_no_lemmas_no_tokens.csv', 
        chunksize=chunk_size, 
        encoding='utf-8', 
        index_col=0,  
        keep_default_na=False,
        dtype={
            'rubrics': 'str', 
            'source': 'str',
            'keywords': 'str',
            'title': 'str',
            'city': 'str',
            'genre': 'str',
            'texts': 'str'
        }
    ):
    
    chunk.dropna(subset=['texts'], inplace=True)
    non_empty = chunk['texts'].apply(lambda x: isinstance(x, str) and x.strip() != "")

    chunk = chunk.loc[non_empty]
    
    start_time = time.time()
    
    lemmas = lemmatize_sentences(chunk['texts'], 'german', 'all')
    
    # Add the lemmas to the chunk DataFrame
    chunk['lemmas'] = lemmas
    
    # Save the processed chunk as a separate CSV file
    chunk.to_csv(f'D:\Studium\PhD\Single Author\Data\dpa\chunk_{chunk_count}_lemmas.csv')
    
    end_time = time.time()
    execution_time = end_time - start_time
    print(f"Processed chunk {chunk_count} in {execution_time} seconds.")
    print(chunk_count)
    
    # Increment the chunk count
    chunk_count += 1

# Concatenate all chunks into a single DataFrame
final_df = pd.DataFrame()

for i in range(1, chunk_count):
    chunk_df = pd.read_csv(f'D:\Studium\PhD\Single Author\Data\dpa\chunk_{i}_lemmas.csv', index_col=0)
    final_df = pd.concat([final_df, chunk_df])

# Save the final DataFrame
final_df.to_csv(r'D:\Studium\PhD\Single Author\Data\dpa\dpa_prepro_final_sentences_no_lemmas_full_with_lemmas.csv')
 


# start_time = time.time()

# lemmas = lemmatize_sentences(data['texts'], 'german', 'all')

# end_time = time.time()

# execution_time = end_time - start_time

# print(f"The function took {execution_time} seconds to run.")

# data['lemmas'] = lemmas


####



# NUM_CORE = mp.cpu_count()

# # Calculate chunk size
# chunk_size = int(data.shape[0] / NUM_CORE)

# # Split data into chunks
# chunks = [data.iloc[data.index[i:i + chunk_size]] for i in range(0, data.shape[0], chunk_size)]

# # Tokenize articles in parallel
# start_time = time.time()

# if __name__ == "__main__":
#     with ProcessPoolExecutor(max_workers=NUM_CORE) as executor:
#         sentences = list(executor.map(process_data_tokenizer_articles, chunks))

# sentences = pd.concat(sentences)

# sentences.to_csv(r'D:\Studium\PhD\Single Author\Data\dpa\dpa_prepro_final_sentences.csv')

# tokens = [tokenize_sentences(sentence, 'german')[0] for sentence in sentences['texts']]

# lemmas = lemmatize_sentences(sentences['texts'], 'german', 'all')

# end_time = time.time()
# execution_time = end_time - start_time
# print(f"The lemmatize_sentences function took {execution_time} seconds to run.")
