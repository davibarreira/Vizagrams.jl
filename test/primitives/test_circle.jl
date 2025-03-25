using Vizagrams
import Vizagrams: CovCircle, ϕ, ψ, coordinates

@testset "Circle" begin
    r = R(π / 2)
    t = T(1.0, 2.0)
    s = U(3.0)
    @testset "Constructor" begin
        @test Circle(1, [0, 0]).r == 1
        @test Circle(1, [0, 0]).c == [0, 0]
        @test Circle(-1, [0, 0]).r == -1 #check that it works with negative radius
    end

    @testset "CovCircle" begin
        @test CovCircle([1, 2], [3, 4])._1 == [1, 2]
        @test CovCircle([1, 2], [3, 4])._2 == [3, 4]
    end

    @testset "act" begin
        g = T(1.0, 1.0)
        @test act(g, CovCircle([1, 2], [3, 4]))._1 == [2, 3]
        @test act(g, CovCircle([1, 2], [3, 4]))._2 == [4, 5]

        @test act(r, Circle()).r ≈ 1
        @test act(r, Circle()).c ≈ [0, 0]
        @test act(t, Circle()).r ≈ 1
        @test act(t, Circle()).c ≈ [1, 2]
        @test act(s, Circle()).r ≈ 3
        @test act(s, Circle()).c ≈ [0, 0]
    end

    @testset "ψ" begin
        @test ψ(CovCircle([1, 2], [3, 4])).r ≈ 1.4142135623730951
        @test ψ(CovCircle([1, 2], [3, 4])).c ≈ [2, 3]
    end

    @testset "ϕ" begin
        @test ϕ(Circle(1, [0, 0]))._1 ≈ [-1, 0]
        @test ϕ(Circle(1, [0, 0]))._2 ≈ [1, 0]
    end

    @testset "coordinates" begin
        rad = rand()
        c = rand(2)
        @test coordinates(Circle(rad, c)) ==
            [[rad * cos(θ) + c[1], rad * sin(θ) + c[2]] for θ in 0:(2π / 100):(2π)]
    end
end
