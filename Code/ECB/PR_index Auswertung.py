# -*- coding: utf-8 -*-
"""
Created on Thu Aug 18 19:47:35 2022

@author: Nutzer
"""

import json
import pylab as plt
import pandas as pd
import numpy as np

f = open('D:\Studium\PhD\Github\Single-Author\Data\press_cons_index.json')
  
data_json = json.load(f)

data = pd.read_json(data_json)

#data['date'] = [date.replace('"', '') for date in data['date']]

data['date'] = pd.to_datetime(data['date'])

data = data[62:170]


labels = ["Neutral",  "Hawkish", "Dovish"]
fig, ax = plt.subplots()
ax.stackplot(data['date'], np.array(data[[ 'mp neut', 'mp rest','mp acco' ]]).transpose(), labels=labels)
ax.legend(loc='upper left')
plt.show()

labels = ["Negative", "Positive",  "Neutral"]
fig, ax = plt.subplots()
ax.stackplot(data['date'], np.array(data[['ec nega', 'ec posi', 'ec neut']]).transpose(), labels=labels)
ax.legend(loc='upper left')
ax.set_ylim([0.15, 1])
plt.show()

plt.plot(data['date'], data['ec nega'])


plt.plot(data['date'], data['index mon']) 
plt.plot(data['date'], data['index ec']) 

#data = data.drop(1292)

def moving_average(a, n=5) :
    ret = np.cumsum(a, dtype=float)
    ret[n:] = ret[n:] - ret[:-n]
    return ret[n - 1:] / n

movam = moving_average(list(data['index mon']), 7)
movam = np.append(movam, np.repeat(np.nan,3))
movam = np.insert(movam,0,np.repeat(np.nan,3))

def moving_average(a, n=5) :
    ret = np.cumsum(a, dtype=float)
    ret[n:] = ret[n:] - ret[:-n]
    return ret[n - 1:] / n

movae = moving_average(list(data['index ec']), 7)
movae = np.append(movae, np.repeat(np.nan,3))
movae = np.insert(movae,0,np.repeat(np.nan,3))

plt.plot(data['date'], movam) 
plt.plot(data['date'], movae) 

# 752 - 1757