# -*- coding: utf-8 -*-
"""
Created on Mon Aug 11 19:30:55 2025

@author: Jasper Bär
"""

import torch
import torch.nn.functional as F
import matplotlib.pyplot as plt
import seaborn as sn
import numpy as np
import pandas as pd
import os
from sklearn.metrics import confusion_matrix, f1_score, accuracy_score, balanced_accuracy_score
from torch import nn
from tqdm import tqdm
from prettytable import PrettyTable
from transformers import AdamW, get_linear_schedule_with_warmup

def train(model, config, train_dataloader, validation_dataloader):
    """
    Main training and validation loop for the BERT model.
    Saves the best model based on validation F1 score.
    """
    output_path = config['output_model_path']
    epochs = config['epochs']
    learning_rate = config['learning_rate']
    train_on_gpu = config.get('train_on_gpu', True)

    if train_on_gpu and torch.cuda.is_available():
        model.cuda()
        device = torch.device("cuda")
    else:
        device = torch.device("cpu")
        model.to(device) # Ensure model is on the correct device

    table = PrettyTable(['Epoch', 'Train Loss', 'Val Loss', 'Val F1', 'Best Model'])
    best_val_f1 = 0
    loss_function = nn.CrossEntropyLoss()

    param_optimizer = list(model.named_parameters())
    no_decay = ['bias', 'gamma', 'beta']
    optimizer_grouped_parameters = [
        {'params': [p for n, p in param_optimizer if not any(nd in n for nd in no_decay)], 'weight_decay_rate': 0.01},
        {'params': [p for n, p in param_optimizer if any(nd in n for nd in no_decay)], 'weight_decay_rate': 0.0}
    ]
    optimizer = AdamW(optimizer_grouped_parameters, lr=learning_rate, correct_bias=False)
    total_steps = len(train_dataloader) * epochs
    lr_scheduler = get_linear_schedule_with_warmup(optimizer, num_warmup_steps=0, num_training_steps=total_steps)

    for epoch in range(1, epochs + 1):
        model.train()
        total_train_loss = 0

        for batch in tqdm(train_dataloader, desc=f"Epoch {epoch}/{epochs} [Training]"):
            b_input_ids, b_input_mask, b_labels = tuple(t.to(device) for t in batch)
            
            optimizer.zero_grad()
            
            output = model(input_ids=b_input_ids, attention_mask=b_input_mask, labels=b_labels)
            loss = output.loss
            logits = output.logits
            
            total_train_loss += loss.item()
            loss.backward()
            optimizer.step()
            lr_scheduler.step()

        avg_train_loss = total_train_loss / len(train_dataloader)

        model.eval()
        total_val_loss = 0
        all_preds, all_labels = [], []

        for batch in tqdm(validation_dataloader, desc=f"Epoch {epoch}/{epochs} [Validation]"):
            b_input_ids, b_input_mask, b_labels = tuple(t.to(device) for t in batch)
            
            with torch.no_grad():
                output = model(input_ids=b_input_ids, attention_mask=b_input_mask, labels=b_labels)
                loss = output.loss
                logits = output.logits

            total_val_loss += loss.item()
            preds = torch.argmax(logits, dim=1)
            all_preds.extend(preds.cpu().numpy())
            all_labels.extend(b_labels.cpu().numpy())

        avg_val_loss = total_val_loss / len(validation_dataloader)
        val_f1 = f1_score(all_labels, all_preds, average='macro')
        
        evaluated_epoch_marker = ''
        if val_f1 > best_val_f1:
            best_val_f1 = val_f1
            torch.save(model.state_dict(), output_path)
            evaluated_epoch_marker = '<-- Best'
        
        table.add_row([f'{epoch}/{epochs}', f'{avg_train_loss:.4f}', f'{avg_val_loss:.4f}', f'{val_f1:.4f}', evaluated_epoch_marker])

    print(table)
    print(f"\nTraining complete. Best model saved to {output_path} with F1 Score: {best_val_f1:.4f}")
    return best_val_f1

def test(model, config, test_dataloader):
    """Evaluates the model on the test set."""
    output_dir = config.get('output_dir', 'outputs')
    num_labels = config['num_labels']
    train_on_gpu = config.get('train_on_gpu', True)

    if train_on_gpu and torch.cuda.is_available():
        model.cuda()
        device = torch.device("cuda")
    else:
        device = torch.device("cpu")
        model.to(device)
        
    model.eval()
    true_labels, pred_labels = [], []

    for batch in tqdm(test_dataloader, desc="Testing"):
        b_input_ids, b_input_mask, b_labels = tuple(t.to(device) for t in batch)
        
        with torch.no_grad():
            output = model(input_ids=b_input_ids, attention_mask=b_input_mask)
            logits = output.logits

        preds = torch.argmax(logits, dim=1)
        pred_labels.extend(preds.cpu().numpy())
        true_labels.extend(b_labels.cpu().numpy())
        
    test_f1 = f1_score(true_labels, pred_labels, average='macro')
    test_acc = accuracy_score(true_labels, pred_labels)
    test_bal_acc = balanced_accuracy_score(true_labels, pred_labels)

    print(f'\nTest Accuracy: {test_acc:.3f}, Balanced Accuracy: {test_bal_acc:.3f}, F1 Score (Macro): {test_f1:.3f}')
    
    cm = confusion_matrix(true_labels, pred_labels)
    cm_normalized = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis]
    df_cm = pd.DataFrame(cm_normalized, index=range(num_labels), columns=range(num_labels))
    
    plt.figure(figsize=(10, 7))
    sn.heatmap(df_cm, annot=True, fmt='.2%', cmap='Blues')
    plt.xlabel("Predicted Label")
    plt.ylabel("True Label")
    
    os.makedirs(output_dir, exist_ok=True)
    plot_path = os.path.join(output_dir, 'confusion_matrix.png')
    plt.savefig(plot_path)
    print(f"Confusion matrix saved to {plot_path}")
    plt.show()
    
    return test_f1

def predict(model, config, dataloader):
    """Runs inference on unlabeled data."""
    train_on_gpu = config.get('train_on_gpu', True)

    if train_on_gpu and torch.cuda.is_available():
        model.cuda()
        device = torch.device("cuda")
    else:
        device = torch.device("cpu")
        model.to(device)
        
    model.eval()
    all_preds = []

    for batch in tqdm(dataloader, desc="Predicting"):
        b_input_ids, b_input_mask = tuple(t.to(device) for t in batch)
        
        with torch.no_grad():
            output = model(input_ids=b_input_ids, attention_mask=b_input_mask)
            logits = output.logits
        
        preds = torch.argmax(logits, dim=1)
        all_preds.extend(preds.cpu().numpy())
        
    return all_preds