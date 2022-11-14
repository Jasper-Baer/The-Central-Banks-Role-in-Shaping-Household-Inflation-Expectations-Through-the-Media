# -*- coding: utf-8 -*-
"""
Created on Wed Aug 17 22:18:09 2022

@author: jbaer
"""

import pandas as pd
import numpy as np
import json
import os

import pylab as plt


from nltk.tokenize import word_tokenize
from collections import Counter
from ast import literal_eval
from tqdm import tqdm

PATH = r"D:\Studium\PhD\Github\Single-Author\Code\Unsupervised"

os.chdir(PATH)

from PR_index_supp import prepare_text, count_ngrams, create_dict, create_index

# f = open('D:\Studium\PhD\Single Author\Data\ECB\press_conferences_cleaned.json')
# data_json = json.load(f)
# data = pd.read_json(data_json)

data = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\inflation_lemmas_example.xlsx')
data = data[0:2000]

label_direction = data['Direction']
label_sentiment = data['Sentiment']

#data = data.rename(columns = {'sentence': 'Sentences', 'Direction' : 'Label'})[['Sentences', 'Label']]
#data = data.rename(columns = {'sentence': 'Sentences'})

data['tokens'] = prepare_text(data['sentence']).preproces_text()

##############################################################################
# Direction
##############################################################################

data['Label'] = label_direction

word_dict, n_grams = count_ngrams(data)
direction_lex = create_dict(word_dict, n_grams, 'direction')
#direction_lex.drop(['n_grams'], axis = 1, inplace = True)

##############################################################################
# Sentiment
##############################################################################

data['Label'] = label_sentiment

word_dict, n_grams = count_ngrams(data)
sentiment_lex = create_dict(word_dict, n_grams, 'sentiment')
sentiment_lex.drop(['n_grams'], axis = 1, inplace = True)

PR_lex_full = pd.concat([direction_lex, sentiment_lex], axis=1)
PR_lex_full['tokens'] = [word_tokenize(keyword) for keyword in PR_lex_full['n_grams']]

#PR_lex_full.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\PR_lex_news.xlsx')
PR_lex_full = pd.read_excel(r'D:\Studium\PhD\Github\Single-Author\Data\PR_lex_news.xlsx')
PR_lex_full['tokens'] = PR_lex_full['tokens'].apply(lambda x: literal_eval(str(x)))

idx_null = PR_lex_full[PR_lex_full['n_grams'] != PR_lex_full['n_grams']].index[0]
# PR_lex_full = PR_lex_full.loc[PR_lex_full['n_grams'] == idx_null, 'n_grams'] = 'abc'

PR_lex_full.loc[[idx_null], 'n_grams'] = 'null'

PR_lex_dir = PR_lex_full[['n_grams', 'tokens', 'positive direction index', 'neutral direction index', 'negative direction index']]
PR_lex_dir = PR_lex_dir.rename(columns = {'n_grams': 'keyword', 'positive direction index' : 'positive','neutral direction index' : 'neutral','negative direction index' : 'negative'})

PR_lex_sent = PR_lex_full[['n_grams', 'tokens', 'positive sentiment index', 'neutral sentiment index', 'negative sentiment index']]
PR_lex_sent = PR_lex_sent.rename(columns = {'n_grams': 'keyword', 'positive sentiment index' : 'positive','neutral sentiment index' : 'neutral','negative sentiment index' : 'negative'})

data_inf = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\inflation_lemmas_examplev02.xlsx')
#data_inf = data_inf.rename(columns = {'sentence': 'Sentences'})

data_inf['tokens'] = prepare_text(data_inf['sentence']).preproces_text()

data_sent = pd.read_csv('D:\Studium\PhD\Single Author\Data\dpa_sents_v01.csv')

#data_inf = data_inf.sample(5000)
idx = data_inf['index']

data_final = data_sent.iloc[idx]

