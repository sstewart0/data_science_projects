"""
Feature engineering:
    -> 1. Count Vectors as features
    3. Word Embeddings as features
    4. Text / NLP based features
    5. Topic Models as features
"""
import pickle
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
from sklearn import preprocessing
from keras.preprocessing import text, sequence
import numpy

# Load training and test data
with open("training_data", "rb") as f:
    train = pickle.load(f)
with open("test_data", "rb") as f:
    test = pickle.load(f)

# encode the target variable
encoder = preprocessing.LabelEncoder()
train.neighbourhood = encoder.fit_transform(train.neighbourhood)
test.neighbourhood = encoder.fit_transform(test.neighbourhood)

# Create list of strings to pass to CountVectorizer:
x_train = [str(x) for x in train.name]
x_test = [str(x) for x in test.name]

# 1. Convert names into a matrix of token counts:
count_vect = CountVectorizer(lowercase=False, ngram_range=(1, 2), min_df=10,
                             max_features=200)
doc_matrix_count = count_vect.fit_transform(x_train)

# 2. Create word embeddings:
vocab_size = 1000
encoded = [text.one_hot(text=title, n=vocab_size, lower=False, split=" ") for title in x_train]
# 2. Make vectors same length:
encoded = sequence.pad_sequences(encoded, padding='post')

# 2. Create tokenizer:
token = text.Tokenizer(lower=False, split=" ", char_level=False)
token.fit_on_texts(x_train)
word_index = token.word_index

# 2. Create vectors with equal length using sequence:
train_seq_x = sequence.pad_sequences(token.texts_to_sequences(x_train))
test_seq_x = sequence.pad_sequences(token.texts_to_sequences(x_test))

# 2. Create a mapping from token -> embedding
