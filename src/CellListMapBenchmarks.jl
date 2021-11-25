module CellListMapBenchmarks

import Pkg
using Dates
using CellListMap

include("./namd/simulate.jl")
using .Simulation

export version
export namd10k, namd100k

# function to get the CellListMap version used
get_version()=filter(x-> x.second.name == "CellListMap", Pkg.dependencies()) |> x -> first(x)[2].version

# Package dir
const package_dir = "$(@__DIR__)/.."

# Namd dir
const namd_dir = "/home/leandro/programs/namd/NAMD_2.14_Linux-x86_64-multicore"

# Create benchmark dir 
function create_dir(version,name)
    dir="$package_dir/results/$version/$name"
    mkpath(dir)
    println("Results directory for $version/$name created.")
    return dir
end

# Run namd 10k benchmark
function namd10k()
    hostname=gethostname()
    name="namd10k"
    version = get_version()
    dir = create_dir(version,name)
    working_dir = Simulation.working_dir
    params = Simulation.Params(
        x0=Simulation.getcoor(working_dir*"/ne10k_initial.pdb"),
        trajfile=working_dir*"/ne10k_traj.xyz",
        nsteps=5000
    )
    np = Threads.nthreads()
    t_cl = @elapsed Simulation.simulate(params)
    t_namd = @elapsed run(`$namd_dir/namd2 +p$np $working_dir/ne10k.namd`)
    log = open(dir*"/$hostname-$(np)-threads.dat","w")
    println(log,"Number of threads: $np")
    println(log,"CellListMap: $t_cl")
    println(log,"Namd 2.14:   $t_namd")
    close(log)
end

# Run namd 100k benchmark
function namd100k()
    hostname=gethostname()
    name="namd100k"
    version = get_version()
    dir = create_dir(version,name)
    working_dir = Simulation.working_dir
    params = Simulation.Params(
        x0=Simulation.getcoor(working_dir*"/ne100k_initial.pdb"),
        trajfile=working_dir*"/ne100k_traj.xyz",
        nsteps=1000,
        box = Box([ 99.88, 99.88, 99.88 ], 12., lcell=2)
    )
    np = Threads.nthreads()
    t_cl = @elapsed Simulation.simulate(params)
    t_namd = @elapsed run(`$namd_dir/namd2 +p$np $working_dir/ne100k.namd`)
    log = open(dir*"/$hostname-$(np)-threads.dat","w")
    println(log,"Number of threads: $np")
    println(log,"CellListMap: $t_cl")
    println(log,"Namd 2.14:   $t_namd")
    close(log)
end


end