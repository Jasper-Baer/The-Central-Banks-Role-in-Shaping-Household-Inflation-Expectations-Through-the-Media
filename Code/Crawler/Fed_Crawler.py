# -*- coding: utf-8 -*-
"""
Created on Tue Feb 22 15:36:30 2022

@author: jbaer
"""

from selenium import webdriver
import pandas as pd
import requests
import re
import os
import datetime

path = r"D:\Studium\PhD\Single Author\Data\FOMC"
os.chdir(path)

def save_pdf(pdf_url_list, path, year):
    
    for url in pdf_url_list:
        
        r = requests.get(url, allow_redirects=True)
        
        # get file name
        file = re.findall('fdp\.(.*?)/', url[::-1])[0][::-1]
        open(path + '\\' + str(year) + '\\' + file + '.pdf', 'wb').write(r.content)

# load webdriver
driver = webdriver.Chrome(executable_path = r"D:\Studium\PhD\Single Author\Code\Crawler\chromedriver_win32\chromedriver.exe")

urls_htm_list = []
data_pressreleases = pd.DataFrame()

for i in range(2016, 1976, -1):
    
    driver.get("https://www.federalreserve.gov/monetarypolicy/fomchistorical" + str(i) + ".htm")
    
    elements = driver.find_element_by_css_selector('div#article') 
    links = elements.find_elements_by_tag_name("a")
    
    urls_pdfs = []
    urls_htm = []
    
    # exclude links which are already saved as pdfs
    exclude_htm = ['beigebook', 'fomcminutes']
    
    for link in links:
        
        # besser beatifulsoup???
        url = link.get_attribute('href')
        typ = url[-3:]
        
        if typ == 'pdf':
            
            urls_pdfs.append(url)
            
        elif typ == 'htm':
            
            if not any(typ in url for typ in exclude_htm):
                
                urls_htm.append(url)
                
        # elif typ == 'tml':
            
        #     if not any(typ in url for typ in exclude_htm):
                
        #         urls_html.append(url)
                
    urls_htm = set(urls_htm)
    urls_htm_list.extend(urls_htm)
    
    for url in urls_htm:
    
        urls_memo_pdfs = []
        urls_memo_html = []    
    
        if 'fomc-memos' in url:
            
            driver.get(url)
            elements = driver.find_element_by_css_selector('div#article') 
            links = elements.find_elements_by_tag_name("a")
            
            for link in links:
                
                    url_memo = link.get_attribute('href')
                    
                    if url_memo != None:
                    
                        if 'html' in url_memo:
                            
                            urls_memo_html.append(url_memo)
                            
                        else:
                            
                            urls_memo_pdfs.append(url_memo)
                    
            #urls_memo_pdfs = list(filter(None.__ne__, urls_memo_pdfs))
            
        elif 'pressreleases' in url:
        
            driver.get(url)
            article = driver.find_element_by_css_selector('div#content') 
            text = article.text
            name = driver.find_elements_by_xpath("//body/div[3]/div[2]/div/div/h3")[0].text
            date = re.search('(?<=Last Update:\s)\w+\s\d{1,2}\,\s\d{4}', text).group(0)
            year = re.search('\d{4}', date).group(0)
            month = re.search('\w+', date).group(0)
            month = datetime.datetime.strptime(month, "%B").month
            day = re.search('\d{1,2}', date).group(0)
            
            data = pd.DataFrame({'text': text, 'year': year, 'month': str(month), 'day': day, 'name': name}, index = [0])
            data_pressreleases = data_pressreleases.append(data)
    
    save_pdf(urls_pdfs, path,i)
    
    if urls_memo_pdfs != []:
    
        save_pdf(urls_memo_pdfs, path,i)
    
    
    #########save_pdf for urls_memo_html##############
    
data_pressreleases.reset_index(inplace = True, drop = True)

import PyPDF2 

sections = []
texts = []

years = []
months = []
days = []

pdfs = []

