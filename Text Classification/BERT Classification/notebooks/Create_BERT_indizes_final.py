# -*- coding: utf-8 -*-
"""
Created on Mon Aug 22 21:19:32 2022

"""

import pandas as pd
import os
import numpy as np

from tqdm import tqdm
tqdm.pandas()

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

data['date'] = pd.to_datetime(data['date'], errors='coerce')
data_inf_all['date'] = pd.to_datetime(data_inf_all['date'], errors='coerce')
data_sent_all['date'] = pd.to_datetime(data_sent_all['date'], errors='coerce')
data_mon_all['date'] = pd.to_datetime(data_mon_all['date'], errors='coerce')
data_sentmon_all['date'] = pd.to_datetime(data_sentmon_all['date'], errors='coerce')

cutoff_start = pd.to_datetime('2001-11-15')
cutoff_end = pd.to_datetime('2023-12-15')
#cutoff_end = pd.to_datetime('2023-12-31')

data            = data.loc[data['date'].between(cutoff_start, cutoff_end, inclusive='both')].copy()
data_inf_all    = data_inf_all.loc[data_inf_all['date'].between(cutoff_start, cutoff_end, inclusive='both')].copy()
data_sent_all   = data_sent_all.loc[data_sent_all['date'].between(cutoff_start, cutoff_end, inclusive='both')].copy()
data_mon_all    = data_mon_all.loc[data_mon_all['date'].between(cutoff_start, cutoff_end, inclusive='both')].copy()
data_sentmon_all= data_sentmon_all.loc[data_sentmon_all['date'].between(cutoff_start, cutoff_end, inclusive='both')].copy()

data_inf_all = data_inf_all[~data_inf_all['text'].str.contains('Referenzkurs', case=False, na=False)]
data_sent_all = data_sent_all[~data_sent_all['text'].str.contains('Referenzkurs', case=False, na=False)]
data_mon_all = data_mon_all[~data_mon_all['text'].str.contains('Referenzkurs', case=False, na=False)]
data_sentmon_all = data_sentmon_all[~data_sentmon_all['text'].str.contains('Referenzkurs', case=False, na=False)]

data = data[~data['texts'].str.contains('Referenzkurs', case=False, na=False)]

###############################################################################

version = "survey"#"press_conference"    # or "survey"

def compute_periods(df, version):
    out = df.copy()  

    # if version == "press_conference":
    #     press_sents = pd.read_excel(r'D:\Studium\PhD\Github\Single-Author\Data\ECB_sents_prepared.xlsx')
    #     press_sents['date'] = pd.to_datetime(press_sents['date'])
        
    #     agg_dates = np.sort(press_sents['date'].dropna().dt.normalize().unique())
    #     date_mapping = {i: dt for i, dt in enumerate(agg_dates)}
        
    #     d = pd.to_datetime(out['date'], errors='coerce').dt.normalize().to_numpy()
    #     a = pd.to_datetime(agg_dates).to_numpy()
        
    #     next_idx = np.searchsorted(a, d, side='left')
    #     next_idx = np.clip(next_idx, 0, len(a) - 1)
    #     delta_days = ((a[next_idx] - d) / np.timedelta64(1, 'D')).astype(float)
    #     inwin = np.isfinite(delta_days) & (delta_days >= 0) & (delta_days <= 14)
        
    #     out = out[inwin].copy()
    #     out['Period'] = next_idx[inwin]
    #     out['t_date'] = out['Period'].map(date_mapping)
        
    if version == "press_conference":
        press_sents = pd.read_excel(r'D:\Studium\PhD\Github\Single-Author\Data\ECB_sents_prepared.xlsx')
        press_sents['date'] = pd.to_datetime(press_sents['date'])
        agg_dates = np.sort(press_sents['date'].dropna().dt.normalize().unique())
        date_mapping = {i: dt for i, dt in enumerate(agg_dates)}
        d = pd.to_datetime(out['date'], errors='coerce').dt.normalize().to_numpy()
        a = pd.to_datetime(agg_dates).to_numpy()
        prev_idx = np.searchsorted(a, d, side='right') - 1
        prev_idx = np.clip(prev_idx, 0, len(a) - 1)
        delta_days = ((d - a[prev_idx]) / np.timedelta64(1, 'D')).astype(float)
        inwin = np.isfinite(delta_days) & (delta_days >= 0) & (delta_days <= 14)
        out = out[inwin].copy()
        out['Period'] = prev_idx[inwin]
        out['t_date'] = out['Period'].map(date_mapping)

    elif version == "survey":
        data_surv_dates = pd.date_range(start='2001-11-01', periods=266, freq='MS') + pd.Timedelta(days=14)
        agg_dates = np.sort(data_surv_dates)
        date_mapping = {i: date for i, date in enumerate(agg_dates)}  

        d = pd.to_datetime(out['date'], errors='coerce').dt.normalize().to_numpy()
        a = pd.to_datetime(agg_dates).normalize().to_numpy() 

        idx = np.searchsorted(a, d, side='left')
        idx = np.clip(idx, 0, len(a) - 1)
        
        out['Period'] = idx
        out['InWindow'] = True
        out.drop(columns=['InWindow'], inplace=True)

    else:
        raise ValueError("version must be 'survey' or 'press_conference'")

    out['t_date'] = out['Period'].map({i: pd.Timestamp(dt) for i, dt in enumerate(agg_dates)})
    return out


