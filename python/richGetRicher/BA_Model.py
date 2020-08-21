import graph
import dijkstra
from scipy import stats
import numpy as np
import random


def initialise(n0):
    g_dict = {i: [] for i in range(1, n0+1)}
    # Each node has edges to its (immediate) left and right neighbour
    for i in range(1, n0+1):
        if i == 1:
            g_dict[i].append(n0)
            g_dict[i].append(2)
        elif i == n0:
            g_dict[i].append(n0-1)
            g_dict[i].append(1)
        else:
            g_dict[i].append(i-1)
            g_dict[i].append(i+1)
    return graph.Graph(g_dict)


def add_node(g, n_edges):
    # Generate degree distribution
    degree_dist = g.get_in_degree_dist()
    keys = degree_dist.keys()
    # Create the probability mass function for the nodes
    nodes = np.array([key for key in list(keys)], dtype=int)
    probs = np.array([degree_dist[key] for key in keys])
    pmf = stats.rv_discrete(name='pmf', values=(nodes, probs))
    # Create new node to attach neighbours to
    new_node = nodes.max()+1
    g.add_vertex(new_node)
    edges = g.edges()
    # Use the pmf to generate neighbour nodes (nodes with higher degrees are preferential)
    for _ in range(n_edges):
        while True:
            neighbour = pmf.rvs()
            if (new_node, neighbour) not in edges:
                g.add_edge((new_node, neighbour))
                break
    return g


def main():
    # Initialise graph with 10 nodes & 10 edges
    g = initialise(10)
    # Add new 10 nodes successively, each with 1<edges<5
    for _ in range(5):
        x = random.randint(1, 5)
        add_node(g, x)
    print(g.avg_path_length())


if __name__ == "__main__":
    main()
