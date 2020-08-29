import numpy as np
import BA_Model as ba
import kernels as krn


def main():
    network = ba.initialise(5)
    ba.add_n_nodes(network, 5)
    similarity_matrix = krn.sim_matrix(network, method="adj")
    kernel = krn.von_neumann_diff_kernel(similarity_matrix, .1)



if __name__ == "__main__":
    main()
