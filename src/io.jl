# module IO

include("IO/plexon.jl")
include("IO/edf.jl")
include("IO/neurolynx.jl")

export loadplx, loadedf, loadncs

loadplx(filename::String) = PLXData(filename)
loadedf(filename::String) = EDFData(filename)

loadncs(filename::String) = readNCSFile(filename)

# end  # module IO