dates = [str(int(year)) + ' ' + str(int(month)) + ' ' + str(int(day)) for year,month, day in zip(list(data_final['year']),list(data_final['month']), list(data_final['day']))]
dates = pd.to_datetime(dates, format = '%Y %m %d')

data_inf['date'] = dates

data_dir = create_index(data_inf, PR_lex_dir)
data_sent = create_index(data_inf, PR_lex_sent)

# data_dir.to_csv('D:\Studium\PhD\Github\Single-Author\Data\PR_news_direction_results.csv')
# data_sent.to_csv('D:\Studium\PhD\Github\Single-Author\Data\PR_news_sentiment_results.csv')
##############################################################################
# PR_lex = pd.read_csv('D:\Studium\PhD\Github\Single-Author\Data\export_lexicon.csv', delimiter=';')
# PR_lex['tokens'] = [word_tokenize(keyword) for keyword in PR_lex['keyword']]
PR_News_lex['tokens'] = [word_tokenize(keyword) for keyword in PR_News_lex['n_grams']]

# PR_lex = pd.read_csv('D:\Studium\PhD\Github\Single-Author\Data\export_lexicon.csv', delimiter=';')
# PR_lex['tokens'] = [word_tokenize(keyword) for keyword in PR_lex['keyword']]
#mp_acc_words = PR_lex[PR_lex['mp_acco'] > 0.5]

def prepare_date(data):
    
    data = data.sort_values('date')
    monthly_data = data.groupby(data['date'].dt.strftime('%Y-%m')).mean()
    yearly_data = data.groupby(data['date'].dt.strftime('%Y')).mean()
    
    return(data, monthly_data, yearly_data)

data_dir, monthly_dir, yearly_dir = prepare_date(data_dir)
data_sent, monthly_sent, yearly_sent = prepare_date(data_sent)

plt.stackplot(data_dir['date'], np.array(data_dir[['pos share', 'neu share', 'neg share']]).transpose())      
plt.plot(data_dir['date'], data_dir['index']) 

plt.stackplot(data_sent['date'], np.array(data_sent[['pos share', 'neu share', 'neg share']]).transpose())      
plt.plot(data_sent['date'], data_sent['index']) 

plt.stackplot(pd.to_datetime(monthly_dir.index), np.array(monthly_dir[['pos share', 'neu share', 'neg share']]).transpose())
plt.show()

plt.plot(pd.to_datetime(monthly_dir.index), monthly_dir['index']) 
plt.show()

plt.stackplot(pd.to_datetime(monthly_sent.index), np.array(monthly_sent[['pos share', 'neu share', 'neg share']]).transpose())
plt.plot(pd.to_datetime(monthly_sent.index), monthly_sent['index']) 

plt.plot(pd.to_datetime(monthly_sent.index), monthly_sent['index']) 
plt.show()

plt.stackplot(pd.to_datetime(yearly_dir.index), np.array(yearly_dir[['pos share', 'neu share', 'neg share']]).transpose())
plt.show()

plt.plot(pd.to_datetime(yearly_dir.index), yearly_dir['index']) 
plt.show()

plt.stackplot(pd.to_datetime(yearly_sent.index), np.array(yearly_sent[['pos share', 'neu share', 'neg share']]).transpose())
plt.show()

plt.plot(pd.to_datetime(yearly_sent.index), yearly_sent['index']) 
plt.show()

##############################################################################

plt.plot(data_picault['date'], data_picault['ecc index']) 
plt.plot(data['date'], data['index ec']) 

plt.plot(data_picault['date'], data_picault['money index']) 
plt.plot(data['date'], np.array(data['index mon'])*-1) 

data = data.to_json()

with open('D:\Studium\PhD\Github\Single-Author\Data\speeches_index_index.json', 'w+', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=4)

mp_acco_list = []
mp_neut_list = []
mp_rest_list = []

ec_nega_list = []
ec_neut_list = []
ec_posi_list = []

index_mon_list = []
index_ec_list = []

for tokens in tqdm(data['tokens']):
    
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
    