data_inf_all     = compute_periods(data_inf_all, version)
data_sent_all    = compute_periods(data_sent_all, version)
data_mon_all     = compute_periods(data_mon_all, version)
data_sentmon_all = compute_periods(data_sentmon_all, version)
data             = compute_periods(data, version)

###############################################################################

# data_inf_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_inf_period_full_month_survey_ECB_5.xlsx')
# data_sent_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_sent_period_full_month_survey_ECB_5.xlsx')
# data_mon_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_mon_period_full_month_survey_ECB_5.xlsx')
# data_sentmon_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_sentmon_period_full_month_survey_ECB_5.xlsx')

# data = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\dpa\data_period_full_month_survey_ECB_5.csv', encoding = 'utf-8', index_col = 0,  keep_default_na=False,
#                     dtype = {'rubrics': 'str', 
#                             'source': 'str',
#                             'keywords': 'str',
#                             'title': 'str',
#                             'city': 'str',
#                             'genre': 'str',
#                             'texts': 'str'})

###############################################################################

data_inf_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_inf_period_full_month_survey_15_new.xlsx')
data_sent_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_sent_period_full_month_survey_15_new.xlsx')
data_mon_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_mon_period_full_month_survey_15_new.xlsx')
data_sentmon_all = pd.read_excel(r'D:\Studium\PhD\Single Author\Data\dpa\data_sentmon_period_full_month_survey_15_new.xlsx')

data = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\dpa\data_period_full_month_survey_15_new.csv', encoding = 'utf-8', index_col = 0,  keep_default_na=False,
                    dtype = {'rubrics': 'str', 
                            'source': 'str',
                            'keywords': 'str',
                            'title': 'str',
                            'city': 'str',
                            'genre': 'str',
                            'texts': 'str'})

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

PATH = r'D:\Studium\PhD\Github\Single-Author\Data\Regression'

