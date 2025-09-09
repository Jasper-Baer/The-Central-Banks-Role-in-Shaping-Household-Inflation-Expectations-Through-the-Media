# -*- coding: utf-8 -*-
"""
Created on Mon Oct  2 12:46:19 2023

@author: Jasper Bär
"""

import pandas as pd
import numpy as np

import os

import statsmodels.api as sm

from dateutil.relativedelta import relativedelta
from pandas.tseries.offsets import MonthEnd
from itertools import islice

PATH_data = r'D:\Studium\PhD\Github\Single-Author\Data\Regression'
PATH_Reuter = r'D:\Studium\PhD\Github\Single-Author\Data\Reuters Poll'
PATH_Consensus = r'D:\Studium\PhD\Github\Single-Author\Data\Consensus Forecast'
PATH_code = r"D:\Studium\PhD\Github\Single-Author\Code\Plots"

os.chdir(PATH_code)

from Data_Prep_Supp import scale_ECB_index, transform_quantiles_V1, transform_quantiles_V2

start_date = '1999-12-31'
end_date = '2024-01-01'
end_date_forecast = '2024-01-21'

start_date_12_month_shift = '2000-12-31'
end_date_12_month_shift = '2024-01-01'

start_date_hist_berk_1 = '1998-10-31'
start_date_hist = '1995-12-31'

# Helper Functions
def load_csv_data(base_path, file_name, column_date=None):
    file_path = os.path.join(base_path, file_name)
    data = pd.read_csv(file_path)
    if column_date:
        data[column_date] = pd.to_datetime(data[column_date])
        data.set_index(column_date, inplace=True)
    return data

def load_excel_data(base_path, file_name, sheet_name = 0, col=None, skip_rows=0, index_col=None):
    file_path = os.path.join(base_path, file_name)
    df = pd.read_excel(file_path, skiprows=skip_rows, index_col=index_col, sheet_name = sheet_name)
    if col:
        return df[col]
    return df

def year_to_month(data):
    data = pd.DataFrame(data)
    data['Year'] = pd.to_datetime(data['Year'], format='%Y')
    data = data.set_index('Year')
    data = data['One-Year-Ahead']
    data_m = data.resample('M').mean()
    data_m = data_m.interpolate(method='linear')
    return pd.DataFrame(data_m)

def get_last_day_of_month(year_month_str):
    """Return the last day of a month given a year-month string."""
    dt = pd.to_datetime(year_month_str)
    return dt + relativedelta(day=1, months=1) - relativedelta(days=1)

def update_dataframe_dates_and_filter(df, date_column_name='date'):
    """Update dates of a dataframe, set as index, and filter by a global date range."""
    df[date_column_name] = df[date_column_name].apply(get_last_day_of_month)
    df.set_index(date_column_name, inplace=True)
    return df.loc[(df.index >= start_date) & (df.index <= end_date)]

def transform_inflation_data_1(data):
    
    data = data.dropna(subset=['TIME', 'Germany'])[['TIME', 'Germany']]
    data.rename(columns = {'Germany':'Inflation'}, inplace = True)
    data = transform_date(data)
    
    return(data)

def transform_inflation_data_2(data, start_date, end_date):
    
    data = data.loc[(data.index >= start_date) & (data.index <= end_date)]
    data.iloc[:,1] = pd.to_numeric(data.iloc[:,1])
    data['Inflation'] = pd.to_numeric(data['Inflation'])
    #mean_inflation = data['Inflation'].mean()
    
    return(data)

def transform_date(data):
    
    data.iloc[:,0] = pd.to_datetime(data.iloc[:,0]) + MonthEnd(0)
    data.index = data.iloc[:,0]
    
    return(data)

def transform_date_2(data):
    
    data.index = pd.to_datetime(data.index) + MonthEnd(0)
    
    return(data)
        
###############################################################################
# Inflation
###############################################################################

forecast_q = load_excel_data(PATH_Reuter, 'Forecast_Inflation_Reuter.xlsx')
forecast_q = forecast_q.dropna(subset = ['One-Year-Ahead Direct'])

forecast_q_eu_staff = load_excel_data(PATH_data, 'EU_staff_forecast.xlsx')
forecast_q_eu_staff_inf = forecast_q_eu_staff.dropna(subset = ['Inflation Forecast EU Staff'])

forecast_q_eu_staff = load_excel_data(PATH_data, 'EU_staff_forecast.xlsx')
forecast_q_eu_staff_gdp = forecast_q_eu_staff.dropna(subset = ['GDP Forecast EU Staff'])

consensus_forecast_de = load_excel_data(PATH_Consensus, 'Consensus Inflation Forecast.xlsx')
consensus_forecast_de = consensus_forecast_de[['Survey month', 'Final Forecast DE']]

consensus_forecast_ea = load_excel_data(PATH_Consensus, 'Consensus Inflation Forecast.xlsx')
consensus_forecast_ea = consensus_forecast_ea[['Survey month', 'Final Forecast EA']]

#ecb_dfr = load_excel_data(PATH_data, 'ECBDFR.xls', skip_rows=10)
ecb_mro = load_excel_data(PATH_data, 'ECBMRRFR.xls', skip_rows=10)
germany_harmonised_inflation_m = load_excel_data(PATH_data, 'CPHPTT01DEM659N.xls', skip_rows=10)

unemp_ger_m = load_excel_data(PATH_data, 'Germany_Unemployment.xlsx', skip_rows=9, sheet_name = 'Sheet 1').iloc[1, :].T
unemp_ger_m = unemp_ger_m.iloc[1::2]

fred_monthly = load_excel_data(PATH_data, 'Fred_data_monthly.xlsx', skip_rows=6)
ip_ger_m = fred_monthly.iloc[:-10, 0:2]
ip_ea_m = fred_monthly.iloc[:-199, 6:8]

cycle, trend = sm.tsa.filters.hpfilter(ip_ger_m['value'], lamb=14400)
ip_ger_m['cyclical'] = cycle

#cycle, trend = sm.tsa.filters.hpfilter(ip_ea_m['value.3'], lamb=14400)
#ip_ea_m['cyclical'] = cycle

inflation_ea_m = load_excel_data(PATH_data, 'Inflation_2.xlsx', sheet_name = "Headline Inflation")
#inflation_ea_m = load_excel_data(PATH, 'Inflation_2.xlsx', sheet_name = "Core Inflation")

#inflation_ea_m = inflation_ea_m.dropna(subset=['TIME', 'Euro area - 19 countries  (2015-2022)'])[['TIME', 'Euro area - 19 countries  (2015-2022)']]
#inflation_ea_m.rename(columns = {'Euro area - 19 countries  (2015-2022)':'Inflation'}, inplace = True)
#inflation_ea_m = transform_date(inflation_ea_m)[:-3]

inflation_ger_m = load_excel_data(PATH_data, 'Inflation_2.xlsx', sheet_name = "Headline Inflation")
#inflation_ger_m_cor = load_excel_data(PATH_data, 'Inflation_2.xlsx', sheet_name = "Core Inflation")
#inflation_ger_m_fb = load_excel_data(PATH_data, 'Inflation_2.xlsx', sheet_name = "Food and Beverages")
#inflation_ger_m_energy = load_excel_data(PATH_data, 'Inflation_2.xlsx', sheet_name = "Energy")

#inflation_ger_m = transform_inflation_data_1(inflation_ger_m)
#inflation_ger_m_cor = transform_inflation_data_1(inflation_ger_m_cor)
#inflation_ger_m_fb = transform_inflation_data_1(inflation_ger_m_fb)
#inflation_ger_m_energy = transform_inflation_data_1(inflation_ger_m_energy)

euro_dollar_m = load_excel_data(PATH_data, 'EXUSEU.xls')[10:]
#eonita = load_excel_data(PATH_data, 'EONIARATE.xls')[10:]
eurostoxx = load_excel_data(PATH_data, 'Eurostoxx50.xlsx')[['DATE', 'OBS.VALUE']]

