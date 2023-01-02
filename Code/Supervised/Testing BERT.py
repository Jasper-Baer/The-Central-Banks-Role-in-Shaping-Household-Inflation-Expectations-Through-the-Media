# -*- coding: utf-8 -*-
"""
Created on Mon Aug 22 21:19:32 2022

@author: jbaer
"""

import os
os.environ['CUDA_LAUNCH_BLOCKING'] = "1"

import numpy as np
import matplotlib.pyplot as plt

from sklearn import preprocessing
from sklearn.preprocessing import MinMaxScaler

from tqdm import tqdm

import torch
import pandas as pd
#from transformers import BertModel
from transformers import BertTokenizer

PATH = r"D:\Studium\PhD\BERT"

os.chdir(PATH)

from BERT_run import predict, train_test_BERT

PATH = r"D:\Studium\PhD\Fischerei\Code"
os.chdir(PATH)

from BERT_pre_processing import pre_processing
# Set seed for torch and numpy
seed = 1

# Torch RNG
torch.manual_seed(seed)
torch.cuda.manual_seed_all(seed)

# Python RNG
np.random.seed(seed)

##############################################################################
# Load Data
##############################################################################

# Load data
data = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\ECB\press_sents_sample_labeled_speeches_v02.xlsx')
#data = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\inflation_lemmas_example.xlsx')

#data = data[0:3000]

data = data[0:2250]

#data = data.rename(columns = {'sentence': 'Sentences', 'Sentiment' : 'Label'})[['Sentences', 'Label']]
#data = data.rename(columns = {'sentence': 'Sentences', 'Direction' : 'Label'})[['Sentences', 'Label']]
#data = data.rename(columns = {'sentence': 'Sentences', 'monetary' : 'Label'})[['Sentences', 'Label']]
#data = data.rename(columns = {'sentence': 'Sentences', 'outlook' : 'Label'})[['Sentences', 'Label']]
data = data.rename(columns = {'sentence': 'Sentences', 'inflation' : 'Label'})[['Sentences', 'Label']]

##############################################################################
# Initialize BERT
##############################################################################

# english bert-base-cased
# german deepset/gbert-base

# Set word embedding model
word_embedding = "bert-base-uncased"
#word_embedding = "deepset/gbert-base"

PATH = r"D:\Studium\PhD\Single Author\Code\News\Sentiment\model_BERT_ecb_inf_speeches.pt"

#PATH = r"D:\Studium\PhD\Single Author\Code\News\Sentiment\model_BERT_news_sent.pt"

model = train_test_BERT(data, word_embedding, PATH)
#model.load_state_dict(torch.load(PATH))
tokenizer = BertTokenizer.from_pretrained(word_embedding, do_lower_case=True)

##############################################################################
# Prepare ECB press cons and predict
##############################################################################

import json

f = open('D:\Studium\PhD\Single Author\Data\ECB\press_conferences_cleaned.json')
  
data_json = json.load(f)

data_full = pd.read_json(data_json)

data_full = data_full.rename(columns = {'speeches': 'text'})

data_ECB_sents = pd.DataFrame()

for idx, text in tqdm(enumerate(data_full['text'])):
    
    for sent in text:
        
        date = data_full.iloc[idx]['date']    
        data_ECB_sents = data_ECB_sents.append({'text': sent, 'date': date}, ignore_index=True)
    
dataloader = pre_processing(data_ECB_sents, tokenizer, 100)

data_ECB_sents["Label"] = predict(model, dataloader)
data_ECB_sents.to_excel('D:\Studium\PhD\Single Author\Data\ECB\press_sents_full_index_labeled_inf.xlsx')

##############################################################################


















































data_labeled = pd.read_excel('D:\Studium\PhD\Single Author\Data\ECB\press_sents_full_index_labeled_outlook.xlsx')
sentiment_index = []
data_sents['date'] = pd.to_datetime(data_sents['date'])

# for idx, dates in enumerate(sorted(set(data_sents['date']))):
    
#     #data_con = data_labeled[data_labeled['index'] == idx]
#     data_con = data_sents[data_sents['date'] == dates]
#     data_con_pos = len(data_con[data_con['Label'] == 2])
#     data_con_neu = len(data_con[data_con['Label'] == 1])
#     data_con_neg = len(data_con[data_con['Label'] == 0])
    
#     sentiment_index.append((data_con_pos - data_con_neg)/(data_con_pos + data_con_neu + data_con_neg))
    
# import matplotlib.pyplot as plt

# dates = list(data_full['date'])
# dates.reverse()

# window_size = 7

# numbers_series = pd.Series(sentiment_index[1:251])
# #numbers_series = pd.Series(sentiment_index)
# windows = numbers_series.rolling(window_size)
# moving_averages = windows.mean()

# moving_averages_list = moving_averages.tolist()
# mon_rolling = moving_averages_list[window_size - 1:]

# data_prod = pd.read_excel('D:\Studium\PhD\Single Author\Data\EU Prod ex construction.xlsx')

