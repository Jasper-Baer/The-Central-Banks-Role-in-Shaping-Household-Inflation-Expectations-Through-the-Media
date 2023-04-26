# -*- coding: utf-8 -*-
"""
Created on Mon Dec 19 23:30:12 2022

@author: Nutzer
"""

import pandas as pd
import matplotlib.pyplot as plt

dates_q = pd.date_range('10/1/1998', '10/1/2022', freq = 'Q').tolist()

infl_exps = []
end_months = ['Dec', 'Mar', 'Jun', 'Sep']

for year in range(1999,2023):
    
    for quarter in range(1,5):

        infl_exp = pd.read_csv(r"D:\\Studium\\PhD\\Single Author\\Data\\ECB\\Inflation Expectations\\" + str(year) + "Q" + str(quarter) + ".csv")
        
        infl_exp_de = list(infl_exp[infl_exp.iloc[:,0] == 'CORE INFLATION EXPECTATIONS; YEAR-ON-YEAR CHANGE IN CORE'].index)[0]-1
        
        infl_exp = infl_exp.iloc[1:infl_exp_de,]
        infl_exp.dropna(inplace = True, subset = ['Unnamed: 2'])
        
        if quarter == 1:
            
            idx = 0
            
        else:
            
            idx = 1
        
        infl_exp = infl_exp[infl_exp.iloc[:,0] == str(year+idx) + end_months[quarter-1]]
        
        infl_exp.iloc[:,2] = infl_exp.iloc[:,2].astype(float)
        infl_exp = sum(infl_exp.iloc[:,2])/len(infl_exp)
        infl_exps.append(infl_exp)
        
inflation_expectations = pd.DataFrame({'Inflation Expectations': infl_exps})
inflation_expectations.index = dates_q

plt.plot(inflation_expectations[:-12])
plt.show()

#inflation_expectations.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\Infl_Exp.xlsx')