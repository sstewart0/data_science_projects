import numpy as np


def find_min(q, arr):
    mini = 999999
    min_node = 0
    for node in q:
        if (arr[node-1] > -1) & (arr[node-1] < mini):
            mini = arr[node-1]
            min_node = node
    return min_node


def dijkstra(g):
    nodes = g.gdict.keys()
    vertices = np.array([node for node in nodes], dtype=int)
    n = len(vertices)
    dist = np.zeros((n, n), dtype=int)
    for start in vertices:
        q = np.array([start], dtype=int)
        for vertex in vertices:
            # Nodes are integers from 1 to (n+1)
            dist[start-1][vertex-1] = -1
            if vertex != start:
                q = np.append(q, [vertex])
        dist[start-1][start-1] = 0
        while len(q) > 0:
            cur = find_min(q, dist[start-1])
            if cur == 0:
                cur = q[0]
                q = np.delete(q, 0)
            else:
                index = np.where(q == cur)
                q = np.delete(q, index)
            for nhbr in q:
                length = g.get_length(cur, nhbr)
                if dist[start-1][cur-1] == -1:
                    alt = length
                else:
                    alt = dist[start-1][cur-1] + length
                if length != -1:
                    if (alt < dist[start-1][nhbr-1]) or (dist[start-1][nhbr-1] == -1):
                        dist[start-1][nhbr-1] = alt
    return dist
