# -*- coding: utf-8 -*-
"""
Created on Tue Dec 20 17:11:31 2022

@author: jbaer
"""

import pandas as pd
import matplotlib.pyplot as plt
import os
from sklearn import preprocessing
import numpy as np
import scipy

PATH = r"D:\Studium\PhD\Github\Single-Author\Code\Unsupervised"

os.chdir(PATH)

from PR_index_supp import inf_senti_index

##############################################################################

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
        
##############################################################################
# Inflation
##############################################################################

PATH = r'D:\Studium\PhD\Github\Single-Author\Data\Regression'

#inflation_ger_q = pd.read_excel(PATH + '\Consumer Price IndexAll Items Total Total for Germany.xls')[10:]
inflation_ger_qoq = pd.read_excel(PATH + '\Germany_Inflation_qoq.xls')[10:]
#data_inf = pd.read_excel(PATH + '\Eurozone_CPI.xls')[10:]
ecb_dfr = pd.read_excel(PATH + '\ECBDFR.xls')[10:]

fred_monthly = pd.read_excel(PATH + '\Fred_data_monthly.xlsx')[10:]
ip_ger_m = fred_monthly.iloc[:,0:2]
ip_ea_m = fred_monthly.iloc[:,6:8]
inflation_ger_m = fred_monthly.iloc[:,2:4]
inflation_ea_m = fred_monthly.iloc[:,4:6]

# Datenmenge zu klein
# ea_household_inf_exp = pd.read_csv(PATH + '\ecb.CES_data_2022_monthly.csv')
# ea_household_inf_exp = ea_household_inf_exp[ea_household_inf_exp['a0020'] == 'DE']


# data_ECB_sents_inf = pd.read_excel('D:\Studium\PhD\Single Author\Data\ECB\press_sents_full_index_labeled_inf.xlsx')
# data_ECB_sents_inf = ECB_index(data_ECB_sents_inf)

# fig, ax1 = plt.subplots()

# ax2 = ax1.twinx()
# ax1.plot(data_ECB_sents_inf['date'][180:220], data_ECB_sents_inf['index'][180:220], color = "blue")
# ax2.plot(dire_senti[270:].iloc[:,0], dire_senti[270:].iloc[:,1]*-1, color = "red")

# fig.legend(loc = 'lower left')

# plt.show()

data_ECB_index_inf1 = pd.read_csv(PATH + '\PR_ecb_inflation_results.csv')[['date', 'index']]
data_ECB_index_mon1 = pd.read_csv(PATH + '\PR_ecb_monetary_results.csv')[['date', 'index']]
data_ECB_index_ec1 = pd.read_csv(PATH + '\PR_ecb_outlook_results.csv')[['date', 'index']]

data_ECB_index_inf2 = pd.read_csv(PATH + '\ECB_inf_own_trainingsset_labels.csv')[['date', 'index']]
data_ECB_index_mon2 = pd.read_csv(PATH + '\ECB_monetary_own_trainingsset_labels.csv')[['date', 'index']]
data_ECB_index_ec2 = pd.read_csv(PATH + '\ECB_economic_own_trainingsset_labels.csv')[['date', 'index']]

data_ECB_index_inf = data_ECB_index_inf1
data_ECB_index_mon = data_ECB_index_mon1
data_ECB_index_ec = data_ECB_index_ec1

