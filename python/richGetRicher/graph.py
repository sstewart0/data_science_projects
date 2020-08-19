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
        edge = set(edge)
        (vrtx1, vrtx2) = tuple(edge)
        if vrtx1 in self.gdict:
            self.gdict[vrtx1].append(vrtx2)
        else:
            self.gdict[vrtx1] = [vrtx2]

    def get_degree_dist(self):
        degree_dist = {}
        for vrtx in self.gdict:
            edges = self.gdict[vrtx]
            degree = len(edges)
            if degree not in degree_dist:
                degree_dist[degree] = 1
            else:
                degree_dist[degree] += 1
        return degree_dist

