module LinearFilter

export guassian_kernel, apply_linear_filter, apply_roi_aggregate
# Kernel function
"""
`gaussian_kernel(train::Array{Float64,1}, sigma::Float64)`

The Gaussian Kernel.

```math
w(\\tau) = \\frac{1}{\\sqrt{2 \\pi} \\sigma_w}
\\exp(-\\frac{(\\mathbf{t} - \\tau)^2}{2 \\sigma^2_w})
```
"""
function gaussian_kernel(train::Array{Float64,1},sigma::Float64=1.0)
    return t->sum(1/sqrt(2*pi)/sigma .* exp.(-broadcast(-, train, t).^2./(2*sigma^2)), 1)
end


function apply_linear_filter(k, tstart, tend; step=100)
    _t = tstart:1/step:tend |> Array{Float64, 1} |> transpose
    k(_t)
end

"""
```apply_roi_aggregate(kernel::LinearFilter.kernel, starts::Array{Float64,1}, roi::Range, backgrounds::Range)```

Returns:
- _result :: Array{Float64, 2}(signal, trial)
"""
function apply_roi_aggregate(kernel, starts, roi, backgrounds)
    _result = zeros(length(starts),length(roi))
    for idx = 1:length(starts)
        _mark = starts[idx]
        _x = (_mark + roi) |> Array{Float64, 1} |> transpose
        _backgrounds = (_mark + backgrounds) |> Array{Float64, 1} |> transpose
        _target = kernel(_x)
        _backgrounds = kernel(_backgrounds) |> mean

        _result[idx,:] = _target - _backgrounds
    end
    _result'
end
end
