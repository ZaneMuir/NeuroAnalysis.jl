
mutable struct EDF_FileHeader
    # Header
    Version::Clong                      # 8 ascii : version of this data format (0)
    Patient::String                # 80 ascii : local patient identification (mind item 3 of the additional EDF+ specs)
    Comment::String                 # 80 ascii : local recording identification (mind item 4 of the additional EDF+ specs)
#     start_date::String                  # 8 ascii : startdate of recording (dd.mm.yy) (mind item 2 of the additional EDF+ specs)
#     start_time::String                  # 8 ascii : starttime of recording (hh.mm.ss)
    
    Year::Cint
    Month::Cint
    Day::Cint
    Hour::Cint
    Minute::Cint
    Second::Cint
    
    Padding::Vector{Cuchar}             # 8 ascii : number of bytes in header record
                                        # 44 ascii : reserved
    NumRecord::Cint                     # 8 ascii : number of data records (-1 if unknown, obey item 10 of the additional EDF+ specs)
    SampleDuration::Cfloat              # 8 ascii : duration of a data record, in seconds
    NumChannel::Cint                    # 4 ascii : number of signals (ns) in data record
    
    ChannelLabels::Vector{String}     # ns * 16 ascii : ns * label (e.g. EEG Fpz-Cz or Body temp) (mind item 9 of the additional EDF+ specs)
    ChannelType::Vector{String}       # ns * 80 ascii : ns * transducer type (e.g. AgAgCl electrode)
    PhysicalDim::Vector{String}       # ns * 8 ascii : ns * physical dimension (e.g. uV or degreeC)
    PhysicalMin::Vector{Cfloat}       # ns * 8 ascii : ns * physical minimum (e.g. -500 or 34)
    PhysicalMax::Vector{Cfloat}       # ns * 8 ascii : ns * physical maximum (e.g. 500 or 40)
    DigitalMin::Vector{Cshort}        # ns * 8 ascii : ns * digital minimum (e.g. -2048)
    DigitalMax::Vector{Cshort}        # ns * 8 ascii : ns * digital maximum (e.g. 2047)
    
    Prefiltering::Vector{String}      # ns * 80 ascii : ns * prefiltering (e.g. HP:0.1Hz LP:75Hz)
    NumSamplesInRecord::Vector{Cshort}           # ns * 8 ascii : ns * nr of samples in each data record
    NumReservedSamplesInRecord::Vector{Cshort}  # ns * 32 ascii : ns * reserved
    
    EDF_FileHeader(file::IOStream) = begin
        _x = new()
        
        _x.Version = read(file, Int64)
        _x.Patient = read(file, 80) |> String |> strip
        _x.Comment = read(file, 80) |> String |> strip
        
        _x.Day, _x.Month, _x.Year = read(file, 8) |> String |> strip |> 
            x->match(r"(\d{2})\.(\d{2})\.(\d{2})", x) |> x-> (x[1], x[2], x[3]) .|> Meta.parse
        _x.Hour, _x.Minute, _x.Second = read(file, 8) |> String |> strip |> 
            x->match(r"(\d{2})\.(\d{2})\.(\d{2})", x) |> x-> (x[1], x[2], x[3]) .|> Meta.parse
        _x.Padding = read(file, 52)
        
        _x.NumRecord = read(file, 8) |> String |> Meta.parse
        _x.SampleDuration = read(file, 8) |> String |> Meta.parse
        _x.NumChannel = read(file, 4) |> String |> Meta.parse
        
        _x.ChannelLabels = read(file, 16*_x.NumChannel) |> x->reshape(x, (16, _x.NumChannel)) |> b-> mapreduce(x->String([x]), *, b, dims=1)[:] .|> strip
        _x.ChannelType = read(file, 80*_x.NumChannel) |> x->reshape(x, (80, _x.NumChannel)) |> b-> mapreduce(x->String([x]), *, b, dims=1)[:] .|> strip
        _x.PhysicalDim = read(file, 8*_x.NumChannel) |> x->reshape(x, (8, _x.NumChannel)) |> b-> mapreduce(x->String([x]), *, b, dims=1)[:] .|> strip
        _x.PhysicalMin = read(file, 8*_x.NumChannel) |> x->reshape(x, (8, _x.NumChannel)) |> b-> mapreduce(x->String([x]), *, b, dims=1)[:] .|> strip .|> Meta.parse
        _x.PhysicalMax = read(file, 8*_x.NumChannel) |> x->reshape(x, (8, _x.NumChannel)) |> b-> mapreduce(x->String([x]), *, b, dims=1)[:] .|> strip .|> Meta.parse
        _x.DigitalMin  = read(file, 8*_x.NumChannel) |> x->reshape(x, (8, _x.NumChannel)) |> b-> mapreduce(x->String([x]), *, b, dims=1)[:] .|> strip .|> Meta.parse
        _x.DigitalMax  = read(file, 8*_x.NumChannel) |> x->reshape(x, (8, _x.NumChannel)) |> b-> mapreduce(x->String([x]), *, b, dims=1)[:] .|> strip .|> Meta.parse
        
        _x.Prefiltering = read(file, 80*_x.NumChannel) |> x->reshape(x, (80, _x.NumChannel)) |> b-> mapreduce(x->String([x]), *, b, dims=1)[:] .|> strip
        _x.NumSamplesInRecord = read(file, 8*_x.NumChannel) |> x->reshape(x, (8, _x.NumChannel)) |> b-> mapreduce(x->String([x]), *, b, dims=1)[:] .|> strip .|> Meta.parse
        _x.NumReservedSamplesInRecord = read(file, 32*_x.NumChannel) |> x->reshape(x, (32, _x.NumChannel)) |> b-> mapreduce(x->String([x]), *, b, dims=1)[:] .|> strip .|> Meta.parse .|> x -> (x==nothing) ? 0 : x
        
        _x
    end
