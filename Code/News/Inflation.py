# -*- coding: utf-8 -*-
"""
Created on Sun Aug 21 19:18:29 2022

@author: jbaer
"""

# word_list_ecb_two_words = [
#     "Wim Duisenberg",           # President of the ECB (1998-2003)
#     "Jean-Claude Trichet",      # President of the ECB (2003-2011)
#     "Mario Draghi",             # President of the ECB (2011-2019)
#     "Christine Lagarde",        # President of the ECB (2019-Present, as of Sept 2021)

#     "Christian Noyer",          # Vice-President of the ECB (1998-2002)
#     "Lucas Papademos",          # Vice-President of the ECB (2002-2010)
#     "Vítor Constâncio",         # Vice-President of the ECB (2010-2018)
#     "Luis de Guindos",          # Vice-President of the ECB (2018-Present, as of Sept 2021)

#     # Executive Board Members
#     "Sirkka Hämäläinen",        # (1998-2003)
#     "Tommaso Padoa-Schioppa",   # (1998-2005)
#     "Eugenio Domingo Solans",   # (1998-2004)
#     "Otmar Issing",             # (1998-2006)
#     "José Manuel González-Páramo",  # (2004-2012)
#     "Jürgen Stark",             # (2006-2011)
#     "Lorenzo Bini Smaghi",      # (2005-2011)
#     "Peter Praet",              # (2011-2019)
#     "Jörg Asmussen",            # (2012-2013)
#     "Sabine Lautenschläger",    # (2014-2019)
#     "Benoît Cœuré",             # (2012-2019)
#     "Yves Mersch",              # (2012-2020)
#     "Isabel Schnabel",          # (2020-Present)
#     "Philip R. Lane",           # (2019-Present)
#     "Fabio Panetta",            # (2020-Present)
#     "Frank Elderson",           # (2021-Present)
    
#     ]

import pandas as pd
import os
import json
import numpy as np
import stanza
from tqdm import tqdm
from ast import literal_eval

# Function to process data and save them
def process_and_save_data(data, file_suffix):
    data['texts'] = data['texts'].apply(lambda x: [x])
    data = data.drop(['lemmas', 'Unnamed: 0'], axis=1)

    pre_processing = prepare_text(data['texts']).preproces_text()
    data['tokens'] = pre_processing[0]
    stem_map = pre_processing[1]

    data_file_path = f'D:\\Studium\\PhD\\Single Author\\Data\\dpa_sents_final_preprocessed_{file_suffix}.csv'
    data.to_csv(data_file_path)

    stem_map_file_path = f'D:\\Studium\\PhD\\Single Author\\Data\\stem_map_{file_suffix}.json'
    with open(stem_map_file_path, 'w') as fp:
        json.dump(stem_map, fp)

    return data_file_path, stem_map_file_path

PATH = r"D:\Studium\PhD\Github\Single-Author\Code\Unsupervised"
os.chdir(PATH)

from PR_index_supp import prepare_text

import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)

nlp = stanza.Pipeline(processors= 'lemma,tokenize,pos,depparse', lang = 'de')

# Determine the number of rows in the file
num_rows = sum(1 for line in open(r'D:\Studium\PhD\Single Author\Data\dpa\dpa_prepro_final_sentences_no_lemmas_full_with_lemmas.csv', encoding = 'utf-8'))

data_file_paths = []
stem_map_file_paths = []
final_stem_map = {}

