# -*- coding: utf-8 -*-
"""
Created on Mon Aug 11 21:17:41 2025

@author: Jasper Bär
"""

import yaml
import os
import pandas as pd
from src.index_calculator import calculate_all_indices

def load_data(config):
    """Helper function to load data based on the config."""

    base_path = config['base_path']
    inf_paths = config['classified_inputs']['dpa_inflation']
    mon_paths = config['classified_inputs']['dpa_monetary']

    df_inf_old = pd.read_excel(inf_paths['old'].format(base_path=base_path))
    df_inf_new = pd.read_excel(inf_paths['new'].format(base_path=base_path))
    df_inf = pd.concat([df_inf_old, df_inf_new])

    df_mon_old = pd.read_excel(mon_paths['old'].format(base_path=base_path))
    df_mon_new = pd.read_excel(mon_paths['new'].format(base_path=base_path))
    df_mon = pd.concat([df_mon_old, df_mon_new])
    
    ref_path = config['reference_dates_file'].format(base_path=base_path)
    df_ref = pd.read_excel(ref_path)
    reference_dates = pd.to_datetime(df_ref['date']).unique().tolist()
    
    return {'dpa_inflation': df_inf, 'dpa_monetary': df_mon}, reference_dates

def main():
    """Main function to run the index creation pipeline."""
    print("--- Running Time-Series Index Creation Pipeline ---")
    
    with open('config/index_creation_config.yaml', 'r') as f:
        config = yaml.safe_load(f)

    # Load all the classified data
    data_dict, reference_dates = load_data(config)

    # Calculate all indices
    indices = calculate_all_indices(data_dict, reference_dates, config['aggregation_window_days'])

    # Save all indices to separate files
    output_dir = config['output_dir']
    os.makedirs(output_dir, exist_ok=True)
    print(f"\nSaving {len(indices)} indices to '{output_dir}'...")

    for name, series in indices.items():
        file_path = os.path.join(output_dir, f"{name}.xlsx")
        series.to_excel(file_path)

    print("--- Index Creation Pipeline Finished Successfully ---")

if __name__ == "__main__":
    main()