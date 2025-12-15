# -*- coding: utf-8 -*-
"""
Created on Mon Aug 11 19:30:55 2025

@author: Jasper Bär
"""

import torch
import torch.nn.functional as F
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sn
import numpy as np

from torch import nn
from sklearn.metrics import f1_score, accuracy_score, balanced_accuracy_score, confusion_matrix
from tqdm import tqdm
from prettytable import PrettyTable
from transformers import AdamW, get_linear_schedule_with_warmup

def train(model, config, train_dataloader, validation_dataloader):
    """Main training and validation loop. Saves the best model based on validation F1 score."""
    output_path = config['output_model_path']
    epochs = config['epochs']
    learning_rate = config['learning_rate']
    train_on_gpu = config.get('train_on_gpu', True)

    if train_on_gpu and torch.cuda.is_available():
        model.cuda()
        device = torch.device("cuda")
    else:
        device = torch.device("cpu")
        model.to(device)

    table = PrettyTable(['Epoch', 'Train Loss', 'Val Loss', 'Val F1', 'Best Model'])
    best_val_f1 = 0
    
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
    
    train_on_gpu = config.get('train_on_gpu', True)
    
    # Sent model to GPU
    if train_on_gpu and torch.cuda.is_available():
        model.cuda()
        device = torch.device("cuda")
    else:
        device = torch.device("cpu")
        model.to(device)
    
    model.eval()

    true_label = []
    pred_label = []
    test_loss_set = []
    avg_test_loss = 0
    
    # Initialized loss function
    loss_function = nn.CrossEntropyLoss()
    
    # iterate over test data
    for batch in tqdm(test_dataloader):
    
        if train_on_gpu:
            batch = tuple(t.cuda() for t in batch)
        # Unpack the inputs from our dataloader
        b_input_ids, b_input_mask, b_labels = batch
        # Telling the model not to compute or store gradients, saving memory and speeding up validation
        with torch.no_grad():
          # Forward pass, calculate logit predictions
          output = model(input_ids = b_input_ids, attention_mask=b_input_mask)
          output = output.logits
        
        logits = F.softmax(output, dim = 1)
        test_loss = loss_function(output, b_labels)
        
        test_loss_set.append(test_loss.item())
        preds = torch.max(logits, dim=1)[1]
        
        pred_label.extend(preds.cpu().tolist())
        true_label.extend(b_labels.cpu().tolist())
        
        test_loss = loss_function(output, b_labels)
        avg_test_loss += test_loss.item()
     
    avg_test_loss /= len(test_dataloader)
    
    # f1 makro score over all test data    
    test_f1_score = f1_score(true_label, pred_label, average = 'macro')
    
    # balanced accuracy over all test data
    test_bal_acc = balanced_accuracy_score(true_label, pred_label)
    
    # accuracy over all test data
    test_acc = accuracy_score(true_label, pred_label)
    
    # -- stats -- ##
    
    print('Test loss: {:.3f}'.format(avg_test_loss),
          'Test accuracy: {:.3f}'.format(test_acc),
          'Test balanced accuracy: {:.3f}'.format(test_bal_acc),
          'F1 Score: {:.3f}'.format(test_f1_score)) 
    
    # plot confusion matrix
    confn_matrix = confusion_matrix(pred_label, true_label)
    norm_c =  confn_matrix/confn_matrix.astype(float).sum(axis=0)
    df_cm = pd.DataFrame(norm_c, range(3), range(3))
    group_counts = ["{0:0.0f}".format(value) for value in confn_matrix.flatten()]
    group_percentages = ["{0:.2%}".format(value) for value in norm_c.flatten()]
    labels = [f"{v1}\n{v2}" for v1, v2 in zip(group_counts,group_percentages)]
    labels = np.asarray(labels).reshape(3,3)
    sn.heatmap(df_cm, annot=labels, annot_kws={"size": 12},fmt="", cmap = "Blues", cbar = False, xticklabels=["negative", "neutral", "positive"],yticklabels=  ["negative", "neutral", "postive"])
    plt.xlabel("True Class")
    plt.ylabel("Predicted Class")
    plt.savefig('D:\Studium\PhD\BERT_results.png', format='png')
    plt.show()
    
    return(test_f1_score)
    
def predict(model, config, dataloader):
    """Runs inference on unlabeled data."""
    
    train_on_gpu = config.get('train_on_gpu', True)
    
    # Sent model to GPU
    if train_on_gpu and torch.cuda.is_available():
        model.cuda()
        device = torch.device("cuda")
    else:
        device = torch.device("cpu")
        model.to(device)

    model.eval()
    
    pred_label = []
    
    # iterate over test data
    for step, batch in enumerate(tqdm(dataloader)):
    
        if train_on_gpu:
            batch = tuple(t.cuda() for t in batch)
        # Unpack the inputs from our dataloader
        b_input_ids, b_input_mask = batch
        # Telling the model not to compute or store gradients, saving memory and speeding up validation
        with torch.no_grad():
          # Forward pass, calculate logit predictions
          output = model(input_ids = b_input_ids, attention_mask=b_input_mask)
          output = output.logits
        
        logits = F.softmax(output, dim = 1)
        
        #test_loss_set.append(output.loss.item())
        preds = torch.max(logits, dim=1)[1]
        
        pred_label.extend(preds.cpu().tolist())
        
    return(pred_label)