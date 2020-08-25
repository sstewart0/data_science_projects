import numpy as np
import powIter
import dijkstra


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
                edgename.append((vrtx, nxtvrtx))
        return edgename

    def add_vertex(self, vrtx):
        if vrtx not in self.gdict:
            self.gdict[vrtx] = []

    def add_edge(self, edge):
        edge = set(edge)
        (vrtx1, vrtx2) = tuple(edge)
        if vrtx1 in self.gdict:
            self.gdict[vrtx1].append(vrtx2)
        else:
            self.gdict[vrtx1] = [vrtx2]

    # Function to check if two nodes are adjacent (or not)
    def get_length(self, node, neighbour):
        edges = self.edges()
        for edge in edges:
            (x, y) = tuple(edge)
            if (x == node) & (y == neighbour):
                return 1
        return -1

    # In undirected graphs {degree = in-degree = out-degree}
    # Function returns the out-degree distribution of the graph
    def get_out_degree_dist(self):
        degree_dist = {}
        tot_degree = len(self.edges())
        for vrtx in self.gdict:
            edges = self.gdict[vrtx]
            degree = len(edges)
            degree_dist[vrtx] = (degree/tot_degree)
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

    # Function returns the adjacency matrix of the graph
    def adjacency_matrix(self):
        nodes = self.gdict.keys()
        n = len(nodes)
        adj = np.zeros((n, n), dtype=int)
        edges = self.edges()
        for edge in edges:
            (a, b) = tuple(edge)
            # Nodes are integers from 1 to n
            adj[a-1][b-1] = 1
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
        return (1/(tot_nodes*(tot_nodes-1)))*mysum

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
        return 2*efficiency/(n*(n-1))

    # Centrality: How center/important nodes are
    # Eccentricity centrality of a node X is 1/eccentricity(X)
    def eccentricity_centrality(self):
        eccentricity = self.eccentricity()
        result = np.array([1/ecc for ecc in eccentricity])
        return result

    # Closeness centrality of a node X is 1/sum(distance(X,Y)) for all other nodes Y
    def closeness_centrality(self):
        distances = dijkstra.dijkstra(self)
        (nrow, ncol) = tuple(distances.shape)
        result = np.array(nrow)
        for i, row in enumerate(distances):
            for element in row:
                if element != -1:
                    result[i] += element
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
    def transitivity(self):
        adj = self.adjacency_matrix()
        n = len(adj)
        denominator = 0
        numerator = 0
        for i in range(n):
            k = 0
            for j in range(n - i):
                k += adj[i][i + j]
            denominator += k * (k - 1)
            for j in range(n):
                for k in range(n):
                    numerator += adj[i][j] * adj[j][k] * adj[k][i]
        if denominator == 0:
            return 0
        else:
            return numerator / denominator

    # FUNCTIONS FOR DIRECTED GRAPHS:
    # Web Centralities:
    # Function returns the authority scores for all nodes in the (directed) graph
    # Authority score: How many "good" nodes point to the given node
    def authority_score(self):
        adj = self.adjacency_matrix()
        adj_t = np.transpose(adj)
        ATA = adj.dot(adj_t)
        return powIter.power_iteration(ATA)

    # Function returns the hub scores for all nodes in the (directed) graph
    # Hub score: How many "good" nodes the given node points to
    def hub_score(self):
        adj = self.adjacency_matrix()
        adj_t = np.transpose(adj)
        AAT = adj_t.dot(adj)
        return powIter.power_iteration(AAT)
