# -*- coding: utf-8 -*-
"""
Created on Fri Nov 18 12:31:44 2022

@author: Nutzer
"""

import pandas as pd
import pylab as plt
import numpy as np
import os

data_mon1 = pd.read_csv(r'D:\Studium\PhD\Github\Single-Author\Data\ECB_monetary_labels.csv')
data_mon2 = pd.read_csv(r'D:\Studium\PhD\Github\Single-Author\Data\ECB_monetary_own_trainingsset_labels.csv')

data_ec1 = pd.read_csv(r'D:\Studium\PhD\Github\Single-Author\Data\ECB_economic_labels.csv')
data_ec2 = pd.read_csv(r'D:\Studium\PhD\Github\Single-Author\Data\ECB_economic_own_trainingsset_labels.csv')

data_inf2 = pd.read_csv(r'D:\Studium\PhD\Github\Single-Author\Data\ECB_inf_own_trainingsset_labels.csv')

pr_data = pd.read_csv(r'D:\Studium\PhD\Github\Single-Author\Data\cbci_data.csv')
pr_mon = pr_data['r_mp_rest'] - pr_data['r_mp_acco']
pr_ec = pr_data['r_ec_posi'] - pr_data['r_ec_nega']

data_mon1['date'] = pd.to_datetime(data_mon1['date'])
data_ec1['date'] = pd.to_datetime(data_ec1['date'])
data_mon2['date'] = pd.to_datetime(data_mon2['date'])
data_ec2['date'] = pd.to_datetime(data_ec2['date'])
pr_data['date'] = pd.to_datetime(pr_data['date'])

plt.plot(data_mon1['date'], np.array(data_mon1['index']), color = 'green')
plt.plot(pr_data['date'], np.array(pr_mon), color = 'blue')
plt.show()

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(data_mon1['date'], np.array(data_mon1['index']), color = 'green', label = 'PR Lex ECB EC')
ax2.plot(pr_data['date'], np.array(pr_mon), color = 'blue', label = 'PR ECB EC')

fig.legend(loc = 'lower left')
plt.title('ECB Outlook - PR OG vs BERT')
plt.show()

##############################################################################

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(data_mon1['date'], np.array(data_mon1['index']), color = 'green', label = 'PR Lex ECB MON')
ax1.plot(pr_data['date'], np.array(pr_mon), color = 'red', label = 'PR OG ECB MON')
ax2.plot(data_mon2['date'], np.array(data_mon2['index'])*-1, color = 'blue', label = 'PR OWN Lex ECB MON')

fig.legend(loc = 'lower left')
plt.title('ECB Monetary - PR Lex vs own Lex vs PR OG')
plt.show()

##############################################################################

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(data_ec1['date'], np.array(data_ec1['index']), color = 'green', label = 'PR Lex ECB EC')
ax1.plot(pr_data['date'], np.array(pr_ec), color = 'red', label = 'PR OG ECB EC')
ax2.plot(data_ec2['date'], np.array(data_ec2['index']), color = 'blue', label = 'PR OWN Lex ECB EC')

fig.legend(loc = 'lower left')
plt.title('ECB Outlook - PR Lex vs own Lex vs PR OG')
plt.show()

##############################################################################

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(data_mon2['date'], np.array(data_mon2['index'])*-1, color = 'green', label = 'OWN LEX ECB EC')
ax2.plot(pr_data['date'], np.array(pr_mon), color = 'blue', label = 'PR ECB EC')

fig.legend(loc = 'lower left')
plt.title('ECB Monetary - PR OG vs BERT')
plt.show()

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(data_mon['date'], np.array(data_mon['index'])*-1, color = 'green')
ax2.plot(pr_data['date'], np.array(pr_ec), color = 'blue', label = 'PR ECB EC')

fig.legend(loc = 'lower left')
plt.title('ECB Outlook - PR OG vs BERT')
plt.show()

plt.plot(data_ec['date'], np.array(data_ec['index']), color = 'green')
plt.plot(pr_data['date'], np.array(pr_ec), color = 'blue')
plt.show()

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

##############################################################################

