# -*- coding: utf-8 -*-
"""
Created on Thu Nov 17 12:37:00 2022

@author: Nutzer
"""

import pandas as pd
import os

from nltk.tokenize import word_tokenize
from ast import literal_eval

PATH = r"D:\Studium\PhD\Github\Single-Author\Code\Unsupervised"

os.chdir(PATH)

from PR_index_supp import prepare_text, count_ngrams, create_dict

# f = open('D:\Studium\PhD\Single Author\Data\ECB\press_conferences_cleaned.json')
# data_json = json.load(f)
# data = pd.read_json(data_json)

# data = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\ECB\press_sents_sample_labeled_speeches_v02.xlsx')
# data = data[0:2000]

# label_monetary = data['monetary']
# label_outlook = data['outlook']
# label_inflation = data['inflation']

data = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\inflation_lemmas_example.xlsx')
data = data[0:2000]

label_direction = data['Direction']
label_sentiment = data['Sentiment']

data['tokens'] = prepare_text(data['sentence']).preproces_text()

##############################################################################
# Sentiment
##############################################################################

data['Label'] = label_sentiment

word_dict, n_grams = count_ngrams(data)
sentiment_lex = create_dict(word_dict, n_grams, 'sentiment')
sentiment_lex.drop(['n_grams'], axis = 1, inplace = True)

##############################################################################
# Direction
##############################################################################

data['Label'] = label_direction

word_dict, n_grams = count_ngrams(data)
direction_lex = create_dict(word_dict, n_grams, 'direction')
#direction_lex.drop(['n_grams'], axis = 1, inplace = True)

##############################################################################
# Monetary
##############################################################################

data['Label'] = label_monetary

word_dict, n_grams = count_ngrams(data)
monetary_lex = create_dict(word_dict, n_grams, 'monetary')
#monetary_lex.drop(['n_grams'], axis = 1, inplace = True)

##############################################################################
# Outlook
##############################################################################

data['Label'] = label_outlook

word_dict, n_grams = count_ngrams(data)
outlook_lex = create_dict(word_dict, n_grams, 'outlook')
outlook_lex.drop(['n_grams'], axis = 1, inplace = True)

##############################################################################
# Inflation
##############################################################################

data['Label'] = label_inflation

word_dict, n_grams = count_ngrams(data)
inflation_lex = create_dict(word_dict, n_grams, 'inflation')
inflation_lex.drop(['n_grams'], axis = 1, inplace = True)

##############################################################################
# Create Lexicons
##############################################################################

PR_lex_full = pd.concat([monetary_lex, outlook_lex, inflation_lex], axis=1)
PR_lex_full['tokens'] = [word_tokenize(keyword) for keyword in PR_lex_full['n_grams']]
#PR_lex_full.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\PR_lex_ECB.xlsx')

PR_lex_full = pd.concat([sentiment_lex, direction_lex], axis=1)
PR_lex_full['tokens'] = [word_tokenize(keyword) for keyword in PR_lex_full['n_grams']]
#PR_lex_full.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\PR_lex_news.xlsx')

PR_lex_full = pd.read_excel(r'D:\Studium\PhD\Github\Single-Author\Data\PR_lex_news.xlsx')
#PR_lex_full = pd.read_excel(r'D:\Studium\PhD\Github\Single-Author\Data\PR_lex_ECB.xlsx')
PR_lex_full['tokens'] = PR_lex_full['tokens'].apply(lambda x: literal_eval(str(x)))

#idx_null = PR_lex_full[PR_lex_full['n_grams'] != PR_lex_full['n_grams']].index[0]
#PR_lex_full.loc[[idx_null], 'n_grams'] = 'null'

PR_lex_monetary = PR_lex_full[['n_grams', 'tokens', 'positive monetary index', 'neutral monetary index', 'negative monetary index']]
PR_lex_monetary = PR_lex_monetary.rename(columns = {'n_grams': 'keyword', 'positive monetary index' : 'positive','neutral monetary index' : 'neutral','negative monetary index' : 'negative'})

PR_lex_outlook = PR_lex_full[['n_grams', 'tokens', 'positive outlook index', 'neutral outlook index', 'negative outlook index']]
PR_lex_outlook = PR_lex_outlook.rename(columns = {'n_grams': 'keyword', 'positive outlook index' : 'positive','neutral outlook index' : 'neutral','negative outlook index' : 'negative'})

PR_lex_inflation = PR_lex_full[['n_grams', 'tokens', 'positive inflation index', 'neutral inflation index', 'negative inflation index']]
PR_lex_inflation = PR_lex_inflation.rename(columns = {'n_grams': 'keyword', 'positive inflation index' : 'positive','neutral inflation index' : 'neutral','negative inflation index' : 'negative'})

PR_lex_monetary.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\monetary_own_lexicon.xlsx')
PR_lex_outlook.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\outlook_own_lexicon.xlsx')
PR_lex_inflation.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\inflation_own_lexicon.xlsx')

PR_lex_direction = PR_lex_full[['n_grams', 'tokens', 'positive direction index', 'neutral direction index', 'negative direction index']]
PR_lex_direction = PR_lex_direction.rename(columns = {'n_grams': 'keyword', 'positive direction index' : 'positive','neutral direction index' : 'neutral','negative direction index' : 'negative'})

PR_lex_sentiment = PR_lex_full[['n_grams', 'tokens', 'positive sentiment index', 'neutral sentiment index', 'negative sentiment index']]
PR_lex_sentiment = PR_lex_sentiment.rename(columns = {'n_grams': 'keyword', 'positive sentiment index' : 'positive','neutral sentiment index' : 'neutral','negative sentiment index' : 'negative'})

PR_lex_direction.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\direction_own_lexicon.xlsx')
PR_lex_sentiment.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\sentiment_own_lexicon.xlsx')