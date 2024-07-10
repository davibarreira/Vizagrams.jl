using Vizagrams
import Vizagrams: Slice, CovSlice, act, ψ, ϕ

@testset "Slice" begin
    @testset "Constructor" begin
        @test Slice(2, 1, [0, 0], π / 2, 0).rmajor == 2
        @test Slice(2, 1, [0, 0], π / 2, 0).rminor == 1
        @test Slice(2, 1, [0, 0], π / 2, 0).c == [0, 0]
        @test Slice(2, 1, [0, 0], π / 2, 0).ang == π / 2
        @test Slice(2, 1, [0, 0], π / 2, 0).θ == 0
    end

    @testset "CovSlice" begin
        @test CovSlice([0, 0], [1, 1], [2, 2], [3, 3])._1 == [0, 0]
        @test CovSlice([0, 0], [1, 1], [2, 2], [3, 3])._2 == [1, 1]
        @test CovSlice([0, 0], [1, 1], [2, 2], [3, 3])._3 == [2, 2]
        @test CovSlice([0, 0], [1, 1], [2, 2], [3, 3])._4 == [3, 3]
    end

    @testset "act" begin
        g = T(1.0, 1.0)
        @test act(g, CovSlice([1, 1], [2, 2], [3, 3], [4, 4]))._1 == [2, 2]
        @test act(g, CovSlice([1, 1], [2, 2], [3, 3], [4, 4]))._2 == [3, 3]
        @test act(g, CovSlice([1, 1], [2, 2], [3, 3], [4, 4]))._3 == [4, 4]
        @test act(g, CovSlice([1, 1], [2, 2], [3, 3], [4, 4]))._4 == [5, 5]
    end

    @testset "ψ" begin
        p = CovSlice([0, 0], [2, 0], [0, 2], [1, 0])
        @test compare_structs(ψ(p), Slice(2.0, 1.0, [0, 0], π / 2, π / 2))
    end

    @testset "ϕ" begin
        p = Slice(2.0, 1.0, [0, 0], π / 2, π / 2)
        @test compare_structs(ϕ(p), CovSlice([0, 0], [2, 0], [0, 2], [1, 0]), eq=(x, y) -> x ≈ y)
    end
end
