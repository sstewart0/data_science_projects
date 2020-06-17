import numpy as np

n = int(input("Number of vectors = "))
print("Vectors (elements space separated, vectors line separated) = ")
vectors = np.array([input().split() for _ in range(0, n)], dtype=float)

u1 = vectors[0]

# Normalise
e1 = u1/(np.linalg.norm(u1))

# Create set of orthonormal vectors
orthonormal = e1

for i in range(0, n-1):
    v = vectors[i+1]
    u = v
    for j in range(0, i+1):
        c = vectors[j]
        # Successively orthogonalize
        u -= (np.inner(c, v)/np.inner(c, c))*c
    # Normalise
    e = u/(np.linalg.norm(u))
    orthonormal = np.vstack((orthonormal, e))

print(orthonormal)
exit()
