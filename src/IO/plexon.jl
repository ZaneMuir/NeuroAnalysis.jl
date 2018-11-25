# for PLEXON file version 105 and greater.

mutable struct PLX_FileHeader
    MagicNumber::Cuint ;  # // == 0x58454c50
    Version::Cint ;

    Comment::String ;  # char[128]
    ADFrequency::Cint ;  # // TimeStamp frequency in hertz
    NumSpikeChannels::Cint ;
    NumEventChannels::Cint ;
    NumContinuousChannels::Cint ;

    NumPointsWave::Cint ;
    NumPointsPreThr::Cint ;

    Year::Cint ;
    Month::Cint ;
    Day::Cint ;
    Hour::Cint ;
    Minute::Cint ;
    Second::Cint ;

    FastRead::Cint ;  # // reserved
    WaveformFreq::Cint ;  # // waveform sampling rate;
    LastTimeStamp::Cdouble ;  # // duration of the experimental session, in ticks

    Trodalness::UInt8;
    DataTrodalness::UInt8;
    BitsPerSpikeSample::UInt8;
    BitsPerContinuousSample::UInt8;

    SpikeMaxMagnitudeMV::UInt16;
    ContinuousMaxMagnitudeMV::UInt16;
    SpikePreAmpGain::UInt16;

    Padding::String;

    TSCounts::Array{Int32, 2};
    WFCounts::Array{Int32, 2};
    EVCounts::Vector{Int32};

    PLX_FileHeader(file::IOStream) = begin
        _x = new()

        _x.MagicNumber, _x.Version = read!(file, Vector{Cuint}(undef, 2))
        _x.Comment = read!(file, Vector{UInt8}(undef, 128)) |> String
        _x.ADFrequency, _x.NumSpikeChannels, _x.NumEventChannels, _x.NumContinuousChannels = read!(file, Vector{Cint}(undef, 4))
        _x.NumPointsWave, _x.NumPointsPreThr = read!(file, Vector{Cint}(undef, 2))
        _x.Year, _x.Month, _x.Day, _x.Hour, _x.Minute, _x.Second = read!(file, Vector{Cint}(undef, 6))
        _x.FastRead, _x.WaveformFreq = read!(file, Vector{Cint}(undef, 2))

        _x.LastTimeStamp = read!(file, Vector{Cdouble}(undef, 1))[1]

        _x.Trodalness, _x.DataTrodalness, _x.BitsPerSpikeSample, _x.BitsPerContinuousSample = read!(file, Vector{UInt8}(undef, 4))
        _x.SpikeMaxMagnitudeMV, _x.ContinuousMaxMagnitudeMV, _x.SpikePreAmpGain = read!(file, Vector{UInt16}(undef, 3))

        _x.Padding = read!(file, Vector{UInt8}(undef, 46)) |> String

        _x.TSCounts = read!(file, Array{Cint,2}(undef, 130, 5))
        _x.WFCounts = read!(file, Array{Cint,2}(undef, 130, 5))
        _x.EVCounts = read!(file, Vector{Cint}(undef, 512))

        _x
    end
end

mutable struct PLX_SpikeChannelHeader
    Name::String;
    SIGName::String;
    Channel::Cint;
    WFRate::Cint;

    SIG::Cint;
    Ref::Cint;
    Gain::Cint;

    Filter::Cint;
    Threashold::Cint;
    Method::Cint;
    NUnits::Cint;

    Template::Array{Cshort, 2};
    Fit::Vector{Cint};
    SortWidth::Cint;

    Boxes::Array{Cshort, 3};
    SortBeg::Cint;

    Comment::String;
    Padding::Vector{Cint};

    PLX_SpikeChannelHeader(file::IOStream) = begin
        _x = new()

        _x.Name = read!(file, Vector{UInt8}(undef, 32)) |> String
        _x.SIGName = read!(file, Vector{UInt8}(undef, 32)) |> String

        _x.Channel, _x.WFRate, _x.SIG, _x.Ref, _x.Gain, _x.Filter, _x.Threashold, _x.Method, _x.NUnits = read!(file, Vector{Cint}(undef, 9))

        _x.Template = read!(file, Array{Cshort,2}(undef, 5,64))
        _x.Fit = read!(file, Vector{Cint}(undef, 5))
        _x.SortWidth = read!(file, Vector{Cint}(undef, 1))[1]

        _x.Boxes = read!(file, Array{Cshort, 3}(undef, 5,2,4))
        _x.SortBeg = read!(file, Vector{Cint}(undef, 1))[1]

        _x.Comment = read!(file, Vector{UInt8}(undef, 128)) |> String
        _x.Padding = read!(file, Vector{Cint}(undef, 11))

        _x
    end
end

mutable struct PLX_EventChannelHeader
    Name::String;
    Channel::Cint;
    Comment::String;
    Padding::Vector{Cint};

    PLX_EventChannelHeader(file::IOStream) = begin
        _x = new()

        _x.Name = read!(file, Vector{UInt8}(undef, 32)) |> String
        _x.Channel = read!(file, Vector{Cint}(undef, 1))[1]
        _x.Comment = read!(file, Vector{UInt8}(undef, 128)) |> String
        _x.Padding = read!(file, Vector{Cint}(undef, 33))

        _x
    end
end

mutable struct PLX_ContinuousChannelHeader
    Name::String;
    Channel::Cint;
    ADFreq::Cint;
    Gain::Cint;
    Enabled::Cint;
    PreAmpGain::Cint;
    SpikeChannel::Cint;
    Comment::String;
    Padding::Vector{Cint};

    PLX_ContinuousChannelHeader(file::IOStream) = begin
        _x = new()

        _x.Name = read!(file, Vector{UInt8}(undef, 32)) |> String
        _x.Channel, _x.ADFreq, _x.Gain, _x.Enabled, _x.PreAmpGain, _x.SpikeChannel = read!(file, Vector{Cint}(undef, 6))
        _x.Comment = read!(file, Vector{UInt8}(undef, 128)) |> String
        _x.Padding = read!(file, Vector{Cint}(undef, 28))

        _x
    end
