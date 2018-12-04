
# morlet wavelet
function morlet(F::T, fs::T; dtype=Float32) where {T}
    wtime = range(-1, stop=1, length=Int(2 * fs))
    s = 6 / ( 2 * pi * F)
    wavelet = exp.(2im * pi * F .* wtime) .* exp.(-wtime.^2 ./ (2*s^2));
    return wavelet |> Vector{Complex{dtype}}
end


"""
function dwt(data, fs, frange; reflection=false, wavelet=morlet)

Arguments:
- data
- fs
- frange

Keyword Arguments:
- reflection
- wavelet

Return result:

Note:
discrete wavelet transformation by convolution between the fft results of
original values and the wavelet function.
"""
function dwt(data::Vector{D}, fs::T, frange::Vector{T};
             reflection::Bool=false, wavelet::Function=morlet) where {D, T}
    data_fft = data
    if reflection
        data_flip = reverse(data_fft, dims=1)
        data_fft = [data_flip;data_fft;data_flip]
    end

    data_fft = data_fft |> Vector{Complex{Float32}}
    result = zeros(Complex{Float32}, size(data,1), length(frange))

    for (fidx, ftarget) in enumerate(frange)
        w = wavelet(ftarget, fs)
        if reflection
            result[:, fidx] = DSP.conv(data_fft, w)[Int(fs)+size(data,1):end-Int(fs)-size(data, 1)]
        else
            result[:, fidx] = DSP.conv(data_fft, w)[Int(fs):end-Int(fs)]
        end
    end

    result
end
