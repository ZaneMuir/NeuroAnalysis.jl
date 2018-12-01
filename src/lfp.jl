# module LFP

# function chunk_bymarker(data::Array{D, N}, marker::Vector{T}, roi::Tuple{T, T}, freq::T, mbias::T=0) where {D, T, N}
#     gap = (roi[2]-roi[1]) * freq |> ceil |> Int64
#     result = zeros(D, size(data, 1), gap, size(data, 2))

#     for (midx, eachm) in enumerate(marker)
#         _start = (eachm + roi[1] + mbias) * freq |> floor |> Int64
#         result = [:, :, midx] = #TODO
#     end
#     #TODO
# end

include("LFP/iSplitContainer.jl")
# for both one-dimensional and two-dimensional size.

# Container.jl
# create compact channel data (i.e. iSplit format)
# load compact channel data
# create_epoch, chunk_iSplit,

# Decomposition.jl
# morlet wavelet transformation
# cmplx_power
# cmplx_phase

# Filter.jl
# gaussian window filter



# end
