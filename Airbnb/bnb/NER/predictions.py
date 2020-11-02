"""
Feature engineering:
    -> 1. Count Vectors as features
    2. Word Embeddings as features
    3. Text / NLP based features
    4. Topic Models as features
"""
import pickle
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
from sklearn import preprocessing, metrics, linear_model, svm, discriminant_analysis as dc
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sn
import pandas as pd

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
    return CountVectorizer(lowercase=False, ngram_range=ngram_range, min_df=10,
                           max_features=max_f)


def pred(classifier, x_train, x_test, y_train):
    classifier.fit(x_train, y_train)
    predictions = classifier.predict(x_test)
    return predictions


def choose_ngram_max_features():
    n_range = (1, 1)
    max_acc = 0
    max_f = 0
    for i in range(1, 4):
        for k in range(1, 7):
            l = k*100
            cv = count_vec((1, i), l)
            cv.fit(x_train)
            x_train_vec = cv.transform(x_train)
            x_test_vec = cv.transform(x_test)
            y_pred = pred(linear_model.LogisticRegression(max_iter=200), x_train_vec, x_test_vec,
                          train.neighbourhood)
            acc = metrics.accuracy_score(test.neighbourhood, y_pred)
            if max_acc < float(acc):
                max_acc = float(acc)
                n_range = (1, i)
                max_f = l
    return "ngram = {}, ".format(n_range)+"max features = {}, ".format(max_f)+"Accuracy = {}.".format(max_acc)

def plot_f1(models, f1_scores):
    x = np.arange(len(f1_scores))
    fig, ax = plt.subplots()
    plot = ax.bar(x, f1_scores)
    ax.set_ylabel('F1-Score')
    ax.set_xlabel('Model')
    ax.set_title('F1 scores for multiple models')
    ax.set_xticks(x)
    ax.set_xticklabels(models)
    fig.tight_layout()
    plt.xticks(rotation=90)
    plt.show()



def main():
    # Fit Count Vectorizer to training titles
    cv = count_vec((1, 1), 600)
    cv.fit(x_train)
    x_train_vec = cv.transform(x_train)
    x_test_vec = cv.transform(x_test)

    """"# Logistic Regression
    y_pred = pred(linear_model.LogisticRegression(max_iter=200), x_train_vec, x_test_vec,
                  train.neighbourhood)
    logr_f1 = metrics.f1_score(test.neighbourhood, y_pred, average='weighted')
    logr_acc = metrics.accuracy_score(test.neighbourhood, y_pred)
    print("Logistic Regression accuracy = {acc}, f1-score = {f1}".format(acc=logr_acc, f1=logr_f1))

    conf_matrix = metrics.confusion_matrix(test.neighbourhood, y_pred)
    y_encoded = sorted(train.neighbourhood.unique())
    labels = encoder.inverse_transform(y_encoded)

    df_cm = pd.DataFrame(conf_matrix, index=labels,
                         columns=labels)
    plt.figure(figsize=(10, 7))
    sn.heatmap(df_cm, annot=False)

    plt.show()

    # Unweighted SCV
    svc = svm.SVC(kernel='linear')
    svc.fit(x_train_vec, train.neighbourhood)
    svc_pred = svc.predict(x_test_vec)

    svc_f1 = metrics.f1_score(test.neighbourhood, svc_pred, average='weighted')
    svc_acc = metrics.accuracy_score(test.neighbourhood, svc_pred)
    print("Unweighted SVC accuracy = {acc}, f1-score = {f1}".format(acc=svc_acc, f1=svc_f1))

    # Weighted SVS
    wsvc = svm.SVC(kernel='linear', class_weight='balanced')
    wsvc.fit(x_train_vec, train.neighbourhood)
    wsvc_pred = wsvc.predict(x_test_vec)

    wsvc_f1 = metrics.f1_score(test.neighbourhood, wsvc_pred, average='weighted')
    wsvc_acc = metrics.accuracy_score(test.neighbourhood, wsvc_pred)
    print("Weighted SVC accuracy = {acc}, f1-score = {f1}".format(acc=wsvc_acc, f1=wsvc_f1))

    # Unweighted rbf SVM
    svm_rbf = svm.SVC(kernel='rbf')
    svm_rbf.fit(x_train_vec, train.neighbourhood)
    svm_rbf_pred = svm_rbf.predict(x_test_vec)

    svm_f1 = metrics.f1_score(test.neighbourhood, svm_rbf_pred, average='weighted')
    svm_acc = metrics.accuracy_score(test.neighbourhood, svm_rbf_pred)
    print("Unweighted RBF SVM accuracy = {acc}, f1-score = {f1}".format(acc=svm_acc, f1=svm_f1))"""

    # Weighted rbf SVM
    wsvm_rbf = svm.SVC(kernel='rbf', class_weight='balanced')
    wsvm_rbf.fit(x_train_vec, train.neighbourhood)
    wsvm_rbf_pred = wsvm_rbf.predict(x_test_vec)

    wsvm_f1 = metrics.f1_score(test.neighbourhood, wsvm_rbf_pred, average='weighted')
    wsvm_acc = metrics.accuracy_score(test.neighbourhood, wsvm_rbf_pred)
    print("Weighted RBF SVM accuracy = {acc}, f1-score = {f1}".format(acc=wsvm_acc, f1=wsvm_f1))

    conf_matrix = metrics.confusion_matrix(test.neighbourhood, wsvm_rbf_pred)
    y_encoded = sorted(train.neighbourhood.unique())
    labels = encoder.inverse_transform(y_encoded)

    df_cm = pd.DataFrame(conf_matrix, index=labels,
                         columns=labels)
    plt.figure(figsize=(10, 7))
    sn.heatmap(df_cm, annot=False)

    plt.show()

    """fpr, tpr, thresholds = metrics.roc_curve(test.neighbourhood, wsvm_rbf_pred, pos_label=2)
    print(metrics.auc(fpr, tpr))

    models = np.array(["Logistic Regression", "SVC", "Weighted SCV", "RBF SVM", "Weighted RBF SVM"])
    f1_scores = np.array([logr_f1, svc_f1, wsvc_f1, svm_f1, wsvm_f1])

    print(plot_f1(models, f1_scores))"""




if __name__ == "__main__":
    main()
