# -*- coding: utf-8 -*-
"""
Created on Tue Apr 18 12:29:42 2023

@author: Nutzer
"""

import scipy
import pandas as pd
import numpy as np

from dateutil.relativedelta import relativedelta
from datetime import timedelta
from pandas.tseries.offsets import MonthEnd

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
    
    data.iloc[:,0] = pd.to_datetime(data.iloc[:,0]) + MonthEnd(0)
    data.index = data.iloc[:,0]
    
    return(data)

def scale_ECB_index(ECB_index, date_inf):
    
    scaled_ECB_index = pd.DataFrame()
    prev_date = date_inf[0]
    prev_index = list(ECB_index.iloc[0])
    
    for idx, date in enumerate(date_inf):
        
        index = list(ECB_index[(ECB_index.index <= date) & (ECB_index.index > prev_date)]['index']) 
        
        if index == []:
            index = prev_index
            
        if len(index) > 1:
            index = [sum(index)/len(index)]
        else:
            index = index
            
        new_row = pd.DataFrame([{"date": date, "index": index}])
        scaled_ECB_index = pd.concat([scaled_ECB_index, new_row], ignore_index=True)
        
        prev_date = date
        prev_index = index
    
    scaled_ECB_index['index'] = [ind[0] for ind in scaled_ECB_index['index']]
    
    return(scaled_ECB_index)

