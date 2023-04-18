# -*- coding: utf-8 -*-
"""
Created on Tue Apr 18 12:29:42 2023

@author: Nutzer
"""

import scipy
import pandas as pd
import numpy as np

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

def rolling_quant(ger_inf_exp_inc_rap, ger_inf_exp_inc_same, ger_inf_exp_inc_slow, ger_inf_exp_same, ger_inf_exp_fall, 
                  ger_inf_per_inc_rap, ger_inf_per_inc_same, ger_inf_per_inc_slow, ger_inf_per_same, ger_inf_per_fall,
                  inflation_ger_m):
    
    P1 = ger_inf_exp_inc_rap
    P2 = ger_inf_exp_inc_same
    P3 = ger_inf_exp_inc_slow
    P4 = ger_inf_exp_same
    P5 = ger_inf_exp_fall

    P1_prime = ger_inf_per_inc_rap
    P2_prime = ger_inf_per_inc_same
    P3_prime = ger_inf_per_inc_slow
    P4_prime = ger_inf_per_same
    P5_prime = ger_inf_per_fall

    A = ger_inf_exp_fall
    B = ger_inf_exp_same
    C = ger_inf_exp_inc_slow
    D = ger_inf_exp_inc_same

    A_prime = ger_inf_per_fall
    B_prime = ger_inf_per_same
    C_prime = ger_inf_per_inc_slow
    D_prime = ger_inf_per_inc_same

    Z1 = scipy.stats.norm.ppf(list(1-P1.iloc[:,1]/100), loc=0, scale=1)
    Z2 = scipy.stats.norm.ppf(list(1-P1.iloc[:,1]/100-P2.iloc[:,1]/100), loc=0, scale=1)
    Z3 = scipy.stats.norm.ppf(list(1-P1.iloc[:,1]/100-P2.iloc[:,1]/100-P3.iloc[:,1]/100), loc=0, scale=1)
    Z4 = scipy.stats.norm.ppf(list(P5.iloc[:,1]/100), loc=0, scale=1)

    Z1_prime = scipy.stats.norm.ppf(list(1-P1_prime.iloc[:,1]/100), loc=0, scale=1)
    Z2_prime = scipy.stats.norm.ppf(list(1-P1_prime.iloc[:,1]/100-P2_prime.iloc[:,1]/100), loc=0, scale=1)
    Z3_prime = scipy.stats.norm.ppf(list(1-P1_prime.iloc[:,1]/100-P2_prime.iloc[:,1]/100-P3_prime.iloc[:,1]/100), loc=0, scale=1)
    Z4_prime = scipy.stats.norm.ppf(list(P5_prime.iloc[:,1]/100), loc=0, scale=1)

    ger_scale = (- Z3_prime - Z4_prime)/(Z1_prime + Z2_prime - Z3_prime - Z4_prime)*(- Z3 - Z4)/(Z1 + Z2 - Z3 - Z4)

    a = scipy.stats.logistic.ppf(list(A.iloc[:,1]/100), loc=0, scale=1)
    b = scipy.stats.logistic.ppf(list(A.iloc[:,1]/100 + B.iloc[:,1]/100), loc=0, scale=1)
    c = scipy.stats.logistic.ppf(list((A.iloc[:,1]/100 + B.iloc[:,1]/100 + C.iloc[:,1]/100)), loc=0, scale=1)
    d = scipy.stats.logistic.ppf(list((A.iloc[:,1]/100 + B.iloc[:,1]/100 + C.iloc[:,1]/100 + D.iloc[:,1]/100)), loc=0, scale=1)

    a_prime = scipy.stats.logistic.ppf(list(A_prime.iloc[:,1]/100), loc=0, scale=1)
    b_prime = scipy.stats.logistic.ppf(list(A_prime.iloc[:,1]/100 + B_prime.iloc[:,1]/100), loc=0, scale=1)
    c_prime = scipy.stats.logistic.ppf(list((A_prime.iloc[:,1]/100 + B_prime.iloc[:,1]/100 + C_prime.iloc[:,1]/100)), loc=0, scale=1)
    d_prime = scipy.stats.logistic.ppf(list((A_prime.iloc[:,1]/100 + B_prime.iloc[:,1]/100 + C_prime.iloc[:,1]/100 + D_prime.iloc[:,1]/100)), loc=0, scale=1)

    #ger_scale = (a_prime+b_prime)/(a_prime+b_prime-c_prime-d_prime)*(a+b)/(a+b-c-d)
    ger_scale_exp = (a+b)/(a+b-c-d)
    ger_scale_exp = pd.Series(ger_scale_exp).fillna(1).tolist()
    ger_scale_exp = pd.DataFrame(ger_scale_exp)
    ger_scale_exp['date'] = ger_inf_exp_fall['TOT']
    ger_scale_exp.reset_index(drop = True, inplace = True)

    ger_scale = (a_prime+b_prime)/(a_prime+b_prime-c_prime-d_prime)
    ger_scale = pd.Series(ger_scale).fillna(1).tolist()
    ger_scale = pd.DataFrame(ger_scale)
    ger_scale['date'] = ger_inf_exp_fall['TOT']
    ger_scale.reset_index(drop = True, inplace = True)

    # Lahiri and Zhao (2014)

    for years_roll in range(1, 13):

        years_roll = 9
        
        scaling = pd.DataFrame()
        w = years_roll*12
        
        for date in ger_scale['date'][w:]:
            
           end_t = ger_scale[ger_scale['date'] == date].index.values.astype(int)
           start_t = end_t - w
           
           window = ger_scale[start_t[0]:end_t[0]].iloc[:,0]
           
           windows_sq_sum = sum(np.square(np.array(window)))
           window_inf_sum = sum(np.array(inflation_ger_m[297:-3][start_t[0]:end_t[0]].iloc[:,1])*np.array(window))
        
           lambda_t =  window_inf_sum/windows_sq_sum   
        
           scaling = scaling.append({'date': date, 'lambda': lambda_t}, ignore_index=True)

        scaling['German Inflation Expectations'] = np.array(scaling.iloc[:,1]) * np.array(ger_scale_exp[w:].iloc[:,0])
        
        MSE = np.mean((np.array(inflation_ger_m[476:705]['Unnamed: 3']) - np.array(list(scaling[167-w:396-w]['German Inflation Expectations'])))**2)
        
    return(scaling)