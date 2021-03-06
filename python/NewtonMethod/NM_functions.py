import numpy as np
import sympy

'''
Requirements:
    -> f : R^n -> R is continuously differentiable function
    -> grad(f) is a system of (continuous) non-linear eq's
    -> Hessian(f) is an invertible matrix, continuous at all x in Neighbourhood(x*)
'''
d = int(input("Dimension of domain(f) = "))
f = str(input("f:R^n -> R where f(x0,x1,...,xn) = "))
x_b = sympy.Matrix(np.array([input("Start point of NM (in the form x0 x1 ... xn) = ").split()], float)).transpose()

variables = np.array(['x'+str(i) for i in range(0, d)])
df = np.array([sympy.diff(f, var) for var in variables])
df_M = sympy.Matrix(df)

d2f = np.array([[sympy.diff(grad, var) for var in variables] for grad in df])
d2f_M = sympy.Matrix(d2f)

d2f_inv_M = d2f_M.inv()

n_iter = 0
df_b = df_M.subs([(variables[j], x_b[j]) for j in range(0, d)])
d2f_inv_b = d2f_inv_M.subs([(variables[j], x_b[j]) for j in range(0, d)])

x = 0

while True:
    next_x = x_b-(d2f_inv_b*df_b)
    for i in range(0, d):
        if (abs((next_x-x_b)[i]) < 0.001) & (i == d-1):
            x = 1
    if x == 1:
        break
    else:
        df_b = df_M.subs([(variables[j], next_x[j]) for j in range(0, d)])
        d2f_inv_b = d2f_inv_M.subs([(variables[j], next_x[j]) for j in range(0, d)])
        x_b = next_x
    print(x_b)

exit()
