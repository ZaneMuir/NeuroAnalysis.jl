
mutable struct iSplitUnit
    Channel::Int           # Channel Index
    RecordDate::String     # "180903"
    RecordTime::String     # "18-09-03 18:33:20"
    Comment::Dict{String, String} # Comments
    PhysicalUnit::Float32  # mV = PhysicalUnit * Value
    SamplingFreq::Float32   # sampling rate in hertz
    Value::Vector{Int16}   # raw value, shoule be integer.
end

mutable struct iSplitContainer
    Name::String             # file name or other label
    Comment::String          # Comments
    Data::Vector{iSplitUnit} # data list
end


# function chunk_iSplit(isplitdata::iSplitContainer, markers::Vector{T}, mbias::Float32, roi=Tuple{T, T}; flatten=true, selector::Function=x->true) where {T <: Number}
#     _targets = filter(selector, isplitdata.Data)
# end

"""load JLD file"""
function loadisplit(filename::String)
    _raw = load(filename)
    _data = [_raw[item] for item in keys(_raw) if !(item in ["Name", "Comment"])]
    
    iSplitContainer(_raw["Name"], _raw["Comment"], _data)
end