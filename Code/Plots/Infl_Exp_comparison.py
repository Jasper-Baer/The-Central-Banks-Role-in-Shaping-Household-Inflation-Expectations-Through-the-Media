# -*- coding: utf-8 -*-
"""
Created on Tue Dec 20 17:11:31 2022

@author: jbaer
"""

import pandas as pd
import numpy as np

import warnings
import os

from dateutil.relativedelta import relativedelta

warnings.simplefilter(action='ignore', category=FutureWarning)
PATH = r"D:\Studium\PhD\Github\Single-Author\Code\Plots"
#PATH = r"D:\Single Author\Github\Single-Author\Code\Plots"
os.chdir(PATH)

from Data_Prep_Supp import transform_date, scale_ECB_index, rolling_quant
from Survey_Quantification import recursive_mean, stm

start_date = '1999-12-31'
end_date = '2019-01-01'

start_date_hist_berk_1 = '1998-10-31'
start_date_hist = '1995-12-31'

##############################################################################
        
##############################################################################
# Inflation
##############################################################################

forecast_df = pd.DataFrame()

for year in range(2000, 2021):
    
   inflation_poll = pd.read_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Reuters Poll\Inflation_Forecast_' + str(year) + '.xlsx')
   inflation_poll =  inflation_poll[7:9]
   
   date = inflation_poll.iloc[0,:]
   median = inflation_poll.iloc[1,:]
   
   inflation_poll = pd.DataFrame({'Date': date, 'Median': median, 'Target': year})[1:]
   
   forecast_df = forecast_df.append(inflation_poll, ignore_index=True)
 
forecast_df['Date'] = pd.to_datetime(forecast_df['Date'])

forecast_df = forecast_df.dropna()
forecast_df = forecast_df.reset_index(drop = True)

#forecast_df.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Reuters Poll\Forecast_Inflation_Reuter.xlsx')

# def transform_forecast(row):
    
#     for row in forecast_df[3:-6].iterrows():
        
#         row = row[1]
    
#         m = row['Date'].month
#         t = row['Date'].year
#         next_year_t = t + 1
#         target = row['Target']
        
#         if t <= target:
            
#             print(row)
        
#             forecast_t = row['Median']
    
#             next_year_forecast = forecast_df.loc[forecast_df['Target'] == next_year_t, 'Median'].iloc[0]
    
#     transformed_forecast = (13 - m) / 12 * forecast_t + (m - 1) / 12 * next_year_forecast
#     return transformed_forecast

# Apply the transformation to the DataFrame

# for year in set(forecast_df['Target']):
    
#     yearly_data = forecast_df[forecast_df['Target'] == year]

# forecast_df['Transformed_Forecast'] = forecast_df.apply(transform_forecast, axis=1)

forecast_df = pd.read_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Reuters Poll\Forecast_Inflation_Reuter.xlsx')
forecast_df = forecast_df.dropna(subset = ['One-Year-Ahead'])
forecast_df['Date'] = pd.to_datetime(forecast_df['Date'])
forecast_df.index = forecast_df['Date']

PATH = r'D:\Studium\PhD\Github\Single-Author\Data\Regression'
#PATH = r'D:\Single Author\Github\Single-Author\Data\Regression'

#inflation_ger_q = pd.read_excel(PATH + '\Consumer Price IndexAll Items Total Total for Germany.xls')[10:]
#inflation_ger_m = pd.read_excel(PATH + '\Germany_harmonized_inflation.xls')[10:]

iwh_inflation = pd.read_excel(PATH + '\Forecast_Inflation_IWH.xls')
GD_inflation = iwh_inflation[iwh_inflation['Institute'] == 'GD']

institue_forecasts = pd.read_excel(PATH + '\German_Institutes_Forecast_First_Quarter.xlsx')
#institue_forecasts_IFW = institue_forecasts[institue_forecasts['Institute'] == 'IfW']
#institue_forecasts_IWH = institue_forecasts[institue_forecasts['Institute'] == 'IWH']
RWI_inflation = institue_forecasts[institue_forecasts['Institute'] == 'RWI']

def year_to_month(data):

    data = pd.DataFrame(data)
    data['Year'] = pd.to_datetime(data['Year'], format='%Y')
    data = data.set_index('Year')
    data = data['One-Year-Ahead']
    
    # Resample to monthly data
    data_m = data.resample('M').mean()
    
    # Interpolate missing values using linear interpolation
    data_m = data_m.interpolate(method='linear')
    
    data_m = pd.DataFrame(data_m)
    
    return(data_m)

GD_inflation_m = year_to_month(GD_inflation)
RWI_inflation_m = year_to_month(RWI_inflation)

start_date_RWI = RWI_inflation_m.index.min() - pd.DateOffset(years=2)
end_date_RWI = RWI_inflation_m.index.min() - pd.DateOffset(months=1)
zero_index = pd.date_range(start=start_date_RWI, end=end_date_RWI, freq='M')

zero_series = pd.Series(0, index=zero_index)

# Concatenate the DataFrames
RWI_inflation_m = pd.concat([zero_series, RWI_inflation_m])

inflation_ger_qoq = pd.read_excel(PATH + '\Germany_Inflation_qoq.xls')[10:]
inflation_ger_y = pd.read_excel(PATH + '\Germany CPI Yearly.xls')[10:]
ecb_dfr = pd.read_excel(PATH + '\ECBDFR.xls')[10:]

germany_harmonised_inflation_m = pd.read_excel(PATH + '\Germany_Harmonised_Inflation.xls')[10:]

fred_monthly = pd.read_excel(PATH + '\Fred_data_monthly.xlsx')[10:]
ip_ger_m = fred_monthly.iloc[:,0:2]
ip_ea_m = fred_monthly.iloc[:,6:8]
inflation_ger_m = fred_monthly.iloc[:,2:4]
inflation_ger_m = inflation_ger_m.rename(columns={"Unnamed: 3": "Inflation"})
inflation_ea_m = fred_monthly.iloc[:,4:6]

monthly_ecb_count = pd.read_csv(PATH + '\monthly_ecb_counts.csv')

data_ECB_index_inf = pd.read_csv(PATH + '\PR_ecb_inflation_results.csv')[['date', 'index']]
data_ECB_index_mon = pd.read_csv(PATH + '\PR_ecb_monetary_results.csv')[['date', 'index']]
data_ECB_index_ec = pd.read_csv(PATH + '\PR_ecb_outlook_results.csv')[['date', 'index']]

# data_ECB_index_inf = pd.read_csv(PATH + '\ECB_inf_own_trainingsset_labels.csv')[['date', 'index']]
# data_ECB_index_mon = pd.read_csv(PATH + '\ECB_monetary_own_trainingsset_labels.csv')[['date', 'index']]
# data_ECB_index_ec = pd.read_csv(PATH + '\ECB_economic_own_trainingsset_labels.csv')[['date', 'index']]

