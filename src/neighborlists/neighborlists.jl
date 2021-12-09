module NeighborLists

using BenchmarkTools, Test
using NearestNeighbors
using CellListMap
using StaticArrays
using LinearAlgebra

working_dir=@__DIR__

# 
# inrage using BallTree
#
function nl_NN(x,y,r)
    balltree = BallTree(x)
    return inrange(balltree,y,r,true)
end

#
# a simple wrapper around the neighborlist function, to simplify the swapping
# for this test
#
function nl_CL(x,y,r;parallel=true,autoswap=false)
    box = Box(limits(x,y),r)
    cl = CellList(x,y,box,parallel=parallel,autoswap=autoswap)
    return CellListMap.neighborlist(box,cl,parallel=parallel)
end

#
# Function that checks if the results are the same for both NN methods
#
function compare_result(list_CL,list_NN)
    if length(list_CL) <= 100
        for (i,list) in pairs(list_NN)
            cl = filter(tup -> tup[2] == i, list_CL)
            length(cl) != length(list) &&  return false
            for j in list
               length(findall(tup -> tup[1] == j, cl)) != 1 && return false
            end
        end
    else
        npairs = 0
        for i in list_NN
            npairs += length(list_NN[i])
        end
        npairs != length(list_CL) && return false
    end
    return true
end

#
# Naive algorithm, just for checking
#
function naive(x,y,cutoff)
  pair_list = Int[]
  for vx in x
    for (i,vy) in pairs(y) 
      if norm(vx - vy) <= cutoff  
        push!(pair_list,i)
      end
    end
  end
  pair_list
end

function neighborlists(filename)

  ρ = 0.1 # density of atoms in water atoms/Å^3
  r = 12. # typical MD cutoff

  file = open(filename,"w")
  println("N1,N2,NNxy, NNyx, cls_xy, clp_xy, cls_yx, clp_xy")
  println(file,"N1,N2,NNxy, NNyx, cls_xy, clp_xy, cls_yx, clp_xy")
  for N1 in [1, 10, 100, 1_000, 10_000, 100_000]
    for N2 in [10^6]

       side = ((N1+N2)/ρ)^(1/3)

       x = [ side*rand(SVector{3,Float64}) for i in 1:N1 ]
       y = [ side*rand(SVector{3,Float64}) for i in 1:N2 ]
       
       list_CL = nl_CL(x,y,r,parallel=true)
       GC.gc()
       list_NN = nl_NN(x,y,r)
       GC.gc()

       nn_xy = @belapsed nl_NN($x,$y,$r) samples=1
       GC.gc()
       nn_yx = @belapsed nl_NN($y,$x,$r) samples=1 
       GC.gc()
       cls_xy = @belapsed nl_CL($x,$y,$r,parallel=false, autoswap=false) samples=1
       GC.gc()
       clp_xy = @belapsed nl_CL($x,$y,$r,parallel=true, autoswap=false) samples=1
       GC.gc()
       cls_yx = @belapsed nl_CL($y,$x,$r,parallel=false, autoswap=false) samples=1
       GC.gc()
       clp_yx = @belapsed nl_CL($y,$x,$r,parallel=true, autoswap=false) samples=1
       GC.gc()
       println("$N1, $N2, $nn_xy, $nn_yx, $cls_xy, $clp_xy, $cls_yx, $clp_yx") 
       println(file, "$N1, $N2, $nn_xy, $nn_yx, $cls_xy, $clp_xy, $cls_yx, $clp_yx") 

    end
  end
  close(file)

  return 
end

end







