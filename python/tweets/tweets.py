import pandas as pd
import numpy as np
import clean_data as cd
import random
from keras_preprocessing.text import Tokenizer
from keras import Sequential, initializers, regularizers, layers, utils, Input

f = 'tweet_data.csv'
num_lines = sum(1 for _ in open(f, encoding='latin-1'))
size = int(num_lines / 1000)
skip_idx = random.sample(range(1, num_lines), num_lines - size)
tweet_data = pd.read_csv(f, skiprows=skip_idx, encoding='latin-1')

tweet_data.columns = ['target', 'id', 'date', 'flag', 'user', 'text']

tweet_data.loc[tweet_data['target'] == 2, 'target'] = 1
tweet_data.loc[tweet_data['target'] == 4, 'target'] = 2

target, text = tweet_data.iloc[:,0], tweet_data.iloc[:,5]

text = cd.clean(text) # Clean tweet data

train, test, validate = cd.train_test(text, target) # Create train and test data

# Create matrix for model
num_words_keep = 1000
tokenizer = Tokenizer(num_words=num_words_keep,filters='',lower=False,split=' ',
                      char_level=False, oov_token=None)

train_tweets = train.iloc[:,0]
train_target = train.iloc[:,1]

tokenizer.fit_on_texts(texts=train_tweets)

modes = ['binary', 'count', 'tfidf', 'freq']
encoded_tweets = tokenizer.texts_to_matrix(train_tweets, mode=modes[1])

# Implement model
model = Sequential()

activation_functions = ['relu','sigmoid','tanh']

initialiser = initializers.GlorotNormal(seed=1) # Mitigating risk of vanishing/exploding gradients

reg_constant1 = 0.01
l2_regulariser = regularizers.l2(l=reg_constant1)

# Add dropout layer?

layer1 = layers.Dense(
    units = 3,
    activation= activation_functions[1],
    use_bias=True,
    kernel_initializer=initialiser,
    bias_initializer='zeros',
    kernel_regularizer=l2_regulariser,
    bias_regularizer=None,
    activity_regularizer=None,
    kernel_constraint=None,
    bias_constraint=None,
)

model.add(Input(shape=(1000,)))
model.add(layer1)

model.compile(optimizer='Adam',
              loss='categorical_crossentropy',
              metrics=['accuracy', 'AUC'])

x_validate = validate.iloc[:,0]
x_validate = tokenizer.texts_to_matrix(x_validate)

y_validate = validate.iloc[:,1]

y_train = utils.to_categorical(train_target, num_classes=3)
y_validate = utils.to_categorical(y_validate, num_classes=3)

model.fit(x=encoded_tweets,
          y=y_train,
          batch_size=32,
          epochs=10,
          verbose=2, #one line per epoch
          validation_data=(x_validate,y_validate),
          shuffle=True,
          validation_freq=2)
