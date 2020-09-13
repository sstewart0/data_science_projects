import numpy as np
import pandas as pd
from keras import Sequential, initializers, regularizers
from tensorflow.keras import layers


train_csv = pd.read_csv('./house-prices-advanced-regression-techniques/train.csv')
train_data = pd.DataFrame(train_csv)

# FULL TRAIN DATA ---> [TRAIN (50%), VALIDATE (25%), TEST (25%)]

# Initialise model that we will add layers to:
model = Sequential()

# Activation functions
acts = ['relu','sigmoid','tanh']

# Initialise weights with w ~ N(mean1, sd1)
mean1, sd1 = 0,  0.1
norm_init = initializers.RandomNormal(mean=mean1,
                                      stddev=sd1,
                                      seed=123)

# Initialise weights with w ~ UNIF(lower_bound, upper_bound)
lower_bound, upper_bound = -.5, .5
unif_init = initializers.RandomUniform(minval=lower_bound,
                                       maxval=upper_bound,
                                       seed=123)

# Kernel L2 Regulariser: reg_constant1 is our regularisation constant
reg_constant1 = 0.01
l2_regulariser = regularizers.l2(l=reg_constant1)

# Kernel L1 Regulariser: reg_constant2 is our regularisation constant
reg_constant2 = 0.01
l1_regulariser = regularizers.l1(l=reg_constant2)

# Kernel L1-L2 Regulariser: reg_constant2 is our regularisation constant
l1_l2_regulariser = regularizers.l1_l2(l1=reg_constant1,
                                       l2=reg_constant2)

# regularisation constants can be optimised (hyperparam's)

# Create a single dense layer:
layer1 = layers.Dense(
    units = 1,
    activation= acts[1],
    use_bias=True,
    kernel_initializer=norm_init,
    bias_initializer='zeros',
    kernel_regularizer=l2_regulariser,
    bias_regularizer=None,
    activity_regularizer=None,
    kernel_constraint=None,
    bias_constraint=None
)


def main():


if __name__ == "__main__":
    main()