# Database manipulation
import pandas as pd
# linear Algebra
import numpy as np
# Statistical learning
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import confusion_matrix
from sklearn.metrics import classification_report
from sklearn.utils import resample
# Plotting
import matplotlib.pyplot as plt
# Core library
import itertools

data = pd.read_csv('~/Downloads/HR_comma_sep.csv')

# Avg Performance
avg_performance = np.mean(data.last_evaluation)
print("The average performance is: ", avg_performance)

# New feature: left & high performing
data['left2'] = 0
data.loc[(data.left == 1) & (data.last_evaluation > avg_performance),'left2'] = 1

# Convert salary to integer:
cat = pd.Categorical(data['salary'], categories=['low', 'medium', 'high'])
codes, uniques = pd.factorize(cat)

data['salary2'] = codes

# Remove sales, salary & left features
data = data.drop(['sales','salary', 'left'],axis=1)

print("{x} high performers left".format(x=len(data[data.left2 == 1])))
print("{y} employees stayed (or left but were low performers)".format(y=len(data[data.left2 == 0])))

# Create a random subset of 80% of the data to train the model
msk = np.random.rand(len(data)) < 0.8

train = data[msk]
test = data[~msk]

# Upsample the minority group, i.e. high earners who left
majority = train[train.left2 == 0]
minority = train[train.left2 == 1]

upsampled_minority = resample(minority,
                              replace=True,
                              n_samples=len(majority),
                              random_state=123)

upsampled_train = pd.concat([majority, upsampled_minority])

X_train_upsampled = upsampled_train.loc[:, upsampled_train.columns != 'left2'].to_numpy()
y_train_upsampled = upsampled_train['left2'].to_numpy()

# Create train and test data
X_train = train.loc[:, train.columns != 'left2'].to_numpy()
y_train = train['left2'].to_numpy()

X_test = test.loc[:, test.columns != 'left2'].to_numpy()
y_test = test['left2'].to_numpy()

# rf classifier model: why? non-linear decision boundaries clear from analysis
model = RandomForestClassifier(random_state=1,
                               verbose=1,
                               oob_score=True)

cols = ['satisfaction_level', 'last_evaluation', 'number_project', 'average_montly_hours',
        'time_spend_company', 'Work_accident', 'promotion_last_5years','salary2']

# fit the model
model.fit(X_train_upsampled, y_train_upsampled)

# get importance
importance = model.feature_importances_

# summarize feature importance
feat_imp = {}
for i, imp in enumerate(importance):
    feat_imp[cols[i]] = imp

sorted_imps = {k:v for k,v in sorted(feat_imp.items(), key = lambda x: x[1],reverse=True)}

for i in sorted_imps.keys():
    print("Feature {f} has importance {imp}".format(
        f=i, imp=round(sorted_imps[i], 4)
    ))

# Model predictions
predictions = model.predict(X_test)

# Confusion matrix
def plot_confusion_matrix(cm, classes, title='Confusion matrix', cmap=plt.cm.Blues):

    cm = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis]

    plt.imshow(cm, interpolation='nearest', cmap=cmap)
    plt.title(title, fontsize=16)
    plt.colorbar()
    tick_marks = np.arange(len(classes))
    plt.xticks(tick_marks, classes, rotation=90, fontsize=16)
    plt.yticks(tick_marks, classes, fontsize=16)

    fmt = '.2f'
    thresh = cm.max() / 2.
    for i, j in itertools.product(range(cm.shape[0]), range(cm.shape[1])):
        plt.text(j, i, format(cm[i, j], fmt),
                 horizontalalignment="center",
                 color="white" if cm[i, j] > thresh else "black")

    plt.ylabel('True label', fontsize=16)
    plt.xlabel('Predicted label', fontsize=16)

# Plot confusion matrix
cnf_matrix = confusion_matrix(y_test, predictions)
plt.figure(figsize=(8,8))
plot_confusion_matrix(cm=cnf_matrix, classes=['Stayed','Left'])
plt.show()
plt.close()

# Model results
print(classification_report(y_test,predictions))

# Can we make employees stay by giving them less work (and paying them more)?
X_test2 = test.loc[:, test.columns != 'left2']
X_test2 = X_test2.loc[(data.left2 == 1) & (data.satisfaction_level < .2)]

# Decrease workload
X_test2['average_montly_hours'] -= 50
X_test2['number_project'] -= 2

# Increase salary
X_test2['salary2'] = np.array([x+1 if x < 2 else x for x in X_test2['salary2']])

X_test2 = X_test2.to_numpy()

y_test2 = test['left2']
y_test2 = y_test2.loc[data.left2 == 1].to_numpy()

# Make new predictions
pred2 = model.predict(X_test2)

print("Of the {x} high performers who were going to leave we were able to keep {y} by "
      "decreasing their workload and increasing their salary".format(x=len(pred2), y=np.sum(pred2)))
