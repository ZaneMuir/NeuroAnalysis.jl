push!(LOAD_PATH,"../src/")
using Documenter, NeuroAnalysis

# makedocs(
#     # format = :html,
#     # sitename = "NeuroAnalysis.jl",
#     )

# deploydocs(
#     deps   = Deps.pip("mkdocs", "python-markdown-math"),
#     repo = "github.com/ZaneMuir/NeuroAnalysis.jl.git",
#     julia  = "0.6"
# )

makedocs(
    format = :html,
    sitename = "NeuroAnalysis.jl",
    pages = Any[
        "Introduction" => "index.md",
        "Workflow" => Any[
            "Getting Started" => "index.md"
        ],
        "API" => Any[
            "Spike" => "lib/Spike.md",
            "Reader" => "lib/Reader.md",
            "Waveform" => "lib/Waveform.md"
        ]
    ]
    )