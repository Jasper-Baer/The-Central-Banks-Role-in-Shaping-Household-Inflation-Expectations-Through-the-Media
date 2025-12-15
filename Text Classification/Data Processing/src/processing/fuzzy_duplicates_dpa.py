# -*- coding: utf-8 -*-
"""
Created on Mon Sep 28 14:42:57 2020
@author: mokuneva
"""

# source: https://towardsdatascience.com/a-laymans-guide-to-fuzzy-document-deduplication-a3b3cf9a05a7

from gensim.utils import simple_preprocess
from gensim import corpora
from gensim.similarities import MatrixSimilarity

def fuzzy_duplicates(inputs):
    """ 
    This function returns the indices of duplicated articles.
    """ 
    # Select a new dataframe corresponding to a particular month and year.
    documents = inputs[2][(inputs[2]['year'] == inputs[0]) & (inputs[2]['month'] == inputs[1])]       
    # Reset the index of the DataFrame.
    documents = documents.reset_index()
    # Convert documents to a collection of words.
    texts = [[text for text in simple_preprocess(doc, deacc=True)] for doc in documents.texts]
    # Create a dictionary.
    dictionary = corpora.Dictionary(texts)
    # Create a corpus (BOW representation).
    corpus = [dictionary.doc2bow(docString) for docString in texts]
    # Build a pairwise cosine similarity index.
    index = MatrixSimilarity(corpus, num_features=len(dictionary))
    
    # Parse similarities.
    doc_id = 0
    similar_docs = {}
    for similarities in index:
        similar_docs[doc_id] = list(enumerate(similarities))
        doc_id += 1
    
    # Set a similarity cutoff threshold.
    sim_threshold = 0.93
    
    # Return the indices of duplicated articles.
    delete_indices = []
    considered_pairs = []
    for doc_id, sim_doc_tuples in similar_docs.items():
        for sim_doc_tuple in sim_doc_tuples:
            sim_doc_id = sim_doc_tuple[0]
            sim_score = sim_doc_tuple[1]
            if (sim_score >= sim_threshold) and (doc_id != sim_doc_id):
                if (doc_id, sim_doc_id) not in considered_pairs:
                    considered_pairs.append((doc_id, sim_doc_id))
                    considered_pairs.append((sim_doc_id, doc_id))
                    
                    doc1_date = documents['date'][doc_id]
                    doc2_date = documents['date'][sim_doc_id]
                    
                    if doc1_date == doc2_date:
                        if documents['word_count'][doc_id] >= documents['word_count'][sim_doc_id]:
                            delete_indices.append(documents['index'][sim_doc_id])                            
                        else:
                            delete_indices.append(documents['index'][doc_id])
                    else:
                        if doc1_date < doc2_date:
                            delete_indices.append(documents['index'][sim_doc_id])
                        else:
                            delete_indices.append(documents['index'][doc_id])
                            
    return delete_indices