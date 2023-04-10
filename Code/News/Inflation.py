# -*- coding: utf-8 -*-
"""
Created on Sun Aug 21 19:18:29 2022

@author: Nutzer
"""

import pandas as pd
from nltk.tokenize import word_tokenize 
import ast
from tqdm import tqdm

import nltk
import stanza

import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)

#stanza.download('de')
nlp = stanza.Pipeline(processors= 'lemma,tokenize,pos,depparse', lang = 'de')

data = pd.read_csv('D:\Studium\PhD\Single Author\Data\dpa_sents_v01.csv')

word_list = [
    'Deflation',
    'Geldentwertung',
    'Geldwert',
    'Hyperinflation',
    'Inflation',
    'Inflations',
    'Inflationsrate',
    'Kaufkraft',
    'Lebenshaltungskosten',
    'Preisanstieg',
    'Preiserhöhung',
    'Preisindex',
    'Preisniveau',
    'Teuerung',
    'Verbraucherpreisindex',
    'Verteuerung',
    'Warenkorb'
]
# word_list_ecb_two_words = [
#     "Wim Duisenberg",           # President of the ECB (1998-2003)
#     "Jean-Claude Trichet",      # President of the ECB (2003-2011)
#     "Mario Draghi",             # President of the ECB (2011-2019)
#     "Christine Lagarde",        # President of the ECB (2019-Present, as of Sept 2021)

#     "Christian Noyer",          # Vice-President of the ECB (1998-2002)
#     "Lucas Papademos",          # Vice-President of the ECB (2002-2010)
#     "Vítor Constâncio",         # Vice-President of the ECB (2010-2018)
#     "Luis de Guindos",          # Vice-President of the ECB (2018-Present, as of Sept 2021)

#     # Executive Board Members
#     "Sirkka Hämäläinen",        # (1998-2003)
#     "Tommaso Padoa-Schioppa",   # (1998-2005)
#     "Eugenio Domingo Solans",   # (1998-2004)
#     "Otmar Issing",             # (1998-2006)
#     "José Manuel González-Páramo",  # (2004-2012)
#     "Jürgen Stark",             # (2006-2011)
#     "Lorenzo Bini Smaghi",      # (2005-2011)
#     "Peter Praet",              # (2011-2019)
#     "Jörg Asmussen",            # (2012-2013)
#     "Sabine Lautenschläger",    # (2014-2019)
#     "Benoît Cœuré",             # (2012-2019)
#     "Yves Mersch",              # (2012-2020)
#     "Isabel Schnabel",          # (2020-Present)
#     "Philip R. Lane",           # (2019-Present)
#     "Fabio Panetta",            # (2020-Present)
#     "Frank Elderson",           # (2021-Present)
    
#     ]

word_list_ecb = [
    
    "EZB",
    "Europäische Zentralbank"
    "EZB-Präsident", 
    "EZB-Präsidentin", 
    "EZB-Vizepräsident",
    "Duisenberg",
    "Trichet",
    "Draghi",
    "Lagarde",
    "Noyer",
    "Papademos",
    "Constâncio",
    "de Guindos",
    "Hämäläinen",
    "Padoa-Schioppa",
    "Domingo Solans",
    "Issing",
    "González-Páramo",
    "Stark",
    "Bini Smaghi",
    "Praet",
    "Asmussen",
    "Lautenschläger",
    "Cœuré",
    "Mersch",
    "Schnabel",
    "Lane",
    "Panetta",
    "Elderson"
    
]

word_list = [word.lower() for word in word_list]
word_list_ecb = [word.lower() for word in word_list_ecb]

filtered_lemmas = pd.DataFrame()
ecb_sentences = pd.DataFrame()

dependency_df= pd.DataFrame()

