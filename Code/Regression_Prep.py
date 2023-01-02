# -*- coding: utf-8 -*-
"""
Created on Fri Dec 30 16:21:31 2022

@author: Nutzer
"""

import pandas as pd
import pylab as plt
import numpy as np

data_eco = pd.read_excel('D:\Studium\PhD\Github\Single-Author\Data\Eurozone_IP.xls')[10:]
data_eco = data_eco[94:171]

data_eco.iloc[:,0] = pd.to_datetime(data_eco.iloc[:,0])

data_inf = pd.read_excel('D:\Studium\PhD\Github\Single-Author\Data\Eurozone_CPI.xls')[10:]
data_inf = data_inf[36:113]

data_inf.iloc[:,0] = pd.to_datetime(data_inf.iloc[:,0])

data_mon2 = pd.read_csv(r'D:\Studium\PhD\Github\Single-Author\Data\ECB_monetary_own_labels.csv')
data_ec2 = pd.read_csv(r'D:\Studium\PhD\Github\Single-Author\Data\ECB_economic_own_labels.csv')
data_inf_ECB = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\ECB\press_sents_full_index_labeled_inf.xlsx')

data_inf_index = pd.DataFrame()

for date in sorted(set(data_inf_ECB['date'])):
    
    press_con = data_inf_ECB[data_inf_ECB['date'] == date]
    
    pos = len(press_con[press_con['Label'] == 2])
    neu = len(press_con[press_con['Label'] == 1])
    neg = len(press_con[press_con['Label'] == 0])
    
    index = (pos-neg)/(pos+neu+neg)
    
    data_inf_index = data_inf_index.append({'date': date, 'index': index}, ignore_index=True)
    
data_inf_index['date'] = pd.to_datetime(data_inf_index['date'])   
data_mon2['date'] = pd.to_datetime(data_mon2['date'])
data_ec2['date'] = pd.to_datetime(data_ec2['date'])

data_mon2.index = data_mon2['date']
data_ec2.index = data_ec2['date']


data_inf_index.index = data_inf_index['date']
data_inf_index = data_inf_index.groupby(pd.Grouper(freq="Q")).mean()

data_mon2_q = data_mon2.groupby(pd.Grouper(freq="Q")).mean()
data_ec2_q = data_ec2.groupby(pd.Grouper(freq="Q")).mean()

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(data_mon2['date'], np.array(data_mon2['index']), color = 'green', label = 'ECB Monetary')
ax2.plot(data_inf.iloc[:,0], np.array(data_inf.iloc[:,1]), color = 'blue', label = 'Eurozone CPI')

fig.legend(loc = 'lower left')
plt.title('ECB Monetary vs Eurozone Inflation')
plt.show()

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(data_inf_index.index, np.array(data_inf_index['index']), color = 'green', label = 'ECB Monetary')
ax2.plot(data_inf.iloc[:,0], np.array(data_inf.iloc[:,1]), color = 'blue', label = 'Eurozone CPI')

fig.legend(loc = 'lower left')
plt.title('ECB Inflation vs Eurozone Inflation')
plt.show()

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(data_ec2['date'], np.array(data_ec2['index']), color = 'green', label = 'ECB Outlook')
ax2.plot(data_eco.iloc[:,0], np.array(data_eco.iloc[:,1]), color = 'blue', label = 'Eurozone IP')

fig.legend(loc = 'lower left')
plt.title('ECB Outlook vs Eurozone IP')
plt.show()

Inf_current = list(data_inf[25:61]['Unnamed: 1'])
Inf_lag = list(data_inf[13:49]['Unnamed: 1'])
ECB_inf = list(data_inf_index[31:67]['index'])
ECB_inf_lag = list(data_inf_index[19:55]['index'])
ECB_mon = list(data_mon2_q['index'])

Regression_data = pd.DataFrame()

Regression_data['Inflation'] = Inf_current
Regression_data['Inflation Lag'] = Inf_lag
Regression_data['ECB inflation'] = ECB_inf
Regression_data['ECB Inflation lag'] = ECB_inf_lag
Regression_data['ECB Monetary'] = ECB_mon




