"""
Feature engineering:
    -> 1. Count Vectors as features
    2. Word Embeddings as features
    3. Text / NLP based features
    4. Topic Models as features
"""
import pickle
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
from sklearn import preprocessing, metrics, linear_model
import numpy as np

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


# Convert names into a matrix of token counts:
def count_vec(ngram_range, max_f):
    """
    :param ngram_range: tuple
    :param max_f: int
    :return: CountVectorizer()
    """
    return CountVectorizer(lowercase=False, ngram_range=ngram_range, min_df=10,
                           max_features=max_f)


def train_model(classifier, x_train, x_test, y_train):
    """
    :param classifier: model
    :param x_train: train independent variables
    :param x_test: test independent variables
    :param y_train: train dependent variables
    :param y_test: test dependent variables
    :return:
    """
    classifier.fit(x_train, y_train)
    predictions = classifier.predict(x_test)
    return predictions


def choose_ngram_max_features():
    """
    :return: tuple, int
    """
    n_range = (1, 1)
    max_acc = 0
    max_f = 0
    for i in range(1, 4):
        for k in range(5, 11):
            l = k*100
            cv = count_vec((1, i), l)
            cv.fit(x_train)
            x_train_vec = cv.transform(x_train)
            x_test_vec = cv.transform(x_test)
            mod = train_model(linear_model.LogisticRegression(max_iter=200), x_train_vec, x_test_vec,
                              train.neighbourhood, test.neighbourhood)
            acc = metrics.accuracy_score(test.neighbourhood, mod)
            if max_acc < float(acc):
                max_acc = float(acc)
                n_range = (1, i)
                max_f = l
    return "ngram = {}, ".format(n_range)+"max features = {}, ".format(max_f)+"Accuracy = {}.".format(max_acc)


def main():
    cv = count_vec((1, 1), 600)
    cv.fit(x_train)
    x_train_vec = cv.transform(x_train)
    x_test_vec = cv.transform(x_test)
    mod = train_model(linear_model.LogisticRegression(max_iter=200), x_train_vec, x_test_vec,
                      train.neighbourhood, test.neighbourhood)
    print(metrics.f1_score(test.neighbourhood, mod))


if __name__ == "__main__":
    main()
