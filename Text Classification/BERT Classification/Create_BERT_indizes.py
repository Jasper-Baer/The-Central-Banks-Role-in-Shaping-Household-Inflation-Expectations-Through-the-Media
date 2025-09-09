# -*- coding: utf-8 -*-
"""
Created on Mon Aug 22 21:19:32 2022

"""

import pandas as pd

import os

from tqdm import tqdm
tqdm.pandas()


from ast import literal_eval
from datetime import timedelta

def load_csv_data(base_path, file_name, column_date=None):
    file_path = os.path.join(base_path, file_name)
    data = pd.read_csv(file_path)
    if column_date:
        data[column_date] = pd.to_datetime(data[column_date])
        data.set_index(column_date, inplace=True)
    return data

###############################################################################

data = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\dpa\dpa_prepro_final_sentences_no_lemmas_no_tokens.csv', encoding = 'utf-8', index_col = None,  keep_default_na=False,
                   dtype = {'title': 'str',
                          'texts': 'str'},
                   usecols=['date','title', 'texts'])

data_new = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\dpa\dpa_prepro_final_sentences_no_lemmas_full_with_lemmas_new_dpa.csv', encoding = 'utf-8', index_col = None,  keep_default_na=False,
                    dtype = {'title': 'object',
                            'texts': 'object'},
                    usecols=['date', 'title', 'texts'], low_memory = False)

data_inf_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\sent_inf_label_BERTv3.xlsx', usecols=['tokens', 'date', 'text','Label'])
data_sent_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\sent_sent_label_BERTv3.xlsx', usecols=['tokens', 'date', 'text','Label'])
data_mon_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\sent_mon_label_BERTv3.xlsx', usecols=['tokens', 'date', 'text','Label'])
data_sentmon_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\sent_sentmon_label_BERTv3.xlsx', usecols=['tokens', 'date', 'text','Label'])

data_inf_all_new = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\sent_inf_label_BERTv3_new_dpa.xlsx', usecols=['tokens', 'date', 'text','Label'])
data_sent_all_new = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\sent_sent_label_BERTv3_new_dpa.xlsx', usecols=['tokens', 'date', 'text','Label'])
data_mon_all_new = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\sent_mon_label_BERTv3_new_dpa.xlsx', usecols=['tokens', 'date', 'text','Label'])
data_sentmon_all_new = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\sent_sentmon_label_BERTv3_new_dpa.xlsx', usecols=['tokens', 'date', 'text','Label'])

data_new['date'] = pd.to_datetime(data_new['date']).dt.strftime('%Y-%m-%d')

data_inf_all_new['date'] = pd.to_datetime(data_inf_all_new['date']).dt.strftime('%Y-%m-%d')
data_sent_all_new['date'] = pd.to_datetime(data_sent_all_new['date']).dt.strftime('%Y-%m-%d')
data_mon_all_new['date'] = pd.to_datetime(data_mon_all_new['date']).dt.strftime('%Y-%m-%d')
data_sentmon_all_new['date'] = pd.to_datetime(data_sentmon_all_new['date']).dt.strftime('%Y-%m-%d')

data = pd.concat([data, data_new])

data_inf_all = pd.concat([data_inf_all, data_inf_all_new])
data_sent_all = pd.concat([data_sent_all, data_sent_all_new])
data_mon_all = pd.concat([data_mon_all, data_mon_all_new])
data_sentmon_all = pd.concat([data_sentmon_all, data_sentmon_all_new])

data_inf_all['date'] = pd.to_datetime(data_inf_all['date'])
data_sent_all['date'] = pd.to_datetime(data_inf_all['date'])
data_mon_all['date'] = pd.to_datetime(data_mon_all['date'])
data_sentmon_all['date'] = pd.to_datetime(data_sentmon_all['date'])

data['date'] = pd.to_datetime(data['date'])

###############################################################################

# PR = load_csv_data('D:\Studium\PhD\Github\Single-Author\Code\Regression', 'cbci_data.csv')
# PR['date'] = pd.to_datetime(PR['date'])
# PR.index = PR['date'] 
# PR = PR.drop('date', axis=1)
#PR = PR[:-16]
#PR = PR.resample('M').ffill()

#data_surv_dates = list(PR.index)

press_sents = pd.read_excel(r'D:\Studium\PhD\Github\Single-Author\Data\ECB_sents_prepared.xlsx')
press_sents['date'] = pd.to_datetime(press_sents['date'])

data_surv_dates = sorted(press_sents['date'].unique())

# dates_series = pd.Series(pd.to_datetime(data_surv_dates))
# double = [0]*len(dates_series)

# for i in range(1, len(dates_series)):
#     if dates_series[i] == dates_series[i-1]:
#         dates_series[i] = dates_series[i] + pd.DateOffset(months=1)
#         double[i] = 1

#data_surv_dates = dates_series

#pd.DataFrame(double).to_csv(PATH + '\\' + 'double_ECB_months.csv')

# data_surv_dates = pd.to_datetime(dates_series)
# data_surv_dates = pd.DatetimeIndex(data_surv_dates)

###############################################################################

def extract_date(entry):

    if '(' in entry:
        date_str = entry.split(' (')[0]
        month_str = entry.split(' (')[1].replace(')', '')
    else:
        date_str = entry
        month_str = date_str.split(' ')[0]
    
    return pd.to_datetime(date_str), month_str

###

#data_surv_dates = pd.date_range(start='2001-11-01', periods=266, freq='MS') + pd.Timedelta(days=14)
#data_surv_dates = pd.date_range(start='2001-12-01', periods=229, freq='MS') + pd.Timedelta(days=29)

data_inf_all = data_inf_all[(data_inf_all['date'] >= data_surv_dates[0]) & (data_inf_all['date'] <= data_surv_dates[-1])]
data_sent_all = data_sent_all[(data_sent_all['date'] >= data_surv_dates[0]) & (data_sent_all['date'] <= data_surv_dates[-1])]
data_mon_all = data_mon_all[(data_mon_all['date'] >= data_surv_dates[0]) & (data_mon_all['date'] <= data_surv_dates[-1])]
data_sentmon_all = data_sentmon_all[(data_sentmon_all['date'] >= data_surv_dates[0]) & (data_sentmon_all['date'] <= data_surv_dates[-1])]
data = data[(data['date'] >= data_surv_dates[0]) & (data['date'] <= data_surv_dates[-1])]

###

data_inf_all = data_inf_all[~data_inf_all['text'].str.contains('Referenzkurs', case=False, na=False)]
data_sent_all = data_sent_all[~data_sent_all['text'].str.contains('Referenzkurs', case=False, na=False)]
data_mon_all = data_mon_all[~data_mon_all['text'].str.contains('Referenzkurs', case=False, na=False)]
data_sentmon_all = data_sentmon_all[~data_sentmon_all['text'].str.contains('Referenzkurs', case=False, na=False)]

data = data[~data['texts'].str.contains('Referenzkurs', case=False, na=False)]

###############################################################################

####### CHANGE THIS
####### IMPORTANT

# def assign_period(date, agg_dates):
#     two_weeks = pd.Timedelta(weeks=2)
#     for idx in range(len(agg_dates) - 1):
#         if agg_dates[idx] <= date <= agg_dates[idx] + two_weeks:
#             return idx, True
#     return len(agg_dates) - 1, False

# agg_period_inf = data_inf_all['date'].progress_apply(lambda x: assign_period(x, data_surv_dates))
# data_inf_all['Period'] = agg_period_inf.apply(lambda x: x[0])
# data_inf_all['InWindow'] = agg_period_inf.apply(lambda x: x[1])
# data_inf_all = data_inf_all[data_inf_all['InWindow']]

# agg_period_sent = data_sent_all['date'].progress_apply(lambda x: assign_period(x, data_surv_dates))
# data_sent_all['Period'] = agg_period_sent.apply(lambda x: x[0])
# data_sent_all['InWindow'] = agg_period_sent.apply(lambda x: x[1])
# data_sent_all = data_sent_all[data_sent_all['InWindow']]

# agg_period_mon = data_mon_all['date'].progress_apply(lambda x: assign_period(x, data_surv_dates))
# data_mon_all['Period'] = agg_period_mon.apply(lambda x: x[0])
# data_mon_all['InWindow'] = agg_period_mon.apply(lambda x: x[1])
# data_mon_all = data_mon_all[data_mon_all['InWindow']]

# agg_period_sentmon = data_sentmon_all['date'].progress_apply(lambda x: assign_period(x, data_surv_dates))
# data_sentmon_all['Period'] = agg_period_sentmon.apply(lambda x: x[0])
# data_sentmon_all['InWindow'] = agg_period_sentmon.apply(lambda x: x[1])
# data_sentmon_all = data_sentmon_all[data_sentmon_all['InWindow']]