def ECB_quotes(data_mon_ecb_quotes, data_sent_ecb_quotes, data_mon_ecb_non_quotes, data_sent_ecb_non_quotes, data_sentmon_ecb_quotes, data_sentmon_ecb_non_quotes, data, data_count = None, dates = None, og = False):

    def prepare_data(data, freq = 'M', og = False):
       
       data = data.copy()  
         
       data.rename_axis('index', inplace=True)
       data['t_date'] = pd.to_datetime(data['t_date'])
       
       if og == False:
         
       
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
        
        data_count = prepare_data(data, og = og)
      
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

    hawkish_ECB_quotes_news = (prepare_data(data_mon_ecb_quotes[data_mon_ecb_quotes['Label'] == 2], og = og)/data_count).fillna(0)
    nomon_ECB_quotes_news = (prepare_data(data_mon_ecb_quotes[data_mon_ecb_quotes['Label'] == 1], og = og)/data_count).fillna(0)
    dovish_ECB_quotes_news = (prepare_data(data_mon_ecb_quotes[data_mon_ecb_quotes['Label'] == 0], og = og)/data_count).fillna(0)
    
    ###
    
    hawkish_ECB_non_quotes_news = (prepare_data(data_mon_ecb_non_quotes[data_mon_ecb_non_quotes['Label'] == 2], og = og)/data_count).fillna(0)
    nomon_ECB_non_quotes_news = (prepare_data(data_mon_ecb_non_quotes[data_mon_ecb_non_quotes['Label'] == 1], og = og)/data_count).fillna(0)
    dovish_ECB_non_quotes_news = (prepare_data(data_mon_ecb_non_quotes[data_mon_ecb_non_quotes['Label'] == 0], og = og)/data_count).fillna(0)
    
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
            
    return (
            hawkish_ECB_quotes_news, nomon_ECB_quotes_news, dovish_ECB_quotes_news,
            hawkish_ECB_non_quotes_news, nomon_ECB_non_quotes_news, dovish_ECB_non_quotes_news,
            positive_ECB_quotes_news, neutral_ECB_quotes_news, negative_ECB_quotes_news,
            positive_ECB_non_quotes_news, neutral_ECB_non_quotes_news, negative_ECB_non_quotes_news, 
            ECB_quotes_count, ECB_non_quotes_count
        )

ECB_quotes_results = ECB_quotes(data_mon_ecb_quotes, data_sent_ecb_quotes, data_mon_ecb_non_quotes, data_sent_ecb_non_quotes, data_sentmon_ecb_quotes, data_sentmon_ecb_non_quotes,data)

##

ECB_quotes_results[0].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_ecbhawkish_quotes.xlsx')
ECB_quotes_results[1].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_ecbnomon_quotes.xlsx')
ECB_quotes_results[2].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_ecbdovish_quotes.xlsx')

ECB_quotes_results[3].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_ecbhawkish_non_quotes.xlsx')
ECB_quotes_results[4].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_ecbnomon_non_quotes.xlsx')
ECB_quotes_results[5].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_ecbdovish_non_quotes.xlsx')

ECB_quotes_results[6].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_ecbpositive_quotes.xlsx')
ECB_quotes_results[7].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_ecbneutral_quotes.xlsx')
ECB_quotes_results[8].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_ecbnegative_quotes.xlsx')

ECB_quotes_results[9].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_ecbpositive_non_quotes.xlsx')
ECB_quotes_results[10].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_ecbneutral_non_quotes.xlsx')
ECB_quotes_results[11].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_ecbnegative_non_quotes.xlsx')

ECB_quotes_results[12].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_ecb_quotes_number.xlsx')
ECB_quotes_results[13].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_ecb_non_quotes_number.xlsx')

###############################################################################

# ECB_quotes_results_og = ECB_quotes(data_mon_ecb_quotes, data_sent_ecb_quotes, data_mon_ecb_non_quotes, data_sent_ecb_non_quotes, data_sentmon_ecb_quotes, data_sentmon_ecb_non_quotes,data, og = True)

# ##############################################################################

# ECB_quotes_results_og[0].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbhawkish_quotes_og.xlsx')
# ECB_quotes_results_og[1].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbnomon_quotes_og.xlsx')
# ECB_quotes_results_og[2].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbdovish_quotes_og.xlsx')

# ECB_quotes_results_og[3].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbhawkish_non_quotes_og.xlsx')
# ECB_quotes_results_og[4].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbnomon_non_quotes_og.xlsx')
# ECB_quotes_results_og[5].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbdovish_non_quotes_og.xlsx')

# ECB_quotes_results_og[6].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbpositive_quotes_og.xlsx')
# ECB_quotes_results_og[7].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbneutral_quotes_og.xlsx')
# ECB_quotes_results_og[8].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbnegative_quotes_og.xlsx')

