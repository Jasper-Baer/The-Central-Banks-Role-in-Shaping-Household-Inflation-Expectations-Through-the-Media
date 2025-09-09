# -*- coding: utf-8 -*-
"""
Created on Sun May 16 21:26:31 2021

@author: jbaer
"""
import re

def numeric_articles(text, word_count, tr = 0.5):
    """ 
    This function determines if a text consists mostly of numbers.
    
    :text: A string which the function evaluates either as mostly consisting 
    of numbers or not
    :word: count: Number of words in text
    :tr: Threshold value that the share of numbers has to exceed to classify the
    corresponding text as mostly consisting of numbers
    """
    
    # count numbers in text
    count_n = len(re.findall(r'[0-9]+\.[0-9]+|[0-9]+\,[0-9]+|[0-9]+', text))
                  
    # check if share of numbers is above threshold
    if count_n/word_count > tr:
        numeric_article = True
    else:
        numeric_article = False
    
    return numeric_article