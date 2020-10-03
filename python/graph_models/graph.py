import numpy as np
import powIter
import dijkstra
import networkx as nx
import matplotlib.pyplot as plt
import plotly.graph_objects as go


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

    # Draw an interactive network using plotly
    def draw_interactive_network(self, model):
        # Create graph
        G = nx.Graph()
        nodes = self.gdict.keys()
        edges = self.edges()
        G.add_nodes_from(nodes)
        G.add_edges_from(edges)

        # Layout for nodes
        pos = nx.spring_layout(G)

        # Create edge trace
        edge_x = []
        edge_y = []
        for edge in G.edges():
            char_1 = edge[0]
            char_2 = edge[1]
            x0, y0 = pos[char_1]
            x1, y1 = pos[char_2]
            edge_x.append(x0)
            edge_x.append(x1)
            edge_x.append(None)
            edge_y.append(y0)
            edge_y.append(y1)
            edge_y.append(None)

        edge_trace = go.Scatter(
            x=edge_x, y=edge_y,
            line=dict(width=0.5, color='#888'),
            hoverinfo='none',
            mode='lines')

        # Create node trace
        node_x = []
        node_y = []
        for node in G.nodes():
            x, y = pos[node]
            node_x.append(x)
            node_y.append(y)

        node_trace = go.Scatter(
            x=node_x, y=node_y,
            mode='markers',
            hoverinfo='text',
            marker=dict(
                showscale=True,
                colorscale='YlGnBu',
                reversescale=True,
                color=[],
                size=10,
                colorbar=dict(
                    thickness=15,
                    title='Node Connections',
                    xanchor='left',
                    titleside='right'
                ),
                line_width=2))

        node_adjacencies = []
        node_text = []
        for node, adjacencies in enumerate(G.adjacency()):
            node_adjacencies.append(len(adjacencies[1]))
            node_text.append('# of connections: ' + str(len(adjacencies[1])))

        node_trace.marker.color = node_adjacencies
        node_trace.text = node_text

        fig = go.Figure(data=(edge_trace, node_trace),
                        layout=go.Layout(
                            title='Barabasi-Albert Scale-Free Random Graph',
                            titlefont_size=16,
                            showlegend=False,
                            hovermode='closest',
                            margin=dict(b=20, l=5, r=5, t=40),
                            annotations=[dict(
                                showarrow=False,
                                xref="paper", yref="paper",
                                x=0.005, y=-0.002)],
                            xaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
                            yaxis=dict(showgrid=False, zeroline=False, showticklabels=False))
                        )
        fig.show()

    # Function to draw the network
    def draw_network(self, model,interactive=False):
        if interactive:
            self.draw_interactive_network(model)
        else:
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
