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
        include("./primitives/test_graphical_primitives.jl")
        include("./primitives/test_envelopes.jl")
    end

    @safetestset "Trees" begin
        include("./trees/test_freemonad.jl")
        include("./trees/test_envelopes.jl")
        include("./trees/test_align.jl")
        include("./trees/test_mark_tree.jl")
        include("./trees/test_diagram_tree.jl")
        include("./trees/test_operations.jl")
    end

    # Tests below not working on GitHub Actions
    @safetestset "Visual Tests" begin
        # include("./visual/visual_tests.jl")
        include("./visual/plots.jl")
    end
end