MRO_surprise = load_excel_data(PATH_data, 'Reuters_Poll2.xlsx')[10:].iloc[:,[3,7]]
MRO_surprise.iloc[:,1] = MRO_surprise.iloc[:,1].fillna(0)
MRO_surprise['Positive_Surprise'] = np.where(MRO_surprise.iloc[:,1] > 0, MRO_surprise.iloc[:,1], 0)
MRO_surprise['Negative_Surprise'] = abs(np.where(MRO_surprise.iloc[:,1] < 0, MRO_surprise.iloc[:,1], 0))

# Share of sentences: Sentences about inflation weighted by all sentences
#monthly_inf_count = load_csv_data(PATH_data, 'monthly_count_inf_to_all.csv')

# Share of sentences: ECB Quotes talking about monetary policy weighted by all sentences
#monthly_ecb_quotes_count = load_csv_data(PATH_data, 'monthly_count_ecb_quotes_to_all.csv')

# Share of sentences: ECB Non Quotes talking about monetary policy weighted by all sentences
#monthly_ecb_non_quotes_count = load_csv_data(PATH_data, 'monthly_count_ecb_non_quotes_to_all.csv')

# Share of sentences: All sentences talking about monetary policy weighted by all sentences
#monthly_ecb_all_count = load_csv_data(PATH_data, 'monthly_count_ecb_all_to_all.csv')

#data_ECB_index_inf = load_csv_data(PATH_data, 'PR_ecb_inflation_results.csv').sort_values(by='date', ascending=True)

# data_ECB_index_mon = load_csv_data(PATH_data, 'PR_ecb_monetary_results.csv')[['date', 'index']].sort_values(by='date', ascending=True)
# data_ECB_index_ec = load_csv_data(PATH_data, 'PR_ecb_outlook_results.csv')[['date', 'index']].sort_values(by='date', ascending=True)

# data_ECB_index_mon_2 = load_csv_data(PATH_data, 'ECB_monetary_own_trainingsset_labels.csv')[['date', 'index']].sort_values(by='date', ascending=True)
# data_ECB_index_ec_2 = load_csv_data(PATH_data, 'PR_ecb_outlook_results.csv')[['date', 'index']].sort_values(by='date', ascending=True)

#data_ECB_index_inf = load_csv_data(PATH_data, 'ECB_inf_BERT.csv')[['date', 'index']]
#data_ECB_index_mon = load_csv_data(PATH_data, 'ECB_mon_BERT.csv')[['date', 'index']]
#data_ECB_index_ec = load_csv_data(PATH_data, 'ECB_out_BERT.csv')[['date', 'index']]

Ifo = load_excel_data(PATH_data, 'Ifo_index.xlsx')[8:]
Ifo.rename(columns = {'Unnamed: 4': 'Business_climate', 'Unnamed: 5': 'Business_situation', 'Unnamed: 6': 'Business_expectations'}, inplace = True)
Ifo.iloc[:,0] = pd.to_datetime(Ifo.iloc[:,0]) + pd.offsets.MonthEnd(0)
Ifo.index = Ifo.iloc[:,0]

Ifo = Ifo[['Business_climate', 'Business_situation', 'Business_expectations']]

# dire_senti_m = load_excel_data(PATH_data, 'news_index_dire_senti_BERT_m.xlsx')
# dire_senti_m.rename(columns = {'t_date': 'date'}, inplace = True)
#dire_senti_m = load_excel_data(PATH, 'news_index_dire_senti_lex.xlsx')
#dire_senti_m = load_excel_data(PATH, 'news_index_dire_senti_lex_PMI.xlsx')

# dire_m = load_excel_data(PATH_data, 'news_index_dire_BERT_m.xlsx')
# dire_m.rename(columns = {'t_date': 'date'}, inplace = True)
#dire_m = load_excel_data(PATH, 'news_index_dire_lex.xlsx')
#dire_m = load_excel_data(PATH, 'news_index_dire_lex_PMI.xlsx')

# sent_m = load_excel_data(PATH_data, 'news_index_senti_BERT_m.xlsx')
# sent_m.rename(columns = {'t_date': 'date'}, inplace = True)
#sent_m = load_excel_data(PATH, 'news_index_senti_lex.xlsx')
#sent_m = load_excel_data(PATH, 'news_index_senti_lex_PMI.xlsx')

data_inf_exp_eu = pd.read_excel(PATH_data + '\Infl_Exp.xlsx', index_col = 0)
#ger_oecd_inf_exp = pd.read_csv(PATH + '\OECD_INF_FOR.csv', index_col = 0)

data_out_ger = pd.read_excel(PATH_data + '\consumer_total_sa_nace2.xlsx', sheet_name='CONSUMER MONTHLY')[['Unnamed: 0', 'CONS.DE.TOT.COF.BS.M', 'CONS.DE.TOT.1.BS.M',  'CONS.DE.TOT.2.BS.M', 'CONS.DE.TOT.3.BS.M',  'CONS.DE.TOT.4.BS.M', 'CONS.DE.TOT.5.BS.M',  'CONS.DE.TOT.6.BS.M', 'CONS.DE.TOT.7.BS.M', 'CONS.DE.TOT.12.BS.M']]

# data_comb_ecb_index = load_excel_data(PATH_data, 'news_ecbindex_dire_senti_BERT_m.xlsx')
# data_comb_ecb_index.rename(columns = {'t_date': 'date'}, inplace = True)

###

# dire_senti_m = update_dataframe_dates_and_filter(dire_senti_m)
# dire_m = update_dataframe_dates_and_filter(dire_m)
# sent_m = update_dataframe_dates_and_filter(sent_m)

#data_comb_ecb_index_m = update_dataframe_dates_and_filter(data_comb_ecb_index)

VDAX_NEW = pd.read_excel(PATH_data + '\DAX.xlsx').iloc[:, 0:2]

VDAX_NEW['Datum'] = pd.to_datetime(VDAX_NEW['Date1'], format='%Y.%m.%d')
VDAX_NEW.set_index('Datum', inplace=True)

VDAX_NEW = VDAX_NEW

DAX = pd.read_excel(PATH_data + '\DAX.xlsx').iloc[:, 2:4]

DAX['Datum'] = pd.to_datetime(DAX['Date2'], format='%Y.%m.%d')
DAX.set_index('Datum', inplace=True)

###############################################################################

# ea_inf_exp_quant = pd.read_excel(PATH_data + "\consumer_inflation_quantitative_estimates.xlsx", sheet_name="EU_Q61")
# ea_inf_exp_quant = ea_inf_exp_quant[['Unnamed: 0', 'Median', 'Mean', '1st Quartile', '3rd Quartile']]

# cont = 'DE'
# # #cont = 'EU'

# cols = ["6.PP.M", "6.P.M", "6.E.M", "6.M.M", "6.MM.M", "6.N.M"]
# cols_per = ["5.PP.M", "5.P.M", "5.E.M", "5.M.M", "5.MM.M", "5.N.M"]

# groups = [
#     "TOT",
#     "ED1",
#     "ED2",
#     "ED3",
# #    "AG1",
# #    "AG2",
# #    "AG3",
# #    "AG4"
# ]

# processed_data = {}
# processed_data_per = {}

# for group in groups:
    
#     prefix = "CONS." + cont + "." + group + "."
    
#     inf_exp_surv = pd.read_excel(PATH_data + "\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name=group)
#     inf_per_surv = pd.read_excel(PATH_data + "\consumer_subsectors_nsa_q5_nace2.xlsx", sheet_name=group)
    
#     inf_exp_dfs = [inf_exp_surv[[group, prefix + col]] for col in cols]
#     inf_per_dfs = [inf_per_surv[[group, prefix + col]] for col in cols_per]

#     for df in inf_exp_dfs + inf_per_dfs:
#         df['date'] = pd.to_datetime(df[group])
    
#     # survey_weights, perc_inf = transform_quantiles_V2(
#     #     inflation_ger_m[32:-57],
#     #     *(df[179:-43] for df in inf_exp_dfs + inf_per_dfs)
#     # )

#     # perc_inf = transform_date(perc_inf)
#     # exp_inf = pd.DataFrame({'date': survey_weights['date'], 'exp_inf': np.array(survey_weights['exp_weight']*np.array(perc_inf['CP_perc_inf']))})
#     # exp_inf = transform_date(exp_inf)

#     # perc_inf_m = perc_inf.loc[(perc_inf.index >= start_date) & (perc_inf.index <= end_date)]
#     # exp_inf_m = exp_inf.loc[(exp_inf.index >= start_date) & (exp_inf.index <= end_date)]

