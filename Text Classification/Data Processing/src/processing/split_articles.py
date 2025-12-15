# -*- coding: utf-8 -*-
"""
Created on Sun May 23 21:21:11 2021

@author: jbaer
"""

import re
import pandas as pd

def split_articles(multiple_articles):
    """
    This function splits up collections of articles into single articles.
    """
    split_art =[]
    
    multiple_articles.reset_index(inplace = True, drop = True)
    
    for index, row in multiple_articles.iterrows():
                
        mult_art = []
        
        no_headline = False
        
        if 'WEITERE MELDUNGEN:\n' in row['texts']:
            row['texts'] = row['texts'].split('WEITERE MELDUNGEN:\n')[0]
            
        if 'W I R T S C H A F T\n' in row['texts']:
            row['texts'] = row['texts'].replace('W I R T S C H A F T\n', '')
            
        if len(re.findall('(?<=PARAGRAPH)\n{0,1}\s*?\({0,1}Sperrf{0,1}rist.+\){0,1}', row['texts'])) > 0:
            row['texts'] = re.sub('(?<=PARAGRAPH)\n{0,1}\s*?\({0,1}Sperrf{0,1}rist.+\){0,1}','',row['texts'])
        
        # Remove pictures references
        if len(re.findall('\n\(mit dpa-Grafik.+\)\s=', row['texts'])) > 0:
            row['texts'] = re.sub('\n\(mit dpa-Grafik.+\)\s=','',row['texts'])        
        
        # Remove the docket number 
        if len(re.findall(r'\(Aktenzeichen.+\)|\(Az\.:.+\)', row['texts'])) > 0:
            row['texts'] = re.sub('\(Aktenzeichen.+\)|\(Az\.:.+\)','',row['texts'])  
                    
        if ' bdt0055 3 pl 90  dpa 0062' in row['texts']:
            row['texts'] = row['texts'].replace(' bdt0055 3 pl 90  dpa 0062', '')
        
        # By mistake, the same article contains two dpa references.
        if 'Washington/Brüssel (dpa) - Berlin/Washington (dpa)' in row['texts']:
            row['texts'] = row['texts'].replace('Washington/Brüssel (dpa) - Berlin/Washington (dpa)', 'Washington/Brüssel (dpa)')
        
        # Remove metadata from the text
        if '\ndpa mhxfn022\nvv fnbf\nfnb 000\nNachrichtenüberblick/dpa/Vermischtes/\ndpa-Nachrichtenüberblick VERMISCHTES14.10.2002 - 05:00 Uhr =' in row['texts']:
            row['texts'] = row['texts'].replace('\ndpa mhxfn022\nvv fnbf\nfnb 000\nNachrichtenüberblick/dpa/Vermischtes/\ndpa-Nachrichtenüberblick VERMISCHTES14.10.2002 - 05:00 Uhr =', '')
        
        # Remove metadata from the text
        if len(re.findall('(?:dpa ks\n){0,1}dpa-Nachrichtenüberblick[\S\s]+?(?:VERMISCHTES[\S\s]+?=\n|VERMISCHTES\n)',row['texts'])) > 0:
            row['texts'] = re.sub('(?:dpa ks\n){0,1}dpa-Nachrichtenüberblick[\S\s]+?(?:VERMISCHTES[\S\s]+?=\n|VERMISCHTES\n)','',row['texts'])
            
        # Remove dpa reference from the text
        if '.dpa la' in row['texts']:
            row['texts'] = row['texts'].replace('.dpa la', '.')
            
        # Remove metadata from the text 
        if len(re.findall(r"""\(dpa-Umfrage\)\n|\(dpa-Grafik.+\)\n|\(Bilder.+\)\n|\(dpa-Bild.+\)\n|\ndpa yyzz kfAuto[\S\s]+$""", row['texts'])) > 0:
            row['texts'] = re.sub("""\(dpa-Umfrage\)\n|\(dpa-Grafik.+\)\n|\(Bilder.+\)\n|\(dpa-Bild.+\)\n|\ndpa yyzz kfAuto[\S\s]+$""",'',row['texts']) 

        # Remove metadata from the text 
        if len(re.findall(r'\n*\s*dpa yyzz ra[\s\S]+$|\n*\s*dpa gra yyzz n1 gra[\s\S]+$', row['texts'])) > 0:
            row['texts'] = re.sub(r'\n*\s*dpa yyzz ra[\s\S]+$|\n*\s*dpa gra yyzz n1 gra[\s\S]+$','',row['texts'])
            
        # Remove internal information
        if len(re.findall(r'\n*# dpa-Notizblock[\s\S]+$|\n*# Notizblock[\s\S]+$', row['texts'])) > 0:
            row['texts'] = re.sub(r'\n*# dpa-Notizblock[\s\S]+$|\n*# Notizblock[\s\S]+$','',row['texts'])       
                    
        # Typos that lead to the wrong splitting
        typos_dic = {
        "seien.,": "seien.",
        "geben.s": "geben.",
        "zulegte.1": "zulegte.",
        "lassen.e": "lassen.",
        "Sonderurlaub.e": "Sonderurlaub.",
        "zeigen.t": "zeigen.",
        "viel.a": "viel.",
        "ab.i": "ab.",
        "Bodenobjekten.e": "Bodenobjekten.",
        "seien.m": "seien.",
        "Koalitionsgespräch.e": "Koalitionsgespräch.",
        "weiterführen.d": "weiterführen.",
        ".#+": "."}

        for typo, correction in typos_dic.items():
            row['texts'] = row['texts'].replace(typo, correction)  
                
        weekday = ['MONTAG', 'DIENSTAG', 'MITTWOCH', 'DONNERSTAG', 'FREITAG']
        # In the articles of the type 'Analysten-Einstufungen', weekdays are not
        # headlines.
        if any(st in row['title'] for st in ['Analysten-Einstufungen', 'ANALYSTEN-EINSTUFUNGEN']):
            for day in weekday:
                row['texts'] = row['texts'].replace(day, '')
                
        # Text version with a 'PARAGRAPH' tag
        txt_par = row["texts"]
        row["texts"] = row["texts"].replace(' PARAGRAPH ', ' ').replace(' PARAGRAPH', '')
            
        # Capitalized words at the beginning of the paragraph.
        capital_words1 = re.findall(r'(?:\s{2,})[/A-ZÄÖÜß]{4,}\b', row["texts"])
        # Capitalized words at the beginning of the line.
        capital_words2 = re.findall(r'(?:\n)[A-ZÄÖÜß-]{5,}\b.{0,}(?<![a-z])\n', row["texts"])
        # Headlines of the articles with multipe dpa references.
        dpa_type = re.findall(r'(?:^|(?<=\.\s{2})|(?<=\.»\s{2})|(?<=(?<!dpa)\)\s{2})|(?<=Maschinenbauers\s{2}))[\S\s]+?(?=\(dpa(?!\-Grafik).+?)', row['texts'].strip().replace("\n", ' ').replace("\t", ' '))
          
        # A fully capitalized word at the beginning of a paragraph
        # indicates the beginning of a new article, 'BEGRENZTES' is an exception.
        # Exclude articles with multiple dpa references.
        if (len(capital_words1) > 1 and all('BEGRENZTES' not in w for w in capital_words1) and len(dpa_type) <= 1) or (len(capital_words2) > 1 and len(dpa_type) <= 1):
            
            # Search for dpa references
            dpa_ref = re.findall(r'\(dpa.*?\)', row["texts"])
            change_split_pattern = False
            
            # If there is a dpa reference in the article
            if len(dpa_ref) >= 1:
                # If there are capitalized titles that start from \n and end with \s{2}
                if len(re.findall(r'\n(?:[A-Z\' ])[A-ZÄÖÜß0-9-\: \'\,\.\n]{5,}?\s{2}', row["texts"].strip().replace("\n", ' ').replace("\t", ' '))) >= 1:
                    
                    # find all the paragraphs
                    paragraphs = re.findall(r'((?:^|(?:\s{2}))(?:[A-ZÄÖÜß:\-\(]).+?(?:\s{2}|$))', row["texts"].strip().replace("\n", ' ').replace("\t", ' '))
                    num_par = len(paragraphs)
                    
                    # if the number of paragraphs is 3 times larger than the number of capitalized headlines
                    if num_par > 3*len(re.findall(r'\n(?:[A-Z\' ])[A-ZÄÖÜß0-9-\: \'\,\.\n]{5,}?\s{2}', row["texts"])):
                        mult_art = [p.strip() for p in paragraphs]
                        no_headline = True
                    else:
                        headlines = re.findall(r'\n(?:[A-Z\' ])[A-ZÄÖÜß0-9-\: \'\,\.\n]{5,}?\s{2}', row["texts"])
                        headlines = [h.strip().replace("\n", ' ') for h in headlines if h.strip() != '' ]
                        
                        txt = row['texts']
                        txt = txt.strip().replace("\n", ' ').replace("\t", ' ')
                        
                        # Replace headline with 'SEP'
                        for ind, headline in enumerate(headlines):
                            txt = txt.replace(headline, 'SEP', 1)
                            headlines[ind] = ' '.join(headline.split())
                        
                        # Split text by 'SEP' tokens
                        mult_art = [i.strip() for i in txt.split('SEP')][1:]
                
                # If there are articles of the Analysten-Einstufungen type with the headlines that start from \.\n{1} and end with smth like '\nBerlin - '
                elif len([r.strip() for r in re.findall(r'(?:^|(?<=\.\n{1}))[^\.]+?(?=\n[\s]*?[A-ZÄÖÜß][A-ZÄÖÜa-zäöüß /]+ - )', row["texts"]) if r.strip() != '']) > 1 and \
                    any(st in row['title'] for st in ['Analysten-Einstufungen', 'ANALYSTEN-EINSTUFUNGEN']):
                    
                    # The pattern for the first headline depends on whether there is a period after
                    # the first paragraph. For consistency, remove the period
                    # after the first paragraph, if present.
                    if len(re.findall(r'(?:^\s*)FRANKFURT[\S\s]+?\n{2}', row['texts'])) > 0:
                        first_paragraph = re.findall(r'(?:^\s*)FRANKFURT[\S\s]+?\n{2}', row['texts'])[0].strip() 
                        if first_paragraph[-1] == '.':
                            row['texts'] = row['texts'].replace(first_paragraph, first_paragraph[:-1])
                            
                    # Capitalized words in the beginning of the paragraphs (not headlines)
                    word_par = re.findall(r'(?:\s{2,})[/ A-ZÄÖÜß-]{2,}(?= -)', row["texts"])
                    word_par = [w.strip() for w in word_par]
 
                    # The case where capitalized headlines contain period
                    if len([r.strip() for r in re.findall(r'\n(?:[A-Z\' ])[A-ZÄÖÜß0-9-\: \'\,\.\(\)\&+]{2,}?(?:\n|\s{2}(?!-))', row["texts"]) if r.strip() != '']) > \
                        (len(re.findall(r'(?:^|(?<=\.\n{1}))[^\.]+?(?=\n[\s]*?[A-ZÄÖÜß][A-ZÄÖÜa-zäöüß /]+ - )', row['texts'])) + 1):
                        headlines = [r.strip() for r in re.findall(r'\n(?:[A-Z\' ])[A-ZÄÖÜß0-9-\: \'\,\.\(\)\&+]{2,}?(?:\n|\s{2}(?!-))', row["texts"]) if r.strip() != '']
                    # If there are empty headlines
                    elif len([r for r in re.findall(r'\n(?:[A-Z\' ])[A-ZÄÖÜß0-9-\: \'\,\.\(\)\&+]{2,}?(?:\n|\s{2}(?!-))', row["texts"]) if r.strip() == '']) >= 1 and \
                        len([r.strip() for r in re.findall(r'\n(?:[A-Z\' ])[A-ZÄÖÜß0-9-\: \'\,\.\(\)\&+]{2,}?(?:\n|\s{2}(?!-))', row["texts"]) if r.strip() != '']) >= 1:
                        change_split_pattern = True
                        headlines =  re.findall(r'\n(?:[A-Z\' ])[A-ZÄÖÜß0-9-\: \'\,\.\(\)\&+]{2,}?(?:\n|\s{2}(?!-))', row["texts"])
                        row['texts'] = re.sub(r'\n(?:[A-Z\' ])[A-ZÄÖÜß0-9-\: \'\,\.\(\)\&+]{2,}?(?:\n|\s{2}(?!-))', ' SEP ', row['texts'])  
                    # If there is a non-capitalized headline that is followed by - and not by smth like
                    # FRANKFURT - .
                    elif len([r.strip() for r in re.findall(r'\n(?:[A-Z\' ])[A-ZÄÖÜß0-9-\: \'\,\.\(\)\&+]{2,}?(?:\n|\s{2}(?!-))', row["texts"]) if r.strip() != '']) == 0 and \
                        len([r.strip() for r in re.findall(r'(?:^|(?<=\.\n{1}))[^\.]+?(?=\n[\s]*? - )', row['texts']) if r.strip() != '']) >= 1:
                        # Headlines that are followed by - , or FRANKFURT - .  
                        headlines = [[r.strip() for r in re.findall(r'(?<=\n{2})[^\.]+?(?=\n{1})', row['texts']) if r.strip() != ''][0]] + \
                            re.findall(r'(?:^|(?<=\.\n{1}))[^\.]+?(?=\n[\s]*?[A-ZÄÖÜa-zäöüß /]+ - )', row['texts'])                           
                    # Non-capitalized headlines contain period.
                    # This case only applies to articles in which the first paragraph
                    # is not the headline.
                    elif len(re.findall(r'(?:^\s*)FRANKFURT[\S\s]+?\n{2}', row['texts'])) > 0 and \
                        (len(word_par)-1 > len(re.findall(r'(?:^|(?<=\.\n{1}))[^\.]+?(?=\n[\s]*?[A-ZÄÖÜß][A-ZÄÖÜa-zäöüß /]+ - )', row['texts'])) or \
                         '.' in [r.strip() for r in re.findall(r'(?<=\n{2})[\S\s]+?(?=\n{1})', row['texts']) if r.strip() != ''][0]) and \
                        len([r.strip() for r in re.findall(r'\n(?:[A-Z\' ])[A-ZÄÖÜß0-9-\: \'\,\.\(\)\&+]{2,}?(?:\n|\s{2}(?!-))', row["texts"]) if r.strip() != '']) == 0:
                        # Includes headlines and beginnings of the articles
                        headlines = [r.strip() for r in re.findall(r'(?<=\n{2})[\S\s]+?(?=\n{1})', row['texts']) if r.strip() != '']
                        # Keep headline only (they don't contain words from word_par)
                        headlines = [h for h in headlines if all(w not in h for w in word_par)]                    
                    # The first headline is the one that starts from \n{2} and ends with \n{1}.
                    # This case only applies to articles in which the first paragraph
                    # is not the headline.
                    elif len([r.strip() for r in re.findall(r'(?<=\n{2})[^\.]+?(?=\n{1})', row['texts']) if r.strip() != '']) >= 1 and \
                        len(re.findall(r'(?:^\s*)FRANKFURT[\S\s]+?\n{2}', row['texts'])) > 0:
                        headlines = [[r.strip() for r in re.findall(r'(?<=\n{2})[^\.]+?(?=\n{1})', row['texts']) if r.strip() != ''][0]] + \
                        re.findall(r'(?:^|(?<=\.\n{1}))[^\.]+?(?=\n[\s]*?[A-ZÄÖÜß][A-ZÄÖÜa-zäöüß /]+ - )', row['texts'])
                    else:
                        headlines = re.findall(r'(?:^|(?<=\.\n{1}))[^\.]+?(?=\n[\s]*?[A-ZÄÖÜß][A-ZÄÖÜa-zäöüß /]+ - )', row['texts'])
                    headlines = [h.replace("\n", ' ').replace("\t", ' ').strip() for h in headlines]
                    
                    txt = row['texts']
                    txt = txt.strip().replace("\n", ' ').replace("\t", ' ')
                    
                    # Case with empty headlines
                    if change_split_pattern == True:
                        # Split text by 'SEP' tokens    
                        mult_art = [i.strip() for i in txt.split('SEP')][1:]
                    else:
                        # There is a special case where company names are used as headlines.
                        # As a consequence, the name of the company might be used 
                        # as a headline several times, and it might also appear in the text. 
                        # This leads to mistakes in splitting which we next correct.
                        mult_art = []
                        # Replace the first two headlines with 'SEP' 
                        for ind, headline in enumerate(headlines[:2]):
                            txt = txt.replace(headline, 'SEP', 1)
                        # Split text by 'SEP' tokens    
                        splitting = [i.strip() for i in txt.split('SEP')][1:]                         
                        # The first part is the first article
                        mult_art.append(splitting[0])
                        # The second part is the rest of the text
                        txt = splitting[1]
                        
                        # Use all the other headlines starting from the 3rd one
                        # to split the text.
                        for p in range(2,len(headlines)):
                            headline = headlines[p]
                            # Replace the headline with 'SEP'
                            txt = txt.replace(headline, 'SEP', 1)
                            # Split by 'SEP'
                            splitting = [i.strip() for i in txt.split('SEP')]
                            # The first part is the new article
                            mult_art.append(splitting[0])
                            # The second part is the rest of the text
                            txt = splitting[1]
                        # Add the last article to mult_art list
                        mult_art.append(txt)
                                                                              
                # If there is more than one capitalized title that starts from \n and ends with \n or \s{2}       
                elif len([r.strip() for r in re.findall(r'\n(?:[A-Z\' ])[A-ZÄÖÜß0-9-\: \'\,\.\(\)\&+]{2,}?(?:\n|\s{2}(?!-))', row["texts"]) if r.strip() != '']) > 1:
                        
                    # Titles of the corresponding articles
                    headlines = re.findall(r'\n(?:[A-Z\' ])[A-ZÄÖÜß0-9-\: \'\,\.\(\)\&+]{2,}?(?:\n|\s{2}(?!-))', row["texts"])
                    headlines = [h.strip().replace("\n", ' ') for h in headlines if h.strip() != '' ]
                    # Articles of the type ANALYSTEN-EINSTUFUNGEN sometimes include week summaries.
                    # Weekdays are not titles.
                    headlines = [h for h in headlines if h not in weekday]
                    
                    txt = row['texts']
                    txt = txt.strip().replace("\n", ' ').replace("\t", ' ')
                    
                    # Replace headline with 'SEP'
                    for ind, headline in enumerate(headlines):
                        txt = txt.replace(headline, 'SEP', 1)
                        headlines[ind] = ' '.join(headline.split())
                        
                    # Split text by 'SEP' tokens
                    mult_art = [i.strip() for i in txt.split('SEP')][1:]
                    
                # If there is more than one title that starts with \n{2} and ends with \n{2}    
                elif len([r.strip() for r in re.findall(r'(?:^|(?<=\n{2}))(?:[ ]{0,2})(?:[\'\"A-Za-zÄÖÜß:\-\(])[\S\s]{5,}?(?=\n{2})', row["texts"].strip()) if r.strip() != '']) > 1:
                    # Find the headlines and paragraphs separated by \n{2}
                    headlines = re.findall(r'(?:^|(?<=\n{2}))(?:[ ]{0,2})(?:[\'\"A-Za-zÄÖÜß:\-\(])[\S\s]{5,}?(?=\n{2})', row["texts"].strip())
                    headlines = [h.strip().replace("\n", ' ') for h in headlines if h.strip() != '' ]
                    
                    txt = row['texts']
                    txt = txt.strip().replace("\n", ' ').replace("\t", ' ')
                    
                    # Replace headline with 'SEP'
                    for ind, headline in enumerate(headlines):
                        txt = txt.replace(headline, 'SEP', 1)
                        headlines[ind] = ' '.join(headline.split())
                        
                    # Split text by 'SEP' tokens
                    mult_art = [i.strip() for i in txt.split('SEP')][1:]                   
                
                # If there is more than one title separated by two spaces
                elif len([r.strip() for r in re.findall(r'(?:^|(?<=\s{2}))[^.]{5,}?(?=\s{2})', row["texts"]) if r.strip() != '']) > 1:    
                    # Titles of the corresponding articles
                    headlines = re.findall(r'(?:^|(?<=\s{2}))[^.]{5,}?(?=\s{2})', row["texts"])
                    headlines = [h.strip().replace("\n", ' ') for h in headlines if h.strip() != '' ]
                    
                    txt = row['texts']
                    txt = txt.strip().replace("\n", ' ').replace("\t", ' ')
                    
                    # Replace headline with 'SEP'
                    for ind, headline in enumerate(headlines):
                        txt = txt.replace(headline, 'SEP', 1)
                        headlines[ind] = ' '.join(headline.split())
                        
                    # Split text by 'SEP' tokens
                    mult_art = [i.strip() for i in txt.split('SEP')][1:]
                else:
                    # Split by paragraphs
                    no_headline = True
                    txt = row['texts']
                    txt = txt.strip().replace("\n", ' ').replace("\t", ' ')
                    mult_art = re.findall(r'((?:^|(?:\s{2}))(?:[A-ZÄÖÜß:\-\(]).+?(?:\s{2}(?![A-Z][a-z])|$))', txt)
                    mult_art = [m.strip() for m in mult_art]
                                                   
            else:
                # If there is more than one capitalized title that starts from \n and ends with \s{2}
                if len([r.strip() for r in re.findall(r'\n(?:[A-Z\' ])[A-ZÄÖÜß0-9-\: \'\,\.\n]{5,}?\s{2}', row["texts"]) if r.strip() != '']) > 1:
                    
                    # Combine a capitalized title at the beginning of the text
                    # and titles separated by \n
                    headlines = re.findall(r'^[A-ZÄÖÜß0-9-\: \'\,\.\n%]{5,}?(?=\s{2})', row["texts"]) + \
                    re.findall(r'\n(?:[A-Z\' ])[A-ZÄÖÜß0-9-\: \'\,\.\n]{5,}?\s{2}', row["texts"])
                    headlines = [h.strip().replace("\n", ' ') for h in headlines if h.strip() != '' ]
                    
                    txt = row['texts']
                    txt = txt.strip().replace("\n", ' ').replace("\t", ' ')
                    
                    # Replace headline with 'SEP'
                    for ind, headline in enumerate(headlines):
                        txt = txt.replace(headline, 'SEP', 1)
                        headlines[ind] = ' '.join(headline.split())
                        
                    # Split text by 'SEP' tokens
                    mult_art = [i.strip() for i in txt.split('SEP')][1:]
                    
                # If there is more than one title that starts with \n{2} and ends with \n{2}    
                elif len([r.strip() for r in re.findall(r'(?:^|(?<=\n{2}))(?:[ ]{0,2})(?:[\'\"A-Za-zÄÖÜß:\-\(])[\S\s]{5,}?(?=\n{2})', row["texts"].strip()) if r.strip() != '']) > 1:
                    # Find the headlines and paragraphs separated by \n{2}
                    headlines = re.findall(r'(?:^|(?<=\n{2}))(?:[ ]{0,2})(?:[\'\"A-Za-zÄÖÜß:\-\(])[\S\s]{5,}?(?=\n{2})', row["texts"].strip())
                    headlines = [h.strip().replace("\n", ' ') for h in headlines if h.strip() != '' ]
                    
                    txt = row['texts']
                    txt = txt.strip().replace("\n", ' ').replace("\t", ' ')
                    
                    # Replace headline with 'SEP'
                    for ind, headline in enumerate(headlines):
                        txt = txt.replace(headline, 'SEP', 1)
                        headlines[ind] = ' '.join(headline.split())
                        
                    # Split text by 'SEP' tokens
                    mult_art = [i.strip() for i in txt.split('SEP')][1:]
                    
                # If there is more than one title that starts with \n{2} and ends with \n{2}
                # + there might be up to 5 spaces between \n{2} and the beginning of the paragraph
                # which makes it difficult to distinguish between paragraphs and headlines
                elif len([r.strip() for r in re.findall(r'(?:^|(?<=\n{2}))(?:[ ]{0,5})(?:[\'0-9A-ZÄÖÜß:\-\(])[\S\s]{5,}?(?=\n{2})', row["texts"].strip()) if r.strip() != '']) > 1:
                    # Find the headlines and paragraphs separated by \n{2}
                    headlines = re.findall(r'(?:^|(?<=\n{2}))(?:[ ]{0,5})(?:[\'0-9A-ZÄÖÜß:\-\(])[\S\s]{5,}?(?=\n{2})', row["texts"].strip())
                    # Capitalized words in the beginning of the paragraphs (not headlines)
                    word_par = re.findall(r'(?:\s{2,})[/ A-ZÄÖÜß-]{2,}(?= -)', row["texts"])
                    word_par = [w.strip() for w in word_par]
                    # Strings that start from capitalized words are not headlines
                    headlines = [h for h in headlines if all(w not in h for w in word_par)]
                    
                    # If not all headlines were found, try another pattern for the headline.
                    if len(headlines)<len(word_par):
                        headlines = re.findall(r'(?:^|(?<=\n{1}))[^\.\,]{5,}?(?=\n{2})', row["texts"].strip())
                        # Two more patterns for headlines if the previous pattern did not work out
                        if len(headlines)<len(word_par) and len(re.findall(r'((?<=\n{3})[\s]{0,5}[A-ZÄÖÜß/]+ - )', row["texts"].strip())) >= 1:
                            headlines = headlines + re.findall(r'((?<=\n{3})[\s]{0,5}[A-ZÄÖÜß/]+ - )', row["texts"].strip())
                        elif len(headlines)<len(word_par) and len(re.findall(r'(?:^|(?<=\n{2}))[^\.]{5,}?(?=\n{1})', row["texts"].strip())) >= 1:
                            headlines = re.findall(r'(?:^|(?<=\n{2}))[^\.]{5,}?(?=\n{1})', row["texts"].strip())
                    headlines = [h.strip().replace("\n", ' ') for h in headlines if h.strip() != '' ]
                     
                    txt = row['texts']
                    txt = txt.strip().replace("\n", ' ').replace("\t", ' ')
                    
                    if headlines != []:                                                   
                        # Replace headline with 'SEP'
                        for ind, headline in enumerate(headlines):
                            txt = txt.replace(headline, 'SEP', 1)
                            headlines[ind] = ' '.join(headline.split())
                            
                        # Split text by 'SEP' tokens
                        mult_art = [i.strip() for i in txt.split('SEP')][1:]
                    else:                                                                      
                        # Split by paragraphs
                        no_headline = True
                        mult_art = re.findall(r'((?:^|(?:\s{2}))(?:[A-ZÄÖÜß:\-\(]).+?(?:\s{2}|$))', txt)
                        mult_art = [m.strip() for m in mult_art]            
                                       
                # If there is more than one capitalized title that starts from \n\s and ends with \n\s
                elif len([r.strip() for r in re.findall(r'\n\s(?:[A-Z\' ])[A-ZÄÖÜß0-9-\: \'\,\.\n ]{5,}?\n\s', row["texts"]) if r.strip() != '']) > 1:
                    
                    # Combine a capitalized title at the beginning of the text
                    # and titles separated by \n\s
                    headlines = re.findall(r'^[A-ZÄÖÜß0-9-\: \'\,\.\n%]{5,}?(?=\s{2})', row["texts"]) + \
                    re.findall(r'\n\s(?:[A-Z\' ])[A-ZÄÖÜß0-9-\: \'\,\.\n ]{5,}?\n\s', row["texts"])
                    headlines = [h.strip().replace("\n", ' ') for h in headlines if h.strip() != '' ]
                    
                    txt = row['texts']
                    txt = txt.strip().replace("\n", ' ').replace("\t", ' ')
                    
                    # Replace headline with 'SEP'
                    for ind, headline in enumerate(headlines):
                        txt = txt.replace(headline, 'SEP', 1)
                        headlines[ind] = ' '.join(headline.split())
                        
                    # Split text by 'SEP' tokens
                    mult_art = [i.strip() for i in txt.split('SEP')][1:]     
                              
                # If there is more than one title separated by two spaces
                elif len([r.strip() for r in re.findall(r'(?:^|(?<=\s{2}))[^.\n]{5,}?(?=\s{2})', row["texts"]) if r.strip() != '']) > 1:    
                    # Titles of the corresponding articles
                    headlines = re.findall(r'(?:^|(?<=\s{2}))[^.\n]{5,}?(?=\s{2}(?!\-))', row["texts"] )
                    headlines = [h.strip() for h in headlines if h.strip() != '' ]
                    
                    paragraphs = re.findall(r'((?:^|(?:\s{2}))(?:[\"A-ZÄÖÜß:\-\(]).+?(?:\s{2}|$))', row["texts"].strip().replace("\n", ' ').replace("\t", ' '))
                                         
                    # Split articles based on paragraphs and the occurence of fully 
                    # capitalized words
                    mult_art = re.findall(r'(?:\s{2,})[/A-ZÄÖÜß:-]{2,}(?:\s+[\x96A-ZÄÖÜß:\-]+)+[\S\s]{30,}?(?:\s{2}|$)', row["texts"])
                    
                    # If the number of headlines is less than the number of paragraph tags
                    # and larger than the number of actual paragraphs
                    if len(headlines) < len(paragraphs) and len(headlines) > len(mult_art):
                        # This pattern allows for \n and period in the headline
                        # and makes sure that paragraphs are not included in the headlines
                        headlines = re.findall(r'(?:^|(?<=\n{2}(?![ /])))[\S\s]{5,}?(?=(?<!\.)\n{2}(?![\-\n]))', row["texts"]) 
                        headlines = [h.strip() for h in headlines if h.strip() != '' ]
                        
                    # If headlines include the first capital words from the paragraphs
                    if len(paragraphs) == len(headlines):
                        capital_words1 = [w.strip() for w in capital_words1]
                        # Exclude capital words from the paragraphs
                        headlines = [h for h in headlines if all(w not in h for w in capital_words1)] 
                
                    # Pre-process the texts
                    for ind, m in enumerate(mult_art):
                        m = m.strip() # strip whitespace on both sides
                        m = m.replace("\n", ' ') # replace line break (new line character) with space 
                        m = m.replace("\t", ' ') # replace tab with space
                        m = ' '.join(m.split()) # make sure that there are no extra white spaces
                        mult_art[ind] = m
                        
                # If there is more than one title that starts with \n and ends with \s{2}      
                elif len([r.strip() for r in re.findall(r'(?:^|(?<=\n))[^.\n]{5,}?(?=\s{2})', row["texts"]) if r.strip() != '']) > 1:
                    # Titles of the corresponding articles
                    headlines = re.findall(r'(?:^|(?<=\n))[^.\n]{5,}?(?=\s{2})', row["texts"])
                    headlines = [h.strip().replace("\n", ' ') for h in headlines if h.strip() != '' ]
                    
                    txt = row['texts']
                    txt = txt.strip().replace("\n", ' ').replace("\t", ' ')
                    
                    # Replace headline with 'SEP'
                    for ind, headline in enumerate(headlines):
                        txt = txt.replace(headline, 'SEP', 1)
                        headlines[ind] = ' '.join(headline.split())
                        
                    # Split text by 'SEP' tokens
                    mult_art = [i.strip() for i in txt.split('SEP')][1:]
                    
                # If there is more than one capitalized title that starts from \n and ends with \n
                elif len([r.strip() for r in re.findall(r'\n(?:[A-Z\' ])[A-ZÄÖÜß0-9-\: \'\,\.\n]{5,}?\n', row["texts"]) if r.strip() != '']) > 1:
                    
                    # Combine a capitalized title at the beginning of the text
                    # and titles separated by \n
                    headlines = re.findall(r'^[A-ZÄÖÜß0-9-\: \'\,\.\n%]{5,}?(?=\n)', row["texts"]) + \
                    re.findall(r'\n(?:[A-Z\' ])[A-ZÄÖÜß0-9-\: \'\,\.\n]{5,}?\n', row["texts"])
                    headlines = [h.strip().replace("\n", ' ') for h in headlines if h.strip() != '' ]
                    
                    txt = row['texts']
                    txt = txt.strip().replace("\n", ' ').replace("\t", ' ')
                    
                    # Replace headline with 'SEP'
                    for ind, headline in enumerate(headlines):
                        txt = txt.replace(headline, 'SEP', 1)
                        headlines[ind] = ' '.join(headline.split())
                        
                    # Split text by 'SEP' tokens
                    mult_art = [i.strip() for i in txt.split('SEP')][1:]
                                
                else:
                    # Split by paragraphs
                    no_headline = True
                    txt = row['texts']
                    txt = txt.strip().replace("\n", ' ').replace("\t", ' ')
                    mult_art = re.findall(r'((?:^|(?:\s{2}))(?:[A-ZÄÖÜß:\-\(]).+?(?:\s{2}(?!\-)|$))', txt)
                    mult_art = [m.strip() for m in mult_art]                    
            
            if no_headline == False:
                # Combine headlines and texts into articles
                mult_art = [headline + '. ' + art if headline != '' else art for headline, art in zip(headlines, mult_art)]
            
        # The second indication for multiple articles is the occurence of 
        # multiple dpa references. 
        else:            
            # Search for dpa references
            dpa_ref = re.findall(r'\(dpa.*?\)', row["texts"])
            change_split_pattern = False
                        
            # If there is a dpa reference in the article
            if len(dpa_ref) >= 1:
                
                txt = row['texts']
                txt = txt.strip().replace("\n", ' ').replace("\t", ' ')
                if len(re.findall(r'\./\s', txt)) > 1:
                    # Split articles based on a different pattern: each article ends with './'
                    mult_art = re.findall(r'((?:^|(?:\s{2}))(?:[A-ZÄÖÜß:\-]).+?(?:\./\s{2}|$))', txt)
                else:
                    # Split articles based on paragraphs
                    mult_art = re.findall(r'((?:^|(?:\s{2}))(?:[\'A-ZÄÖÜß0-9:\-\(]).+?(?:\s{2}(?!\-|<|[a-z]| [a-z])|$))', txt)
                    
                # The articles that contain 'Kurznachrichten/Wirtschaft' should be
                # treated differently. The first title should be deleted,
                # and if the second title is present, it should be used to separate
                # the text into smaller articles.
                title1 = ''
                if 'Kurznachrichten/Wirtschaft' in row["texts"]:
                    # Find the title of the first article
                    title1 = re.findall(r'^[\S\s]+?(?=[A-ZÄÖÜß][a-z]+(?:/[A-ZÄÖÜß][a-z]+){0,1}[ ]\(dpa.+?)', row["texts"])[0]
                    # Remove this title
                    row["texts"] = row["texts"].replace(title1, '')
                    # Try to find the second title
                    title2 = re.findall(r'(?<=\.\n|\.\s)(?:[A-ZÄÖÜß\n])[^.]+?(?:[0-9]\.){0,1}[^.]+?[=]{0,1}(?:\n{2})', row["texts"])
                    if title2 != []:
                        title2 = title2[0]
                        headlines = ['', title2]
                        # Use the second title to split the text into articles
                        mult_art = row["texts"].split(title2)
                        # Combine headlines and texts into articles
                        mult_art = [headline + ' ' + art for headline, art in zip(headlines, mult_art)]  
                    else:
                        mult_art = [row["texts"].strip().replace("\n", ' ').replace("\t", ' ')]
                        
                headlines_attempt = re.findall(r'(?:^|(?<=\.\n{1}\s)|(?<=\.\n{2})|(?<=»\n{1}\s))[^\.]+?(?=\n[\s]*?[A-ZÄÖÜß][A-ZÄÖÜa-zäöüß /]+ - )', row["texts"])
                # Exclude headlines that contain '(dpa)' to understand if there are headlines
                # that contain smth like '\nBerlin - '.
                headlines_attempt = [h for h in headlines_attempt if '(dpa)' not in h]
                
                # If there is a headline that starts from .\n and ends with =
                if (len(re.findall(r'(?:^[ ]*|(?<=\.\n)[ ]*)(?:[A-ZÄÖÜßa-z\n])[^.]+?(?:=)', row['texts'])) > 0) and ('Kurznachrichten/Wirtschaft' not in txt_par) and \
                    len(mult_art) != 1 and (len(mult_art) > len(dpa_ref)):
                    headlines = re.findall(r'(?:^[ ]*|(?<=\.\n)[ ]*)(?:[A-ZÄÖÜßa-z\n])[^.]+?(?:=)', row['texts'])
                    headlines = [h.replace("\n", ' ').replace("\t", ' ').replace("dpa ak", " ").strip() for h in headlines]
                    
                    # If there are not only headlines ending with =, but also
                    # headlines preceding '\nBerlin (dpa)'
                    if len(re.findall(r'(?:^|(?<=\.\s{2})|(?<=\.»\s{2})|(?<=(?<!dpa)\)\s{2})|(?<=Maschinenbauers\s{2})|(?<=\!\»\s{2}))[\S\s]+?(?:\(dpa.+?)', txt)) > len(headlines):
                        headlines = re.findall(r'(?:^|(?<=\.\s{2})|(?<=\.»\s{2})|(?<=(?<!dpa)\)\s{2})|(?<=Maschinenbauers\s{2})|(?<=Serbenrepublik\.)|(?<=\!\»\s{2}))[\S\s]+?(?:\(dpa.+?)', txt)
                        # The case where headlines can be identified using the following pattern:
                        # '.\n|.\s (PARAGRAPH){0,1} ... (PARAGRAPH){0,1]   Wiesbaden (dpa/vwd)'.
                        if len(headlines)<len(dpa_ref):
                            headlines = re.findall(r'(?:^|(?<=\.\n{1})|(?<=\.\s{1}))(?:(?!\.\n{1}|\. PARAGRAPH)[\s\S])+?(?:PARAGRAPH){0,1}(?:\s*\n*\s*[A-ZÄÖÜß][A-ZÄÖÜa-zäöüßú\.\-\' /\(\)]+[ ]{0,1}[-]{0,1}\(dpa.+?)', txt_par)
                            headlines = [h for h in headlines if "PARAGRAPH" in h]
                            headlines = [h.replace("\n", ' ').replace(" PARAGRAPH ", ' ').replace("PARAGRAPH ", ' ') for h in headlines]
                            
                    # A pattern to find the headlines following paragraphs without a period 
                    # at the end.
                    if len(headlines) < len(mult_art)/2 or \
                    len(headlines) < len(re.findall(r'(?:^|(?<=(?<!=\s{2})\s{2}))[^\( ][\S\s]+?(?=\(dpa(?!\-Grafik).+?)', txt)):
                        headlines = re.findall(r'(?:^|(?<=(?<!=\s{2})\s{2}))[^\( ][\S\s]+?(?=\(dpa(?!\-Grafik).+?)', txt)
                    
                    # The case where headlines can be identified using the tag PARAGRAPH.
                    if len(headlines)<len(dpa_ref):
                        headlines = re.findall(r'(?:^|(?<=\.\n{1})|(?<=\.\s{1})|(?<=\.\)\n{1}))(?:(?!\.\n{1}|\. PARAGRAPH|\.\)\n{1})[\s\S])+?(?:PARAGRAPH){0,1}(?:\s*\n*\s*[A-ZÄÖÜß][A-ZÄÖÜa-zäöüßú\.\-\' /\(\)]+[ ]{0,1}[-]{0,1}\(dpa.+?)', txt_par)
                        headlines = [h for h in headlines if "PARAGRAPH" in h]
                        headlines = [h.replace("\n", ' ').replace(" PARAGRAPH ", ' ').replace("PARAGRAPH ", ' ') for h in headlines]
                    
                    headlines = [h.replace("\n", ' ').replace("\t", ' ').replace("dpa ak", " ").strip() for h in headlines]
                    
                    # Replace headline with 'SEP'
                    for ind, headline in enumerate(headlines):
                        txt = txt.replace(headline, 'SEP', 1)
                        # Capitalize the first letter of the first word if it is in lowercase
                        if headline.split()[0].islower():
                           headline = headline.split()[0].capitalize() + headline.replace(headline.split()[0], '')
                        headlines[ind] = ' '.join(headline.split())
                    
                    # Split text by 'SEP' tokens
                    mult_art = [i.strip() for i in txt.split('SEP')]
                    # Exclude empty articles
                    mult_art = [art for art in mult_art if art != '']
                    
                    # If the first article does not have a headline
                    if len(headlines) < len(mult_art):
                        headlines = [''] + headlines
                        
                    # Combine headlines and texts into articles
                    mult_art = [headline + ' ' + art for headline, art in zip(headlines, mult_art)]
                    
                # The case where the number of paragraphs is larger than 
                # the number of DPA references, and there are paragraphs that 
                # start from smth like '\nBerlin - ' (and not '\nBerlin (dpa)')
                elif len(mult_art) > len(dpa_ref) and \
                    len([r.strip() for r in headlines_attempt if r.strip() != '']) > 0 and \
                        dpa_ref != ['(dpa-AFX)']:
                    
                    # Headlines preceding '\nBerlin - ' and '\nBerlin (dpa)'
                    headlines = re.findall(r'(?:^|(?<=\.\n{1}\s)|(?<=\.\n{2})|(?<=»\n{1}\s)|(?<=wolle\.\n{1})|(?<=\.\s{4})|(?<=\.\s{2})|(?<=\.»\n)|(?<=\.\n))[^\n]+?(?=\n[\s]*?[A-ZÄÖÜß][A-ZÄÖÜa-zäöüß /]+ - |\n[\s]*?[A-ZÄÖÜß][A-ZÄÖÜa-zäöüß\-\' /\(\)]+[ ]{0,1}[-]{0,1}\(dpa.+?|\s{4}.+?\(dpa.+?)', row['texts'].strip())
                    headlines = [h for h in headlines if h.strip()!='']
                    # Identify headlines using the 'PARAGRAPH' tag
                    headlines_par = re.findall(r'(?:^|(?<=\.\n{1})|(?<=\.\s{1})|(?<=\.\)\n{1}))(?:(?!\.\n{1}|\. PARAGRAPH|\.\)\n{1})[\s\S])+?(?:PARAGRAPH){0,1}(?:\s*\n*\s*[A-ZÄÖÜß][A-ZÄÖÜa-zäöüßú\.\-\' /\(\)]+[ ]{0,1}[-]{0,1}\(dpa.+?|PARAGRAPH[\s]*?[A-ZÄÖÜß][A-ZÄÖÜa-zäöüß /]+ -)', txt_par)
                    headlines_try = re.findall(r'(?:^|(?<=\.\n{1}\s)|(?<=\.\n{2})|(?<=»\n{1}\s)|(?<=\.\s{4})|(?<=\.\s{2})|(?<=\.»\n)|(?<=\.\n)|(?<=\.\s{1}))[^\.]+?(?=\n[\s]*?[A-ZÄÖÜß][A-ZÄÖÜa-zäöüß /]+ - [A-ZÄÖÜ]|\n[\s]*?[A-ZÄÖÜß][A-ZÄÖÜa-zäöüß\-\' /\(\)]+ [-]{0,1}\(dpa.+?|\s{4}.+?\(dpa.+?)', row['texts'])
                    headlines_try = [h for h in headlines_try if h.strip()!='']
                    # A pattern to find the headlines that might include \n,
                    # but do not include \.
                    if len(headlines) < len(mult_art)/2 or \
                        (len(headlines) < len(headlines_try) and len(headlines) < len(headlines_par) and len(re.findall('PARAGRAPH', txt_par))>1) or \
                            (len(headlines) < len(headlines_try) and len(re.findall('PARAGRAPH', txt_par))==1):
                        headlines = re.findall(r'(?:^|(?<=\.\n{1}\s)|(?<=\.\n{2})|(?<=»\n{1}\s)|(?<=\.\s{4})|(?<=\.\s{2})|(?<=\.»\n)|(?<=\.\n)|(?<=\.\s{1}))[^\.]+?(?=\n[\s]*?[A-ZÄÖÜß][A-ZÄÖÜa-zäöüß /]+ - [A-ZÄÖÜ]|\n[\s]*?[A-ZÄÖÜß][A-ZÄÖÜa-zäöüß\-\' /\(\)]+ [-]{0,1}\(dpa.+?|\s{4}.+?\(dpa.+?)', row['texts'])                
                        headlines = [h for h in headlines if h.strip()!='']
                        
                    # If there are empty headlines
                    # Use the 'PARAGRAPH' tag to make sure that the first headline
                    # pattern has failed.
                    elif (len(re.findall(r'(?<=\.\n{2})\s{1,}.+?\(dpa\) - ', row['texts'])) > 0 and len(headlines) != len(headlines_par) and len(re.findall('PARAGRAPH', txt_par))>1) or \
                        (len(re.findall(r'(?<=\.\n{2})\s{1,}.+?\(dpa\) - ', row['texts'])) > 0 and len(re.findall('PARAGRAPH', txt_par))==1):
                        change_split_pattern = True
                        headlines =  re.findall(r'(?:^|(?<=\.\n{2})).+?(?=\n{0,2}\s*[A-ZÄÖÜß][A-ZÄÖÜa-zäöüß\-\' /\(\)]+[ ]{0,1}[-]{0,1}\(dpa.+?|\n{0,2}\s*[A-ZÄÖÜß][A-ZÄÖÜa-zäöüß /]+ - )', row["texts"].strip())
                        row['texts'] = re.sub(r'(?:^|(?<=\.\n{2})).+?(?=\n{0,2}\s*[A-ZÄÖÜß][A-ZÄÖÜa-zäöüß\-\' /\(\)]+[ ]{0,1}[-]{0,1}\(dpa.+?|\n{0,2}\s*[A-ZÄÖÜß][A-ZÄÖÜa-zäöüß /]+ - )', ' SEP ', row['texts'].strip())  
                        txt = row['texts']
                        txt = txt.strip().replace("\n", ' ').replace("\t", ' ')
                        
                    headlines = [h.replace("\n", ' ').replace("\t", ' ').strip() for h in headlines]
                    
                    # Case with empty headlines
                    if change_split_pattern == True:
                        # Split text by 'SEP' tokens    
                        mult_art = [i.strip() for i in txt.split('SEP')][1:]
                    else:                                                            
                        # Replace headline with 'SEP'
                        for ind, headline in enumerate(headlines):
                            txt = txt.replace(headline, 'SEP', 1)
                            headlines[ind] = ' '.join(headline.split())
                        
                        # Split text by 'SEP' tokens
                        mult_art = [i.strip() for i in txt.split('SEP')][1:]
                    
                    # Combine headlines and texts into articles
                    mult_art = [headline + ' ' + art for headline, art in zip(headlines, mult_art)]                
                                       
                # The case where the number of paragraphs is larger than 
                # the number of DPA references requires a different pattern
                # for splitting the articles
                elif len(mult_art) > len(dpa_ref) and dpa_ref != ['(dpa-AFX)']:
                                     
                    # Search for headline preceding the DPA references
                    headlines = re.findall(r'(?:^|(?<=\.\s{2})|(?<=\.»\s{2})|(?<=(?<!dpa)\)\s{2}(?![a-zäöüß]))|(?<=Maschinenbauers\s{2})|(?<=\?\s{2}))[\S\s]+?(?=\(dpa(?!\-Grafik).+?)', txt)
                    
                    # A pattern to find the headlines following paragraphs without a period 
                    # at the end.
                    headlines_try = re.findall(r'(?:^|(?<=\s{2}))[^\(][\S\s]+?(?=\(dpa(?!\-Grafik).+?)', txt)
                    # Headlines that consist of one word are cities preceding the dpa reference;
                    # a headline consisting of 40 words and more indicates a mistake in splitting.
                    headlines_try = [h for h in headlines_try if len(h.split())>1 and len(h.split())<40]
                    if (len(headlines) < len(mult_art)/2 and len(headlines) < len(dpa_ref)) or \
                        len(headlines) < len(headlines_try):
                        headlines = re.findall(r'(?:^|(?<=\s{2}))[^\(][\S\s]+?(?=\(dpa(?!\-Grafik).+?)', txt)
                        headlines = [h for h in headlines if len(h.split())>1 and len(h.split())<40]
                                                                    
                    if len(headlines) <= 1:
                        # Headlines that start from .\s and end with dpa reference
                        headlines = re.findall(r'(?:^|(?<=\.\s{1}))[^\.]+?(?=\(dpa.+?)', txt)
                    
                    # If there are headlines that start from .\s and end with the dpa reference
                    # (no period inside a headline is allowed).
                    if len(headlines) < len(re.findall(r'(?:^|(?<=\.\s{1})|(?<=\?\s{1})|(?<=\.»\s{1}))[^\.]+?(?=\(dpa(?!\)\.|\) [a-z]).+?)', txt)):
                        headlines = re.findall(r'(?:^|(?<=\.\s{1})|(?<=\?\s{1})|(?<=\.»\s{1}))[^\.]+?(?=\(dpa(?!\)\.|\) [a-z]).+?)', txt)
                    
                    # If one of the headlines starts from .\s and another one contains a period.
                    if len(headlines) < len(re.findall(r'(?:^|(?<=\.\n)|(?<=\?\n)|(?<=\.»\n)|(?<=\.\s{2}))[^\n]+?(?:\n.+?(?<!Agentur )\(dpa.+?|\s{4}.+?(?<!Agentur )\(dpa.+?)', row['texts'].strip())):
                        headlines = re.findall(r'(?:^|(?<=\.\n)|(?<=\?\n)|(?<=\.»\n)|(?<=\.\s{2}))[^\n]+?(?:\n.+?(?<!Agentur )\(dpa.+?|\s{4}.+?(?<!Agentur )\(dpa.+?)', row['texts'].strip())
                        headlines = [h.replace("\n", ' ').replace("\t", ' ').strip() for h in headlines]
                    
                    # A headline consisting of 20 words and more indicates a mistake in splitting,
                    # use the 'PARAGRAPH' tag to identify the headlines.
                    headlines_length = [h for h in headlines if len(h.split())<20]
                    if len(headlines_length)<len(headlines) and len(re.findall('PARAGRAPH', txt_par))>1:
                        headlines = re.findall(r'(?:^|(?<=\.\n{1})|(?<=\.\s{1})|(?<=\.\)\n{1}))(?:(?!\.\n{1}|\. PARAGRAPH|\.\)\n{1})[\s\S])+?(?:PARAGRAPH){0,1}(?:\s*\n*\s*[A-ZÄÖÜß][A-ZÄÖÜa-zäöüßú\.\-\' /\(\)]+[ ]{0,1}[-]{0,1}\(dpa.+?)', txt_par)
                        headlines = [h.replace("\n", ' ').replace(" PARAGRAPH ", ' ').replace("PARAGRAPH ", ' ').strip() for h in headlines]
                        # If one of the texts does not end with the punctuation mark,
                        # another pattern is required to identify the headlines.
                        if len([h for h in headlines if len(h.split())<30])<len(headlines):
                            headlines = re.findall(r'(?:PARAGRAPH|(?<=\.\n\s))(?:(?!\.\n{1}|\. PARAGRAPH|\.\)\n{1})[\s\S])+?(?:PARAGRAPH){0,1}(?:\s*\n*\s*[A-ZÄÖÜß][A-ZÄÖÜa-zäöüßú\.\-\' /\(\)]+[ ]{0,1}[-]{0,1}\(dpa.+?)', txt_par)
                            headlines = [h.replace("\n", ' ').replace(" PARAGRAPH ", ' ').replace("PARAGRAPH ", ' ').strip() for h in headlines]
                    
                    # A headline consisting of 20 words and more indicates a mistake in splitting,
                    # try to use the pattern where headlines start from .\s and end with the dpa reference
                    # (no period inside a headline is allowed).
                    if len(headlines_length)<len(headlines) and len(re.findall('PARAGRAPH', txt_par))==1:
                        headlines =re.findall(r'(?:^|(?<=\.\s{1})|(?<=\?\s{1})|(?<=\.»\s{1}))[^\.]+?(?=\(dpa(?!\)\.|\) [a-z]).+?)', txt)
                        # If the previous pattern did not work, try to find headlines
                        # separated by four spaces.
                        if len(headlines)<len(re.findall(r'(?:^|(?<=\.\s{4})|(?<=\.»\s{4}))[\S\s]+?(?=\s{4})', txt)):
                            headlines = re.findall(r'(?:^|(?<=\.\s{4})|(?<=\.»\s{4}))[\S\s]+?(?=\s{4})', txt)
                        # A headline might start from \.\n{4} and end with \n{2}.
                        if len(headlines)<len(re.findall(r'(?:^|(?<=\.\n{4}))[^\n]+?(?:\n{2})', row['texts'].strip())):
                            headlines = re.findall(r'(?:^|(?<=\.\n{4}))[^\n]+?(?:\n{2})', row['texts'].strip())
                            headlines = [h.replace("\n", ' ').replace("\t", ' ').strip() for h in headlines]
                        # A headline might start from \.\n{2} and end with \n{2}.
                        if len(headlines)<len(re.findall(r'(?:^|(?<=\.\n{2})|(?<=\. \n{2})|(?<=\.» \n{2}))[^\n]+?(?:\n{2}.+?\(dpa.+?)', row['texts'].strip())):
                            headlines = re.findall(r'(?:^|(?<=\.\n{2})|(?<=\. \n{2})|(?<=\.» \n{2}))[^\n]+?(?:\n{2}.+?\(dpa.+?)', row['texts'].strip())
                            headlines = [h.replace("\n", ' ').replace("\t", ' ').strip() for h in headlines]
                                                   
                    # Replace headline with 'SEP'
                    for ind, headline in enumerate(headlines):
                        txt = txt.replace(headline, 'SEP', 1)
                        headlines[ind] = ' '.join(headline.split())
                    
                    # Split text by 'SEP' tokens
                    mult_art = [i.strip() for i in txt.split('SEP')][1:]
                    
                    # Combine headlines and texts into articles
                    mult_art = [headline + ' ' + art for headline, art in zip(headlines, mult_art)]
                # Another regular expression is required to split an article 
                # into headlines and paragraphs
                elif (mult_art == [] or len(mult_art) == 1 or len(mult_art)<=len(dpa_ref)) and ('Kurznachrichten/Wirtschaft' not in txt_par):
                    # Special pattern for texts with one dpa reference
                    if len(dpa_ref) == 1 and title1 == '':
                        headlines = re.findall(r'(?:^)[\S\s]+?(?=\(dpa.+?)', txt)
                    else:
                        # Search for headline preceding the DPA references
                        headlines = re.findall(r'(?:^|(?<=\.\s{1})|(?<=\?\s{1})|(?<=\.»\s{1})|(?<=\.\)\s{1}))[^\.]+?(?:\(dpa.+?)', txt)
                        # Some headlines contain a period                        
                        if len(headlines) < len(dpa_ref):
                            headlines = re.findall(r'(?:^|(?<=\.\n)|(?<=\?\n)|(?<=\.»\n)|(?<=\.\s{2}))[^\n]+?(?:\n.+?\(dpa.+?|\s{4}.+?\(dpa.+?)', row['texts'].strip())    
                            # If the previous pattern did not help, then use
                            # the version of the text with the 'PARAGRAPH' tag.
                            # Search for smth like 'PARAGRAPH headline PARAGRAPH Bonn (dpa)' 
                            if len(headlines) < len(dpa_ref):
                                headlines = re.findall(r'(?<=PARAGRAPH)[\S\s]+?(?:PARAGRAPH){0,1}(?:\s*\n*\s*[A-ZÄÖÜß][A-ZÄÖÜa-zäöüßúè\.\-\' /]+[ ]{0,1}[-]{0,1}\(dpa.+?)', txt_par) 
                                headlines = [h.replace("\n", ' ').replace(" PARAGRAPH ", ' ').replace("PARAGRAPH ", ' ') for h in headlines]
                                # If all the previous patterns did not work, allow for
                                # some words with the period in the headline: '.com'
                                if len(headlines) < len(dpa_ref):
                                    headlines = re.findall(r'(?:^|(?<=\.\s{1})|(?<=\?\s{1})|(?<=\.»\s{1})|(?<=\.\s{2}))[^\.]+?(?:\.com)*[^\.]+?(?:\(dpa.+?)', txt)
                                    # In some cases, to identify the first headline, we only
                                    # need to remove the first \n and keep the spaces.
                                    if len(headlines) < len(dpa_ref):
                                        headlines = re.findall(r'(?:^|(?<=\.\n)|(?<=\?\n)|(?<=\.»\n)|(?<=\.\s{2}))[^\n]+?(?:\n.+?\(dpa.+?|\s{4}.+?\(dpa.+?)', row['texts'].replace('\n', ' ', 1))
                                        # If all the previous patterns did not work,
                                        # try to find headlines that start from \.\s{2} or \?»\s{2}.
                                        # A headline might contain a period.
                                        if len(headlines) < len(dpa_ref):
                                            headlines =  re.findall(r'(?:^|(?<=\.\s{2})|(?<=\?»\s{2}))[\s\S]+?(?:\(dpa.+?)', txt) 
                                            # Only if all the previous patterns did not work,
                                            # try to find the headlines that start from \s{2}.
                                            if len(headlines) < len(dpa_ref):
                                                headlines = re.findall(r'(?:^|(?<=\.\s{2})|(?<=\?»\s{2})|(?<=\s{2}))[A-ZÄÖÜ][\s\S]+?(?:\(dpa.+?)', txt)
                        # A headline that conists of two words (e.g., 'Berlin (dpa)') might indicate
                        # a mistake in splitting. Use a 'PARAGRAPH' tag to identify the headlines.
                        if len(headlines) == len(dpa_ref) and len([h for h in headlines if len(h.split()) == 2])>0 and \
                            len(re.findall(r'(?<=PARAGRAPH)[\S\s]+?(?:PARAGRAPH){0,1}(?:\s*\n*\s*[A-ZÄÖÜß][A-ZÄÖÜa-zäöüßúè\.\-\' /]+[ ]{0,1}[-]{0,1}\(dpa.+?)', txt_par)) == len(headlines):
                            headlines = re.findall(r'(?<=PARAGRAPH)[\S\s]+?(?:PARAGRAPH){0,1}(?:\s*\n*\s*[A-ZÄÖÜß][A-ZÄÖÜa-zäöüßúè\.\-\' /]+[ ]{0,1}[-]{0,1}\(dpa.+?)', txt_par)
                            headlines = [h.replace("\n", ' ').replace(" PARAGRAPH ", ' ').replace("PARAGRAPH ", ' ') for h in headlines]
                        # If a text contains more than one dpa-reference, make sure that
                        # (dpa) is not preceded by Deutsche Presse-Agentur                 
                        if len(headlines) == len(dpa_ref) and len(re.findall(r'(?<=Agentur\n|Agentur\s)(?:\(dpa.*?\))', row['texts']))>0:
                            headlines = re.findall(r'(?:^|(?<=\.\s{1})|(?<=\?\s{1})|(?<=\.»\s{1})|(?<=\.\)\s{1}))[^\.]+?(?:(?<!Agentur )\(dpa.+?)', txt)
                        # A headline consisting of 20 words and more indicates a mistake in splitting,
                        # try a pattern where a headline starts from \n{2} and ends
                        # with \n{2}.
                        headlines_length = [h for h in headlines if len(h.split())<20] 
                        if len(headlines_length)<len(headlines) and \
                            len(re.findall(r'(?:^|(?<=\.\n{2})|(?<=\. \n{2})|(?<=\.» \n{2})|(?<=\n{2}))[^\n]+?(?:\n{2}.+?\(dpa.+?)',row['texts'].strip())) == len(dpa_ref):
                            headlines = re.findall(r'(?:^|(?<=\.\n{2})|(?<=\. \n{2})|(?<=\.» \n{2})|(?<=\n{2}))[^\n]+?(?:\n{2}.+?\(dpa.+?)', row['texts'].strip())                        
                        # If some of the headlines contain a period,
                        # use the 'PARAGRAPH' tag to identify the headlines.
                        if len(re.findall(r'(?<=PARAGRAPH)[\S\s]+?(?:PARAGRAPH){0,1}(?:\s*\n*\s*[A-ZÄÖÜß][A-ZÄÖÜa-zäöüßúè\.\-\' /]+[ ]{0,1}[-]{0,1}\(dpa.+?)', txt_par)) == len(headlines):
                            headlines = re.findall(r'(?<=PARAGRAPH)[\S\s]+?(?:PARAGRAPH){0,1}(?:\s*\n*\s*[A-ZÄÖÜß][A-ZÄÖÜa-zäöüßúè\.\-\' /]+[ ]{0,1}[-]{0,1}\(dpa.+?)', txt_par) 
                            headlines = [h.replace("\n", ' ').replace(" PARAGRAPH ", ' ').replace("PARAGRAPH ", ' ') for h in headlines]
                        headlines = [h.replace("\n", ' ').replace("\t", ' ').strip() for h in headlines]
                            
                    if headlines != []:                       
                        # Replace headline with 'SEP'
                        for ind, headline in enumerate(headlines):                            
                            txt = txt.replace(headline, 'SEPARATE', 1)
                            headlines[ind] = ' '.join(headline.split())
                            
                        # Split text by 'SEP' tokens
                        mult_art = [i.strip() for i in txt.split('SEPARATE')][1:] 
                    else:
                        headlines = ['']
                                        
                    # Combine headlines and texts into articles
                    mult_art = [headline + ' ' + art for headline, art in zip(headlines, mult_art)]                                    
                else:
                    mult_art = [m.replace("\n", ' ').replace("\t", ' ').strip() for m in mult_art]
            
            # If there are articles with the headlines that start from \.\n{1} and end with smth like '\nBerlin - '
            elif len([r.strip() for r in re.findall(r'(?:^|(?<=\.\n{1}))[^\.]+?(?=\n[\s]*?[A-ZÄÖÜß][A-ZÄÖÜa-zäöüß /\-]+ - )', row["texts"]) if r.strip() != '']) > 0:
                headlines = re.findall(r'(?:^|(?<=\.\n{1}))[^\.]+?(?=\n[\s]*?[A-ZÄÖÜß][A-ZÄÖÜa-zäöüß /\-]+ - )', row['texts'])
                headlines = [h.replace("\n", ' ').replace("\t", ' ').strip() for h in headlines]
                
                txt = row['texts']
                txt = txt.strip().replace("\n", ' ').replace("\t", ' ')
                
                # Replace headline with 'SEP'
                for ind, headline in enumerate(headlines):
                    txt = txt.replace(headline, 'SEP', 1)
                
                # Split text by 'SEP' tokens
                mult_art = [i.strip() for i in txt.split('SEP')][1:]
                    
                # Combine headlines and texts into articles
                mult_art = [headline + '. ' + art for headline, art in zip(headlines, mult_art)]
                
            # If there are articles with the headlines that start from \.\n{1}, end with smth like '\nBERLIN - ',
            # and possibly contain ' - ' in the headline.
            elif len([r.strip() for r in re.findall(r'(?:^|(?<=\.\n{1}))[^\.]+?(?=\n[\s]*?[A-ZÄÖÜß][A-ZÄÖÜ /]+ - )', row["texts"]) if r.strip() != '']) > 0:
                headlines = re.findall(r'(?:^|(?<=\.\n{1}))[^\.]+?(?=\n[\s]*?[A-ZÄÖÜß][A-ZÄÖÜ /]+ - )', row['texts'])
                headlines = [h.replace("\n", ' ').replace("\t", ' ').strip() for h in headlines]
                
                txt = row['texts']
                txt = txt.strip().replace("\n", ' ').replace("\t", ' ')
                
                # Replace headline with 'SEP'
                for ind, headline in enumerate(headlines):
                    txt = txt.replace(headline, 'SEP', 1)
                
                # Split text by 'SEP' tokens
                mult_art = [i.strip() for i in txt.split('SEP')][1:]
                    
                # Combine headlines and texts into articles
                mult_art = [headline + '. ' + art for headline, art in zip(headlines, mult_art)]
             
            # If there are articles whose headlines start from \n{2} and end with smth like FRANKFURT\s{2}.
            elif len([r.strip() for r in re.findall(r'(?:^|(?<=\n{2}))[^\.]+?(?=\n[\s]*?[A-ZÄÖÜß][A-ZÄÖÜ/]+\s{2})', row['texts']) if r.strip() != '']) > 0:
                headlines = re.findall(r'(?:^|(?<=\n{2}))[^\.]+?(?=\n[\s]*?[A-ZÄÖÜß][A-ZÄÖÜ/]+\s{2})', row["texts"])
                headlines = [h.replace("\n", ' ').replace("\t", ' ').strip() for h in headlines]
                
                txt = row['texts']
                txt = txt.strip().replace("\n", ' ').replace("\t", ' ')

                # Replace headline with 'SEP'
                for ind, headline in enumerate(headlines):
                    txt = txt.replace(headline, 'SEP', 1)
                
                # Split text by 'SEP' tokens
                mult_art = [i.strip() for i in txt.split('SEP')][1:]
                    
                # Combine headlines and texts into articles
                mult_art = [headline + '. ' + art for headline, art in zip(headlines, mult_art)]
                
            # If there are articles with the headlines that start from \.\n{1}, end with smth like '\nBerlin - ', and
            # contain a period.
            elif len([r.strip() for r in re.findall(r'(?:^|(?<=\.\n{1}))[\S\s]+?(?=\n[\s]*?[A-ZÄÖÜß][A-ZÄÖÜa-zäöüß /]+ - )', row["texts"]) if r.strip() != '']) > 0:
                headlines = re.findall(r'(?:^|(?<=\.\n{1}))[\S\s]+?(?=\n[\s]*?[A-ZÄÖÜß][A-ZÄÖÜa-zäöüß /]+ - )', row['texts'])
                headlines = [h.replace("\n", ' ').replace("\t", ' ').strip() for h in headlines]
                
                txt = row['texts']
                txt = txt.strip().replace("\n", ' ').replace("\t", ' ')
                
                # Replace headline with 'SEP'
                for ind, headline in enumerate(headlines):
                    txt = txt.replace(headline, 'SEP', 1)
                
                # Split text by 'SEP' tokens
                mult_art = [i.strip() for i in txt.split('SEP')][1:]
                    
                # Combine headlines and texts into articles
                mult_art = [headline + '. ' + art for headline, art in zip(headlines, mult_art)]
            
            # If there are articles whose headlines start from \n{2}, end with smth like FRANKFURT\s{2}, and
            # contain a period.
            elif len([r.strip() for r in re.findall(r'(?:^|(?<=\n{2}))[\S\s]+?(?=\n[\s]*?[A-ZÄÖÜß][A-ZÄÖÜ]+\s{2})', row['texts']) if r.strip() != '']) > 0:
                headlines = re.findall(r'(?:^|(?<=\n{2}))[\S\s]+?(?=\n[\s]*?[A-ZÄÖÜß][A-ZÄÖÜ]+\s{2})', row["texts"])
                headlines = [h.replace("\n", ' ').replace("\t", ' ').strip() for h in headlines]
                
                txt = row['texts']
                txt = txt.strip().replace("\n", ' ').replace("\t", ' ')

                # Replace headline with 'SEP'
                for ind, headline in enumerate(headlines):
                    txt = txt.replace(headline, 'SEP', 1)
                
                # Split text by 'SEP' tokens
                mult_art = [i.strip() for i in txt.split('SEP')][1:]
                    
                # Combine headlines and texts into articles
                mult_art = [headline + '. ' + art for headline, art in zip(headlines, mult_art)]                 
                                                                         
            else:
                # If neither capitalized words nor multiple DPA references can
                # be found in the text split articles based on paragraphs
                # This method can sometimes lead to false positives, hence the 
                # two previous approaches
                txt = row['texts']
                txt = txt.strip().replace("\n", ' ').replace("\t", ' ')
                # Capitalize the first letter of a string if it is in lowercase
                if txt[0].islower():
                    txt = txt.split()[0].capitalize() + txt.replace(txt.split()[0], '')
                mult_art = re.findall(r'((?:^|(?:\s{2}))(?:[\'A-ZÄÖÜß0-9:\-\(]).+?(?:\s{2}(?!\-|<|[a-z]| [a-z])|$))', txt)    
                mult_art = [m.strip() for m in mult_art]
        
        # Make sure that there are no extra white spaces
        mult_art = [' '.join(m.split()) for m in mult_art] 
        
        if mult_art != []:
            
            for art in mult_art:
                # Store meta data for the article
                separated_articles = multiple_articles.iloc[index][multiple_articles.iloc[index] != 'texts']
                # Assign the new text to the matching meta data
                separated_articles['texts'] = art
                split_art.append(separated_articles)
                    
        else:
            split_art.append(row) 

    return(pd.concat(split_art, axis=1).transpose())