# Loop over the data in tenths
for i in range(10):
    # Load the necessary data
    data = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\dpa\dpa_prepro_final_sentences_no_lemmas_full_with_lemmas.csv', 
                       encoding = 'utf-8',  
                       keep_default_na=False,
                       dtype = {'rubrics': 'str', 
                                'source': 'str',
                                'keywords': 'str',
                                'title': 'str',
                                'city': 'str',
                                'genre': 'str',
                                'texts': 'str'},
                       skiprows = range(1, i * num_rows // 10 + 1),
                       nrows = num_rows // 10)

    # Process the data and save it
    data_file_path, stem_map_file_path = process_and_save_data(data, f'part_{i+1}')
    data_file_paths.append(data_file_path)
    stem_map_file_paths.append(stem_map_file_path)

# Combine all the parts
final_data_parts = []
for file_path in data_file_paths:
    final_data_parts.append(pd.read_csv(file_path))
final_data = pd.concat(final_data_parts)

# Merge all stem_maps
for file_path in stem_map_file_paths:
    with open(file_path) as f:
        stem_map = json.load(f)
    final_stem_map = {**final_stem_map, **stem_map}

# Save the final data and stem_map
final_data.to_csv('D:\\Studium\\PhD\\Single Author\\Data\\dpa_sents_final_preprocessed.csv')

with open('D:\\Studium\\PhD\\Single Author\\Data\\stem_map.json', 'w') as fp:
    json.dump(final_stem_map, fp)

###################################################

data = pd.read_csv('D:\\Studium\\PhD\\Single Author\\Data\\dpa_sents_final_preprocessed.csv', 
                   encoding = 'utf-8',  
                   keep_default_na=False,
                   #converters = {'tokens': literal_eval},
                   dtype = {'rubrics': 'str', 
                            'source': 'str',
                            'keywords': 'str',
                            'title': 'str',
                            'city': 'str',
                            'genre': 'str',
                            'texts': 'str'})

with open('D:\\Studium\\PhD\\Single Author\\Data\\stem_map.json', 'r') as fp:
    final_stem_map = json.load(fp)
    
##########################################################################

# #stanza.download('de')


# data = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\dpa\dpa_prepro_final_sentences_no_lemmas_full_with_lemmas.csv', encoding = 'utf-8',  keep_default_na=False,
#                    dtype = {'rubrics': 'str', 
#                             'source': 'str',
#                             'keywords': 'str',
#                             'title': 'str',
#                             'city': 'str',
#                             'genre': 'str',
#                             'texts': 'str'})

# data['texts'] = data['texts'].apply(lambda x: [x])
# data = data.drop(['lemmas', 'Unnamed: 0'], axis=1)

# #pre_processing = prepare_text(data['sentences']).preproces_text()
# pre_processing = prepare_text(data['texts']).preproces_text()
# data['tokens'] = pre_processing[0]
# stem_map = pre_processing[1]

# data.to_csv('D:\Studium\PhD\Single Author\Data\dpa_sents_final_preprocessed.csv')

# import json

# # assuming stem_map is your dictionary
# with open('D:\Studium\PhD\Single Author\Data\stem_map.json', 'w') as fp:
#     json.dump(stem_map, fp)


word_list = [
    'Deflation',
    'Geldentwertung',
    'Geldwert',
    'Hyperinflation',
    'Inflation',
    'Inflations',
    'Inflationsrate',
    'Kaufkraft',
    'Lebenshaltungskosten',
    'Preisanstieg',
    'Preiserhöhung',
    'Preisindex',
    'Preisniveau',
    'Teuerung',
    'Verbraucherpreisindex',
    'Verteuerung',
    'Warenkorb'
]

word_list_ecb = [
    
    "EZB",
    "EZB-Präsident", 
    "EZB-Präsidentin", 
    "EZB-Vizepräsident",
    "EZB-Rat",
    "Währungshüter",
    "Duisenberg",
    "Trichet",
    "Draghi",
    "Lagarde",
    "Noyer",
    "Papademos",
    "Constâncio",
    "de Guindos",
    "Hämäläinen",
    "Padoa-Schioppa",
    "Domingo Solans",
    "Issing",
    "González-Páramo",
    "Bini Smaghi",
    "Praet",
    "Asmussen",
    "Lautenschläger",
    "Cœuré",
    "Mersch",
    "Schnabel",
    "Lane",
    "Panetta",
    "Elderson"
    
]

a = snowball_stemmer.stem("(Zusammenfassung 1045) EZB stellt Zinssenkung in Aussicht - keine Deflationsgefahr. Frankfurt/Main Die Europäische Zentralbank (EZB) stellt sich wegen zunehmender Preisstabilität auf eine Zinssenkung ein. Die Gefahr einer Deflation mit dauerhaft rückläufigen Preisen und sinkender Nachfrage ist nach Ansicht von EZB-Vizepräsident Lucas Papademos allerdings auch in Deutschland sehr gering. Sämtliche Prognosen auch des Internationalen Währungsfonds (IWF) rechneten für 2004 in Euroland mit einer durchschnittlichen Preiserhöhung von etwa 1,5 Prozent, sagte Papademos am Montagabend im Internationalen Club Frankfurter Wirtschaftsjournalisten. Für Deutschland sieht der griechische Notenbankpolitiker nur eine «sehr geringe Wahrscheinlichkeit» für ein Abrutschen in die Deflation. Entsprechende Befürchtungen waren aufgekommen, nachdem die jährliche Teuerungsrate hier zu Lande im Mai auf 0,7 (Vormonat: 1,0) Prozent abgesackt war. Die Gefahr für Deutschland wäre allerdings größer, wenn die wichtigste Volkswirtschaft derzeit allein stünde und nicht Mitglied der Währungsunion wäre. Die derzeit niedrige Inflation stärkt laut Papademos jedoch die Wettbewerbsposition der deutschen Exportwirtschaft gegenüber den Nachbarländern. Gegen nachhaltige Preisrückgänge sprächen aber auch immer noch steigende Löhne und Dienstleistungspreise. Im unerwarteten Extremfall werde die EZB aber rechtzeitig reagieren, um eine Deflation zu bekämpfen. Schließlich sei man in Euroland noch weit weg von einem Null-Zinsniveau, betonte Papademos. Während vor allem in Deutschland hitzig über Deflation debattiert wird, sondiert die EZB sämtliche verfügbare Daten, um die Inflation mittelfristig einschätzen zu können. Der starke Euro und die schwache Konjunktur stärkten die Hoffnung, dass die jährliche Teuerungsrate im Euroraum 2004 unter der Ziellinie von 2 Prozent liegen werde, betonte der EZB-Vizepräsident. Diese Aussage werten Beobachter als Signal für eine Senkung der Leitzinsen bereits Anfang Juni um 0,25 Prozentpunkte auf dann 2,25 Prozent. Die europäischen Währungshüter rechnen erst in der zweiten Jahreshälfte mit einer allmählichen Erholung der Konjunktur. Dieser positive Trend werde sich 2004 voraussichtlich verstärken. Da die weltweite Nachfrage eher verhalten einzuschätzen sei, erwartet Papademos die entscheidenden Impulse von der Binnenkonjunktur. Sinkende Ölpreise und geringe Inflation erhöhten die Kaufkraft der privaten Verbraucher. Das durchschnittliche Wirtschaftswachstum für Euroland könnte im laufenden Jahr knapp unter 1 Prozent liegen. Die Diskussion über einen angeblich überschießenden Euro-Kurs gegenüber dem Dollar hält der Zentralbank-Vizepräsident für übertrieben. Vielmehr sei der Außenwert der Gemeinschaftswährung in der Vergangenheit - im Verhältnis zu den fundamentalen volkswirtschaftlichen Daten - eher unterbewertet gewesen. Der aktuelle Kurs bewege sich nun wieder auf dem Ausgangsniveau von Anfang 1999. Dies entspreche auch dem langjährigen Durchschnitt der Kursrelation zur amerikanischen Währung. Trotz der bekundeten Bereitschaft, die Geldpolitik zu lockern, mahnte Papademos die europäischen Regierungen, damit würden die strukturellen Probleme in den Staatshaushalten nicht gelöst. Insbesondere in Deutschland hingen die mittel- und langfristigen Wachstumsperspektiven davon ab, die notwendigen Strukturreformen anzupacken.)")

from nltk.stem.snowball import SnowballStemmer

snowball_stemmer = SnowballStemmer('german')

word_list = [snowball_stemmer.stem(word.lower()) for word in word_list]
word_list_ecb = [snowball_stemmer.stem(word.lower()) for word in word_list_ecb]

inflation_sentences = pd.DataFrame()
ecb_sentences = pd.DataFrame()

for idx, art in tqdm(enumerate(data['tokens'])):
    
    for j, tok in enumerate(art):
        
        found_names = set()
        
        if any(word in word_list for word in tok):
        
            inflation_sentences = pd.concat([inflation_sentences,pd.DataFrame({'tokens' : [tok], 'index': [idx]})], ignore_index=True)
            
            for i in range(len(tok) - 1):
                
                if tok[i] in word_list_ecb:
                    
                    found_names.add(tok[i])
                    
                elif tok[i] == "europa" and tok[i+1] == "zentralbank":
                    
                    found_names.add(tok[i])
                
                # expection for "Jürgen Stark"
                elif tok[i] == "jurg" and tok[i+1] == "stark":
                    
                    found_names.add(tok[i])
                                                       
            if len(found_names) > 0:
                
                #sent = literal_eval(data['sentences'].iloc[idx])[j]
                
                #ecb_sentences = ecb_sentences.append({'sentence': sent,'tokens' : tok, 'index': idx}, ignore_index=True) 
                
                ecb_sentences = pd.concat([ecb_sentences,pd.DataFrame({'tokens' : [tok], 'index': [idx]})], ignore_index=True)
                
                
# Initialize an empty list to store the rows
rows = []
ecb_rows = []

for idx, art in tqdm(enumerate(data['tokens'])):
    for j, tok in enumerate(art):
        found_names = set()
        if any(word in word_list for word in tok):
            rows.append({'tokens' : tok, 'index': idx})
            for i in range(len(tok) - 1):
                if tok[i] in word_list_ecb:
                    found_names.add(tok[i])
                elif tok[i] == "europa" and tok[i+1] == "zentralbank":
                    found_names.add(tok[i])
                elif tok[i] == "jurg" and tok[i+1] == "stark":
                    found_names.add(tok[i])
            if len(found_names) > 0:
                #sent = ast.literal_eval(data['texts'].iloc[idx])[j]
                sent = data['texts'].iloc[idx][j]
                #sent = ast.literal_eval(data['sentences'].iloc[idx])[j]
                ecb_rows.append({'sentence': sent,'tokens' : tok, 'index': idx})

# Create the DataFrame from the list of dictionaries all at once
inflation_sentences = pd.DataFrame(rows)
ecb_sentences = pd.DataFrame(ecb_rows)

inflation_sentences.to_csv(r'D:\Studium\PhD\Github\Single-Author\Data\newspaper_dpa_inflation_sentences_final.csv')
ecb_sentences.to_csv(r'D:\Studium\PhD\Github\Single-Author\Data\news_dpa_ecb_inflation_sentences_final.csv')

inflation_sentences= pd.read_csv(r'D:\Studium\PhD\Github\Single-Author\Data\newspaper_dpa_inflation_sentences_final.csv')   

ecb_sentences = pd.read_csv(r'D:\Studium\PhD\Github\Single-Author\Data\news_dpa_ecb_inflation_sentences_final.csv',
                            encoding = 'utf-8')

ecb_sentences = data[data.index.isin(ecb_sentences['index'])]

#ecb_sentences.to_csv(r'D:\Studium\PhD\Github\Single-Author\Data\news_dpa_ecb_inflation_sentences_final.csv')
ecb_sentences = pd.read_csv(r'D:\Studium\PhD\Github\Single-Author\Data\news_dpa_ecb_inflation_sentences_final.csv',
                            encoding = 'utf-8')

ecb_sentences['texts'] = ecb_sentences['texts'].apply(lambda x: [x])

ecb_sentences_pre = prepare_text(ecb_sentences['texts']).preproces_text()
ecb_sentences['texts'] = ecb_sentences['texts'].apply(lambda x: x[0])

stem_map = ecb_sentences_pre[1]

nlp = stanza.Pipeline(processors= 'lemma,tokenize,pos,depparse', lang = 'de')
        
def process_sentence(sentence, idx, stem_map):
    
        nlp_pars = nlp(sentence)
        parsed_sentence = nlp_pars.sentences[0]
        deps = []

        for dep in  parsed_sentence.dependencies:
            
            try:
                dep_word = (stem_map[dep[2].text.lower()], dep[0].id, dep[1], dep[2].id) 
            except KeyError:
                dep_word = (dep[2].text, dep[0].id, dep[1], dep[2].id) 
                
            deps.append(dep_word)
                
        return {'sentence': sentence, 'dependencies': deps, 'index': idx}

dependency_data = [process_sentence(row['texts'], idx, stem_map) for idx, row in tqdm(ecb_sentences.iterrows())]
dependency_data = [item for item in dependency_data if item is not None]
dependency_df = pd.DataFrame(dependency_data)

#dependency_df.to_csv(r'D:\Studium\PhD\Single Author\Data\dependencies130623.csv')

dependency_df = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\dependencies130623.csv',
                            converters = {'dependencies': literal_eval})

