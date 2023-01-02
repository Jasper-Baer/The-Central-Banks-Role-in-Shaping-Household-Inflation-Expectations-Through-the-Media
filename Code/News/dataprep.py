# -*- coding: utf-8 -*-
"""
Created on Sun Jul 25 16:06:42 2021

@author: Nutzer
"""

######### CITE SOMAJO ! ######################
from somajo import SoMaJo
######### CITE SOMAJO ! ######################

from tensorflow.keras.preprocessing.sequence import pad_sequences
import pandas as pd
from torch.utils.data import TensorDataset, DataLoader
import torch
import numpy as np
import treetaggerwrapper
from nltk.corpus import stopwords
from sklearn.feature_extraction.text import TfidfVectorizer 

def tokenizer_articles(data):
    
    # initialize tokenizer
    tokenizer = SoMaJo("de_CMC", split_camel_case=True)
    sentence_split = pd.DataFrame()
    
    # split articles into sentences
    articles_token = [tokenizer.tokenize_text([x]) for x in data['text']]
    
    i = 0
    for article in articles_token:
            for sent in article:  
                
                metadata = data.loc[:, data.columns != 'text'].iloc[i]
                metadata['text'] = [" ".join([token.text for token in sent])][0]                
                sentence_split = sentence_split.append(metadata)
            i += 1
    
    return(sentence_split)

def tokenize_sentences(sentence):
    
    # initialize tokenizer
    tokenizer = SoMaJo("de_CMC", split_camel_case=True)
    
    # split sentences into words
    sent_token = tokenizer.tokenize_text([sentence])
    token_sent = []
    
    for sent in sent_token:
            
        sent_tokens = [token.text for token in sent]     
        token_sent.append(sent_tokens)

    return(token_sent)

def pre_processing(sentences, tokenizer, max_len):
    
    fish_sentences = ["[CLS] " + sentence + " [SEP]" for sentence in sentences['text']]
    fish_tokenized_texts = [tokenizer.tokenize(sent) for sent in fish_sentences]
    fish_input_ids = [tokenizer.convert_tokens_to_ids(x) for x in fish_tokenized_texts]
    fish_input_ids = pad_sequences(fish_input_ids, maxlen=max_len, dtype="long", truncating="post", padding="post")
    
    # Create attention masks
    fish_attention_masks = []
      
      # Create a mask of 1s for each token followed by 0s for padding
    for seq in fish_input_ids:
       seq_mask = [float(i>0) for i in seq]
       fish_attention_masks.append(seq_mask)
    
    fish_inputs = torch.tensor(fish_input_ids)
    fish_masks = torch.tensor(np.array(fish_attention_masks))
    
    batch_size = 32
    
    # Create an iterator of our data with torch DataLoader. This helps save on memory during training because, unlike a for loop, 
    # with an iterator the entire dataset does not need to be loaded into memory
    
    fish_data = TensorDataset(fish_inputs, fish_masks)
    
    #sampler not realy needed
    #fish_sampler = RandomSampler(fish_data)
    
    fish_dataloader = DataLoader(fish_data, batch_size=batch_size) # sampler=fish_sampler
    
    return(fish_dataloader)
    
