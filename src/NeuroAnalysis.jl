module NeuroAnalysis

include("Spike/SpikeUnits.jl")

export SpikeUnits

end  # module NeuroAnalysis

"""
Split-apply-combine in one step; apply `f` to each grouping in `d`
based on columns `col`
```julia
by(d::AbstractDataFrame, cols, f::Function; sort::Bool = false)
by(f::Function, d::AbstractDataFrame, cols; sort::Bool = false)
```
### Arguments
* `d` : an AbstractDataFrame
* `cols` : a column indicator (Symbol, Int, Vector{Symbol}, etc.)
* `f` : a function to be applied to groups; expects each argument to
  be an AbstractDataFrame
* `sort`: sort row groups (no sorting by default)
`f` can return a value, a vector, or a DataFrame. For a value or
vector, these are merged into a column along with the `cols` keys. For
a DataFrame, `cols` are combined along columns with the resulting
DataFrame. Returning a DataFrame is the clearest because it allows
column labeling.
A method is defined with `f` as the first argument, so do-block
notation can be used.
`by(d, cols, f)` is equivalent to `combine(map(f, groupby(d, cols)))`.
### Returns
* `::DataFrame`
### Examples
```julia
df = DataFrame(a = repeat([1, 2, 3, 4], outer=[2]),
               b = repeat([2, 1], outer=[4]),
               c = randn(8))
by(df, :a, d -> sum(d[:c]))
by(df, :a, d -> 2 * skipmissing(d[:c]))
by(df, :a, d -> DataFrame(c_sum = sum(d[:c]), c_mean = mean(skipmissing(d[:c]))))
by(df, :a, d -> DataFrame(c = d[:c], c_mean = mean(skipmissing(d[:c]))))
by(df, [:a, :b]) do d
    DataFrame(m = mean(skipmissing(d[:c])), v = var(skipmissing(d[:c])))
end
"""