data_ECB_sents_out = pd.read_excel('D:\Studium\PhD\Single Author\Data\ECB\press_sents_full_index_labeled_outlook.xlsx')

data_ECB_full = ECB_index(data_ECB_sents_out)

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(data_ECB_full['date'], np.array(data_ECB_full['index']), color = 'green', label = 'BERT ECB EC')
ax2.plot(pr_data['date'], np.array(pr_ec), color = 'blue', label = 'PR ECB EC')

fig.legend(loc = 'lower left')
plt.title('ECB Outlook - PR OG vs BERT')
plt.show()

##############################################################################

data_ECB_sents_mon = pd.read_excel('D:\Studium\PhD\Single Author\Data\ECB\press_sents_full_index_labeled_monetary.xlsx')

data_ECB_full = ECB_index(data_ECB_sents_mon)

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(data_ECB_full['date'], np.array(data_ECB_full['index'])*-1, color = 'green', label = 'BERT ECB MON')
ax2.plot(pr_data['date'], np.array(pr_mon), color = 'blue', label = 'PR ECB MON')

fig.legend(loc = 'lower left')
plt.title('ECB Monetary - PR OG vs BERT')
plt.show()

##############################################################################

data_ECB_sents_inf = pd.read_excel('D:\Studium\PhD\Single Author\Data\ECB\press_sents_full_index_labeled_inf.xlsx')

data_ECB_full = ECB_index(data_ECB_sents_inf)
data_ECB_full['index'] = data_ECB_full.rolling(3).mean()
data_ECB_full = data_ECB_full[2:]

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(data_ECB_full['date'], np.array(data_ECB_full['index']), color = 'green', label = 'BERT ECB INF')
ax2.plot(pr_data['date'], np.array(pr_mon), color = 'blue', label = 'PR MON')

fig.legend(loc = 'lower left')
plt.title('ECB INF vs ECB MON')
plt.show()

##############################################################################

from sklearn import preprocessing

ecb_mon_bert = np.array(data_ECB_full['index'])*-1

normalized_ecb_mon_bert = preprocessing.scale(np.float32(ecb_mon_bert))
normalized_ecb_mon_pr = preprocessing.scale(np.float32(pr_mon))

PATH = r"D:\Studium\PhD\Github\Single-Author\Code\Unsupervised\Support"

os.chdir(PATH)

from PR_index_supp import inf_senti_index

##############################################################################
# News Direction
############################################################################## 

data_dir = pd.read_csv('D:\Studium\PhD\Single Author\Data\dpa_dir_labels_test.csv')
           
monthly_count_dire, dire = inf_senti_index(data_dir)  

##############################################################################
# News Sentiment
##############################################################################

data_senti = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\dpa_sent_labels_test.csv')

monthly_count_senti, senti = inf_senti_index(data_senti) 

senti_short = senti[107:]

senti_short = pd.DataFrame(senti_short)
#data['count'] = monthly_count[107:]
senti_short.index = dates_m

senti_short_q = senti_short.groupby(pd.Grouper(freq="Q")).mean()
senti_short_Y = senti_short.groupby(pd.Grouper(freq="Y")).mean()

plt.plot(senti_short_q)
plt.plot(senti_short_Y)
plt.show()

##############################################################################