# agg_period_data = data['date'].progress_apply(lambda x: assign_period(x, data_surv_dates))
# data['Period'] = agg_period_data.apply(lambda x: x[0])
# data['InWindow'] = agg_period_data.apply(lambda x: x[1])
# data = data[data['InWindow']]

# data_inf_all = data_inf_all.drop(columns=['InWindow'])
# data_sent_all = data_sent_all.drop(columns=['InWindow'])
# data_mon_all = data_mon_all.drop(columns=['InWindow'])
# data_sentmon_all = data_sentmon_all.drop(columns=['InWindow'])
# data = data.drop(columns=['InWindow'])

import numpy as np

agg_dates = np.sort(data_surv_dates)

two_weeks = pd.Timedelta(weeks=2)

def assign_period_vectorized(data, agg_dates):
    agg_dates = np.sort(agg_dates)
    
    periods = np.searchsorted(agg_dates, data['date'], side='right') - 1
    
    periods = np.clip(periods, 0, len(agg_dates) - 1)
    
    in_window_mask = (data['date'] >= agg_dates[periods]) & (data['date'] <= agg_dates[periods] + two_weeks)
    
    return periods, in_window_mask

data_inf_all['Period'], data_inf_all['InWindow'] = assign_period_vectorized(data_inf_all, agg_dates)
data_sent_all['Period'], data_sent_all['InWindow'] = assign_period_vectorized(data_sent_all, agg_dates)
data_mon_all['Period'], data_mon_all['InWindow'] = assign_period_vectorized(data_mon_all, agg_dates)
data_sentmon_all['Period'], data_sentmon_all['InWindow'] = assign_period_vectorized(data_sentmon_all, agg_dates)
data['Period'], data['InWindow'] = assign_period_vectorized(data, agg_dates)

data_inf_all = data_inf_all[data_inf_all['InWindow']].drop(columns=['InWindow'])
data_sent_all = data_sent_all[data_sent_all['InWindow']].drop(columns=['InWindow'])
data_mon_all = data_mon_all[data_mon_all['InWindow']].drop(columns=['InWindow'])
data_sentmon_all = data_sentmon_all[data_sentmon_all['InWindow']].drop(columns=['InWindow'])
data = data[data['InWindow']].drop(columns=['InWindow'])

# FULL MONTH
date_mapping = {i: date for i, date in enumerate(data_surv_dates)}

data_inf_all['t_date'] = data_inf_all['Period'].map(date_mapping)
data_sent_all['t_date'] = data_sent_all['Period'].map(date_mapping)

data_mon_all['t_date'] = data_mon_all['Period'].map(date_mapping)
data_sentmon_all['t_date'] = data_sentmon_all['Period'].map(date_mapping)

data['t_date'] = data['Period'].map(date_mapping)

###############################################################################



# def assign_period(date, agg_dates):
#     for idx, agg_date in enumerate(agg_dates):
#         if date <= agg_date:
#             return idx
#     return len(agg_dates)

# def assign_period(date, agg_dates):
#     for idx in range(len(agg_dates) - 1):
#         if agg_dates[idx] <= date < agg_dates[idx + 1]:
#             return idx
#     return len(agg_dates) - 1 

#agg_period = data_inf_all['date'].progress_apply(lambda x: assign_period(x, data_surv_dates))
# data_inf_all['Period'] = np.searchsorted(agg_dates, data_inf_all['date'])
# data_sent_all['Period'] =np.searchsorted(agg_dates, data_sent_all['date'])

# #agg_period = data_mon_all['date'].progress_apply(lambda x: assign_period(x, data_surv_dates))
# data_mon_all['Period'] = np.searchsorted(agg_dates, data_mon_all['date'])
# data_sentmon_all['Period'] = np.searchsorted(agg_dates, data_sentmon_all['date'])

# #agg_period = data['date'].progress_apply(lambda x: assign_period(x, data_surv_dates))
# data['Period'] = np.searchsorted(agg_dates, data['date'])

# date_mapping = {i: date for i, date in enumerate(data_surv_dates)}

# data_inf_all['t_date'] = data_inf_all['Period'].map(date_mapping)
# data_sent_all['t_date'] = data_sent_all['Period'].map(date_mapping)

# data_mon_all['t_date'] = data_mon_all['Period'].map(date_mapping)
# data_sentmon_all['t_date'] = data_sentmon_all['Period'].map(date_mapping)

# data['t_date'] = data['Period'].map(date_mapping)

###############################################################################

def prepare_data(data, freq = 'M'):
    
   data['t_date'] = pd.to_datetime(data['t_date'])
   #data['year_month'] = (data['t_date']) #+ pd.offsets.MonthEnd(0))
   #.dt.strftime('%Y-%m-%d')
   data_count = data.groupby('t_date').size()
   
   return(data_count)

data_count = prepare_data(data)
#data_count_inf_all = prepare_data(data_inf_all)

###############################################################################

# data.to_csv(r'D:\Studium\PhD\Single Author\Data\dpa\data_period_full_month_survey_ECB_4.csv')
# data_inf_all.to_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_inf_period_full_month_survey_ECB_4.xlsx')
# data_sent_all.to_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_sent_period_full_month_survey_ECB_4.xlsx')
# data_mon_all.to_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_mon_period_full_month_survey_ECB_4.xlsx')
# data_sentmon_all.to_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_sentmon_period_full_month_survey_ECB_4.xlsx')

# data.to_csv(r'D:\Studium\PhD\Single Author\Data\dpa\data_period_full_month_survey_ECB_3.csv')
# data_inf_all.to_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_inf_period_full_month_survey_ECB_3.xlsx')
# data_sent_all.to_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_sent_period_full_month_survey_ECB_3.xlsx')
# data_mon_all.to_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_mon_period_full_month_survey_ECB_3.xlsx')
# data_sentmon_all.to_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_sentmon_period_full_month_survey_ECB_3.xlsx')

# data.to_csv(r'D:\Studium\PhD\Single Author\Data\dpa\data_period_full_month_survey_15_new.csv')
# data_inf_all.to_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_inf_period_full_month_survey_15_new.xlsx')
# data_sent_all.to_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_sent_period_full_month_survey_15_new.xlsx')
# data_mon_all.to_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_mon_period_full_month_survey_15_new.xlsx')
# data_sentmon_all.to_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_sentmon_period_full_month_survey_15_new.xlsx')

# data.to_csv(r'D:\Studium\PhD\Single Author\Data\dpa\data_period_full_month_survey_15.csv')
# data_inf_all.to_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_inf_period_full_month_survey_15.xlsx')
# data_sent_all.to_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_sent_period_full_month_survey_15.xlsx')
# data_mon_all.to_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_mon_period_full_month_survey_15.xlsx')
# data_sentmon_all.to_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_sentmon_period_full_month_survey_15.xlsx')

# data.to_csv(r'D:\Studium\PhD\Single Author\Data\dpa\data_period_full_month.csv')
# data_inf_all.to_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_inf_period_full_month.xlsx')
# data_sent_all.to_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_sent_period_full_month.xlsx')
# data_mon_all.to_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_mon_period_full_month.xlsx')
# data_sentmon_all.to_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_sentmon_period_full_month.xlsx')

###############################################################################
###############################################################################
###############################################################################

data_inf_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_inf_period_full_month_survey_ECB_4.xlsx')
data_sent_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_sent_period_full_month_survey_ECB_4.xlsx')
data_mon_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_mon_period_full_month_survey_ECB_4.xlsx')
data_sentmon_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_sentmon_period_full_month_survey_ECB_4.xlsx')

data = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\dpa\data_period_full_month_survey_ECB_4.csv', encoding = 'utf-8', index_col = 0,  keep_default_na=False,
                    dtype = {'rubrics': 'str', 
                            'source': 'str',
                            'keywords': 'str',
                            'title': 'str',
                            'city': 'str',
                            'genre': 'str',
                            'texts': 'str'})

# data_inf_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_inf_period_full_month_survey_ECB_3.xlsx')
# data_sent_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_sent_period_full_month_survey_ECB_3.xlsx')
# data_mon_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_mon_period_full_month_survey_ECB_3.xlsx')
# data_sentmon_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_sentmon_period_full_month_survey_ECB_3.xlsx')

# data = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\dpa\data_period_full_month_survey_ECB_3.csv', encoding = 'utf-8', index_col = 0,  keep_default_na=False,
#                     dtype = {'rubrics': 'str', 
#                             'source': 'str',
#                             'keywords': 'str',
#                             'title': 'str',
#                             'city': 'str',
#                             'genre': 'str',
#                             'texts': 'str'})

###############################################################################

# data_inf_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_inf_period_full_month_survey_15.xlsx')
# data_sent_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_sent_period_full_month_survey_15.xlsx')
# data_mon_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_mon_period_full_month_survey_15.xlsx')
# data_sentmon_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_sentmon_period_full_month_survey_15.xlsx')

