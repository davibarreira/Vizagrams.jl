using Vizagrams
import Vizagrams: CovRectangle, coordx, coordy, compare_structs

@testset "Graphical Primitives" begin
    @testset "GeometricPrimitive" begin
        @testset "coordx" begin
            @test all(coordx(Rectangle(2, 3, [0, 0], 0)) .== [-1.5, 1.5, 1.5, -1.5])
        end

        @testset "coordy" begin
            @test all(coordy(Rectangle(2, 3, [0, 0], 0)) .== [-1.0, -1.0, 1.0, 1.0])
        end

        @testset "act" begin
            g = T(1, 1)
            @test compare_structs(
                act(g, Rectangle(2, 3, [0, 0], 0)), Rectangle(2, 3, [1, 1], 0)
            )
            @test compare_structs(
                act(g, CovRectangle([0, 0], [3, 0], [0, 2])),
                CovRectangle([1, 1], [4, 1], [1, 3]),
            )
        end
    end

    @testset "Prim" begin
        @testset "act" begin
            g = T(1, 1)
            prim = Prim(Rectangle(2, 3, [0, 0], 0))
            gs = (g, S(Dict(:color => "red")))
            ps = act(gs, prim)
            @test compare_structs(ps.geom, Rectangle(2, 3, [1, 1], 0))
            @test compare_structs(ps.s, S(Dict(:color => "red")))
        end
    end
end
