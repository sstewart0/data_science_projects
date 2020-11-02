"""
Clean data:
    1. Remove special characters: !@£$%^&*() ...
    2. Change all "words" to lower case
    3. Remove possessive pronouns, e.g. Stephen's ---> Stephen
    4. Amend abbreviations e.g. apt ---> apartment; {BR,bdrm,...} ---> bedroom
    5. Separate numbers and words e.g. 2bath ---> 2 bath
    6. Change numbers to word equivalent e.g. 2 bath ---> two bath
"""
import pandas as pd
from sklearn.model_selection import train_test_split
from nltk.corpus import stopwords, words
from nltk.tokenize import word_tokenize
from nltk.probability import FreqDist
from nltk.tokenize.treebank import TreebankWordDetokenizer
import re
import pickle

REPLACE_BY_SPACE_RE = re.compile('[/(){}\[\]\|@,;*#_]')
BAD_SYMBOLS_RE = re.compile('[^0-9a-z]')
STOPWORDS = set(stopwords.words('english'))
NOTSTOP = set(['from', 'to', 'by'])
POSSESSIVE = re.compile("\'s")
STOPWORDS = STOPWORDS - NOTSTOP


# Function to get and save abbreviations in titles:
def get_abbreviations(col, out, run):
    WORDS = words.words()
    fdist = FreqDist()
    # Create frequency distribution table with words that are not in english vocab:
    for title in col:
        if type(title) is not float:
            for word in word_tokenize(title):
                word = ''.join([letter for letter in word if not letter.isdigit()])
                if (len(word) > 1) and (word not in WORDS):
                    fdist[word.lower()] += 1
    # Save frequency distribution:
    with open(out, "wb") as f:
        pickle.dump(fdist, f)
    # Run to print list of abbreviations:
    if run:
        for key in fdist:
            if (fdist[key] > 10) and (len(key) < 5):
                print([key, fdist[key]])


# Abbreviations (first word of list = true word)
bedroom = [' bedroom ', 'br ', 'bdr ', 'bdrm ', 'brm ']
street = ['street', ' st ']
bed = [' bed ', 'beds ', 'bd ']
room = [' room ', 'rm ']
NewYorkCity = [' nyc ', ' ny ', 'new york city', 'new york']
UpperEastSide = [' ues ', 'upper east side']
LowerEastSide = [' les ', 'lower east side']
UpperWestSide = [' uws ', 'upper west side']
TimesSquare = [' times square ', 'timesq ', 'times sq ']
SquareFeet = [' sqft ', ' ft', 'sf ', 'sqr ', 'square feet', ' sq ft ']
minutes = [' minutes ', 'mins ', 'min ']
FinancialDistrict = [' fidi ', 'financial district']
building = [' building ', 'bldg ']
private = [' private ', 'priv ', 'pvt ']
university = [' university ', 'uni ', 'univ ']
floor = [' floor ', 'fl ', 'flr ']
houseKeeping = [' house keeping ', 'hk ']
bath = [' bath ', 'bth ']
pennsylvania = [' pennsylvania ', 'penn ']
people = [' people ', 'ppl ']
poughkeepsie = [' poughkeepsie ', 'pk ']
large = [' large ', 'xl ', 'lg ']
elevator = [' elevator ', 'elev ']
center = [' center ', 'ctr ']
location = [' location ', 'loc ']
apartment = [' apartment ', 'apt']
wit = [' with ', ' w ']

# List of all abbreviations
abbreviations = [bed, bedroom, room, NewYorkCity, UpperEastSide, LowerEastSide,
                 UpperWestSide, SquareFeet, minutes, FinancialDistrict, building,
                 private, university, floor, houseKeeping, bath, pennsylvania,
                 people, poughkeepsie, large, elevator, center, location,
                 apartment, TimesSquare, street, wit]

# Used to split numbers from words eg. '2bath' ---> '2 bath'
separate = re.compile(r"([0-9]+)([a-z]+)")


# Function to separate numbers from words
def sep_numbers(text):
    token = word_tokenize(text)
    for i in range(0, len(token)):
        match = re.match(separate, token[i])
        if match:
            items = match.groups()
            token[i] = ' '.join(j for j in items)
    return TreebankWordDetokenizer().detokenize(token)


NUMBERS = {1: "one", 2: "two", 3: "three", 4: "four", 5: "five",
           6: "six", 7: "seven", 8: "eight", 9: "nine"}


# Function to change integers to word
# (must be completed after number's and words have be separated)
def num_to_word(text):
    token = word_tokenize(text)
    for i in range(0, len(token)):
        if (token[i].isdigit()) and (0 < int(token[i]) < 10):
            token[i] = NUMBERS[int(token[i])]
    return TreebankWordDetokenizer().detokenize(token)


# Function to remove whitespace
def remove_white_space(text):
    text = text.replace('  ', ' ')
    return text


# Function to perform steps 4 and 5:
def clean(text):
    if type(text) is not float:
        text = text.lower()
        text = REPLACE_BY_SPACE_RE.sub(' ', text)
        text = BAD_SYMBOLS_RE.sub(' ', text)
        text = ' '.join(word for word in text.split() if word not in STOPWORDS)
        text = POSSESSIVE.sub('', text)
        text = sep_numbers(text)
        text = num_to_word(text)
        for lis in abbreviations:
            for i in range(1, len(lis)):
                text = text.replace(lis[i], lis[0])
        text = remove_white_space(text)
    return text


# Create train, test data and save
def train_test(x, y, size):
    x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=size, random_state=42)
    train = pd.concat([x_train, y_train], axis=1)
    test = pd.concat([x_test, y_test], axis=1)
    with open("training_data", "wb") as f:
        pickle.dump(train, f)
    with open("test_data", "wb") as f:
        pickle.dump(test, f)


def main():
    # All data
    bnb_data = pd.read_csv("../../AB_NYC_2019.csv")
    # Manhattan data
    bnb_manhattan = bnb_data.loc[bnb_data['neighbourhood_group'] == 'Manhattan']
    # Separate title and nbhd from data:
    x = bnb_manhattan['name']
    y = bnb_manhattan['neighbourhood']
    # Clean data.
    x = x.apply(clean)
    # Create random train and test set (reproducible)
    train_test(x, y, 0.1)


if __name__ == "__main__":
    main()
