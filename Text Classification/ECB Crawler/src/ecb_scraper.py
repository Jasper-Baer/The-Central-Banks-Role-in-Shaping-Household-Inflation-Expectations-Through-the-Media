# -*- coding: utf-8 -*-
"""
Created on Sat Apr 30 12:40:45 2022

@author: Jasper Bär
"""

import pandas as pd
import requests
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains 
from webdriver_manager.chrome import ChromeDriverManager
from selenium.common.exceptions import NoSuchElementException
import re
import json
import time
from tqdm import tqdm
from typing import Optional, Dict, Any, List

class ECBScraper:
    """
    A scraper for ECB press conferences.
    
    This class handles finding conference URLs, parsing each page,
    and saving the data.
    """

    def __init__(self, config: Dict[str, Any]):
        """
        Initializes the scraper with configuration.
        """
        self.base_url = config['base_url']
        self.output_path = config['output_path']
        self.conference_urls: List[str] = []
        self.scraped_data: List[Dict[str, Any]] = []

    def _get_driver(self) -> webdriver.Chrome:
        """Initializes and returns a Selenium WebDriver."""
        options = webdriver.ChromeOptions()
        service = Service(ChromeDriverManager().install())
        return webdriver.Chrome(service=service, options=options)

    def find_conference_urls(self):
        """Finds all press conference URLs"""
        print("Finding press conference URLs...")
        driver = self._get_driver()
        driver.get(self.base_url)
        urls = []

        try:

            actions = ActionChains(driver)
            
            elements = driver.find_elements(By.CSS_SELECTOR, "div[id^='snippet']")
            max_i = len(elements)
            print(f"Found {max_i} initial snippet elements. Iterating through them to load page...")

            for i in range(0, max_i):
                try:
                    # Re-find the element in each loop to avoid stale references
                    element = driver.find_element(By.CSS_SELECTOR, 'div#snippet' + str(i))
                    
                    # Scroll page down to load correctly
                    actions.move_to_element(element).perform()
                    
                    # A small delay can help stabilize interactions
                    time.sleep(0.2)
                    
                    links = element.find_elements(By.TAG_NAME, 'a')
                    for link in links:
                        url = link.get_attribute('href')
                        if url and 'en' in url[-7:] and 'press_conference' in url and 'shared' not in url:
                            urls.append(url)
                except NoSuchElementException:
                    print(f"Warning: Could not find element 'div#snippet{i}'. Page structure may have changed.")
                    continue

            self.conference_urls = sorted(set(urls), key=urls.index)
            print(f"Found {len(self.conference_urls)} unique URLs after successful interaction.")

        except Exception as e:
            print(f"An unexpected error occurred during URL finding: {e}")
        finally:
            driver.quit()

    def _parse_page(self, url: str) -> Optional[Dict[str, Any]]:
        """Parses a single press conference page."""
        try:
            response = requests.get(url, timeout=10)
            response.raise_for_status()
        except requests.RequestException as e:
            print(f"Skipping URL {url} due to error: {e}")
            return None

        soup = BeautifulSoup(response.text, "html.parser")
        main_content = soup.find(id='main-wrapper')
        if not main_content:
            return None

        title_element = soup.find('h2', class_='ecb-pressContentSubtitle')
        title_text = title_element.get_text(strip=True) if title_element else ""
        
        paras = main_content.findAll('p')
        texts_fil = [para.text.replace('’', '’') for para in paras]
        author = title_text
        
        date_match = re.search(r'\b\d{1,2} [A-Za-z]+ \d{4}\b', title_text)
        if date_match:
            date = date_match.group(0)
        else:
            date_element = soup.find('p', class_='ecb-publicationDate')
            date_text = date_element.text if date_element else ""
            date_match = re.search(r'\b\d{1,2} [A-Za-z]+ \d{4}\b', date_text)
            date = date_match.group(0) if date_match else "Date not found"

        year_match = re.search(r'[/](\d{4})[/]', url)
        year = year_match.groups()[0] if year_match else "Year not found"

        return {"Texts": texts_fil, "Author": author, "Date": date, "urls": url, "years": year}

    def scrape_pages(self):
        """Iterates through URLs and scrapes data from each page."""
        if not self.conference_urls:
            print("No URLs to scrape.")
            return
            
        print("Scraping individual pages...")
        for url in tqdm(self.conference_urls, desc="Parsing Pages"):
            page_data = self._parse_page(url)
            if page_data:
                self.scraped_data.append(page_data)

    def save_data(self):
        """Builds a DataFrame and saves data to JSON, matching the original format."""
        if not self.scraped_data:
            print("No data to save.")
            return

        print("Constructing final DataFrame...")
        press_conferences = pd.DataFrame(self.scraped_data)
        press_conferences = press_conferences[['Texts', 'Author', 'Date', 'urls', 'years']]

        print(f"Saving data to {self.output_path}...")
        json_output_string = press_conferences.to_json(indent=4)
        
        with open(self.output_path, 'w', encoding='utf-8') as f:
            json.dump(json_output_string, f, ensure_ascii=False, indent=4)
        
        print("Scraping complete. Data saved.")

    def run(self):
        """Runs the entire scraping pipeline: find URLs, scrape, and save."""
        self.find_conference_urls()
        self.scrape_pages()
        self.save_data()