data_inf_exp_eu = pd.read_excel(PATH + '\Infl_Exp.xlsx', index_col = 0)
ger_oecd_inf_exp = pd.read_csv(PATH + '\OECD_INF_FOR.csv', index_col = 0)

#dire_senti = pd.read_excel(PATH + '\\news_index_dire_senti.xlsx')
dire_senti = pd.read_excel(PATH + '\\news_index_dire_senti_lex.xlsx')
dire = pd.read_excel(PATH + '\\news_index_dire_lex.xlsx')
sent = pd.read_excel(PATH + '\\news_index_senti_lex.xlsx')
count_rel = pd.read_excel(PATH + '\\count_rel.xlsx')

###############################################################################

ea_inf_exp_quant = pd.read_excel(PATH + "\consumer_inflation_quantitative_estimates.xlsx", sheet_name = "EU_Q61")
ea_inf_exp_quant = ea_inf_exp_quant[['Unnamed: 0', 'Median', 'Mean']]

cont = 'DE'
#cont = 'EU'

inf_exp_surv = pd.read_excel(PATH + "\consumer_subsectors_nsa_q6_nace2.xlsx", sheet_name = "TOT")

inf_exp_fall = inf_exp_surv[["TOT", "CONS." + cont + ".TOT.6.MM.M"]]
inf_exp_same = inf_exp_surv[["TOT", "CONS." + cont + ".TOT.6.M.M"]]
inf_exp_inc_slow = inf_exp_surv[["TOT", "CONS." + cont + ".TOT.6.E.M"]]
inf_exp_inc_same = inf_exp_surv[["TOT", "CONS." + cont + ".TOT.6.P.M"]]
inf_exp_inc_rap = inf_exp_surv[["TOT", "CONS." + cont + ".TOT.6.PP.M"]]
inf_exp_miss = inf_exp_surv[["TOT", "CONS." + cont + ".TOT.6.N.M"]]

inf_exp_balanced = inf_exp_surv[["TOT", "CONS." + cont + ".TOT.6.B.M"]]

inf_per_surv = pd.read_excel(PATH + "\consumer_subsectors_nsa_q5_nace2.xlsx", sheet_name = "TOT")

inf_per_balanced = inf_per_surv[["TOT", "CONS." + cont + ".TOT.5.B.M"]]

inf_per_fall = inf_per_surv[["TOT", "CONS." + cont + ".TOT.5.MM.M"]]
inf_per_same = inf_per_surv[["TOT", "CONS." + cont + ".TOT.5.M.M"]]
inf_per_inc_slow = inf_per_surv[["TOT", "CONS." + cont + ".TOT.5.E.M"]]
inf_per_inc_same = inf_per_surv[["TOT", "CONS." + cont + ".TOT.5.P.M"]]
inf_per_inc_rap = inf_per_surv[["TOT", "CONS." + cont + ".TOT.5.PP.M"]]
inf_per_miss = inf_per_surv[["TOT", "CONS." + cont + ".TOT.5.N.M"]]

scaling = rolling_quant(
 inf_exp_inc_rap,
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
 inflation_ger_m,
 5)

scaling = scaling.loc[(scaling['date'] >= start_date) & (scaling['date'] <= end_date)]

###############################################################################

inflation_ger_m = transform_date(inflation_ger_m)

hist_ger_inflation_m = inflation_ger_m.loc[(inflation_ger_m.index >= start_date_hist) & (inflation_ger_m.index <= end_date)]
hist_ger_inflation_rollm_m = hist_ger_inflation_m.rolling(12).mean().shift(3)[14:]

hist_ger_inflation_m_berk_1 = inflation_ger_m.loc[(inflation_ger_m.index >= start_date_hist_berk_1) & (inflation_ger_m.index <= end_date)]
hist_ger_inflation_rollm_m_berk_1 = hist_ger_inflation_m_berk_1.rolling(12).mean().shift(3)[14:]
#mean()[60:-3]
hist_ger_inflation_m.iloc[:,1] = pd.to_numeric(hist_ger_inflation_m.iloc[:,1])
hist_ger_inflation_m_mean = hist_ger_inflation_m.iloc[:,1].mean()

inflation_ger_m = inflation_ger_m.loc[(inflation_ger_m.index >= start_date) & (inflation_ger_m.index <= end_date)]
inflation_ger_m.iloc[:,1] = pd.to_numeric(inflation_ger_m.iloc[:,1])
mean_inflation = inflation_ger_m.mean()

###############################################################################

germany_harmonised_inflation_m = transform_date(germany_harmonised_inflation_m)

germany_harmonised_inflation_m = germany_harmonised_inflation_m.loc[(germany_harmonised_inflation_m.index >= start_date) & (germany_harmonised_inflation_m.index <= end_date)]
germany_harmonised_inflation_m.iloc[:,1] = pd.to_numeric(germany_harmonised_inflation_m.iloc[:,1])

###

hist_ger_inflation_rollm_m_tran = hist_ger_inflation_m.rolling(48).mean()[48:]

from sklearn.preprocessing import MinMaxScaler, StandardScaler

# Initial guess for phi, phi_prime, gamma, and c_threshold
#initial_params = [1, 1, 1, 1] 
#initial_params = [2, 3, 4, 1.5] 
initial_params = [2.15, 3.23, 4.56, 1.62]

rec_mean = recursive_mean(inflation_ger_m)[1]
stm_lam_df = stm(initial_params, scaling, hist_ger_inflation_rollm_m_tran, inflation_ger_m)

# # Scale the transition variable using Min-Max scaling
# min_max_scaler = MinMaxScaler()
# scaled_st = min_max_scaler.fit_transform(np.array(hist_ger_inflation_rollm_m_tran['Unnamed: 3']).reshape(-1, 1)).flatten()

# # Scale the inflation rate series using Standard scaling
# standard_scaler = StandardScaler()
# scaled_pi_t = standard_scaler.fit_transform(np.array(inflation_ger_m['Unnamed: 3']).reshape(-1, 1)).flatten()

###############################################################################

# from pykalman import KalmanFilter

# # Load your data
# # Assuming that the data is stored in a DataFrame called inflation_df

# # Define the matrices and vectors for the state-space model
# # Replace a, b, and c with the appropriate values in your dataset
# F = np.array([[1]])  # Transition matrix
# H = np.array([[scaling['exp_weight']]])  # Observation matrix
# Q = np.array([[0.1]])  # Process noise covariance matrix (initial guess for γσ^2)
# R = np.array([[1]])  # Measurement noise covariance matrix (initial guess for (1-γ)σ^2)
# initial_state_mean = np.array([0])  # Initial state mean
# initial_state_covariance = np.array([[1]])  # Initial state covariance

