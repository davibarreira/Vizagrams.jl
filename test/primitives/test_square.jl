using Vizagrams
import Vizagrams: CovSquare, ϕ, ψ, coordinates

@testset "Square" begin
    @testset "Constructor" begin
        @test_throws AssertionError Square(-1, [0, 0], 0)
        @test Square(1, [0, 0], 0).l == 1
        @test Square(1, [0, 0], 0).c == [0, 0]
        @test Square(1, [0, 0], 0).θ == 0
    end

    @testset "CovSquare" begin
        @test CovSquare([1, 2], [3, 4])._1 == [1, 2]
        @test CovSquare([1, 2], [3, 4])._2 == [3, 4]
    end

    @testset "act" begin
        r = R(π / 2)
        t = T(1.0, 2.0)
        s = U(3.0)
        g = T(1.0, 1.0)

        @test act(g, CovSquare([1, 2], [3, 4]))._1 == [2, 3]
        @test act(g, CovSquare([1, 2], [3, 4]))._2 == [4, 5]

        @test act(r, Square()).l ≈ 1
        @test act(r, Square()).c ≈ [0, 0]
        @test act(r, Square()).θ ≈ π / 2
        @test act(t, Square()).l ≈ 1
        @test act(t, Square()).c ≈ [1, 2]
        @test act(t, Square()).θ ≈ 0
        @test act(s, Square()).l ≈ 3
        @test act(s, Square()).c ≈ [0, 0]
        @test act(s, Square()).θ ≈ 0
    end

    @testset "ψ" begin
        @test ψ(CovSquare([1, 2], [3, 4])).l ≈ 2√2
        @test ψ(CovSquare([1, 2], [3, 4])).c ≈ [2.0, 3.0]
        @test ψ(CovSquare([1, 2], [3, 4])).θ ≈ π / 4
    end

    @testset "ϕ" begin
        @test ϕ(Square(1, [0, 0], 0))._1 ≈ [-0.5, 0.0]
        @test ϕ(Square(1, [0, 0], 0))._2 ≈ [0.5, 0.0]
    end

    @testset "coordinates" begin
        @test all(coordinates(Square(1, [0, 0], 0)) .≈ ([-0.5, 0.5], [-0.5, -0.5], [0.5, -0.5], [0.5, 0.5]))
    end
end
