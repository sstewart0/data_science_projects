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
            vals, vec = np.linalg.eig(s)
            diag_vals = np.diag(vals)
            return vec.dot(np.linalg.matrix_power(diag_vals, walk_length)).dot(
                np.transpose(vec))
        else:
            print("Similarity matrix is not positive semi-definite")
    # if walk length is even we are guaranteed a valid (i.e. positive semi-definite) kernel
    else:
        vals, vec = np.linalg.eig(s)
        diag_vals = np.diag(vals)
        return vec.dot(np.linalg.matrix_power(diag_vals, walk_length)).dot(
            np.transpose(vec))


# Function that produces an exponential diffusion kernel using the provided similarity matrix s
def exp_diff_kernel(s, damping_factor):
    eigen_vals, eigen_vec = np.linalg.eig(s)
    # Eigenvalues are guaranteed to be non-negative => kernel is valid (pos semi-def)
    kernel_eigen_vals = np.array([math.exp(damping_factor*eig) for eig in eigen_vals])
    diag = np.diag(kernel_eigen_vals)
    return eigen_vec.dot(diag).dot(np.transpose(eigen_vec))


# Function that produces the Von Neumann Diffusion Kernel using the provided similarity matrix s
def von_neumann_diff_kernel(s, damping_factor):
    vals, vec = np.linalg.eig(s)
    spectral_radius = vals.flat[abs(vals).argmax()]
    if abs(damping_factor) < 1/spectral_radius:
        identity = np.identity(len(vals))
        diag_vals = np.diag(vals)
        diagonal = np.linalg.inv(identity - damping_factor*diag_vals)
        return vec.dot(diagonal).dot(np.transpose(vec))
    else:
        print("Damping factor must be smaller than ", 1/spectral_radius)
    return None


# Given a kernel matrix we can perform operations in the feature space without explicitly
# stating the map (from input to feature space) Ω : I -> F.
# We know that the valid kernel is equivalent to the inner product in some feature space F

# Function to compute norm in feature space
def norm(kernel):
    if kernel is not None:
        return np.array([[math.sqrt(x) if round(x, 5) > 0 else 0 for x in y] for y in kernel])
    else:
        print("Kernel is not valid")


# Function to compute the squared distances between all pairs of points in the feature space
def sq_distance(kernel):
    n, m = np.shape(kernel)
    distances = np.zeros((n, n))
    for i, row in enumerate(kernel):
        for j, element in enumerate(row):
            distances[i][j] = kernel[i][i]+kernel[j][j]-2*kernel[i][j]
    return distances


# Function to compute squared norm of the mean in the feature space
def sq_norm_mean(kernel):
    n, m = np.shape(kernel)
    return (1/n**2)*np.sum(kernel)


# Function to compute distance between each point and the mean in the feature space
def distance_to_mean(kernel):
    n, m = np.shape(kernel)
    a = (2/n)*np.sum(kernel, axis=1)
    b = (1/n**2)*np.ones((1, n))*np.sum(kernel)
    return np.diag(kernel)-a+b


# Function to compute the total variance in the feature space
def tot_var(kernel):
    n, m = np.shape(kernel)
    return (1/n)*np.sum(np.diag(kernel)) - (1/n**2)*np.sum(kernel)


# Function to produce a centred kernel matrix
def centred_kernel(kernel):
    n, m = np.shape(kernel)
    centring = np.identity(n) - (1/n)*np.ones((n, n))
    return centring.dot(kernel).dot(centring)


# Function to normalise the kernel matrix
def normalise_kernel(kernel):
    n, m = np.shape(kernel)
    diag = np.zeros((n, n))
    np.fill_diagonal(diag, np.diag(kernel))
    print(diag)
    normaliser = np.linalg.inv(np.sqrt(diag))
    print(normaliser)
    return normaliser.dot(kernel).dot(normaliser)
