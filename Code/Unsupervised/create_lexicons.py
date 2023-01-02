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

data = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\ECB\press_sents_sample_labeled_speeches_v02.xlsx')
#data = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\inflation_lemmas_example.xlsx')
data = data[0:2000]

#label_direction = data['Direction']
#label_sentiment = data['Sentiment']

label_direction = data['monetary']
label_sentiment = data['outlook']

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

##############################################################################
# Create Lexicons
##############################################################################

PR_lex_full = pd.concat([direction_lex, sentiment_lex], axis=1)
PR_lex_full['tokens'] = [word_tokenize(keyword) for keyword in PR_lex_full['n_grams']]

#PR_lex_full.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\PR_lex_ECB.xlsx')
#PR_lex_full = pd.read_excel(r'D:\Studium\PhD\Github\Single-Author\Data\PR_lex_news.xlsx')
PR_lex_full = pd.read_excel(r'D:\Studium\PhD\Github\Single-Author\Data\PR_lex_ECB.xlsx')
PR_lex_full['tokens'] = PR_lex_full['tokens'].apply(lambda x: literal_eval(str(x)))

#idx_null = PR_lex_full[PR_lex_full['n_grams'] != PR_lex_full['n_grams']].index[0]
#PR_lex_full.loc[[idx_null], 'n_grams'] = 'null'

PR_lex_dir = PR_lex_full[['n_grams', 'tokens', 'positive direction index', 'neutral direction index', 'negative direction index']]
PR_lex_dir = PR_lex_dir.rename(columns = {'n_grams': 'keyword', 'positive direction index' : 'positive','neutral direction index' : 'neutral','negative direction index' : 'negative'})

PR_lex_sent = PR_lex_full[['n_grams', 'tokens', 'positive sentiment index', 'neutral sentiment index', 'negative sentiment index']]
PR_lex_sent = PR_lex_sent.rename(columns = {'n_grams': 'keyword', 'positive sentiment index' : 'positive','neutral sentiment index' : 'neutral','negative sentiment index' : 'negative'})

#PR_lex_dir.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\monetary_own_lexicon.xlsx')
#PR_lex_sent.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\economic_own_lexicon.xlsx')