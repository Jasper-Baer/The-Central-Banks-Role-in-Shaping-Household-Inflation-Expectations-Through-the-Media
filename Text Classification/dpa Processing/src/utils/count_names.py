# -*- coding: utf-8 -*-
"""
Created on Tue Apr 25 17:37:12 2023

@author: mokuneva
"""

from collections import Counter
import re

def count_names(text, word_count, names_list):
    
    '''This function computes the ratio of the occurrence of names to the
    total word count (excluding numbers) within a given text.'''
    
    words = re.findall(r'\b\w+\b', text)
    word_counts = Counter(words)
    
    count = sum(word_counts[name] for name in names_list)
    return count / word_count