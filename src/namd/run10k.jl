
include("./simulate.jl")

# Compile
params = Params(nsteps=50)
simulate(params)

# 10k simulation
params = Params(
    nsteps=2000,
    x0 = getcoor("./ne10k_initial.pdb"),
    cutoff = 12.,
    box = Box([ 46.37, 46.37, 46.37 ], 12., lcell=2)
)
@time simulate(params)