for idx, art in tqdm(enumerate(data['sentences'])):
    
    art = ast.literal_eval(art)
    
    for sent in art:
        
        tokens = word_tokenize(sent.lower())
        
        found_names = set()
        
        if any(word in word_list for word in tokens):
        
            filtered_lemmas = filtered_lemmas.append({'sentence' : sent, 'index': idx}, ignore_index=True)
            
            for i in range(len(tokens) - 1):
                
                if tokens[i] in word_list_ecb:
                    
                    found_names.add(tokens[i])
                    
            
                
                # if i < len(tokens) - 1:
                    
                #     combined_name = f"{tokens[i]} {tokens[i + 1]}"
                    
                #     if combined_name in word_list_ecb_two_words:
                #         found_names.add(combined_name)
                        
                #         print(combined_name)
                        
            if len(found_names) > 0:
                
                ecb_sentences = ecb_sentences.append({'sentence' : sent, 'index': idx}, ignore_index=True) 

for ecb_sentence in  ecb_sentences['sentence']:

    dependencies = []
    
    if any(word in word_list_ecb for word in word_tokenize(sent.lower())):
    
        nlp_pars = nlp(sent)
        
        for sentence in  nlp_pars.sentences:
        
            for dep in sentence.dependencies:
                dependencies.append((dep[2].text, dep[0].id, dep[1], dep[2].id))
            
            dependency_df = dependency_df.append({'dependencies' : dependencies, 'index': idx}, ignore_index=True)

filtered_ecb_sentences = []
                
for ecb_sentence in dependency_df.iterrows():
    
    deps = ecb_sentence[1]['dependencies']
    reporting_verbs = ['sagte', 'sehen', 'geht', 'berichtet', 'meinen', 'erwarten', 'vorhergesagt']
    
    subj = None
    root = None
    sent_in_ecb = False
    
    for dep in deps:
        
        if dep[2] in ["nsubj", "nsubjpass"]:
            
            subj = dep
            
            if subj[0].lower() in word_list_ecb:
                
                sent_in_ecb = True
                
        elif dep[2] in ['obj', 'iobj']:
            
            if dep[0].lower() in word_list_ecb:
                
                obj_dep = dep[1]
                
                if deps[obj_dep] in reporting_verbs:
                    
                    sent_in_ecb = True
                
    if sent_in_ecb == True:
        
        filtered_ecb_sentences.append(ecb_sentence)
              
ecb_data = data[ data.index.isin(ecb_sentences['index'])]
ecb_data['date'] = pd.to_datetime(ecb_data[['year', 'month', 'day']])

news_data_full = data[ data.index.isin(filtered_lemmas['index'])]
news_data_full['date'] = pd.to_datetime(news_data_full[['year', 'month', 'day']])

news_data_full.set_index('date', inplace=True)
ecb_data.set_index('date', inplace=True)

ecb_data.to_csv(r'D:\Studium\PhD\Single Author\Data\ecb_data.csv')
news_data_full.to_csv(r'D:\Studium\PhD\Single Author\Data\news_data_full_inflation.csv')

import matplotlib.pyplot as plt

# Resample the DataFrame by month and count the number of rows in each month
monthly_counts_ecb = ecb_data.resample('M').size()
monthly_counts_full_data = news_data_full.resample('M').size()

monthly_counts = monthly_counts_ecb/monthly_counts_full_data

# Plot the number of rows in each month
monthly_counts.plot(kind='bar')
plt.xlabel('Month')
plt.ylabel('Number of Rows')
plt.title('Number of Rows per Month')
plt.show()

# pd.DataFrame(inflation_lemmas).to_excel('D:\Studium\PhD\Single Author\Data\inflation_lemmas_examplev02.xlsx')    

inflation_lemmas = pd.read_csv('D:\Studium\PhD\Single Author\Data\inflation_lemmas_examplev02.xlsx', encoding= 'unicode_escape')

import os

PATH = r"D:\Studium\PhD\Github\Single-Author\Code\News"

#data_sent = pd.read_csv('D:\Studium\PhD\Single Author\Data\data_sents_dpa_test3.csv')
#data_sent.reset_index(inplace = True)

os.chdir(PATH)

from dataprep import lemmatize_sentences

lemmas = []

for art in tqdm(data_sent['sentence']):
    
    # art = ast.literal_eval(art)
    art = word_tokenize(art)
    lemm_art = lemmatize_sentences([art])
    lemmas.append(lemm_art)
    
    # art = [n.strip() for n in art]
    
    # lem_sent = [lemmatize_sentences(word_tokenize(sent)) for sent in art]

data_sent['lemmas'] = lemmas
    