# data = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\dpa\data_period_full_month_survey_15.csv', encoding = 'utf-8', index_col = 0,  keep_default_na=False,
#                     dtype = {'rubrics': 'str', 
#                             'source': 'str',
#                             'keywords': 'str',
#                             'title': 'str',
#                             'city': 'str',
#                             'genre': 'str',
#                             'texts': 'str'})

# data_inf_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_inf_period_full_month_survey_15_new.xlsx')
# data_sent_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_sent_period_full_month_survey_15_new.xlsx')
# data_mon_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_mon_period_full_month_survey_15_new.xlsx')
# data_sentmon_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_sentmon_period_full_month_survey_15_new.xlsx')

# data = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\dpa\data_period_full_month_survey_15_new.csv', encoding = 'utf-8', index_col = 0,  keep_default_na=False,
#                     dtype = {'rubrics': 'str', 
#                             'source': 'str',
#                             'keywords': 'str',
#                             'title': 'str',
#                             'city': 'str',
#                             'genre': 'str',
#                             'texts': 'str'})

###############################################################################

# data_inf_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_inf_period_full_month.xlsx')
# data_sent_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_sent_period_full_month.xlsx')
# data_mon_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_mon_period_full_month.xlsx')
# data_sentmon_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_sentmon_period_full_month.xlsx')

# data = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\dpa\data_period_full_month.csv', encoding = 'utf-8', index_col = 0,  keep_default_na=False,
#                     dtype = {'rubrics': 'str', 
#                             'source': 'str',
#                             'keywords': 'str',
#                             'title': 'str',
#                             'city': 'str',
#                             'genre': 'str',
#                             'texts': 'str'})

###############################################################################

# data_inf_all_lex = pd.read_csv(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\PR_news_inf_direction_results_final.csv')
# #data_sent_all_lex = pd.read_csv(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\PR_news_sent_direction_results_final.csv')
# data_mon_all_lex = pd.read_csv(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\PR_news_mon_direction_results_final.csv')
# data_sentmon_all_lex = pd.read_csv(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\PR_news_mon_sentiment_results_final.csv')

# data_inf_all_lex = data_inf_all_lex.rename(columns={'text' + 's': 'text', 't_date': 'date'})
# data_inf_all_lex['text'] = data_inf_all_lex['text'].apply(lambda x: literal_eval(str(x))[0])

# def process_and_merge(data_all, data_all_lex):

#     data_all_lex = data_all_lex[data_all_lex['text'].isin(data_all['text'])]
    
#     data_subset = data_all[['text', 'date']]
#     data_all_lex = pd.merge(data_all_lex, data_subset, on='text', how='left')
#     #data_all_lex = data_all_lex.drop_duplicates(subset='text')
    
#     if 'date_y' in data_all_lex.columns:
#         data_all_lex.drop(columns=['date_y'], inplace=True)

#     if 'date_x' in data_all_lex.columns:
#         data_all_lex.rename(columns={'date_x': 'date'}, inplace=True)
        
#     data_all_lex['tokens'] = data_all['tokens']
#     data_all_lex['t_date'] = data_all['t_date']
    
#     return(data_all_lex)

# data_inf_all = process_and_merge(data_inf_all, data_inf_all_lex)
# #data_sent_all_lex_processed = process_and_merge(data_sent_all, data_sent_all_lex)

# data_mon_all = process_and_merge(data_mon_all, data_mon_all_lex)
# data_sentmon_all = process_and_merge(data_sentmon_all, data_sentmon_all_lex)

###############################################################################

data_inf_all['date'] = pd.to_datetime(data_inf_all['date'])
data_sent_all['date'] = pd.to_datetime(data_inf_all['date'])

data_mon_all['date'] = pd.to_datetime(data_mon_all['date'])
data_sentmon_all['date'] = pd.to_datetime(data_sentmon_all['date'])

data['date'] = pd.to_datetime(data['date'])

###############################################################################

ecb_sentences = pd.read_csv(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\news_dpa_ecb_inflation_sentences_ecbrelated_2.csv'
                            , encoding = 'utf-8')

ecb_sentences_new = pd.read_csv(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\news_dpa_ecb_inflation_sentences_ecbrelated_2_new_dpa.csv'
                            , encoding = 'utf-8')

ecb_sentences_new['date'] = pd.to_datetime(ecb_sentences_new['date']).dt.strftime('%Y-%m-%d')

ecb_sentences = pd.concat([ecb_sentences, ecb_sentences_new])

ecb_sentences = ecb_sentences[~ecb_sentences['text'].str.contains('Referenzkurs', case=False, na=False)]
ecb_sentences = ecb_sentences[~ecb_sentences['text'].str.contains('Zentralbank \(EZB\) setzte', case=False, na=False)]
ecb_sentences = ecb_sentences[~ecb_sentences['text'].str.contains('Zentralbank \(EZB\) ließ', case=False, na=False)]

###

data_inf = data_inf_all
data_sent = data_sent_all
data_mon = data_mon_all
data_sentmon = data_sentmon_all

ecb_sentences_non_quotes = ecb_sentences[~ecb_sentences['Label'].astype(bool)]
ecb_sentences_quotes = ecb_sentences[ecb_sentences['Label'].astype(bool)]

data_inf_ecb_quotes = data_inf_all[data_inf_all['tokens'].isin(ecb_sentences_quotes['tokens'])]
data_inf_ecb_non_quotes = data_inf_all[data_inf_all['tokens'].isin(ecb_sentences_non_quotes['tokens'])]

data_sent_ecb_quotes = data_sent_all[data_sent_all['tokens'].isin(ecb_sentences_quotes['tokens'])]
data_sent_ecb_non_quotes = data_sent_all[data_sent_all['tokens'].isin(ecb_sentences_non_quotes['tokens'])]

data_mon_ecb_quotes = data_mon_all[data_mon_all['tokens'].isin(ecb_sentences_quotes['tokens'])]
data_mon_ecb_non_quotes = data_mon_all[data_mon_all['tokens'].isin(ecb_sentences_non_quotes['tokens'])]

data_sentmon_ecb_quotes = data_sentmon_all[data_sentmon_all['tokens'].isin(ecb_sentences_quotes['tokens'])]
data_sentmon_ecb_non_quotes = data_sentmon_all[data_sentmon_all['tokens'].isin(ecb_sentences_non_quotes['tokens'])]

###

data_inf_ecb_quotes = data_inf_ecb_quotes.dropna(subset=['date'])
data_inf_ecb_non_quotes = data_inf_ecb_non_quotes.dropna(subset=['date'])

data_sent_ecb_quotes = data_sent_ecb_quotes.dropna(subset=['date'])
data_sent_ecb_non_quotes = data_sent_ecb_non_quotes.dropna(subset=['date'])

data_sentmon_ecb_quotes = data_sentmon_ecb_quotes.dropna(subset=['date'])
data_sentmon_ecb_non_quotes = data_sentmon_ecb_non_quotes.dropna(subset=['date'])

data_mon_ecb_quotes = data_mon_ecb_quotes.dropna(subset=['date'])
data_mon_ecb_non_quotes = data_mon_ecb_non_quotes.dropna(subset=['date'])

###############################################################################

#count_rel_news_m = (prepare_data(data_inf_all)/data_count).fillna(0)
#count_rel_news_m.to_csv(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\monthly_inflation_count_inf_to_all.csv')

# count_rel_ecb_news_quotes_m = (prepare_data(data_mon_ecb_quotes)/data_count).fillna(0)

###

#data_ECB_sents_inf = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\ECB\press_sents_full_index_labeled_inf.xlsx')

# dates0 = set(data_ECB_sents_inf['date'])
# dates1 = {timestamp - timedelta(days=1) for timestamp in dates0}

###