data_inf_exp = pd.read_excel(PATH + '\Infl_Exp.xlsx', index_col = 0)
ger_oecd_inf_exp = pd.read_csv(PATH + '\OECD_INF_FOR.csv', index_col = 0)
ger_inf_exp = pd.read_excel(PATH + "\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name = "TOT")[["TOT", "CONS.DE.TOT.6.B.M"]]

dire_senti = pd.read_excel(PATH + '\\news_index_dire_senti.xlsx')
dire_senti = pd.read_excel(PATH + '\\news_index_dire_senti_lex.xlsx')
count_rel = pd.read_excel(PATH + '\\count_rel.xlsx')

###############################################################################

ea_inf_exp_fall = pd.read_excel(PATH + "\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name = "TOT")[["TOT", "CONS.EA.TOT.6.MM.M"]]
ea_inf_exp_same = pd.read_excel(PATH + "\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name = "TOT")[["TOT", "CONS.EA.TOT.6.M.M"]]
ea_inf_exp_inc_slow = pd.read_excel(PATH + "\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name = "TOT")[["TOT", "CONS.EA.TOT.6.E.M"]]
ea_inf_exp_inc_same = pd.read_excel(PATH + "\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name = "TOT")[["TOT", "CONS.EA.TOT.6.P.M"]]


ger_inf_exp_fall = pd.read_excel(PATH + "\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name = "TOT")[["TOT", "CONS.DE.TOT.6.MM.M"]]
ger_inf_exp_same = pd.read_excel(PATH + "\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name = "TOT")[["TOT", "CONS.DE.TOT.6.M.M"]]
ger_inf_exp_inc_slow = pd.read_excel(PATH + "\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name = "TOT")[["TOT", "CONS.DE.TOT.6.E.M"]]
ger_inf_exp_inc_same = pd.read_excel(PATH + "\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name = "TOT")[["TOT", "CONS.DE.TOT.6.P.M"]]
ger_inf_exp_inc_rap = pd.read_excel(PATH + "\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name = "TOT")[["TOT", "CONS.DE.TOT.6.PP.M"]]
ger_inf_exp_miss = pd.read_excel(PATH + "\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name = "TOT")[["TOT", "CONS.DE.TOT.6.N.M"]]

ger_inf_exp_balanced = pd.read_excel(PATH + "\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name = "TOT")[["TOT", "CONS.DE.TOT.6.B.M"]]

ger_inf_per_fall = pd.read_excel(PATH + "\consumer_subsectors_nsa_q5_nace2.xlsx", sheet_name = "TOT")[["TOT", "CONS.DE.TOT.5.MM.M"]]
ger_inf_per_same = pd.read_excel(PATH + "\consumer_subsectors_nsa_q5_nace2.xlsx", sheet_name = "TOT")[["TOT", "CONS.DE.TOT.5.M.M"]]
ger_inf_per_inc_slow = pd.read_excel(PATH + "\consumer_subsectors_nsa_q5_nace2.xlsx", sheet_name = "TOT")[["TOT", "CONS.DE.TOT.5.E.M"]]
ger_inf_per_inc_same = pd.read_excel(PATH + "\consumer_subsectors_nsa_q5_nace2.xlsx", sheet_name = "TOT")[["TOT", "CONS.DE.TOT.5.P.M"]]
ger_inf_per_inc_rap = pd.read_excel(PATH + "\consumer_subsectors_nsa_q5_nace2.xlsx", sheet_name = "TOT")[["TOT", "CONS.DE.TOT.5.PP.M"]]
ger_inf_per_miss = pd.read_excel(PATH + "\consumer_subsectors_nsa_q5_nace2.xlsx", sheet_name = "TOT")[["TOT", "CONS.DE.TOT.5.N.M"]]

# Inflation expectations in the Euro area: are consumers rational?

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

# A = ea_inf_exp_fall
# B = ea_inf_exp_same
# C = ea_inf_exp_inc_slow
# D = ea_inf_exp_inc_same

# all_q = 1 - ger_inf_exp_miss.iloc[:,1]/100

# P1.iloc[:,1] = P1.iloc[:,1]/all_q
# P2.iloc[:,1] = P2.iloc[:,1]/all_q
# P3.iloc[:,1] = P3.iloc[:,1]/all_q
# P4.iloc[:,1] = P4.iloc[:,1]/all_q
# P5.iloc[:,1] = P5.iloc[:,1]/all_q

# P1.iloc[:,1] + P2.iloc[:,1] + P3.iloc[:,1] + P4.iloc[:,1] + P5.iloc[:,1] 

# A.iloc[:,1] = A.iloc[:,1]/all_q
# B.iloc[:,1] = B.iloc[:,1]/all_q
# C.iloc[:,1] = C.iloc[:,1]/all_q
# D.iloc[:,1] = D.iloc[:,1]/all_q

# Als Function und Paper dazuschreiben

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

ger_scale_roll = np.array(ger_scale.iloc[:,0])/np.square(np.array(ger_scale.iloc[:,0]))
ger_scale_roll_k = np.array(ger_scale_roll)*np.array(inflation_ger_m[297:-3].iloc[:,1])
ger_scale_roll_k = pd.DataFrame(ger_scale_roll_k)
ger_scale_roll_k['date'] = ger_inf_exp_fall['TOT']
ger_scale_roll_k.reset_index(drop = True, inplace = True)

# Lahiri and Zhao (2014)

scaling = pd.DataFrame()
w = 9*12

for date in ger_scale['date'][w:]:
    
   end_t = ger_scale[ger_scale['date'] == date].index.values.astype(int)
   start_t = end_t - w
   
   window = ger_scale[start_t[0]:end_t[0]].iloc[:,0]
   
   windows_sq_sum = sum(np.square(np.array(window)))
   window_inf_sum = sum(np.array(inflation_ger_m[297:-3][start_t[0]:end_t[0]].iloc[:,1])*np.array(window))

   lambda_t =  window_inf_sum/windows_sq_sum   

   scaling = scaling.append({'date': date, 'lambda': lambda_t}, ignore_index=True)

scaling['German Inflation Expectations'] = np.array(scaling.iloc[:,1]) * np.array(ger_scale_exp[w:].iloc[:,0])
#scaling.index = pd.date_range('1/1/1989', '31/7/2023', freq = 'M').tolist()
#scaling.index = pd.date_range('1/1/1994', '31/7/2022', freq = 'M').tolist()

inflation_ger_m = transform_date(inflation_ger_m)
#hist_ger_inflation_m = inflation_ger_m[428:657]
hist_ger_inflation_m = inflation_ger_m[367:704]
hist_ger_inflation_rollm_m = hist_ger_inflation_m.rolling(108).mean()[108:]
hist_ger_inflation_m.iloc[:,1] = pd.to_numeric(hist_ger_inflation_m.iloc[:,1])
mean_inflation = inflation_ger_m[475:704].mean()
inflation_ger_m_past = inflation_ger_m[475:704]
inflation_ger_m_past.iloc[:,1] = pd.to_numeric(inflation_ger_m_past.iloc[:,1])
inflation_ger_m = inflation_ger_m[476:705]
inflation_ger_m.iloc[:,1] = pd.to_numeric(inflation_ger_m.iloc[:,1])

# Wrong timeframe!
# Extend_inf = pd.DataFrame()
# Extend_inf['historical german inflation'] = list(hist_ger_inflation_m[108:].iloc[1:,1])
# Extend_inf['german inflation'] = list(inflation_ger_m.iloc[1:,1])

# Extend_inf.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Extend_inf.xlsx')

ip_ger_m = transform_date(ip_ger_m)
ip_ger_m = ip_ger_m[476:705]
ip_ger_m.iloc[:,1] = pd.to_numeric(ip_ger_m.iloc[:,1])

ip_ea_m = transform_date(ip_ea_m)
ip_ea_m = ip_ea_m[278:507]
ip_ea_m.iloc[:,1] = pd.to_numeric(ip_ea_m.iloc[:,1])

inflation_ea_m = transform_date(inflation_ea_m)
inflation_ea_m_past = inflation_ea_m[31:260]
inflation_ea_m_past.iloc[:,1] = pd.to_numeric(inflation_ea_m_past.iloc[:,1])
inflation_ea_m = inflation_ea_m[32:261]
inflation_ea_m.iloc[:,1] = pd.to_numeric(inflation_ea_m.iloc[:,1])

date_inf = list(inflation_ea_m.iloc[:,0])

inflation_ger_qoq = transform_date(inflation_ger_qoq)
inflation_ger_qoq = inflation_ger_qoq[:77]

ger_oecd_inf_exp = ger_oecd_inf_exp[ger_oecd_inf_exp.index == "DEU"]
ger_oecd_inf_exp = ger_oecd_inf_exp[1:]
ger_oecd_inf_exp.index = pd.date_range('31/12/1999', '1/1/2019', freq = 'Q').tolist()
ger_oecd_inf_exp = ger_oecd_inf_exp['Value']
ger_oecd_inf_exp_m = ger_oecd_inf_exp.groupby(pd.Grouper(freq="M")).mean().fillna(method = 'ffill')

data_inf_exp  = data_inf_exp[3:80]
data_inf_exp_m = data_inf_exp['Inflation Expectations'].groupby(pd.Grouper(freq="M")).mean().fillna(method = 'ffill')
#data_inf_exp_m = data_inf_exp['Inflation Expectations Next Year'].groupby(pd.Grouper(freq="M")).mean().fillna(method = 'ffill')

ecb_dfr = transform_date(ecb_dfr)
ecb_dfr = ecb_dfr.groupby(pd.Grouper(freq="M")).mean()
ecb_dfr = ecb_dfr[:229]

dire_senti.iloc[:,0] = pd.to_datetime(dire_senti.iloc[:,0])
dire_senti = dire_senti[107:]

dire_senti.index = dire_senti.iloc[:,0]
#dire_senti.iloc[:,0] = preprocessing.scale(np.float32(dire_senti))
dire_senti_q = dire_senti.groupby(pd.Grouper(freq="Q")).mean()
dire_senti_m = dire_senti.groupby(pd.Grouper(freq="M")).mean()

count_rel.iloc[:,0] = pd.to_datetime(count_rel.iloc[:,0])
count_rel = count_rel[107:]

count_rel.index = count_rel.iloc[:,0]
#count_rel.iloc[:,0] = preprocessing.scale(np.float32(count_rel))
count_rel_q = count_rel.groupby(pd.Grouper(freq="Q")).mean()
count_rel_m = count_rel.groupby(pd.Grouper(freq="M")).mean()

# ger_inf_exp.index = ger_inf_exp.iloc[:,0]
# ger_inf_exp = ger_inf_exp[179:408]
# #ger_inf_exp.iloc[:,0] = preprocessing.scale(np.float32(ger_inf_exp))
# ger_inf_exp_q = ger_inf_exp.groupby(pd.Grouper(freq="Q")).mean()
# ger_inf_exp_m = ger_inf_exp.groupby(pd.Grouper(freq="M")).mean()

# ger_inf_exp_m.iloc[:,0] = np.array(ger_scale.iloc[:,0])*np.array(inflation_ger_m_past.iloc[:,1])

# ea_inf_exp = transform_date(ea_inf_exp)
# ea_inf_exp = ea_inf_exp[179:408]
# #ea_inf_exp.iloc[:,0] = preprocessing.scale(np.float32(ea_inf_exp))
# ea_inf_exp_q = ea_inf_exp.groupby(pd.Grouper(freq="Q")).mean()
# ea_inf_exp_m = ea_inf_exp.groupby(pd.Grouper(freq="M")).mean()

# ea_inf_exp_m.iloc[:,0] = np.array(scale.iloc[:,0])*np.array(inflation_ea_m_past.iloc[:,1])

# plt.plot(ea_inf_exp_m)
# plt.plot(inflation_ea_m.iloc[:,0], inflation_ea_m.iloc[:,1])
# plt.show()

# data_ECB_index_inf = ECB_index(data_ECB_sents_inf)
# data_ECB_index_inf.set_index('date', inplace=True)
# data_ECB_index_inf = data_ECB_index_inf[18:232]
# #data_ECB_index_inf.iloc[:,0] = preprocessing.scale(np.float32(data_ECB_index_inf))
# data_ECB_index_inf_q = pd.DataFrame(data_ECB_index_inf).groupby(pd.Grouper(freq="Q")).mean()
# data_ECB_index_inf_m = pd.DataFrame(data_ECB_index_inf).groupby(pd.Grouper(freq="M")).mean()

data_ECB_index_inf.set_index('date', inplace=True)
data_ECB_index_inf.index = pd.to_datetime(data_ECB_index_inf.index)
data_ECB_index_inf['index'] = pd.to_numeric(data_ECB_index_inf['index'])
data_ECB_index_inf = data_ECB_index_inf[:217]

###############################################################################
data_ECB_index_inf_m = scale_ECB_index(data_ECB_index_inf,date_inf)
###############################################################################

#data_ECB_index_inf2.iloc[:,0] = preprocessing.scale(np.float32(data_ECB_index_inf2))
#data_ECB_index_inf2_q = pd.DataFrame(data_ECB_index_inf2).groupby(pd.Grouper(freq="Q")).mean()
#data_ECB_index_inf2_m = pd.DataFrame(data_ECB_index_inf2).groupby(pd.Grouper(freq="M")).mean().fillna(method = 'ffill')

data_ECB_index_mon.set_index('date', inplace=True)
data_ECB_index_mon.index = pd.to_datetime(data_ECB_index_mon.index)
data_ECB_index_mon['index'] = pd.to_numeric(data_ECB_index_mon['index'])
data_ECB_index_mon = data_ECB_index_mon[:217]

###############################################################################
data_ECB_index_mon_m = scale_ECB_index(data_ECB_index_mon,date_inf)
###############################################################################

#data_ECB_index_mon2.iloc[:,0] = preprocessing.scale(np.float32(data_ECB_index_mon2))
#data_ECB_index_mon2_q = pd.DataFrame(data_ECB_index_mon2).groupby(pd.Grouper(freq="Q")).mean()
#data_ECB_index_mon2_m = pd.DataFrame(data_ECB_index_mon2).groupby(pd.Grouper(freq="M")).mean().fillna(method = 'ffill')

data_ECB_index_ec.set_index('date', inplace=True)
data_ECB_index_ec.index = pd.to_datetime(data_ECB_index_ec.index)
data_ECB_index_ec['index'] = pd.to_numeric(data_ECB_index_ec['index'])
data_ECB_index_ec = data_ECB_index_ec[:217]

###############################################################################
data_ECB_index_ec_m = scale_ECB_index(data_ECB_index_ec,date_inf)
###############################################################################

#data_ECB_index_mon2.iloc[:,0] = preprocessing.scale(np.float32(data_ECB_index_mon2))
#data_ECB_index_ec2_q = pd.DataFrame(data_ECB_index_ec2).groupby(pd.Grouper(freq="Q")).mean()
#data_ECB_index_ec2_m = pd.DataFrame(data_ECB_index_ec2).groupby(pd.Grouper(freq="M")).mean().fillna(method = 'ffill')

#data_inf = data_inf[36:113]
#data_inf.iloc[:,0] = pd.to_datetime(data_inf.iloc[:,0])

#ger_scale_exp = ger_scale_exp[178:-44]

# ea_relative_exp_gap_q = ea_inf_exp_q.iloc[:,0][1:78] - data_inf_exp.iloc[:,0][4:80]
# ea_abs_exp_gap_q = abs(ea_relative_exp_gap_q)

# ea_relative_exp_gap_m = ea_inf_exp_m.iloc[:,0] - list(inflation_ea_m.iloc[:,1])
# ea_abs_exp_gap_m = abs(ea_relative_exp_gap_m)

# cor = np.corrcoef(inflation_ger_m.iloc[60:,1], list(data_inf_exp_m)[60:])
# cor = np.corrcoef(inflation_ger_m.iloc[60:,1], scaling['German Inflation Expectations'][191:360])

# sum(np.square(inflation_ger_m.iloc[60:,1] - list(data_inf_exp_m)[60:]))
# sum(np.square(inflation_ger_m.iloc[60:,1] - list(scaling['German Inflation Expectations'][191:360])))

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(inflation_ger_m.iloc[:,0], inflation_ger_m.iloc[:,1], color = 'black', label = 'German Inflation')
ax2.plot(count_rel_m, color = 'grey', label = 'ECB Inflation Forecast')

fig.legend(loc = 'lower left')

plt.show()

plt.plot(inflation_ger_m.iloc[:,0], inflation_ger_m.iloc[:,1], color = 'black', label = 'German Inflation')
plt.plot(count_rel_m, color = 'grey', label = 'ECB Inflation Forecast')
plt.legend(loc = 'lower left', prop={'size': 6})
plt.show()

plt.plot(inflation_ger_m.iloc[:,0], inflation_ger_m.iloc[:,1], color = 'black', label = 'German Inflation')
plt.plot(data_inf_exp_m.index, list(data_inf_exp_m), color = 'grey', label = 'ECB Inflation Forecast')
plt.legend(loc = 'lower left', prop={'size': 6})
plt.show()

plt.plot(inflation_ger_m.iloc[:,0], inflation_ger_m.iloc[:,1], color = 'black', label = 'German Inflation')
plt.plot(scaling['date'][59:288], scaling['German Inflation Expectations'][59:288], color = "blue", label = 'rolling window adv. scaling')
plt.plot(data_inf_exp_m.index, list(data_inf_exp_m), color = 'grey', label = 'ECB Inflation Forecast')
plt.legend(loc = 'lower left', prop={'size': 6})
plt.show()

plt.plot(inflation_ger_m.iloc[:,0], inflation_ger_m.iloc[:,1], color = 'black', label = 'German Inflation')
plt.plot(scaling.index[131:360], scaling['German Inflation Expectations'][131:360], color = "blue", label = 'rolling window adv. scaling')
plt.plot(data_inf_exp_m.index, list(data_inf_exp_m), color = 'grey', label = 'ECB Inflation Forecast')
plt.legend(loc = 'lower left', prop={'size': 6})
plt.show()

plt.plot(scaling.index[131:360], scaling['German Inflation Expectations'][131:360], color = "blue", label = 'rolling window adv. scaling')
plt.plot(data_inf_exp_m.index, list(data_inf_exp_m), color = 'grey', label = 'ECB Inflation Forecast')
plt.legend(loc = 'lower left', prop={'size': 6})
plt.show()

# 2010-08-31 00:00:00

plt.plot(scaling['date'][119:300], scaling['German Inflation Expectations'][119:300], color = "blue", label = 'rolling window adv. scaling')
plt.plot(data_inf_exp_m[48:], color = 'grey', label = 'ECB Inflation Forecast')
plt.legend(loc = 'lower left', prop={'size': 6})
plt.show()

plt.plot(scaling['date'][167:348], scaling['German Inflation Expectations'][167:348], color = "blue", label = 'rolling window adv. scaling')
plt.plot(data_inf_exp_m[48:], color = 'grey', label = 'ECB Inflation Forecast')
plt.legend(loc = 'lower left', prop={'size': 6})
plt.show()

plt.plot(scaling['date'][59:288], scaling['German Inflation Expectations'][59:288] - list(data_inf_exp_m))
plt.plot(scaling['date'][167:288], scaling['German Inflation Expectations'][167:288] - list(data_inf_exp_m[108:]))

plt.plot(scaling['date'][131:360], scaling['German Inflation Expectations'][131:360] - list(inflation_ger_m.iloc[:,1]))

plt.plot(scaling['date'][142:242], scaling['German Inflation Expectations'][142:242], color = "blue", label = 'rolling window adv. scaling')
plt.plot(ger_scale_exp['date'][:-130], (np.array(ger_scale_exp.iloc[:,0])*np.array(hist_ger_inflation_rollm_m.iloc[:,0]))[:-130], color = "red", label = 'rolling window simp. scaling')
plt.plot(ger_scale_exp['date'][:-130], (np.array(ger_scale_exp.iloc[:,0])*np.array(mean_inflation))[:-130], color = 'green', label = 'av. inflation scaling')
plt.plot(inflation_ger_m.iloc[:,0][:-130], inflation_ger_m.iloc[:,1][:-130], color = 'black', label = 'German Inflation')
plt.plot(data_inf_exp_m.index[4:-134], list(data_inf_exp_m.iloc[:,0])[4:-130], color = 'grey', label = 'ECB Inflation Forecast')
plt.legend(loc = 'lower left', prop={'size': 6})
plt.show()

plt.plot(scaling['date'][130:380], scaling['German Inflation Expectations'][130:380], color = "blue", label = 'rolling window adv. scaling')
#plt.plot(ger_scale_exp['date'], (np.array(ger_scale_exp.iloc[:,0])*np.array(hist_ger_inflation_rollm_m.iloc[:,0])), color = "red", label = 'rolling window simp. scaling')
#plt.plot(ger_scale_exp['date'], (np.array(ger_scale_exp.iloc[:,0])*np.array(mean_inflation)), color = 'green', label = 'av. inflation scaling')
#plt.plot(inflation_ger_m.iloc[:,0], inflation_ger_m.iloc[:,1], color = 'black', label = 'German Inflation')
plt.plot(data_inf_exp_m.index[:-4], list(data_inf_exp_m.iloc[:,0])[4:], color = 'grey', label = 'ECB Inflation Forecast')
plt.legend(loc = 'lower left', prop={'size': 6})
plt.show()

plt.plot(ger_scale.index[:-130], (np.array(ger_scale.iloc[:,0])*np.array(hist_ger_inflation_rollm_m.iloc[:,0]))[:-130], color = "red")
plt.plot(ger_oecd_inf_exp_m.index[:-130], (np.array(ger_oecd_inf_exp_m))[:-130], color = "blue" )
plt.show()

plt.plot(ger_scale.index, (np.array(ger_scale.iloc[:,0])*np.array(hist_ger_inflation_rollm_m.iloc[:,0])), color = "red")
plt.plot(ger_oecd_inf_exp_m.index, (np.array(ger_oecd_inf_exp_m)), color = "blue" )
plt.plot(inflation_ger_m.index[480:-40], (np.array(inflation_ger_m.iloc[:,1]))[480:-40], color = "black" )
plt.show()

plt.plot(ger_scale.index[:-130], (np.array(ger_scale.iloc[:,0])*np.array(mean_inflation))[:-130])

#scaling['date'][134:372], scaling['German Inflation Expectations'][134:372] - list(data_inf_exp_m.iloc[:,0])

# ger_relative_exp_gap_m = ger_inf_exp_m.iloc[:,0] - list(ger_oecd_inf_exp_m)
# ger_abs_exp_gap_m = abs(ger_relative_exp_gap_m)

ger_relative_exp_error_m = inflation_ger_m.iloc[:,1] - np.array(scaling['German Inflation Expectations'][59:288])
ger_abs_exp_error_m = abs(ger_relative_exp_error_m)

ger_relative_exp_gap_m = np.array(scaling['German Inflation Expectations'][71:300]) - data_inf_exp_m
ger_abslolute_exp_gap_m = abs(ger_relative_exp_gap_m)

# Regression_data_q = pd.DataFrame()
# #Regression_data_q['German Inflation Year-on-Year'] = inflation_ger_q.iloc[1:,1]
# Regression_data_q['German Inflation Quarter-on-Quarter'] = inflation_ger_qoq.iloc[1:,1]http://127.0.0.1:38879/graphics/plot_zoom_png?width=1200&height=900
# Regression_data_q['News Inflation Index'] = list(dire_senti_q.iloc[1:,0])
# Regression_data_q['News Inflation Count'] = list(count_rel_q.iloc[1:,0])
# Regression_data_q['German Household Inflation Expectations'] = list(ger_inf_exp_q.iloc[:,0])
# Regression_data_q['Eurozone Household Inflation Expectations'] = list(ea_inf_exp_q.iloc[:,0])
# Regression_data_q['ECB Inflation Index'] = list(data_ECB_index_inf2_q.iloc[:,0])
# Regression_data_q['ECB Monetary Index'] = list(data_ECB_index_mon2_q.iloc[:,0])
# Regression_data_q['ECB Economic Index'] = list(data_ECB_index_ec2_q.iloc[:,0])
# #Regression_data_q['Eurozone Inflation'] = list(data_inf.iloc[1:,1])
# Regression_data_q['Eurozone Inflation Professionell Forecasts'] = list(data_inf_exp.iloc[:,0][4:80])
# Regression_data_q['Absolute Expectations Gap'] = list(abs_exp_gap_q)
# Regression_data_q['Relative Expectations Gap'] = list(relative_exp_gap_q)

Regression_data_m = pd.DataFrame()
Regression_data_m['Eurozone Industrial Production'] = ip_ea_m.iloc[1:,1]
Regression_data_m['German Industrial Production'] = ip_ger_m.iloc[1:,1]
Regression_data_m['German Inflation Year-on-Year'] = inflation_ger_m.iloc[1:,1]
Regression_data_m['ECB DFR'] = list(ecb_dfr.iloc[:-1,1])
Regression_data_m['News Inflation Index'] = list(dire_senti_m.iloc[1:,0])
Regression_data_m['News Inflation Count'] = list(count_rel_m.iloc[1:,0])
# Falscher Index
Regression_data_m['German Household Inflation Expectations'] = list(scaling['German Inflation Expectations'][71:300])[1:]
#Regression_data_m['Eurozone Household Inflation Expectations'] = list(ea_inf_exp_m.iloc[1:,0])
Regression_data_m['ECB Inflation Index'] = list(data_ECB_index_inf_m.iloc[1:,1])
Regression_data_m['ECB Monetary Index'] = list(data_ECB_index_mon_m.iloc[1:,1])
Regression_data_m['ECB Economic Index'] = list(data_ECB_index_ec_m.iloc[1:,1])
Regression_data_m['Eurozone Inflation'] = list(inflation_ea_m.iloc[1:,1])
Regression_data_m['Eurozone Inflation Professionell Forecasts'] = list(data_inf_exp_m[1:])
# Regression_data_m['EA Absolute Expectations Gap'] = list(ea_abs_exp_gap_m[1:]) # FALSCH
# Regression_data_m['EA Relative Expectations Gap'] = list(ea_relative_exp_gap_m[1:]) # FALSCH
Regression_data_m['German Absolute Expectations Gap'] = list(ger_abslolute_exp_gap_m)[1:]
Regression_data_m['German Relative Expectations Gap'] = list(ger_relative_exp_gap_m)[1:]
Regression_data_m['German Household Inflation Expectations Balanced'] = list(ger_inf_exp_balanced.iloc[:,1][180:408])

#Regression_data_q.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\regression_data.xlsx')
Regression_data_m.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\regression_data_monthly.xlsx')

##############################################################################

fig, ax1 = plt.subplots()
#ax1.tick_params(axis='y', colors=color)

ax1.bar(list(count_rel.index), list(count_rel.iloc[:,0]), 50,color = 'grey', label = 'News Relative Count')

ax2 = ax1.twinx()
ax2.plot(dire_senti*-1, color = 'red')

#ax2.tick_params(axis='y', colors=color)

#fig.legend(loc = 'lower left')

plt.show()

data_ECB_index_inf2_m.iloc[:,1] -= np.mean(data_ECB_index_inf2_m.iloc[:,1])
data_ECB_index_inf2_m.iloc[:,1] /= np.std(data_ECB_index_inf2_m.iloc[:,1])

dire_senti.iloc[:,1] -= np.mean(dire_senti.iloc[:,1])
dire_senti.iloc[:,1] /= np.std(dire_senti.iloc[:,1])

ger_relative_exp_gap_m -= np.mean(ger_relative_exp_gap_m)
ger_relative_exp_gap_m /= np.std(ger_relative_exp_gap_m)

diff_inf_exp = dire_senti.iloc[:,1] - list(data_ECB_index_inf2_m.iloc[:,1])

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()

#ax1.plot(data_ECB_index_inf, color = 'green', label = 'ECB Inflation Index (BERT)')
#ax1.plot(data_ECB_index_inf2, color = 'red', label = 'ECB Inflation Index (Lex)')
#ax1.plot(dire_senti.index, dire_senti.iloc[:,1]*-1, color = 'cyan', label = 'News Inflation/Sentiment Index (BERT)')
ax1.plot(dire_senti.index, dire_senti.iloc[:,1]*-1, color = 'red', label = 'News Inflation/Sentiment Index (BERT)')
ax1.plot(diff_inf_exp.index, diff_inf_exp*-1, color = 'cyan', label = 'News ECB Diff Inflation')
#ax1.plot(ger_inf_exp_q, color = 'violet', label = 'German Household Inflation Expectations (one-year-ahead)')
#ax1.plot(ea_inf_exp_q, color = 'red', label = 'Eurozone Household Inflation Expectations (one-year-ahead)')
#ax2.plot(data_inf.iloc[:,0], data_inf.iloc[:,1], color = 'black', label = 'Eurozone Inflation')
#ax2.plot(inflation_ger_m.iloc[:,0], inflation_ger_m.iloc[:,1], color = 'yellow', label = 'German Inflation')
ax2.plot(ger_relative_exp_gap_m, color = 'blue', label = 'German Household Exp Gap')

fig.legend(loc = 'upper left')

plt.show()

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()

ax1.plot(data_ECB_index_inf, color = 'green', label = 'ECB Inflation Index (BERT)')
ax1.plot(dire_senti*-1, color = 'cyan', label = 'News Inflation/Sentiment Index (BERT)')
ax1.plot(ger_inf_exp_q, color = 'violet', label = 'German Household Inflation Expectations (one-year-ahead)')
ax1.plot(ea_inf_exp_q, color = 'red', label = 'Eurozone Household Inflation Expectations (one-year-ahead)')
#ax2.plot(data_inf.iloc[:,0], data_inf.iloc[:,1], color = 'black', label = 'Eurozone Inflation')
#ax2.plot(inflation_ger_q.iloc[:,0], inflation_ger_q.iloc[:,1], color = 'yellow', label = 'German Inflation')
ax2.plot(data_inf_exp[1:-9], color = 'blue', label = 'Forecasters Inflation Expectations Eurozone (one-year-ahead)')

fig.legend(loc = 'lower left')

plt.show()

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()

ax1.plot(data_ECB_index_inf2, color = 'green', label = 'ECB Inflation Index (Lex)')
ax1.plot(data_ECB_index_inf, color = 'red', label = 'ECB Inflation Index (BERT)')
#ax1.plot(dire_senti*-1, color = 'cyan', label = 'News Inflation/Sentiment Index (BERT)')
#ax1.plot(ger_inf_exp_q, color = 'violet', label = 'German Household Inflation Expectations (one-year-ahead)')
#ax1.plot(ea_inf_exp_q, color = 'red', label = 'Eurozone Household Inflation Expectations (one-year-ahead)')
ax2.plot(data_inf.iloc[:,0], data_inf.iloc[:,1], color = 'black', label = 'Eurozone Inflation')
#ax2.plot(inflation_ger_q.iloc[:,0], inflation_ger_q.iloc[:,1], color = 'red', label = 'German Inflation (year-on-year)')
#ax2.plot(inflation_ger_qoq.iloc[:,0], inflation_ger_qoq.iloc[:,1], color = 'red', label = 'German Inflation (quarter-on-quarter)')
#ax2.plot(data_inf_exp[1:-9], color = 'blue', label = 'Forecasters Inflation Expectations Eurozone (one-year-ahead)')

fig.legend(loc = 'upper left')

plt.show()

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()

#ax1.plot(data_ECB_index_inf2, color = 'green', label = 'ECB Inflation Index (Lex)')
ax1.plot(data_ECB_index_inf, color = 'red', label = 'ECB Inflation Index (BERT)')
ax1.plot(dire_senti*-1, color = 'cyan', label = 'News Inflation/Sentiment Index (BERT)')
#ax1.plot(ger_inf_exp_q, color = 'violet', label = 'German Household Inflation Expectations (one-year-ahead)')
#ax1.plot(ea_inf_exp_q, color = 'red', label = 'Eurozone Household Inflation Expectations (one-year-ahead)')
#ax2.plot(relative_exp_gap, color = 'black', label = 'Relative Exp Gap')
ax2.plot(abs_exp_gap, color = 'green', label = 'Absolute Exp Gap')


fig.legend(loc = 'upper left')

plt.show()

ECB_index_eurozone_inflation_corr = np.corrcoef(np.array(list(data_ECB_index_inf.iloc[:,0])), np.array(list(data_inf.iloc[:,1])))
News_index_eurozone_inflation_corr = np.corrcoef(np.array(list(dire_senti.iloc[:,0]*-1)), np.array(list(data_inf.iloc[:,1])))

##############################################################################
# Proffesional Inflation Expectations
##############################################################################

import numpy as np

np.corrcoef(list(dire_q[32:].iloc[:,0]), list(data_inf_exp[:-16].iloc[:,0]))
np.corrcoef(list(data_ECB_full[1:-15].iloc[:,0]), list(data_inf_exp[:-16].iloc[:,0]))

##############################################################################

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(dire_q[32:], color = 'green', label = 'News Inflation')
ax2.plot(data_inf_exp[:-16], color = 'blue', label = 'Forecasters Inflation Expectations')

fig.legend(loc = 'lower left')

plt.show()

##############################################################################



##############################################################################

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(data_ECB_full[1:-3], color = 'red', label = 'ECB Inflation')
ax2.plot(data_inf_exp[:-4], color = 'blue', label = 'Forecasters Inflation Expectations')

fig.legend(loc = 'lower left')

plt.show()

##############################################################################

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(dire_q, color = 'green', label = 'News Inflation')
ax1.plot(data_ECB_full['date'], data_ECB_full['index'], color = 'red', label = 'ECB Inflation')
ax2.plot(data_inf_exp[:-8], color = 'blue', label = 'Forecasters Inflation Expectations')

fig.legend(loc = 'lower left')

plt.show()