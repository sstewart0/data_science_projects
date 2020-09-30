import pandas as pd
import clean_data as cd
import random
from keras_preprocessing.text import Tokenizer

f = 'tweet_data.csv'
num_lines = sum(1 for _ in open(f, encoding='latin-1'))
size = int(num_lines / 1000)
skip_idx = random.sample(range(1, num_lines), num_lines - size)
tweet_data = pd.read_csv(f, skiprows=skip_idx, encoding='latin-1')

tweet_data.columns = ['target', 'id', 'date', 'flag', 'user', 'text']
target, text = tweet_data.iloc[:,0], tweet_data.iloc[:,5]

# Clean tweet data
text = cd.clean(text)

# Create train and test data
train, test = cd.train_test(target, text, 0.4)