end

PLX_DATATYPE_SPIKE = 1
PLX_DATATYPE_EVENT = 4
PLX_DATATYPE_CONTINUOUS = 5

mutable struct PLX_DataBlock_Header  # 16 bytes
    Type::Cshort;  # Data type; 1=spike, 4=Event, 5=continuous
    UpperByteOf5ByteTimestamp::Cushort;
    TimeStamp::UInt32;  # 40-bits timestamp
    Channel::Cshort;
    Unit::Cshort;
    NumberOfWaveforms::Cshort;
    NumberOfWordsInWaveform::Cshort;

    PLX_DataBlock_Header(file::IOStream) = begin
        _x = new()
        _x.Type, _x.UpperByteOf5ByteTimestamp = read!(file, Vector{Cshort}(undef, 2))
        _x.TimeStamp = read!(file, Vector{UInt32}(undef, 1))[1]
        _x.Channel, _x.Unit, _x.NumberOfWaveforms, _x.NumberOfWordsInWaveform = read!(file, Vector{Cshort}(undef, 4))
        _x
    end
end

mutable struct PLXData
    FILE_HEADER::PLX_FileHeader
    SPIKE_CHANNEL_HEADER::Vector{PLX_SpikeChannelHeader}
    EVENT_CHANNEL_HEADER::Vector{PLX_EventChannelHeader}
    CONTINUOUS_CHANNEL_HEADER::Vector{PLX_ContinuousChannelHeader}

    EVENTS::Dict{Int, Vector{UInt64}}
    SPIKE_DATA::Dict{Int, Dict{Int, Vector{Int16}}}
    SPIKE_TS::Dict{Int, Dict{Int, Vector{UInt64}}}
    CONTINUOUS_DATA::Dict{Int, Vector{Int16}}
    CONTINUOUS_TS::Dict{Int, Vector{UInt64}}

    PLXData(filename::String) = begin
        _f = open(filename, "r")
        _x = new()

        _x.FILE_HEADER = PLX_FileHeader(_f)
        if _x.FILE_HEADER.Version < 105
            @error "plexon files version < 105 are not supported. "
        end

        _x.SPIKE_CHANNEL_HEADER = [PLX_SpikeChannelHeader(_f) for i = 1:_x.FILE_HEADER.NumSpikeChannels]
        _x.EVENT_CHANNEL_HEADER = [PLX_EventChannelHeader(_f) for i = 1:_x.FILE_HEADER.NumEventChannels]
        _x.CONTINUOUS_CHANNEL_HEADER = [PLX_ContinuousChannelHeader(_f) for i = 1:_x.FILE_HEADER.NumContinuousChannels]

        _x.EVENTS = Dict{Int, Vector{UInt64}}()
        _x.SPIKE_DATA = Dict{Int, Dict{Int, Vector{Int16}}}()
        _x.SPIKE_TS = Dict{Int, Dict{Int, Vector{Int16}}}()
        _x.CONTINUOUS_DATA = Dict{Int, Vector{Int16}}()
        _x.CONTINUOUS_TS = Dict{Int, Vector{UInt64}}()

        _flag = 0
        while !eof(_f)
            _data_header = PLX_DataBlock_Header(_f)
            _channel = _data_header.Channel
            _unit = _data_header.Unit

            if _data_header.Type == PLX_DATATYPE_SPIKE
                if _data_header.NumberOfWaveforms == 1
                    _raw = read!(_f, Vector{Int16}(undef, _data_header.NumberOfWordsInWaveform))
                end

                if !haskey(_x.SPIKE_DATA, _channel)
                    _x.SPIKE_DATA[_channel] = Dict{Int, Vector{Int16}}()
                    _x.SPIKE_TS[_channel] = Dict{Int, Vector{UInt64}}()
                end
                if !haskey(_x.SPIKE_DATA[_channel], _unit)
                    _x.SPIKE_DATA[_channel][_unit] = _raw
                    _x.SPIKE_TS[_channel][_unit] = [_data_header.TimeStamp]
                else
                    append!(_x.SPIKE_DATA[_channel][_unit], _raw)
                    push!(_x.SPIKE_TS[_channel][_unit], _data_header.TimeStamp)
                end

            elseif _data_header.Type == PLX_DATATYPE_EVENT
                if !haskey(_x.EVENTS, _channel)
                    _x.EVENTS[_channel] = Vector{UInt64}([_data_header.TimeStamp])
                else
                    push!(_x.EVENTS[_channel], _data_header.TimeStamp)
                end

            elseif _data_header.Type == PLX_DATATYPE_CONTINUOUS
                if _data_header.NumberOfWaveforms == 1
                    _raw = read!(_f, Vector{Int16}(undef, _data_header.NumberOfWordsInWaveform))
                end
                if !haskey(_x.CONTINUOUS_DATA, _channel)
                    _x.CONTINUOUS_DATA[_channel] = Vector{Int16}(_raw)
                    _x.CONTINUOUS_TS[_channel] = Vector{UInt64}([_data_header.TimeStamp])
                else
                    append!(_x.CONTINUOUS_DATA[_channel], _raw)
                    push!(_x.CONTINUOUS_TS[_channel], _data_header.TimeStamp)
                end

            else
                @error "$(_flag) - unknow data type $(_data_header.Type)"
            end

            _flag += 1

        end
        close(_f)
        _x
    end
end
