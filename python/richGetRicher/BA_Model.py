import graph


def initialise(n0):
    """
    :param n0: number of nodes & edges
    :return: graph with n0 nodes and n0 edges
    """
    g_dict = {i: [] for i in range(1, n0+1)}
    # Each node has edges to its (immediate) left and right neighbour
    for i in range(1, n0+1):
        if i == 1:
            g_dict[i].append(n0-1)
            g_dict[i].append(2)
        elif i == n0:
            g_dict[i].append(n0-1)
            g_dict[i].append(1)
        else:
            g_dict[i].append(i-1)
            g_dict[i].append(i+1)
    return graph.Graph(g_dict)


def new_node(g):
    """
    :param g: graph object
    :return: updated graph object
    """


def main():
    g = initialise(10)
    print(g.get_degree_dist())


if __name__ == "__main__":
    main()