##############################################################################

data_news = pd.read_excel('D:\Studium\PhD\Single Author\Data\inflation_news.xlsx')

data_news = data_news.rename(columns = {'sentence': 'text'})
dataloader = pre_processing(data_news, tokenizer, 100)

data_news["Label"] = predict(model, dataloader)

#data_news.to_csv('D:\Studium\PhD\Single Author\Data\dpa_dir_labels_test.csv')
data_news.to_csv('D:\Studium\PhD\Single Author\Data\dpa_sent_labels_test.csv')

##############################################################################

#data_full_sents = pd.read_csv('D:\Studium\PhD\Single Author\Data\dpa_sents_v01.csv')



### ECB inflation ### 





















# scaler = MinMaxScaler(feature_range=(0, 1))
# scaler = scaler.fit(np.array(dire).reshape((len(dire), 1)))
# dire_normalized = scaler.transform(np.array(dire).reshape((len(dire), 1)))

# scaler = scaler.fit(np.array(data_inflation_ger['inflation']).reshape((len(data_inflation_ger['inflation']), 1)))
# inf_normalized = scaler.transform(np.array(data_inflation_ger['inflation']).reshape((len(data_inflation_ger['inflation']), 1)))


























plt.plot(range(1992,2019), dire_diff)
plt.plot(range(1991,2022), data_inflation_ger['inflation'])

plt.show()

# Plot hering sentiment and differences between hering quotas and advices
fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(range(1992,2019), dire_diff, color = 'green')
ax2.plot(range(1991,2022), data_inflation['inflation'])

plt.show()

# Plot hering sentiment and differences between hering quotas and advices
fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(range(1995,2013), dire[4:-6], color = 'green')
ax2.plot(range(1995,2013), data_inflation['inflation'][4:-9])

plt.show()

# Plot hering sentiment and differences between hering quotas and advices
fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(range(1994,2019), dire[3:], color = 'green')
ax2.plot(range(1994,2019), data_inflation['inflation'][3:-3])

plt.show()

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(range(1994,2019), preprocessing.scale(dire[3:]), color = 'green')
ax2.plot(range(1994,2019), preprocessing.scale(data_inflation['inflation'][3:-3]))

plt.show()

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(range(37,337), dire[36:], color = 'green')
ax2.plot(range(37,349,12), inf_normalized[3:-2])

plt.show()

data_exp_ger_past = pd.read_excel('D:\Studium\PhD\Github\Single-Author\Data\consumer_subsectors_nsa_q5_nace2.xlsx', sheet_name = 'TOT')[['TOT','CONS.DE.TOT.5.B.M']]
data_exp_ger_fut = pd.read_excel('D:\Studium\PhD\Github\Single-Author\Data\consumer_subsectors_nsa_q6_nace2.xlsx', sheet_name = 'TOT')[['TOT','CONS.DE.TOT.6.B.M']]

data_exp_ger_past = data_exp_ger_past[85:407]
data_exp_ger_past['TIME'] = pd.date_range('1992-02-01', end = '2018-12-01',  freq='M')

data_exp_ger_fut = data_exp_ger_fut[85:407]
data_exp_ger_fut['TIME'] = pd.date_range('1992-02-01', end = '2018-12-01',  freq='M')

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(data_exp_ger_past['TIME'],data_exp_ger_past['CONS.DE.TOT.5.B.M'], color = 'green')
ax2.plot(data_exp_ger_fut['TIME'], data_exp_ger_fut['CONS.DE.TOT.6.B.M'])

plt.show()

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(pd.date_range('1990-12-01', end = '2018-12-01',  freq='M'),dire, color = 'green')
ax2.plot(data_exp_ger_fut['TIME'], data_exp_ger_fut['CONS.DE.TOT.6.B.M'])

plt.show()

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(pd.date_range('1990-12-01', end = '2018-12-01',  freq='M'),dire, color = 'green')
ax2.plot(data_exp_ger_fut['TIME'], data_exp_ger_past['CONS.DE.TOT.5.B.M'])

plt.show()

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(pd.date_range('1990-12-01', end = '2018-12-01',  freq='M'), dire, color = 'green')
ax2.plot(pd.date_range('1990-12-01', end = '2018-12-01',  freq='Y'), data_inflation['inflation'][:-3])

plt.show()

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(pd.date_range('1990-12-01', end = '2018-12-01',  freq='M'), dire, color = 'green')
ax2.plot(pd.date_range('1990-12-01', end = '2018-12-01',  freq='Y'), data_inflation['inflation'][:-3])

plt.show()

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(pd.date_range('1995-12-01', end = '2018-12-01',  freq='M'), dire[60:], color = 'green')
ax2.plot(pd.date_range('1995-12-01', end = '2018-12-01',  freq='Y'), data_inflation['inflation'][5:-3])

plt.show()

window_size = 3

