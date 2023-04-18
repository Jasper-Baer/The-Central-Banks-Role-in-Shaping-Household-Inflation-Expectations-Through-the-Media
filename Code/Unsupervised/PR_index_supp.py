# -*- coding: utf-8 -*-
"""
Created on Sat Nov  5 10:58:02 2022

@author: jbaer
"""

import re
import string as st
import ast
import copy

from nltk.tokenize import word_tokenize
from nltk.tokenize import sent_tokenize
from nltk.corpus import stopwords
from nltk.stem.snowball import SnowballStemmer
from collections import Counter
from tqdm import tqdm

import numpy as np
import pandas as pd

class prepare_text:
    
    def __init__(self, text, language = 'german'):

        self.text = text
        self.language = language

    def __clean_sentence(self, sentence):
    
        # remove numbers
        sentence = re.sub(r'\d+', '', sentence)
        
        # define punctations
        punct = st.punctuation + ('“”–€–’')
        
        # remove punctuations and convert characters to lower case
        sentence = "".join([char.lower() for char in sentence if char not in punct]) 
        
        # replace multiple whitespace with single whitespace and remove leading and trailing whitespaces
        sentence = re.sub('\s+', ' ', sentence).strip()
    
        return (sentence)

    def preproces_text(self):
    
        snowball_stemmer = SnowballStemmer(self.language)
        
        preprocessed_text = []
        token_mapping = {}

        for sentences in tqdm(self.text):
            
            preprocessed_sentence = []
            
            if not isinstance(sentences, list):
                
                sentences = ast.literal_eval(sentences) 
            
            for sentence in sentences:
                
                # Clean text
                sentence = self.__clean_sentence(sentence)
                
                # Tokenize text
                tokens = word_tokenize(sentence)
                
                # Define stopwords based on the input language
                stop_words = set(stopwords.words(self.language))
    
                if self.language == 'german':
                    negation_words = ['kein', 'keine', 'keinem', 'keinen', 'keiner', 'keines', 'nicht', 'nichts', 'ohne']
                elif self.language == 'english':
                    negation_words = ['not']
    
                # Only keep stopwords which are not negation words
                stop_words = stop_words.difference(negation_words)
                
                # Stem text and delete stopwords from it
                stem_sentence = []
                for w in tokens:
                     stem_w = snowball_stemmer.stem(w)
                     if w not in stop_words:
                         stem_sentence.append(stem_w)
                         token_mapping[w] = stem_w
         
                preprocessed_sentence.append(stem_sentence)
                
            preprocessed_text.append(preprocessed_sentence)

        # Return either a list of tokens for a single sentence or a list of lists of tokens for multiple sentences
        if len(preprocessed_text) == 1:
            return preprocessed_text[0], token_mapping
        else:
            return preprocessed_text, token_mapping

def count_ngrams(data):
    '''
    This function takes sentences and given labels for each sentence as input
    and counts how often each n_gram in the corpus occurs for each label.

    Parameters
    ----------
    data : Pandas DataFrame with a column "Sentences", "Label" and "tokens"
    
    Returns
    -------
    word dictionary : Dictionary with all n-grams wich occur at least 2 times in the corpus and the count 
    of their occurences in each class.
    
    n_grams: list of all n_grams in the coprus which occur at least 2 times
    '''
    
    # create dictionary for the occurence of the n_grams for each label
    word_dict = dict()
    
    # create dictionaryfor the occurence of the n_grams (independent of label)
    word_count = dict()
    
    for index, tokens in enumerate(tqdm((data['tokens']))):
        
        # select the current label 
        label = data.iloc[index]['Label']
        
        # Go through each n-gram from 10-gram to 1-gram (starting at 10-grams) where n = j
        for j in reversed(range(1,11)):
            
            # Split tokens into j-grams
            grams = [tokens[i:i+j] for i in range(len(tokens)-j+1)]
            
            if len(grams) != 0:
            
                for token in grams:
                    
                    if len(token) > 1:
                      
                        # join tokens and save them together with the current label
                        token = ' '.join(token)
                        entry = tuple([label,token])
                        
                        # if the entry is already in the dict, increase the 
                        # coresponding count by 1 otherwise create a new 
                        # entry 
                        if entry in word_dict.keys():
                            
                            word_dict[entry] += 1
                        
                        else:
                            
                            word_dict[entry] = 1
                        
                        # do the same as above for the word_count dict without the labels
                        if token in word_count.keys():
                            
                            word_count[token] += 1
                            
                        else:
                            
                            word_count[token] = 1
                            
                    
                    else:
                        
                        token = token[0]
                        entry = tuple([label,token])
    
                        if entry in word_dict.keys():
                            
                            word_dict[entry] += 1
                        
                        else:
                            
                            word_dict[entry] = 1
                            
                        if token in word_count.keys():
                            
                            word_count[token] += 1
                            
                        else:
                            
                            word_count[token] = 1
    
    n_grams = [word for word, count in word_count.items() if count > 1]
    word_dict = {word:count for word, count in tqdm(word_dict.items()) if word[1] in n_grams}
    
    return(word_dict, n_grams)