# # Initialize the Kalman filter
# kf = KalmanFilter(transition_matrices=F, observation_matrices=H,
#                   initial_state_mean=initial_state_mean, initial_state_covariance=initial_state_covariance,
#                   transition_covariance=Q, observation_covariance=R)

# # Fit the Kalman filter to the observed data (inflation rates)
# observed_inflation = inflation_ger_m['Unnamed: 3'].values
# kf = kf.em(observed_inflation)

# # Apply the Kalman filter to obtain the filtered and smoothed state estimates
# filtered_state_means, filtered_state_covariances = kf.filter(observed_inflation)
# smoothed_state_means, smoothed_state_covariances = kf.smooth(observed_inflation)

# # Add the filtered and smoothed estimates of λ to the DataFrame
# inflation_df['filtered_lambda'] = filtered_state_means.squeeze()
# inflation_df['smoothed_lambda'] = smoothed_state_means.squeeze()

# # Display the DataFrame
# print(inflation_df)

###############################################################################

ea_inf_exp_quant['Unnamed: 0'] = pd.to_datetime(ea_inf_exp_quant['Unnamed: 0'])
ea_inf_exp_quant.set_index('Unnamed: 0', inplace=True)

ea_inf_exp_quant = ea_inf_exp_quant['Median'].resample('M').mean().interpolate(method='linear')

first_date = ea_inf_exp_quant.index.min() - pd.DateOffset(years=5)
last_date = ea_inf_exp_quant.index.max()
new_index = pd.date_range(start=first_date, end=last_date, freq='M')

ea_inf_exp_quant = pd.DataFrame(ea_inf_exp_quant)

# Create a new DataFrame with the same columns and the new index
extended_data = pd.DataFrame(index=new_index, columns=ea_inf_exp_quant.columns)

# Fill the new DataFrame with 0 values for the additional four years
extended_data.loc[:first_date + pd.DateOffset(years=4, months=-1), :] = 0

# Concatenate the new DataFrame with the original DataFrame
extended_data.update(ea_inf_exp_quant)

ea_inf_exp_quant = extended_data

ea_inf_exp_quant = ea_inf_exp_quant.loc[(ea_inf_exp_quant.index >= start_date) & (ea_inf_exp_quant.index <= end_date)]

###############################################################################

forecast_df_m = forecast_df.groupby(pd.Grouper(freq="M")).mean().fillna(method = 'ffill')

first_date = forecast_df_m.index.min() - pd.DateOffset(years=5)
last_date = forecast_df_m.index.max()
new_index = pd.date_range(start=first_date, end=last_date, freq='M')

forecast_df_m = pd.DataFrame(forecast_df_m)

# Create a new DataFrame with the same columns and the new index
extended_data = pd.DataFrame(index=new_index, columns=forecast_df_m.columns)

# Fill the new DataFrame with 0 values for the additional four years
extended_data.loc[:first_date + pd.DateOffset(years=4, months=-1), :] = 0

# Concatenate the new DataFrame with the original DataFrame
extended_data.update(forecast_df_m)

forecast_df_m = extended_data

forecast_df_m = forecast_df_m.loc[(forecast_df_m.index >= start_date) & (forecast_df_m.index <= end_date)]

###############################################################################

start_date_RWI = RWI_inflation_m.index.min() - pd.DateOffset(years=4)
end_date_RWI = RWI_inflation_m.index.min() - pd.DateOffset(months=1)
zero_index = pd.date_range(start=start_date_RWI, end=end_date_RWI, freq='M')

zero_series = pd.Series(0, index=zero_index)

# Concatenate the DataFrames
RWI_inflation_m = pd.concat([zero_series, RWI_inflation_m])

ip_ger_m = transform_date(ip_ger_m)
ip_ger_m = ip_ger_m.loc[(ip_ger_m.index >= start_date) & (ip_ger_m.index <= end_date)]
ip_ger_m.iloc[:,1] = pd.to_numeric(ip_ger_m.iloc[:,1])

ip_ea_m = transform_date(ip_ea_m)
ip_ea_m = ip_ea_m.loc[(ip_ea_m.index >= start_date) & (ip_ea_m.index <= end_date)]
ip_ea_m.iloc[:,1] = pd.to_numeric(ip_ea_m.iloc[:,1])

inflation_ea_m = transform_date(inflation_ea_m)
inflation_ea_m = inflation_ea_m.loc[(inflation_ea_m.index >= start_date) & (inflation_ea_m.index <= end_date)]
inflation_ea_m.iloc[:,1] = pd.to_numeric(inflation_ea_m.iloc[:,1])

ger_oecd_inf_exp = ger_oecd_inf_exp[ger_oecd_inf_exp.index == "DEU"]
ger_oecd_inf_exp = ger_oecd_inf_exp[1:]
ger_oecd_inf_exp.index = pd.date_range('31/12/1999', '1/1/2019', freq = 'Q').tolist()
ger_oecd_inf_exp = ger_oecd_inf_exp['Value']
ger_oecd_inf_exp_m = ger_oecd_inf_exp.groupby(pd.Grouper(freq="M")).mean().fillna(method = 'ffill')

#GD_inflation_m = GD_inflation.groupby(pd.Grouper(freq="M")).mean().fillna(method = 'ffill')
GD_inflation_m = GD_inflation_m.loc[(GD_inflation_m.index >= start_date) & (GD_inflation_m.index <= end_date)]

# institue_forecasts_RWI['Vintage'] = pd.to_datetime(institue_forecasts_RWI['Vintage'])
# institue_forecasts_RWI.index = institue_forecasts_RWI['Vintage']
# institue_forecasts_RWI_m = institue_forecasts_RWI.groupby(pd.Grouper(freq="M")).mean().fillna(method = 'ffill')
RWI_inflation_m = RWI_inflation_m.loc[(RWI_inflation_m.index >= start_date) & (RWI_inflation_m.index <= end_date)]

data_inf_exp_eu = data_inf_exp_eu.loc[(data_inf_exp_eu.index >= start_date) & (data_inf_exp_eu.index <= end_date)]
data_inf_exp_eu = data_inf_exp_eu.groupby(pd.Grouper(freq="M")).mean().fillna(method = 'ffill')

ecb_dfr = transform_date(ecb_dfr)
ecb_dfr = ecb_dfr.groupby(pd.Grouper(freq="M")).mean()
ecb_dfr = ecb_dfr.loc[(ecb_dfr.index >= start_date) & (ecb_dfr.index <= end_date)]
ecb_dfr.loc[pd.to_datetime('2000-01-01')] = {'Unnamed: 1': 2.0}
ecb_dfr = ecb_dfr.sort_index()