#     processed_data[group] = exp_inf_m['exp_inf'].tolist()
#     processed_data_per[group] = perc_inf_m['CP_perc_inf'].tolist()

###############################################################################
    
PR = load_csv_data('D:\Studium\PhD\Github\Single-Author\Code\Regression', 'cbci_data.csv')
PR['date'] = pd.to_datetime(PR['date'])
PR.index = PR['date'] 
PR = PR.drop('date', axis=1)
#PR = PR.resample('M').ffill()

data_surv_dates = list(PR.index)

#double_month_count = pd.read_csv(r'D:\Studium\PhD\Github\Single-Author\Code\Regression\double_ECB_months.csv')

#PR.index = pd.to_datetime(PR.index) + MonthEnd(0)

#PR = transform_date(PR)

# first_date = PR.index.min() - pd.DateOffset(years=7)
# last_date = PR.index.min()

# new_index = pd.date_range(start=first_date, end=last_date, freq='M')

# extended_data = pd.DataFrame(index=new_index)
# extended_data.index = pd.to_datetime(extended_data.index)

# PR = pd.concat([extended_data[:-1], PR]).fillna(0)
# PR = PR.loc[(PR.index >= start_date) & (PR.index <= end_date)]
    
###############################################################################

germ_balanced = pd.read_excel(PATH_data + "\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name="TOT")[['TOT','CONS.DE.TOT.6.B.M']][180:]
germ_balanced_ed1 = pd.read_excel(PATH_data + "\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name="ED1")[['ED1','CONS.DE.ED1.6.B.M']][180:]
germ_balanced_ed2 = pd.read_excel(PATH_data + "\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name="ED2")[['ED2','CONS.DE.ED2.6.B.M']][180:]
germ_balanced_ed3 = pd.read_excel(PATH_data + "\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name="ED3")[['ED3','CONS.DE.ED3.6.B.M']][180:]

germ_balanced_perc = pd.read_excel(PATH_data + "\consumer_subsectors_nsa_q5_nace2.xlsx", sheet_name="TOT")[['TOT','CONS.DE.TOT.5.B.M']][180:]
germ_balanced_ed1_perc = pd.read_excel(PATH_data + "\consumer_subsectors_nsa_q5_nace2.xlsx", sheet_name="ED1")[['ED1','CONS.DE.ED1.5.B.M']][180:]
germ_balanced_ed2_perc = pd.read_excel(PATH_data + "\consumer_subsectors_nsa_q5_nace2.xlsx", sheet_name="ED2")[['ED2','CONS.DE.ED2.5.B.M']][180:]
germ_balanced_ed3_perc = pd.read_excel(PATH_data + "\consumer_subsectors_nsa_q5_nace2.xlsx", sheet_name="ED3")[['ED3','CONS.DE.ED3.5.B.M']][180:]

###############################################################################

data_out_ger = transform_date(data_out_ger)
data_out_ger = data_out_ger.loc[(data_out_ger.index >= start_date) & (data_out_ger.index <= end_date)]
data_out_ger.drop(columns=['Unnamed: 0'], inplace = True)

data_out_ger = data_out_ger.apply(pd.to_numeric)

###

unemp_ger_m = transform_date_2(unemp_ger_m)
unemp_ger_m = unemp_ger_m.loc[(unemp_ger_m.index >= start_date) & (unemp_ger_m.index <= end_date)]
unemp_ger_m = pd.to_numeric(unemp_ger_m)

###

inflation_ger_m = transform_inflation_data_1(inflation_ger_m)
inflation_ger_m = transform_inflation_data_2(inflation_ger_m, start_date, end_date)
# inflation_ger_m_cor = transform_inflation_data_2(inflation_ger_m_cor, start_date, end_date)
# inflation_ger_m_fb = transform_inflation_data_2(inflation_ger_m_fb, start_date, end_date)
# inflation_ger_m_energy = transform_inflation_data_2(inflation_ger_m_energy, start_date, end_date)

###

# eonita = transform_date(eonita)
# eonita = eonita.resample("M").mean()
# eonita = eonita.loc[(eonita.index >= start_date) & (eonita.index <= end_date)]

###

eurostoxx = transform_date(eurostoxx)
eurostoxx = eurostoxx.loc[(eurostoxx.index >= start_date) & (eurostoxx.index <= end_date)]
eurostoxx.iloc[:,1] = pd.to_numeric(eurostoxx.iloc[:,1])

###

MRO_surprise = transform_date(MRO_surprise)
MRO_surprise = MRO_surprise.loc[(MRO_surprise.index >= start_date) & (MRO_surprise.index <= end_date)]

###

first_date = Ifo.index.min() - pd.DateOffset(years=7)
last_date = Ifo.index.min()

new_index = pd.date_range(start=first_date, end=last_date, freq='M')

extended_data = pd.DataFrame(index=new_index)
extended_data.index = pd.to_datetime(extended_data.index)

Ifo = pd.concat([extended_data[:-1], Ifo]).fillna(0)
Ifo = Ifo.loc[(Ifo.index >= start_date) & (Ifo.index <= end_date)]

###

consensus_forecast_de = transform_date(consensus_forecast_de)
consensus_forecast_de = consensus_forecast_de.loc[(consensus_forecast_de.index >= start_date) & (consensus_forecast_de.index <= end_date)]

# ###

consensus_forecast_ea = transform_date(consensus_forecast_ea)
consensus_forecast_ea = consensus_forecast_ea.loc[(consensus_forecast_ea.index >= start_date) & (consensus_forecast_ea.index <= end_date)]

###############################################################################

def process_dataframe(filepath, start_date, end_date):
    """
    Load, preprocess, and filter a dataframe from a given filepath based on given start and end dates.
    """
    df = pd.read_excel(filepath)
    #df['t_date'] = pd.to_datetime(df['t_date'])
    
    df.index = pd.to_datetime(df.iloc[:,0])
    
   # df.index = df['t_date']
   # df.index = df.index.shift(1, freq='M')
    return df.loc[(df.index >= start_date) & (df.index <= end_date)]

file_names_news = [
  #  'news_index_ecbgoodfalling_non_quotes', 'news_index_ecbneutralfalling_non_quotes', 'news_index_ecbbadfalling_non_quotes',
 #   'news_index_ecbgoodfalling_quotes', 'news_index_ecbneutralfalling_quotes', 'news_index_ecbbadfalling_quotes',
    'news_index_ecbhawkish_non_quotes', 'news_index_ecbnomon_non_quotes', 'news_index_ecbdovish_non_quotes',
    'news_index_ecbhawkish_quotes', 'news_index_ecbnomon_quotes', 'news_index_ecbdovish_quotes',
    'news_index_ecbgoodhawkish_quotes', 'news_index_ecbgoodnomon_quotes', 'news_index_ecbgooddovish_quotes',
    'news_index_ecbneutralhawkish_quotes', 'news_index_ecbneutralnomon_quotes', 'news_index_ecbneutraldovish_quotes',
    'news_index_ecbbadhawkish_quotes', 'news_index_ecbbadnomon_quotes', 'news_index_ecbbaddovish_quotes',
    'news_index_ecbgoodhawkish_non_quotes', 'news_index_ecbgoodnomon_non_quotes', 'news_index_ecbgooddovish_non_quotes',
    'news_index_ecbneutralhawkish_non_quotes', 'news_index_ecbneutralnomon_non_quotes', 'news_index_ecbneutraldovish_non_quotes',
    'news_index_ecbbadhawkish_non_quotes', 'news_index_ecbbadnomon_non_quotes', 'news_index_ecbbaddovish_non_quotes',
   # 'news_index_ecbgoodnotrend_non_quotes', 'news_index_ecbneutralnotrend_non_quotes', 'news_index_ecbbadnotrend_non_quotes',
  #  'news_index_ecbgoodnotrend_quotes', 'news_index_ecbneutralnotrend_quotes', 'news_index_ecbbadnotrend_quotes',
 #   'news_index_ecbgoodrising_non_quotes', 'news_index_ecbneutralrising_non_quotes', 'news_index_ecbbadrising_non_quotes',
#    'news_index_ecbgoodrising_quotes', 'news_index_ecbneutralrising_quotes', 'news_index_ecbbadrising_quotes',
 #   'news_index_ecbrising_non_quotes', 'news_index_ecbnotrend_non_quotes', 'news_index_ecbfalling_non_quotes',
 #   'news_index_ecbrising_quotes', 'news_index_ecbnotrend_quotes', 'news_index_ecbfalling_quotes',
 
    'news_index_ecbpositive_non_quotes_daily_lead', 'news_index_ecbneutral_non_quotes_daily_lead', 'news_index_ecbnegative_non_quotes_daily_lead',
    'news_index_ecbpositive_quotes_daily_lead', 'news_index_ecbneutral_quotes_daily_lead', 'news_index_ecbnegative_quotes_daily_lead',
    'news_index_rising_lead', 'news_index_notrend_lead', 'news_index_falling_lead',
    'news_index_good_lead', 'news_index_neutral_lead', 'news_index_bad_lead',
    'news_index_goodrising_lead', 'news_index_neutralrising_lead', 'news_index_badrising_lead',
    'news_index_goodnotrend_lead', 'news_index_neutralnotrend_lead', 'news_index_badnotrend_lead',
    'news_index_goodfalling_lead', 'news_index_neutralfalling_lead', 'news_index_badfalling_lead',
 
    'news_index_ecbpositive_non_quotes', 'news_index_ecbneutral_non_quotes', 'news_index_ecbnegative_non_quotes',
    'news_index_ecbpositive_quotes', 'news_index_ecbneutral_quotes', 'news_index_ecbnegative_quotes',
    'news_index_rising', 'news_index_notrend', 'news_index_falling',
    'news_index_good', 'news_index_neutral', 'news_index_bad',
    'news_index_goodrising', 'news_index_neutralrising', 'news_index_badrising',
    'news_index_goodnotrend', 'news_index_neutralnotrend', 'news_index_badnotrend',
    'news_index_goodfalling', 'news_index_neutralfalling', 'news_index_badfalling',
    
    
    'news_index_ecbpositive_non_quotes_daily', 'news_index_ecbneutral_non_quotes_daily', 'news_index_ecbnegative_non_quotes_daily',
    'news_index_ecbpositive_quotes_daily', 'news_index_ecbneutral_quotes_daily', 'news_index_ecbnegative_quotes_daily',
    'news_index_rising_daily', 'news_index_notrend_daily', 'news_index_falling_daily',
       'news_index_good_daily', 'news_index_neutral_daily', 'news_index_bad_daily',
       'news_index_goodrising_daily', 'news_index_neutralrising_daily', 'news_index_badrising_daily',
       'news_index_goodnotrend_daily', 'news_index_neutralnotrend_daily', 'news_index_badnotrend_daily',
       'news_index_goodfalling_daily', 'news_index_neutralfalling_daily', 'news_index_badfalling_daily',
       
       'news_index_ecb_quotes_number', 'news_index_ecb_non_quotes_number',
       
       'news_index_inf_number', 'news_index_mon_number',
      
       'news_index_ecbpositive_non_quotes_daily_lag1', 'news_index_ecbneutral_non_quotes_daily_lag1', 'news_index_ecbnegative_non_quotes_daily_lag1',
       'news_index_ecbpositive_quotes_daily_lag1', 'news_index_ecbneutral_quotes_daily_lag1', 'news_index_ecbnegative_quotes_daily_lag1',
       'news_index_rising_daily_lag1', 'news_index_notrend_daily_lag1', 'news_index_falling_daily_lag1',
          'news_index_good_daily_lag1', 'news_index_neutral_daily_lag1', 'news_index_bad_daily_lag1',
          'news_index_goodrising_daily_lag1', 'news_index_neutralrising_daily_lag1', 'news_index_badrising_daily_lag1',
          'news_index_goodnotrend_daily_lag1', 'news_index_neutralnotrend_daily_lag1', 'news_index_badnotrend_daily_lag1',
          'news_index_goodfalling_daily_lag1', 'news_index_neutralfalling_daily_lag1', 'news_index_badfalling_daily_lag1',
       
#    'news_index_hawkish', 'news_index_nomon', 'news_index_dovish', 
#    'news_index_goodhawkish', 'news_index_goodnomon', 'news_index_gooddovish',
 #   'news_index_neutralhawkish', 'news_index_neutralnomon', 'news_index_neutraldovish',
 #   'news_index_badhawkish', 'news_index_badnomon', 'news_index_baddovish'
 
    'news_index_ecbhawkish_non_quotes_daily', 'news_index_ecbnomon_non_quotes_daily', 'news_index_ecbdovish_non_quotes_daily',
    'news_index_ecbhawkish_quotes_daily', 'news_index_ecbnomon_quotes_daily', 'news_index_ecbdovish_quotes_daily',
    'news_index_ecbgoodhawkish_quotes_daily', 'news_index_ecbgoodnomon_quotes_daily', 'news_index_ecbgooddovish_quotes_daily',
    'news_index_ecbneutralhawkish_quotes_daily', 'news_index_ecbneutralnomon_quotes_daily', 'news_index_ecbneutraldovish_quotes_daily',
    'news_index_ecbbadhawkish_quotes_daily', 'news_index_ecbbadnomon_quotes_daily', 'news_index_ecbbaddovish_quotes_daily',
    'news_index_ecbgoodhawkish_non_quotes_daily', 'news_index_ecbgoodnomon_non_quotes_daily', 'news_index_ecbgooddovish_non_quotes_daily',
    'news_index_ecbneutralhawkish_non_quotes_daily', 'news_index_ecbneutralnomon_non_quotes_daily', 'news_index_ecbneutraldovish_non_quotes_daily',
    'news_index_ecbbadhawkish_non_quotes_daily', 'news_index_ecbbadnomon_non_quotes_daily', 'news_index_ecbbaddovish_non_quotes_daily',
    
    'news_index_ecbhawkish_non_quotes_daily_lag1', 'news_index_ecbnomon_non_quotes_daily_lag1', 'news_index_ecbdovish_non_quotes_daily_lag1',
    'news_index_ecbhawkish_quotes_daily_lag1', 'news_index_ecbnomon_quotes_daily_lag1', 'news_index_ecbdovish_quotes_daily_lag1',
    'news_index_ecbgoodhawkish_quotes_daily_lag1', 'news_index_ecbgoodnomon_quotes_daily_lag1', 'news_index_ecbgooddovish_quotes_daily_lag1',
    'news_index_ecbneutralhawkish_quotes_daily_lag1', 'news_index_ecbneutralnomon_quotes_daily_lag1', 'news_index_ecbneutraldovish_quotes_daily_lag1',
    'news_index_ecbbadhawkish_quotes_daily_lag1', 'news_index_ecbbadnomon_quotes_daily_lag1', 'news_index_ecbbaddovish_quotes_daily_lag1',
    'news_index_ecbgoodhawkish_non_quotes_daily_lag1', 'news_index_ecbgoodnomon_non_quotes_daily_lag1', 'news_index_ecbgooddovish_non_quotes_daily_lag1',
    'news_index_ecbneutralhawkish_non_quotes_daily_lag1', 'news_index_ecbneutralnomon_non_quotes_daily_lag1', 'news_index_ecbneutraldovish_non_quotes_daily_lag1',
    'news_index_ecbbadhawkish_non_quotes_daily_lag1', 'news_index_ecbbadnomon_non_quotes_daily_lag1', 'news_index_ecbbaddovish_non_quotes_daily_lag1',
 
]

news_indices = {}

for name in file_names_news:
    filepath = PATH_data + '\\' + name + '.xlsx'
    news_indices[name] = process_dataframe(filepath, start_date, end_date)

###

file_names_news_og = [
    
       'news_index_ecbpositive_non_quotes_og', 'news_index_ecbneutral_non_quotes_og', 'news_index_ecbnegative_non_quotes_og',
       'news_index_ecbpositive_quotes_og', 'news_index_ecbneutral_quotes_og', 'news_index_ecbnegative_quotes_og',
       
       'news_index_ecbhawkish_non_quotes_og', 'news_index_ecbnomon_non_quotes_og', 'news_index_ecbdovish_non_quotes_og',
       'news_index_ecbhawkish_quotes_og', 'news_index_ecbnomon_quotes_og', 'news_index_ecbdovish_quotes_og',
       'news_index_ecbgoodhawkish_quotes_og', 'news_index_ecbgoodnomon_quotes_og', 'news_index_ecbgooddovish_quotes_og',
       'news_index_ecbneutralhawkish_quotes_og', 'news_index_ecbneutralnomon_quotes_og', 'news_index_ecbneutraldovish_quotes_og',
       'news_index_ecbbadhawkish_quotes_og', 'news_index_ecbbadnomon_quotes_og', 'news_index_ecbbaddovish_quotes_og',
       'news_index_ecbgoodhawkish_non_quotes_og', 'news_index_ecbgoodnomon_non_quotes_og', 'news_index_ecbgooddovish_non_quotes_og',
       
       'news_index_ecbneutralhawkish_non_quotes_og', 'news_index_ecbneutralnomon_non_quotes_og', 'news_index_ecbneutraldovish_non_quotes_og',
       'news_index_ecbbadhawkish_non_quotes_og', 'news_index_ecbbadnomon_non_quotes_og', 'news_index_ecbbaddovish_non_quotes_og',
        
       'news_index_rising_og', 'news_index_notrend_og', 'news_index_falling_og',
       'news_index_good_og', 'news_index_neutral_og', 'news_index_bad_og',
       
       'news_index_goodrising_og', 'news_index_neutralrising_og', 'news_index_badrising_og',
       'news_index_goodnotrend_og', 'news_index_neutralnotrend_og', 'news_index_badnotrend_og',
       'news_index_goodfalling_og', 'news_index_neutralfalling_og', 'news_index_badfalling_og',
       
       'news_index_inf_number_og', 'news_index_mon_number_og',
       'news_index_ecb_quotes_number_og', 'news_index_ecb_non_quotes_number_og'
      
]

news_indices_og = {}

for name in file_names_news_og:
    filepath = PATH_data + '\\' + name + '.xlsx'
    news_indices_og[name] = process_dataframe(filepath, start_date, end_date)
    
###

file_names_news_lex = [
    
    'news_index_rising_lex', 'news_index_notrend_lex', 'news_index_falling_lex',
    'news_index_ecbhawkish_quotes_lex', 'news_index_ecbnomon_quotes_lex', 'news_index_ecbdovish_quotes_lex',
    'news_index_ecbhawkish_non_quotes_lex', 'news_index_ecbnomon_non_quotes_lex', 'news_index_ecbdovish_non_quotes_lex',
    'news_index_ecbpositive_quotes_lex', 'news_index_ecbneutral_quotes_lex', 'news_index_ecbnegative_quotes_lex',
    'news_index_ecbpositive_non_quotes_lex', 'news_index_ecbneutral_non_quotes_lex', 'news_index_ecbnegative_non_quotes_lex',
    
]

news_indices_lex = {}

for name in file_names_news_lex:
    filepath = PATH_data + '\\' + name + '.xlsx'
    news_indices_lex[name] = process_dataframe(filepath, start_date, end_date)    

###

file_names_ECB_og = [
    'ECB_inf_up_og', 'ECB_inf_same_og', 'ECB_inf_down_og',
    'ECB_mon_dov_og', 'ECB_mon_not_og', 'ECB_mon_haw_og',
    'ECB_out_up_og', 'ECB_out_same_og', 'ECB_out_down_og'
]

ECB_indices_og = {}

for name in file_names_ECB_og:
    filepath = PATH_data + '\\' + name + '.xlsx'
    ECB_indices_og[name] = process_dataframe(filepath, start_date, end_date)

###

def process_dataframe(filepath, start_date, end_date):
    """
    Load, preprocess, and filter a dataframe from a given filepath based on given start and end dates.
    """
    df = pd.read_excel(filepath)
    #df['year_month'] = pd.to_datetime(df['year_month'])
    #df.index = df['year_month']
    df.index = pd.to_datetime(df.iloc[:,0])
    #df.index = df.index.shift(1, freq='M')
    return df.loc[(df.index >= start_date) & (df.index <= end_date)]

###
    
file_names_speeches = ['ECB_speech_inf_up', 'ECB_speech_inf_same', 'ECB_speech_inf_down',
                       'ECB_speech_out_up', 'ECB_speech_out_same', 'ECB_speech_out_down',
                       'ECB_speech_mon_dov', 'ECB_speech_mon_not', 'ECB_speech_mon_haw']

speech_indices = {}

for name in file_names_speeches:
    filepath = PATH_data + '\\' + name + '.xlsx'
    speech_indices[name] = process_dataframe(filepath, start_date, end_date)
    
###

file_names_ECB = [
    'ECB_inf_up', 'ECB_inf_same', 'ECB_inf_down',
    'ECB_mon_dov', 'ECB_mon_not', 'ECB_mon_haw',
    'ECB_out_up', 'ECB_out_same', 'ECB_out_down'
]

ECB_indices = {}

for name in file_names_ECB:
    filepath = PATH_data + '\\' + name + '.xlsx'
    ECB_indices[name] = process_dataframe(filepath, start_date, end_date)


###############################################################################

forecast_q['Date'] = pd.to_datetime(forecast_q['Date']) + pd.offsets.MonthEnd(0)
forecast_q = forecast_q.set_index('Date')[['One-Year-Ahead Direct']] 

forecast_df_m = forecast_q['One-Year-Ahead Direct'][2:].resample('M').interpolate(method='polynomial', order=3)

forecast_q_eu_staff_inf = forecast_q_eu_staff_inf.set_index('Date')[['Inflation Forecast EU Staff']] 
forecast_q_eu_staff_gdp = forecast_q_eu_staff_gdp.set_index('Date')[['GDP Forecast EU Staff']] 

#forecast_df_eu_staff_m = forecast_q_eu_staff['Next year forecast'].resample('M').interpolate(method='polynomial', order=3)

####

first_date = forecast_df_m.index.min() - pd.DateOffset(years=5)
last_date = forecast_df_m.index.min()

new_index = pd.date_range(start=first_date, end=last_date, freq='M')

extended_data = pd.DataFrame(index=new_index)
extended_data.index = pd.to_datetime(extended_data.index)

forecast_df_m = pd.concat([extended_data[:-1], forecast_df_m]).fillna(0)
forecast_df_m = forecast_df_m.loc[(forecast_df_m.index >= start_date) & (forecast_df_m.index <= end_date)]

###

# first_date = forecast_df_eu_staff_m.index.min() - pd.DateOffset(years=3)
# last_date = forecast_df_eu_staff_m.index.min()

# new_index = pd.date_range(start=first_date, end=last_date, freq='M')

# extended_data = pd.DataFrame(index=new_index)
# extended_data.index = pd.to_datetime(extended_data.index)

# forecast_df_eu_staff_m = pd.concat([extended_data[:-1], forecast_df_eu_staff_m]).fillna(0)
# forecast_df_eu_staff_m = forecast_df_eu_staff_m.loc[(forecast_df_eu_staff_m.index >= start_date) & (forecast_df_eu_staff_m.index <= end_date)]

###############################################################################

def process_dataframe(df, col_to_convert=None, set_index_from_col=0, transform_func=transform_date, start_date=start_date, end_date=end_date):
    df = transform_func(df)
    df.set_index(df.iloc[:, set_index_from_col], inplace=True)
    df = df.loc[(df.index >= start_date) & (df.index <= end_date)]
    if col_to_convert is not None:
        df.iloc[:, col_to_convert] = pd.to_numeric(df.iloc[:, col_to_convert], errors='coerce')
    return df

ip_ger_m = process_dataframe(ip_ger_m, 1)
#ip_ea_m = process_dataframe(ip_ea_m, 1)
#inflation_ea_m = process_dataframe(inflation_ea_m, 1)
euro_dollar_m = process_dataframe(euro_dollar_m, 1)

###

data_inf_exp_eu = data_inf_exp_eu.loc[(data_inf_exp_eu.index >= start_date) & (data_inf_exp_eu.index <= end_date)]
data_inf_exp_eu = data_inf_exp_eu.groupby(pd.Grouper(freq="M")).mean().fillna(method='ffill')

# ecb_dfr = process_dataframe(ecb_dfr, transform_func=lambda x: x)
# ecb_dfr.loc[pd.to_datetime('2000-01-01')] = {'Unnamed: 1': 2.0}
# ecb_dfr = ecb_dfr.sort_index()

# ecb_dfr = ecb_dfr.resample('M').first()

ecb_mro = process_dataframe(ecb_mro, transform_func=lambda x: x)
#ecb_mro.loc[pd.to_datetime('2000-01-01')] = {'Unnamed: 1': 2.0}
ecb_mro = ecb_mro.sort_index()

###

data_surv_dates = pd.date_range(start='1999-12-01', periods=301, freq='MS') + pd.Timedelta(days=14)

def assign_period(date, agg_dates):
    for idx, agg_date in enumerate(agg_dates):
        if date < agg_date:
            return idx
    return len(agg_dates)

from tqdm import tqdm

tqdm.pandas()

agg_period = ecb_mro['observation_date'].progress_apply(lambda x: assign_period(x, data_surv_dates))
ecb_mro['Period'] = agg_period

date_mapping = {i: date for i, date in enumerate(pd.date_range(start='1999-12-31', periods=ecb_mro['Period'].max() + 1, freq='M'))}

ecb_mro['t_date'] = ecb_mro['Period'].map(date_mapping)

ecb_mro.index = ecb_mro['t_date']

###

ecb_mro = ecb_mro.resample('M').last()
#ecb_mro = ecb_mro['Unnamed: 3'][:-1]

# monthly_inf_count = process_dataframe(monthly_inf_count, set_index_from_col=0, transform_func=lambda x: x)
# monthly_ecb_quotes_count = process_dataframe(monthly_ecb_quotes_count, set_index_from_col=0, transform_func=lambda x: x)
# monthly_ecb_non_quotes_count = process_dataframe(monthly_ecb_non_quotes_count, set_index_from_col=0, transform_func=lambda x: x)
# monthly_ecb_all_count = process_dataframe(monthly_ecb_all_count, set_index_from_col=0, transform_func=lambda x: x)

# date_inf = list(inflation_ea_m.iloc[:,0])

###############################################################################

columns_to_average = ['pos share', 'neu share', 'neg share', 'pos share PMI', 'neu share PMI',
'neg share PMI', 'index', 'index PMI']

# data_ECB_index_inf = data_ECB_index_inf.groupby(data_ECB_index_inf['date'])[columns_to_average].mean()
# data_ECB_index_inf.reset_index(inplace=True)

# data_ECB_index_inf = data_ECB_index_inf[18:-30]

###############################################################################

def absolute_errors(quant_surv, proff_fore):

    ger_relative_exp_gap_m = np.array(quant_surv) - proff_fore
    ger_abslolute_exp_gap_m = abs(ger_relative_exp_gap_m)
    
    return(ger_relative_exp_gap_m, ger_abslolute_exp_gap_m)

def add_nans_to_dataframe(df, num_nans=60, columns=None):
    """Add NaN rows to the top of a dataframe."""
    nan_df = pd.DataFrame(np.nan, index=range(num_nans), columns=columns if columns is not None else df.columns)
    return pd.concat([nan_df, df], ignore_index=True)

def compute_and_format(array1, array2, index):
    """Element-wise multiplication of two arrays, and format as DataFrame."""
    product = np.array(array1) * np.array(array2)
    df = pd.DataFrame(product)
    df.index = index
    return df

#ger_relative_exp_gap_m_CP_Reuter, ger_abslolute_exp_gap_m_CP_Reuter = absolute_errors(processed_data['TOT'], forecast_df_m['One-Year-Ahead'])
#ger_relative_exp_gap_m_CP_Reuter, ger_abslolute_exp_gap_m_CP_Reuter = absolute_errors(processed_data['TOT'], forecast_df_m.iloc[:,0])
#ger_relative_exp_gap_m_CP_Real, ger_abslolute_exp_gap_m_CP_Real = absolute_errors(processed_data['TOT'], inflation_ger_m.iloc[:,1])

###############################################################################

start = 1

###

Regression_data_m = pd.DataFrame()
#Regression_data_m['Eurozone Industrial Production Gap'] = ip_ea_m.iloc[start:,2]
#Regression_data_m['Eurozone Industrial Production'] = ip_ea_m.iloc[start:,1]
#Regression_data_m['Consensus Poll Forecast'] = list(consensus_forecast.iloc[start:,1])
Regression_data_m['Germany Unemployment'] = unemp_ger_m
Regression_data_m['German Industrial Production Gap'] = ip_ger_m.iloc[start:,2]
Regression_data_m['German Industrial Production'] = ip_ger_m.iloc[start:,1]
Regression_data_m['German Inflation Year-on-Year'] = list(inflation_ger_m.iloc[start:,1])
# Regression_data_m['German Inflation Year-on-Year Core'] = list(inflation_ger_m_cor.iloc[start:,1])
# Regression_data_m['German Inflation Year-on-Year Food'] = list(inflation_ger_m_fb.iloc[start:,1])
# Regression_data_m['German Inflation Year-on-Year Energy'] = list(inflation_ger_m_energy.iloc[start:,1])
# Regression_data_m['ECB DFR'] = list(ecb_dfr.iloc[start:,1])
Regression_data_m['ECB MRO'] = list(ecb_mro[(start):]['ECBMRRFR'])

positive_surprise_values = list(MRO_surprise['Positive_Surprise'][start:])
if len(positive_surprise_values) < len(Regression_data_m):
    positive_surprise_values.extend([np.nan] * (len(Regression_data_m) - len(positive_surprise_values)))

Regression_data_m['ECB MRO POS'] = positive_surprise_values

negative_surprise_values = list(MRO_surprise['Negative_Surprise'][start:])
if len(negative_surprise_values) < len(Regression_data_m):
    negative_surprise_values.extend([np.nan] * (len(Regression_data_m) - len(negative_surprise_values)))

Regression_data_m['ECB MRO POS'] = positive_surprise_values
Regression_data_m['ECB MRO NEG'] = negative_surprise_values

# Regression_data_m['ECB MRO POS'] = list(MRO_surprise['Positive_Surprise'][start:])
# Regression_data_m['ECB MRO NEG'] = list(MRO_surprise['Negative_Surprise'][start:])
# Regression_data_m['Eonita'] = list(eonita['Unnamed: 1'][start:])

# start = 0

# #Regression_data_m['News Inflation Index'] = list(dire_senti_m.iloc[start:,0])
# Regression_data_m['News Inflation Count'] = list(monthly_inf_count.iloc[:,1])

# #Regression_data_m['News Inflation Sentiment Index'] = list(sent_m.iloc[start:,0])

# start = 1

# #Regression_data_m['News Inflation Direction Index'] = list(dire_m.iloc[start:,0])

# Regression_data_m['News Inflation Count'] = list(monthly_inf_count.iloc[:,1])

# Regression_data_m['ECB Quote Count'] = list(monthly_ecb_quotes_count.iloc[:,1])
# Regression_data_m['ECB Non Quote Count'] = list(monthly_ecb_non_quotes_count.iloc[:,1])
# Regression_data_m['ECB All Count'] = list(monthly_ecb_all_count.iloc[:,1])

###############################################################################

#Regression_data_m['ECB News Index'] = list(data_comb_ecb_index_m.iloc[:,0])

#Regression_data_m['Eurozone Inflation Professionell Forecasts'] = list(data_inf_exp_eu.iloc[start:,0])

Regression_data_m['ED Exchange Rate'] = list(euro_dollar_m.iloc[start:,1])
Regression_data_m['Eurostoxx'] = list(eurostoxx.iloc[start:,1])

Regression_data_m['Germany Conf'] = list(data_out_ger.iloc[start:,0])
Regression_data_m['Germany Past Fin'] = list(data_out_ger.iloc[start:,1])
Regression_data_m['Germany Future Fin'] = list(data_out_ger.iloc[start:,2])
Regression_data_m['Germany Past Eco'] = list(data_out_ger.iloc[start:,3])
Regression_data_m['Germany Future Eco'] = list(data_out_ger.iloc[start:,4])
Regression_data_m['Germany Future Un'] = list(data_out_ger.iloc[start:,7])
Regression_data_m['Germany Fin Status'] = list(data_out_ger.iloc[start:,8])

#Regression_data_m['PR Mon'] = list(PR['r_mp_rest'] - PR['r_mp_acco'])[start:]
#Regression_data_m['PR Eco'] = list(PR['r_ec_posi'] - PR['r_ec_nega'])[start:]

# Regression_data_m['PR Mon Acc'] = list(PR['r_mp_acco'])[start:]
# Regression_data_m['PR Mon Res'] = list(PR['r_mp_rest'])[start:]

# Regression_data_m['PR Eco Pos'] = list(PR['r_ec_posi'])[start:]
# Regression_data_m['PR Eco Neg'] = list(PR['r_ec_nega'])[start:]

Regression_data_m['Ifo_Business_climate'] = list(Ifo['Business_climate'])[start:]
Regression_data_m['Ifo_Business_situation'] = list(Ifo['Business_situation'])[start:]
Regression_data_m['Ifo_Business_expectations'] = list(Ifo['Business_expectations'])[start:]

#Regression_data_m['Consensus Forecast DE'] = list(consensus_forecast_de['Final Forecast DE'])[start:]
#Regression_data_m['Consensus Forecast EA'] = list(consensus_forecast_ea['Final Forecast EA'])[start:]

# Regression_data_m['German Absolute CP Expectations Gap Quant Reuter'] = list(ger_abslolute_exp_gap_m_CP_Reuter[start:])
# Regression_data_m['German Relative CP Expectations Gap Quant Reuter'] = list(ger_relative_exp_gap_m_CP_Reuter[start:])

# Regression_data_m['German Absolute CP Expectations Gap Quant Real'] = list(ger_abslolute_exp_gap_m_CP_Real[start:])
# Regression_data_m['German Relative CP Expectations Gap Quant Real'] = list(ger_relative_exp_gap_m_CP_Real[start:])

#Regression_data_m['Reuter Poll Forecast'] = list(forecast_df_m['One-Year-Ahead'][start:])
#Regression_data_m['Reuter Poll Forecast'] = list(forecast_df_m.iloc[:,0][start:])

reuters_poll = list(forecast_df_m.iloc[:,0][start:])
if len(reuters_poll) < len(Regression_data_m):
    reuters_poll.extend([np.nan] * (len(Regression_data_m) - len(reuters_poll)))
    
Regression_data_m['Reuter Poll Forecast'] = reuters_poll

#Regression_data_m['ECB Forecast'] = list(forecast_df_eu_staff_m.iloc[:,0][start:])

# for group, data_list in processed_data.items():
#     Regression_data_m[f'German Household Inflation Expectations CP.{group}'] = data_list[start:]
    
# for group, data_list in processed_data_per.items():
#     Regression_data_m[f'German Household Inflation Expectations CP.{group}.per'] = data_list[start:]
    
#Regression_data_m['Eurozone Inflation'] = list(inflation_ea_m.iloc[start:,1])

Regression_data_m['date'] = unemp_ger_m.index

forecast_q_eu_staff_inf['date'] = forecast_q_eu_staff_inf.index
forecast_q_eu_staff_gdp['date'] = forecast_q_eu_staff_gdp.index

Regression_data_m = Regression_data_m.merge(forecast_q_eu_staff_inf,on='date',how='left')
Regression_data_m = Regression_data_m.merge(forecast_q_eu_staff_gdp,on='date',how='left')

Regression_data_m['German Inflation Balanced'] = list(germ_balanced.iloc[:-10,1])
Regression_data_m['German Inflation Balanced Primary'] = list(germ_balanced_ed1.iloc[:-10,1])
Regression_data_m['German Inflation Balanced Secondary'] = list(germ_balanced_ed2.iloc[:-10,1])
Regression_data_m['German Inflation Balanced Further'] = list(germ_balanced_ed3.iloc[:-10,1])

Regression_data_m['German Inflation Balanced Perc'] = list(germ_balanced_perc.iloc[:-10,1])
Regression_data_m['German Inflation Balanced Primary Perc'] = list(germ_balanced_ed1_perc.iloc[:-10,1])
Regression_data_m['German Inflation Balanced Secondary Perc'] = list(germ_balanced_ed2_perc.iloc[:-10,1])
Regression_data_m['German Inflation Balanced Further Perc'] = list(germ_balanced_ed3_perc.iloc[:-10,1])

Regression_data_m['VDAX'] = list(VDAX_NEW['VDAX-NEW VOLATILITY INDEX - PRICE INDEX'][126:-7])
Regression_data_m['DAX'] = list(DAX['DAX PERFORMANCE - PRICE INDEX'][126:-7])

start = 1

# for name, df in islice(ECB_indices.items(), 3):
    
#     df = df.resample('M').ffill()
#     Regression_data_m[name] = list(df.iloc[start:, 1]*100)
    
# for name, df in speech_indices.items():
    
#     Regression_data_m[name] = list(df.iloc[start:, 1]*100)
    
# for name, df in news_indices_lex.items():
    
#     Regression_data_m[name] = list(df.iloc[start:, 1]*100)

# Regression_data_m['Double_Count_ECB'] = [0]*len(Regression_data_m)
# Regression_data_m['Double_Count_ECB'][-156:] = double_month_count.iloc[:,1]

for name, df in news_indices.items():
    
    df_to_merge = df.iloc[start:, ].rename(columns={df.columns[1]: name})
    #df_to_merge.rename(columns={df.columns[0]: 'date'}, inplace = True)
    
    df_to_merge['date'] = df_to_merge.index
    df_to_merge.iloc[:, 1] = df_to_merge.iloc[:, 1] * 100
    
    Regression_data_m = pd.merge(Regression_data_m, df_to_merge.iloc[:,[1,2]], on='date', how='outer')
    
    #Regression_data_m[name] = list(df.iloc[start:, 1]*100)
    
for name, df in islice(ECB_indices_og.items(), 9):
    df = df.sort_index()
    Regression_data_m[name] = df.reindex(Regression_data_m['date'], method='ffill').iloc[:, 1].values * 100

Regression_data_m.to_excel(PATH_data + '\\regression_data_monthly_2_inf.xlsx')

###############################################################################

ecb_mro = load_excel_data(PATH_data, 'ECBMRRFR.xls', skip_rows=10)

dates = ECB_indices_og['ECB_inf_down_og']['t_date'].index

ECB_full_data = pd.DataFrame()

for name, df in islice(ECB_indices_og.items(), 3):
    
    ECB_full_data[name] = list(df.iloc[:, 1]*100)

ECB_full_data.index = dates
ECB_full_data['date'] = dates

Regression_data_m = pd.DataFrame()

for name, df in islice(ECB_indices_og.items(), 9):
    
    Regression_data_m[name] = list(df.iloc[:, 1]*100)

Regression_data_m.index = dates
Regression_data_m['date'] = dates

for name, df in news_indices_og.items():
    
    df = df[df.index.isin(dates)]
    df = df.reindex(dates, fill_value=0)
    
    Regression_data_m[name] = list(df.iloc[:, 1]*100)

def merge_month_year(df1, df2, date_col2, data_col, new_col_name):
    """
    Merges two dataframes on the year and month of the specified date columns and adds a specified column.

    Parameters:
    df1 (pd.DataFrame): The first dataframe containing the data to be added.
    df2 (pd.DataFrame): The second dataframe.
    date_col2 (str): The name of the date column in the second dataframe (or the index name if it's the index).
    data_col (str): The name of the column to be added from the first dataframe.
    new_col_name (str): The new name for the column to be added in the merged dataframe.

    Returns:
    pd.DataFrame: The merged dataframe with the specified column added.
    """
    # Ensure the date columns are in datetime format
    df1.index = pd.to_datetime(df1.index)
    if date_col2 in df2.columns:
        df2[date_col2] = pd.to_datetime(df2[date_col2])
    else:
        df2.index = pd.to_datetime(df2.index)
        df2 = df2.reset_index().rename(columns={'index': date_col2})
    
    # Extract year and month
    df1['year_month'] = df1.index.to_period('M')
    df2['year_month'] = df2[date_col2].dt.to_period('M')
    
    # Merge the dataframes on the year_month column
    merged_df = pd.merge(df2, df1[[data_col, 'year_month']], on='year_month', how='left')
    
    # Rename the specified column
    merged_df = merged_df.rename(columns={data_col: new_col_name})
    
    # Drop the year_month column if not needed
    merged_df = merged_df.drop(columns=['year_month'])
    
    return merged_df

unemp_ger_m = pd.DataFrame(unemp_ger_m)
unemp_ger_m['Germany'] = list(unemp_ger_m.iloc[:,0])

Regression_data_m = merge_month_year(unemp_ger_m, Regression_data_m,'date', 'Germany', 'Germany Unemployment')
Regression_data_m = merge_month_year(ip_ger_m, Regression_data_m, 'date', 'cyclical', 'German Industrial Production Gap')
Regression_data_m = merge_month_year(inflation_ger_m, Regression_data_m, 'date', 'Inflation', 'German Inflation Year-on-Year')
Regression_data_m = merge_month_year(MRO_surprise, Regression_data_m, 'date', 'Positive_Surprise', 'ECB MRO POS')
Regression_data_m = merge_month_year(MRO_surprise, Regression_data_m, 'date', 'Negative_Surprise', 'ECB MRO NEG')
Regression_data_m = merge_month_year(DAX, Regression_data_m, 'date', 'DAX PERFORMANCE - PRICE INDEX', 'DAX')
Regression_data_m = merge_month_year(VDAX_NEW, Regression_data_m, 'date', 'VDAX-NEW VOLATILITY INDEX - PRICE INDEX', 'VDAX')

# ecb_mro['year_month'] = ecb_mro['observation_date'].dt.to_period('M')
# ecb_mro = ecb_mro.groupby('year_month').last().reset_index()
# ecb_mro.index = ecb_mro['observation_date']
# ecb_mro = ecb_mro[42:]

Regression_data_m['end_date'] = Regression_data_m['date'] + pd.Timedelta(days=14)

ecb_mro = ecb_mro.reset_index()  
full_date_range = pd.date_range(
    start=ecb_mro['observation_date'].min(),
    end=ecb_mro['observation_date'].max(),
    freq='D'
)

full_ecb_mro = pd.DataFrame({'observation_date': full_date_range})

full_ecb_mro = pd.merge(full_ecb_mro, ecb_mro[['observation_date', 'ECBMRRFR']], on='observation_date', how='left')
full_ecb_mro['ECBMRRFR'] = full_ecb_mro['ECBMRRFR'].fillna(method='ffill')

Regression_data_m = Regression_data_m.merge(
    full_ecb_mro,
    left_on='end_date',
    right_on='observation_date',
    how='left'
)

Regression_data_m = Regression_data_m.drop(columns=['observation_date'])

Regression_data_m = Regression_data_m.rename(columns={'ECBMRRFR': 'ECB MRO'})

# # Map ecb_mro values to Regression_data_m
# ecb_mro = ecb_mro.reset_index()
# Regression_data_m['ECBMRRFR'] = Regression_data_m['date'].apply(
#     lambda d: ecb_mro.loc[
#         (ecb_mro['observation_date'] >= d) & (ecb_mro['observation_date'] <= d + pd.Timedelta(days=14)),
#         'ECBMRRFR'
#     ].iloc[0]
# )

# # Remove the temporary column
# Regression_data_m = Regression_data_m.drop(columns=['end_date'])

#Regression_data_m = merge_month_year(ecb_mro, Regression_data_m, 'date', 'ECBMRRFR', 'ECB MRO')

data_ECB_sents_monetary = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\ECB\press_sents_full_index_labeled_mon.xlsx')
data_ECB_sents_monetary['date'] = pd.to_datetime(data_ECB_sents_monetary['date'])

data_ECB_sents_monetary = data_ECB_sents_monetary.sort_values(by='date')

data_surv_dates = sorted(list(set(data_ECB_sents_monetary['date'])))

# PR is missing two dates 2007-08-02 ,2014-10-26 which we need to filter out
#PR['date'] = PR.index

start_date = data_surv_dates[0]
end_date = data_surv_dates[-1]

# Filter for rows that are either outside the PR date range
# or within the range and also present in PR.date
filtered_data = Regression_data_m[
    (Regression_data_m['date'] < start_date) |
    (Regression_data_m['date'] > end_date) |
    (Regression_data_m['date'].isin(data_surv_dates))
]

# Update Regression_data_m to only include the filtered rows and reset the index
Regression_data_m = filtered_data.reset_index(drop=True)

# Regression_data_m['PR Mon Acc'] = [np.nan] * 47 + list(PR['r_mp_acco']) + [np.nan] * 24 
# Regression_data_m['PR Mon Res'] = [np.nan] * 47 + list(PR['r_mp_rest']) + [np.nan] * 24

# Regression_data_m['PR Eco Pos'] = [np.nan] * 47 + list(PR['r_ec_posi']) + [np.nan] * 24
# Regression_data_m['PR Eco Neg'] = [np.nan] * 47 + list(PR['r_ec_nega']) + [np.nan] * 24 

#Regression_data_m['Inf Up Lex'] = data_ECB_index_inf['pos share']
#Regression_data_m['Inf Down Lex'] = data_ECB_index_inf['neg share']

# Regression_data_m = merge_month_year(PR, Regression_data_m, 'date', 'date', 'r_mp_acco', 'PR Mon Acc')
# Regression_data_m = merge_month_year(PR, Regression_data_m, 'date', 'date', 'r_mp_rest', 'PR Mon Res')

# Regression_data_m = merge_month_year(PR, Regression_data_m, 'date', 'date', 'r_ec_posi', 'PR Eco Pos')
# Regression_data_m = merge_month_year(PR, Regression_data_m, 'date', 'date', 'r_ec_nega', 'PR Eco Neg')

forecast_df_m['date'] = forecast_df_m.index
forecast_df_m['values'] = forecast_df_m.iloc[:,0]

forecast_q_eu_staff_inf['date'] = forecast_q_eu_staff_inf.index
forecast_q_eu_staff_inf['values'] = forecast_q_eu_staff_inf.iloc[:,0]

forecast_q_eu_staff_gdp['date'] = forecast_q_eu_staff_gdp.index
forecast_q_eu_staff_gdp['values'] = forecast_q_eu_staff_gdp.iloc[:,0]

Regression_data_m = merge_month_year(forecast_df_m, Regression_data_m, 'date', 'values', 'Reuter Poll Forecast')
Regression_data_m = merge_month_year(forecast_q_eu_staff_inf, Regression_data_m, 'date', 'values', 'Inflation Forecast EU Staff')
Regression_data_m = merge_month_year(forecast_q_eu_staff_gdp, Regression_data_m, 'date', 'values', 'GDP Forecast EU Staff')
Regression_data_m = merge_month_year(euro_dollar_m, Regression_data_m, 'date', 'Unnamed: 1', 'ED Exchange Rate')
Regression_data_m = merge_month_year(eurostoxx, Regression_data_m, 'date', 'OBS.VALUE', 'Eurostoxx')

Regression_data_m = merge_month_year(data_out_ger, Regression_data_m, 'date', 'CONS.DE.TOT.COF.BS.M', 'Germany Conf')
Regression_data_m = merge_month_year(data_out_ger, Regression_data_m, 'date', 'CONS.DE.TOT.2.BS.M', 'Germany Future Fin')
Regression_data_m = merge_month_year(data_out_ger, Regression_data_m, 'date', 'CONS.DE.TOT.4.BS.M', 'Germany Future Eco')
Regression_data_m = merge_month_year(data_out_ger, Regression_data_m, 'date', 'CONS.DE.TOT.7.BS.M', 'Germany Future Un')

germ_balanced.index = germ_balanced['TOT']

Regression_data_m = merge_month_year(germ_balanced, Regression_data_m, 'date', 'CONS.DE.TOT.6.B.M', 'Household Inflation Expectations')

#Regression_data_m = merge_month_year(inflation_ea_m, Regression_data_m, 'date', 'Inflation', 'Eurozone Inflation')

Regression_data_m.to_excel(PATH_data + '\\regression_data_monthly_2_ECB_2_og.xlsx')

#ECB_full_data.to_excel(PATH_data + '\\regression_data_monthly_2_ECB_2_og_full.xlsx')