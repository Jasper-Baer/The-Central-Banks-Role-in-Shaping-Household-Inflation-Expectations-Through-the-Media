# -*- coding: utf-8 -*-
"""
Created on Sun Aug 21 19:18:29 2022

@author: jbaer
"""

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

import pandas as pd
from nltk.tokenize import word_tokenize 
import ast
from tqdm import tqdm

#import nltk
import stanza
import os

PATH = r"D:\Studium\PhD\Github\Single-Author\Code\Unsupervised"

os.chdir(PATH)

from PR_index_supp import prepare_text

import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)

#stanza.download('de')
nlp = stanza.Pipeline(processors= 'lemma,tokenize,pos,depparse', lang = 'de')

data = pd.read_csv('D:\Studium\PhD\Single Author\Data\dpa_sents_v01.csv')

pre_processing = prepare_text(data['sentences']).preproces_text()
data['tokens'] = pre_processing[0]
stem_map = pre_processing[1]

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

word_list_ecb = [
    
    "EZB",
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

from nltk.stem.snowball import SnowballStemmer

snowball_stemmer = SnowballStemmer('german')

word_list = [snowball_stemmer.stem(word.lower()) for word in word_list]
word_list_ecb = [snowball_stemmer.stem(word.lower()) for word in word_list_ecb]

inflation_sentences = pd.DataFrame()
ecb_sentences = pd.DataFrame()

for idx, art in tqdm(enumerate(data['tokens'])):
    
    for j, tok in enumerate(art):
        
        found_names = set()
        
        if any(word in word_list for word in tok):
        
            inflation_sentences = inflation_sentences.append({'tokens' : tok, 'index': idx}, ignore_index=True)
            
            for i in range(len(tok) - 1):
                
                if tok[i] in word_list_ecb:
                    
                    found_names.add(tok[i])
                    
                elif tok[i] == "europa" and tok[i+1] == "zentralbank":
                    
                    found_names.add(tok[i])
                
                # expection for "Jürgen Stark"
                elif tok[i] == "jurg" and tok[i+1] == "stark":
                    
                    found_names.add(tok[i])
                                                       
            if len(found_names) > 0:
                
                sent = ast.literal_eval(data['sentences'].iloc[idx])[j]
                
                ecb_sentences = ecb_sentences.append({'sentence': sent,'tokens' : tok, 'index': idx}, ignore_index=True) 

inflation_sentences.to_csv('D:\Studium\PhD\Github\Single-Author\Data\newspaper_dpa_inflation_sentences.csv')
ecb_sentences.to_csv('D:\Studium\PhD\Github\Single-Author\Data\news_dpa_ecb_inflation_sentences.csv')
                
def process_sentence(sentence, idx, stem_map):
    
        nlp_pars = nlp(sentence)
        parsed_sentence = nlp_pars.sentences[0]
        deps = []

        for dep in  parsed_sentence.dependencies:
            
            try:
                dep_word = (stem_map[dep[2].text.lower()], dep[0].id, dep[1], dep[2].id) 
            except KeyError:
                dep_word = (dep[2].text, dep[0].id, dep[1], dep[2].id) 
                
            deps.append(dep_word)
                
        return {'sentence': sentence, 'dependencies': deps, 'index': idx}

dependency_data = [process_sentence(row['sentence'], idx, stem_map) for idx, row in tqdm(ecb_sentences.iterrows())]
dependency_data = [item for item in dependency_data if item is not None]
dependency_df = pd.DataFrame(dependency_data)

dependency_df.to_csv(r'D:\Studium\PhD\Single Author\Data\dependencies.csv')

filtered_ecb_sentences = []

reporting_verbs = ['sagen', 'sehen', 'gehen', 'berichten', 'meinen', 'erwarten', 'vorhergesagen', 'rechnen']

def filter_rows(row):
    deps = row['dependencies']
    sent_in_ecb = False
    prev_dep = ""

    for dep in deps:

        if dep[2] in ["nsubj", "nsubjpass"]:
            subj = dep
            if subj[0] in word_list_ecb or (prev_dep == "europa" and subj[0] == "zentralbank"):
                sent_in_ecb = True

        elif dep[2] in ['obj', 'iobj']:
            if dep[0].lower() in word_list_ecb or (prev_dep == "europa" and dep[0] == "zentralbank"):
                obj_dep = dep[1]
                if deps[obj_dep] in reporting_verbs:
                    sent_in_ecb = True
                    
        prev_dep = dep[0]

    if sent_in_ecb:
        return row

filtered_series = dependency_df.apply(filter_rows, axis=1).dropna()
filtered_ecb_sentences = pd.DataFrame(filtered_series.tolist(), columns=dependency_df.columns)
              
ecb_data = data[ data.index.isin(filtered_ecb_sentences['index'])]
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
    