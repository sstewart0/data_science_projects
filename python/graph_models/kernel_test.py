import numpy as np
import BA_Model as ba
import kernels as krn


def main():
    network = ba.initialise(5)
    ba.add_n_nodes(network, 5)
    similarity_matrix = krn.sim_matrix(network, method="adj")

    kernel1 = krn.power_kernel(similarity_matrix, 2)
    kernel2 = krn.exp_diff_kernel(similarity_matrix, .1)
    kernel3 = krn.von_neumann_diff_kernel(similarity_matrix, .1)

    np.set_printoptions(suppress=True)

    '''
    print(np.round(krn.norm(kernel1), 2))
    print(np.round(krn.norm(kernel2), 2))
    print(np.round(krn.norm(kernel3), 2))
    
    print(np.round(krn.sq_distance(kernel1), 2))
    print(np.round(krn.sq_distance(kernel2), 2))
    print(np.round(krn.sq_distance(kernel3), 2))
    
    print(np.round(krn.sq_norm_mean(kernel1), 2))
    print(np.round(krn.sq_norm_mean(kernel2), 2))
    print(np.round(krn.sq_norm_mean(kernel3), 2))
    
    print(np.round(krn.distance_to_mean(kernel1), 2))
    print(np.round(krn.distance_to_mean(kernel2), 2))
    print(np.round(krn.distance_to_mean(kernel3), 2))
    
    print(np.round(krn.tot_var(kernel1), 2))
    print(np.round(krn.tot_var(kernel2), 2))
    print(np.round(krn.tot_var(kernel3), 2))
    
    print(np.round(krn.centred_kernel(kernel1), 2))
    print(np.round(krn.centred_kernel(kernel2), 2))
    print(np.round(krn.centred_kernel(kernel3), 2))
    
    print(np.round(krn.normalise_kernel(kernel1), 2))
    print(np.round(krn.normalise_kernel(kernel2), 2))
    print(np.round(krn.normalise_kernel(kernel3), 2))
    '''


if __name__ == "__main__":
    main()