def ECB_quotes(data_mon_ecb_quotes, data_sent_ecb_quotes, data_mon_ecb_non_quotes, data_sent_ecb_non_quotes, data_sentmon_ecb_quotes, data_sentmon_ecb_non_quotes, data, data_count = None, dates = None, lex = False, og = False):

    def prepare_data(data, freq = 'M', lex = False, og = False):
        
       #.dt.strftime('%Y-%m-%d')
       
       data = data.copy()  
         
       data.rename_axis('index', inplace=True)
       data['t_date'] = pd.to_datetime(data['t_date'])
       
       if lex == False and og == False:
         
       
           data_count = data.groupby('t_date').size()
           data_count.rename_axis('index', inplace=True)
           
           data_count = data_count.resample('M').ffill()
           
           data['t_date'] = (data['t_date'] + pd.offsets.MonthEnd(0))
           
           start_date = data_count.index.min()
           end_date = data_count.index.max()
           
           start_date = pd.to_datetime('1999-12-31')
           end_date = pd.to_datetime('2023-12-31')
           
           all_months = pd.date_range(start=start_date, end=end_date, freq=freq)
           data_count = data_count.reindex(all_months, fill_value=0)
           
       elif lex == True:
           
           def process_data(data, value_column, freq, start_date='1999-12-31', end_date='2018-12-31'):
 
            data['t_date'] = pd.to_datetime(data['t_date'])
        
            data_avg_index = data.groupby('t_date')[value_column].mean().reset_index()
            data_avg_index['t_date'] = data_avg_index['t_date'] + pd.offsets.MonthEnd(0)

            start_date = pd.to_datetime(start_date)
            end_date = pd.to_datetime(end_date)
        
            all_months = pd.date_range(start=start_date, end=end_date, freq=freq)
        
            data_count = data_avg_index.set_index('t_date').reindex(all_months, fill_value=0).reset_index()
            data_count.rename(columns={'index': 't_date'}, inplace=True)
        
            return(data_count)
        
           pos_share = process_data(data, 'pos share PMI', 'M')
           neu_share = process_data(data, 'neu share PMI', 'M')
           neg_share = process_data(data, 'neg share PMI', 'M')
            
           combined_data = pos_share.merge(neu_share, on='t_date', suffixes=('_pos', '_neu'))
           combined_data = combined_data.merge(neg_share, on='t_date')
           combined_data.rename(columns={'pos share PMI': 'pos_share', 'neu share PMI': 'neu_share', 'neg share PMI': 'neg_share'}, inplace=True)
            
           return(combined_data)
           
       elif og == True:
           
           data_count = data.groupby('t_date').size()
           data_count.rename_axis('index', inplace=True)
       
       return(data_count)  
    
    if dates is not None:
        
        data = data[data['date'].isin(dates)]
        data['t_date'] = data['date']
        data_count = prepare_data(data)
        
        data_inf['t_date'] = data_inf['date']
        data_mon['t_date'] = data_mon['date']
        data_sent['t_date'] = data_sent['date']
        
    else:
        
        #data['t_date'] = data['date']
        data_count = prepare_data(data, og = og)
       # data_count = data_count[1:]
       
        
    # else:
        
    # data_count.rename_axis('index', inplace=True)
    # start_date = data_count.index.min()
    # end_date = data_count.index.max()
    # all_months = pd.date_range(start=start_date, end=end_date, freq='M')
    # data_count = data_count.reindex(all_months)
    
    #data_prepared = prepare_data(data_mon_ecb_quotes[data_mon_ecb_quotes['Label'] == 2])
    #data_count = data_count.reindex(data_prepared.index)[0]
    
    if lex == False:
        
        data_sentmon_ecb_quotes = data_sentmon_ecb_quotes[:-1] 
        data_mon_ecb_quotes = data_mon_ecb_quotes[:-1]
        data_sent_ecb_non_quotes = data_sent_ecb_non_quotes[:-1]
        
        data_mon_ecb_quotes.index = data_mon_ecb_quotes['t_date']
        data_sentmon_ecb_quotes.index = data_sentmon_ecb_quotes['t_date']
        data_mon_ecb_non_quotes.index = data_mon_ecb_non_quotes['t_date']
        data_sentmon_ecb_non_quotes.index = data_sentmon_ecb_non_quotes['t_date']
        
        data_sent_ecb_quotes.index = data_sent_ecb_quotes['t_date']
        data_mon_ecb_non_quotes.index = data_mon_ecb_non_quotes['t_date']
        data_sent_ecb_non_quotes.index = data_sent_ecb_non_quotes['t_date']
        
        #data_count.index = prepare_data(data_mon_ecb_quotes[data_mon_ecb_quotes['Label'] == 2], og = og).index
    
        hawkish_ECB_quotes_news = (prepare_data(data_mon_ecb_quotes[data_mon_ecb_quotes['Label'] == 2], og = og)/data_count).fillna(0)
        nomon_ECB_quotes_news = (prepare_data(data_mon_ecb_quotes[data_mon_ecb_quotes['Label'] == 1], og = og)/data_count).fillna(0)
        dovish_ECB_quotes_news = (prepare_data(data_mon_ecb_quotes[data_mon_ecb_quotes['Label'] == 0], og = og)/data_count).fillna(0)
        
        ###
        
        hawkish_ECB_non_quotes_news = (prepare_data(data_mon_ecb_non_quotes[data_mon_ecb_non_quotes['Label'] == 2], og = og)/data_count).fillna(0)
        nomon_ECB_non_quotes_news = (prepare_data(data_mon_ecb_non_quotes[data_mon_ecb_non_quotes['Label'] == 1], og = og)/data_count).fillna(0)
        dovish_ECB_non_quotes_news = (prepare_data(data_mon_ecb_non_quotes[data_mon_ecb_non_quotes['Label'] == 0], og = og)/data_count).fillna(0)
        
        #############
        # BAUSTELLE #
        #############
        
        goodhawkish_ECB_quotes_news = (prepare_data(data_mon_ecb_quotes[(data_mon_ecb_quotes['Label'] == 2) & (data_sentmon_ecb_quotes['Label'] == 2)], og = og)/data_count).fillna(0)
        goodnomon_ECB_quotes_news = (prepare_data(data_mon_ecb_quotes[(data_mon_ecb_quotes['Label'] == 1) & (data_sentmon_ecb_quotes['Label'] == 2)], og = og)/data_count).fillna(0)
        gooddovish_ECB_quotes_news = (prepare_data(data_mon_ecb_quotes[(data_mon_ecb_quotes['Label'] == 0) & (data_sentmon_ecb_quotes['Label'] == 2)], og = og)/data_count).fillna(0)
        
        ###
        
        neutralhawkish_ECB_quotes_news = (prepare_data(data_mon_ecb_quotes[(data_mon_ecb_quotes['Label'] == 2) & (data_sentmon_ecb_quotes['Label'] == 1)], og = og)/data_count).fillna(0)
        neutralnomon_ECB_quotes_news = (prepare_data(data_mon_ecb_quotes[(data_mon_ecb_quotes['Label'] == 1) & (data_sentmon_ecb_quotes['Label'] == 1)], og = og)/data_count).fillna(0)
        neutraldovish_ECB_quotes_news = (prepare_data(data_mon_ecb_quotes[(data_mon_ecb_quotes['Label'] == 0) & (data_sentmon_ecb_quotes['Label'] == 1)], og = og)/data_count).fillna(0)
        
        ###
        
        badhawkish_ECB_quotes_news = (prepare_data(data_mon_ecb_quotes[(data_mon_ecb_quotes['Label'] == 2) & (data_sentmon_ecb_quotes['Label'] == 0)], og = og)/data_count).fillna(0)
        badnomon_ECB_quotes_news = (prepare_data(data_mon_ecb_quotes[(data_mon_ecb_quotes['Label'] == 1) & (data_sentmon_ecb_quotes['Label'] == 0)], og = og)/data_count).fillna(0)
        baddovish_ECB_quotes_news = (prepare_data(data_mon_ecb_quotes[(data_mon_ecb_quotes['Label'] == 0) & (data_sentmon_ecb_quotes['Label'] == 0)], og = og)/data_count).fillna(0)
        
        ###
        
        goodhawkish_ECB_non_quotes_news = (prepare_data(data_mon_ecb_non_quotes[(data_mon_ecb_non_quotes['Label'] == 2) & (data_sentmon_ecb_non_quotes['Label'] == 2)], og = og)/data_count).fillna(0)
        goodnomon_ECB_non_quotes_news = (prepare_data(data_mon_ecb_non_quotes[(data_mon_ecb_non_quotes['Label'] == 1) & (data_sentmon_ecb_non_quotes['Label'] == 2)], og = og)/data_count).fillna(0)
        gooddovish_ECB_non_quotes_news = (prepare_data(data_mon_ecb_non_quotes[(data_mon_ecb_non_quotes['Label'] == 0) & (data_sentmon_ecb_non_quotes['Label'] == 2)], og = og)/data_count).fillna(0)
        
        ###
        
        neutralhawkish_ECB_non_quotes_news = (prepare_data(data_mon_ecb_non_quotes[(data_mon_ecb_non_quotes['Label'] == 2) & (data_sentmon_ecb_non_quotes['Label'] == 1)], og = og)/data_count).fillna(0)
        neutralnomon_ECB_non_quotes_news = (prepare_data(data_mon_ecb_non_quotes[(data_mon_ecb_non_quotes['Label'] == 1) & (data_sentmon_ecb_non_quotes['Label'] == 1)], og = og)/data_count).fillna(0)
        neutraldovish_ECB_non_quotes_news = (prepare_data(data_mon_ecb_non_quotes[(data_mon_ecb_non_quotes['Label'] == 0) & (data_sentmon_ecb_non_quotes['Label'] == 1)], og = og)/data_count).fillna(0)
        
        ###
        
        badhawkish_ECB_non_quotes_news = (prepare_data(data_mon_ecb_non_quotes[(data_mon_ecb_non_quotes['Label'] == 2) & (data_sentmon_ecb_non_quotes['Label'] == 0)], og = og)/data_count).fillna(0)
        badnomon_ECB_non_quotes_news = (prepare_data(data_mon_ecb_non_quotes[(data_mon_ecb_non_quotes['Label'] == 1) & (data_sentmon_ecb_non_quotes['Label'] == 0)], og = og)/data_count).fillna(0)
        baddovish_ECB_non_quotes_news = (prepare_data(data_mon_ecb_non_quotes[(data_mon_ecb_non_quotes['Label'] == 0) & (data_sentmon_ecb_non_quotes['Label'] == 0)], og = og)/data_count).fillna(0)
    
        ###
        
        positive_ECB_quotes_news = (prepare_data(data_sentmon_ecb_quotes[data_sentmon_ecb_quotes['Label'] == 2], og = og)/data_count).fillna(0)
        neutral_ECB_quotes_news = (prepare_data(data_sentmon_ecb_quotes[data_sentmon_ecb_quotes['Label'] == 1], og = og)/data_count).fillna(0)
        negative_ECB_quotes_news = (prepare_data(data_sentmon_ecb_quotes[data_sentmon_ecb_quotes['Label'] == 0], og = og)/data_count).fillna(0)
    
        ###
    
        positive_ECB_non_quotes_news = (prepare_data(data_sentmon_ecb_non_quotes[data_sentmon_ecb_non_quotes['Label'] == 2], og = og)/data_count).fillna(0)
        neutral_ECB_non_quotes_news = (prepare_data(data_sentmon_ecb_non_quotes[data_sentmon_ecb_non_quotes['Label'] == 1], og = og)/data_count).fillna(0)
        negative_ECB_non_quotes_news = (prepare_data(data_sentmon_ecb_non_quotes[data_sentmon_ecb_non_quotes['Label'] == 0], og = og)/data_count).fillna(0)
    
        ECB_quotes_count = prepare_data(data_mon_ecb_quotes, og = og)/data_count
        ECB_non_quotes_count = prepare_data(data_mon_ecb_non_quotes, og = og)/data_count
        
    elif lex == True:
            
        hawkish_ECB_quotes_news_lex = pd.DataFrame((prepare_data(data_mon_ecb_quotes, lex = True)['pos_share']).fillna(0))
        nomon_ECB_quotes_news_lex = pd.DataFrame((prepare_data(data_mon_ecb_quotes, lex = True)['neu_share']).fillna(0))
        dovish_ECB_quotes_news_lex = pd.DataFrame((prepare_data(data_mon_ecb_quotes, lex = True)['neg_share']).fillna(0))
        
        hawkish_ECB_quotes_news_lex.index = data_count.index        
        nomon_ECB_quotes_news_lex.index = data_count.index
        dovish_ECB_quotes_news_lex.index = data_count.index
        
        hawkish_ECB_quotes_news_lex.rename(columns={'pos_share': 'hawkish_pos_share_quotes'}, inplace=True)
        nomon_ECB_quotes_news_lex.rename(columns={'neu_share': 'nomon_neu_share_quotes'}, inplace=True)
        dovish_ECB_quotes_news_lex.rename(columns={'neg_share': 'dovish_neg_share_quotes'}, inplace=True)
        
        hawkish_ECB_non_quotes_news_lex = pd.DataFrame((prepare_data(data_mon_ecb_non_quotes, lex = True)['pos_share']).fillna(0))
        nomon_ECB_non_quotes_news_lex = pd.DataFrame((prepare_data(data_mon_ecb_non_quotes, lex = True)['neu_share']).fillna(0))
        dovish_ECB_non_quotes_news_lex = pd.DataFrame((prepare_data(data_mon_ecb_non_quotes, lex = True)['neg_share']).fillna(0))
        
        hawkish_ECB_non_quotes_news_lex.index = data_count.index        
        nomon_ECB_non_quotes_news_lex.index = data_count.index
        dovish_ECB_non_quotes_news_lex.index = data_count.index
        
        hawkish_ECB_non_quotes_news_lex.rename(columns={'pos_share': 'hawkish_pos_share_non_quotes'}, inplace=True)
        nomon_ECB_non_quotes_news_lex.rename(columns={'neu_share': 'nomon_neu_share_non_quotes'}, inplace=True)
        dovish_ECB_non_quotes_news_lex.rename(columns={'neg_share': 'dovish_neg_share_non_quotes'}, inplace=True)
        
        positive_ECB_quotes_news_lex = pd.DataFrame((prepare_data(data_sentmon_ecb_quotes, lex = True)['pos_share']).fillna(0))
        neutral_ECB_quotes_news_lex = pd.DataFrame((prepare_data(data_sentmon_ecb_quotes, lex = True)['neu_share']).fillna(0))
        negative_ECB_quotes_news_lex = pd.DataFrame((prepare_data(data_sentmon_ecb_quotes, lex = True)['neg_share']).fillna(0))
        
        positive_ECB_quotes_news_lex.index = data_count.index        
        neutral_ECB_quotes_news_lex.index = data_count.index
        negative_ECB_quotes_news_lex.index = data_count.index
        
        positive_ECB_quotes_news_lex.rename(columns={'pos_share': 'positive_pos_share_quotes'}, inplace=True)
        neutral_ECB_quotes_news_lex.rename(columns={'neu_share': 'neutral_neu_share_quotes'}, inplace=True)
        negative_ECB_quotes_news_lex.rename(columns={'neg_share': 'negative_neg_share_quotes'}, inplace=True)
            
        positive_ECB_non_quotes_news_lex = pd.DataFrame((prepare_data(data_sentmon_ecb_non_quotes, lex = True)['pos_share']).fillna(0))
        neutral_ECB_non_quotes_news_lex = pd.DataFrame((prepare_data(data_sentmon_ecb_non_quotes, lex = True)['neu_share']).fillna(0))
        negative_ECB_non_quotes_news_lex = pd.DataFrame((prepare_data(data_sentmon_ecb_non_quotes, lex = True)['neg_share']).fillna(0))
        
        positive_ECB_non_quotes_news_lex.index = data_count.index        
        neutral_ECB_non_quotes_news_lex.index = data_count.index
        negative_ECB_non_quotes_news_lex.index = data_count.index
        
        positive_ECB_non_quotes_news_lex.rename(columns={'pos_share': 'positive__pos_share_non_quotes'}, inplace=True)
        neutral_ECB_non_quotes_news_lex.rename(columns={'neu_share': 'neutral_neu_share_non_quotes'}, inplace=True)
        negative_ECB_non_quotes_news_lex.rename(columns={'neg_share': 'negative_neg_share_non_quotes'}, inplace=True)
            
        #sent_index = (prepare_data(data_sent, lex = True)['index']).fillna(0)
    
    if lex == False:
        
        return (
            hawkish_ECB_quotes_news, nomon_ECB_quotes_news, dovish_ECB_quotes_news,
            hawkish_ECB_non_quotes_news, nomon_ECB_non_quotes_news, dovish_ECB_non_quotes_news,
            goodhawkish_ECB_quotes_news, goodnomon_ECB_quotes_news, gooddovish_ECB_quotes_news,
            neutralhawkish_ECB_quotes_news, neutralnomon_ECB_quotes_news, neutraldovish_ECB_quotes_news,
            badhawkish_ECB_quotes_news, badnomon_ECB_quotes_news, baddovish_ECB_quotes_news,
            goodhawkish_ECB_non_quotes_news, goodnomon_ECB_non_quotes_news, gooddovish_ECB_non_quotes_news,
            neutralhawkish_ECB_non_quotes_news, neutralnomon_ECB_non_quotes_news, neutraldovish_ECB_non_quotes_news,
            badhawkish_ECB_non_quotes_news, badnomon_ECB_non_quotes_news, baddovish_ECB_non_quotes_news,
            positive_ECB_quotes_news, neutral_ECB_quotes_news, negative_ECB_quotes_news,
            positive_ECB_non_quotes_news, neutral_ECB_non_quotes_news, negative_ECB_non_quotes_news, 
            ECB_quotes_count, ECB_non_quotes_count
        )
    
    elif lex == True:
        
        return (
                hawkish_ECB_quotes_news_lex, nomon_ECB_quotes_news_lex, dovish_ECB_quotes_news_lex,
                hawkish_ECB_non_quotes_news_lex, nomon_ECB_non_quotes_news_lex, dovish_ECB_non_quotes_news_lex,
                positive_ECB_quotes_news_lex, neutral_ECB_quotes_news_lex, negative_ECB_quotes_news_lex,
                positive_ECB_non_quotes_news_lex, neutral_ECB_non_quotes_news_lex, negative_ECB_non_quotes_news_lex
            )

