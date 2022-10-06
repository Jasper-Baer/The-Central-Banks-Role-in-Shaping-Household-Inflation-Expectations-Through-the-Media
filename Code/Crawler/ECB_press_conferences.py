# -*- coding: utf-8 -*-
"""
Created on Sat Apr 30 12:40:45 2022

@author: jbaer
"""

from bs4 import BeautifulSoup
from urllib.request import urlopen

from selenium import webdriver
from selenium.webdriver.common.by import By
import re
import pandas as pd
import json

#html = urlopen("https://www.ecb.europa.eu/press/pressconf/html/index.en.html").read()

# load webdriver
driver = webdriver.Chrome(executable_path = r"D:\Studium\PhD\Single Author\Code\Crawler\chromedriver_win32\chromedriver.exe")
driver.get("https://www.ecb.europa.eu/press/pressconf/html/index.en.html")

urls = []
dates_list = []

from selenium.webdriver.common.action_chains import ActionChains
actions = ActionChains(driver)

for i in range(0,33):
    
    element = driver.find_element(By.CSS_SELECTOR, 'div#snippet' + str(i))    
    
    actions.move_to_element(element).perform()
    
    links = element.find_elements(By.TAG_NAME, 'a')
    
    for link in links:
        # besser beatifulsoup???
          url = link.get_attribute('href')
          
          if 'en' in url[-7:]:
              
              urls.append(url)
              
    dates = driver.find_elements(By.XPATH, "//body/div[2]/main/div[4]/dl/div[" + str(i) + ']/dt' )
    
    for date in dates:
        
        dates_list.append(date.text)
  
urls = sorted(set(urls), key=urls.index)        

years = []

for url in urls:
    
    years.append(re.search(r'[/](\d{4})[/]', url).groups()[0])

press_conferences = pd.DataFrame()
          
for url in urls:
    
    html = urlopen(url).read()
    soup = BeautifulSoup(html, features="html.parser")
    
    driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
    
    text = soup.find(id='main-wrapper')
    
    soup.find('main',text=True)
    
    driver.get(url)
    driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
    
    paras = text.findAll('p')
    
    texts_fil = []
    
    for para in paras:
        # replace  with apostrophe.  is invisible
        texts_fil.append(para.text.replace(r'','’'))
    
    try:
        title = driver.find_elements(By.XPATH, "//body/div[2]/main/div[2]/h2")[0].text
    except:
        title = driver.find_elements(By.XPATH, "//body/div[2]/main/div[3]/h2")[0].text
            
    author = re.search(r'(.+?)(?:\,)',title).groups()[0]
    
    press_conferences = press_conferences.append({'Texts': texts_fil, 'Author': author}, ignore_index = True)
    
press_conferences['date'] = dates_list
press_conferences['urls'] = urls
press_conferences['years'] = years

data = press_conferences.to_json()

with open('D:\Studium\PhD\Single Author\Data\ECB\press_conferences.json', 'w+', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=4)