# Function to get the last day of the month
def get_last_day_of_month(year_month_str):
    # Convert the string to a datetime object (first day of the month)
    dt = pd.to_datetime(year_month_str)
    
    # Add one month and subtract one day to get the last day of the month
    last_day = dt + relativedelta(day=1, months=1) - relativedelta(days=1)
    
    return last_day

dire_senti.iloc[:,0] = dire_senti.iloc[:,0].apply(get_last_day_of_month)
dire_senti.index = dire_senti.iloc[:,0]
dire_senti = dire_senti.loc[(dire_senti.index >= start_date) & (dire_senti.index <= end_date)]
dire_senti_q = dire_senti.groupby(pd.Grouper(freq="Q")).mean()

dire.iloc[:,0] = dire.iloc[:,0].apply(get_last_day_of_month)
dire.index = dire.iloc[:,0]
dire = dire.loc[(dire.index >= start_date) & (dire.index <= end_date)]
dire_q = dire.groupby(pd.Grouper(freq="Q")).mean()

sent.iloc[:,0] = sent.iloc[:,0].apply(get_last_day_of_month)
sent.index = sent.iloc[:,0]
sent = sent.loc[(sent.index >= start_date) & (sent.index <= end_date)]
sent_q = sent.groupby(pd.Grouper(freq="Q")).mean()

count_rel.iloc[:,0] = pd.to_datetime(count_rel.iloc[:,0])
count_rel.index = count_rel.iloc[:,0]
count_rel = count_rel.loc[(count_rel.index >= start_date) & (count_rel.index <= end_date)]
count_rel_q = count_rel.groupby(pd.Grouper(freq="Q")).mean()

monthly_ecb_count.iloc[:,0] = pd.to_datetime(monthly_ecb_count.iloc[:,0])
monthly_ecb_count.index = monthly_ecb_count.iloc[:,0]
monthly_ecb_count = monthly_ecb_count.loc[(monthly_ecb_count.index >= start_date) & (monthly_ecb_count.index <= end_date)]
monthly_ecb_count_q = monthly_ecb_count.groupby(pd.Grouper(freq="Q")).mean()

date_inf = list(inflation_ea_m.iloc[:,0])

###############################################################################

data_ECB_index_inf.set_index('date', inplace=True)
data_ECB_index_inf.index = pd.to_datetime(data_ECB_index_inf.index)
data_ECB_index_inf['index'] = pd.to_numeric(data_ECB_index_inf['index'])
data_ECB_index_inf = data_ECB_index_inf.loc[(data_ECB_index_inf.index >= start_date) & (data_ECB_index_inf.index <= end_date)]
data_ECB_index_inf_m = scale_ECB_index(data_ECB_index_inf,date_inf)

###############################################################################

data_ECB_index_mon.set_index('date', inplace=True)
data_ECB_index_mon.index = pd.to_datetime(data_ECB_index_mon.index)
data_ECB_index_mon['index'] = pd.to_numeric(data_ECB_index_mon['index'])
data_ECB_index_mon = data_ECB_index_mon.loc[(data_ECB_index_mon.index >= start_date) & (data_ECB_index_mon.index <= end_date)]
data_ECB_index_mon_m = scale_ECB_index(data_ECB_index_mon,date_inf)

###############################################################################

data_ECB_index_ec.set_index('date', inplace=True)
data_ECB_index_ec.index = pd.to_datetime(data_ECB_index_ec.index)
data_ECB_index_ec['index'] = pd.to_numeric(data_ECB_index_ec['index'])
data_ECB_index_ec = data_ECB_index_ec.loc[(data_ECB_index_ec.index >= start_date) & (data_ECB_index_ec.index <= end_date)]
data_ECB_index_ec_m = scale_ECB_index(data_ECB_index_ec,date_inf)

###############################################################################
###
###############################################################################

exp_inf_berk_1 = np.array(hist_ger_inflation_rollm_m_berk_1['Inflation'])*np.array(scaling['exp_weight'])
exp_inf_berk_1 = pd.DataFrame(exp_inf_berk_1)
exp_inf_berk_1.index = inflation_ger_m.iloc[:,0]

exp_inf_berk_5_var_mean = np.array(inflation_ger_m['recursive_mean'])*np.array(scaling['exp_weight'])
exp_inf_berk_5_var_mean = pd.DataFrame(exp_inf_berk_5_var_mean)
exp_inf_berk_5_var_mean.index = inflation_ger_m.iloc[:,0]

# exp_inf_berk_5_glob_mean = np.array(rec_mean)*np.array(scaling['exp_weight'])
# exp_inf_berk_5_glob_mean = pd.DataFrame(exp_inf_berk_5_glob_mean)
# exp_inf_berk_5_glob_mean.index = inflation_ger_m.iloc[:,0]

def absolute_errors(quant_surv, proff_fore):

    ger_relative_exp_gap_m = np.array(quant_surv) - proff_fore
    ger_abslolute_exp_gap_m = abs(ger_relative_exp_gap_m)
    
    return(ger_relative_exp_gap_m, ger_abslolute_exp_gap_m)
 
ger_relative_exp_gap_m_role_RWI, ger_abslolute_exp_gap_m_role_RWI = absolute_errors(scaling['German Inflation Expectations'], RWI_inflation_m['One-Year-Ahead'])   
ger_relative_exp_gap_m_role_GD, ger_abslolute_exp_gap_m_role_GD = absolute_errors(scaling['German Inflation Expectations'], GD_inflation_m['One-Year-Ahead'])
ger_eu_relative_exp_gap_m_role, ger_eu_abslolute_exp_gap_m_role =  absolute_errors(scaling['German Inflation Expectations'], data_inf_exp_eu.iloc[:,0])
ger_relative_inf_gap_m_role, ger_abslolute_inf_gap_m_role = absolute_errors(scaling['German Inflation Expectations'], inflation_ger_m.iloc[:,1])

ger_relative_exp_gap_m_berk_1_RWI, ger_abslolute_exp_gap_m_berk_1_RWI = absolute_errors(exp_inf_berk_1.iloc[:,0], RWI_inflation_m['One-Year-Ahead'])
ger_relative_exp_gap_m_berk_1_GD, ger_abslolute_exp_gap_m_berk_1_GD = absolute_errors(exp_inf_berk_1.iloc[:,0], GD_inflation_m['One-Year-Ahead'])
ger_eu_relative_exp_gap_m_berk_1, ger_eu_abslolute_exp_gap_m_berk_1 = absolute_errors(exp_inf_berk_1.iloc[:,0], data_inf_exp_eu.iloc[:,0])
ger_relative_inf_gap_m_berk_1, ger_abslolute_inf_gap_m_berk_1 = absolute_errors(exp_inf_berk_1.iloc[:,0], inflation_ger_m.iloc[:,1])

