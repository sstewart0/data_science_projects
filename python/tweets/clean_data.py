"""
Clean data:
    1. Remove special characters: !£$%^&*()#
    2. Remove stopwords (e.g. the, and,  ...) minus {???}
    3. Ignore case
    5. Remove links which are in the form https://
    6. Remove @'s
    7. Remove numbers
    8. stemming, lemmatization, normalization
"""

import pandas as pd
from sklearn.model_selection import train_test_split
from nltk.corpus import stopwords
from nltk import RegexpTokenizer
from nltk.stem import WordNetLemmatizer
from nltk.stem.porter import PorterStemmer
import re
import string

# Function to remove html links & mentions
def remove_html_mentions(text):
    text = re.sub(r"(?:\@|https?\://)\S+", "", text)
    return text

# Function to remove numbers
def remove_numbers(text):
    text = ''.join([''.join([i for i in word if not i.isdigit()]) for word in text])
    return text

# Function to remove punctuation
def remove_punctuation(text):
    text = ''.join([symbol for symbol in text if symbol not in string.punctuation])
    return text

tokenizer = RegexpTokenizer('\s+', gaps=True)
# Function to tokenize text
def tokenize_text(text):
    tokenized_text = tokenizer.tokenize(text)
    return tokenized_text

# Function to remove stopwords
def remove_stopwords(text):
    words = [w for w in text if w not in stopwords.words('english')]
    return words

lemmatizer = WordNetLemmatizer()
# Function to lemmatize words:
def lemmatize_words(text):
    lem_text = [lemmatizer.lemmatize(word) for word in text]
    return lem_text

stemmer = PorterStemmer()
# Function to stem words
def stem_words(text):
    stem_text = ' '.join([stemmer.stem(word) for word in text])
    return stem_text

# Clean data:
def clean(data):
    data = data.apply(lambda x: remove_html_mentions(x))
    data = data.apply(lambda x: remove_numbers(x))
    data = data.apply(lambda x: remove_punctuation(x))
    data = data.apply(lambda x: tokenize_text(x.lower()))
    data = data.apply(lambda x: remove_stopwords(x))
    data = data.apply(lambda x: lemmatize_words(x))
    data = data.apply(lambda x: stem_words(x))
    return data

# Create train, test & validation data
def train_test_validate(x, y, t_size=.25, validation_size=.25):
    x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=t_size, random_state=1)

    val_size = round((1-t_size)*validation_size,2)
    x_train, x_val, y_train, y_val = train_test_split(x_train, y_train, test_size=val_size, random_state=1)

    train = pd.concat([x_train, y_train], axis=1)
    test = pd.concat([x_test, y_test], axis=1)
    validate = pd.concat([x_val, y_val], axis=1)

    return train, test, validate


sample = "@nationwid4eclass no, 44 it's not 3behaving at all." \
         " i'm mad4. why am4 i here? becau4se I can't see you all o..."

def main():
    text = remove_html_mentions(sample)
    text = remove_punctuation(text)
    text = remove_numbers(text)
    print(text)

if __name__ == "__main__":
    main()
