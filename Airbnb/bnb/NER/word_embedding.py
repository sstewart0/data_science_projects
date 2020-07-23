"""
Feature engineering:
    1. Count Vectors as features
    -> 2. Word Embeddings as features
    3. Text / NLP based features
    4. Topic Models as features
"""
import pickle
from keras.preprocessing import text, sequence

# Load training and test data
with open("training_data", "rb") as f:
    train = pickle.load(f)
with open("test_data", "rb") as f:
    test = pickle.load(f)

x_train = [str(x) for x in train.name]
x_test = [str(x) for x in test.name]

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
