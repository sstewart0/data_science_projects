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

    def get_length(self, node, neighbour):
        edges = self.edges()
        for edge in edges:
            (x, y) = tuple(edge)
            if (x == node) & (y == neighbour):
                return 1
        return -1

    def get_out_degree_dist(self):
        degree_dist = {}
        tot_degree = len(self.edges())
        for vrtx in self.gdict:
            edges = self.gdict[vrtx]
            degree = len(edges)
            degree_dist[vrtx] = (degree/tot_degree)
        return degree_dist

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

    def adjacency_matrix(self):
        nodes = self.gdict.keys()
        n = len(nodes)
        adj = np.zeros((n, n), dtype=int)
        edges = self.edges()
        for edge in edges:
            (a, b) = tuple(edge)
            adj[a-1][b-1] = 1
        return adj

    def authority_score(self):
        adj = self.adjacency_matrix()
        adj_t = np.transpose(adj)
        ATA = adj.dot(adj_t)
        return powIter.power_iteration(ATA)

    def hub_score(self):
        adj = self.adjacency_matrix()
        adj_t = np.transpose(adj)
        AAT = adj_t.dot(adj)
        return powIter.power_iteration(AAT)

    def avg_path_length(self):
        distances = dijkstra.dijkstra(self)
        tot_nodes = len(self.gdict)
        mysum = 0
        for row in distances:
            for element in row:
                if element != -1:
                    mysum += element
        return (1/(tot_nodes*(tot_nodes-1)))*mysum

    # def cluster_coeff(self):

    # def transitivity(self):


