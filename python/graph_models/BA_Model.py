# The Barabasi–Albert (BA) algorithm generates random scale-free networks using a preferential attachment
# mechanism for adding nodes. That is, nodes with higher in-degrees are preferential, for this reason the model
# is also known as the rich get richer approach.

import graph
import dijkstra
from scipy import stats
import numpy as np
import random


# Function that initialises an UNDIRECTED BA Model with n0 nodes.
# Each node has (in & out) degree 2, being connected to its left and right neighbors in a circular layout.
def initialise(n0):
    g_dict = {i: [] for i in range(1, n0+1)}
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


# Function that adds nodes using preferential attachment mechanism
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
    edges = sorted(g.edges(), key=lambda tup: (tup[0], tup[1]))
    # Use the pmf to generate neighbour nodes (nodes with higher in-degrees are preferential)
    for _ in range(n_edges):
        while True:
            neighbour = pmf.rvs()
            (a, b) = tuple(sorted([neighbour, new_node]))
            if (a, b) not in edges:
                # Edges are undirected so each node is the others neighbour
                g.add_edge((a, b))
                g.add_edge((b, a))
                edges = sorted(g.edges(), key=lambda tup: (tup[0], tup[1]))
                break
    return g


def add_n_nodes(g, n_nodes):
    for _ in range(n_nodes):
        num_nodes = len(g.get_vertices())
        x = random.randint(1, num_nodes - 1)
        add_node(g, x)


def main():
    # Initialise graph with X nodes & X edges
    print("The Barabasi–Albert (BA) algorithm generates random scale-free networks \nusing a preferential attachment "
          "mechanism for adding nodes. \nThat is, nodes with higher in-degrees are preferential, \n"
          "for this reason the model is also known as the rich get richer approach.")
    g = initialise(int(input("Enter number of nodes to initialise BA model with: ")))
    # Add new nodes successively, each with random degree.
    for i in range(int(input("Enter number of iterations: "))):
        num_nodes = len(g.get_vertices())
        x = random.randint(1, num_nodes-1)
        add_node(g, x)
        # print("Hub score for nodes at time", i, " \n= ", g.hub_score())
    """print("High degree hubs begin to emerge as expected.")
    print("Graph vertices = ", g.get_vertices())
    print("Graph edges = ", g.edges())
    print("Average path length of graph = ", g.avg_path_length())
    print("Eccentricity for all nodes = ", g.eccentricity())
    print("Radius of graph = ", g.radius())
    print("Diameter of graph = ", g.diameter())
    print("Efficiency of graph = ", g.efficiency())
    print("Eccentricity centrality for all nodes = ", g.eccentricity_centrality())
    print("Closeness centrality for all nodes = ", g.closeness_centrality())
    print("Adjacency matrix of graph = \n", g.adjacency_matrix(undirected=True))
    print("Transitivity (global cluster co-eff) of graph = ", g.transitivity(undirected=True))"""
    g.draw_network(model="BA", interactive=True)


if __name__ == "__main__":
    main()