def create_dict(word_dict, n_grams, typ):
    
    direction_lex = pd.DataFrame({'n_grams': n_grams, 'positive ' + typ: np.repeat(0, len(n_grams)), 'neutral ' + typ: np.repeat(0, len(n_grams)), 'negative ' + typ: np.repeat(0, len(n_grams))})

    for gram, count in tqdm(word_dict.items()):
        
        #if gram[1] in n_grams:
            
            word = gram[1]
            label = gram[0]
            
            if label == 2:
                
                direction_lex.loc[direction_lex['n_grams'] == word, 'positive ' + typ] = count
                
            if label == 1:
            
                direction_lex.loc[direction_lex['n_grams'] == word, 'neutral ' + typ] = count
            
            if label == 0:
            
                direction_lex.loc[direction_lex['n_grams'] == word, 'negative ' + typ] = count
                
    direction_lex['positive ' + typ + ' index'] = direction_lex['positive ' + typ]/(direction_lex['positive ' + typ] + direction_lex['neutral ' + typ] + direction_lex['negative ' + typ])
    direction_lex['neutral ' + typ + ' index'] = direction_lex['neutral ' + typ]/(direction_lex['positive ' + typ] + direction_lex['neutral ' + typ] + direction_lex['negative ' + typ])
    direction_lex['negative ' + typ + ' index'] = direction_lex['negative ' + typ]/(direction_lex['positive '+ typ] + direction_lex['neutral ' + typ] + direction_lex['negative ' + typ])
            
    return(direction_lex)

