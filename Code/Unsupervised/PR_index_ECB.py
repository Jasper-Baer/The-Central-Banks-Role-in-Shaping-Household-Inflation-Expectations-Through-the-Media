# -*- coding: utf-8 -*-
"""
Created on Thu Nov 17 15:09:25 2022

@author: Nutzer
"""

import json
import pandas as pd
import os

from nltk.tokenize import word_tokenize
from tqdm import tqdm
from ast import literal_eval

PATH = r"D:\Studium\PhD\Github\Single-Author\Code\Unsupervised\Support"

os.chdir(PATH)

from PR_index_supp import prepare_text
from PR_index_supp import create_index

##############################################################################
# Prepare ECB press conferences
##############################################################################

f = open('D:\Studium\PhD\Single Author\Data\ECB\press_conferences_cleaned.json')
data_json = json.load(f)
data = pd.read_json(data_json)

ECB_sents = pd.DataFrame()

for idx, speech in tqdm(enumerate(data['Texts'])):
    
    meta_data = data[['Author', 'date', 'years']].iloc[idx]
    
    for sent in data['speeches'].iloc[idx]:
        
        meta_data['sent'] = sent
        
        ECB_sents = ECB_sents.append(meta_data)

data['speeches'] = [' '.join(sents) for sents in data['speeches']]
data['tokens'] = prepare_text(data['speeches'], language = 'english').preproces_text()

# data.to_csv(r"D:\Studium\PhD\Github\Single-Author\Data\ECB_prepared.csv")

##############################################################################

##############################################################################
# Prepare original PR lext
##############################################################################

PR_lex_ECB_og = pd.read_excel(r'D:\Studium\PhD\Github\Single-Author\Data\monetary_own_lexicon.xlsx')
#PR_lex_ECB_og = pd.read_csv(r'D:\Studium\PhD\Github\Single-Author\Data\export_lexicon.csv', sep = ';')

#PR_lex_ECB_og = pd.read_csv(r'D:\Studium\PhD\Github\Single-Author\Data\export_lexicon.csv', sep = ';')

PR_lex_ECB_og['tokens'] = [word_tokenize(keyword) for keyword in PR_lex_ECB_og['keyword']]

PR_lex_ECB_mon = PR_lex_ECB_og

PR_lex_ECB_mon = PR_lex_ECB_og[['keyword', 'tokens', 'mp_acco', 'mp_neut', 'mp_rest']]
PR_lex_ECB_mon.rename(columns = {'mp_acco': 'negative', 'mp_neut': 'neutral', 'mp_rest': 'positive'}, inplace = True)

# PR_lex_ECB_ec = PR_lex_ECB_og[['keyword', 'tokens', 'ec_nega', 'ec_neut', 'ec_posi']]
# PR_lex_ECB_ec.rename(columns = {'ec_posi': 'positive', 'ec_neut': 'neutral', 'ec_nega': 'negative'}, inplace = True)

# PR_lex_ECB_mon.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\monetary_lexicon.xlsx')
# PR_lex_ECB_ec.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\economic_lexicon.xlsx')

##############################################################################

data = pd.read_csv(r"D:\Studium\PhD\Github\Single-Author\Data\ECB_prepared.csv")[['tokens', 'date', 'Author', 'years']]
data['tokens'] = data['tokens'].apply(lambda x: literal_eval(str(x)))

#data = data[(data['years'] >= 2006) & (data['years'] <= 2014)]
data = data[data['years'] >= 2006]

data['date'] = pd.to_datetime(data['date'])

data.sort_values(by='date', inplace=True)
data.reset_index(inplace = True, drop = True)

PR_lex_ECB_mon = pd.read_excel(r'D:\Studium\PhD\Github\Single-Author\Data\monetary_own_lexicon.xlsx')
# PR_lex_ECB_mon = pd.read_excel(r'D:\Studium\PhD\Github\Single-Author\Data\monetary_lexicon.xlsx')
PR_lex_ECB_mon['tokens'] = PR_lex_ECB_mon['tokens'].apply(lambda x: literal_eval(str(x)))

PR_lex_ECB_ec = pd.read_excel(r'D:\Studium\PhD\Github\Single-Author\Data\economic_own_lexicon.xlsx')
#PR_lex_ECB_ec = pd.read_excel(r'D:\Studium\PhD\Github\Single-Author\Data\economic_lexicon.xlsx')
PR_lex_ECB_ec['tokens'] = PR_lex_ECB_ec['tokens'].apply(lambda x: literal_eval(str(x)))

data_mon = create_index(data, PR_lex_ECB_mon, neg_window = 0)
data_mon.to_csv(r'D:\Studium\PhD\Github\Single-Author\Data\ECB_monetary_own_trainingsset_labels.csv')
#data_mon.to_csv(r'D:\Studium\PhD\Github\Single-Author\Data\ECB_monetary_labels.csv')

data_ec = create_index(data, PR_lex_ECB_ec, neg_window = 0)
data_ec.to_csv(r'D:\Studium\PhD\Github\Single-Author\Data\ECB_economic_own_trainingsset_labels.csv')
#data_ec.to_csv(r'D:\Studium\PhD\Github\Single-Author\Data\ECB_economic_labels.csv')
