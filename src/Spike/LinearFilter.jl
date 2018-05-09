module LinearFilter


# Kernel function
"""
`gaussian_kernel(sigma::Float64)`
The Gaussian Kernel.

$$ w(\\tau) = \\frac{1}{\\sqrt{2 \\pi} \\sigma_w}
\\exp(-\\frac{\\tau^2}{2 \\sigma^2_w}) $$

"""
function gaussian_kernel(sigma=1)
    return t->1/sqrt(2*pi)/sigma .* exp.(-t.^2./(2*sigma^2))
end



end
