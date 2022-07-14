# -*- coding: utf-8 -*-
"""
Created on Sat Apr  2 11:51:34 2022

@author: jbaer
"""

from selenium import webdriver
from datetime import datetime
from urllib.request import urlopen
from bs4 import BeautifulSoup
import pandas as pd
import nltk.data

import os
import multiprocessing as mp
import re

NUM_CORE = mp.cpu_count()

PATH = r"D:\Studium\PhD\Fischerei\Code"
os.chdir(PATH)

import count_words

# load webdriver
driver = webdriver.Chrome(executable_path = r"D:\Studium\PhD\Single Author\Code\Crawler\chromedriver_win32\chromedriver.exe")

########### fed speeches after 2005

driver.get("https://www.federalreserve.gov/newsevents/speeches.htm")
urls_htm = []

next_page = False

while not next_page:
    
    speeches = driver.find_element_by_xpath("//*[@id='article'][1]")
    speeches = speeches.find_elements_by_class_name('row')
    
    for element in speeches:
            
            link = element.find_elements_by_tag_name("a")
            # besser beatifulsoup???
            url = link[0].get_attribute('href')
            
            urls_htm.append(url)
            
    pagination = driver.find_elements_by_class_name('pagination')[1]
    pagination = pagination.find_elements_by_class_name('pagination-next')[0]
    click = pagination.find_elements_by_class_name('ng-binding')[0]
    next_page = driver.execute_script("return arguments[0].hasAttribute(\"disabled\");", click) 
    
    if next_page == False:
    
        driver.execute_script("arguments[0].click();", click)
        
def downnload_speech(url):
    
    driver.get(url)
    
    speech = driver.find_element_by_xpath("//div[@id='article']/div[3]").text
    
    article = driver.find_element_by_xpath("//div[@id='article']")
    info = article.find_elements_by_class_name('heading')[0]
    
    date = info.find_elements_by_class_name('article__time')[0].text
    title = info.find_elements_by_class_name('title')[0].text
    speaker = info.find_elements_by_class_name('speaker')[0].text
    location = info.find_elements_by_class_name('location')[0].text
    
    data = pd.DataFrame({'speech': speech, 'date': date, 'title': title, 'speaker': speaker, 'location': location}, index=[0])
    
    return(data)

data = pd.DataFrame()

startTime = datetime.now()

for url in urls_htm[0:100]:
    
    data = data.append(downnload_speech(url))
    
print(datetime.now()-startTime)

data.reset_index(inplace = True, drop = True)

########### fed speeches before and at 2005

data = pd.DataFrame()

for y in range(1996, 2006):
    
    #driver.get("https://www.federalreserve.gov/newsevents/speech/" + str(y) + "speech.htm")
    
    html = urlopen("https://www.federalreserve.gov/newsevents/speech/" + str(y) + "speech.htm").read()
    soup = BeautifulSoup(html, features="html.parser")
    
    articles = soup.find(id="speechIndex")
    
    articles_by_titles = articles.find_all("div", class_="title")
    titles = [title.text for title in articles_by_titles]
    
    speakers = articles.find_all("div", class_="speaker")
    speakers = [speaker.text for speaker in speakers]
    
    locations = articles.find_all("div", class_="location")
    locations = [location.text for location in locations]
    
    lis = articles.findAll('li')
    dates = [li.contents[0].strip() for li in lis]
    
    years = [re.search('\d{4}',date).group(0) for date in dates]
    
    urls_htm = []
    
    for title in articles_by_titles:
       
        urls_htm.append('https://www.federalreserve.gov/' + title.find('a', href = True)['href'])
    
    texts = []
    
    for url in urls_htm:
    
        html = urlopen(url).read()
        soup = BeautifulSoup(html, features="html.parser")
        
        #text = soup.findAll('table')[1].findAll('tr').text
        
        text = ' '.join([t for t in soup.find_all(text=True) if len(t) > 5 if t.parent.name == 'p'])
        
        texts.append(text)
    
    data = data.append(pd.DataFrame({'speech': texts, 'date': dates, 'year': years, 'title': titles, 'speaker': speakers, 'location': locations}))
    
# Außnahmen:
# 1996: OK
# 1997: OK
# 1998;17
# 1999: OK
# 2000: OK
# 2001: 20, 21, 19, 4, 5, 15
# 2002: 9, 10, 12, 17, 31, 38, 74, 55, 7, 70, 34
# 2003: 6, 42, 31 raus
# 2004: OK
# 2005: OK
    
from datetime import datetime
startTime = datetime.now()

if __name__ == "__main__":
    pool = mp.Pool(NUM_CORE)
    count_results = pool.map(count_words.count_words, [speech for speech in data['speech']]) 
    pool.close()
    pool.join()
    
print(datetime.now()-startTime)

# überflüssig für zweiten Part?
data['word_count'] = count_results
#data = data[data['word_count']>=150]
#data.reset_index(inplace = True, drop = True)

#data.to_csv('D:/Studium/PhD/Single Author/Data/Fed/Speeches/speeches_raw.csv')
data_test = pd.read_csv('D:/Studium/PhD/Single Author/Data/Fed/Speeches/speeches_raw.csv', index_col=0)
data = data_test

data.rename(columns = {'Unnamed: 0': 'original_index'}, inplace = True)

data_index = []

for i in range(0, len(data)):
    
    data_index.append(str(data['original_index'][i] + 1) + '.' + str(data['year'][i]))

data['article ID'] = data_index
data.drop('Unnamed: 0.1', axis=1, inplace=True)
#data['speech'] 

tokenizer = nltk.data.load('tokenizers/punkt/english.pickle')

sentences_df = pd.DataFrame()

startTime = datetime.now()

for idx in data.index:
    
    sentences = tokenizer.tokenize(data['speech'].iloc[idx])
    
    for sentence in sentences:
        
        sentence_data = {'article ID': data['article ID'].iloc[idx], 'sentence': sentence}
        
        sentences_df = sentences_df.append(sentence_data, ignore_index=True)
        
print(datetime.now()-startTime)
    
startTime = datetime.now()

if __name__ == "__main__":
    pool = mp.Pool(NUM_CORE)
    count_results = pool.map(count_words.count_words, [speech for speech in sentences_df['sentence']]) 
    pool.close()
    pool.join()
    
print(datetime.now()-startTime)

sentences_df['word_count'] = count_results
sentences_df = sentences_df[sentences_df['word_count']>=3]
        
sentences_df.reset_index(inplace = True, drop = True)

sentences_df.to_csv('D:/Studium/PhD/Single Author/Data/Fed/Speeches/speeches_raw_sentences.csv')
sentences_df.to_excel('D:/Studium/PhD/Single Author/Data/Fed/Speeches/speeches_raw_sentences.xlsx')

# del: https://alrov.activetrail.biz/March-24-Eng
# del: https://www.chicagofed.org/events/2022/fedlistens
# del: https://ucsb.zoom.us/j/87622084923
# del: https://twitter.com/i/broadcasts/1ZkKzbWwpXvKv
# del: https://www.aei.org/events/federal-reserve-governor-randal-k-quarles-discusses-the-feds-supervision-and-regulation/
# del: https://www.youtube.com/user/ClevelandFed
# del: https://www.brookings.edu/events/taking-stock-of-new-fed-and-ecb-monetary-policy-frameworks/

# https://www.c-span.org/video/?518841-1/acting-fed-reserve-chair-others-remarks-economic-conference-part-1 raus?