# -*- coding: utf-8 -*-
"""
Created on Mon Aug 22 21:19:32 2022

@author: jbaer
"""

import torch
import pandas as pd
import numpy as np
from transformers import BertForSequenceClassification, AdamW
from transformers import get_linear_schedule_with_warmup
#from transformers import BertModel

PATH = r"D:\Studium\PhD\Github\Fischerei - Master\Sentiment-Analysis-Western-Baltic-Sea\Sentiment Analysis"

import os
os.chdir(PATH)

from BERT_preprocess import transform_data
from BERT_LSTM_class import BERT_LSTM
from BERT_run import train, test, predict
seed = 1

# # Torch RNG
# torch.manual_seed(seed)
# torch.cuda.manual_seed_all(seed)

# # Python RNG
# np.random.seed(seed)

##############################################################################
# Load Data
##############################################################################

# Load data
#data = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\ECB\press_sents_sample2_labelded.xlsx')
data = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\inflation_lemmas_example.xlsx')

data = data[0:3000]

#data = data[0:2250]

#data = data.rename(columns = {'sentence': 'Sentences', 'Sentiment' : 'Label'})[['Sentences', 'Label']]
data = data.rename(columns = {'sentence': 'Sentences', 'Direction' : 'Label'})[['Sentences', 'Label']]
#data = data.rename(columns = {'sentence': 'Sentences', 'monetary' : 'Label'})[['Sentences', 'Label']]
#data = data.rename(columns = {'sentence': 'Sentences', 'outlook' : 'Label'})[['Sentences', 'Label']]
#data = data.rename(columns = {'sentence': 'Sentences', 'inflation' : 'Label'})[['Sentences', 'Label']]
data['Label'] = data['Label'].astype(np.int64)

##############################################################################
# Initialize BERT
##############################################################################

# Select max sentence length
max_len = 100

# Select a batch size for training.
batch_size = 32

# english bert-base-cased
# german deepset/gbert-base

# Set word embedding model
#word_embedding = "bert-base-uncased"
word_embedding = "deepset/gbert-base"

# Transform data and split them into train, validation and test data
train_dataloader, test_dataloader, validation_dataloader = transform_data(data, max_len, batch_size, word_embedding)

# Select classification layer 
bert_type = 'Sequence'

if bert_type == 'LSTM':
    model = BERT_LSTM()
if bert_type == 'Sequence':
    model =  BertForSequenceClassification.from_pretrained(word_embedding, num_labels=3)
else:
    print('Please set bert_type as LSTM or Sequence')    

# Get all parameters from BERT embedding layers
pretrained_names = [f'bert.{k}' for (k, v) in model.bert.named_parameters()]

# Get all parameters from LSTM classification layer
new_params= [v for k, v in model.named_parameters() if k not in pretrained_names]

# optimizer = AdamW(
#     [{'params': pretrained}, {'params': new_params, 'lr': learning_rate * 10}],
#     lr=learning_rate,
# )

learning_rate = 2e-5

param_optimizer = list(model.named_parameters())
no_decay = ['bias', 'gamma', 'beta']
optimizer_grouped_parameters = [
    {'params': [p for n, p in param_optimizer if not any(nd in n for nd in no_decay)],
     'weight_decay_rate': 0.01},
    {'params': [p for n, p in param_optimizer if any(nd in n for nd in no_decay)],
     'weight_decay_rate': 0.0}
]

# This variable contains all of the hyperparemeter information for our training loop
#optimizer = BertAdam(optimizer_grouped_parameters, lr=5e-6, warmup=.1)

# recommended are 2, 3 or 4 epochs
epochs = 4

max_train_steps = len(train_dataloader) * epochs

optimizer = AdamW(optimizer_grouped_parameters, lr=learning_rate, correct_bias=False)

lr_scheduler = get_linear_schedule_with_warmup(optimizer, num_training_steps = max_train_steps, num_warmup_steps=0)
#lr_scheduler = None

train_on_gpu = True
#train_on_gpu = False

PATH = r"D:\Studium\PhD\Github\Single-Author\Data\news_inflation_model.pt"
#PATH = r"D:\Studium\PhD\Github\Single-Author\Data\news_sentiment_model.pt"
#PATH = r"D:\Studium\PhD\Github\Single-Author\Data"

train(PATH, epochs, model, bert_type, optimizer, lr_scheduler, train_on_gpu, train_dataloader, validation_dataloader)

model.load_state_dict(torch.load(PATH))       