ger_relative_exp_gap_m_berk_5_RWI, ger_abslolute_exp_gap_m_berk_5_RWI = absolute_errors(exp_inf_berk_5_var_mean.iloc[:,0], RWI_inflation_m['One-Year-Ahead'])
ger_relative_exp_gap_m_berk_5_GD, ger_abslolute_exp_gap_m_berk_5_GD = absolute_errors(exp_inf_berk_5_var_mean.iloc[:,0], GD_inflation_m['One-Year-Ahead'])
ger_eu_relative_exp_gap_m_berk_5, ger_eu_abslolute_exp_gap_m_berk_5 = absolute_errors(exp_inf_berk_5_var_mean.iloc[:,0], data_inf_exp_eu.iloc[:,0])
ger_relative_inf_gap_m_berk_5, ger_abslolute_inf_gap_m_berk_5 = absolute_errors(exp_inf_berk_5_var_mean.iloc[:,0], inflation_ger_m.iloc[:,1])

ger_relative_exp_gap_m_berk_stm_RWI, ger_abslolute_exp_gap_m_berk_stm_RWI = absolute_errors(stm_lam_df.iloc[:,0], RWI_inflation_m['One-Year-Ahead'])
ger_relative_exp_gap_m_berk_stm_GD, ger_abslolute_exp_gap_m_berk_stm_GD = absolute_errors(stm_lam_df.iloc[:,0], GD_inflation_m['One-Year-Ahead'])
ger_eu_relative_exp_gap_m_berk_stm, ger_eu_abslolute_exp_gap_m_berk_stm = absolute_errors(stm_lam_df.iloc[:,0], data_inf_exp_eu.iloc[:,0])
ger_relative_inf_gap_m_berk_stm, ger_abslolute_inf_gap_m_berk_stm = absolute_errors(stm_lam_df.iloc[:,0], inflation_ger_m.iloc[:,1])

ger_relative_exp_gap_m_quant_RWI, ger_abslolute_exp_gap_m_quant_RWI = absolute_errors(ea_inf_exp_quant['Median'], RWI_inflation_m['One-Year-Ahead'])   
ger_relative_exp_gap_m_quant_GD, ger_abslolute_exp_gap_m_quant_GD = absolute_errors(ea_inf_exp_quant['Median'], GD_inflation_m['One-Year-Ahead'])
ger_eu_relative_exp_gap_m_quant, ger_eu_abslolute_exp_gap_m_quant =  absolute_errors(ea_inf_exp_quant['Median'], data_inf_exp_eu.iloc[:,0])
ger_relative_inf_gap_m_quant, ger_abslolute_inf_gap_m_quant = absolute_errors(ea_inf_exp_quant['Median'], inflation_ger_m.iloc[:,1])

####

ger_relative_exp_gap_m_berk_stm_Reuter, ger_abslolute_exp_gap_m_berk_stm_Reuter = absolute_errors(stm_lam_df.iloc[:,0], forecast_df_m['One-Year-Ahead'])
ger_relative_exp_gap_m_role_Reuter, ger_abslolute_exp_gap_m_role_Reuter = absolute_errors(scaling['German Inflation Expectations'], forecast_df_m['One-Year-Ahead'])
ger_relative_exp_gap_m_berk_5_Reuter, ger_abslolute_exp_gap_m_berk_5_Reuter = absolute_errors(exp_inf_berk_5_var_mean.iloc[:,0], forecast_df_m['One-Year-Ahead'])


###############################################################################

#inflation_ger_m['Recursive_Mean'] = inflation_ger_m['Inflation'].expanding().mean()

###############################################################################

Regression_data_m = pd.DataFrame()
Regression_data_m['Eurozone Industrial Production'] = ip_ea_m.iloc[:,1]
Regression_data_m['Eurozone Inflation'] = list(inflation_ea_m.iloc[:,1])
Regression_data_m['German Industrial Production'] = ip_ger_m.iloc[:,1]
Regression_data_m['German Inflation Year-on-Year'] = list(inflation_ger_m.iloc[:,1])
Regression_data_m['German Inflation Year-on-Year Harmonised'] = list(germany_harmonised_inflation_m.iloc[:,1])
Regression_data_m['ECB DFR'] = list(ecb_dfr.iloc[:,1])
Regression_data_m['News Inflation Index'] = list(dire_senti.iloc[:,1])
Regression_data_m['News Inflation Sentiment Index'] = list(sent.iloc[:,1])
Regression_data_m['News Inflation Direction Index'] = list(dire.iloc[:,1])
Regression_data_m['News Inflation Count'] = list(count_rel.iloc[:,1])
Regression_data_m['News ECB Count'] = list(monthly_ecb_count.iloc[:,1])
Regression_data_m['ECB Inflation Index'] = list(data_ECB_index_inf_m.iloc[:,1])
Regression_data_m['ECB Monetary Index'] = list(data_ECB_index_mon_m.iloc[:,1])
Regression_data_m['ECB Economic Index'] = list(data_ECB_index_ec_m.iloc[:,1])
Regression_data_m['German Household Inflation Expectations Berk 1'] = list(exp_inf_berk_1.iloc[:,0])
Regression_data_m['German Household Inflation Expectations EU Median'] = list(ea_inf_exp_quant['Median'])
Regression_data_m['German Household Inflation Expectations Berk 5'] = list(exp_inf_berk_5_var_mean.iloc[:,0])
Regression_data_m['German Household Inflation Expectations Role'] = list(scaling['German Inflation Expectations'])
Regression_data_m['German Household Inflation Expectations Stm'] = list(stm_lam_df.iloc[:,0])
Regression_data_m['Eurozone Inflation Professionell Forecasts'] = list(data_inf_exp_eu.iloc[:,0])
#Regression_data_m['Germany Inflation Professionell Forecasts'] = list(iwh_inflation_m['Value'])
Regression_data_m['Germany Inflation Professionell Forecasts GD'] = list(GD_inflation_m['One-Year-Ahead'])
Regression_data_m['Germany Inflation Professionell Forecasts RWI'] = list(RWI_inflation_m['One-Year-Ahead'])

Regression_data_m['German Absolute Expectations Gap Role GD'] = list(ger_abslolute_exp_gap_m_role_GD)
Regression_data_m['German Relative Expectations Gap Role GD'] = list(ger_relative_exp_gap_m_role_GD)
Regression_data_m['German Absolute Expectations Gap Role RWI'] = list(ger_abslolute_exp_gap_m_role_RWI)
Regression_data_m['German Relative Expectations Gap Role RWI'] = list(ger_relative_exp_gap_m_role_RWI)
Regression_data_m['German ECB Absolute Expectations Gap Role'] = list(ger_eu_abslolute_exp_gap_m_role)
Regression_data_m['German ECB Relative Expectations Gap Role'] = list(ger_eu_relative_exp_gap_m_role)
Regression_data_m['German Absolute Real Inflation Expectations Gap Role'] = list(ger_abslolute_inf_gap_m_role)
Regression_data_m['German Relative Real Inflation Expectations Gap Role'] = list(ger_relative_inf_gap_m_role)