def lemmatize_sentences(sentences, remove_stopwords = 'all'):
    
    # initialize list with all negation words which are kept for the negation feature
    neg_words = ["nicht", "nichts", "kein", "keinen", "keine", "keiner", 
                 "keines", "keinem", "keins", "niemals", "nie"]
    
    # initialize list with special charakter to remove
    delims = ["-", "_", "#", "+", "*", "~", "$", "%", "`", "´", "=", "§", 
              "{", "}", "/", "[", "]", "^", "°", str("("), str(")"), str("'"),
              "&", "in+die","zu+die", "@card@",".", ",", ";",":", str("„"), 
              "@ord@",str('"'), "an+die", "von+die", 'bei+die',".", ",", "?",
              "!", ":", ";", 'für+die', '“', '„', '«', '»', 'bu', 'BU','das', 
              'für', 'fuer', 'oz'] 
    
    stopset = stopwords.words("german")
    
    if remove_stopwords == ('all' or 'delim'):
        
        # load set with stopwords and add delimiters to them
        stopset += delims 
    
    elif remove_stopwords == ('all' or 'negations'):
        
        # add negation words from stopword list
        stopset += neg_words
    
        # add token for links and ip to stopword list
    stopset += ['replaced-dns', 'replaced-ip']

    stopset = set(stopset)

    # use the treetagwrapper to lemmatize sentences
    tagger = treetaggerwrapper.TreeTagger(TAGLANG='de')
    lemmas = [[j for j in treetaggerwrapper.make_tags(tagger.tag_text(sentences[i]), allow_extra = False)] for i in range(len(sentences))]
    sent_lemmas = [[j[2].lower() for j in lemmas[i] if type(j) == treetaggerwrapper.Tag]for i in
                   range(len(lemmas))]
    
    if remove_stopwords == ('all' or 'dellim' or 'negations'):
        
        # remove stopwords from lemmas and (POS)
        sent_lemmas  = [[word for word in sent_lemmas[i] if word not in stopset] for i in range(0, len(sent_lemmas))]
        lemma_str = [" ".join(j) for j in sent_lemmas]
        lemma_str = [sent.replace('„','') for sent in lemma_str]
        lemma_str = [sent.replace('.','') for sent in lemma_str]
        lemma_str = [sent.replace('“','') for sent in lemma_str]
        
    else:
        
        lemma_str = [" ".join(j) for j in sent_lemmas]
    
    return(lemma_str)
    
def reorder_data(data, year, start_month, end_month):
    
    start_date = str(year) + start_month
    end_date = str(year+1) + end_month
    yearly_data = data[(data["Date"] >= start_date) & (data["Date"] <= end_date)]
    
    return(yearly_data)

def average_sentiment(data):
    
    if len(data) > 0:
        
        pos_sent = len(data[data['Label'] == 2])
        neu_sent = len(data[data['Label'] == 1])
        neg_sent = len(data[data['Label'] == 0])
        
        sentiment = (pos_sent - neg_sent)/len(data)
        
        pos_sent_ratio = pos_sent/len(data)
        neu_sent_ratio = neu_sent/len(data)
        neg_sent_ratio = neg_sent/len(data)
        
        results = [sentiment, [pos_sent, neu_sent, neg_sent], [pos_sent_ratio, neu_sent_ratio, neg_sent_ratio]]
        
    else:
        
        results = None
    
    return(results)    

def transform_tf_idf(data):
    
    vectorizer = TfidfVectorizer()
    vecs = vectorizer.fit_transform(data)
    words = vectorizer.get_feature_names()
    dense_word_vec = vecs.todense()
    word_vec_list = dense_word_vec.tolist() 
    word_vec_list = map(sum, zip(* word_vec_list))
    tf_idf_scores = pd.Series(word_vec_list, index = words)
    tf_idf_scores = tf_idf_scores.sort_values(ascending = False)
    
    return(tf_idf_scores)

def sentiment_index(data, start_month, end_month):
  
    # initialize dataframes to store results
    sentiment_data = pd.DataFrame()
    
    for year in range(2004,2022):
        
        yearly_data = reorder_data(data, year, start_month, end_month)
        yearly_sentiment  = average_sentiment(yearly_data) 
        
        if yearly_sentiment != None:
        
            sentiment = pd.DataFrame({'year':[year], 'Sentiment Index': [yearly_sentiment[0]], 
                                      'pos': [yearly_sentiment[1][0]], 'neu': [yearly_sentiment[1][1]],
                                      'neg': [yearly_sentiment[1][2]], 'pos_sent_ratio': [yearly_sentiment[2][0]],
                                      'neu_sent_ratio': [yearly_sentiment[2][1]], 'neg_sent_ratio': [yearly_sentiment[2][2]]})
        else:
            
            sentiment = None
        
        sentiment_data = sentiment_data.append(sentiment)
        
    return(sentiment_data)