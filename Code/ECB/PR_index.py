# -*- coding: utf-8 -*-
"""
Created on Wed Aug 17 22:18:09 2022

@author: jbaer
"""

import pandas as pd
import numpy as np
import json
import re

from nltk.tokenize import word_tokenize
from collections import Counter
from dataprep import tokenizer_articles
import nltk

import pylab as plt
import string as st
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from nltk.stem import PorterStemmer
from tqdm import tqdm

# f = open('D:\Studium\PhD\Single Author\Data\ECB\press_conferences_cleaned.json')
  
# data_json = json.load(f)

# data = pd.read_json(data_json)

data = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\dpa_dir_labels_test.csv')

def clean_speech(speech):
    
    # remove numbers
    speech = re.sub(r'\d+', '', speech)
    
    # define punctations
    punct = st.punctuation + ('“”–€–’')
    
    # remove punctuations and convert characters to lower case
    speech = "".join([char.lower() for char in speech if char not in punct]) 
    
    # replace multiple whitespace with single whitespace and remove leading and trailing whitespaces
    speech = re.sub('\s+', ' ', speech).strip()
    
    return (speech)

port_stemmer = PorterStemmer()

tokens_speeches = []

# for speech in data['speeches']:
    
#     speech = ' '.join(speech)
    
#     speech = clean_speech(speech)
#     tokens_speech = word_tokenize(speech)
    
#     stop_words = set(stopwords.words('english'))   

    
#     filtered_speech = [port_stemmer.stem(w) for w in tokens_speech]
#     filtered_speech = [w for w in filtered_speech if not w in stop_words]
    
#     tokens_speeches.append(filtered_speech)
    
for speech in data['text']:
    
    #speech = ' '.join(speech)
    
    speech = clean_speech(speech)
    tokens_speech = word_tokenize(speech)
    
    stop_words = set(stopwords.words('german')) 
    
    filtered_speech = [port_stemmer.stem(w) for w in tokens_speech]
    filtered_speech = [w for w in filtered_speech if not w in stop_words]
    
    tokens_speeches.append(filtered_speech)

data['tokens_speeches'] = tokens_speeches
direction_lex = dict()

for tokens in tqdm(data['tokens_speeches']):
    
    # Go through each n-gram from 10-gram to 1-gram (starting at 10-grams) where n = j
    for j in reversed(range(1,11)):
        
        # Split tokens into j-grams
        grams = [tokens[i:i+j] for i in range(len(tokens)-j+1)]
        
        if len(grams) != 0:
        
            for token in grams:
                
                if len(token) > 1:
                  
                    token = ' '.join(token)
                        
                    if token in direction_lex.keys():
                        
                        direction_lex[token] += 1
                    
                    else:
                        
                        direction_lex[token] = 1
                        
direction_lex = {word:count for word, count in direction_lex.items() if count >1}
        

##############################################################################
PR_lex = pd.read_csv('D:\Studium\PhD\Github\Single-Author\Data\export_lexicon.csv', delimiter=';')
PR_lex['tokens'] = [word_tokenize(keyword) for keyword in PR_lex['keyword']]

#mp_acc_words = PR_lex[PR_lex['mp_acco'] > 0.5]

mp_acco_list = []
mp_neut_list = []
mp_rest_list = []

ec_nega_list = []
ec_neut_list = []
ec_posi_list = []

index_mon_list = []
index_ec_list = []

for tokens in tqdm(data['tokens_speeches']):
    
    mp_acco = 0
    mp_neut = 0
    mp_rest = 0
    
    ec_nega = 0
    ec_neut = 0
    ec_posi = 0
    
    # Go through each n-gram from 8-gram to 1-gram (starting at 8-grams) where n = j
    for j in reversed(range(1,9)):
        
        # Split tokens into j-grams
        grams = [tuple(tokens[i:i+j]) for i in range(len(tokens)-j+1)]
        
        # Count j-grams
        counts = dict(Counter(grams))
        
        # Filter out all j-grams from lexicon
        keywords = [tuple(ngram) for ngram in PR_lex['tokens'] if len(ngram) == j]
        
        # Delete all n-grams from tokens which are not j-grams
        keywords_speech = dict([(k,v) for k,v in counts.items() if k in keywords])
        
        # Count all lexicon j-grams in tokens und multiply the number of their 
        # occurrences with their respective probabilities
        for k,v in keywords_speech.items():
            
            k = ' '.join(k)
            keyword_prob = PR_lex[PR_lex['keyword'] == k]
            
            mp_acco += float(keyword_prob['mp_acco']*v)
            mp_neut += float(keyword_prob['mp_neut']*v)
            mp_rest += float(keyword_prob['mp_rest']*v)
            
            ec_nega += float(keyword_prob['ec_nega']*v)
            ec_neut += float(keyword_prob['ec_neut']*v)
            ec_posi += float(keyword_prob['ec_posi']*v)
        
        # ?????
        # for keyword in keywords_speech:
        
        #     ind = [range(i,i+len(keyword)) for i,x in enumerate(tokens) if tokens[i:i+len(keyword)] == keyword]
        #     ind_set = set([item for sublist in ind for item in sublist])
        #     tokens = [x for i,x in enumerate(tokens) if i not in ind_set]     
      
    mp_all = mp_acco + mp_neut + mp_rest
    ec_all = ec_nega + ec_neut+ ec_posi
    
    mp_acco_ov = mp_acco/mp_all
    mp_neut_ov = mp_neut/mp_all
    mp_rest_ov = mp_rest/mp_all
    
    ec_nega_ov = ec_nega/ec_all
    ec_neut_ov = ec_neut/ec_all
    ec_posi_ov = ec_posi/ec_all
    
    mp_acco_list.append(mp_acco_ov)
    mp_neut_list.append(mp_neut_ov)
    mp_rest_list.append(mp_rest_ov)
    
    ec_nega_list.append(ec_nega_ov)
    ec_neut_list.append(ec_neut_ov)
    ec_posi_list.append(ec_posi_ov)
    
    index_mon = mp_acco_ov - mp_rest_ov
    index_ec = ec_posi_ov - ec_nega_ov
    
    index_mon_list.append(index_mon)
    index_ec_list.append(index_ec)

data['mp acco'] = mp_acco_list
data['mp neut'] = mp_neut_list
data['mp rest'] = mp_rest_list

data['ec nega'] = ec_nega_list
data['ec neut'] = ec_neut_list
data['ec posi'] = ec_posi_list   

data['index mon'] = index_mon_list 
data['index ec'] = index_ec_list 

data['date'] = pd.to_datetime(data['date'])

plt.stackplot(data['date'], np.array(data[['mp acco', 'mp neut', 'mp rest']]).transpose())      
plt.stackplot(data['date'], np.array(data[['ec posi', 'ec neut', 'ec nega']]).transpose())  
plt.plot(data['date'], data['index mon']) 
plt.plot(data['date'], data['index ec']) 

plt.plot(data_picault['date'], data_picault['ecc index']) 
plt.plot(data['date'], data['index ec']) 

plt.plot(data_picault['date'], data_picault['money index']) 
plt.plot(data['date'], np.array(data['index mon'])*-1) 

data = data.to_json()

with open('D:\Studium\PhD\Github\Single-Author\Data\speeches_index_index.json', 'w+', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=4)
    
