# -*- coding: utf-8 -*-
"""
Created on Thu Nov 17 12:37:00 2022

@author: Nutzer
"""

import numpy as np
import pandas as pd
import os

from nltk.tokenize import word_tokenize
from ast import literal_eval

PATH = r"D:\Studium\PhD\Github\Single-Author\Code\Unsupervised"

os.chdir(PATH)

from PR_index_supp import prepare_text, count_ngrams, create_dict

def PMI(lex):
    
    lex['n_grams_count'] = lex.iloc[:,1:4].sum(axis = 1)
    
    all_words = sum(lex['n_grams_count'])
    
    P_w = lex['n_grams_count'] / all_words
    P_l = lex.iloc[:,1:4].sum(axis = 0) / all_words
    P_w_l = lex.iloc[:,1:4]/ lex.iloc[:,1:4].sum(axis = 0)
    
    for label in P_l.index:
    
        PW_PL = float(P_l[P_l.index == label])*P_w
        
        PMI = (P_w_l[label]/PW_PL).apply(np.log2)
    
        lex[label + ' PMI'] = PMI
    
    lex.iloc[:,-3:] = lex.iloc[:,-3:].replace(-np.inf, 0)
    
    return(lex)

data = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\ECB\press_sents_sample_labeled_speeches_v02.xlsx')
data = data[0:2000]

label_monetary = data['monetary']
label_outlook = data['outlook']
label_inflation = data['inflation']

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
sentiment_lex = PMI(sentiment_lex)
sentiment_lex.drop(['n_grams'], axis = 1, inplace = True)

##############################################################################
# Direction
##############################################################################

data['Label'] = label_direction

word_dict, n_grams = count_ngrams(data)
direction_lex = create_dict(word_dict, n_grams, 'direction')
direction_lex = PMI(direction_lex)
#direction_lex.drop(['n_grams'], axis = 1, inplace = True)

##############################################################################
##############################################################################
##############################################################################

##############################################################################
# Monetary
##############################################################################

data['Label'] = label_monetary

word_dict, n_grams = count_ngrams(data)
monetary_lex = create_dict(word_dict, n_grams, 'monetary')
monetary_lex = PMI(monetary_lex)
#monetary_lex.drop(['n_grams'], axis = 1, inplace = True)

##############################################################################
# Outlook
##############################################################################

data['Label'] = label_outlook

word_dict, n_grams = count_ngrams(data)
outlook_lex = create_dict(word_dict, n_grams, 'outlook')
outlook_lex = PMI(outlook_lex)
outlook_lex.drop(['n_grams'], axis = 1, inplace = True)

##############################################################################
# Inflation
##############################################################################

data['Label'] = label_inflation

word_dict, n_grams = count_ngrams(data)
inflation_lex = create_dict(word_dict, n_grams, 'inflation')
inflation_lex = PMI(inflation_lex)
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

#PR_lex_full = pd.read_excel(r'D:\Studium\PhD\Github\Single-Author\Data\PR_lex_ECB.xlsx')
PR_lex_full = pd.read_excel(r'D:\Studium\PhD\Github\Single-Author\Data\PR_lex_news.xlsx')
PR_lex_full['tokens'] = PR_lex_full['tokens'].apply(lambda x: literal_eval(str(x)))

#idx_null = PR_lex_full[PR_lex_full['n_grams'] != PR_lex_full['n_grams']].index[0]
#PR_lex_full.loc[[idx_null], 'n_grams'] = 'null'

PR_lex_monetary = PR_lex_full[['n_grams', 'tokens', 'positive monetary index', 'neutral monetary index', 'negative monetary index', 'positive monetary PMI', 'neutral monetary PMI', 'negative monetary PMI']]
PR_lex_monetary = PR_lex_monetary.rename(columns = {'n_grams': 'keyword', 'positive monetary index' : 'positive','neutral monetary index' : 'neutral','negative monetary index' : 'negative', 'positive monetary PMI' : 'PMI positive', 'neutral monetary PMI' : 'PMI neutral', 'negative monetary PMI' : 'PMI negative'})

PR_lex_outlook = PR_lex_full[['n_grams', 'tokens', 'positive outlook index', 'neutral outlook index', 'negative outlook index', 'positive outlook PMI', 'neutral outlook PMI', 'negative outlook PMI']]
PR_lex_outlook = PR_lex_outlook.rename(columns = {'n_grams': 'keyword', 'positive outlook index' : 'positive','neutral outlook index' : 'neutral','negative outlook index' : 'negative', 'positive outlook PMI' : 'PMI positive', 'neutral outlook PMI' : 'PMI neutral', 'negative outlook PMI' : 'PMI negative'})

PR_lex_inflation = PR_lex_full[['n_grams', 'tokens', 'positive inflation index', 'neutral inflation index', 'negative inflation index', 'positive inflation PMI', 'neutral inflation PMI', 'negative inflation PMI']]
PR_lex_inflation = PR_lex_inflation.rename(columns = {'n_grams': 'keyword', 'positive inflation index' : 'positive','neutral inflation index' : 'neutral','negative inflation index' : 'negative', 'positive inflation PMI' : 'PMI positive', 'neutral inflation PMI' : 'PMI neutral', 'negative inflation PMI' : 'PMI negative'})

PR_lex_monetary.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\monetary_own_lexicon.xlsx')
PR_lex_outlook.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\outlook_own_lexicon.xlsx')
PR_lex_inflation.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\inflation_own_lexicon.xlsx')

PR_lex_direction = PR_lex_full[['n_grams', 'tokens', 'positive direction index', 'neutral direction index', 'negative direction index', 'positive direction PMI', 'neutral direction PMI', 'negative direction PMI']]
PR_lex_direction = PR_lex_direction.rename(columns = {'n_grams': 'keyword', 'positive direction index' : 'positive','neutral direction index' : 'neutral','negative direction index' : 'negative', 'positive direction PMI' : 'PMI positive', 'neutral direction PMI' : 'PMI neutral', 'negative direction PMI' : 'PMI negative'})

PR_lex_sentiment = PR_lex_full[['n_grams', 'tokens', 'positive sentiment index', 'neutral sentiment index', 'negative sentiment index', 'positive sentiment PMI', 'neutral sentiment PMI', 'negative sentiment PMI']]
PR_lex_sentiment = PR_lex_sentiment.rename(columns = {'n_grams': 'keyword', 'positive sentiment index' : 'positive','neutral sentiment index' : 'neutral','negative sentiment index' : 'negative', 'positive direction PMI' : 'PMI positive', 'neutral direction PMI' : 'PMI neutral', 'negative direction PMI' : 'PMI negative'})

PR_lex_direction.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\direction_own_lexicon.xlsx')
PR_lex_sentiment.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\sentiment_own_lexicon.xlsx')