module IO

include("IO/plexon.jl")
include("IO/edf.jl")
include("IO/neurolynx.jl")

export loadplx, loadedf, loadncs

function loadplx(filename::String)
    PLXData(filename)
end

function loadedf(filename::String)
    readEDFFile(filename)
end

function loadncs(filename::String)
    readNCSFile(filename)
end

end  # module IO
