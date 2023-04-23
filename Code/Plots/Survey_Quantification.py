# -*- coding: utf-8 -*-
"""
Created on Sat Apr 22 14:56:00 2023

@author: Nutzer
"""

import pandas as pd
import numpy as np

from scipy.optimize import least_squares
from scipy.optimize import minimize


def recursive_mean(inflation_m):
# Initialize the recursive_mean column with zeros
    inflation_m['recursive_mean'] = 0.0
    
    def average(a):
        def helper(a, n):
            if n == 0:
                return a[0]
            else:
                return (a[n] + n * helper(a, n - 1)) / (n + 1)
    
        return helper(a, len(a) - 1)
    
    rec_mean = average(list(inflation_m['Inflation']))
    
    # Iterate through the DataFrame, updating the mean and storing it in 'recursive_mean' column
    for i in range(1, len(inflation_m)):
        previous_mean = inflation_m['recursive_mean'].iloc[i - 1]
        current_value = inflation_m['Inflation'].iloc[i]
        updated_mean = ((i * previous_mean) + current_value) / (i + 1)
        
        inflation_m['recursive_mean'].iloc[i] = updated_mean
        
    return(inflation_m, rec_mean)

def stm(initial_params, scaling, inflation_rollm_m, inflation_m):
        
    def stm_function(params, perc_weight, st):
        phi, phi_prime, gamma, c_threshold = params
        G = logistic_transition_function(st, gamma, c_threshold)
        return phi * perc_weight + phi_prime * G * perc_weight
    
    def logistic_transition_function(st, gamma, c_threshold):
        return (1 + np.exp(-gamma * (st - c_threshold))) ** -1
    
    def objective_function(params, perc_weight, st, pi_t):
        pi_t_hat = stm_function(params, perc_weight, st)
        return pi_t - pi_t_hat

    result = least_squares(objective_function, initial_params, 
                           args=(np.array(scaling['perc_weight']), 
                                 np.array(inflation_rollm_m['Inflation']), 
                                 np.array(inflation_m['Inflation'])))
    estimated_params = result.x

    stm_lam = stm_function(estimated_params, 
                           np.array(np.array(scaling['perc_weight'])), 
                           np.array(inflation_rollm_m['Inflation']))
    
    stm_lam_df = pd.DataFrame(stm_lam)
    stm_lam_df.index = inflation_m.index
    stm_lam_df['exp_inf_ls'] = np.array(scaling['exp_weight'])*np.array(stm_lam)

    def objective_function(params, perc_weight, st, pi_t):
        pi_t_hat = stm_function(params, perc_weight, st)
        return np.sum((pi_t - pi_t_hat) ** 2)

    result = minimize(objective_function, initial_params, 
                  args=(np.array(scaling['perc_weight']), 
                        np.array(inflation_rollm_m['Inflation']), 
                        np.array(inflation_m['Inflation'])), 
                        options={'gtol': 1e-6, 'maxiter': 5000})

    estimated_params = result.x

    stm_lam = stm_function(estimated_params, 
                           np.array(np.array(scaling['perc_weight'])), 
                           np.array((inflation_rollm_m['Inflation'])))
    
    stm_lam_df['exp_inf_min'] = np.array(scaling['exp_weight'])*np.array(stm_lam)
    
    return(stm_lam_df)