filtered_ecb_sentences = []

reporting_verbs = ['sagen', 'sagt', 'betont', 'sehen', 'gehen', 'berichten', 'meinen', 'erwarten', 'vorhergesagen', 'rechnen', 'mahnen', 'warnen']

def filter_rows(row):
    deps = row['dependencies']
    sent_in_ecb = False
    prev_dep = ""

    for dep in deps:

        if dep[2] in ["nsubj", "nsubjpass"]:
            subj = dep
            if subj[0] in word_list_ecb or (prev_dep == "europa" and subj[0] == "zentralbank"):
                sent_in_ecb = True

        elif dep[2] in ['obj', 'iobj']:
            if dep[0].lower() in word_list_ecb or (prev_dep == "europa" and dep[0] == "zentralbank"):
                obj_dep = dep[1]
                if deps[obj_dep] in reporting_verbs:
                    sent_in_ecb = True
                    
        prev_dep = dep[0]

    if sent_in_ecb:
        return row

filtered_series = dependency_df.apply(filter_rows, axis=1).dropna()
filtered_ecb_sentences = pd.DataFrame(filtered_series.tolist(), columns=dependency_df.columns)
              
ecb_data = ecb_sentences[ecb_sentences.index.isin(filtered_ecb_sentences['index'])]
ecb_data['index'] = ecb_data.index
#ecb_data = data[data.index.isin(ecb_data['index'])]
#ecb_data['date'] = pd.to_datetime(ecb_data[['year', 'month', 'day']])

