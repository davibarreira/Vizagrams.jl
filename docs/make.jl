using Vizagrams
using Documenter

DocMeta.setdocmeta!(Vizagrams, :DocTestSetup, :(using Vizagrams); recursive=true)
ENV["DATADEPS_ALWAYS_ACCEPT"] = true


makedocs(sitename="Vizagrams.jl",
    format=Documenter.HTML(size_threshold=nothing, example_size_threshold=nothing, assets=["assets/favicon.ico"]),
    pages=[
        "Home" => "index.md",
        "Tutorials" => [
            "1 - Diagramming Basics" => "tutorials/1_basics.md"
            "2 - Custom Marks" => "tutorials/2_custommarks.md"
            "3 - Data Vizualization Basics" => "tutorials/3_datavisualization.md"
            "4 - Graphic Expressions" => "tutorials/4_expressiveness.md"
            "5 - Customizing Visualizations" => "tutorials/5_customization.md"
            "6 - Polar Visualizations" => "tutorials/6_polar.md"
            "7 - Composite Visualizations" => "tutorials/7_composite.md"
        ],
        "Gallery" => [
            "BoxPlot" => "gallery/boxplot.md",
            "Grouped Bar Chart" => "gallery/groupedbar.md",
            "Floating Stacked Bar" => "gallery/floatingbar.md",
            "Histogram" => "gallery/histogram.md",
            "Minard's Chart" => "gallery/minard.md",
            "OECD Better Life Index" => "gallery/moritz.md",
            "PCA" => "gallery/pca.md",
            "Penguins" => "gallery/penguins.md",
            "Rose Diagram" => "gallery/nightingale.md",
        ],
    ]
)

deploydocs(; repo="github.com/davibarreira/Vizagrams.jl", devbranch="master")
