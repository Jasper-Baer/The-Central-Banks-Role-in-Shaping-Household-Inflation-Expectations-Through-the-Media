# -*- coding: utf-8 -*-
"""
Created on Sun Jan  9 19:25:32 2022

@author: Nutzer
"""

import re

def clean_dpa_references(text):
    """  
    This function removes all dpa references from a string
    """

    text = re.sub('''\s\(dpa\)\s-\s|
       |\s\(dpa/vwd\)\s-\s|
       |\s\(dpa/tk\)\s-\s|
       |\s\(dpa-AFX\)\s-\s|
       |\s\(dpa/tk\)\s-\s|
       |\s\(dpa-AFX/APA\)\s-\s|
       |\s\(euro adhoc\)\s-\s|
       |\s\(ots\)\s-\s|
       |\s\(dpa-AFX Broker\)\s-\s|
       |\s\(AFX-CH\)\s-\s|
       |\s\(AFX\)\s-\s''', ' ', text)    
    
    return(text)