news_data_full = data.iloc[data.index[list(inflation_sentences['index'])]]
#news_data_full['date'] = pd.to_datetime(news_data_full[['year', 'month', 'day']])
news_data_full = news_data_full.reset_index(drop = True)
news_data_full['tokens'] = inflation_sentences['tokens']

news_data_full.set_index('date', inplace=True)
ecb_data.set_index('date', inplace=True)

ecb_data.to_csv(r'D:\Studium\PhD\Single Author\Data\ecb_data_final.csv')
news_data_full.to_csv(r'D:\Studium\PhD\Single Author\Data\news_data_full_inflation_final.csv')

news_data_full = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\news_data_full_inflation_final.csv')
ecb_data = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\ecb_data_final.csv')
#data = pd.read_csv('D:\Studium\PhD\Single Author\Data\dpa_sents_v01.csv')

ecb_data.index = pd.to_datetime(ecb_data['date'])
news_data_full.index = pd.to_datetime(news_data_full['date'])
#data.index = pd.to_datetime(data[['year', 'month', 'day']])

# Resample the DataFrame by month and count the number of rows in each month
monthly_counts_ecb = ecb_data.resample('M').size()
monthly_counts_full_data = news_data_full.resample('M').size()

monthly_counts = monthly_counts_ecb/monthly_counts_full_data
monthly_counts = monthly_counts.dropna()

