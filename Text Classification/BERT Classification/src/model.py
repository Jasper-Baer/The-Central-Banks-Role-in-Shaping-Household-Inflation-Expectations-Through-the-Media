# -*- coding: utf-8 -*-
"""
Created on Mon Aug 11 19:43:04 2025

@author: Jasper Bär
"""

import torch
from transformers import BertForSequenceClassification

def initialize_model(config: dict):
    """
    Initializes a BertForSequenceClassification model from a configuration dictionary.

    Args:
        config (dict): A dictionary containing model parameters, including:
            - word_embedding (str): The name of the Hugging Face model (e.g., 'bert-base-cased').
            - num_labels (int): The number of output labels for the classifier.
            - saved_model_path (str, optional): The path to a saved .pt model state dictionary.

    Returns:
        A BertForSequenceClassification model instance.
    """
    word_embedding = config['word_embedding']
    num_labels = config['num_labels']
    saved_model_path = config.get('saved_model_path', None) 

    print(f"Initializing model: {word_embedding} for {num_labels}-class classification.")
    
    model = BertForSequenceClassification.from_pretrained(
        word_embedding, 
        num_labels=num_labels
    )
    
    # If a path to a fine-tuned model is provided, load its state
    if saved_model_path:
        print(f"Loading fine-tuned weights from: {saved_model_path}")
        try:
            model.load_state_dict(torch.load(saved_model_path))
            print("Model weights loaded successfully.")
        except FileNotFoundError:
            print(f"Warning: Model file not found at {saved_model_path}. Proceeding with base model.")
        except Exception as e:
            print(f"An error occurred while loading model weights: {e}")

    return model