# -*- coding: utf-8 -*-
"""
Created on Mon Jul 12 19:53:18 2021

@author: mokuneva
"""

import re

def correct_url_dpa(text):
    
    """  
    This is a function that removes URLs, html file references, and e-mails.
    """
    
    # Define a list of patterns and their replacements
    # 1: Change "wertet.der" to "wertet. der"
    # 2: Change "{any_digit}.dezember" to "{any_digit}. dezember"
    # 3: Change "{any_word}....de" to "{any_word} de"
    # 4: Change "...de" to " de"
    patterns = [
        (r'([A-ZÄÖÜ]?[a-zäöüß]+)\.(der|denn)', r'\1. \2'),
        (r'(\d)\.dezember', r'\1. dezember'),
        (r'(\w+)\.{2,}de', r'\1. de'),
        (r'\.{2,}de', r' de')
    ]

    # Apply all the patterns and their replacements to the text
    for pattern, replacement in patterns:
        text = re.sub(pattern, replacement, text)
      
    exceptions = {'tagesschau.de', 'Web.de', 'web.de', 'freenet.de', 'Booking.com', 'Siegelklarheit.de',
                  'handwerk.de', 'Handwerk.de', 'downdetector.com', 'allestörungen.de', 'Netzpolitik.org',
                  'pey.de', 'scheidung.de', 'gekündigt.de', 'flightright.de', 'Aerobuzz.de',
                  'mobile.de', 'autoscout24.de', 'buch.de', 'amazon.com', 'libri.de', 'MP3.com',
                  'manager-magazin.de', 'Liveleak.com', 'stern.de', 'faz.net', 'wikileaks.org',
                  'Bild.de', 'icasualties.org', 'Neckermann.de', 'neckermann.de',
                  'bild.de', 'Salesforce.com'}

    def replace_url(match):
        url = match.group(0)
        clean_url = url.rstrip(')').rstrip("»").lstrip("«")
        return ' ' if clean_url not in exceptions else url
        
    regex = r'''\(Rückfragen\: [^)]+\)|
    |Den vollständigen Kommentar(?: von [\w\s]+)? lesen Sie unter\:.*$|
    |\([Ii]nternet\: [^)]+\)|
    |\(UNICEF-Spendenkonto\: [^)]+\)|
    |\(Spenden\: [^)]+\)|
    |\(Programm\: [^)]+\)|
    |\(Die Umfrage im Internet\: [^)]+\)|
    |(?:\(Adresse\: |\(Internet-Adresse\: )(?:\S+\.com)(?:[^)]*?\))|
    |\S+\.html|
    |\S+\.de[^. ]*(?:\.pdf)?|
    |\S+\.org[^. ]*|
    |\S+\.com[ ]\)|
    |\S+\.com[^. ]*|
    |\S+\.eu\.int[^. ]*|
    |\S+\.net[^. ]*|
    |\S+\.heim\.at[^. ]*'''
    
    text = re.sub(regex, replace_url, text)

    # Make sure that there are no extra white spaces
    text = ' '.join(text.split()) 
    
    return text