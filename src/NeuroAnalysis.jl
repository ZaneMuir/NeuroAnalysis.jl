module NeuroAnalysis

using FileIO, JLD2
using Plots
gr(fmt="png", size=(600, 400))

include("IO/io.jl")
include("Spike/Spike.jl")

end  # module NeuroAnalysis
