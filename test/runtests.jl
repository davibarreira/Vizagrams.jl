using Vizagrams
using Test
using Aqua
using JET
using SafeTestsets

@testset "Vizagrams.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(Vizagrams,
            ambiguities=false,
            deps_compat=(ignore=[
                :LinearAlgebra,
                :Statistics,
                :Test,
            ],),
        )
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(Vizagrams; target_defined_modules=true)
    end

    @safetestset "Primitives" begin
        include("./primitives/test_line.jl")
        include("./primitives/test_circle.jl")
        include("./primitives/test_square.jl")
        include("./primitives/test_rectangle.jl")
        include("./primitives/test_bezier.jl")
        include("./primitives/test_polygon.jl")
        include("./primitives/test_text.jl")
        include("./primitives/test_slice.jl")
        include("./primitives/test_ellipse.jl")
        include("./primitives/test_arc.jl")
        include("./primitives/test_graphical_primitives.jl")
        include("./primitives/test_envelopes.jl")
    end
    @safetestset "Marks" begin
        include("./marks/test_boxplot.jl")
        include("./marks/test_histogram.jl")
        include("./marks/test_latex.jl")
    end

    @safetestset "Trees" begin
        include("./trees/test_freemonad.jl")
        include("./trees/test_envelopes.jl")
        include("./trees/test_align.jl")
        include("./trees/test_mark_tree.jl")
        include("./trees/test_diagram_tree.jl")
        include("./trees/test_operations.jl")
    end

    @safetestset "Scales" begin
        include("./scales/test_binscale.jl")
    end

    @safetestset "Encoding" begin
        include("./encoding/test_quickplot.jl")
    end

    @safetestset "Auxiliar" begin
        include("./auxiliar/test_treemanipulation.jl")
    end
    @safetestset "Helper Functions" begin
        include("./auxiliar/test_helperfunctions.jl")
    end

    # Tests below not working on GitHub Actions
    @safetestset "Visual Tests" begin
        include("./visual/plots.jl")
        include("./visual/test_polar.jl")
    end
    @safetestset "Savefigs" begin
        include("./backends/test_savefigs.jl")
    end
end
