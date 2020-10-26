import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

bnb_data = pd.read_csv('airbnb.csv')

print(bnb_data.columns)

counts = bnb_data[['id','nbhd_ids']].groupby(['nbhd_ids']).agg(['count'])

counts = np.sort(np.array([x for x in counts.iloc[:,0]]))

"""n, bins, patches = plt.hist(counts, bins=[10*i for i in range(0, 400)])

plt.xlabel('NBHD Count')
plt.ylabel('Density')
plt.title('Histogram')
plt.grid(True)

plt.show()"""

aggr = {
        'price':'median'
        }

df = pd.DataFrame({'count': bnb_data.groupby(["nbhd_ids"]).size()}).reset_index()
df2 = bnb_data[['nbhd_ids', 'price']].groupby(['nbhd_ids']).agg(aggr)

df['price'] = df2['price'].tolist()

names = [name.replace('_',' ') for name in df['nbhd_ids'].tolist()]
print(names)
# Create bins with equal 'area'
