push!(LOAD_PATH,"../src/")
using Documenter, NeuroAnalysis

makedocs(
    format = :html,
    sitename = "NeuroAnalysis.jl",
)

deploydocs(
    deps   = Deps.pip("mkdocs", "python-markdown-math"),
    repo = "github.com/ZaneMuir/NeuroAnalysis.jl.git",
    julia  = "0.6"
)