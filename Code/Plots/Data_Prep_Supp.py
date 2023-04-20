# -*- coding: utf-8 -*-
"""
Created on Tue Apr 18 12:29:42 2023

@author: Nutzer
"""

import scipy
import pandas as pd
import numpy as np

from dateutil.relativedelta import relativedelta

def ECB_index(ECB_data):
    
    index_list = []
    
    for date in sorted(set(ECB_data['date'])):
        
        conf_data = ECB_data[ECB_data['date'] == date]['Label']
        pos = len(conf_data[conf_data == 2])
        neu = len(conf_data[conf_data == 1])
        neg = len(conf_data[conf_data == 0])
        
        index = (pos - neg)/(pos + neu + neg)
        index_list.append(index)
        
    data_ECB_full = pd.DataFrame({'date': sorted(set(ECB_data['date'])), 'index': index_list})
    
    return(data_ECB_full)

def transform_date(data):
    
    data.iloc[:,0] = pd.to_datetime(data.iloc[:,0])
    data.index = data.iloc[:,0]
    
    return(data)

def scale_ECB_index(ECB_index, date_inf):
    
    scaled_ECB_index = pd.DataFrame()
    prev_date = date_inf[0]
    prev_index = list(ECB_index.iloc[0])
    
    for idx, date in enumerate(date_inf):
        
        index = list(ECB_index[(ECB_index.index <= date) & (ECB_index.index > prev_date)]['index']) 
        #prev_date = date
        
        if index == []:
            
            index = prev_index
            
        if len(index) > 1:
            
            index = [sum(index)/len(index)]
            
        else:
            
            index = index
            
        scaled_ECB_index = scaled_ECB_index.append({"date": date, "index": index}, ignore_index=True)
        prev_date = date
        prev_index = index
    
    scaled_ECB_index['index'] = [ind[0] for ind in scaled_ECB_index['index']]
    
    return(scaled_ECB_index)

def transform_quantiles(inf_exp_inc_rap,
    inf_exp_inc_same,
    inf_exp_inc_slow,
    inf_exp_same,
    inf_exp_fall,
    inf_per_inc_rap,
    inf_per_inc_same,
    inf_per_inc_slow,
    inf_per_same,
    inf_per_fall,
    inf_exp_miss, 
    inf_per_miss):

    P1 = inf_exp_inc_rap.iloc[:,1]/100/(1- (inf_exp_miss.iloc[:,1]/100))
    P2 = inf_exp_inc_same.iloc[:,1]/100/(1- (inf_exp_miss.iloc[:,1]/100))
    P3 = inf_exp_inc_slow.iloc[:,1]/100/(1- (inf_exp_miss.iloc[:,1]/100))
    P4 = inf_exp_same.iloc[:,1]/100/(1- (inf_exp_miss.iloc[:,1]/100))
    P5 = inf_exp_fall.iloc[:,1]/100/(1- (inf_exp_miss.iloc[:,1]/100))
    
    P1_prime = inf_per_inc_rap.iloc[:,1]/100/(1- (inf_per_miss.iloc[:,1]/100))
    P2_prime = inf_per_inc_same.iloc[:,1]/100/(1- (inf_per_miss.iloc[:,1]/100))
    P3_prime = inf_per_inc_slow.iloc[:,1]/100/(1- (inf_per_miss.iloc[:,1]/100))
    P4_prime = inf_per_same.iloc[:,1]/100/(1- (inf_per_miss.iloc[:,1]/100))
    P5_prime = inf_per_fall.iloc[:,1]/100/(1- (inf_per_miss.iloc[:,1]/100))
    
    Z1 = scipy.stats.norm.ppf(list(1- P1), loc=0, scale=1)
    Z2 = scipy.stats.norm.ppf(list(1- P1 - P2), loc=0, scale=1)
    Z3 = scipy.stats.norm.ppf(list(1- P1 - P2 - P3), loc=0, scale=1)
    Z4 = scipy.stats.norm.ppf(list(P5), loc=0, scale=1)
    
    # 1-P1.iloc[:,1]/100-P2.iloc[:,1]/100-P3.iloc[:,1]/100 - P5.iloc[:,1]/100
    
    Z1_prime = scipy.stats.norm.ppf(list(1-P1_prime), loc=0, scale=1)
    Z2_prime = scipy.stats.norm.ppf(list(1-P1_prime-P2_prime), loc=0, scale=1)
    Z3_prime = scipy.stats.norm.ppf(list(1-P1_prime-P2_prime-P3_prime), loc=0, scale=1)
    Z4_prime = scipy.stats.norm.ppf(list(P5_prime), loc=0, scale=1)
    
    perc_weight = - (Z3_prime + Z4_prime)/(Z1_prime + Z2_prime - Z3_prime - Z4_prime)
    exp_weight = - (Z3 + Z4)/(Z1 + Z2 - Z3 - Z4)
    
    exp_weight = pd.Series(exp_weight).fillna(1).tolist()
    perc_weight = pd.Series(perc_weight).fillna(1).tolist()
    
    scale = np.array(perc_weight)*np.array(exp_weight)
    scale = pd.DataFrame({'date': inf_exp_inc_rap['TOT'], 'scale': scale, 'perc_weight': perc_weight, 'exp_weight': exp_weight})
    scale.reset_index(drop = True, inplace = True)

    return(scale)