monthly_counts.to_csv(r'D:\\Studium\\PhD\\Github\\Single-Author\\Data\\Regression\\monthly_ecb_counts.csv')

# Resample the DataFrame by month and count the number of rows in each month
quarterly_counts_ecb = ecb_data.resample('Q').size()
quarterly_counts_full_data = news_data_full.resample('Q').size()

quarterly_counts = quarterly_counts_ecb/quarterly_counts_full_data
quarterly_counts = quarterly_counts.dropna()

quarterly_counts.to_csv(r'D:\\Studium\\PhD\\Github\\Single-Author\\Data\\Regression\\quarterly_ecb_counts.csv')

###

data['date'] = pd.to_datetime(data['date'])
data.index = data['date'] 

monthly_counts_full_data_all = data['date'].resample('M').size() 
quarterly_counts_full_data_all = data['date'].resample('Q').size() 

monthly_inflation_count = monthly_counts_full_data/monthly_counts_full_data_all
quarterly_inflation_count = quarterly_counts_full_data/quarterly_counts_full_data_all

monthly_inflation_count.to_csv(r'D:\\Studium\\PhD\\Github\\Single-Author\\Data\\Regression\\monthly_inflation_count.csv')
quarterly_inflation_count.to_csv(r'D:\\Studium\\PhD\\Github\\Single-Author\\Data\\Regression\\quarterly_inflation_count.csv')

