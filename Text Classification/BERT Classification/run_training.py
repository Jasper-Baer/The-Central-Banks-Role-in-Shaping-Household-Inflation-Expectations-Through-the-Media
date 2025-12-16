# -*- coding: utf-8 -*-
"""
Created on Wed Sep 10 20:09:03 2024

@author: Jasper Bär
"""

"""
Train and evaluate a BERT text classifier from a YAML config: load the labeled 
Excel data, build train/val/test DataLoaders, train and save the best model 
checkpoint, then reload that checkpoint and evaluate on the test set.
"""

import yaml
import pandas as pd
import torch
import numpy as np
import argparse 
import os

#os.chdir(r"D:/Studium/PhD/Github/Single-Author - Final GitHub/Code/Bär_2025/Text Classification/BERT Classification")

from src.data_loader import BertDataManager
from src.model import initialize_model
from src.trainer import train, test

#config_path = r"D:/Studium/PhD/Github/Single-Author - Final GitHub/Code/Bär_2025/Text Classification/BERT Classification/config/train_inflation_news.yaml"

def main(config_path: str):
    """
    Orchestrates a full model training and evaluation pipeline from a config file.
    """
    # Load config
    print(f"Loading configuration from: {config_path}")
    with open(config_path, 'r', encoding='utf-8') as f:
        config = yaml.safe_load(f)

    # Set random seeds for reproducibility
    seed = config.get('random_seed', 42)
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    np.random.seed(seed)
    print(f"Using random seed: {seed}")

    # Load and prepare data
    print(f"Loading data from: {config['input_data_path']}")
    df = pd.read_excel(config['input_data_path'])
    
    # Rename columns if a map is provided
    if 'column_rename_map' in config:
        df.rename(columns=config['column_rename_map'], inplace=True)
    
    # Keep only the necessary columns
    df = df[[config['text_column'], config['label_column']]]

    df[config['label_column']] = df[config['label_column']].astype(int)
    
    # Create DataLoaders
    data_manager = BertDataManager(config)
    train_loader, val_loader, test_loader = data_manager.get_train_eval_loaders(df)
    print("DataLoaders created successfully.")

    # Initialize model
    model = initialize_model(config)
    
    # Ensure model and output directories exist
    os.makedirs(os.path.dirname(config['output_model_path']), exist_ok=True)
    os.makedirs(config.get('output_dir', 'outputs'), exist_ok=True)

    # Train the model
    print("\n--- Starting Model Training ---")
    train(model, config, train_loader, val_loader)

    # Test the best model
    print("\n--- Starting Model Evaluation on Test Set ---")
    # Load the best performing model that was saved during training
    model.load_state_dict(torch.load(config['output_model_path']))
    test(model, config, test_loader)
    
    print("\n--- Pipeline Finished Successfully ---")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Run a BERT training experiment.")
    parser.add_argument('--config', type=str, required=True, help="Path to the training configuration YAML file.")
    args = parser.parse_args()
    
    main(args.config)