# -*- coding: utf-8 -*-
"""
Created on Thu Dec 29 16:11:16 2022

@author: Nutzer
"""

from nltk.tokenize import word_tokenize

import pandas as pd 
import numpy

data_news = pd.read_excel('D:\Studium\PhD\Single Author\Data\inflation_news.xlsx')

sents = []

for sent in data_news['sentence']:
    
    sents_token = word_tokenize(sent)
    sents.append(sents_token)
  
import gensim
from gensim.models import Word2Vec

model1 = gensim.models.Word2Vec(sents, min_count = 1,vector_size = 100, window = 5)

model1.wv.similarity('inflation', 'steigt')
model1.wv.most_similar('teuer')

numpy.dot(model1.wv['inflation'], model1.wv['teuer'])/(numpy.linalg.norm(model1.wv['inflation'])* numpy.linalg.norm(model1.wv['teuer']))

numpy.dot(model1.wv['inflation'], model1.wv['teuer'])/(numpy.linalg.norm(model1.wv['inflation'])* numpy.linalg.norm(model1.wv['teuer']))