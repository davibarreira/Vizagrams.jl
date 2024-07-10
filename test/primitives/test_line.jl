using Vizagrams
import Vizagrams: coordinates

@testset "Line" begin
    @testset "Constructor" begin
        @test Line().pts == [[0, 0], [1, 1]]
        @test Line([[2, 2], [3, 3]]).pts == [[2, 2], [3, 3]]
        @test Line([[4, 4]]).pts == [[4, 4], [4, 4]]
    end

    @testset "act" begin
        r = R(π / 2)
        t = T(1.0, 2.0)
        s = U(3.0)
        @test act(r, Line()).pts[1] ≈ [0, 0]
        @test act(r, Line()).pts[2] ≈ [-1, 1]
        @test act(t, Line()).pts[1] ≈ [1, 2]
        @test act(t, Line()).pts[2] ≈ [2, 3]
        @test act(s, Line()).pts[1] ≈ [0, 0]
        @test act(s, Line()).pts[2] ≈ [3, 3]
        @test Line([[1, 2]]).pts == [[1, 2], [1, 2]]
    end

    @testset "coordinates" begin
        @test coordinates(Line([[1, 2]])) == Line([[1, 2]]).pts
        x = rand(10)
        y = rand(10)
        @test Line(x, y).pts == [[i[1], i[2]] for i in zip(x, y)]
        @test Line([(i[1], i[2]) for i in zip(x, y)]).pts == Line(x, y).pts
    end
end
