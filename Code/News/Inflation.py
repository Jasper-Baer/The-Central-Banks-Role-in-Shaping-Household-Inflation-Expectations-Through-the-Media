# -*- coding: utf-8 -*-
"""
Created on Sun Aug 21 19:18:29 2022

@author: Nutzer
"""

import pandas as pd
from dataprep import tokenizer_articles, lemmatize_sentences
import matplotlib.pyplot as plt
from nltk.tokenize import word_tokenize 
import ast

data = pd.read_csv('D:\Studium\PhD\Media Tenor\Results\dpa_prepro_step9.csv')

data = data.sample(100000)
data = data.reset_index()
data = data.rename(columns = {'texts' : 'text'})
data.to_csv('D:\Studium\PhD\Media Tenor\Results\dpa_sample.csv')

data_sent = tokenizer_articles(data[0:500])

data_lem = lemmatize_sentences(data['text'])
data['lemmas'] = data_lem 

#data.to_csv('D:\Studium\PhD\Media Tenor\Results\dpa_lemmas_test.csv')

inflation_share = []
inflation = []
inflation

for year in range(1998,2019):
  
    data_yearly = data[data['year'] == year]
    yearly_lemmas = ' '.join(data_yearly['lemmas'])
    
    tokens = word_tokenize(yearly_lemmas)
    
    inflation.append(tokens.count('inflation')/len(tokens))
    
    inflation_share.append(len([1 for article in data_yearly['lemmas'] if 'inflation' in article or 'inflations' in article])/len(data_yearly))

plt.plot(range(1998,2019), inflation_share)
plt.plot(range(1998,2019), inflation)

data_sent = pd.read_csv('D:\Studium\PhD\Single Author\Data\data_sents_dpa_test3.csv')
data_lemmas = pd.read_csv('D:\Studium\PhD\Media Tenor\Results\dpa_lemmas_test.csv')
data = pd.read_csv('D:\Studium\PhD\Single Author\Data\dpa_sents_v01.csv')

data_sent.reset_index(inplace = True)

for art in data_sent['sentences']:
    
    art = ast.literal_eval(art)
    art = word_tokenize(art)
    # art = [n.strip() for n in art]
    
    lem_sent = [lemmatize_sentences(word_tokenize(sent)) for sent in art]

data_lem_sent = lemmatize_sentences(data_sent['text'])
data_sent['lemmas'] = data_lem_sent

inflation_synonyms = ['Inflation', 'Teuerung' , 'Verteuerung' , 'Preisanstieg', 'Preiserhöhung', 'Inflations']
inflation_synonyms = [word.lower() for word in inflation_synonyms]

inflation_lemmas = pd.DataFrame()

#any(word in inflation_synonyms for word in sent)

for idx, art in enumerate(data['sentences']):
    
    art = ast.literal_eval(art)
    
    for sent in art:
        
        if any(word in inflation_synonyms for word in word_tokenize(sent.lower())):
        
            inflation_lemmas = inflation_lemmas.append({'sentence' : sent, 'index': idx}, ignore_index=True)
    
    if idx%100000 == 0:
        print(idx) 
        
for idx, sent in enumerate(data_sent['sentence']):
    
   # art = ast.literal_eval(art)
    
   # for sent in art:
        
    if any(word in inflation_synonyms for word in word_tokenize(sent.lower())):
    
        inflation_lemmas = inflation_lemmas.append({'sentence' : sent, 'index': idx}, ignore_index=True)
    
    if idx%1000000 == 0:
        print(idx) 

# pd.DataFrame(inflation_lemmas).to_excel('D:\Studium\PhD\Single Author\Data\inflation_lemmas_examplev02.xlsx')    

inflation_lemmas = pd.read_csv('D:\Studium\PhD\Single Author\Data\inflation_lemmas_example.csv')
    