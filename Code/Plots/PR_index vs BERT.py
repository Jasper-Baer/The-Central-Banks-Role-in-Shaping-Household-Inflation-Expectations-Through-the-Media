# -*- coding: utf-8 -*-
"""
Created on Mon Nov 14 11:01:23 2022

@author: jbaer
"""

import os

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

PATH = r"D:\Studium\PhD\Github\Single-Author\Code\Unsupervised\Support"

os.chdir(PATH)

from PR_index_supp import inf_senti_index

PATH = r"D:\Studium\PhD\Github\Single-Author\Code\Plots"

os.chdir(PATH)

from PR_BERT_supp import plot_news

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

number_monthly_inf = data_senti.groupby(["year", "month"]).count()['text']
number_monthly_all = data_full_sents.groupby(["year", "month"]).count()['sentences']

count_rel = []

for y in range(0, 28):  
    
    yearly_data_inf = number_monthly_inf[y*12:(y*12)+12]
    yearly_data_all = number_monthly_all[y*12:(y*12)+12]
    count_rel.extend(yearly_data_inf/sum(yearly_data_all))
    
#count_rel = np.array(data_senti.groupby(["year", "month"]).count()['text'])/len(data_senti)

count_rel = pd.DataFrame(count_rel)
count_rel.index = pd.date_range('1/1/1991', '1/1/2019', freq = 'M').tolist()

count_rel.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\count_rel.xlsx')

dire_rel = np.multiply(count_rel, dire)
# dire = np.multiply(count_rel_monthly, dire)
        
plot_news(dire, monthly_count_dire, lex_dir, data_full_sents)

plot_news(dire_rel, monthly_count_dire, lex_dir, data_full_sents)

plot_news(senti, monthly_count_senti, lex_sen, data_full_sents)

dire_senti = np.multiply(senti, dire)
#dire_senti_rel = np.multiply(dire_senti, count_rel)

plot_news(dire_senti*-1, monthly_count_dire, lex_dir, data_full_sents)
#plot_news(dire_senti_rel*-1, monthly_count_dire, lex_dir, data_full_sents)

dire_senti = pd.DataFrame(dire_senti)
dire_senti.index = pd.date_range('1/1/1991', '1/1/2019', freq = 'M').tolist()

dire_senti.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\news_index_dire_senti.xlsx')

dire_senti_rel = np.multiply(dire_senti, count_rel)

plot_news(dire_senti_rel*-1, monthly_count_dire, lex_dir, data_full_sents)

data_inflation_ger = pd.read_excel('D:\Studium\PhD\Single Author\Data\German_inflation_fred.xls')[0:29]['inflation']

dates_m = pd.date_range('1/1/1991', '1/1/2019', freq = 'M').tolist()
#dire_senti = pd.DataFrame({'Date': dates_m, 'Dire Senti Index': dire_senti})
#dire_senti.to_excel('D:\Studium\PhD\Github\Single-Author\Data\dire_senti.xlsx')

news_index_dataframe = pd.DataFrame({'Date': dates_m, 'Dire Senti Index': dire_senti, 'Senti': senti, 'Dire': dire})
news_index_dataframe.to_excel('D:\Studium\PhD\Github\Single-Author\Data\news_index_dataframe.xlsx')

##############################################################################

from sklearn.preprocessing import MinMaxScaler

scaler = MinMaxScaler(feature_range=(0, 1))
scaler = scaler.fit(np.array(senti).reshape((len(senti), 1)))
senti_normalized = scaler.transform(np.array(senti).reshape((len(dire), 1)))

senti_normalized = pd.Series(list(senti_normalized)).rolling(3).mean()
senti_normalized = senti_normalized[2:]

dire = pd.Series(list(dire)).rolling(3).mean()
dire = dire[2:]

colormap = plt.get_cmap('RdYlGn')
color = colormap(senti_normalized).reshape(334,4)

import matplotlib.pyplot as plt
from matplotlib.collections import LineCollection

dates_m = pd.date_range('1/1/1991', '1/1/2019', freq = 'M').tolist()

y = dire
y = np.float32(y)
x = np.float32(range(2,336))
xy = np.array([x, y], dtype='object').T.reshape(-1, 1, 2)
segments = np.hstack([xy[:-1], xy[1:]])
fig, ax = plt.subplots()
lc = LineCollection(segments, colors=color)
ax.add_collection(lc)
ax.autoscale()
ax.set_title('News - BERT - Direction and Sentiment')
#plt.xticks(dates_m)
plt.show()
