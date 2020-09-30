import pandas as pd
import networkx as nx
import matplotlib.pyplot as plt
import matplotlib.colors as colors
import matplotlib.cm as cmx
import numpy as np
from sklearn.metrics import pairwise
from sklearn import preprocessing

# Read data
iris_data = pd.read_csv("iris.data")

# Scale numerical data
scaled_data = preprocessing.scale(iris_data.iloc[:, 0:4])
scaled_data = pd.DataFrame(scaled_data)

# Class labels
class_labels = iris_data.iloc[:, 4]

# Add label to scaled_data
scaled_data = pd.concat([scaled_data, class_labels], axis=1)

# Rename columns
scaled_data = scaled_data.rename(columns={0:'sepal_length',
                                          1:'sepal_width',
                                          2:'petal_length',
                                          3:'petal_width',
                                          'Iris-setosa':'class'})

# Radial basis function pairwise similarities
# Since all columns have s.d = 1 => choose gamma = 0.5 for rbf kernel similarity
gamma = 0.5
rbf_similarity = pairwise.pairwise_kernels(scaled_data.iloc[:,0:4], metric='rbf', gamma=gamma)

# Graph nodes
nodes = np.arange(start=1, stop=149, step=1, dtype=int)

# Labels for nodes
node_labels = {}
for node in nodes:
    node_labels[node] = scaled_data.loc[node,'class']

# Create graph
G_IRIS = nx.Graph()

G_IRIS.add_nodes_from(nodes)

pos = nx.circular_layout(G_IRIS)

# Edges to add to graph & weights for edge width's
edges = []
weights = []
for i in range(0, len(node_labels)):
    for j in range(i, len(node_labels)):
        if i != j:
            weight = round(rbf_similarity[i + 1, j + 1], 2)
            if weight > .5:
                weights.append(weight)
                edges.append(tuple((i+1, j+1, {'weight': weight})))

G_IRIS.add_edges_from(edges)

# Node colours
val_map = {'Iris-setosa': 1.0,
           'Iris-versicolor': 0.5714285714285714,
           'Iris-virginica': 0.0}

values = [val_map.get(node_labels[node]) for node in nodes]

jet = cm = plt.get_cmap('jet')
cNorm = colors.Normalize(vmin=0, vmax=max(values))
scalarMap = cmx.ScalarMappable(norm=cNorm, cmap=jet)

# Create legend
f = plt.figure(1)
ax = f.add_subplot(1,1,1)
for label in val_map:
    ax.plot([0],[0],color=scalarMap.to_rgba(val_map[label]),label=label)

# Draw graph
nx.draw_networkx_nodes(G_IRIS,pos, cmap = jet, vmin=0, vmax= max(values),
                       node_color=values,with_labels=False,ax=ax,node_size=60)

nx.draw_networkx_edges(G_IRIS,pos, cmap = jet, vmin=0, vmax= max(values),
                       width=weights, alpha=.3)

plt.axis('off')
f.set_facecolor('w')
plt.legend()
f.tight_layout()
plt.show()