def create_index(data, PR_lex, neg_window = 0, language = "german"):
    
    def delete_multiple_element(list_object, indices):
        indices = sorted(indices, reverse=True)
        for idx in indices:
            if idx < len(list_object):
                list_object.pop(idx)
                
        return(list_object)
    
    pos_list = []
    neu_list = []
    neg_list = []
    
    pos_PMI_list = []
    neu_PMI_list = []
    neg_PMI_list = []
    
    index_list = []
    index_list_PMI = []
    
    if (neg_window > 0 and language == "german"):
        
        negation_words = ['kein', 'keine', 'keinem', 'keinen', 'keiner', 'keines', 'nicht', 'nichts', 'ohne']
        
    elif (neg_window > 0 and language == "english"):
        
        negation_words = ['not']
        
    else:
        
        negation_words = []
     
    for tokens in tqdm(data['tokens']):
        
        tokens = tokens.copy()
        start_tokens = tokens.copy()
        
        negation_index = np.array([1 if neg in negation_words else 0 for neg in tokens])
        negation_index = np.where(negation_index == 1)[0]
        
        negations = []
        
        for idx in negation_index:
                    
            start = max(0, idx - neg_window)
            end = min(len(tokens)-1, idx + neg_window)
        
            negations.extend(list(range(start, end+1)))
                    
        negations = list(set(negations))
        
        pos = 0
        neu = 0
        neg = 0
        
        pos_PMI = 0
        neu_PMI = 0
        neg_PMI = 0
    
        # Go through each n-gram from 8-gram to 1-gram (starting at 8-grams) where n = j
        for j in reversed(range(1,9)):
            
            if j == 1:
                
                grams = tokens
                grams_neg = start_tokens
                keywords = [tuple(ngram)[0] for ngram in PR_lex['tokens'] if len(ngram) == j]
                     
            else:
                
                # Split tokens into j-grams
                grams = [tuple(tokens[i:i+j]) for i in range(len(tokens)-j+1)]
                
                grams_neg = [tuple(start_tokens[i:i+j]) for i in range(len(start_tokens)-j+1)]
                
                # Filter out all j-grams from lexicon
                keywords = [tuple(ngram) for ngram in PR_lex['tokens'] if len(ngram) == j]
                
                # if negations != []:
                
                #     neg_grams = [tuple(tokens[i:i+j]) for i in range(len(tokens)-j+1)]
    
           
            # Count j-grams
            #counts = dict(Counter(grams))  
            
            # Delete all n-grams from tokens which are not j-grams
            #keywords_speech = dict([(k,v) for k,v in counts.items() if k in keywords])
            
            keywords_speech = [k for k in (grams and grams_neg) if k in keywords]
      
            del_index = []  
      
            if j > 1 and keywords_speech != []:
                
                #print(j)
                
                #idx_start = 0
                
                # delete n_grams which were already considered previosly 
                for n_gram in keywords_speech:
                    
                    for i in range(len(tokens)+1-j):
                        
                        if tokens[i] == n_gram[0] and tokens[i+len(n_gram)-1] == n_gram[-1]:
                            
                            idx_start = i
                            idx_end = idx_start + j 
                            
                            del_idx = list(range(idx_start, idx_end+1))
                            del_index.extend(del_idx)
                    
                            # idx_start = tokens.index(n_gram[0])
                            
                        #del tokens[idx_start:idx_end]
            
            del_index = list(set(del_index))
            
            tokens = delete_multiple_element(tokens, del_index)
             
            # HIER!
            grams_neg_idx = [i for i in range(len(grams_neg)) if grams_neg[i] in keywords_speech]
            
            if negations != []:
            
                negations_ind = [-1 if gram_idx in negations else 1 for gram_idx in grams_neg_idx]
                
            else:
                
                negations_ind = [1]*len(keywords_speech)
            
            # Count all lexicon j-grams in tokens und multiply the number of their 
            # occurrences with their respective probabilities
            
            count_keywords = Counter(keywords_speech)
            
            if keywords_speech != []:
            
                for idx, k in enumerate(list(set(keywords_speech))):
                    
                    ocur = count_keywords[k]
                    
                    if j > 1:
                        
                        k = ' '.join(k)
                                                                
                    negation = negations_ind[idx]
    
                    keyword_prob = PR_lex[PR_lex['n_grams'] == k]
                
                    if negation == -1:
                    
                        pos += float(keyword_prob['negative'])*ocur
                        neu += float(keyword_prob['neutral'])*ocur
                        neg += float(keyword_prob['positive'])*ocur
                        
                        pos_PMI += float(keyword_prob['PMI negative'])*ocur
                        neu_PMI += float(keyword_prob['PMI neutral'])*ocur
                        neg_PMI += float(keyword_prob['PMI positive'])*ocur
                        
                    elif negation == 1:
                        
                        pos += float(keyword_prob['positive'])*ocur
                        neu += float(keyword_prob['neutral'])*ocur
                        neg += float(keyword_prob['negative'])*ocur
                        
                        pos_PMI += float(keyword_prob['PMI positive'])*ocur
                        neu_PMI += float(keyword_prob['PMI neutral'])*ocur
                        neg_PMI += float(keyword_prob['PMI negative'])*ocur
          
        label_all = pos + neu + neg
        label_all_PMI = pos_PMI + neu_PMI + neg_PMI
        
        if label_all > 0:
            
            pos_share = pos/label_all
            neu_share = neu/label_all
            neg_share = neg/label_all
            
            pos_PMI_share = pos_PMI/label_all_PMI
            neu_PMI_share = neu_PMI/label_all_PMI
            neg_PMI_share = neg_PMI/label_all_PMI
            
        elif label_all == 0:
            
            pos_share = 0
            neu_share = 0
            neg_share = 0
            
            pos_PMI_share = 0
            neu_PMI_share = 0
            neg_PMI_share = 0
        
        pos_list.append(pos_share)
        neu_list.append(neu_share)
        neg_list.append(neg_share)
        
        pos_PMI_list.append(pos_PMI_share)
        neu_PMI_list.append(neu_PMI_share)
        neg_PMI_list.append(neg_PMI_share)
        
        index = pos_share - neg_share
        index_PMI = pos_PMI_share - neg_PMI_share
        
        index_list.append(index)
        index_list_PMI.append(index_PMI)
    
    data['pos share'] = pos_list
    data['neu share'] = neu_list
    data['neg share'] = neg_list
    
    data['pos share PMI'] = pos_PMI_list
    data['neu share PMI'] = neu_PMI_list
    data['neg share PMI'] = neg_PMI_list
    
    data['index'] = index_list 
    data['index PMI'] = index_list_PMI
  
    return(data)

def inf_senti_index(data):

    index = []    
    count = []

    for year in set(data['year']):
        
        yearly_data = data[data['year'] == year]
        
        for month in set(yearly_data['month']):
            
            monthly_data = yearly_data[yearly_data['month'] == month]
            idx = (len(monthly_data[monthly_data['Label'] == 2]) - len(monthly_data[monthly_data['Label'] == 0]))/len(monthly_data)
            
            count.append(len(monthly_data))
            index.append(idx)
            
    return(count, index)