#ECB_quotes_results1 = ECB_quotes(data_mon_ecb_quotes, data_sent_ecb_quotes, data_mon_ecb_non_quotes, data_sent_ecb_non_quotes, data_sentmon_ecb_quotes, data_sentmon_ecb_non_quotes,data, data_count, dates1)

#ECB_quotes_results = ECB_quotes(data_mon_ecb_quotes, data_sent_ecb_quotes, data_mon_ecb_non_quotes, data_sent_ecb_non_quotes, data_sentmon_ecb_quotes, data_sentmon_ecb_non_quotes,data)
#ECB_quotes_results_lex = ECB_quotes(data_mon_ecb_quotes, data_sent_ecb_quotes, data_mon_ecb_non_quotes, data_sent_ecb_non_quotes, data_sentmon_ecb_quotes, data_sentmon_ecb_non_quotes,data, lex = True)

##

ECB_quotes_results[0].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbhawkish_quotes.xlsx')
ECB_quotes_results[1].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbnomon_quotes.xlsx')
ECB_quotes_results[2].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbdovish_quotes.xlsx')

###

ECB_quotes_results[3].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbhawkish_non_quotes.xlsx')
ECB_quotes_results[4].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbnomon_non_quotes.xlsx')
ECB_quotes_results[5].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbdovish_non_quotes.xlsx')

