"""
The 'Power Iteration Method' is a recursive algorithm that finds the
dominant eigenvalue and eigenvector pair of a matrix.
"""
import numpy as np


def power_iteration(mat):
    n = mat.shape[0]
    pk = np.ones((n, 1))
    for _ in range(0, 10):
        pn = np.dot(mat, pk)
        pk = pn / np.linalg.norm(pn)
    return pn
