# -*- coding: utf-8 -*-
"""
Created on Mon Nov 14 11:21:15 2022

@author: jbaer
"""

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

def plot_news(data, monthly_count, lex_data = pd.DataFrame(), data_full_sents = pd.DataFrame()):

    dates_m = pd.date_range('1/1/1991', '1/1/2019', freq = 'M').tolist()
    #dates_q = pd.date_range('1/1/1991', '1/1/2019', freq = 'Q').tolist()
    dates_y = pd.date_range('1/1/1990', '1/1/2019', freq = 'Y').tolist()
    
    data_inflation_ger = pd.read_excel('D:\Studium\PhD\Single Author\Data\German_inflation_fred.xls')[0:29]
    data_inflation_eu= pd.read_excel('D:\Studium\PhD\Single Author\Data\EU_inflation_fred.xls')[0:29]
    
    inflation_ger_q = pd.read_excel('D:\Studium\PhD\Single Author\Data\Consumer Price IndexAll Items Total Total for Germany.xls')[10:]
    
    plt.plot(dates_y, data_inflation_ger['inflation'], color = 'black')
    plt.plot(dates_y, data_inflation_eu['inflation'], color = 'blue')
    plt.title('Yearly - Germand and EU Inflation')
    plt.show()
    
    plt.plot(dates_m, data)
    plt.title('Monthly - BERT')
    plt.show()

##############################################################################

    dates_m = pd.date_range('1/1/2000', '1/1/2019', freq = 'M').tolist()
    dates_q = pd.date_range('12/1/1999', '1/1/2019', freq = 'Q').tolist()
    dates_y = pd.date_range('1/1/2000', '1/1/2019', freq = 'Y').tolist()
    
    data = data[108:]
    data_inflation_ger = pd.read_excel('D:\Studium\PhD\Single Author\Data\German_inflation_fred.xls')[10:29]
    
    data = pd.DataFrame(data)
    data['count'] = monthly_count[108:]
    data.index = dates_m
    
    data_q = data.groupby(pd.Grouper(freq="Q")).mean()
    
    ### Quarterly dire vs monthly dire
    
    plt.plot(data.iloc[:,0], label = 'Monthly BERT')
    plt.plot(data_q.iloc[:,0], label = 'Quarterly BERT')
    plt.title('Quarterly vs Monthly BERT')
    plt.legend()
    plt.show()

##############################################################################
    
    ### quarterly dire, quarterly inf
    
    fig, ax1 = plt.subplots()
    
    ax2 = ax1.twinx()
    ax1.plot(data_q.iloc[:,0], color = 'green', label = 'Quarterly BERT')
    ax2.plot(dates_q, inflation_ger_q.iloc[:,1], color = 'blue', label = 'Quarterly Inflation')
    
    fig.legend(loc = 'lower left')
    plt.title('Quarterly - BERT vs Inflation')
    plt.show()

##############################################################################

    if not lex_data.empty:   

        ### lex dir, quarterly and monthly
        
        lex_data_m = lex_data.groupby(pd.Grouper(freq="M")).mean()[108:]
        lex_data_q = lex_data.groupby(pd.Grouper(freq="q")).mean()[36:]
        
        plt.plot(lex_data_m['index'], label = 'Lex Monthly Index')
        plt.plot(lex_data_q['index'], label = 'Lex Quarterly Index')
        
        plt.legend()
        plt.title('Lex - Quarterly vs Monthly')
        plt.show()
        
        ### lex monthly, bert monthly
        
        fig, ax1 = plt.subplots()
        
        ax2 = ax1.twinx()
        ax1.plot(lex_data_m['index'], color = 'green', label = 'Lex Monthly Index')
        ax2.plot(data.iloc[:,0], color = 'blue', label = 'BERT Monthly')
        
        fig.legend(loc = 'lower left')
        plt.title('Monthly - Lex vs BERT')
        plt.show()
    
        ### lex dire quarterly, bert dire quarterly
        
        fig, ax1 = plt.subplots()
        
        ax2 = ax1.twinx()
        ax1.plot(lex_data_q['index'], color = 'green', label = 'Lex Quarterly Index')
        ax2.plot(data_q.iloc[:,0], color = 'blue', label = 'BERT Quarterly Index')

        fig.legend(loc = 'lower left')
        plt.title('Quarterly - Lex vs BERT')
        plt.show()
    
        ### lex dir monthly negative, bert dir monthly
        
        lex_data_m['index neg'] = np.array(lex_data_m['index'])*-1
        
        fig, ax1 = plt.subplots()
        
        ax2 = ax1.twinx()
        ax1.plot(lex_data_m['index neg'], color = 'green', label = 'Lex Monthly Index Negative')
        ax2.plot(data.iloc[:,0], color = 'blue', label = 'BERT Quarterly Index')

        fig.legend(loc = 'lower left')
        plt.title('Monthly - Negative Lex vs BERT')
        plt.show()
        
        ### lex dir quarterly negative, bert dir quarterly
        
        lex_data_q['index neg'] = np.array(lex_data_q['index'])*-1
        
        fig, ax1 = plt.subplots()
        
        ax2 = ax1.twinx()
        ax1.plot(lex_data_q['index neg'], color = 'green', label = 'Lex Quarterly Index Negative')
        ax2.plot(data_q.iloc[:,0], color = 'blue', label = 'BERT Quarterly Index')
        
        fig.legend(loc = 'lower left')
        plt.title('Quarterly - Negative Lex vs BERT')
        plt.show()
        
    if not data_full_sents.empty:

        ### relative count inf, bert dir quarterly 
    
        monthly_absolute_count = data_full_sents.groupby(['year', 'month']).count()[108:].iloc[:,0]
        data['relative count'] = np.array(data['count'])/np.array(monthly_absolute_count)
        
        fig, ax1 = plt.subplots()
        
        ax2 = ax1.twinx()
        ax1.plot(data['relative count'], color = 'green', label = 'Relative Count Inf')
        ax2.plot(data_q.iloc[:,0], color = 'blue', label = 'BERT Quarterly Index')
        
        fig.legend(loc = 'lower left')
        plt.title('Quarterly - Relative Count Inf vs BERT')
        plt.show()
        
        ### relative count inf, inf quarterly 
        
        fig, ax1 = plt.subplots()
        
        ax2 = ax1.twinx()
        ax1.plot(data['relative count'], color = 'green', label = 'Relative Count Inf')
        ax2.plot(dates_q, inflation_ger_q.iloc[:,1], color = 'blue', label = 'Quarterly Inflation')
        
        fig.legend(loc = 'lower left')
        plt.title('Quarterly - Relative Count Inf vs Inf')
        plt.show()