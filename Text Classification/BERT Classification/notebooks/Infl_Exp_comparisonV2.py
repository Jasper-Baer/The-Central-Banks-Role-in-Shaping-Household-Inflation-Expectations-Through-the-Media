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
PATH_code = r"D:\Studium\PhD\Github\Single-Author\Code\Plots"

os.chdir(PATH_code)

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
forecast_q_eu_staff_gdp = forecast_q_eu_staff.dropna(subset = ['GDP Forecast EU Staff'])

ecb_mro = load_excel_data(PATH_data, 'ECBMRRFR.xls', skip_rows=10)
germany_harmonised_inflation_m = load_excel_data(PATH_data, 'CPHPTT01DEM659N.xls', skip_rows=10)

unemp_ger_m = load_excel_data(PATH_data, 'Germany_Unemployment.xlsx', skip_rows=9, sheet_name = 'Sheet 1').iloc[1, :].T
unemp_ger_m = unemp_ger_m.iloc[1::2]

fred_monthly = load_excel_data(PATH_data, 'Fred_data_monthly.xlsx', skip_rows=6)
ip_ger_m = fred_monthly.iloc[:-10, 0:2]
ip_ea_m = fred_monthly.iloc[:-199, 6:8]

cycle, trend = sm.tsa.filters.hpfilter(ip_ger_m['value'], lamb=14400)
ip_ger_m['cyclical'] = cycle

inflation_ger_m = load_excel_data(PATH_data, 'Inflation_2.xlsx', sheet_name = "Headline Inflation")

euro_dollar_m = load_excel_data(PATH_data, 'EXUSEU.xls')[10:]
eurostoxx = load_excel_data(PATH_data, 'Eurostoxx50.xlsx')[['DATE', 'OBS.VALUE']]

MRO_surprise = load_excel_data(PATH_data, 'Reuters_Poll2.xlsx')[10:].iloc[:,[3,7]]
MRO_surprise.iloc[:,1] = MRO_surprise.iloc[:,1].fillna(0)
MRO_surprise['Positive_Surprise'] = np.where(MRO_surprise.iloc[:,1] > 0, MRO_surprise.iloc[:,1], 0)
MRO_surprise['Negative_Surprise'] = abs(np.where(MRO_surprise.iloc[:,1] < 0, MRO_surprise.iloc[:,1], 0))

data_inf_exp_eu = pd.read_excel(PATH_data + '\Infl_Exp.xlsx', index_col = 0)

data_out_ger = pd.read_excel(PATH_data + '\consumer_total_nsa_nace2.xlsx', sheet_name='CONSUMER MONTHLY')[['Unnamed: 0', 'CONS.DE.TOT.COF.B.M', 'CONS.DE.TOT.1.B.M',  'CONS.DE.TOT.2.B.M', 'CONS.DE.TOT.3.B.M',  'CONS.DE.TOT.4.B.M', 'CONS.DE.TOT.5.B.M',  'CONS.DE.TOT.6.B.M', 'CONS.DE.TOT.7.B.M', 'CONS.DE.TOT.12.B.M']]

VDAX_NEW = pd.read_excel(PATH_data + '\DAX.xlsx').iloc[:, 0:2]
VDAX_NEW['Datum'] = pd.to_datetime(VDAX_NEW['Date1'], format='%Y.%m.%d')
VDAX_NEW.set_index('Datum', inplace=True)

DAX = pd.read_excel(PATH_data + '\DAX.xlsx').iloc[:, 2:4]
DAX['Datum'] = pd.to_datetime(DAX['Date2'], format='%Y.%m.%d')
DAX.set_index('Datum', inplace=True)

###############################################################################
    
PR = load_csv_data('D:\Studium\PhD\Github\Single-Author\Code\Regression', 'cbci_data.csv')
PR['date'] = pd.to_datetime(PR['date'])
PR.index = PR['date'] 
PR = PR.drop('date', axis=1)

data_surv_dates = list(PR.index)
    
###############################################################################

