# -*- coding: utf-8 -*-
"""
Created on Fri Aug 19 19:12:41 2022

@author: Nutzer
"""

import pandas as pd

data_inf_exp = pd.read_excel('D:\Studium\PhD\Github\Single-Author\Data\consumer_inflation_quantitative_estimates.xlsx', sheet_name = 2)
data_inf_eu = pd.read_csv('D:\Studium\PhD\Github\Single-Author\Data\HCPI_EU.csv', delimiter = ',')
data_inf_eu['TIME'] = pd.date_range('1997-01-01', end = '2022-08-01',  freq='M')
data_inf_eu['Value'] = [value.replace(',', '.') for value in data_inf_eu['Value']]

data_inf_eu['Value'] = pd.to_numeric(data_inf_eu['Value'])

data_picault = pd.read_csv('D:\Studium\PhD\Github\Single-Author\Data\cbci_data.csv')
data = data[1:123]
data_picault['date'] = pd.to_datetime(data_picault['date'])

media_data = pd.read_csv('D:\Studium\PhD\Github\Single-Author\Data\Export.csv', delimiter = ';')

media_data['date'] = pd.to_datetime(media_data['date'], format = '%d%b%y')
    
dates = pd.date_range(start="2006-01-02",end="2016-12-30").to_pydatetime().tolist()
dates = pd.DataFrame({'dates':dates})

dates = dates[dates['dates'].dt.weekday < 5]

media_data['date'] = list(dates['dates'])

media_data = media_data.set_index('date')

media_data_weekly = media_data.resample('W').mean()
media_data_monthly = media_data.resample('M').mean()

data_picault['money index'] =  data_picault['r_mp_rest'] - data_picault['r_mp_acco']
data_picault['ecc index'] =  data_picault['r_ec_posi'] - data_picault['r_ec_nega']

plt.plot(media_data_weekly.index, media_data_weekly['art_sentiment1_noecb_dm_we_ip'])
plt.plot(media_data_monthly.index, media_data_monthly['art_sentiment1_noecb_dm_we_ip'])

plt.plot(media_data_monthly.index, media_data_monthly['art_sentiment1_noecb_dm_we_ip'])
plt.plot(data['date'], data['money index'])
plt.show()

plt.plot(media_data_monthly.index, media_data_monthly['art_sentiment1_noecb_dm_we_ip'])
plt.plot(data['date'], data['ecc index'])
plt.show()

data_inf_exp['Unammed: 0'] = pd.date_range('2004-01-01', end = '2022-07-01',  freq='Q')
data_inf_eu['TIME'] = pd.to_datetime(data_inf_eu['TIME'])

plt.plot(data_inf_exp['Unammed: 0'], data_inf_exp['Mean'])

plt.plot(data_inf_eu['TIME'], data_inf_eu['Value'])
plt.plot(data_inf_exp['Unammed: 0'], data_inf_exp['Mean'])
plt.show()

data_inf_exp['Unammed: 0'].groupby(pd.PeriodIndex(data_inf_exp, freq='Q'), axis=1).mean()

data_inf_eu.set_index('TIME').groupby(data_inf_eu.index).resample('QS')['Value'].sum()

data_inf_eu.set_index('TIME', inplace=True)
data_inf_eu_quarter = data_inf_eu.resample('QS').sum()
data_inf_eu_quarter = data_inf_eu_quarter[29:]

data.set_index('date', inplace=True)
data = data.resample('MS').sum()
media_data_monthly = media_data_monthly[1:]

diff_inf = np.array(data_inf_exp['Mean']) - np.array(data_inf_eu_quarter['Value'])
diff_sent = np.array(media_data_monthly['art_sentiment1_noecb_dm_we_ip']) - np.array(data['money index'])

from sklearn import preprocessing

plt.plot(media_data_monthly.index, preprocessing.scale(media_data_monthly['art_sentiment1_noecb_dm_we_ip']))
plt.plot(data['date'], preprocessing.scale(data['money index']))
plt.plot(data_inf_eu_quarter.index, preprocessing.scale(diff_inf))
plt.show()

plt.plot(data.index, preprocessing.scale(diff_sent))
plt.plot(data_inf_eu_quarter.index, preprocessing.scale(diff_inf))
plt.show()