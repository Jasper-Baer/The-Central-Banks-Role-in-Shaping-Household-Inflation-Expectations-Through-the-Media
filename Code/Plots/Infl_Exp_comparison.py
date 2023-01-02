# -*- coding: utf-8 -*-
"""
Created on Tue Dec 20 17:11:31 2022

@author: Nutzer
"""

import pandas as pd

import matplotlib.pyplot as plt

import os

PATH = r"D:\Studium\PhD\Github\Single-Author\Code\Unsupervised"

os.chdir(PATH)

from PR_index_supp import inf_senti_index

##############################################################################

def ECB_index(ECB_data):
    
    index_list = []
    
    for date in sorted(set(ECB_data['date'])):
        
        conf_data = ECB_data[ECB_data['date'] == date]['Label']
        pos = len(conf_data[conf_data == 2])
        neu = len(conf_data[conf_data == 1])
        neg = len(conf_data[conf_data == 0])
        
        index = (pos - neg)/(pos + neu + neg)
        index_list.append(index)
        
    data_ECB_full = pd.DataFrame({'date': sorted(set(ECB_data['date'])), 'index': index_list})
    
    return(data_ECB_full)

##############################################################################

data_ECB_sents_inf = pd.read_excel('D:\Studium\PhD\Single Author\Data\ECB\press_sents_full_index_labeled_inf.xlsx')

data_ECB_full = ECB_index(data_ECB_sents_inf)
data_ECB_full.set_index('date', inplace=True)

data_ECB_full = pd.DataFrame(data_ECB_full).groupby(pd.Grouper(freq="q")).mean()

data_ECB_full['index'] = data_ECB_full.rolling(3).mean()
data_ECB_full = data_ECB_full[2:]


##############################################################################
# News Direction
############################################################################## 

data_dir = pd.read_csv('D:\Studium\PhD\Single Author\Data\dpa_dir_labels_test.csv')
           
monthly_count_dire, dire = inf_senti_index(data_dir)  

dates_m = pd.date_range('1/1/1991', '1/1/2019', freq = 'M').tolist()

dire = pd.DataFrame({"News Inflation Direction":dire})
dire.index = dates_m

dire_q = pd.DataFrame(dire).groupby(pd.Grouper(freq="q")).mean()

##############################################################################
# Proffesional Inflation Expectations
##############################################################################

data_inf_exp = pd.read_excel('D:\Studium\PhD\Single Author\Data\ECB\Inflation Expectations\Infl_Exp.xlsx', index_col = 0)

import numpy as np

np.corrcoef(list(dire_q[32:].iloc[:,0]), list(data_inf_exp[:-16].iloc[:,0]))
np.corrcoef(list(data_ECB_full[1:-15].iloc[:,0]), list(data_inf_exp[:-16].iloc[:,0]))

##############################################################################

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(dire_q[32:], color = 'green', label = 'News Inflation')
ax2.plot(data_inf_exp[:-16], color = 'blue', label = 'Forecasters Inflation Expectations')

fig.legend(loc = 'lower left')

plt.show()

##############################################################################



##############################################################################

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(data_ECB_full[1:-3], color = 'red', label = 'ECB Inflation')
ax2.plot(data_inf_exp[:-4], color = 'blue', label = 'Forecasters Inflation Expectations')

fig.legend(loc = 'lower left')

plt.show()

##############################################################################

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(dire_q, color = 'green', label = 'News Inflation')
ax1.plot(data_ECB_full['date'], data_ECB_full['index'], color = 'red', label = 'ECB Inflation')
ax2.plot(data_inf_exp[:-8], color = 'blue', label = 'Forecasters Inflation Expectations')

fig.legend(loc = 'lower left')

plt.show()