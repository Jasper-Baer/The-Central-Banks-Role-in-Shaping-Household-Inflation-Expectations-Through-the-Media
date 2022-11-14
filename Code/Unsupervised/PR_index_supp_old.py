# -*- coding: utf-8 -*-
"""
Created on Sat Nov  5 10:58:02 2022

@author: jbaer
"""

import re
import string as st

from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from nltk.stem import PorterStemmer
from collections import Counter
from tqdm import tqdm

class prepare_text:
    
    def __init__(self, text):
        self.text = text

    def preproces_text(self):
        
        def clean_sentence(sentence):
        
            # remove numbers
            sentence = re.sub(r'\d+', '', sentence)
            
            # define punctations
            punct = st.punctuation + ('“”–€–’')
            
            # remove punctuations and convert characters to lower case
            sentence = "".join([char.lower() for char in sentence if char not in punct]) 
            
            # replace multiple whitespace with single whitespace and remove leading and trailing whitespaces
            sentence = re.sub('\s+', ' ', sentence).strip()
        
            return (sentence)
    
        port_stemmer = PorterStemmer()
        
        preprocessed_text = []
            
        for sentence in tqdm(self.text):
            
            #text = ' '.join(text)
            
            # use clean text function on data
            sentence = clean_text(sentence)
            
            # tokenize text
            tokens = word_tokenize(sentence)
            
            # define stopwords
            stop_words = set(stopwords.words('german')) 
            # stop_words = set(stopwords.words('english')) 
            
            # stem text and delete stopwords from it
            stem_sentence = [port_stemmer.stem(w) for w in tokens]
            stem_sentence = [w for w in stem_sentence if not w in stop_words]
            
            preprocessed_text.append(stem_sentence)
            
        return(preprocessed_text)

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

def create_index(data, PR_lex):
    
    pos_list = []
    neu_list = []
    neg_list = []
    
    index_list = []
    
    for tokens in tqdm(data['tokens']):
        
        pos = 0
        neu = 0
        neg = 0
    
        # Go through each n-gram from 8-gram to 1-gram (starting at 8-grams) where n = j
        for j in reversed(range(1,9)):
            
            if j == 1:
                
                grams = tokens
                keywords = [tuple(ngram)[0] for ngram in PR_lex['tokens'] if len(ngram) == j]
       
            else:
                
                # Split tokens into j-grams
                grams = [tuple(tokens[i:i+j]) for i in range(len(tokens)-j+1)]
                
                # Filter out all j-grams from lexicon
                keywords = [tuple(ngram) for ngram in PR_lex['tokens'] if len(ngram) == j]
    
            # Count j-grams
            counts = dict(Counter(grams))  
            
            # Delete all n-grams from tokens which are not j-grams
            keywords_speech = dict([(k,v) for k,v in counts.items() if k in keywords])
            
            # Count all lexicon j-grams in tokens und multiply the number of their 
            # occurrences with their respective probabilities
            for k,v in keywords_speech.items():
                
                if j > 1:
                    
                    k = ' '.join(k)
                    
                keyword_prob = PR_lex[PR_lex['keyword'] == k]
                
                pos += float(keyword_prob['positive']*v)
                neu += float(keyword_prob['neutral']*v)
                neg += float(keyword_prob['negative']*v)
            
            # ?????
            # for keyword in keywords_speech:
            
            #     ind = [range(i,i+len(keyword)) for i,x in enumerate(tokens) if tokens[i:i+len(keyword)] == keyword]
            #     ind_set = set([item for sublist in ind for item in sublist])
            #     tokens = [x for i,x in enumerate(tokens) if i not in ind_set]     
          
        label_all = pos + neu + neg
        
        pos_share = pos/label_all
        neu_share = neu/label_all
        neg_share = neg/label_all
        
        pos_list.append(pos_share)
        neu_list.append(neu_share)
        neg_list.append(neg_share)
        
        index = pos_share - neg_share
        
        index_list.append(index)
    
    data['pos share'] = pos_list
    data['neu share'] = neu_list
    data['neg share'] = neg_list
    
    data['index'] = index_list 
    
    #data['date'] = pd.to_datetime(data['date'])
  
    return(data)