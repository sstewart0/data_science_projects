import numpy as np
import powIter
import dijkstra
import networkx as nx
import matplotlib.pyplot as plt


class Graph:
    def __init__(self, gdict=None):
        if gdict is None:
            gdict = {}
        self.gdict = gdict

    def get_vertices(self):
        return list(self.gdict.keys())

    def edges(self):
        return self.find_edges()

    def find_edges(self):
        edgename = []
        for vrtx in self.gdict:
            for nxtvrtx in self.gdict[vrtx]:
                if (nxtvrtx, vrtx) not in edgename:
                    edgename.append((vrtx, nxtvrtx))
        return edgename

    def add_vertex(self, vrtx):
        if vrtx not in self.gdict:
            self.gdict[vrtx] = []

    def add_edge(self, edge):
        (vrtx1, vrtx2) = tuple(edge)
        if vrtx1 in self.gdict:
            if vrtx2 not in self.gdict[vrtx1]:
                self.gdict[vrtx1].append(vrtx2)
        else:
            self.gdict[vrtx1] = [vrtx2]

    # Function to check if two nodes are adjacent (or not)
    def get_length(self, node, neighbour):
        edges = sorted(self.edges(), key=lambda tup: (tup[0], tup[1]))
        (a, b) = tuple(sorted([node, neighbour]))
        for edge in edges:
            (x, y) = tuple(edge)
            if x == a and y == b:
                return 1
        return -1

    # Function returns the adjacency matrix of the graph
    def adjacency_matrix(self, undirected):
        nodes = self.gdict.keys()
        n = len(nodes)
        adj = np.zeros((n, n), dtype=int)
        edges = self.edges()
        for edge in edges:
            (a, b) = tuple(edge)
            # Nodes are integers from 1 to n
            adj[a-1][b-1] = 1
            if undirected:
                adj[b-1][a-1] = 1
        return adj

    # Function returns the average path length of the graph
    def avg_path_length(self):
        distances = dijkstra.dijkstra(self)
        tot_nodes = len(self.gdict)
        mysum = 0
        for row in distances:
            for element in row:
                if element != -1:
                    mysum += element
        return round((1/(tot_nodes*(tot_nodes-1)))*mysum, 2)

    # Function returns the eccentricity of all nodes in the graph
    # The eccentricity of a node X is the maximum distance from X to any other node in the graph
    def eccentricity(self):
        distances = dijkstra.dijkstra(self)
        ecc = np.zeros(len(self.gdict), dtype=int)
        for i, row in enumerate(distances):
            ecc[i] = np.max(row)
        return ecc

    # Function returns the radius of the graph
    # The radius of a connected graph is the minimum eccentricity of any node in the graph
    def radius(self):
        eccentricity = self.eccentricity()
        return np.max(eccentricity)

    # Function returns the diameter of the graph
    # The diameter is the maximum eccentricity of any node in the graph
    def diameter(self):
        eccentricity = self.eccentricity()
        return np.min(eccentricity)

    # Efficiency of a pair of nodes X,Y is defined as 1/(distance(X,Y)).
    # The efficiency of a graph is the average efficiency over all pairs of nodes.
    def efficiency(self):
        n = len(self.gdict)
        distances = dijkstra.dijkstra(self)
        efficiency = 0
        for row in distances:
            for element in row:
                if element != 0:
                    efficiency += (1/element)
        return round(2*efficiency/(n*(n-1)), 2)

    # Centrality: How center/important nodes are
    # Eccentricity centrality of a node X is 1/eccentricity(X)
    def eccentricity_centrality(self):
        eccentricity = self.eccentricity()
        result = np.array([round(1/ecc, 2) for ecc in eccentricity])
        return result

    # Closeness centrality of a node X is 1/sum(distance(X,Y)) for all other nodes Y
    def closeness_centrality(self):
        distances = dijkstra.dijkstra(self)
        (nrow, ncol) = tuple(distances.shape)
        result = np.zeros(nrow)
        for i, row in enumerate(distances):
            for element in row:
                if element != -1:
                    result[i] += element
            result[i] = round(1/result[i], 2)
        return result

    # The clustering coefficient of a node X is a measure of the density of edges in the neighborhood of X
    def cluster_coeff(self, node):
        nodes = self.gdict
        sub_graph_nodes = nodes[node]
        num_nodes = len(sub_graph_nodes)
        num_edges = 0
        for vertex in sub_graph_nodes:
            num_edges += (len(nodes[vertex]) - 1)
        return 2 * num_edges / (num_nodes * (num_nodes - 1))

    # Generalizing the aforementioned notion to the entire graph yields the transitivity
    # of the graph. Informally, transitivity measures the degree to which a friend of your
    # friend is also your friend, say, in a social network.
    # The following function computes the global cluster coefficient (transitivity) for UNDIRECTED GRAPHS
    def transitivity(self, undirected):
        adj = self.adjacency_matrix(undirected)
        n = len(adj)
        denominator = 0
        numerator = 0
        a = 0
        for i in range(n):
            for j in range(n-i):
                a += adj[i][i+j]
            denominator += a*(a-1)
            for j in range(n):
                for k in range(n):
                    numerator += adj[i][j]*adj[j][k]*adj[k][i]
        if denominator == 0:
            return 0
        else:
            return round(numerator/denominator, 2)

    # FUNCTIONS FOR DIRECTED GRAPHS:
    # Web Centralities:
    # Function returns the authority scores for all nodes in the (directed) graph
    # Authority score: How many "good" nodes point to the given node
    def authority_score(self):
        adj = self.adjacency_matrix(False)
        adj_t = np.transpose(adj)
        ATA = adj.dot(adj_t)
        return powIter.power_iteration(ATA)

    # Function returns the hub scores for all nodes in the (directed) graph
    # Hub score: How many "good" nodes the given node points to
    def hub_score(self):
        adj = self.adjacency_matrix(False)
        adj_t = np.transpose(adj)
        AAT = adj_t.dot(adj)
        return powIter.power_iteration(AAT)

    # Function to get diagonal degree matrix
    def degree_matrix(self):
        nodes = self.gdict
        n = len(nodes)
        degree = np.zeros((n, n), dtype=int)
        for i, node in enumerate(nodes):
            edges = nodes[node]
            degree_i = len(edges)
            degree[i][i] = degree_i
        return degree

    # In undirected graphs {degree = in-degree = out-degree}
    # Function returns the out-degree distribution of the graph
    def get_out_degree_dist(self):
        degree_dist = {}
        tot_degree = len(self.edges())
        for vrtx in self.gdict:
            edges = self.gdict[vrtx]
            degree = len(edges)
            degree_dist[vrtx] = (degree / tot_degree)
        return degree_dist

    # Function returns the in-degree distribution of the graph
    def get_in_degree_dist(self):
        degree_dist = {}
        tot_degree = len(self.edges())
        edges = self.edges()
        for edge in edges:
            (x, y) = tuple(edge)
            if y in degree_dist:
                degree_dist[y] += 1
            else:
                degree_dist[y] = 1
        for key in degree_dist.keys():
            degree_dist[key] /= tot_degree
        return degree_dist

    # Function to draw the network
    def draw_network(self, model):
        if model == "BA":
            # Build networkx graph
            g = nx.Graph()
            nodes = self.gdict.keys()
            edges = self.edges()
            g.add_nodes_from(nodes)
            g.add_edges_from(edges)
            # Get node degrees
            node_and_degree = g.degree()
            node_sizes = np.array([degree**2 for (node, degree) in node_and_degree], dtype=int)
            # Create circular layout
            pos = nx.spring_layout(g)
            nx.draw(g, pos, node_color="b", with_labels=False)
            # Intensity of node colour dependent on node degree (i.e. higher degree => darker colour)
            options = {"nodelist": nodes, "node_color": node_sizes, "cmap": plt.cm.Blues}
            nx.draw_networkx_nodes(g, pos, **options)
            plt.show()
