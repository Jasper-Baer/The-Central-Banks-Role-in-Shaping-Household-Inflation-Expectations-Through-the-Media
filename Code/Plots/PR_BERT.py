# -*- coding: utf-8 -*-
"""
Created on Mon Nov 14 11:01:23 2022

@author: jbaer
"""

import os

import pandas as pd

PATH = r"D:\Studium\PhD\Github\Single-Author\Code\Unsupervised"

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
        
plot_news(dire, monthly_count_dire, lex_dir, data_full_sents)
plot_news(senti, monthly_count_senti, lex_sen, data_full_sents)

scaler = MinMaxScaler(feature_range=(0, 1))
scaler = scaler.fit(np.array(senti).reshape((len(senti), 1)))
sentiment_normalized = scaler.transform(np.array(senti).reshape((len(senti), 1)))

colormap = plt.get_cmap('RdYlGn')
color = colormap(sentiment_normalized).reshape(336,4)

y = dire
x = range(1,337)
xy = np.array([x, y]).T.reshape(-1, 1, 2)
segments = np.hstack([xy[:-1], xy[1:]])
fig, ax = plt.subplots()
lc = LineCollection(segments, colors=color)
ax.add_collection(lc)
ax.autoscale()
ax.set_title('A multi-color plot')
plt.show()

plt.stackplot(data_dir['date'], np.array(data_dir[['pos share', 'neu share', 'neg share']]).transpose())      
plt.plot(data_dir['date'], data_dir['index']) 

plt.stackplot(data_sent['date'], np.array(data_sent[['pos share', 'neu share', 'neg share']]).transpose())      
plt.plot(data_sent['date'], data_sent['index']) 

plt.stackplot(pd.to_datetime(monthly_dir.index), np.array(monthly_dir[['pos share', 'neu share', 'neg share']]).transpose())
plt.show()

plt.plot(pd.to_datetime(monthly_dir.index), monthly_dir['index']) 
plt.show()

plt.stackplot(pd.to_datetime(monthly_sent.index), np.array(monthly_sent[['pos share', 'neu share', 'neg share']]).transpose())
plt.plot(pd.to_datetime(monthly_sent.index), monthly_sent['index']) 

plt.plot(pd.to_datetime(monthly_sent.index), monthly_sent['index']) 
plt.show()

plt.stackplot(pd.to_datetime(yearly_dir.index), np.array(yearly_dir[['pos share', 'neu share', 'neg share']]).transpose())
plt.show()

plt.plot(pd.to_datetime(yearly_dir.index), yearly_dir['index']) 
plt.show()

plt.stackplot(pd.to_datetime(yearly_sent.index), np.array(yearly_sent[['pos share', 'neu share', 'neg share']]).transpose())
plt.show()

plt.plot(pd.to_datetime(yearly_sent.index), yearly_sent['index']) 
plt.show()