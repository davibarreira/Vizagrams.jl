using Vizagrams
import Vizagrams: CovRectangle, ϕ, ψ, coordinates, height, width, rectangle, compare_structs

@testset "Rectangle" begin
    @testset "Constructor" begin
        @test Rectangle(2, 3, [0, 0], 0).h == 2
        @test Rectangle(2, 3, [0, 0], 0).w == 3
        @test Rectangle(2, 3, [0, 0], 0).c == [0, 0]
        @test Rectangle(2, 3, [0, 0], 0).θ == 0
    end

    @testset "CovRectangle" begin
        @test CovRectangle([0, 0], [1, 1], [2, 2])._1 == [0, 0]
        @test CovRectangle([0, 0], [1, 1], [2, 2])._2 == [1, 1]
        @test CovRectangle([0, 0], [1, 1], [2, 2])._3 == [2, 2]
    end

    @testset "act" begin
        r = R(π / 2)
        t = T(1.0, 2.0)
        s = U(3.0)
        g = T(1.0, 1.0)
        @test act(g, CovRectangle([1, 1], [2, 2], [3, 3]))._1 == [2, 2]
        @test act(g, CovRectangle([1, 1], [2, 2], [3, 3]))._2 == [3, 3]
        @test act(g, CovRectangle([1, 1], [2, 2], [3, 3]))._3 == [4, 4]

        @test act(r, Rectangle()).h ≈ 1
        @test act(r, Rectangle()).w ≈ 2
        @test act(r, Rectangle()).c ≈ [0, 0] atol = 1e-4
        @test act(r, Rectangle()).θ ≈ π / 2
        @test act(t, Rectangle()).h ≈ 1
        @test act(t, Rectangle()).w ≈ 2
        @test act(t, Rectangle()).c ≈ [1, 2]
        @test act(t, Rectangle()).θ ≈ 0
        @test act(s, Rectangle()).h ≈ 3
        @test act(s, Rectangle()).w ≈ 6
        @test act(s, Rectangle()).c ≈ [0, 0]
        @test act(s, Rectangle()).θ ≈ 0
    end

    @testset "width" begin
        @test width(CovRectangle([0, 0], [3, 0], [0, 2])) == 3
        @test width(CovRectangle([0, 0], [5, 0], [0, 2])) == 5
    end

    @testset "height" begin
        @test height(CovRectangle([0, 0], [3, 0], [0, 2])) == 2
        @test height(CovRectangle([0, 0], [5, 0], [0, 2])) == 2
    end

    @testset "coordinates" begin
        @test coordinates(CovRectangle([0, 0], [3, 0], [0, 2])) == ([0, 0], [3, 0], [3, 2], [0, 2])
        @test coordinates(CovRectangle([0, 0], [5, 0], [0, 2])) == ([0, 0], [5, 0], [5, 2], [0, 2])
    end

    @testset "ψ" begin
        @test compare_structs(ψ(CovRectangle([0, 0], [3, 0], [0, 2])), Rectangle(2, 3, [1.5, 1], 0))
        @test compare_structs(ψ(CovRectangle([0, 0], [5, 0], [0, 2])), Rectangle(2, 5, [2.5, 1], 0))
    end

    @testset "ϕ" begin
        @test compare_structs(CovRectangle([-1.5, -1], [1.5, -1], [0, 1]), ϕ(Rectangle(2, 3, [0, 0], 0)))
        @test compare_structs(CovRectangle([-2.5, -1], [2.5, -1], [0, 1]), ϕ(Rectangle(2, 5, [0, 0], 0)))
    end

    @testset "coordinates" begin
        @test all(coordinates(Rectangle(2, 3, [0, 0], 0)) .≈ ([-1.5, -1.0], [1.5, -1.0], [1.5, 1.0], [-1.5, 1.0]))
    end

    @testset "rectangle" begin
        @test compare_structs(rectangle(), Rectangle(1, 1, [0.5, 0.5], 0))
        @test compare_structs(rectangle([0, 0], [2, 2]), Rectangle(2, 2, [1, 1], 0))
    end
end