numbers_series = pd.Series(dire)
windows = numbers_series.rolling(window_size)
moving_averages = windows.mean()

moving_averages_list = moving_averages.tolist()
dire_rolling = moving_averages_list[window_size - 1:]

window_size = 3

numbers_series = pd.Series(sentiment)
windows = numbers_series.rolling(window_size)
moving_averages = windows.mean()

moving_averages_list = moving_averages.tolist()
senti_rolling = moving_averages_list[window_size - 1:]

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(pd.date_range('1995-01-01', end = '2018-11-01',  freq='M'), dire_rolling[48:], color = 'green')
ax2.plot(pd.date_range('1995-12-01', end = '2018-12-01',  freq='Y'), data_inflation['inflation'][5:-3])

plt.show()

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(pd.date_range('1990-12-01', end = '2018-12-01',  freq='M'),dire, color = 'green')
ax2.plot(data_exp_ger_fut['TIME'], data_exp_ger_fut['CONS.DE.TOT.6.B.M'])

plt.show()


fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(pd.date_range('1990-12-01', end = '2018-12-01',  freq='Y'), data_inflation['inflation'][:-3], color = 'green')
ax2.plot(data_exp_ger_fut['TIME'], data_exp_ger_fut['CONS.DE.TOT.6.B.M'])

plt.show()


###########################################

plt.plot(range(1,337), sentiment)
plt.plot(range(2,336), senti_rolling)
plt.show()

plt.plot(range(1,337), dire)
plt.plot(range(2,336), dire_rolling)
plt.show()

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(pd.date_range('1991-01-01', end = '2018-11-01',  freq='M'), dire_rolling, color = 'green')
ax2.plot(pd.date_range('1991-01-01', end = '2018-11-01',  freq='M'), senti_rolling, color = 'blue')

plt.show()

plt.plot(range(1,336), dire)
plt.plot(range(2,336), dire_rolling)
plt.show()

from sklearn import preprocessing
from sklearn.preprocessing import MinMaxScaler

scaler = MinMaxScaler(feature_range=(0, 1))
scaler = scaler.fit(np.array(dire).reshape((len(dire), 1)))
sentiment_normalized = scaler.transform(np.array(sentiment).reshape((len(dire), 1)))

colormap = plt.get_cmap('RdYlGn')
color = colormap(sentiment_normalized).reshape(336,4)

import matplotlib.pyplot as plt
from matplotlib.collections import LineCollection

y = dire_rolling
x = range(2,336)
xy = np.array([x, y]).T.reshape(-1, 1, 2)
segments = np.hstack([xy[:-1], xy[1:]])
fig, ax = plt.subplots()
lc = LineCollection(segments, colors=color)
ax.add_collection(lc)
ax.autoscale()
ax.set_title('A multi-color plot')
plt.show()

# f = open('D:\Studium\PhD\Single Author\Data\ECB\press_conferences_cleaned.json')
  
# data_json = json.load(f)

# data = pd.read_json(data_json)

# data_sent = pd.DataFrame()

# for idx, sents in enumerate(data['press sent']):
    
#     for sent in sents:
        
#         data_sent = data_sent.append({'index': idx, 'sent': sent}, ignore_index=True)
    
# #data_sent.to_excel('D:\Studium\PhD\Single Author\Data\ECB\press_sents_full_index.xlsx')
# data = pd.read_excel('D:\Studium\PhD\Single Author\Data\ECB\press_sents_full_index.xlsx')
# #data = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\inflation_lemmas_examplev02.xlsx')
# #data_sents = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\dpa_sents_v01.csv')

# fig, ax1 = plt.subplots()

# ax2 = ax1.twinx()
# ax1.plot(dates[93:208], np.array(mon_rolling)[89:-40]*-1, color = 'green')
# ax2.plot(dates[93:208], data_picault['money index'][:-40], color = 'red')

# plt.show()

# fig, ax1 = plt.subplots()

# ax2 = ax1.twinx()
# ax1.plot(dates[93:208], np.array(mon_rolling)[89:-40], color = 'green')
# ax2.plot(data_prod['date'][150:], data_prod['s1'][150:], color = 'red')

# plt.show()

# fig, ax1 = plt.subplots()

# ax2 = ax1.twinx()
# ax1.plot(dates[93:248], data_picault['ecc index'], color = 'green')
# ax2.plot(data_prod['date'][150:], data_prod['s1'][150:], color = 'red')

# plt.show()

# fig, ax1 = plt.subplots()

# ax2 = ax1.twinx()
# ax1.plot(dates[94:248], np.array(sentiment_index[94:248])*-1, color = 'green')
# ax2.plot(dates[93:248], data_picault['money index'], color = 'red')

# plt.show()

# fig, ax1 = plt.subplots()

# ax2 = ax1.twinx()
# ax1.plot(dates[94:248], np.array(sentiment_index[94:248]), color = 'green')
# ax2.plot(dates[93:248], data_picault['ecc index'], color = 'red')

# plt.show()