###

import matplotlib.pyplot as plt

plt.figure(figsize=(10,6))
plt.plot(quarterly_inflation_count[45:])
plt.show()

plt.figure(figsize=(10,6))
plt.plot(quarterly_counts[45:])
plt.show()

###

plt.figure(figsize=(10,6))
plt.plot(monthly_counts)
plt.show()

#####

data = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\dpa\dpa_prepro_final.csv', encoding = 'utf-8', index_col = 0,  keep_default_na=False,
                   dtype = {'rubrics': 'str', 
                            'source': 'str',
                            'keywords': 'str',
                            'title': 'str',
                            'city': 'str',
                            'genre': 'str',
                            'wordcount': 'str'}, sep = ";")

news_data_full = pd.read_csv(r'D:\Studium\PhD\Single Author\Data\news_data_full_inflation_final.csv')

artilces = data[data['file'].isin(news_data_full['file'])]

articles_ecb = artilces[artilces['file'].isin(ecb_data['file'])]

most_common_file = None

n1 = 3 
n2 = 5  

matching_files = []

for file in tqdm(news_data_full['file'].unique()):

    ecb_count = (ecb_data['file'] == file).sum()
    news_count = (news_data_full['file'] == file).sum()

    if ecb_count >= n1 and news_count >= n2:

        matching_files.append(file)

# Print the files that meet the criteria
if matching_files:
    print(f"The following files appear at least {n1} times in ecb_data and at least {n2} times in news_data_full:")
    for file in matching_files:
        print(file)
else:
    print(f"No files found that appear at least {n1} times in ecb_data and at least {n2} times in news_data_full.")
    
potential_sentences_full = news_data_full[news_data_full['file'].isin(matching_files)]
potential_sentences_ecb = ecb_data[ecb_data['file'].isin(matching_files)]
potential_articles = data[data['file'].isin(matching_files)]

