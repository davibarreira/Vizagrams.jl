using Vizagrams
using Documenter

DocMeta.setdocmeta!(Vizagrams, :DocTestSetup, :(using Vizagrams); recursive=true)
ENV["DATADEPS_ALWAYS_ACCEPT"] = true


makedocs(sitename="Vizagrams.jl",
    format=Documenter.HTML(size_threshold=nothing, assets=["assets/favicon.ico"]),
    pages=[
        "Home" => "index.md",
        "Tutorials" => [
            "1 - Diagramming Basics" => "tutorials/1_basics.md"
            "2 - Custom Marks" => "tutorials/2_custommarks.md"
            "3 - Data Vizualization Basics" => "tutorials/3_datavisualization.md"
            "4 - Graphic Expressions" => "tutorials/4_expressiveness.md"
            "5 - Customizing Visualizations" => "tutorials/5_customization.md"
            "7 - Polar Visualizations" => "tutorials/6_polar.md"
        ],
        "Gallery" => [
            "Grouped Bar Chart" => "gallery/groupedbar.md",
            "Histogram" => "gallery/histogram.md",
            "Minard's Chart" => "gallery/minard.md",
            "OECD Better Life Index" => "gallery/moritz.md",
            "Penguins" => "gallery/penguins.md",
        ],
    ]
)

deploydocs(; repo="github.com/davibarreira/Vizagrams.jl", devbranch="master")
