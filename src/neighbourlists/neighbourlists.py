import numpy as np
from scipy.spatial import cKDTree
from timeit import default_timer as timer

def build_trees(x,y):
    kd_tree_x = cKDTree(x) 
    kd_tree_y = cKDTree(y) 
    return kd_tree_x, kd_tree_y
  
def pp(x,y,r) : 
    kd_tree_x,  kd_tree_y = build_trees(x,y)
    pairs = kd_tree_y.query_ball_tree(kd_tree_x,r=r) 
    return pairs 

rho = 0.1
r = 12.

print(" All: ")
for N1 in [1, 10, 100, 1_000, 10_000, 100_000]:
    for N2 in [1_000_000]:
        side = ((float(N1+N2))/rho)**(float(1)/float(3))
        x = np.random.random((N1,3))
        y = np.random.random((N2,3))
        print("N1 =",N1," N2 = ",N2)
        start = timer()
        pp(x,y,r)
        end = timer()
        print("(x,y) ",end-start)
        start = timer()
        pp(y,x,r)
        end = timer()
        print("(y,x) ",end-start)


print(" Query only: ")
for N1 in [1, 10, 100, 1_000, 10_000, 100_000]:
    for N2 in [1_000_000]:
        side = ((float(N1+N2))/rho)**(float(1)/float(3))
        x = np.random.random((N1,3))
        y = np.random.random((N2,3))
        kd_tree_x,  kd_tree_y = build_trees(x,y)
        print("N1 =",N1," N2 = ",N2)
        start = timer()
        pairs = kd_tree_x.query_ball_tree(kd_tree_y,r=r) 
        end = timer()
        print("(x,y) ",end-start)
        start = timer()
        pairs = kd_tree_y.query_ball_tree(kd_tree_x,r=r) 
        end = timer()
        print("(y,x) ",end-start)

#%timeit pp(points)




