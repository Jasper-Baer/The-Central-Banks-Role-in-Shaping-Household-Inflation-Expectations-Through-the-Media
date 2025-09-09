# -*- coding: utf-8 -*-
"""
Created on Fri Aug  8 21:31:45 2025

@author: Jasper Bär
"""

import yaml
import os
from src.ecb_scraper import ECBScraper

def main():
    """
    Main entry point for the application.
    Loads configuration, instantiates the scraper, and runs it.
    """
    print("--- Starting ECB Press Conference Scraper ---")

    # Load config
    try:
        with open('config/ecb_scraper.yaml', 'r') as f:
            config = yaml.safe_load(f)
    except FileNotFoundError:
        print("Error: 'config/config.yaml' not found. Please ensure the file exists in the correct location.")
        return
    
    output_dir = os.path.dirname(config.get("output_path", "data/"))
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        print(f"Created output directory: {output_dir}")

    scraper = ECBScraper(config)
    scraper.run()
    
    print("--- Scraper finished ---")


if __name__ == "__main__":
    main()