for i in range(2016, 1936, -1):

    for pdf in os.listdir(path + '\\' + str(i)):
        
        text = ''
        file = open(path + '\\' + str(i) + '\\' + pdf, 'rb') 
        file = PyPDF2.PdfFileReader(file) 
        num_pages = file.numPages
        
        pdfs.append(pdf)
        
        for p in range(0, num_pages):
            page = file.getPage(p)
            text += page.extractText()
        
        if 'Beigebook' in pdf:    
        
            date = pdf[-12:-4]
            section = 'Beigebook'
            
        elif 'memo' in pdf:
            
            date = pdf[4:12]
            section = 'Memo'
            
        elif 'Agenda' in pdf:
            
            date = pdf[4:12]
            section = 'Agenda'
            
        elif 'material' in pdf:
            
            date = pdf[4:12]
            section = 'Material'
            
        elif 'fomcminutes' in pdf:
        
            date = pdf[-12:-4]
            section = 'Minutes'
            
        elif 'tealbook' in pdf:
            
            date = pdf[4:12]
            section = 'Tealbook'
            
        elif 'SEPcompilation' in pdf:
            
            date = pdf[4:12]
            section = 'SEP Compilation'
            
        elif 'SEPkey' in pdf:
            
            date = pdf[4:12]
            section = 'SEP key'
            
        elif 'meeting' in pdf:
            
            date = pdf[4:12]
            section = 'Meeting'
            
        elif 'moa' in pdf:
            
            date = pdf[-12:-4]
            section = 'Minutes of Action'
            
        elif 'confcall' in pdf:
            
            date = pdf[4:12]
            section = 'Conference Call'
        
        texts.append(text) # .encode('utf-8')
        sections.append(section)
        
        years.append(int(date[:-4]))
        months.append(int(date[-4:-2]))
        days.append(int(date[-2:]))

data = pd.DataFrame({'text': texts, 'year': years, 'month': months, 'day': days, 'sections': sections, 'pdf': pdfs})

cols=["year","month","day"]
data['date'] = data[cols].apply(lambda x: '-'.join(x.values.astype(str)), axis="columns")
data['date'] = pd.to_datetime(data['date'], format='%Y-%m-%d') 

sections_name = {u'FOMChistmin': 'Historical Minutes', 
                 u'FOMChminec': 'Historical Minutes Executive Committee', 
                 u'fomcropa': 'Record of Policy Actions',
                 u'Beigebook_': 'Beigebook', u'SEPkey': 'SEP Participant Key',
                 u'SEPcompilation': 'SEP Individual Projections',
                 u'material': 'Presentation Material'}

# rename some sections for clarity
data['sections'] = [sections_name[k] if k in list(sections_name.keys()) else k for k in data['sections'] ]

data_meeting = data[data['sections'] == 'meeting']
data_meeting.reset_index(inplace = True, drop = True)

data_meeting_speeches = pd.DataFrame()

for idx, meeting in enumerate(data_meeting['text']):
    
    meeting = re.sub('\n', '', meeting)
    meeting = re.sub('™', '’', meeting)    
    meeting = re.sub('Š', '—', meeting)
    meeting = re.sub('½', '%', meeting) 
    meeting = re.sub('¾', '%', meeting)    
    meeting = re.sub('¼', '%', meeting)
    meeting = re.sub('Œ', '–', meeting)
    meeting = re.sub('ﬁ', '“', meeting)
    meeting = re.sub('ﬂ', '”', meeting)
    
    data_meeting.loc[idx, 'text'] = meeting
    
    # 2016
    #meeting = re.split('Transcript of the Federal Open Market Committee Meeting on .*? \d{1,2}–\d{1,2}, \d{4} .*? \d{1,2} Session', meeting)
    
    # 2005
    meeting = re.split('Transcript of (the )?Federal Open Market Committee Meeting (on|of).*?(\d{1,2}-\d{1,2}, \d{4}|\d{1,2}, \d{4})', meeting)
    
    meeting = meeting[-1]

    texts = re.findall('[A-Z.]{2,}\s[A-Z]{2,}\.\d{0,1}(.+?)(?=[A-Z.]{2,}\s[A-Z.]{2,}\.\d{0,1}|$)', meeting)
    names = re.findall('[A-Z.]{2,}\s[A-Z]{2,}\.\d{0,1}', meeting)
    date = data_meeting['date'].iloc[idx]
    
    data_meeting_speeches = data_meeting_speeches.append(pd.DataFrame({'Member': names, 'Texts': texts, 'Date': date}))   
    
    
    ## Transcript of the Federal Open Market Committee Meeting on December 13, 2005 CHAIRMAN GREENSPAN. Good morning, everyone. 

#data_meeting.to_csv('fomc_meeting_data_2016.csv')
data_meeting = pd.read_csv('fomc_meeting_data_2016.csv')

for pdf in os.listdir(path + '\\' + str(i)):
    if 'meeting' in pdf:
        print(pdf)

# Taking the Fed at its Word: A New Approach to Estimating Central Bank Objectives using Text Analysis

# drop utterances with less than five words
# drop stand-alone utterances, defined as an utterance that is preceded and followed by utterances from different speakers
# Oxford Dictionary of Economics (ODE) to filter out remarks that did not contain at least one economics-related term. We define a
# remark as a set of consecutive utterances by a single speaker (i.e., comments made by a speaker before discussion turned to another speaker)