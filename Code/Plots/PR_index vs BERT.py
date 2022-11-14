# -*- coding: utf-8 -*-
"""
Created on Mon Nov 14 11:01:23 2022

@author: jbaer
"""

import os

import pandas as pd

PATH = r"D:\Studium\PhD\Github\Single-Author\Code\Plots"

os.chdir(PATH)

from PR_index vs BERT_supp import inf_senti_index

##############################################################################
# News Direction
############################################################################## 

data_dir = pd.read_csv('D:\Studium\PhD\Single Author\Data\dpa_dir_labels_test.csv')
           
monthly_count_dire, dire = inf_senti_index(data_dir)  

lex_dir = pd.read_csv('D:\Studium\PhD\Github\Single-Author\Data\PR_news_direction_results.csv')
lex_dir['date'] = pd.to_datetime(lex_dir['date'])

lex_dir.index = lex_dir['date']

##############################################################################
# News Sentiment
##############################################################################

data_senti = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\dpa_sent_labels_test.csv')

monthly_count_senti, senti = inf_senti_index(data_senti) 

lex_sen = pd.read_csv('D:\Studium\PhD\Github\Single-Author\Data\PR_news_sentiment_results.csv')
lex_sen['date'] = pd.to_datetime(lex_sen['date'])

lex_sen.index = lex_sen['date']

##############################################################################

data_full_sents = pd.read_csv('D:\Studium\PhD\Single Author\Data\dpa_sents_v01.csv')
        
plot_news(dire, monthly_count_dire, lex_dir, data_full_sents)
plot_news(senti, monthly_count_senti, lex_sen, data_full_sents)