Regression_data_m['German Absolute Expectations Gap Berk 1 GD'] = list(ger_abslolute_exp_gap_m_berk_1_GD) 
Regression_data_m['German Relative Expectations Gap Berk 1 GD'] = list(ger_relative_exp_gap_m_berk_1_GD)
Regression_data_m['German Absolute Expectations Gap Berk 1 RWI'] = list(ger_abslolute_exp_gap_m_berk_1_RWI) 
Regression_data_m['German Relative Expectations Gap Berk 1 RWI'] = list(ger_relative_exp_gap_m_berk_1_RWI)
Regression_data_m['German ECB Absolute Expectations Gap Berk 1'] = list(ger_eu_abslolute_exp_gap_m_berk_1)
Regression_data_m['German ECB Relative Expectations Gap Berk 1'] = list(ger_eu_relative_exp_gap_m_berk_1)
Regression_data_m['German Absolute Real Inflation Expectations Gap Berk 1'] = list(ger_abslolute_inf_gap_m_berk_1)
Regression_data_m['German Relative Real Inflation Expectations Gap Berk 1'] = list(ger_relative_inf_gap_m_berk_1)

Regression_data_m['German Absolute Expectations Gap Berk 5 GD'] = list(ger_abslolute_exp_gap_m_berk_5_GD) 
Regression_data_m['German Relative Expectations Gap Berk 5 GD'] = list(ger_relative_exp_gap_m_berk_5_GD)
Regression_data_m['German Absolute Expectations Gap Berk 5 RWI'] = list(ger_abslolute_exp_gap_m_berk_5_RWI) 
Regression_data_m['German Relative Expectations Gap Berk 5 RWI'] = list(ger_relative_exp_gap_m_berk_5_RWI)
Regression_data_m['German ECB Absolute Expectations Gap Berk 5'] = list(ger_eu_abslolute_exp_gap_m_berk_5)
Regression_data_m['German ECB Relative Expectations Gap Berk 5'] = list(ger_eu_relative_exp_gap_m_berk_5)
Regression_data_m['German Absolute Real Inflation Expectations Gap Berk 5'] = list(ger_abslolute_inf_gap_m_berk_5)
Regression_data_m['German Relative Real Inflation Expectations Gap Berk 5'] = list(ger_relative_inf_gap_m_berk_5)

Regression_data_m['German Absolute Expectations Gap Stm GD'] = list(ger_abslolute_exp_gap_m_berk_stm_GD) 
Regression_data_m['German Relative Expectations Gap Stm GD'] = list(ger_relative_exp_gap_m_berk_stm_GD)
Regression_data_m['German Absolute Expectations Gap Stm RWI'] = list(ger_abslolute_exp_gap_m_berk_stm_RWI) 
Regression_data_m['German Relative Expectations Gap Stm RWI'] = list(ger_relative_exp_gap_m_berk_stm_RWI)
Regression_data_m['German ECB Absolute Expectations Gap Stm'] = list(ger_eu_abslolute_exp_gap_m_berk_stm)
Regression_data_m['German ECB Relative Expectations Gap Stm'] = list(ger_eu_relative_exp_gap_m_berk_stm)
Regression_data_m['German Absolute Real Inflation Expectations Gap Stm'] = list(ger_abslolute_inf_gap_m_berk_stm)
Regression_data_m['German Relative Real Inflation Expectations Gap Stm'] = list(ger_relative_inf_gap_m_berk_stm)

Regression_data_m['German Absolute Expectations Gap Quant GD'] = list(ger_abslolute_exp_gap_m_quant_GD) 
Regression_data_m['German Relative Expectations Gap Quant GD'] = list(ger_relative_exp_gap_m_quant_GD)
Regression_data_m['German Absolute Expectations Gap Quant RWI'] = list(ger_abslolute_exp_gap_m_quant_RWI) 
Regression_data_m['German Relative Expectations Gap Quant RWI'] = list(ger_relative_exp_gap_m_quant_RWI)
Regression_data_m['German ECB Absolute Expectations Gap Quant'] = list(ger_eu_abslolute_exp_gap_m_quant)
Regression_data_m['German ECB Relative Expectations Gap Quant'] = list(ger_eu_relative_exp_gap_m_quant)
Regression_data_m['German Absolute Real Inflation Expectations Gap Quant'] = list(ger_abslolute_inf_gap_m_quant)
Regression_data_m['German Relative Real Inflation Expectations Gap Quant'] = list(ger_relative_inf_gap_m_quant)

ger_relative_exp_gap_m_berk_stm_Reuter, ger_abslolute_exp_gap_m_berk_stm_Reuter = absolute_errors(stm_lam_df.iloc[:,0], forecast_df_m['One-Year-Ahead'])
ger_relative_exp_gap_m_role_Reuter, ger_abslolute_exp_gap_m_role_Reuter = absolute_errors(scaling['German Inflation Expectations'], forecast_df_m['One-Year-Ahead'])
ger_relative_exp_gap_m_berk_5_Reuter, ger_abslolute_exp_gap_m_berk_5_Reuter = absolute_errors(exp_inf_berk_5_var_mean.iloc[:,0], forecast_df_m['One-Year-Ahead'])

Regression_data_m['German Absolute Real Inflation Expectations Gap Stm Reuter'] = list(ger_abslolute_exp_gap_m_berk_stm_Reuter)
Regression_data_m['German Absolute Real Inflation Expectations Gap Role Reuter'] = list(ger_abslolute_exp_gap_m_role_Reuter)
Regression_data_m['German Absolute Real Inflation Expectations Gap Berk5 Reuter'] = list(ger_abslolute_exp_gap_m_berk_5_Reuter)

Regression_data_m['German Relative Real Inflation Expectations Gap Stm Reuter'] = list(ger_relative_exp_gap_m_berk_stm_Reuter)
Regression_data_m['German Relative Real Inflation Expectations Gap Role Reuter'] = list(ger_relative_exp_gap_m_role_Reuter)
Regression_data_m['German Relative Real Inflation Expectations Gap Berk5 Reuter'] = list(ger_relative_exp_gap_m_berk_5_Reuter)

Regression_data_m['Reuter Poll Forecast'] = list(forecast_df_m['One-Year-Ahead'])


