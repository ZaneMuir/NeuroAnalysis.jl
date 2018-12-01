module NeuroAnalysis

using Printf
using HDF5
using JLD
using JSON

# include("Spike/SpikeUnits.jl")
# include("Spike/FiringRate/LinearFilter.jl")
include("lfp.jl")
include("io.jl")


# export SpikeUnits, LinearFilter



end  # module NeuroAnalysis
