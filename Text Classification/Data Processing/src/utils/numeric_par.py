# -*- coding: utf-8 -*-
"""
Created on Mon Jan 30 12:03:11 2023

@author: mokuneva
"""

import re
import sys
import os
sys.path.insert(1, os.getcwd().replace('dpa code', 'Handelsblatt'))
from src.utils import count_words_mp

def numeric_par(paragraphs, tr = 0.7, par_len = 10):
    """ 
    This function determines if a text contains at least one paragraph 
    that is predominantly comprised of numbers and that is at least 10 words long.
    
    :paragraphs: A list of strings, where each string is a paragraph
    :tr: Threshold value that the share of numbers has to exceed to classify the
    corresponding paragraph as mostly consisting of numbers
    :par_len: Any string with a length less that this threshold is considered
    too short to be classified as a paragraph
    """
    
    count_n = []
    word_count = []
    for p in paragraphs:
        # count numbers in a paragraph
        count_n.append(len(re.findall(r'[0-9]+\.[0-9]+|[0-9]+\,[0-9]+|[0-9]+', p)))
        # count words in a paragraph
        word_count.append(count_words_mp.count_words_mp(p))
        
    # check if there is at least one paragraph that is at least par_len words long and
    # that contains at least tr*100% of numbers
    for n, word in zip(count_n, word_count):
        if word >= par_len and n/word >= tr:
            return True
    
    return False