# -*- coding: utf-8 -*-
"""
Created on Sun Jul 11 13:59:03 2021

@author: mokuneva
"""


import re

def split_number_word(text):
    
    """ 
    This function splits the numbers and words erroneously merged together.
    """
    
    # Correct a few random misspellings.
    
    correct_misspellings_dic = {
        "Kapita1erhöhung": "Kapitalerhöhung",
        "sic,h": "sich",
        "Aktien,m": "Aktien,",
        "bereitsin": "bereits in,",
        "erwägt,e": "erwägte",
        "Neil,l": "Neill",
        "habe,n": "haben",
        "Margen,n": "Margen",
        "werden,s agte": "werden, sagte",
        "HANDELSBLATT,t": "HANDELSBLATT",
        "gu,t": "gut",
        "â€Ž": "",
        "â€‹": "",
        "ï¿½": "",
        "austrCent": "austr Cent",
        "0bwohl": "Obwohl",
        "0ei": "bei",
        "1eine": "eine",
        "1eineinhalb": "eineinhalb",
        "08einhalb": "achteinhalb",
        "07einhalb": "siebeneinhalb",
        "17erauf": "17er auf",
        "60erbis": "60er bis",
        "80erbis": "80er bis",
        "90erjahre": "90er Jahre",
        "19j-ährige": "19-Jährige",
        "2A $ je Aktie": "2 $ je Aktie",
        "80erund": "80er und",
        "1erund": "1er und",
        "1920erund": "1920er und",
        "1950erund": "1950er und",
        "1960erund": "1960er und",
        "1970erund": "1970er und",
        "20erund": "20er und",
        "200erund": "200er und",
        "3erund": "3er und",
        "5erund": "5er und",
        "50erund": "50er und",
        "60erund": "60er und",
        "70erund": "70er und",
        "911erund": "911er und",
        "90erJahre": "90er Jahre",
        "80erJahre": "80er Jahre",
        "90erJahren": "90er Jahren",
        "70erund": "70er und",
        "1,5123M": "1,5123DM",
        "1,50M": "1,50DM",
        "200O": "2000",
        "70erJahre": "70er Jahre",
        "80erJahren": "70er Jahren",
        "USDollar": "US Dollar",
        "500Mio. $": "500 Mill. $",
        "5aVVG": "5a VVG",
        "90ger": "90er",
        "(3o Juni)": "(30 Juni)",
        "3o.6.": "30.6.",
        "18.3o Uhr": "18.30 Uhr",
        "gSäure": "g Säure",
        "gRestzucker": "g Restzucker",
        "1O/1O8,7 %": "10/108,7 %",
        "2,O und 2,3": "2,0 und 2,3",
        "+1O,2 %": "+10,2 %",
        "+1O,6 %": "+10,6 %",
        "O,34": "0,34",
        "1R $": "1 R $",
        "11,O %": "11,0 %",
        "O,97 %": "0,97 %",
        "(O,8O)": "(0,80)",
        "14,O Mrd.": "14,0 Mrd.",
        "+11,O %": "+11,0 %",
        "(2 O56) Mill.": "(2 056) Mill.",
        "1822direct": "1822direkt",
        "â™¦": "",
        "70ger": "70er",
        "80ger": "80er",
        "90ger": "90er",
        "1OO": "100",
        "9O": "90",
        "18OO": "1800",
        "3OO": "300",
        "4OO": "400",
        "O,8O": "0,80",
        "50ziger": "50er",
        "80ziger": "80er",
        "den 3oer": "den 30er",
        "8oer": "80er"
        }


    for mistake, correction in correct_misspellings_dic.items():
        text = text.replace(mistake, correction)                  
    
    
    # Create a dictionary where the keys are mistakes (numbers and words merged
    # together) and values are the corresponding corrections.                
    replace_dic = dict()
    
    # A regular expression for the group where the first element is a digit
    # or a comma, and the second element is a word.
    pat = r"(\b[0-9,]+)([a-z\u00C0-\u017F]+\b)"
    to_replace = re.findall(pat, text, re.I)
    
    
    # The list with exceptions: words that should not be split.
    to_merge = ["3com", "3xx", "50hertz", "1822direkt", "3sat", "1mdb",
                "4mbo", "360t", "3par", "3gsm", "12snap", "23andme",
                "4sc", "4assetmanagement", "3ds", "6wunderkinder", "55plus",
                "300er", "3satbörse", "328jet", "25hours", "1aim", "9flats",
                "4cast", "24plus", "49ers", "4asset", "1000mercis", "3dfx",
                "7up", "428jet", "1234yf", "9dtv", "23andme", "3tc",
                "3gc", "3do", "1value", "3do", "8ku", "1822direkt", "3com",
                "2raumwohnung", "3po", "10tacle", "2cv", "20six", 
                "3yourmind", "4content", "2waytraffic", "9live", " 4pl",
                "4you", "010xy", "12go", "3coms", "4flow", "3pars", "90elf",
                "4ing", "7days", "1aims", "5sr", "4motion", "1epos",
                "13fs", "4control", "24timer", "19xx", "20sounsoviel",
                "900neo", "4sc", "83north", "3dsl", "360buy", "7tv", "2wire",
                "1000hands", "320neo", "200er", "99chairs", "1globalplace",
                "3si", "3di", "360networks", "1stmover", "7travel", "5th",
                "1822mobile", "10yearstwitter", "19abrego", "11ac", "3acb",
                "72andsunny", "10betterpages", "1blu", "4chan", "3coraçoes",
                "2cube", "2day", "3deluxe", "99designs", "99drei", "486dx",
                "5elements", "20XX", "528jet", "728jet", "928jet", "1er", "400er",
                "777er"]
    
    # Exceptions based on the second element of the group.
    exc_second = ["er", "st", "ern", "th", "te", "ste", "nd", "sten",
                  "ers", "rd", "iger", "ige", "igsten", "erin", "ten", "stel",
                  "stellige", "ger"]
    
    # t: Tonne, g: Gramm, l: Liter, m: Meter, p:pound
    one_letter_exc = ["t", "g", "l", "m", "p"]
    
    
        
    for rep in to_replace:
        # If the second element of the group is 'O' and the first one is not
        # a comma, then replace 'O' with '0' because it is an OCR-related mistake.
        if (rep[1] == 'O' and rep[0] != ','):
            text = text.replace('O', '0')
            
        rep_before = rep[0]+rep[1]
        # The case where the second element in the group is one letter 
        # (capital or minuscule).
        if (rep[1].isalpha() == True and len(rep[1]) == 1):
            # Split if the letter is from the list one_letter_exc.
            if rep[1] in one_letter_exc:
                replace_dic[rep_before] = rep[0] + ' ' + rep[1]
        # The case where the first element is a comma.
        elif rep[0] == ',':
            # Split if the second element is not 'XX', 'Xx', or 'xx'.
            if rep[1] not in ['XX', 'Xx', 'xx']:
                replace_dic[rep_before] = rep[0] + ' ' + rep[1]
        else:
            # Split if the word is not an exception from the list to_merge and
            # the second element is not from the list exc_second.
            if ((rep_before.lower() not in to_merge) and (rep[1].lower() not in exc_second)):
                replace_dic[rep_before] = rep[0] + ' ' + rep[1]
    
    # Split the words from the dictionary replace_dic.
    for word, repl in replace_dic.items():
        text = text.replace(word, repl)
        
    return(text)