def transform_quantiles_V1(inflation_ger_m,
    inf_exp_inc_rap,
    inf_exp_inc_same,
    inf_exp_inc_slow,
    inf_exp_same,
    inf_exp_fall,
    inf_exp_miss, 
    inf_per_inc_rap,
    inf_per_inc_same,
    inf_per_inc_slow,
    inf_per_same,
    inf_per_fall,
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
    
    P5_prime = P5_prime.replace(0, 0.001)
    P4_prime = P4_prime.replace(0, 0.001)
    P3_prime = P3_prime.replace(0, 0.001)
    P2_prime = P2_prime.replace(0, 0.001)
    P1_prime = P1_prime.replace(0, 0.001)
    
    P5 = P5.replace(0, 0.001)
    P4 = P4.replace(0, 0.001)
    P3 = P3.replace(0, 0.001)
    P2 = P2.replace(0, 0.001)
    P1 = P1.replace(0, 0.001)
    
    P_1_agg = P1_prime + P2_prime + P3_prime
    
    Z1 = scipy.stats.norm.ppf(list(1- P1), loc=0, scale=1)
    Z2 = scipy.stats.norm.ppf(list(1- P1 - P2), loc=0, scale=1)
    Z3 = scipy.stats.norm.ppf(list(1- P1 - P2 - P3), loc=0, scale=1)
    Z4 = scipy.stats.norm.ppf(list(P5), loc=0, scale=1)
    
    Z1_prime = scipy.stats.norm.ppf(list(1-P1_prime), loc=0, scale=1)
    Z2_prime = scipy.stats.norm.ppf(list(1-P1_prime-P2_prime), loc=0, scale=1)
    Z3_prime = scipy.stats.norm.ppf(list(1-P1_prime-P2_prime-P3_prime), loc=0, scale=1)
    Z4_prime = scipy.stats.norm.ppf(list(P5_prime), loc=0, scale=1)
    
    perc_weight = - (Z3_prime + Z4_prime)/(Z1_prime + Z2_prime - Z3_prime - Z4_prime)
    exp_weight = - (Z3 + Z4)/(Z1 + Z2 - Z3 - Z4)
    
    exp_weight = pd.Series(exp_weight).fillna(1).tolist()
    perc_weight = pd.Series(perc_weight).fillna(1).tolist()

    scale = pd.DataFrame({'date': inf_exp_inc_rap['date'], 'perc_weight': perc_weight, 'exp_weight': exp_weight})
    
    a = scipy.stats.norm.ppf(list(P5_prime), loc=0, scale=1)
    b = scipy.stats.norm.ppf(list(1-P_1_agg), loc=0, scale=1)
    
    # 3-month rolling average inflation as scaling factor
    inflation_ger_m_roll = inflation_ger_m['Inflation'].rolling(window=3).mean()[3:]
    
    # factor for survey questions
    survey = (a + b)/(a - b)
    
    # Replace -inf values with max_value
    max_value = np.max(survey[np.isfinite(survey)])
    survey[survey == -np.inf] = max_value
    
    # CP method
    limen_abs = np.nansum(inflation_ger_m['Inflation'])/np.nansum(survey)
    delta_y = limen_abs * survey
    perc_inf = delta_y + inflation_ger_m_roll
    
    perc_inf = pd.DataFrame({'date' : perc_inf.index, 'CP_perc_inf': perc_inf})
    
    scale.reset_index(drop = True, inplace = True)

    return(scale, perc_inf)

def transform_quantiles_V2(inflation_ger_m,
    inf_exp_inc_rap,
    inf_exp_inc_same,
    inf_exp_inc_slow,
    inf_exp_same,
    inf_exp_fall,
    inf_exp_miss, 
    inf_per_inc_rap,
    inf_per_inc_same,
    inf_per_inc_slow,
    inf_per_same,
    inf_per_fall,
    inf_per_miss):
    
    # Following Hirsch et al. 2023
    
    P1 = inf_exp_inc_rap.iloc[:,1]/100/(1- (inf_exp_miss.iloc[:,1]/100))
    P2 = inf_exp_inc_same.iloc[:,1]/100/(1- (inf_exp_miss.iloc[:,1]/100))
    P3 = inf_exp_inc_slow.iloc[:,1]/100/(1- (inf_exp_miss.iloc[:,1]/100))
    P4 = inf_exp_same.iloc[:,1]/100/(1- (inf_exp_miss.iloc[:,1]/100))
    P5 = inf_exp_fall.iloc[:,1]/100/(1- (inf_exp_miss.iloc[:,1]/100))
    
    P1_prime = inf_per_inc_rap.iloc[:,1]/100
    P2_prime = inf_per_inc_same.iloc[:,1]/100
    P3_prime = inf_per_inc_slow.iloc[:,1]/100
    P4_prime = inf_per_same.iloc[:,1]/100
    P5_prime = inf_per_fall.iloc[:,1]/100
    P6_prime = inf_per_miss.iloc[:,1]/100
    
    P5_prime = P5_prime.replace(0, 0.001)
    P4_prime = P4_prime.replace(0, 0.001)
    P3_prime = P3_prime.replace(0, 0.001)
    P2_prime = P2_prime.replace(0, 0.001)
    P1_prime = P1_prime.replace(0, 0.001)
    
    P5 = P5.replace(0, 0.001)
    P4 = P4.replace(0, 0.001)
    P3 = P3.replace(0, 0.001)
    P2 = P2.replace(0, 0.001)
    P1 = P1.replace(0, 0.001)
    
    a = scipy.stats.norm.ppf(list(P5_prime), loc=0, scale=1)
    b = scipy.stats.norm.ppf(list(P5_prime + P6_prime), loc=0, scale=1)
    c = scipy.stats.norm.ppf(list(P4_prime + P5_prime + P6_prime), loc=0, scale=1)
    d = scipy.stats.norm.ppf(list(P4_prime + P5_prime + P6_prime + P3_prime), loc=0, scale=1)
    
    Z1 = scipy.stats.norm.ppf(list(1- P1), loc=0, scale=1)
    Z2 = scipy.stats.norm.ppf(list(1- P1 - P2), loc=0, scale=1)
    Z3 = scipy.stats.norm.ppf(list(1- P1 - P2 - P3), loc=0, scale=1)
    Z4 = scipy.stats.norm.ppf(list(P5), loc=0, scale=1)
    
    perc_weight = - (a + b)/(c + d - a - b)
    exp_weight = - (Z3 + Z4)/(Z1 + Z2 - Z3 - Z4)
    
    exp_weight = pd.Series(exp_weight).fillna(1).tolist()
    perc_weight = pd.Series(perc_weight).fillna(1).tolist()

    scale = pd.DataFrame({'date': inf_exp_inc_rap['date'], 'perc_weight': perc_weight, 'exp_weight': exp_weight})
    
    # 3-month rolling average inflation as scaling factor
    inflation_ger_m_roll = inflation_ger_m['Inflation'].rolling(window=3).mean()[3:]
    
    perc_inf =  inflation_ger_m_roll*perc_weight
    
    perc_inf = pd.DataFrame({'date' : perc_inf.index, 'CP_perc_inf': perc_inf})
    
    scale.reset_index(drop = True, inplace = True)

    return(scale, perc_inf)

def rolling_quant(
    inf_exp_inc_rap,
    inf_exp_inc_same,
    inf_exp_inc_slow,
    inf_exp_same,
    inf_exp_fall,
    inf_exp_miss, 
    inf_per_inc_rap,
    inf_per_inc_same,
    inf_per_inc_slow,
    inf_per_same,
    inf_per_fall,
    inf_per_miss,
    inflation_ger_m, 
    years_roll = 5):
    
    scale,_ = transform_quantiles(
        inflation_ger_m,
        inf_exp_inc_rap,
        inf_exp_inc_same,
        inf_exp_inc_slow,
        inf_exp_same,
        inf_exp_fall,
        inf_exp_miss,
        inf_per_inc_rap,
        inf_per_inc_same,
        inf_per_inc_slow,
        inf_per_same,
        inf_per_fall,
        inf_per_miss)
    
    inflation_ger_m.iloc[:,0] = pd.to_datetime(inflation_ger_m.iloc[:,0])
    inflation_ger_m.iloc[:,1] = pd.to_numeric(inflation_ger_m.iloc[:,1])
    
    inflation_ger_m = inflation_ger_m[(inflation_ger_m.iloc[:,0] >= scale['date'][0]) & (inflation_ger_m.iloc[:,0] <= (scale['date'][len(scale)-1]+ timedelta(days=1)))]
        
    # Lahiri and Zhao (2014)
    
    w = years_roll*12
    scaling = pd.DataFrame()
    
    for date in scale['date'][w:]:
        
        end_t = scale[scale['date'] == date].index.values.astype(int)
        start_t = end_t - w
        
        window = scale[start_t[0]:end_t[0]]['perc_weight']
        
        date_inf_start = date - relativedelta(months=w-1, day = 1)
        
        inflation_past = inflation_ger_m[(inflation_ger_m.iloc[:,0] >= date_inf_start) & (inflation_ger_m.iloc[:,0] <= date)]
        
        windows_sq_sum = sum(np.square(np.array(window)))
        window_inf_sum = sum(np.array(inflation_past.iloc[:,1])*np.array(window))
    
        lambda_t =  window_inf_sum/windows_sq_sum   
        
        new_row = pd.DataFrame([{'date': date, 'lambda': lambda_t}])
        scaling = pd.concat([scaling, new_row], ignore_index=True)
    
    scaling['German Inflation Expectations'] = np.array(scaling.iloc[:,1]) * np.array(scale['exp_weight'][w:])
    scaling['exp_weight'] = list(scale['exp_weight'][w:])
    scaling['perc_weight'] = list(scale['perc_weight'][w:])                        
    
    return(scaling)
