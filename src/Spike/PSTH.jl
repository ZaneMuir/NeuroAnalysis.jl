# export PSTH, PSTHPlot

struct PSTHResult{T}
    ROIRange::StepRangeLen
    PSTHCount::Vector{T}
    Raster::Vector{Vector{T}}
end

"""
PSTH(train::Vector{T}, marker::Vector{T}, ROI::Tuple{T,T}; binsize::T=0.1) where {T}

PSTH - peri-stimulus time histogram or post-stimulus time histogram
each bin is calcuated as \$\$\\frac{\\sum_i^N x_i}{N \\cdot \\text{binsize}}\$\$

arguments:
- train: the spike train as 1d numpy.array
- marker: the marker of stimuli
- ROI: the region of interest for each stimuli, 
       define the range the PSTH.

keyword arguments:
- binsize: the size of each bin [default: 0.1]

return:
- PSTHResult{T}(ROIRange, PSTH, _seg)
    - ROIRange: the x axis
    - PSTH: the `spike/binsize` value of each PSTH bin
    - _seg: spike train for each segment, i.e. the data
            of the raster plot.

"""
function PSTH(train::Vector{T}, marker::Vector{T}, ROI::Tuple{T,T}; binsize::T=0.1) where {T}
    
    _seg = Vector{Vector{T}}(undef, length(marker))
    for (idx, item) in enumerate(marker)
        _seg[idx] = train[(item + ROI[1] .<= train) .& (train .< item + ROI[2])] .- item
    end

    _roi_len = Int(ceil((ROI[2] - ROI[1])/binsize))
    _roi_range = range(ROI[1], stop=ROI[1]+binsize*_roi_len, length=_roi_len+1)
    
    _psth = zeros(T, _roi_len)
    for item in _seg
        for i in item
            _psth[Int(floor((i - ROI[1]) / binsize)) + 1] += 1
        end
    end
    _psth = _psth ./ length(marker) ./ binsize
    
#     _roi_range, _psth, _seg
    PSTHResult{T}(_roi_range, _psth, _seg)
end
PSTH(sch::SpikeChannel, ech::EventChannel, ROI::Tuple{Float64, Float64}; binsize::Float64=0.1) = PSTH(sch.Value, ech.Value, ROI, binsize=binsize)

function PSTHPlot(r::PSTHResult)
    
    plot(legend=nothing)
    for (idx,item) in enumerate(r.Raster)
        for each in item
            plot!([each, each], [idx-0.5, idx+0.5], color=:black)
        end
    end
    _raster = plot!(ylabel="trial #")
    
    _step = r.ROIRange.step.hi + r.ROIRange.step.lo
    _psth = bar(r.ROIRange[1:end-1] .+ _step / 2, r.PSTHCount, legend=nothing, xlabel="ROI (sec)", ylabel="PSTH (spike/sec)")
    plot(_raster, _psth, layout=@layout([_raster; _psth]), size=(600, 800))
end