#Regression_data_m['German Household Inflation Expectations Balanced'] = list(inf_exp_balanced.iloc[:,1])
# Regression_data_m['German Household Inflation Expectations'] = list(scaling['German Inflation Expectations'][180-w:408-w])
# Regression_data_m['German Household Inflation Expectations'] = list(exp_inf[180:-43])

# Regression_data_m['EA Absolute Expectations Gap'] = list(ea_abs_exp_gap_m[1:]) # FALSCH
# Regression_data_m['EA Relative Expectations Gap'] = list(ea_relative_exp_gap_m[1:]) # FALSCH
# Regression_data_m['Eurozone Household Inflation Expectations'] = list(ea_inf_exp_m.iloc[1:,0])

#Regression_data_q.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\regression_data_quarterly.xlsx')
Regression_data_m.to_excel(PATH + '\\regression_data_monthly_2.xlsx')

###############################################################################

###############################################################################

Regression_q = 

Regression_data_m['German Inflation Year-on-Year'] = list(inflation_ger_m.iloc[:,1])
forecast_df
data_inf_exp_eu
Gaps

import pylab as plt

plt.plot(scaling['date'], scaling['German Inflation Expectations'])
plt.plot(inflation_ger_m.index, inflation_ger_m.iloc[:,1])
plt.show()

plt.plot(iwh_inflation_m['One-Year-Ahead'])
plt.plot(institue_forecasts_RWI_m['One-Year-Ahead'])
plt.plot(data_inf_exp_eu)
plt.show()

#plt.plot(inflation_ger_m.index, inflation_ger_m.iloc[:,1])
# plt.plot(exp_inf_berk_5_var_mean)
# plt.plot(exp_inf_berk_5_glob_mean)
#plt.plot(exp_inf_berk_1[:-170])
#plt.plot(iwh_inflation_m['One-Year-Ahead'])
plt.plot(stm_lam_df.index, stm_lam_df['exp_inf_min'])
plt.plot(scaling['date'], scaling['German Inflation Expectations'])
plt.show()

np.sum((np.array(inflation_ger_m['Inflation']) - np.array(scaling['German Inflation Expectations']))**2)
np.sum((np.array(inflation_ger_m['Inflation']) - np.array(stm_lam_df['exp_inf_min']))**2)
np.sum((np.array(inflation_ger_m['Inflation']) - np.array(exp_inf_berk_5_var_mean.iloc[:,0]))**2)
np.sum((np.array(inflation_ger_m['Inflation']) - np.array(exp_inf_berk_1.iloc[:,0]))**2)
np.sum((np.array(inflation_ger_m['Inflation']) - np.array(institue_forecasts_RWI_m['One-Year-Ahead']))**2)
np.sum((np.array(inflation_ger_m['Inflation']) - np.array(iwh_inflation_m['One-Year-Ahead']))**2)
np.sum((np.array(inflation_ger_m['Inflation']) - np.array(exp_inf_berk_1.iloc[:,0]))**2)

np.sum((np.array(inflation_ger_m['Inflation']) - np.array(data_inf_exp_eu.iloc[:,0]))**2)
np.sum((np.array(inflation_ger_m['Inflation']) - np.array(monthly_df.iloc[:,0]))**2)

# plt.plot(data_ECB_index_inf_m['date'], data_ECB_index_inf_m['index'])
# #plt.plot(data_ECB_index_inf_2['date'], data_ECB_index_inf_2['index'])
# plt.plot(dire_senti['date'], dire_senti['index']*5)
# plt.plot()

plt.plot(monthly_df)
plt.plot(data_inf_exp_eu)
plt.show()

plt.plot(forecast_df['Date'], forecast_df['One-Year-Ahead'])
#plt.plot(stm_lam_df.index, stm_lam_df['exp_inf_min'])
#plt.plot(data_inf_exp_eu)
plt.show()


import matplotlib.pyplot as plt
import matplotlib.dates as mdates

fig, ax = plt.subplots()

# Plot the data
ax.plot(forecast_df['Date'], forecast_df['One-Year-Ahead'])

# Set the y-axis label
ax.set_ylabel('Inflation')

# Set the x-axis ticks to yearly
years = mdates.YearLocator()
ax.xaxis.set_major_locator(years)

# Format the x-axis ticks as years
ax.xaxis.set_major_formatter(mdates.DateFormatter('%Y'))

# Rotate the x-axis ticks for better visibility
plt.xticks(rotation=45)

# Display the plot
plt.show()

# from sklearn.linear_model import LinearRegression
# model = LinearRegression()

# exp_inf_berk = inflation_ger_y_prev['Unnamed: 1'] *- np.array((Z3 + Z4)/(Z1 + Z2 - Z3 - Z4))[167:-53:12]
# exp_inf_berk = exp_inf_berk.groupby(pd.Grouper(freq="M")).mean().fillna(method = 'ffill')

# ger_relative_exp_gap_m_berk = np.array(exp_inf_berk) - iwh_inflation_m['Value']

# inflation_ger_m = fred_monthly.iloc[:,2:4]
# inflation_ger_m = inflation_ger_m[297:-3]

# model.fit(np.array(ger_inf_per_balanced.iloc[:,1]).reshape(-1,1) , np.array(inflation_ger_m['Unnamed: 3']).reshape(-1,1))
# alpha, beta = model.intercept_, model.coef_[0]

# perc_hat = alpha + beta * ger_inf_per_balanced.iloc[:,1]
# exp_inf = -perc_hat * (Z3 + Z4)/(Z1 + Z2 - Z3 - Z4)

#exp_inf_berk.index = ger_inf_per_balanced['TOT']
#exp_inf_berk.index = pd.to_datetime(exp_inf_berk.index)

# exp_inf.index = inf_per_balanced['TOT']
# exp_inf.index = pd.to_datetime(exp_inf.index)

# ger_relative_exp_gap_m_buchmann = np.array(exp_inf[179:-43]) - iwh_inflation_m['Value']
# ger_abslolute_exp_gap_m_buchmann = abs(ger_relative_exp_gap_m_buchmann)

###############################################################################

# import pylab as plt

# plt.plot(data_inf_exp_m, label = "ECB Staff Year on Year Inflaiton Forecast")
# plt.plot(data_inf_exp_m.index, inflation_ea_m.iloc[:,1], label = "Eurozone Inflation")

# plt.plot(data_inf_exp_m.index,inflation_ger_m.iloc[:,1], label = "German Inflation")
# plt.plot(data_inf_exp_m.index,iwh_inflation_m['Value'], label = "GD Inflation Forecast")

# plt.legend(loc='upper left', fontsize=7)

# plt.show()


# plt.plot(data_inf_exp_m)
# #plt.plot(iwh_inflation_m.index, iwh_inflation_m['Unnamed: 22'])
# plt.plot(iwh_inflation_m.index, iwh_inflation_m['Value'])

