include("./simulate.jl")

# Compile
params = Params(nsteps=10)
simulate(params)

# 100k simulation
params = Params(
    nsteps=200,
    x0 = getcoor("./ne100k_initial.pdb"),
    cutoff = 12.,
    box = Box([ 99.88, 99.88, 99.88 ], 12., lcell=2)
)
@time simulate(params)