germ_balanced = pd.read_excel(PATH_data + "\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name="TOT")[['TOT','CONS.DE.TOT.6.B.M']][180:]
germ_balanced_ed1 = pd.read_excel(PATH_data + "\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name="ED1")[['ED1','CONS.DE.ED1.6.B.M']][180:]
germ_balanced_ed2 = pd.read_excel(PATH_data + "\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name="ED2")[['ED2','CONS.DE.ED2.6.B.M']][180:]
germ_balanced_ed3 = pd.read_excel(PATH_data + "\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name="ED3")[['ED3','CONS.DE.ED3.6.B.M']][180:]

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

###

eurostoxx = transform_date(eurostoxx)
eurostoxx = eurostoxx.loc[(eurostoxx.index >= start_date) & (eurostoxx.index <= end_date)]
eurostoxx.iloc[:,1] = pd.to_numeric(eurostoxx.iloc[:,1])

###

MRO_surprise = transform_date(MRO_surprise)
MRO_surprise = MRO_surprise.loc[(MRO_surprise.index >= start_date) & (MRO_surprise.index <= end_date)]

###############################################################################

def process_dataframe(filepath, start_date, end_date):
    """
    Load, preprocess, and filter a dataframe from a given filepath based on given start and end dates.
    """
    df = pd.read_excel(filepath)   
    df.index = pd.to_datetime(df.iloc[:,0])
    
    return df.loc[(df.index >= start_date) & (df.index <= end_date)]

file_names_news = [
    'news_index_ecbhawkish_non_quotes', 'news_index_ecbnomon_non_quotes', 'news_index_ecbdovish_non_quotes',
    'news_index_ecbhawkish_quotes', 'news_index_ecbnomon_quotes', 'news_index_ecbdovish_quotes',
 
    'news_index_ecbpositive_non_quotes', 'news_index_ecbneutral_non_quotes', 'news_index_ecbnegative_non_quotes',
    'news_index_ecbpositive_quotes', 'news_index_ecbneutral_quotes', 'news_index_ecbnegative_quotes',
    
    'news_index_rising', 'news_index_notrend', 'news_index_falling',
    'news_index_good', 'news_index_neutral', 'news_index_bad',
       
    'news_index_ecb_quotes_number', 'news_index_ecb_non_quotes_number',
       
    'news_index_inf_number', 'news_index_mon_number'
     
]

news_indices = {}

for name in file_names_news:
    filepath = PATH_data + '\\' + 'Neu' + '\\' + name + '.xlsx'
    news_indices[name] = process_dataframe(filepath, start_date, end_date)

###

file_names_news_og = [
    
       'news_index_ecbpositive_non_quotes_og', 'news_index_ecbneutral_non_quotes_og', 'news_index_ecbnegative_non_quotes_og',
       'news_index_ecbpositive_quotes_og', 'news_index_ecbneutral_quotes_og', 'news_index_ecbnegative_quotes_og',
       
       'news_index_ecbhawkish_non_quotes_og', 'news_index_ecbnomon_non_quotes_og', 'news_index_ecbdovish_non_quotes_og',
       'news_index_ecbhawkish_quotes_og', 'news_index_ecbnomon_quotes_og', 'news_index_ecbdovish_quotes_og',
            
       'news_index_rising_og', 'news_index_notrend_og', 'news_index_falling_og',
       'news_index_good_og', 'news_index_neutral_og', 'news_index_bad_og',
       
       'news_index_inf_number_og', 'news_index_mon_number_og',
       'news_index_ecb_quotes_number_og', 'news_index_ecb_non_quotes_number_og'
      
]

news_indices_og = {}

for name in file_names_news_og:
    filepath = PATH_data + '\\' + name + '.xlsx'
    news_indices_og[name] = process_dataframe(filepath, start_date, end_date)
    
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
    df.index = pd.to_datetime(df.iloc[:,0])
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

####

first_date = forecast_df_m.index.min() - pd.DateOffset(years=5)
last_date = forecast_df_m.index.min()

new_index = pd.date_range(start=first_date, end=last_date, freq='M')

extended_data = pd.DataFrame(index=new_index)
extended_data.index = pd.to_datetime(extended_data.index)

forecast_df_m = pd.concat([extended_data[:-1], forecast_df_m]).fillna(0)
forecast_df_m = forecast_df_m.loc[(forecast_df_m.index >= start_date) & (forecast_df_m.index <= end_date)]

###############################################################################

def process_dataframe(df, col_to_convert=None, set_index_from_col=0, transform_func=transform_date, start_date=start_date, end_date=end_date):
    df = transform_func(df)
    df.set_index(df.iloc[:, set_index_from_col], inplace=True)
    df = df.loc[(df.index >= start_date) & (df.index <= end_date)]
    if col_to_convert is not None:
        df.iloc[:, col_to_convert] = pd.to_numeric(df.iloc[:, col_to_convert], errors='coerce')
    return df

ip_ger_m = process_dataframe(ip_ger_m, 1)
euro_dollar_m = process_dataframe(euro_dollar_m, 1)

###

data_inf_exp_eu = data_inf_exp_eu.loc[(data_inf_exp_eu.index >= start_date) & (data_inf_exp_eu.index <= end_date)]
data_inf_exp_eu = data_inf_exp_eu.groupby(pd.Grouper(freq="M")).mean().fillna(method='ffill')

ecb_mro = process_dataframe(ecb_mro, transform_func=lambda x: x)
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

###############################################################################

start = 1

###

Regression_data_m = pd.DataFrame()
Regression_data_m['Germany Unemployment'] = unemp_ger_m
Regression_data_m['German Industrial Production Gap'] = ip_ger_m.iloc[start:,2]
Regression_data_m['German Industrial Production'] = ip_ger_m.iloc[start:,1]
Regression_data_m['German Inflation Year-on-Year'] = list(inflation_ger_m.iloc[start:,1])
Regression_data_m['ECB MRO'] = list(ecb_mro[(start):]['ECBMRRFR'])

positive_surprise_values = list(MRO_surprise['Positive_Surprise'][start:])
if len(positive_surprise_values) < len(Regression_data_m):
    positive_surprise_values.extend([np.nan] * (len(Regression_data_m) - len(positive_surprise_values)))

negative_surprise_values = list(MRO_surprise['Negative_Surprise'][start:])
if len(negative_surprise_values) < len(Regression_data_m):
    negative_surprise_values.extend([np.nan] * (len(Regression_data_m) - len(negative_surprise_values)))

Regression_data_m['ECB MRO POS'] = positive_surprise_values
Regression_data_m['ECB MRO NEG'] = negative_surprise_values

###############################################################################

Regression_data_m['ED Exchange Rate'] = list(euro_dollar_m.iloc[start:,1])
Regression_data_m['Eurostoxx'] = list(eurostoxx.iloc[start:,1])

Regression_data_m['Germany Conf'] = list(data_out_ger.iloc[start:,0])

reuters_poll = list(forecast_df_m.iloc[:,0][start:])
if len(reuters_poll) < len(Regression_data_m):
    reuters_poll.extend([np.nan] * (len(Regression_data_m) - len(reuters_poll)))
    
Regression_data_m['Reuter Poll Forecast'] = reuters_poll

Regression_data_m['date'] = unemp_ger_m.index

forecast_q_eu_staff_inf['date'] = forecast_q_eu_staff_inf.index
forecast_q_eu_staff_gdp['date'] = forecast_q_eu_staff_gdp.index


forecast_q_eu_staff_inf['values'] = forecast_q_eu_staff_inf.iloc[:,0]
forecast_q_eu_staff_gdp['values'] = forecast_q_eu_staff_gdp.iloc[:,0]

Regression_data_m = Regression_data_m.merge(forecast_q_eu_staff_inf,on='date',how='left')
Regression_data_m = Regression_data_m.merge(forecast_q_eu_staff_gdp,on='date',how='left')

Regression_data_m['German Inflation Balanced'] = list(germ_balanced.iloc[:-10,1])
Regression_data_m['German Inflation Balanced Primary'] = list(germ_balanced_ed1.iloc[:-10,1])
Regression_data_m['German Inflation Balanced Secondary'] = list(germ_balanced_ed2.iloc[:-10,1])
Regression_data_m['German Inflation Balanced Further'] = list(germ_balanced_ed3.iloc[:-10,1])

Regression_data_m['VDAX'] = list(VDAX_NEW['VDAX-NEW VOLATILITY INDEX - PRICE INDEX'][126:-7])
Regression_data_m['DAX'] = list(DAX['DAX PERFORMANCE - PRICE INDEX'][126:-7])

start = 1

for name, df in news_indices.items():
    
    df_to_merge = df.iloc[start:, ].rename(columns={df.columns[1]: name})
    df_to_merge['date'] = df_to_merge.index
    df_to_merge.iloc[:, 1] = df_to_merge.iloc[:, 1] * 100
    
    Regression_data_m = pd.merge(Regression_data_m, df_to_merge.iloc[:,[1,2]], on='date', how='outer')
    
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

data_ECB_sents_monetary = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\ECB\press_sents_full_index_labeled_mon.xlsx')
data_ECB_sents_monetary['date'] = pd.to_datetime(data_ECB_sents_monetary['date'])

data_ECB_sents_monetary = data_ECB_sents_monetary.sort_values(by='date')

data_surv_dates = sorted(list(set(data_ECB_sents_monetary['date'])))

start_date = data_surv_dates[0]
end_date = data_surv_dates[-1]

filtered_data = Regression_data_m[
    (Regression_data_m['date'] < start_date) |
    (Regression_data_m['date'] > end_date) |
    (Regression_data_m['date'].isin(data_surv_dates))
]

Regression_data_m = filtered_data.reset_index(drop=True)

forecast_df_m['date'] = forecast_df_m.index
forecast_df_m['values'] = forecast_df_m.iloc[:,0]

forecast_q_eu_staff_gdp['date'] = forecast_q_eu_staff_gdp.index
forecast_q_eu_staff_gdp['values'] = forecast_q_eu_staff_gdp.iloc[:,0]

Regression_data_m = merge_month_year(forecast_df_m, Regression_data_m, 'date', 'values', 'Reuter Poll Forecast')
Regression_data_m = merge_month_year(forecast_q_eu_staff_inf, Regression_data_m, 'date', 'values', 'Inflation Forecast EU Staff')
Regression_data_m = merge_month_year(forecast_q_eu_staff_gdp, Regression_data_m, 'date', 'values', 'GDP Forecast EU Staff')
Regression_data_m = merge_month_year(euro_dollar_m, Regression_data_m, 'date', 'Unnamed: 1', 'ED Exchange Rate')
Regression_data_m = merge_month_year(eurostoxx, Regression_data_m, 'date', 'OBS.VALUE', 'Eurostoxx')

Regression_data_m = merge_month_year(data_out_ger, Regression_data_m, 'date', 'CONS.DE.TOT.COF.B.M', 'Germany Conf')

germ_balanced.index = germ_balanced['TOT']

Regression_data_m = merge_month_year(germ_balanced, Regression_data_m, 'date', 'CONS.DE.TOT.6.B.M', 'Household Inflation Expectations')

Regression_data_m.to_excel(PATH_data + '\\regression_data_monthly_2_ECB_2_og.xlsx')