# plt.show()

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

#(Buchmann 2009)

# plt.plot(exp_inf_berk.index[180:-115], exp_inf_berk[180:-115])
# plt.plot(inflation_ger_m.iloc[:,0][180:-115],inflation_ger_m['Unnamed: 3'][180:-115])
# plt.show()

# plt.plot(exp_inf_berk.index[180:-115], exp_inf_berk[168:-127])
# plt.plot(inflation_ger_m.iloc[:,0][180:-115],inflation_ger_m['Unnamed: 3'][180:-115])
# plt.show()

# plt.plot(exp_inf.index[180:-115], exp_inf[168:-127])
# plt.plot(inflation_ger_m.iloc[:,0][180:-115],inflation_ger_m['Unnamed: 3'][180:-115])
# plt.show()

# ger_scale_roll = np.array(ger_scale.iloc[:,0])/np.square(np.array(ger_scale.iloc[:,0]))
# ger_scale_roll_k = np.array(ger_scale_roll)*np.array(inflation_ger_m[297:-3].iloc[:,1])
# ger_scale_roll_k = pd.DataFrame(ger_scale_roll_k)
# ger_scale_roll_k['date'] = ger_inf_exp_fall['TOT']
# ger_scale_roll_k.reset_index(drop = True, inplace = True)

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

# data_ECB_index_inf = ECB_index(data_ECB_sents_inf)
# data_ECB_index_inf.set_index('date', inplace=True)
# data_ECB_index_inf = data_ECB_index_inf[18:232]
# #data_ECB_index_inf.iloc[:,0] = preprocessing.scale(np.float32(data_ECB_index_inf))
# data_ECB_index_inf_q = pd.DataFrame(data_ECB_index_inf).groupby(pd.Grouper(freq="Q")).mean()
# data_ECB_index_inf_m = pd.DataFrame(data_ECB_index_inf).groupby(pd.Grouper(freq="M")).mean()

#data_ECB_index_mon2.iloc[:,0] = preprocessing.scale(np.float32(data_ECB_index_mon2))
#data_ECB_index_ec2_q = pd.DataFrame(data_ECB_index_ec2).groupby(pd.Grouper(freq="Q")).mean()
#data_ECB_index_ec2_m = pd.DataFrame(data_ECB_index_ec2).groupby(pd.Grouper(freq="M")).mean().fillna(method = 'ffill')

#ger_scale_exp = ger_scale_exp[178:-44]

# ea_relative_exp_gap_q = ea_inf_exp_q.iloc[:,0][1:78] - data_inf_exp.iloc[:,0][4:80]
# ea_abs_exp_gap_q = abs(ea_relative_exp_gap_q)

# ea_relative_exp_gap_m = ea_inf_exp_m.iloc[:,0] - list(inflation_ea_m.iloc[:,1])
# ea_abs_exp_gap_m = abs(ea_relative_exp_gap_m)

# cor = np.corrcoef(inflation_ger_m.iloc[60:,1], list(data_inf_exp_m)[60:])
# cor = np.corrcoef(inflation_ger_m.iloc[60:,1], scaling['German Inflation Expectations'][191:360])

# sum(np.square(inflation_ger_m.iloc[60:,1] - list(data_inf_exp_m)[60:]))
# sum(np.square(inflation_ger_m.iloc[60:,1] - list(scaling['German Inflation Expectations'][191:360])))

#scaling['date'][134:372], scaling['German Inflation Expectations'][134:372] - list(data_inf_exp_m.iloc[:,0])

# ger_relative_exp_gap_m = ger_inf_exp_m.iloc[:,0] - list(ger_oecd_inf_exp_m)
# ger_abs_exp_gap_m = abs(ger_relative_exp_gap_m)

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

#inflation_ger_m = inflation_ger_y_m

# list(scaling[167-w:396-w]['German Inflation Expectations'])
# np.mean((np.array(inflation_ger_m['Unnamed: 3']) - np.array(list(scaling[167-w:396-w]['German Inflation Expectations'])))**2)

# Wrong timeframe!
# Extend_inf = pd.DataFrame()
# Extend_inf['historical german inflation'] = list(hist_ger_inflation_m[108:].iloc[1:,1])
# Extend_inf['german inflation'] = list(inflation_ger_m.iloc[1:,1])

# Extend_inf.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Extend_inf.xlsx')

#data_ECB_index_mon2.iloc[:,0] = preprocessing.scale(np.float32(data_ECB_index_mon2))
#data_ECB_index_mon2_q = pd.DataFrame(data_ECB_index_mon2).groupby(pd.Grouper(freq="Q")).mean()
#data_ECB_index_mon2_m = pd.DataFrame(data_ECB_index_mon2).groupby(pd.Grouper(freq="M")).mean().fillna(method = 'ffill')


#data_ECB_index_inf2.iloc[:,0] = preprocessing.scale(np.float32(data_ECB_index_inf2))
#data_ECB_index_inf2_q = pd.DataFrame(data_ECB_index_inf2).groupby(pd.Grouper(freq="Q")).mean()
#data_ECB_index_inf2_m = pd.DataFrame(data_ECB_index_inf2).groupby(pd.Grouper(freq="M")).mean().fillna(method = 'ffill')

# inflation_ea_m_past = inflation_ea_m[31:260]
# inflation_ea_m_past.iloc[:,1] = pd.to_numeric(inflation_ea_m_past.iloc[:,1])

# inflation_ger_qoq = transform_date(inflation_ger_qoq)
# inflation_ger_qoq = inflation_ger_qoq[:77]

# inflation_ger_y = transform_date(inflation_ger_y)

# inflation_ger_y_prev = inflation_ger_y[39:-4]
# inflation_ger_y_m_prev = inflation_ger_y.groupby(pd.Grouper(freq="M")).mean().fillna(method = 'ffill')

# inflation_ger_y = inflation_ger_y[40:-3]
# inflation_ger_y_m = inflation_ger_y.groupby(pd.Grouper(freq="M")).mean().fillna(method = 'ffill')

#ea_inf_exp_quant.index = pd.date_range('31/12/2003', '31/3/2022', freq = 'Q').tolist()

# def scale_data(data):
#     return (data - np.mean(data)) / np.std(data)

# # Scale the input data
# scaled_perc_weight = scale_data(scaling['perc_weight'])
# scaled_st = scale_data(hist_ger_inflation_rollm_m_tran['Unnamed: 3'])
# scaled_pi_t = scale_data(inflation_ger_m['Unnamed: 3'])

# # Use better initial parameters (if you have any idea about their values)
# #initial_params = [1, 1, 1, 1]

# result = least_squares(objective_function, initial_params, args=(scaled_perc_weight, scaled_st, scaled_pi_t))

