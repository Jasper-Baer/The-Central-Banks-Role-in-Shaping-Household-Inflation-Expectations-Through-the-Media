# -*- coding: utf-8 -*-
"""
Created on Fri Aug 19 14:22:17 2022

@author: jbaer
"""

import json
import pandas as pd
import re
import os
import nltk

os.chdir("D:\Studium\PhD\Github\Single-Author\Code\ECB")

from clean_data import clean_data

f = open('D:\Studium\PhD\Single Author\Data\ECB\press_conferences.json')
  
data_json = json.load(f)

data = pd.read_json(data_json)

press_cons = []

for press_con in data['Texts']:
    
    press_con = ' '.join(press_con)

    pattern_date = 'Frankfurt am Main\, \d{1,2} \w+ \d{4}' 
    pattern_sent = 'We will now report on the outcome of the meeting of the Governing Council, which was also attended by the Commission Executive Vice-President,(.{,30}?)\.|Let me report on the outcome of our meeting, which was also attended by (.{,30}?)\.|The meeting was also attended by(.{0,30}?)\.|We will now report on the outcome of today’s meeting of the Governing Council, which was also attended by the Commission Executive Vice-President,(.{,30}?)\.|I would like to thank Governor (.{,30}?) for his kind hospitality and express our special gratitude to his staff for the excellent organisation of today’s meeting of the Governing Council.|(I|We) will now report on the outcome of today’s meeting of the Governing Council, which was also attended by the Commission Vice-President,(.{,30}?)\.|We will now report on the outcome of today’s meeting of the Governing Council, which was also attended by the President of the Eurogroup,(.{,30}?), and by the Commission Vice-President,(.{,30}?)\.'
    
    to_replace = ["Click here for the transcript of questions and answers.",
                  "With the transcript of the questions and answers",
                  "With a transcript of the questions and answers",
                  "Welcome address by Jean-Claude Trichet, Governor of the Banque de France",
                  "It is intended to release this report during the next couple of weeks.",
                  "We are at your disposal for any further questions.", 
                  "Reproduction is permitted provided that the source is acknowledged.",
                  "Slides: pdf 36 kB.", "Amsterdam, 9 June 2022,",
                  "Jump to the transcript of the questions and answers",
                  "Amsterdam, 9 June 2022",
                  "Please note that related topic tags are currently available for selected content only.",
                  "Let me wish you all a Happy New Year.",
                  "The Vice‑President and I will now report on the outcome of today’s meeting of the Governing Council of the ECB",
                  "Today, I am very pleased to welcome you to the ECB for the opening of the euro banknote design exhibition.",
                  "The Vice-President and I are very pleased to welcome you to our press conference.",
                  "We will now report on the outcome of today’s meeting of the Governing Council, which was also attended by the Commission Vice-President, Mr Dombrovskis, and the incoming President, Ms Lagarde.",
                  "We will now report on the outcome of today’s meeting of the Governing Council.",
                  "We will now report on the outcome of today’s meeting.",
                  "We will now report on the outcome of today’s meeting of the Governing Council, which was also attended by the Commission Vice-President, Mr Dombrovskis.",
                  "Let me wish you all a very Happy New Year.",
                  "The Vice-President and I will now report on the outcome of today's meeting of the Governing Council of the ECB."]
    
    for string in to_replace:
    
        press_con = press_con.replace(string, '')
     
    press_con = press_con.strip()
    
    press_con = re.sub(pattern_date, '', press_con.strip()).strip()
    press_con = re.sub(pattern_sent, '', press_con.strip()).strip()
    
    press_cons.append(press_con)

data['clean press cons'] = press_cons

tokens = clean_data(press_cons)   

data['tokens'] = tokens
data['press sent'] = [nltk.sent_tokenize(text) for text in data['clean press cons']]

press_sents = pd.DataFrame()

for idx, press_sent in enumerate(data['press sent']):
    
    for sent in press_sent:
        
        press_sents = press_sents.append({'index': idx, 'sentence': sent}, ignore_index=True)

# Delete Greetings from start
data['press sent'] = [press[1:] for press in data['press sent']]
press_cons = data['press sent']

# Before we take your questions, we would like to express our profound gratitude to all those who are dedicating their time and efforts in saving lives and containing the spread of the coronavirus.
questions_start = ['We are now ready to take your questions.',
                   'We are now at your disposal, should you have any questions.', 
                   'Click here for the transcript of questions and answers.',
                   'We stand ready to answer any questions you may have.',
                   'We stand ready to take any questions you might have.',
                   'Click here for the transcript of questions and answers.',
                   'We are at your disposal for any further questions.',
                   'We are at your disposal for further questions.',
                   'I am now at your disposal for questions.',
                   'I am now open to questions.',
                   'I am now at your disposal for questions.',
                   'We are now at your disposal should you have any questions.',
                   'We are now at your disposal for questions.',
                   'We are now at your disposal for questions.',
                   'Click here for the transcript of questions and answers.']

idx_questions = []
QAs = []
speeches = []

