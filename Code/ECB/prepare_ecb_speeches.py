# -*- coding: utf-8 -*-
"""
Created on Wed Apr  6 23:10:18 2022

@author: jbaer
"""

import pandas as pd
import json

import os
import multiprocessing as mp
import identify_eng_2

import string as st
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from nltk.stem import PorterStemmer

# Set the number of cores to use
NUM_CORE = mp.cpu_count()

PATH = r"D:\Studium\PhD\Fischerei\Code"
os.chdir(PATH)

import count_words

data = pd.read_csv('D:\\Studium\\PhD\\Single Author\\Data\\ECB\\Speeches\\all_ECB_speeches_repaired.csv', encoding = 'cp1252', index_col=0)

col_names = ('date', 'speaker', 'heading', 'description', 'speech')

data.columns = col_names

data.dropna(subset = ['speech'], inplace = True)

data['speech'] = data['speech'].str.replace(r'(^\s+Speech\s+|^\s+SPEECH\s+)', '', regex=True)
data['speech'] = data['speech'].str.replace(r'\s*;{2,}', '', regex=True)
data['speech'] = data['speech'].str.replace(r'\[\d{1,2}\]', '', regex=True)

data.reset_index(inplace = True, drop = True)

from datetime import datetime
startTime = datetime.now()

if __name__ == "__main__":
    pool = mp.Pool(NUM_CORE)
    count_results = pool.map(count_words.count_words, [speech for speech in data['speech']]) 
    pool.close()
    pool.join()
    
print(datetime.now()-startTime)

# Filter out empty speeches and entries which only refer to slides of presentation
data['word_count'] = count_results
data = data[data['word_count']>120]
data.reset_index(inplace = True, drop = True)

# Delete all English articles from the data  
startTime = datetime.now()

if __name__ == "__main__":
    pool = mp.Pool(NUM_CORE)
    eng_results = pool.map(identify_eng_2.identify_eng_2, [text for text in data['speech']]) 
    pool.close()
    pool.join()

print(datetime.now()-startTime)

data['language'] = eng_results
data = data[data.language==1]
data.reset_index(inplace=True, drop=True)

test = data[data['speaker'] == 'Philip R. Lane']

presidents = ['Willem F. Duisenberg', 'Jean-Claude Trichet', 'Mario Draghi', 
              'Christine Lagarde', 'Willem F. Duisenberg,Eugenio Domingo Solans']

vice_presidnets= ['Christian Noyer', 'Lucas Papademos', 'Vítor Constâncio' , 'Luis de Guindos']

board_members = ['Otmar Issing', 'Tommaso Padoa-Schioppa', 'Eugenio Domingo Solans', 
                 'Sirkka Hämäläinen', 'Jürgen Stark', 'Lorenzo Bini Smaghi',
                 'José Manuel González-Páramo', 'Gertrude Tumpel-Gugerell', 
                 'Benoît Cœuré', 'Jörg Asmussen', 'Peter Praet', 'Yves Mersch',
                 'Sabine Lautenschläge', 'Fabio Panetta', 'Isabel Schnabel',
                 'Frank Elderson', 'Philip R. Lane', 'Sabine Lautenschläger']

miscellaneous = ['Alexandre Lamfalussy']

speaker_type = []

for speaker in data['speaker']:
    
    if speaker in presidents:
        
        speaker_type.append(2)
        
    elif speaker in vice_presidnets:
        
        speaker_type.append(1)
        
    elif speaker in board_members:
        
        speaker_type.append(0)
        
    elif speaker in miscellaneous:
        
        speaker_type.append(-1)

import re

speeches = []

