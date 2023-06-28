# -*- coding: utf-8 -*-
"""
Created on Thu Nov 17 12:37:00 2022

@author: Nutzer
"""

import numpy as np
import pandas as pd
import os

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

def process_label(data, label):
    data['Label'] = data[label]

    word_dict, n_grams = count_ngrams(data)
    lex = create_dict(word_dict, n_grams, label)
    lex = PMI(lex)

    return lex

def save_lexicons(lexicons, filenames):
    for lexicon, filename in zip(lexicons, filenames):
        lexicon.to_excel(filename)

data_ECB = r'D:\Studium\PhD\Single Author\Data\ECB\press_sents_sample_labeled_speeches_v02.xlsx'
data_News = r'D:\Studium\PhD\Single Author\Data\inflation_lemmas_example.xlsx'
data_ECB = pd.read_excel(data_ECB)
data_ECB = data_ECB[0:2000]
data_News = pd.read_excel(data_News)
data_News = data_News[0:3000]

data_ECB['sentence'] = data_ECB['sentence'].apply(lambda x: [x])
data_News['sentence'] = data_News['sentence'].apply(lambda x: [x])

data_ECB['tokens'] = prepare_text(data_ECB['sentence'], language = 'english').preproces_text()[0]
data_News['tokens'] = prepare_text(data_News['sentence']).preproces_text()[0]

data_ECB['tokens'] = data_ECB['tokens'].apply(lambda x: x[0])
data_News['tokens'] = data_News['tokens'].apply(lambda x: x[0])

labels_ECB = ['monetary', 'outlook', 'inflation']
labels_News = ['Direction', 'Sentiment']

lexicon_ECB = [process_label(data_ECB, label) for label in labels_ECB]
lexicon_News = [process_label(data_News, label) for label in labels_News]

lexicon_ECB_folder = [os.path.join(r"D:\Studium\PhD\Github\Single-Author\Data", f"{label}_PMI_lexicon.xlsx") for label in labels_ECB]
lexicon_News_folder = [os.path.join(r"D:\Studium\PhD\Github\Single-Author\Data", f"{label}_PMI_lexicon.xlsx") for label in labels_News]

save_lexicons(lexicon_ECB, lexicon_ECB_folder)
save_lexicons(lexicon_News, lexicon_News_folder)