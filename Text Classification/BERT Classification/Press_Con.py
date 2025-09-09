# -*- coding: utf-8 -*-
"""
Created on Wed May  7 20:44:48 2025

@author: Ja-ba
"""

import pandas as pd

#date = '2010-09-02'
#date = '2010-11-04'
date = '2011-03-03'

filtered_df = press_sents[press_sents['date'] == date]
filtered_df = filtered_df.drop_duplicates(subset="sentence")

filtered_df_mon = data_ECB_sents_monetary[data_ECB_sents_monetary['date'] == date]
filtered_df_inf = data_ECB_sents_inf[data_ECB_sents_inf['date'] == date]
filtered_df_out = data_ECB_sents_outlook[data_ECB_sents_outlook['date'] == date]

ordered_df_inf = filtered_df.merge(filtered_df_inf, left_on='sentence', right_on='text', how='left')
ordered_df_mon = filtered_df.merge(filtered_df_mon, left_on='sentence', right_on='text', how='left')
ordered_df_out = filtered_df.merge(filtered_df_out, left_on='sentence', right_on='text', how='left')

# filtered_df = filtered_df.rename(columns={"sentence": "text"})
# filtered_df_inf['text'] = filtered_df['sentence']
# filtered_df_mon['text'] = filtered_df['sentence']
# filtered_df_out['text'] = filtered_df['sentence']

combined_df = pd.DataFrame({
    "inf_label": ordered_df_inf["Label"].reset_index(drop=True),
    "mon_label": ordered_df_mon["Label"].reset_index(drop=True),
    "out_label": ordered_df_out["Label"].reset_index(drop=True),
})

combined_df["text"] = list(ordered_df_inf["text"])
combined_df = combined_df.drop_duplicates(subset="text")
#combined_df = ordered_df_inf.merge(combined_df, left_on='text', right_on='text', how='left')

inf_map = {
    0: "Decreasing inflation outlook",
    1: "Stable inflation outlook",
    2: "Increasing inflation outlook"
}

mon_map = {
    2: "dovish monetary stance",
    1: "stable monetary stance",
    0: "hawkish monetary stance"
}

out_map = {
    0: "decreasing economic outlook",
    1: "stable economic outlook",
    2: "improving economic outlook"
}

combined_df["inf_label"] = combined_df["inf_label"].map(inf_map)
combined_df["mon_label"] = combined_df["mon_label"].map(mon_map)
combined_df["out_label"] = combined_df["out_label"].map(out_map)

formatted_lines = [
    f"{row['text'].strip()} [{row['inf_label']}, {row['mon_label']}, {row['out_label']}] \\\\"
    for _, row in combined_df.iterrows()
]

output_text = "\n".join(formatted_lines)
print(output_text)