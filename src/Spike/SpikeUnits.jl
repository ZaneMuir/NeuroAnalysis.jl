module SpikeUnits

using DataFrames, Query
import CSV
import MAT

export SpikeUnit, SpikeMarker, import_spike_train_data, marker_validity


"""
Storing information and data for each channel.

You wouldn't normally create a SpikeUnit struct yourself, this is done
for you when retreiving a mat file from your data directory.

```julia
struct SpikeUnit
    session     ::String
    mouse_id    ::String
    channel     ::String
    spike_train ::Array{Float64,1}
end
```
"""
struct SpikeUnit
    session     ::String
    mouse_id    ::String
    channel     ::String
    spike_train ::Array{Float64,1}
end


"""
Storing and parsing marker information of each session.

You wouldn't normally create a SpikeMarker object yourself, this is done
for you when retreiving a csv file from your data directory.

Specially, the _raw_table shall be a DataFrame, with coloumns("time", "marker"); 
if you have a different layout, you should write
your own ```_chunker(_raw_table, _raw_train)``` function, 
which returns Dict{String, Array{Float64,1}}

```julia
struct SpikeMarker
    session     ::String
    mouse_id    ::String
    _raw_table  ::DataFrames.DataFrame
    _raw_train  ::Array{Float64, 1}
    chunked_marker::Dict{String, Array{Float64,1}}
end
```
"""
struct SpikeMarker
    session     ::String
    mouse_id    ::String
    _raw_table  ::DataFrames.DataFrame
    _raw_train  ::Array{Float64, 1}
    chunked_marker::Dict{String, Array{Float64,1}}
end


"""
Check .csv marker and .mat marker are valid or not.

#### Method:
the time shift between the first and the last marker of .csv and .mat
file shall be less than thresh.

#### Args
- table:  the .csv marker in DataFrame
- train:  the .mat marker in 1d Array
- boundary: the threshold, as seconds [optional, default: 1.0]

#### Returns:
- shift:  the shift value. i.e. how many markers in .csv is not recorded in .mat markers.

#### Raises:
- ErrorException("marker value not match!")
- ErrorException("electrode markers exceed stimulus markers!") when shift < 0
"""
function marker_validity(table, train, boundary=1.0)
    shift = length(table[1]) - length(train)
    
    shift<0 && throw(ErrorException("electrode markers exceed stimulus markers!"))
    
    _start_d = table[:time][1] - train[1]
    _end_d = table[:time][end-shift] - train[end]
    
    if abs(_start_d - _end_d) <= boundary
        return shift
    else
        throw(ErrorException("marker value not match!: $(_start_d - _end_d)"))
    end
end


"""
If you have a different .csv data layout, you should write
your own ```_chunker``` function.

Tips:
- you may need the ```marker_validity``` to get the shift value
  between csv and mat markers.

#### Args:
- _raw_table: the raw csv data
- _raw_train: the raw marker data

#### Returns:
- _chunked: chunked data in Dict{String, Array{Float64,1}}
"""
function _default_marker_chunker(_raw_table, _raw_train)
    _valids = @from item in _raw_table begin
        @where !(item.marker in ["START", "QUIT"])
        @select item
        @collect DataFrame
        end
    
    _shift = marker_validity(_valids, _raw_train)
    _neo = DataFrame(time=_raw_train, marker=_valids[:marker][1:end-_shift])
    _chunked = Dict{String,Array{Float64,1}}()
    
    
    for stim in unique(_valids[:marker])
        _temp = @from item in _valids begin
            @where item.marker == stim
            @select item.time
            @collect
        end
        _chunked[stim] = _temp
    end
    
    _chunked
end
    

"""
Import .mat and .csv data.

#### Args:
- session:    session name in string.
- mouse_id:   mouse name in string.

#### Keyword Args:
- _mat: .mat data file name. [optional, default: ""]
- _csv: .csv data file name. [optional, default: ""]
- _dir: data directory path. [optional, default: data/SpikeTrain]
- _marker_channel: the marker channel name in .mat file.[optional, default: "DIG01"]
- csv_chunker: custom csv chunker function [optional, default: _default_marker_chunker]

#### Returns:
- _spike_units:   Dict{String, SpikeUnit}
- _spike_marker:  SpikeMarker
"""
function import_spike_train_data(session::String, mouse_id::String; 
                                 _mat::String="", _csv::String="",
                                 _dir::String="data/SpikeTrain", _marker_channel::String="DIG01", 
                                 _chunker=_default_marker_chunker)
    _mat==""&&(_mat="$session.mat")
    _csv==""&&(_csv="$session.csv")
    
    _mat_file = joinpath(_dir, _mat)
    _csv_file = joinpath(_dir, _csv)
    
    _marker_train = Array{Float64, 1}()
    _marker_table = CSV.read(_csv_file, nullable=false)
    _spike_units = Dict{String, SpikeUnit}()

    
    _mat_data = MAT.matread(_mat_file)
    for (name, raw_train) in _mat_data

        _raw_train = raw_train["times"][:,1]
        if name != _marker_channel
            _spike_units[name] = SpikeUnit(session, mouse_id, name, _raw_train)
        else
            _marker_train = _raw_train
        end
    end

    _spike_marker = SpikeMarker(session, mouse_id, _marker_table, 
                                _marker_train, _chunker(_marker_table, _marker_train))

    (_spike_units, _spike_marker)
end


end # SpikeUnit