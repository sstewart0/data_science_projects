import pandas as pd
from sklearn.model_selection import train_test_split

import nltk

# All data
bnb_data = pd.read_csv("../../AB_NYC_2019.csv")

# Manhattan data
bnb_manhattan = bnb_data.loc[bnb_data['neighbourhood_group'] == 'Manhattan']

# Neighbourhoods
nbhds = bnb_manhattan['neighbourhood'].unique()
num_nbhds = len(nbhds)

# Create random train and test set (reproducible)
X = bnb_manhattan['name']
y = bnb_manhattan['neighbourhood']

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.15, random_state=42)

for i in y_train.index:
    title = X_train.loc[i]
    title_list = title.split(" ")
    fd = nltk.FreqDist(title_list)
    print(title_list)
    print(fd.most_common())
    break