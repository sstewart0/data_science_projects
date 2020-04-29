

set.seed(1)
Control <- matrix(rnorm(50 * 1000), ncol = 50)
Treatment <- matrix(rnorm(50 * 1000), ncol = 50)
X <- cbind(Control, Treatment)

# create a linear linear trend in one dimension

X[1, ] <- seq(-18, 18 - .36, .36)
pr.out <- prcomp(scale(X))
summary(pr.out)$importance[, 1]

# Now, adding in A vs B via 10 vs 0 encoding 
# and assess the quality of the improved solution.

X <- rbind(X, c(rep(10, 50), rep(0, 50)))
pr.out <- prcomp(scale(X))
summary(pr.out)$importance[, 1]
