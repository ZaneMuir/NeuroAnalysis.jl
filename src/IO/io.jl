# module IO
abstract type AbstractChannel end
abstract type ContinuousChannel <: AbstractChannel end

struct ContinuousChannel8 <: ContinuousChannel
    Index::UInt16
    Name::String
    Note::String
    
    Dimension::String
    Unit::Float16
    Frequency::Float16
    
    Value::Vector{Int8}
end

struct ContinuousChannel16 <: ContinuousChannel
    Index::UInt16
    Name::String
    Note::String
    
    Dimension::String
    Unit::Float32
    Frequency::Float32
    
    Value::Vector{Int16}
end

struct ContinuousChannel32 <: ContinuousChannel
    Index::UInt16
    Name::String
    Note::String
    
    Dimension::String
    Unit::Float64
    Frequency::Float64
    
    Value::Vector{Int32}
end

struct SpikeChannel <: AbstractChannel
    Index::UInt16
    Name::String
    Note::String
    
    Value::Vector{Float64}
end

struct EventChannel <: AbstractChannel
    Index::UInt16
    Name::String
    Note::String
    
    Marker::Vector{UInt16}
    Value::Vector{Float64}
end

struct RawData
    Filename::String
    
    EventChannels::Vector{EventChannel}
    EventComment::String
    SpikeChannels::Vector{SpikeChannel}
    SpikeComment::String
    ContinuousChannels::Vector{ContinuousChannel}
    ContinuousComment::String
end

function savedata(d::RawData)
#     save(d.Filename * ".event.jld2", Dict("Comment" => d.EventComment, "Event" => d.EventChannels))
#     save(d.Filename * ".spike.jld2", Dict("Comment" => d.SpikeComment, "Spike" => d.SpikeChannels))
#     save(d.Filename * ".cont.jld2", Dict("Comment" => d.ContinuousComment, "Cont" => d.ContinuousChannels))
    
    save(d.Filename * ".jld2", Dict("EventComment" => d.EventComment, 
            "SpikeComment" => d.SpikeComment,
            "ContComment" => d.ContinuousComment, 
            "Event" => d.EventChannels,
            "Spike" => d.SpikeChannels,
            "Cont" => d.ContinuousChannels))
end

function restore(filename::String, groups::Symbol=:all)
    if groups == :all
        _groups = [:event, :spike, :continuous, :comment]
    else
        _groups = [groups]
    end
    restore(filename, _groups)
end

function restore(filename::String, groups::Vector{Symbol})
    _event_comment = ""
    _spike_comment = ""
    _cont_comment = ""
    _event = Vector{}()
    _spike = Vector{}()
    _cont = Vector{}()
    
    if :event in groups
        _event = load(filename * ".jld2", "Event")
    end
    if :spike in groups
        _spike = load(filename * ".jld2", "Spike")
    end
    if :continuous in groups
        _cont = load(filename * ".jld2", "Cont")
    end
    if :comment in groups
        (_event_comment, _spike_comment, _cont_comment) = load(filename * ".jld2", "EventComment", "SpikeComment", "ContComment")
    end
    
    RawData(filename, _event, _event_comment, _spike, _spike_comment, _cont, _cont_comment)
end

# include("IO/plexon.jl")
# include("IO/edf.jl")
# include("IO/neurolynx.jl")

# export loadplx, loadedf, loadncs

# loadplx(filename::String) = PLXData(filename)
# loadedf(filename::String) = EDFData(filename)
# loadncs(filename::String) = readNCSFile(filename)

# end  # module IO
