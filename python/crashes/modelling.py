import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report
from sklearn.utils import resample
from imblearn.over_sampling import SMOTE
from sklearn.decomposition import PCA

pd.set_option('display.max_columns', 1000)

data = pd.read_csv('new_collisions.csv',index_col=0)

msk = np.random.rand(len(data)) < 0.8

train = data[msk]
test = data[~msk]

majority = train[train.fatal == 0]
minority = train[train.fatal == 1]

upsampled_minority = resample(minority,
                              replace=True,
                              n_samples=len(majority),
                              random_state=123)

upsampled_train = pd.concat([majority,upsampled_minority])

X_train_upsampled = upsampled_train.loc[:, upsampled_train.columns != 'fatal'].to_numpy()
y_train_upsampled = upsampled_train['fatal'].to_numpy()

X_train = train.loc[:, train.columns != 'fatal'].to_numpy()
y_train = train['fatal'].to_numpy()

X_test = test.loc[:, test.columns != 'fatal'].to_numpy()
y_test = test['fatal'].to_numpy()

oversample = SMOTE()
X_train_smote, y_train_smote = oversample.fit_resample(X_train, y_train)

neg = len(majority)
pos = len(minority)
total = neg + pos

weight_for_0 = (1 / neg)*(total)/2.0
weight_for_1 = (1 / pos)*(total)/2.0


# rf classifier model
model = RandomForestClassifier(random_state=1,
                               verbose=1,
                               oob_score=True,
                               class_weight={1:weight_for_1,0:weight_for_0})

pca = PCA(n_components=len(data.columns)-1)

pca.fit(data.loc[:, data.columns != 'fatal'])

print(pca.explained_variance_ratio_)


"""# fit the model
model.fit(X_train_upsampled, y_train_upsampled)

# get importance
importance = model.feature_importances_

# summarize feature importance
cols = list(data.columns)

for i, imp in enumerate(importance):
    print("Feature {f} has importance {imp}".format(
        f=cols[i],imp=imp
    ))

predictions = model.predict(X_test)
print(classification_report(y_test,predictions))"""
