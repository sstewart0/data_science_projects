import numpy as np
import graph
import math

adjacency = ["adj", "a", "adjacency"]
laplacian = ["lapl", "lap", "laplacian", "l"]


# Function to choose similarity matrix
def sim_matrix(g, method):
    if method in adjacency:
        return g.adjacency_matrix(undirected=True)
    elif method in laplacian:
        degree = g.degree_matrix()
        adj = g.adjacency_matrix(undirected=True)
        return adj - degree


# Function to check symmetry of matrix s
def is_symmetric(s):
    s_transpose = np.transpose(s)
    if (s == s_transpose).all():
        return True
    return False


# Function to test positive semi-definiteness of similarity matrix s
def is_pos_semi_def(s):
    symmetric = is_symmetric(s)
    eig_vals = np.linalg.eigvals(s)
    rounded_eigs = np.array([round(eigenvalue, 3) for eigenvalue in eig_vals])
    pos_eigen = np.all(rounded_eigs >= 0)
    if symmetric and pos_eigen:
        return True
    return False


# Function that produces a power kernel using the provided similarity matrix s
def power_kernel(s, walk_length):
    # If walk length is odd then check that s is positive semi-definite for a valid kernel
    odd_length = walk_length % 2 == 0
    pos_semi_def = is_symmetric(s)
    if odd_length:
        if pos_semi_def:
            return np.linalg.matrix_power(s, walk_length)
        else:
            print("Similarity matrix is not positive semi-definite")
    # if walk length is even we are guaranteed a valid (i.e. positive semi-definite) kernel
    else:
        return np.linalg.matrix_power(s, walk_length)


# Function that produces an exponential diffusion kernel using the provided similarity matrix s
def exp_diff_kernel(s, damping_factor):
    eigen_vals, eigen_vec = np.linalg.eig(s)
    # Eigenvalues are guaranteed to be non-negative => kernel is valid (pos semi-def)
    kernel_eigen_vals = np.array([math.exp(damping_factor*eig) for eig in eigen_vals])
    diag = np.diag(kernel_eigen_vals)
    return eigen_vec.dot(diag).dot(np.transpose(eigen_vec))


# Function that produces the Von Neumann Diffusion Kernel using the provided similarity matrix s
def von_neumann_diff_kernel(s, damping_factor):
    eigen_vals = np.linalg.eigvals(s)
    n = len(eigen_vals)
    spectral_radius = eigen_vals.flat[abs(eigen_vals).argmax()]
    if abs(damping_factor) < 1/spectral_radius:
        return np.linalg.inv(np.identity(n) - s*damping_factor)
    else:
        print("Damping factor must be smaller than ", 1/spectral_radius)
    return None