def rolling_quant(inf_exp_inc_rap,
    inf_exp_inc_same,
    inf_exp_inc_slow,
    inf_exp_same,
    inf_exp_fall,
    inf_per_inc_rap,
    inf_per_inc_same,
    inf_per_inc_slow,
    inf_per_same,
    inf_per_fall,
    inf_exp_miss, 
    inf_per_miss,
    inflation_m, 
    years_roll):
    
    scale = transform_quantiles(inf_exp_inc_rap,
        inf_exp_inc_same,
        inf_exp_inc_slow,
        inf_exp_same,
        inf_exp_fall,
        inf_per_inc_rap,
        inf_per_inc_same,
        inf_per_inc_slow,
        inf_per_same,
        inf_per_fall,
        inf_exp_miss, 
        inf_per_miss)

    # Lahiri and Zhao (2014)
    w = years_roll*12
    scaling = pd.DataFrame()
    
    inflation_m.iloc[:,0] = pd.to_datetime(inflation_m.iloc[:,0])
    inflation_m.iloc[:,1] = pd.to_numeric(inflation_m.iloc[:,1])

    #for years_roll in range(1, 13):
        
    for date in scale['date'][w:]:
        
       end_t = scale[scale['date'] == date].index.values.astype(int)
       start_t = end_t - w
       
       window = scale[start_t[0]:end_t[0]]['perc_weight']
       
       date_inf_start = date - relativedelta(months=w-1, day = 1)
       
       inflation_past = inflation_m[(inflation_m.iloc[:,0] >= date_inf_start) & (inflation_m.iloc[:,0] <= date)]
       
       windows_sq_sum = sum(np.square(np.array(window)))
       window_inf_sum = sum(np.array(inflation_past.iloc[:,1])*np.array(window))
    
       lambda_t =  window_inf_sum/windows_sq_sum   
    
       scaling = scaling.append({'date': date, 'lambda': lambda_t}, ignore_index=True)

    scaling['German Inflation Expectations'] = np.array(scaling.iloc[:,1]) * np.array(scale['exp_weight'][w:])
    scaling['exp_weight'] = list(scale['exp_weight'][w:])
    scaling['perc_weight'] = list(scale['perc_weight'][w:])
    
    return(scaling)
    #MSE = np.mean((np.array(inflation_ger_m[476:705]['Unnamed: 3']) - np.array(list(scaling[167-w:396-w]['German Inflation Expectations'])))**2)