inflation_ger_q = pd.read_excel('D:\Studium\PhD\Single Author\Data\Consumer Price IndexAll Items Total Total for Germany.xls')[10:]
ger_inf_exp = pd.read_excel("D:\Studium\PhD\Github\Single-Author\Data\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name = "TOT")["CONS.DE.TOT.6.B.M"]

ger_inf_exp = pd.read_excel("D:\Studium\PhD\Github\Single-Author\Data\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name = "TOT")["CONS.DE.TOT.6.MM.M"]

ger_inf_exp = pd.read_excel("D:\Studium\PhD\Github\Single-Author\Data\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name = "AG3")["CONS.DE.AG3.6.B.M"]

ger_inf_exp = pd.read_excel("D:\Studium\PhD\Github\Single-Author\Data\consumer_subsectors_nsa_q5_nace2.xlsx", sheet_name = "TOT")["CONS.DE.TOT.5.B.M"]
ger_inf_exp = ger_inf_exp[179:408]

ger_inf_exp = ger_inf_exp[179:]      

dates_q = pd.date_range('12/1/1999', '1/1/2019', freq = 'Q').tolist()
dates_m = pd.date_range('12/1/1999', '1/1/2019', freq = 'M').tolist()

dates_m = pd.date_range('12/1/1999', '8/1/2022', freq = 'M').tolist()

senti_short = pd.DataFrame(senti_short)
senti_short.index = dates_m

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(dates_q, inflation_ger_q.iloc[:,1], color = 'green', label = 'Real')
ax2.plot(dates_m, ger_inf_exp, color = 'blue', label = 'Expectations')

fig.legend(loc = 'lower left') 
plt.title('Quarterly - BERT vs Inflation')
plt.show()

ger_inf_exp = pd.DataFrame(ger_inf_exp)
ger_inf_exp.index = dates_m
ger_inf_exp_q = ger_inf_exp.groupby(pd.Grouper(freq="Q")).mean()

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(dates_q, inflation_ger_q.iloc[:,1], color = 'green', label = 'Real')
ax2.plot(dates_q, ger_inf_exp_q, color = 'blue', label = 'Expectations')

fig.legend(loc = 'lower left') 
plt.title('Quarterly - BERT vs Inflation')
plt.show()

normalized_ger_inf_exp_q = preprocessing.scale(np.float32(ger_inf_exp_q))
normalized_ger_inf = preprocessing.scale(np.float32(inflation_ger_q.iloc[:,1]))

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(dates_q, normalized_ger_inf_exp_q, color = 'green', label = 'Real')
ax2.plot(dates_q, normalized_ger_inf, color = 'blue', label = 'Expectations')

fig.legend(loc = 'lower left') 
plt.title('Quarterly - BERT vs Inflation')
plt.show()

diff_inf_exp = np.squeeze(normalized_ger_inf_exp_q) - np.squeeze(normalized_ger_inf)

plt.plot(dates_q, diff_inf_exp)

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(dates_q, senti_short_q, color = 'green', label = 'Sentiment')
ax2.plot(dates_q, diff_inf_exp, color = 'blue', label = 'Difference')

fig.legend(loc = 'lower left') 
plt.title('Quarterly - BERT vs Inflation')
plt.show()

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.plot(senti_short_Y, color = 'green', label = 'Sentiment')
ax2.plot(dates_q, diff_inf_exp, color = 'blue', label = 'Difference')

fig.legend(loc = 'lower left') 
plt.title('Quarterly - BERT vs Inflation')
plt.show()

##############################################################################

plt.plot(data_ECB_full['date'], normalized_ecb_mon_bert[0])

dates_m = pd.date_range('1/1/1999', '1/1/2019', freq = 'M').tolist()

dates_m = pd.date_range('1/1/2004', '1/1/2019', freq = 'M').tolist()

dire_short = dire[96:]
   
dire_short = dire[156:]

plt.plot(dates_m, normalized_dire_short[0])

ger_inf_exp = pd.read_excel("D:\Studium\PhD\Github\Single-Author\Data\consumer_subsectors_nsa_q5_nace2.xlsx", sheet_name = "TOT")["CONS.DE.TOT.5.B.M"]
ger_inf_exp = pd.read_excel("D:\Studium\PhD\Github\Single-Author\Data\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name = "TOT")["CONS.DE.TOT.6.B.M"]
#ger_inf_exp = ger_inf_exp[168:408]

ger_inf_exp = ger_inf_exp[228:408]

dates_q = pd.date_range('1/1/1999', '1/1/2019', freq = 'Q').tolist()
#dates_m = pd.date_range('1/1/1999', '1/1/2019', freq = 'M').tolist()

ger_inf = pd.read_excel("D:\Studium\PhD\Github\Single-Author\Data\ger_monthly_inf_fred.xls")['Unnamed: 1']
ger_inf_2 = pd.read_excel("D:\Studium\PhD\Github\Single-Author\Data\ger_monthly_inf_fred_2.xls")['Unnamed: 1']

ger_inf = ger_inf[166:246]
#ger_inf_2 = ger_inf_2[442:682]['Unnamed: 1']

ger_inf_2 = ger_inf_2[502:682]

normalized_ger_inf_exp = preprocessing.scale(np.float32(ger_inf_exp))
normalized_ger_inf_2 = preprocessing.scale(np.float32(ger_inf_2))
normalized_ger_inf_news = preprocessing.scale(np.float32(dire_short))
normalized_ger_inf_exp = preprocessing.scale(np.float32(ger_inf_exp))

normalized_dire_short = preprocessing.scale(np.float32(dire_short))
normalized_senti = preprocessing.scale(np.float32(senti_short))

plt.plot(data_ECB_full['date'], normalized_ecb_mon_bert, color = 'black')
plt.plot(dates_m, normalized_dire_short, color = 'blue')
plt.plot(dates_m, normalized_ger_inf_exp, color = 'green')
plt.plot(dates_m, normalized_ger_inf_2, color = 'red')
plt.show()

diff_inf = normalized_ger_inf_exp - normalized_ger_inf_2
scaled_diff_inf = preprocessing.scale(np.float32(diff_inf))

diff_inf_news = normalized_ger_inf_news - normalized_ger_inf_2
scaled_diff_inf_news = preprocessing.scale(np.float32(diff_inf_news))

plt.plot(dates_m, scaled_diff_inf)
plt.plot(dates_m, normalized_ger_inf_2)
plt.show()

plt.plot(dates_m, scaled_diff_inf)
plt.plot(dates_m, normalized_ger_inf_news)
plt.show()

plt.plot(dates_m, scaled_diff_inf)
plt.plot(dates_m, scaled_diff_inf_news)
plt.show()

window_size = 3

windows = pd.Series(normalized_ecb_mon_bert).rolling(window_size)
  
moving_averages = windows.mean()
  
moving_averages__ecb_mon_bert = moving_averages.tolist()
  
moving_averages__ecb_mon_bert = moving_averages__ecb_mon_bert[window_size - 1:]

window_size = 3

windows = pd.Series(normalized_ger_inf_news).rolling(window_size)
  
moving_averages = windows.mean()
  
moving_averages_dire = moving_averages.tolist()
  
moving_averages_dire = moving_averages_dire[window_size - 1:]

plt.plot(data_ECB_full['date'][2:], moving_averages__ecb_mon_bert)
plt.plot(dates_m[2:], moving_averages_dire)
plt.show()


##############################################################################

plt.plot(dates_m, diff_inf, color = 'red')
plt.plot(data_ECB_full['date'], normalized_ecb_mon_bert[0], color = 'black')
plt.plot(dates_m, normalized_dire_short[0], color = 'blue')
plt.show()

plt.plot(dates_m, diff_inf, color = 'red')
plt.plot(dates_m, normalized_dire_short[0], color = 'blue')
plt.show()

dates_m_mov_av = pd.date_range('2/1/1999', '12/1/2018', freq = 'M').tolist()

dates_m_mov_av = pd.date_range('2/1/2004', '12/1/2018', freq = 'M').tolist()
  
window_size = 3

windows = pd.Series(dire_short).rolling(window_size)
  
moving_averages = windows.mean()
  
moving_averages_dire = moving_averages.tolist()
  
moving_averages_dire = moving_averages_dire[window_size - 1:]

plt.plot(dates_m, diff_inf, color = 'red')
plt.plot(dates_m_mov_av, moving_averages_dire)
plt.show()

fig, ax1 = plt.subplots()
  
ax2 = ax1.twinx()
ax1.plot(dates_m, diff_inf, color = 'green')
ax2.plot(dates_m_mov_av, moving_averages_dire, color = 'blue')

plt.show()

##############################################################################

window_size = 3

windows = pd.Series(senti_short).rolling(window_size)
  
moving_averages = windows.mean()
  
moving_averages_senti = moving_averages.tolist()
  
moving_averages_senti = moving_averages_senti[window_size - 1:]

fig, ax1 = plt.subplots()
  
ax2 = ax1.twinx()
ax1.plot(dates_m, diff_inf, color = 'green')
ax2.plot(dates_m_mov_av, np.array(moving_averages_senti)*-1, color = 'blue')

plt.show()