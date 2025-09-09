# -*- coding: utf-8 -*-
"""
Created on Mon Aug 11 21:18:46 2025

@author: Jasper Bär
"""

import pandas as pd
import numpy as np

def assign_periods(df: pd.DataFrame, agg_dates: list, window_days: int) -> pd.DataFrame:
    """Assigns each sentence to a time period based on a list of start dates."""
    agg_dates_np = np.array(sorted(agg_dates), dtype='datetime64[ns]')
    df['date'] = pd.to_datetime(df['date'])
    
    # Find the index of the last agg_date that is <= the sentence date
    periods = np.searchsorted(agg_dates_np, df['date'].values, side='right') - 1
    periods = np.clip(periods, 0, len(agg_dates_np) - 1)
    
    # Check if the date falls within the window (e.g., agg_date + window_days)
    window = pd.Timedelta(days=window_days)
    in_window_mask = (df['date'] >= agg_dates_np[periods]) & (df['date'] <= agg_dates_np[periods] + window)
    
    df['Period'] = periods
    df = df[in_window_mask].copy()
    
    date_mapping = {i: date for i, date in enumerate(agg_dates_np)}
    df['t_date'] = df['Period'].map(date_mapping)
    return df

def calculate_all_indices(data_dict: dict, reference_dates: list, window_days: int) -> dict:
    """
    Takes classified data and calculates all time-series indices.
    This is the new home for the logic in your 'News' and 'ECB_quotes' functions.
    """
    print("Assigning sentences to time periods...")
    for key, df in data_dict.items():
        data_dict[key] = assign_periods(df, reference_dates, window_days)

    print("Calculating indices...")

    df_mon = data_dict['dpa_monetary']
    
    # Get total counts of all monetary sentences per period
    total_mon_counts = df_mon.groupby('t_date').size()
    
    # Group by period and label, then count
    mon_label_counts = df_mon.groupby(['t_date', 'Label']).size().unstack(fill_value=0)
    
    # --- Create the indices ---
    indices = {}
    # Label mapping: 2=hawkish, 1=neutral, 0=dovish
    if 2 in mon_label_counts.columns:
        indices['news_index_hawkish'] = (mon_label_counts[2] / total_mon_counts).fillna(0)
    if 1 in mon_label_counts.columns:
        indices['news_index_nomon'] = (mon_label_counts[1] / total_mon_counts).fillna(0)
    if 0 in mon_label_counts.columns:
        indices['news_index_dovish'] = (mon_label_counts[0] / total_mon_counts).fillna(0)

    # ... you would continue this process for all 30+ of your complex cross-topic indices ...
    
    # Reindex all final series to a common monthly index to ensure they align
    start_date = min(reference_dates)
    end_date = max(reference_dates)
    all_months = pd.date_range(start=start_date, end=end_date, freq='M')
    
    for key, series in indices.items():
        series.index = pd.to_datetime(series.index)
        series = series.resample('M').sum() # or .mean()
        indices[key] = series.reindex(all_months, fill_value=0)
    
    return indices