# ECB_quotes_results_og[9].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbpositive_non_quotes_og.xlsx')
# ECB_quotes_results_og[10].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbneutral_non_quotes_og.xlsx')
# ECB_quotes_results_og[11].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecbnegative_non_quotes_og.xlsx')

# ECB_quotes_results_og[12].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecb_quotes_number_og.xlsx')
# ECB_quotes_results_og[13].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_ecb_non_quotes_number_og.xlsx')

###############################################################################

def News(data_inf, data_mon, data_sent, data, dates = None, og = False):
    
    def prepare_data(data, freq = 'M', og = False):
        
       data = data.copy()  
        
       data.rename_axis('index', inplace=True)
       data['t_date'] = pd.to_datetime(data['t_date'])
       
       if og == False:
       
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

    rising = prepare_data(data_inf[data_inf['Label'] == 2], og = og)/data_count
    notrend = prepare_data(data_inf[data_inf['Label'] == 1], og = og)/data_count
    falling = prepare_data(data_inf[data_inf['Label'] == 0], og = og)/data_count
    
    ###
    
    hawkish = (prepare_data(data_mon[data_mon['Label'] == 2], og = og)/data_count).fillna(0)
    nomon = (prepare_data(data_mon[data_mon['Label'] == 1], og = og)/data_count).fillna(0)
    dovish = (prepare_data(data_mon[data_mon['Label'] == 0], og = og)/data_count).fillna(0)
    
    ###
    
    good = prepare_data(data_sent[data_sent['Label'] == 2], og = og)/data_count
    neutral = prepare_data(data_sent[data_sent['Label'] == 1], og = og)/data_count
    bad = prepare_data(data_sent[data_sent['Label'] == 0], og = og)/data_count
    
    news_data_inf_number_rel = prepare_data(data_inf)/data_count
    news_data_mon_number_rel = prepare_data(data_mon)/data_count
    
    news_data_inf_number_tot = prepare_data(data_inf)
    news_data_mon_number_tot = prepare_data(data_mon)

    return (
            rising, notrend, falling,
            hawkish, nomon, dovish,
            good, neutral, bad,
            news_data_inf_number_rel, news_data_mon_number_rel,
            news_data_inf_number_tot, news_data_mon_number_tot,
            data_count
        )
    
News_results = News(data_inf_all, data_mon_all, data_sent_all, data)

###############################################################################

News_results[0].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_rising.xlsx')
News_results[1].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_notrend.xlsx')
News_results[2].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_falling.xlsx')

News_results[3].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_hawkish.xlsx')
News_results[4].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_nomon.xlsx')
News_results[5].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_dovish.xlsx')

News_results[6].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_good.xlsx')
News_results[7].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_neutral.xlsx')
News_results[8].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_bad.xlsx')

News_results[9].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_inf_number.xlsx')
News_results[10].to_excel(PATH + '\\' + 'Neu' + '\\' + 'news_index_mon_number.xlsx')

#np.corrcoef(News_results[11][23:] , News_results[13][23:])
#np.corrcoef(News_results[12][23:] , News_results[13][23:])

###############################################################################

# News_results_og = News(data_inf, data_mon, data_sent, data, og = True)

# ###############################################################################

# News_results_og[0].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_rising_og.xlsx')
# News_results_og[1].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_notrend_og.xlsx')
# News_results_og[2].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_falling_og.xlsx')

# News_results_og[3].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_hawkish_og.xlsx')
# News_results_og[4].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_nomon_og.xlsx')
# News_results_og[5].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_dovish_og.xlsx')

# News_results_og[6].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_good_og.xlsx')
# News_results_og[7].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_neutral_og.xlsx')
# News_results_og[8].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_bad_og.xlsx')

# News_results_og[9].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_inf_number_og.xlsx')
# News_results_og[10].to_excel(r'D:\Studium\PhD\Github\Single-Author\Data\Regression\\news_index_mon_number_og.xlsx')