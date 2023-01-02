# -*- coding: utf-8 -*-
"""
Created on Sun Aug 21 19:18:29 2022

@author: Nutzer
"""

import pandas as pd
import matplotlib.pyplot as plt
from nltk.tokenize import word_tokenize 
import ast
from tqdm import tqdm

import nltk
import stanfordnlp

stanfordnlp.download('de')
nlp = stanfordnlp.Pipeline(processors= 'tokenize,pos,depparse', lang = 'de')

data = pd.read_csv('D:\Studium\PhD\Single Author\Data\dpa_sents_v01.csv')

word_list = ['Inflation', 'Teuerung' , 'Verteuerung' , 'Preisanstieg', 'Preiserhöhung', 'Inflations']
word_list = ['EZB']
word_list = [word.lower() for word in word_list]

filtered_lemmas = pd.DataFrame()

for idx, art in tqdm(enumerate(data['sentences'])):
    
    art = ast.literal_eval(art)
    
    for sent in art:
        
        #nlp_pars = nlp(sent)
        
        if any(word in word_list for word in word_tokenize(sent.lower())):
        
            filtered_lemmas = filtered_lemmas.append({'sentence' : sent, 'index': idx}, ignore_index=True)

# pd.DataFrame(inflation_lemmas).to_excel('D:\Studium\PhD\Single Author\Data\inflation_lemmas_examplev02.xlsx')    

inflation_lemmas = pd.read_csv('D:\Studium\PhD\Single Author\Data\inflation_lemmas_example.csv')

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
    