test(model, bert_type, train_on_gpu, test_dataloader)

from transformers import BertTokenizer
from BERT_pre_processing import pre_processing

##############################################################################
# Prepare ECB press cons and predict
##############################################################################

data_ECB_sents = pd.read_excel(r'D:\Studium\PhD\Github\Single-Author\Data\ECB_sents_prepared.xlsx')

tokenizer = BertTokenizer.from_pretrained(word_embedding, do_lower_case=True)    

data_ECB_sents = data_ECB_sents.rename(columns = {'sent': 'text'})

dataloader = pre_processing(data_ECB_sents, tokenizer, 100)

data_ECB_sents["Label"] = predict(model, bert_type, train_on_gpu, dataloader)
data_ECB_sents.to_excel('D:\Studium\PhD\Single Author\Data\ECB\press_sents_full_index_labeled_inf.xlsx')

##############################################################################

data = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\news_data_full_inflation.csv')
#data['tokens'] = data['tokens'].apply(lambda x: literal_eval(str(x)))

tokenizer = BertTokenizer.from_pretrained(word_embedding, do_lower_case=True)    

data = data.rename(columns = {'texts': 'text'})

data['text'] = data['text'].str.strip('[]')
data['text'] = data['text'].str.strip("'")

dataloader = pre_processing(data, tokenizer, 100)

data["Label"] = predict(model, bert_type, train_on_gpu, dataloader)
#data.to_excel('D:\Studium\PhD\Single Author\Data\dpa\sent_sent_label_BERT.xlsx')
#data.to_excel('D:\Studium\PhD\Single Author\Data\dpa\sent_inf_label_BERT.xlsx')

data_inf = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\sent_inf_label_BERT.xlsx')
data_sent = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\sent_sent_label_BERT.xlsx')

data_inf['date'] = pd.to_datetime(data_inf['date'])
data_sent['date'] = pd.to_datetime(data_sent['date'])

data_inf.set_index('date', inplace=True)
data_sent.set_index('date', inplace=True)

# Resample data to quarterly frequency
data_q_inf = data_inf.resample('Q')
data_q_sent = data_sent.resample('Q')

pos = data_q_sent['Label'].apply(lambda x: (x == 2).sum())
neg = data_q_sent['Label'].apply(lambda x: (x == 0).sum())
total = data_q_sent['Label'].count()

BERT_index_sent = (pos - neg) / total

inc = data_q_inf['Label'].apply(lambda x: (x == 2).sum())
dec = data_q_inf['Label'].apply(lambda x: (x == 0).sum())
total = data_q_inf['Label'].count()

BERT_index_inf = (inc - dec) / total

import matplotlib.pyplot as plt

plt.plot(BERT_index_sent.index[52:-4], list(BERT_index_sent)[52:-4])
plt.plot(BERT_index_inf.index[52:-4], list(BERT_index_inf)[52:-4])

BERT_index_comb = BERT_index_inf*BERT_index_sent

plt.plot(BERT_index_comb.index[52:-4], list(BERT_index_comb*-1)[52:-4])

BERT_index_comb.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_dire_senti_BERT_q.xlsx')
BERT_index_sent.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_senti_BERT_q.xlsx')
BERT_index_inf.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_dire_BERT_q.xlsx')

###

data_m_inf = data_inf.resample('M')
data_m_sent = data_sent.resample('M')

pos = data_m_sent['Label'].apply(lambda x: (x == 2).sum())
neg = data_m_sent['Label'].apply(lambda x: (x == 0).sum())
total = data_m_sent['Label'].count()

BERT_index_sent = (pos - neg) / total

inc = data_m_inf['Label'].apply(lambda x: (x == 2).sum())
dec = data_m_inf['Label'].apply(lambda x: (x == 0).sum())
total = data_m_inf['Label'].count()

BERT_index_inf = (inc - dec) / total

import matplotlib.pyplot as plt

plt.plot(BERT_index_sent.index[52:-4], list(BERT_index_sent)[52:-4])
plt.plot(BERT_index_inf.index[52:-4], list(BERT_index_inf)[52:-4])

BERT_index_comb = BERT_index_inf*BERT_index_sent

plt.plot(BERT_index_comb.index[52:-4], list(BERT_index_comb*-1)[52:-4])

BERT_index_comb.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_dire_senti_BERT_m.xlsx')
BERT_index_sent.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_senti_BERT_m.xlsx')
BERT_index_inf.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_dire_BERT_m.xlsx')













































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