ECB_quotes_results[6].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbgoodhawkish_quotes.xlsx')
ECB_quotes_results[7].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbgoodnomon_quotes.xlsx')
ECB_quotes_results[8].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbgooddovish_quotes.xlsx')

ECB_quotes_results[9].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbneutralhawkish_quotes.xlsx')
ECB_quotes_results[10].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbneutralnomon_quotes.xlsx')
ECB_quotes_results[11].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbneutraldovish_quotes.xlsx')

ECB_quotes_results[12].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbbadhawkish_quotes.xlsx')
ECB_quotes_results[13].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbbadnomon_quotes.xlsx')
ECB_quotes_results[14].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbbaddovish_quotes.xlsx')

###

ECB_quotes_results[15].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbgoodhawkish_non_quotes.xlsx')
ECB_quotes_results[16].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbgoodnomon_non_quotes.xlsx')
ECB_quotes_results[17].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbgooddovish_non_quotes.xlsx')

ECB_quotes_results[18].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbneutralhawkish_non_quotes.xlsx')
ECB_quotes_results[19].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbneutralnomon_non_quotes.xlsx')
ECB_quotes_results[20].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbneutraldovish_non_quotes.xlsx')

ECB_quotes_results[21].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbbadhawkish_non_quotes.xlsx')
ECB_quotes_results[22].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbbadnomon_non_quotes.xlsx')
ECB_quotes_results[23].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbbaddovish_non_quotes.xlsx')

##

ECB_quotes_results[24].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbpositive_quotes.xlsx')
ECB_quotes_results[25].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbneutral_quotes.xlsx')
ECB_quotes_results[26].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbnegative_quotes.xlsx')

ECB_quotes_results[27].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbpositive_non_quotes.xlsx')
ECB_quotes_results[28].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbneutral_non_quotes.xlsx')
ECB_quotes_results[29].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbnegative_non_quotes.xlsx')

ECB_quotes_results[30].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecb_quotes_number.xlsx')
ECB_quotes_results[31].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecb_non_quotes_number.xlsx')

###############################################################################

#ECB_quotes_results_og = ECB_quotes(data_mon_ecb_quotes, data_sent_ecb_quotes, data_mon_ecb_non_quotes, data_sent_ecb_non_quotes, data_sentmon_ecb_quotes, data_sentmon_ecb_non_quotes,data, og = True)

###############################################################################

ECB_quotes_results_og[0].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbhawkish_quotes_og.xlsx')
ECB_quotes_results_og[1].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbnomon_quotes_og.xlsx')
ECB_quotes_results_og[2].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbdovish_quotes_og.xlsx')

###

ECB_quotes_results_og[3].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbhawkish_non_quotes_og.xlsx')
ECB_quotes_results_og[4].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbnomon_non_quotes_og.xlsx')
ECB_quotes_results_og[5].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbdovish_non_quotes_og.xlsx')

ECB_quotes_results_og[6].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbgoodhawkish_quotes_og.xlsx')
ECB_quotes_results_og[7].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbgoodnomon_quotes_og.xlsx')
ECB_quotes_results_og[8].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbgooddovish_quotes_og.xlsx')

ECB_quotes_results_og[9].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbneutralhawkish_quotes_og.xlsx')
ECB_quotes_results_og[10].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbneutralnomon_quotes_og.xlsx')
ECB_quotes_results_og[11].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbneutraldovish_quotes_og.xlsx')

ECB_quotes_results_og[12].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbbadhawkish_quotes_og.xlsx')
ECB_quotes_results_og[13].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbbadnomon_quotes_og.xlsx')
ECB_quotes_results_og[14].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbbaddovish_quotes_og.xlsx')

###

ECB_quotes_results_og[15].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbgoodhawkish_non_quotes_og.xlsx')
ECB_quotes_results_og[16].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbgoodnomon_non_quotes_og.xlsx')
ECB_quotes_results_og[17].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbgooddovish_non_quotes_og.xlsx')

ECB_quotes_results_og[18].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbneutralhawkish_non_quotes_og.xlsx')
ECB_quotes_results_og[19].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbneutralnomon_non_quotes_og.xlsx')
ECB_quotes_results_og[20].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbneutraldovish_non_quotes_og.xlsx')

ECB_quotes_results_og[21].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbbadhawkish_non_quotes_og.xlsx')
ECB_quotes_results_og[22].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbbadnomon_non_quotes_og.xlsx')
ECB_quotes_results_og[23].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbbaddovish_non_quotes_og.xlsx')

###

ECB_quotes_results_og[24].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbpositive_quotes_og.xlsx')
ECB_quotes_results_og[25].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbneutral_quotes_og.xlsx')
ECB_quotes_results_og[26].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbnegative_quotes_og.xlsx')

ECB_quotes_results_og[27].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbpositive_non_quotes_og.xlsx')
ECB_quotes_results_og[28].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbneutral_non_quotes_og.xlsx')
ECB_quotes_results_og[29].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbnegative_non_quotes_og.xlsx')

ECB_quotes_results_og[30].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecb_quotes_number_og.xlsx')
ECB_quotes_results_og[31].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecb_non_quotes_number_og.xlsx')

# ###############################################################################

# ECB_quotes_results_lex[0].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbhawkish_quotes_lex.xlsx')
# ECB_quotes_results_lex[1].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbnomon_quotes_lex.xlsx')
# ECB_quotes_results_lex[2].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbdovish_quotes_lex.xlsx')

# ECB_quotes_results_lex[3].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbhawkish_non_quotes_lex.xlsx')
# ECB_quotes_results_lex[4].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbnomon_non_quotes_lex.xlsx')
# ECB_quotes_results_lex[5].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbdovish_non_quotes_lex.xlsx')

# ###

# ECB_quotes_results_lex[6].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbpositive_quotes_lex.xlsx')
# ECB_quotes_results_lex[7].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbneutral_quotes_lex.xlsx')
# ECB_quotes_results_lex[8].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbnegative_quotes_lex.xlsx')

# ECB_quotes_results_lex[9].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbpositive_non_quotes_lex.xlsx')
# ECB_quotes_results_lex[10].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbneutral_non_quotes_lex.xlsx')
# ECB_quotes_results_lex[11].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbnegative_non_quotes_lex.xlsx')

###############################################################################

