# -*- coding: utf-8 -*-
"""
Created on Sat Apr 30 12:40:45 2022

@author: Nutzer
"""

from bs4 import BeautifulSoup
from urllib.request import urlopen

from selenium import webdriver
import re
import pandas as pd

#html = urlopen("https://www.ecb.europa.eu/press/pressconf/html/index.en.html").read()

# load webdriver
driver = webdriver.Chrome(executable_path = r"D:\Studium\PhD\Single Author\Code\Crawler\chromedriver_win32\chromedriver.exe")
driver.get("https://www.ecb.europa.eu/press/pressconf/html/index.en.html")

urls = []

from selenium.webdriver.common.action_chains import ActionChains
actions = ActionChains(driver)

for i in range(0,33):
    
    element = driver.find_element_by_css_selector('div#snippet' + str(i)) 
    
    actions.move_to_element(element).perform()
    
    links = element.find_elements_by_tag_name("a")
    
    for link in links:
        # besser beatifulsoup???
          url = link.get_attribute('href')
          
          if 'en' in url[-7:]:
              
              urls.append(url)
              
urls = list(set(urls))

years = []

for url in urls:
    
    years.append(re.search(r'[/](\d{4})[/]', url).groups()[0])

# sort urls by years
from more_itertools import sort_together

urls = sort_together([years, urls])[1]

press_conferences = pd.DataFrame()
          
for url in urls:
    
    html = urlopen(url).read()
    soup = BeautifulSoup(html, features="html.parser")
    
    text = soup.find(id='main-wrapper')
    
    soup.find('main',text=True)
    
    driver.get(url)
    
    paras = text.findAll('p')
    
    texts_fil = []
    
    for para in paras:
        # replace  with apostrophe.  is invisible
        texts_fil.append(para.text.replace(r'','’'))
    
    title = driver.find_elements_by_xpath("//body/div[2]/main/div[2]/h2")[0].text
    date = re.search(r'\d{1,2}\s\w+\s\d{4}',title).group(0)
    author = re.search(r'(.+?)(?:\,)',title).groups()[0]
    
    press_conferences = press_conferences.append({'Texts': texts_fil, 'Date': date, 'Author': author}, ignore_index = True)
    