for idx, con in enumerate(press_cons):
    
    idxs = None
    
    if idx == 20:
        
        delim = 'Before we take your questions, we would like to express our profound gratitude to all those who are dedicating their time and efforts in saving lives and containing the spread of the coronavirus.'
        idxs = [con.index(delim)]
    
    elif idx == 64:
        
        delim = 'My question would be on how credible these tests are.'
        idxs = [con.index(delim)]
        
    elif idx == 68:
        
        delim = 'Question: Mr Draghi, you also reminded us that you intensified your work on the ABS programme or the potential programme.'
        idxs = [con.index(delim)]
        
    elif idx == 99:   
        
        delim = '* * *  Question: You have mentioned again today this fiscal compact which we heard you mention for the first time earlier this month.'
        idxs = [con.index(delim)]
    
    elif idx == 205:
        
        delim = 'Question: A question to the three of you: with the definition of price stability you released today, namely to maintain inflation rates close to 2% over the medium term, would you have had a different monetary policy in the last four years?'
        idxs = [con.index(delim)]            
    
    elif idx == 208:
        
        delim = 'Question: Given the fact that the inflation rate looks benign and that there are still downside risks to growth, which impediments do you have to cutting rates?'
        idxs = [con.index(delim)]
    
    elif idx == 220:
        
        delim = 'Question: I have got two questions.'
        idxs = [con.index(delim)]
    
    elif idx == 225:
        
        delim = 'Question: Mr. Duisenberg, what can European policy makers actually do to help the European economy?'
        idxs = [con.index(delim)]
        
    elif idx == 226:
    
        delim = 'Question: Mr. Duisenberg, can you tell us whether your monetary policy now has an easing bias or, indeed, whether you think that interest rates will be on hold for some time to come?'
        idxs = [con.index(delim)]
    
    elif idx == 234:

        delim = 'Question (translation): President Duisenberg, how would you comment on the statement Alan Greenspan made on 6 December.'
        idxs = [con.index(delim)]
        
    elif idx == 251:   
        
        delim = 'Question (translation): President Duisenberg, for months and weeks there has repeatedly been great excitement; the value of the euro vis-à-vis the US dollar has been dropping constantly.'
        idxs = [con.index(delim)]
        
    elif idx == 252:   
    
        delim = 'Question: Mr President, a few weeks ago at this press conference you were asked whether you would consider it possible that the euro could go below USD 1 and you said: "certainly not".'
        idxs = [con.index(delim)]
        
    elif idx == 254:   
        
        delim = 'Question: I would be very interested if you had anything to say about the exchange rate of the euro, if the central bankers of Europe seem comfortable with it.'
        idxs = [con.index(delim)]
        
    elif idx == 255:   
        
        delim = 'Question (translation): Mr. President, what, in your view, are the reasons for the weak euro?'
        idxs = [con.index(delim)]
        
    elif idx == 259:
        
        delim = 'Question: President Duisenberg, I have a question with respect to point 5 in your statement that says that you decided on a reference rate rather than on a range, and the reason you gave was that the Council believes that announcing a reference range might be falsely interpreted by the public as implying that interest rates would be changed automatically.'
        idxs = [con.index(delim)]
        
        
    else:
        
        idxs = [i for i, sent in enumerate(con, 1) if sent in questions_start]
    
    idx_questions.append(idxs)
    
    if idxs == []:
        
        speech = con
        QA = []
    
    else:
    
        speech = [con[i:j] for i, j in zip([0]+idxs, idxs)]
        QA = [con[i:j] for i, j in zip(idxs+[len(con)], [len(con)])]
     
    if len(speech) == 1:
        
        speech = speech[0]
        
    if len(QA) == 1:
        
        QA = QA[0]
        
    QAs.append(QA)
    speeches.append(speech)

data['speeches'] = speeches
data['QA'] = QAs

speeches_list = []

for speech in speeches:
    
    for sent in speech:
        
        speeches_list.append(sent)

data_train = pd.read_excel('D:\Studium\PhD\Single Author\Data\ECB\press_sents_sample_labeled.xlsx')   

train_sent = pd.DataFrame()    

for idx, sent in enumerate(data_train['sentence']):
    
    if sent in speeches_list:
        
        train_sent = train_sent.append(data_train.iloc[idx])

train_sent.reset_index(inplace = True, drop = True)

train_sent.to_excel('D:\Studium\PhD\Single Author\Data\ECB\press_sents_sample_labeled_speeches.xlsx')

#sample_press_sents = press_sents.sample(10000)

#data['press sent'].to_excel('D:\Studium\PhD\Single Author\Data\ECB\press_sents_full.xlsx')
#sample_press_sents.to_excel('D:\Studium\PhD\Single Author\Data\ECB\press_sents_sample.xlsx')
    
data = data.to_json()

with open('D:\Studium\PhD\Single Author\Data\ECB\press_conferences_cleaned.json', 'w+', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=4)
    
    
f = open('D:\Studium\PhD\Single Author\Data\ECB\press_conferences_cleaned.json')
  
data_json = json.load(f)

data = pd.read_json(data_json)

data = pd.read_excel('D:\Studium\PhD\Single Author\Data\ECB\press_sents_full.xlsx')

