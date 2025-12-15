# -*- coding: utf-8 -*-
"""
This module handles all data loading and preprocessing for the BERT model.
It takes a pandas DataFrame and converts it into PyTorch DataLoaders suitable
for training, evaluation, and prediction.
"""

import torch
import numpy as np
import pandas as pd
from torch.utils.data import TensorDataset, DataLoader, RandomSampler, SequentialSampler
from transformers import BertTokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences

class BertDataManager:
    """Manages the tokenization and creation of PyTorch DataLoaders."""
    
    def __init__(self, config: dict):
        """
        Initializes the data manager with a configuration dictionary.
        """
        self.config = config
        self.tokenizer = BertTokenizer.from_pretrained(config['word_embedding'], do_lower_case=True)
        self.max_len = config['max_len']
        self.batch_size = config['batch_size']

    def _tokenize_and_prepare_tensors(self, texts, labels=None):
        """
        Helper function to perform tokenization, padding, and tensor conversion.
        """
        sentences = ["[CLS] " + str(sentence) + " [SEP]" for sentence in texts]
        tokenized_texts = [self.tokenizer.tokenize(sent) for sent in sentences]
        
        input_ids = [self.tokenizer.convert_tokens_to_ids(x) for x in tokenized_texts]
        input_ids = pad_sequences(input_ids, maxlen=self.max_len, dtype="long", truncating="post", padding="post")
        
        attention_masks = []
        for seq in input_ids:
            seq_mask = [float(i > 0) for i in seq]
            attention_masks.append(seq_mask)
            
        inputs = torch.tensor(input_ids)
        masks = torch.tensor(attention_masks)
        
        if labels is not None:
            labels = torch.tensor(labels, dtype=torch.long)
            return inputs, masks, labels
        else:
            return inputs, masks

    def get_train_eval_loaders(self, df: pd.DataFrame):
        """
        Prepares and splits data for a training run, returning train, validation, and test DataLoaders.
        """
        text_col = self.config['text_column']
        label_col = self.config['label_column']
        
        texts = df[text_col].values
        labels = df[label_col].values
        
        input_ids, attention_masks, labels_tensor = self._tokenize_and_prepare_tensors(texts, labels)
        
        # Split data using indices
        np.random.seed(self.config.get('random_seed', 42))
        indices = np.arange(len(input_ids))
        np.random.shuffle(indices)
        
        train_size = int(0.7 * len(indices))
        val_size = int(0.15 * len(indices))
        
        train_idx = indices[:train_size]
        val_idx = indices[train_size : train_size + val_size]
        test_idx = indices[train_size + val_size:]
        
        # Create training dataloader
        train_data = TensorDataset(input_ids[train_idx], attention_masks[train_idx], labels_tensor[train_idx])
        train_sampler = RandomSampler(train_data)
        train_dataloader = DataLoader(train_data, sampler=train_sampler, batch_size=self.batch_size)
        
        # Create validation dataloader
        val_data = TensorDataset(input_ids[val_idx], attention_masks[val_idx], labels_tensor[val_idx])
        val_sampler = SequentialSampler(val_data)
        validation_dataloader = DataLoader(val_data, sampler=val_sampler, batch_size=self.batch_size)
        
        # Create test dataloader
        test_data = TensorDataset(input_ids[test_idx], attention_masks[test_idx], labels_tensor[test_idx])
        test_sampler = SequentialSampler(test_data)
        test_dataloader = DataLoader(test_data, sampler=test_sampler, batch_size=self.batch_size)
        
        return train_dataloader, validation_dataloader, test_dataloader

    def get_prediction_loader(self, df: pd.DataFrame):
        """
        Prepares data for a prediction run, returning a single DataLoader.
        """
        text_col = self.config['text_column']
        texts = df[text_col].values
        
        inputs, masks = self._tokenize_and_prepare_tensors(texts)
        
        pred_data = TensorDataset(inputs, masks)
        pred_sampler = SequentialSampler(pred_data)
        prediction_dataloader = DataLoader(pred_data, sampler=pred_sampler, batch_size=self.batch_size)
        
        return prediction_dataloader