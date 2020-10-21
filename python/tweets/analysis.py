import pandas as pd

tweet_data = pd.read_csv('tweet_data.csv', encoding='latin1')

nrow = tweet_data.shape[0]
ncol = tweet_data.shape[1]

tweet_data.columns = ['target', 'id', 'date', 'flag', 'user', 'text']