def News(data_inf, data_mon, data_sent, data, dates = None, og = False, lex = False):
    
    def prepare_data(data, freq = 'M', lex = False, og = False):
        
       data = data.copy()  
        
       data.rename_axis('index', inplace=True)
       data['t_date'] = pd.to_datetime(data['t_date'])
       
       if lex == False and og == False:
       
           data_count = data.groupby('t_date').size()
           data_count.rename_axis('index', inplace=True)
           
           data_count = data_count.resample('M').ffill()
           
           data['t_date'] = (data['t_date'] + pd.offsets.MonthEnd(0))
           
           start_date = data_count.index.min()
           end_date = data_count.index.max()
           
           start_date = pd.to_datetime('1999-12-31')
           end_date = pd.to_datetime('2023-12-31')
           
           all_months = pd.date_range(start=start_date, end=end_date, freq=freq)
           data_count = data_count.reindex(all_months, fill_value=0)
           
           return(data_count)
           
       elif lex == True:
           
           def process_data(data, value_column, freq, start_date='1999-12-31', end_date='2018-12-31'):
 
            data['t_date'] = pd.to_datetime(data['t_date'])
        
            data_avg_index = data.groupby('t_date')[value_column].mean().reset_index()
            data_avg_index['t_date'] = data_avg_index['t_date'] + pd.offsets.MonthEnd(0)

            start_date = pd.to_datetime(start_date)
            end_date = pd.to_datetime(end_date)
        
            all_months = pd.date_range(start=start_date, end=end_date, freq=freq)
        
            data_count = data_avg_index.set_index('t_date').reindex(all_months, fill_value=0).reset_index()
            data_count.rename(columns={'index': 't_date'}, inplace=True)
        
            return(data_count)
        
           pos_share = process_data(data, 'pos share', 'M')
           neu_share = process_data(data, 'neu share', 'M')
           neg_share = process_data(data, 'neg share', 'M')
            
           combined_data = pos_share.merge(neu_share, on='t_date', suffixes=('_pos', '_neu'))
           combined_data = combined_data.merge(neg_share, on='t_date')
           combined_data.rename(columns={'pos share': 'pos_share', 'neu share': 'neu_share', 'neg share': 'neg_share'}, inplace=True)
            
           return(combined_data)
                   
       elif og == True:
           
           data_count = data.groupby('t_date').size()
           data_count.rename_axis('index', inplace=True)
       
           return(data_count)  
    
    if dates is not None:
        
        data = data[data['date'].isin(dates)]
        data['t_date'] = data['date']
        data_count = prepare_data(data)
        
        data_inf = data_inf[data_inf['date'].isin(dates)]
        data_mon = data_mon[data_mon['date'].isin(dates)]
        data_sent = data_sent[data_sent['date'].isin(dates)]
        
        data_inf['t_date'] = data_inf['date']
        data_mon['t_date'] = data_mon['date']
        data_sent['t_date'] = data_sent['date']
        
    else:

        data_count = prepare_data(data, og = og)
       
    if lex == False:

        rising = prepare_data(data_inf[data_inf['Label'] == 2], lex = lex, og = og)/data_count
        notrend = prepare_data(data_inf[data_inf['Label'] == 1], lex = lex, og = og)/data_count
        falling = prepare_data(data_inf[data_inf['Label'] == 0], lex = lex, og = og)/data_count
        
        ###
        
        hawkish = (prepare_data(data_mon[data_mon['Label'] == 2], lex = lex, og = og)/data_count).fillna(0)
        nomon = (prepare_data(data_mon[data_mon['Label'] == 1], lex = lex, og = og)/data_count).fillna(0)
        dovish = (prepare_data(data_mon[data_mon['Label'] == 0], lex = lex, og = og)/data_count).fillna(0)
        
        ###
        
        good = prepare_data(data_sent[data_sent['Label'] == 2], lex = lex, og = og)/data_count
        neutral = prepare_data(data_sent[data_sent['Label'] == 1], lex = lex, og = og)/data_count
        bad = prepare_data(data_sent[data_sent['Label'] == 0], lex = lex, og = og)/data_count
        
        ###
        
        goodhawkish = (prepare_data(data_mon[(data_mon['Label'] == 2) & (data_sent['Label'] == 2)], lex = lex, og = og)/data_count).fillna(0)
        neutralhawkish = (prepare_data(data_inf[(data_mon['Label'] == 2) & (data_sent['Label'] == 1)], lex = lex, og = og)/data_count).fillna(0)
        badhawkish = (prepare_data(data_inf[(data_mon['Label'] == 2) & (data_sent['Label'] == 0)], lex = lex, og = og)/data_count).fillna(0)
        
        ###
        
        goodnomon = (prepare_data(data_mon[(data_mon['Label'] == 1) & (data_sent['Label'] == 2)], lex = lex, og = og)/data_count).fillna(0)
        neutralnomon = (prepare_data(data_inf[(data_mon['Label'] == 1) & (data_sent['Label'] == 1)], lex = lex, og = og)/data_count).fillna(0)
        badnomon = (prepare_data(data_inf[(data_mon['Label'] == 1) & (data_sent['Label'] == 0)], lex = lex, og = og)/data_count).fillna(0)
        
        ###
        
        gooddovish = (prepare_data(data_mon[(data_mon['Label'] == 0) & (data_sent['Label'] == 2)], lex = lex, og = og)/data_count).fillna(0)
        neutraldovish = (prepare_data(data_inf[(data_mon['Label'] == 0) & (data_sent['Label'] == 1)], lex = lex, og = og)/data_count).fillna(0)
        baddovish = (prepare_data(data_inf[(data_mon['Label'] == 0) & (data_sent['Label'] == 0)], lex = lex, og = og)/data_count).fillna(0)
        
        ###
        
        goodrising = (prepare_data(data_inf[(data_inf['Label'] == 2) & (data_sent['Label'] == 2)], lex = lex, og = og)/data_count).fillna(0)
        neutralrising = (prepare_data(data_inf[(data_inf['Label'] == 2) & (data_sent['Label'] == 1)], lex = lex, og = og)/data_count).fillna(0)
        badrising = (prepare_data(data_inf[(data_inf['Label'] == 2) & (data_sent['Label'] == 0)], lex = lex, og = og)/data_count).fillna(0)
        
        ###
        
        goodnotrend = (prepare_data(data_inf[(data_inf['Label'] == 1) & (data_sent['Label'] == 2)], lex = lex, og = og)/data_count).fillna(0)
        neutralnotrend = (prepare_data(data_inf[(data_inf['Label'] == 1) & (data_sent['Label'] == 1)], lex = lex, og = og)/data_count).fillna(0)
        badnotrend = (prepare_data(data_inf[(data_inf['Label'] == 1) & (data_sent['Label'] == 0)], lex = lex, og = og)/data_count).fillna(0)

        ###
        
        goodfalling = (prepare_data(data_inf[(data_inf['Label'] == 0) & (data_sent['Label'] == 2)], lex = lex, og = og)/data_count).fillna(0)
        neutralfalling = (prepare_data(data_inf[(data_inf['Label'] == 0) & (data_sent['Label'] == 1)], lex = lex, og = og)/data_count).fillna(0)
        badfalling = (prepare_data(data_inf[(data_inf['Label'] == 0) & (data_sent['Label'] == 0)], lex = lex, og = og)/data_count).fillna(0)
        
    elif lex == True:
        
        pos_inf_index = pd.DataFrame((prepare_data(data_inf_all, lex = True)['pos_share']).fillna(0))
        neu_inf_index = pd.DataFrame((prepare_data(data_inf_all, lex = True)['neu_share']).fillna(0))
        neg_inf_index = pd.DataFrame((prepare_data(data_inf_all, lex = True)['neg_share']).fillna(0))
        
        pos_inf_index.index = data_count.index        
        neu_inf_index.index = data_count.index
        neg_inf_index.index = data_count.index
        
        #sent_index = (prepare_data(data_sent, lex = True)['index']).fillna(0)
    
    news_data_inf_number = prepare_data(data_inf)/data_count
    news_data_mon_number = prepare_data(data_mon)/data_count

    if lex == False:

        return (
                rising, notrend, falling,
                hawkish, nomon, dovish,
                good, neutral, bad,
                goodhawkish, neutralhawkish, badhawkish,
                goodnomon, neutralnomon, badnomon,
                gooddovish, neutraldovish, baddovish,
                goodrising, neutralrising, badrising,
                goodnotrend, neutralnotrend, badnotrend,
                goodfalling, neutralfalling, badfalling,
                news_data_inf_number, news_data_mon_number
            )
    
    elif lex == True:
        
        return (
                pos_inf_index, neu_inf_index, neg_inf_index,
                news_data_inf_number, news_data_mon_number
            )
        
# News_results1 = News(data_inf, data_mon, data_sent, data, dates1)
#News_results = News(data_inf, data_mon, data_sent, data)
#News_results_lex = News(data_inf, data_mon, data_sent, data, lex = True)

###############################################################################

News_results[0].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_rising.xlsx')
News_results[1].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_notrend.xlsx')
News_results[2].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_falling.xlsx')

News_results[3].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_hawkish.xlsx')
News_results[4].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_nomon.xlsx')
News_results[5].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_dovish.xlsx')

News_results[6].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_good.xlsx')
News_results[7].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_neutral.xlsx')
News_results[8].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_bad.xlsx')

News_results[9].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_goodhawkish.xlsx')
News_results[10].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_neutralhawkish.xlsx')
News_results[11].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_badhawkish.xlsx')

News_results[12].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_goodnomon.xlsx')
News_results[13].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_neutralnomon.xlsx')
News_results[14].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_badnomon.xlsx')

News_results[15].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_gooddovish.xlsx')
News_results[16].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_neutraldovish.xlsx')
News_results[17].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_baddovish.xlsx')

News_results[18].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_goodrising.xlsx')
News_results[19].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_neutralrising.xlsx')
News_results[20].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_badrising.xlsx')

News_results[21].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_goodnotrend.xlsx')
News_results[22].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_neutralnotrend.xlsx')
News_results[23].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_badnotrend.xlsx')

News_results[24].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_goodfalling.xlsx')
News_results[25].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_neutralfalling.xlsx')
News_results[26].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_badfalling.xlsx')

News_results[27].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_inf_number.xlsx')
News_results[28].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_mon_number.xlsx')

###############################################################################
News_results_og = News(data_inf, data_mon, data_sent, data, og = True)
###############################################################################

News_results_og[0].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_rising_og.xlsx')
News_results_og[1].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_notrend_og.xlsx')
News_results_og[2].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_falling_og.xlsx')

