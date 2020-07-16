import logging
import pandas as pd
import numpy as np
import nltk
from numpy import random
import gensim
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
from sklearn.metrics import accuracy_score, confusion_matrix
import matplotlib.pyplot as plt
from nltk.corpus import stopwords, words
from nltk.tokenize import word_tokenize
from nltk.probability import FreqDist
import re
import pickle

"""
Purpose:
    1. Perform deterministic text-characterisation,
    2. Perform (multiple) ML text-characterisation methods,
    3. Assess performance,
    4. Choose final model
"""

# All data
bnb_data = pd.read_csv("../../AB_NYC_2019.csv")

# Manhattan data
bnb_manhattan = bnb_data.loc[bnb_data['neighbourhood_group'] == 'Manhattan']

# Neighbourhoods
nbhds = bnb_manhattan['neighbourhood'].unique()
num_nbhds = len(nbhds)

'''
Clean data:
    1. Remove special characters: !@£$%^&*() ...
    2. Change all "words" to lower case
    3. Remove possessive pronouns, e.g. Stephen's ---> Stephen
    4. Amend abbreviations? e.g. apt ---> apartment; {BR,bdrm,...} ---> bedroom
    5. Separate numbers and words
'''

REPLACE_BY_SPACE_RE = re.compile('[/(){}\[\]\|@,;*#_]')
BAD_SYMBOLS_RE = re.compile('[^0-9a-z]')
STOPWORDS = set(stopwords.words('english'))
NOTSTOP = set(['from', 'to', 'by'])
POSSESSIVE = re.compile("\'s")
STOPWORDS = STOPWORDS - NOTSTOP

# Separate title and nbhd from data:
X = bnb_manhattan['name']
y = bnb_manhattan['neighbourhood']


# Create function to perform steps 1 -> 3 above.
def clean(text):
    """
    :param text: string
    :return: string
    """
    if type(text) is not float:
        text = text.lower()
        text = REPLACE_BY_SPACE_RE.sub(' ', text)
        text = BAD_SYMBOLS_RE.sub(' ', text)
        text = ' '.join(word for word in text.split() if word not in STOPWORDS)
        text = POSSESSIVE.sub('', text)
    return text


# A first clean of the data.
X = X.apply(clean)

'''
# Check for abbreviations (they will not be in English words, most likely):
WORDS = words.words()
fdist = FreqDist()

for title in X:
    if type(title) is not float:
        for word in word_tokenize(title):
            word = ''.join([letter for letter in word if not letter.isdigit()])
            if (len(word) > 1) and (word not in WORDS):
                fdist[word.lower()] += 1

# Save frequency distribution with pickle
with open("freqDistribution", "wb") as f:
    pickle.dump(fdist, f)

# Run to make manual list of abbreviations:
    for key in freqDist:
        if (freqDist[key] > 10) and (len(key) < 5):
            print([key, freqDist[key]])
'''

# Abbreviations (first word of list = true word)
bedroom = [' bedroom ', 'br ', 'bdr ', 'bdrm ', 'brm ']
bed = [' bed ', 'beds ', 'bd ']
room = [' room ', 'rm ']
NewYorkCity = [' nyc ', ' ny ', 'new york city']
UpperEastSide = [' ues ', 'upper east side']
LowerEastSide = [' les ', 'lower east side']
UpperWestSide = [' uws ', 'upper west side']
SquareFeet = [' sqft ', 'sq ', ' ft', 'sf ', 'sqr ', 'feet ', 'square feet']
minutes = [' minutes ', 'mins ', 'min ']
FinancialDistrict = [' fidi ', 'financial district']
building = [' building ', 'bldg ']
private = [' private ', 'priv ', 'pvt ']
university = [' university ', 'uni ', 'univ ']
floor = [' floor ', 'fl ', 'flr ']
houseKeeping = [' house keeping ', 'hk ']
bath = [' bath ', 'bth']
pennsylvania = [' pennsylvania ', 'penn ']
people = [' people ', 'ppl ']
poughkeepsie = [' poughkeepsie ', 'pk ']
large = [' large ', 'xl ', 'lg ']
elevator = [' elevator ', 'elev ']
center = [' center ', 'ctr ']
location = [' location ', 'loc ']
apartment = [' apartment ', 'apt']

# List of all abbreviations
abbreviations = [bed, bedroom, room, NewYorkCity, UpperEastSide, LowerEastSide,
                 UpperWestSide, SquareFeet, minutes, FinancialDistrict, building,
                 private, university, floor, houseKeeping, bath, pennsylvania,
                 people, poughkeepsie, large, elevator, center, location,
                 apartment]

# Used to split numbers from words eg. '2bath' ---> '2 bath'
separate = re.compile(r"([0-9]+)([a-z]+)")


# Function to separate numbers from words
def sep_numbers(text):
    """
    :param text: string
    :return: string
    """
    token = word_tokenize(text)
    word = ''
    for i in range(0, len(token)):
        match = re.match(separate, token[i])
        if match:
            items = match.groups()
            token[i] = ' '.join(i for i in items)
        word += token[i] + ' '
    return word


# Function to remove whitespace
def remove_white_space(text):
    """
    :param text: string
    :return: string
    """
    text = text.replace('  ', ' ')
    return text


# A function to perform steps 4 and 5:
def amend(text):
    """
    :param text: string
    :return: string
    """
    if type(text) is not float:
        text = sep_numbers(text)
        for lis in abbreviations:
            for i in range(1, len(lis)):
                text = text.replace(lis[i], lis[0])
        text = remove_white_space(text)
    return text


# Apply secondary clean:
X = X.apply(amend)

# Create random train and test set (reproducible)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.15, random_state=42)

# Training data set
train = pd.concat([X_train, y_train], axis=1)

# Test data set
test = pd.concat([X_test, y_test], axis=1)

# Save train and test data
with open("training_data", "wb") as f:
    pickle.dump(train, f)

with open("test_data", "wb") as f:
    pickle.dump(test, f)
