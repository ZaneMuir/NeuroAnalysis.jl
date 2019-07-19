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

function chunk_bymarker(data::Array{D, 2}, marker::Vector{T}, roi::Tuple{T,T}, freq::T; mbias::T=0.0) where {D, T}
    ngap = (roi[2] - roi[1]) * freq |> ceil |> Int
    _result = zeros(D, ngap, size(data, 2), length(marker))

    for (_idx, _marker) in enumerate(marker)
        _start = (_marker + roi[1] + mbias) * freq |> floor |> Int
        _result[:, :, _idx] = data[_start:_start+ngap-1, :]
    end
    _result
end

function chunk_bymarker(data::Vector{D}, marker::Vector{T}, roi::Tuple{T,T}, freq::T; mbias::T=0.0) where {D, T}
    ngap = (roi[2] - roi[1]) * freq |> ceil |> Int
    _result = zeros(D, ngap, length(marker))

    for (_idx, _marker) in enumerate(marker)
        _start = (_marker + roi[1] + mbias) * freq |> floor |> Int
        _result[:, _idx] = data[_start:_start+ngap-1]
    end
    _result
end

include("LFP/iSplitContainer.jl")
include("LFP/Decomposition.jl")
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