News_results_og[3].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_hawkish_og.xlsx')
News_results_og[4].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_nomon_og.xlsx')
News_results_og[5].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_dovish_og.xlsx')

News_results_og[6].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_good_og.xlsx')
News_results_og[7].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_neutral_og.xlsx')
News_results_og[8].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_bad_og.xlsx')

News_results_og[9].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_goodhawkish_og.xlsx')
News_results_og[10].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_neutralhawkish_og.xlsx')
News_results_og[11].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_badhawkish_og.xlsx')

News_results_og[12].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_goodnomon_og.xlsx')
News_results_og[13].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_neutralnomon_og.xlsx')
News_results_og[14].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_badnomon_og.xlsx')

News_results_og[15].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_gooddovish_og.xlsx')
News_results_og[16].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_neutraldovish_og.xlsx')
News_results_og[17].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_baddovish_og.xlsx')

News_results_og[18].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_goodrising_og.xlsx')
News_results_og[19].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_neutralrising_og.xlsx')
News_results_og[20].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_badrising_og.xlsx')

News_results_og[21].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_goodnotrend_og.xlsx')
News_results_og[22].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_neutralnotrend_og.xlsx')
News_results_og[23].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_badnotrend_og.xlsx')

News_results_og[24].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_goodfalling_og.xlsx')
News_results_og[25].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_neutralfalling_og.xlsx')
News_results_og[26].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_badfalling_og.xlsx')

News_results_og[27].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_inf_number_og.xlsx')
News_results_og[28].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_mon_number_og.xlsx')

# ###############################################################################

# News_results_lex[0].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_rising_lex.xlsx')
# News_results_lex[1].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_notrend_lex.xlsx')
# News_results_lex[2].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_falling_lex.xlsx')

###############################################################################
# ECB Press Conferences
###############################################################################

# def prepare_data_ecb(data, freq='M'):
#    
#     data['t_date'] = pd.to_datetime(data['t_date'])
#     data['year_month'] = data['t_date'].dt.to_period(freq)
#     data_count = data.groupby('year_month').size()
#     date_range = pd.period_range(data['year_month'].min(), data['year_month'].max(), freq=freq)
#     data_count = data_count.reindex(date_range, fill_value=0)
#     data_count.index = data_count.index.to_timestamp(how='end').normalize()
#    
#     return data_count

def prepare_data_og(data):

    data['date'] = pd.to_datetime(data['date'])
    data_count = data.groupby('t_date').size()

    return data_count

###############################################################################

def assign_period(date, agg_dates):
    for idx, agg_date in enumerate(agg_dates):
        if date <= agg_date:
            return idx
    return len(agg_dates)

#data_ECB_sents_inf = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\ECB\press_sents_full_index_labeled_inf.xlsx')
data_ECB_sents_inf = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\ECB\press_sents_full_index_labeled_inf_2.xlsx')
data_ECB_sents_inf['date'] = pd.to_datetime(data_ECB_sents_inf['date'])

data_ECB_sents_inf = data_ECB_sents_inf.sort_values(by='date')

data_surv_dates = sorted(list(set(data_ECB_sents_inf['date'])))

agg_period = data_ECB_sents_inf['date'].progress_apply(lambda x: assign_period(x, data_surv_dates))
data_ECB_sents_inf['Period'] = agg_period 

date_mapping = {i: date for i, date in enumerate(data_surv_dates)}
data_ECB_sents_inf['t_date'] = data_ECB_sents_inf['Period'].map(date_mapping)

# number_inf_up = prepare_data_ecb(data_ECB_sents_inf[data_ECB_sents_inf['Label'] == 2]).resample('M').ffill()
# number_inf_same = prepare_data_ecb(data_ECB_sents_inf[data_ECB_sents_inf['Label'] == 1]).resample('M').ffill()
# number_inf_down = prepare_data_ecb(data_ECB_sents_inf[data_ECB_sents_inf['Label'] == 0]).resample('M').ffill()

number_inf_up_og = prepare_data_og(data_ECB_sents_inf[data_ECB_sents_inf['Label'] == 2])
number_inf_same_og = prepare_data_og(data_ECB_sents_inf[data_ECB_sents_inf['Label'] == 1])
number_inf_down_og = prepare_data_og(data_ECB_sents_inf[data_ECB_sents_inf['Label'] == 0])

###

data_count_ECB_og = prepare_data_og(data_ECB_sents_inf)

inf_up_og = (number_inf_up_og/data_count_ECB_og).fillna(0)
inf_same_og = (number_inf_same_og/data_count_ECB_og).fillna(0)
inf_down_og = (number_inf_down_og/data_count_ECB_og).fillna(0)

from statsmodels.tsa.stattools import adfuller

result = adfuller(inf_down_og, maxlag=1, regression='c')

# Print the results
print("ADF Statistic:", result[0])
print("p-value:", result[1])
print("Critical Values:", result[4])

###############################################################################

data_ECB_sents_monetary = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\ECB\press_sents_full_index_labeled_mon.xlsx')
data_ECB_sents_monetary['date'] = pd.to_datetime(data_ECB_sents_monetary['date'])

data_ECB_sents_monetary = data_ECB_sents_monetary.sort_values(by='date')

data_surv_dates = sorted(list(set(data_ECB_sents_monetary['date'])))

agg_period = data_ECB_sents_monetary['date'].progress_apply(lambda x: assign_period(x, data_surv_dates))
data_ECB_sents_monetary['Period'] = agg_period 

date_mapping = {i: date for i, date in enumerate(data_surv_dates)}
data_ECB_sents_monetary['t_date'] = data_ECB_sents_monetary['Period'].map(date_mapping)

number_mon_haw_og = prepare_data_og(data_ECB_sents_monetary[data_ECB_sents_monetary['Label'] == 0])
number_mon_stab_og = prepare_data_og(data_ECB_sents_monetary[data_ECB_sents_monetary['Label'] == 1])
number_mon_dov_og = prepare_data_og(data_ECB_sents_monetary[data_ECB_sents_monetary['Label'] == 2])

###

data_count_ECB_og = prepare_data_og(data_ECB_sents_monetary)

mon_haw_og = (number_mon_haw_og/data_count_ECB_og).fillna(0)
mon_stab_og = (number_mon_stab_og/data_count_ECB_og).fillna(0)
mon_dov_og = (number_mon_dov_og/data_count_ECB_og).fillna(0)

###############################################################################

data_ECB_sents_outlook = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\ECB\press_sents_full_index_labeled_out.xlsx')
data_ECB_sents_outlook['date'] = pd.to_datetime(data_ECB_sents_outlook['date'])

data_ECB_sents_outlook = data_ECB_sents_outlook.sort_values(by='date')

data_surv_dates = sorted(list(set(data_ECB_sents_outlook['date'])))

agg_period = data_ECB_sents_outlook['date'].progress_apply(lambda x: assign_period(x, data_surv_dates))
data_ECB_sents_outlook['Period'] = agg_period 

date_mapping = {i: date for i, date in enumerate(data_surv_dates)}
data_ECB_sents_outlook['t_date'] = data_ECB_sents_outlook['Period'].map(date_mapping)

number_out_up_og = prepare_data_og(data_ECB_sents_outlook[data_ECB_sents_outlook['Label'] == 2])
number_out_same_og = prepare_data_og(data_ECB_sents_outlook[data_ECB_sents_outlook['Label'] == 1])
number_out_down_og = prepare_data_og(data_ECB_sents_outlook[data_ECB_sents_outlook['Label'] == 0])

###

data_count_ECB_og = prepare_data_og(data_ECB_sents_monetary)

out_up_og = (number_out_up_og/data_count_ECB_og).fillna(0)
out_same_og = (number_out_same_og/data_count_ECB_og).fillna(0)
out_down_og = (number_out_down_og/data_count_ECB_og).fillna(0)


###############################################################################

# inf_up.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\ECB_inf_up.xlsx')
# inf_same.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\ECB_inf_same.xlsx')
# inf_down.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\ECB_inf_down.xlsx')
#
# mon_dov.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\ECB_mon_dov.xlsx')
# mon_not.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\ECB_mon_not.xlsx')
# mon_haw.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\ECB_mon_haw.xlsx')
#
# out_up.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\ECB_out_up.xlsx')
# out_same.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\ECB_out_same.xlsx')
# out_down.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\ECB_out_down.xlsx')

###

inf_up_og.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\ECB_inf_up_og.xlsx')
inf_same_og.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\ECB_inf_same_og.xlsx')
inf_down_og.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\ECB_inf_down_og.xlsx')

mon_dov_og.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\ECB_mon_dov_og.xlsx')
mon_stab_og.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\ECB_mon_not_og.xlsx')
mon_haw_og.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\ECB_mon_haw_og.xlsx')

out_up_og.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\ECB_out_up_og.xlsx')
out_same_og.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\ECB_out_same_og.xlsx')
out_down_og.to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\ECB_out_down_og.xlsx')