end


mutable struct EDFData
    FILE_HEADER::EDF_FileHeader
    CONTINUOUS_DATA::Array{Int16, 2}
    
    ##### misc #####
    Freq::Float32
#     Tspec::Vector{Float32}
    PhysicalUnit::Vector{Float32}
    
    RecordTime::String
    RecordDate::String
    
    EDFData(filename::String) = begin
        _f = open(filename, "r")
        _x = new()
        
        _x.FILE_HEADER = EDF_FileHeader(_f)
        
        _raw_data = zeros(Int16, _x.FILE_HEADER.NumRecord * _x.FILE_HEADER.NumSamplesInRecord[1], _x.FILE_HEADER.NumChannel)
#         _raw_reserved = zeros(Int16, _x.FILE_HEADER.NumChannel, _x.FILE_HEADER.NumRecord * _x.FILE_HEADER.NumReservedSamplesInRecord[1])
        
        _step = sum(_x.FILE_HEADER.NumSamplesInRecord)
        _chstep = _x.FILE_HEADER.NumSamplesInRecord[1]
        for _record_idx = 1:_x.FILE_HEADER.NumRecord
            record_data = read!(_f, Array{Int16, 2}(undef, _chstep, _x.FILE_HEADER.NumChannel))
            _raw_data[_chstep*(_record_idx-1)+1:_chstep*_record_idx, :] = record_data
        end
        _x.CONTINUOUS_DATA = _raw_data
        
        _x.Freq = _chstep / _x.FILE_HEADER.SampleDuration
        _x.PhysicalUnit = ( _x.FILE_HEADER.PhysicalMax .-  _x.FILE_HEADER.PhysicalMin) ./ ( _x.FILE_HEADER.DigitalMax -  _x.FILE_HEADER.DigitalMin)
        
        _header = _x.FILE_HEADER
        _x.RecordTime = "$(_header.Year)-$(_header.Month)-$(_header.Day) $(_header.Hour):$(_header.Minute):$(_header.Second)"
        _x.RecordDate = "$(_header.Year)-$(_header.Month)-$(_header.Day)"
        
        _x
    end
end


function export_isplit(_edf::EDFData; Comment = nothing, _dir="./iSplit")
    
    _index_json = joinpath(_dir, "channel_index.json")
    if !isfile(_index_json)
        open(_index_json, "w") do file
            write(file, "{}")
        end
    end

    channel_index = open(_index_json, "r") do file
        JSON.parse(file)
    end

    _record_time = _edf.RecordTime
    _record_date = _edf.RecordDate

    
    _comment = (Comment == nothing) ? Dict() : Comment


    for (chidx, chlabel) in enumerate(_edf.FILE_HEADER.ChannelLabels)
        
        _comment["label"] = chlabel
        _value = _edf.CONTINUOUS_DATA[:, chidx]
        _idx = hash(_value) |> repr
        
        if haskey(channel_index, @sprintf("channel%03d", chidx))
            if _idx in channel_index[@sprintf("channel%03d", chidx)]
                continue
            end
        else
            channel_index[@sprintf("channel%03d", chidx)] = Vector{String}(undef, 0)
        end

        _isplit_name = joinpath(_dir, @sprintf("channel%03d.jld", chidx))

        if !isfile(_isplit_name)
            jldopen(_isplit_name, "w") do file
                write(file, "Name", @sprintf("Channel%03d", chidx))
                write(file, "Comment", "")

            end
        end

        jldopen(_isplit_name, "r+") do file
            _entry = iSplitUnit(
                chidx, _record_date, _record_time, _comment,
                _edf.PhysicalUnit[chidx], _edf.Freq, _value
            )
            write(file, _idx, _entry)
        end

        push!(channel_index[@sprintf("channel%03d", chidx)], _idx)
    end
        
    open(_index_json, "w") do file
        write(file, JSON.json(channel_index))
    end
end