for idx, speech in enumerate(data['speech']):   
    
    heading = data.iloc[idx]['heading']
    description = data.iloc[idx]['description']
    speech = data.iloc[idx]['speech']
    
    speech = speech.replace(heading, '')
    speech = speech.replace(description, '')
   
    # pattern = '(?=(^\w+\,\s\d{1,2}\s\w+\s\d{4}))'
    pattern = '(^(\w+|\w+\s\w+|\w+\s\w+\s\w+)\,\s\d{1,2}\s\w+\s\d{4})'
    pattern_2 ='(^\d{1,2}\s\w+\s\d{4}\s(Introduction)?)' 
    pattern_3 = '(^\,\s\d{1,2}\s\w+\s\d{4}\s(\w+|\w+\s\w+|\w+\s\w+\s\w+)\,\s\d{1,2}\s\w+\s\d{4})'
    pattern_4 = '(^\,\s\d{1,2}\s\w+\s\d{4})'
    pattern_5 = '(^\[(.{,300}?)\])'
    pattern_6 = '(^Introduction|^Summary|^\*\*\*\s+Summary)|Presentation slides'
    pattern_7 = '^(SPEAKING NOTES )?Washington, D.C., \d{1,2} \w+ \d{4}'
    pattern_8 = '^TRANSCRIPT\s+\d{1,2}\s\w+\s\d{4}'
    pattern_9 = '^EMBARGOTransmission embargo until \d{1,2} (.*?) CET on \w+, \d{1,2} \w+ \d{4}'
    pattern_10 = '(^Speech\sby(.{,300}?)\d{1,2}\s\w+\s\d{4}|^Speech\sby(.{,300}?)\d{1,2}\s\w+\s\d{4}|^Speech\sby(.{,300}?)\w+\s\d{1,2}\,\s\d{4})'
    pattern_11 = '(^Presentation of(.{,300}?)\,\s\d{1,2}\s\w+\s\d{4}|^Presentation of(.{,300}?)\s\d{1,2}\s\w+\s\d{4})'
    pattern_12 = '(^Speech\sby\w+\s\w+\,.{0,300}\d{1,2}\s\w+\s\d{4}|^Speech\sby\w+\s\w+\,.{0,300}\d{1,2}\s\w+\s\w+\sd{4}|^Speech\sby\w+\s\w+\,.{0,300}\d{1,2}\s\w+\s\w+\s\w+\s\d{4}?)'
    pattern_13 = '(^Introductory\sremarks\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\d{4}|^Introductory\sremarks\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\d{4}|^Introductory\sremarks\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\w+\s\d{4}?)'
    pattern_14 = '(^Introductory\sstatement\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\d{4}|^Introductory\sstatement\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\d{4}|^Introductory\sstatement\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\w+\s\d{4}?)'
    pattern_15 = '(^Remarks\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\d{4}|^Remarks\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\d{4}|^Remarks\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\w+\s\d{4}?)'
    pattern_16 = '(^Introductory\sspeech\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\d{4}|^Introductory\sspeech\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\d{4}|^Introductory\sspeech\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\w+\s\d{4}?)'
    pattern_17 = '(^Intervention\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\d{4}|^Intervention\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\d{4}|^Intervention\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\w+\s\d{4}?)'
    pattern_18 = '(^Keynote\sspeech\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\d{4}|^Keynote\sspeech\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\d{4}|^Keynote\sspeech\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\w+\s\d{4}?)'
    pattern_19 = '(^Opening\skeynote\sspeech\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\d{4}|^Opening\sKeynote\sspeech\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\d{4}|^Opening\sKeynote\sspeech\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\w+\s\d{4}?)'
    pattern_20 = '(^Opening\saddress\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\d{4}|^Opening\saddress\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\d{4}|^Opening\saddress\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\w+\s\d{4}?)'
    pattern_21 = '(^Opening\sspeech\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\d{4}|^Opening\sspeech\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\d{4}|^Opening\sspeech\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\w+\s\d{4}?)'
    pattern_22 = '(^Opening\sremarks\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\d{4}|^Opening\sremarks\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\d{4}|^Opening\sremarks\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\w+\s\d{4}?)'
    pattern_23 = '(^Address\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\d{4}|^Address\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\d{4}|^Address\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\w+\s\d{4}?)'
    pattern_24 = '(^Keynote\saddress\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\d{4}|^Keynote\saddress\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\d{4}|^Keynote\saddress\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\w+\s\d{4}?)'
    pattern_25 = '(^Dinner\sspeech\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\d{4}|^Dinner\sspeech\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\d{4}|^Dinner\sspeech\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\w+\s\d{4}?)'
    pattern_26 = '(^Speech\sdelivered\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\d{4}|^Speech\sdelivered\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\d{4}|^Speech\sdelivered\sby\s\w+\s\w+\,.{0,300}\,\s\d{1,2}\s\w+\s\w+\s\w+\s\d{4}?)'

    to_replace = ['Lecture by Vítor Constâncio, Vice-President of the ECB,at the Conference on “European Banking Industry: what’s next?”, organised by the University of Navarra,Madrid, 7 July 2016',
                  'Speech by Isabel Schnabel, Member of the Executive Board of the ECB, at the Roundtable on Monetary Policy, Low Interest Rates and Risk Taking at the 35th Congress of the European Economic Association ',
                  'Speech by Luis de Guindos, Vice-President of the ECB, at the 18th annual symposium on “: an Agenda for Europe and the United States” organised by the Program on International Financial Systems and Harvard Law School (by videoconference)  ',
                  'Speech by Peter Praet, Member of the Executive Board of the ECB,at the conference',
                  'Speech by Vítor Constâncio, Vice-President of the ECB,at the 19th Euro Finance Week: Opening conference, Frankfurt am Main, 14 November 2016', 
                  'Speech by Peter Praet, Member of the Executive Board of the ECB,at The ECB and Its Watchers XVIII Conference organised by the Center for Financial Studies and the Institute for Monetary and Financial Stability at Goethe University Frankfurt, panel on the “Assessment of the expanded asset purchase programme” (with John Taylor and Jan Hatzius),Frankfurt am Main, 6 April 2017',
                  'by Luis de Guindos, Vice-President of the ECB, at the VIII High-level Policy Dialogue between Eurosystem and Latin American central banks Cartagena, 29 November 2019', 'by Christine Lagarde, President of the ECB, on signing the euro banknotes ', 'Introductory statement by Christine Lagarde, President of the ECB, at the (by videoconference) Frankfurt am Main, 21 June 2021',
                  'by Christine Lagarde, President of the ECB, for Dr Wolfgang Schäuble at the VdZ Publishers’ Night, Berlin, 4 November 2019', 'Frankfurt am Main (by video conference), 7 July 2020', 'Introductory statement by Benoît Cœuré, Member of the Executive Board of the ECB, at the session “Revitalizing the Global Economy”,Davos, 20 January 2017',
                  'Virtual IMF Spring Meetings, 8 April 2021', 'Intervention by Peter Praet, Member of the Executive Board of the ECB,at a panel discussion at the G-20 conference ',
                  'Keynote speech by Benoît Cœuré, Member of the Executive Board of the ECB, at the American-Hellenic Chamber of Commerce conference on “Greece and the global disruptive environment: A look into the future”,Athens, 28 November 2016 Ladies and gentlemen, ',
                  'Statement by Mario Draghi, President of the ECB, at the thirty-fourth meeting of the International Monetary and Financial Committee,Washington DC, 7 October 2016 ', 'Policy address by Peter Praet, Member of the Executive Board of the ECB, at the SUERF Conference “Global Implications of Europe’s Redesign”, New York, 6 October 2016',
                  'Introductory remarks by Mario Draghi, President of the ECB,at Deutscher Bundestag, Berlin, 28 September 2016', 'Keynote speech by Benoît Cœuré, Member of the Executive Board of the ECB,at a conference organised by the Istituto Affari Internazionali,Rome, 26 September 2016',
                  'Speech by Benoît Cœuré, Member of the Executive Board of the ECB,at the International Conference on Structural Reforms in Advanced Economies,Hertie School of Governance, Berlin,17 June 2016  Introduction',
                  'Speech by Yves Mersch, Member of the Executive Board of the ECB,at the Morgan Stanley Global Investment Seminar,Terre Blanche, Provence11 June 2015 ',
                  'Introductory statement by Jean-Claude Trichet, President of the ECBBrussels, 4 October 2011', 'Keynote address by Jean-Claude Trichet, President of the ECBat the 25th HORIZONT Award Ceremony Frankfurt am Main, 16 January 2008 ',
                  'Keynote speech by Lorenzo Bini Smaghi, Member of the Executive Board of the ECBSão Paulo, Brazil, 17-18 March 2008 ', 'Keynote address by Jean-Claude Trichet, President of the ECB at the session ""European Financial Supervision, Crisis Management on Financial Markets""European Parliament, Brussels, 23 January 2008 ']
    
    speech = re.sub(pattern, '', speech.strip()).strip()
    speech = re.sub(pattern_2, '', speech.strip()).strip()
    speech = re.sub(pattern_3, '', speech.strip()).strip()
    speech = re.sub(pattern_4, '', speech.strip()).strip()
    speech = re.sub(pattern_5, '', speech.strip()).strip()
    speech = re.sub(pattern_6, '', speech.strip()).strip()
    speech = re.sub(pattern_7, '', speech.strip()).strip()
    speech = re.sub(pattern_8, '', speech.strip()).strip()
    speech = re.sub(pattern_9, '', speech.strip()).strip()
    speech = re.sub(pattern_10, '', speech.strip()).strip()
    speech = re.sub(pattern_11, '', speech.strip()).strip()
    speech = re.sub(pattern_12, '', speech.strip()).strip()
    speech = re.sub(pattern_13, '', speech.strip()).strip()
    speech = re.sub(pattern_14, '', speech.strip(), flags=re.IGNORECASE).strip()
    speech = re.sub(pattern_15, '', speech.strip()).strip()
    speech = re.sub(pattern_16, '', speech.strip()).strip()
    speech = re.sub(pattern_17, '', speech.strip()).strip()
    speech = re.sub(pattern_18, '', speech.strip()).strip()
    speech = re.sub(pattern_19, '', speech.strip(), flags=re.IGNORECASE).strip()
    speech = re.sub(pattern_20, '', speech.strip()).strip()
    speech = re.sub(pattern_21, '', speech.strip()).strip()
    speech = re.sub(pattern_22, '', speech.strip()).strip()
    speech = re.sub(pattern_23, '', speech.strip()).strip()
    speech = re.sub(pattern_24, '', speech.strip()).strip()
    speech = re.sub(pattern_25, '', speech.strip()).strip()
    speech = re.sub(pattern_26, '', speech.strip()).strip()
    
    for string in to_replace:

        speech = speech.replace(string, '')
 
    speech = speech.strip()
    
    speeches.append(speech)

data['speech'] = speeches

#tokenizer = nltk.data.load('tokenizers/punkt/english.pickle')

def clean_speech(speech):
    
    # remove numbers
    speech = re.sub(r'\d+', '', speech)
    
    # define punctations
    punct = st.punctuation + ('“”–€–’')
    
    # remove punctuations and convert characters to lower case
    speech = "".join([char.lower() for char in speech if char not in punct]) 
    
    # replace multiple whitespace with single whitespace and remove leading and trailing whitespaces
    speech = re.sub('\s+', ' ', speech).strip()
    
    return (speech)

port_stemmer = PorterStemmer()

tokens_speeches = []

for speech in data['speech']:
    
    speech = clean_speech(speech)
    tokens_speech = word_tokenize(speech)
    
    stop_words = set(stopwords.words('english'))   
    
    filtered_speech = [port_stemmer.stem(w) for w in tokens_speech]
    filtered_speech = [w for w in filtered_speech if not w in stop_words]
    
    tokens_speeches.append(filtered_speech)

data['tokens'] = tokens_speeches

# data = data.to_json()

# with open('D:\Studium\PhD\Single Author\Data\ECB\speeches.json', 'w+', encoding='utf-8') as f:
#     json.dump(data, f, ensure_ascii=False, indent=4)