potential_articles_search = data[data['file'].isin(news_data_full['file'])]


####

text = "(Zusammenfassung 1600) EZB neigt wegen Inflation zu Zinserhöhung - Zunächst keine Änderung (Mit Bild). Frankfurt/Main Die Europäische Zentralbank (EZB) ist besorgt über die hohe Inflation im Euro-Raum und neigt zu weiteren Zinserhöhungen. «Wir werden nicht zulassen, dass die Inflationsrate weiter ansteigt», sagte EZB-Präsident Jean-Claude Trichet am Donnerstag in Frankfurt. Die Notenbank werde entschieden dagegen vorgehen, dass überzogene Lohnsteigerungen in den kommenden Tarifverhandlungen die Preise weiter nach oben trieben. «Wir werden solche Zweitrundeneffekte nicht tolerieren, das ist glasklar», betonte Trichet. Am Donnerstag ließ die EZB trotz der hohen Inflation den Leitzins vorerst unverändert bei 4,0 Prozent. Es war die erste Sitzung mit den neuen Euro-Mitgliedern Malta und Zypern. «Wir haben das Für und Wider einer Zinserhöhung oder keiner Zinserhöhung besprochen und haben uns entschieden, die Zinsen unverändert zu lassen», sagte Trichet und deutete damit indirekt an, dass eine Zinssenkung nicht in Frage komme. Seit Monaten steckt die EZB in einer Zwickmühle: Niedrigere Zinsen könnten die Inflation anheizen, weil Kredite günstiger werden. Höhere Zinsen würden Kredite verteuern und könnten die ohnehin von dem starken Euro und der Finanzmarktkrise belastete Konjunktur dämpfen. Im Dezember war die Teuerung im Euro-Raum wegen gestiegener Öl- und Lebensmittelpreise auf 3,1 Prozent geklettert. «Die Inflationsrate wird auch in den kommenden Monaten über zwei Prozent verharren und 2008 nur etwas zurückgehen», sagte Trichet. Die EZB sieht Preisstabilität bei 2,0 Prozent gewahrt. Die Aussichten für das Wirtschaftswachstum seien aber trotz der Finanzmarktkrise und des starken Euro gut. Der Notenbankpräsident kündigte wegen der anhaltenden Unsicherheiten am Geldmarkt weitere Finanzspritzen für Geschäftsbanken an: Am 17. Januar werde die EZB zehn Milliarden Euro zur Verfügung stellen. Seit Ausbruch der Finanzmarktkrise im vergangenen Sommer hatten Notenbanken weltweit mehrfach Milliarden zur Verfügung gestellt. Infolge der US-Immobilienkrise leihen sich Banken untereinander nicht mehr im sonst üblichen Maße Geld aus, so dass es am Geldmarkt Engpässe gibt. Ausgestanden ist die Finanzmarktkrise nach Ansicht von Trichet noch nicht. Es sei auch «falsch zu glauben, die Dinge würden sich in Luft auslösen», sobald die Bilanzen der Banken für das Jahr 2007 vorlägen. «Gleichzeitig ist klar, dass wir Transparenz, Klarheit und Wahrheit einfordern»,betonte Trichet. Seit Juni 2007 liegt der Leitzins im Euro-Raum konstant bei 4,0 Prozent. Auch die britische Notenbank ließ ihren Leitzins am Donnerstag wie erwartet unverändert bei 5,50 Prozent."

test = pd.DataFrame({'text': [text]})

import nltk

# Split the text into sentences
sentences = nltk.sent_tokenize(test['text'].iloc[0])

# Create a new DataFrame from the list of sentences
df_sentences = pd.DataFrame({'text': [[sentence] for sentence in sentences]})

####

pre_processing_test = prepare_text(df_sentences['text']).preproces_text()
#data['tokens'] = pre_processing[0]
tokens = pre_processing_test[0]
stem_map = pre_processing_test[1]
