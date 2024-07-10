using Vizagrams
import Vizagrams: cubicbeziermax, getpoints, quadbeziermax, compare_structs

@testset "Bezier Curves" begin

    g = T(1, 1)
    @testset "QBezier" begin
        @testset "Constructor" begin
            @testset "Valid input" begin
                @test compare_structs(QBezier(bpts=[[-1, -1], [1, 1]], cpts=[[0, 1]]), QBezier([[-1, -1], [1, 1]], [[0, 1]]))
            end

            @testset "Invalid input" begin
                @test_throws AssertionError QBezier(bpts=[[-1, -1]], cpts=[[0, 1]]) # Number of base points must be at least 2
                @test_throws AssertionError QBezier(bpts=[[-1, -1], [1, 1]], cpts=[[0, 1], [2, 2]]) # Number of control points must be one less than the number of base points
            end
        end

        @testset "getpoints" begin
            @test getpoints(QBezier(bpts=[[-1, -1], [1, 1]], cpts=[[0, 1]])) == [[-1, -1], [0, 1], [1, 1]]
        end

        @testset "quadbeziermax" begin
            @test quadbeziermax([[-1, -1], [0, 1], [1, 1]]) == [1, 1]
            @test all(quadbeziermax(QBezier([[-1, -1], [0, 1], [1, 0]])) .≈ 1 / 3)
        end

        @testset "act" begin
            @test compare_structs(act(g, QBezier(bpts=[[-1, -1], [1, 1]], cpts=[[0, 1]])), QBezier(bpts=[[0, 0], [2, 2]], cpts=[[1, 2]]))
        end
    end

    @testset "CBezier" begin
        @testset "Constructor" begin
            @testset "Valid input" begin
                @test compare_structs(CBezier(bpts=[[-1, -1], [1, 1]], cpts=[[-1, 1], [1, 1]]), CBezier([[-1, -1], [1, 1]], [[-1, 1], [1, 1]]))
            end

            @testset "Invalid input" begin
                @test_throws AssertionError CBezier(bpts=[[-1, -1]], cpts=[[-1, 1], [1, 1]]) # Number of base points must be at least 2
                @test_throws AssertionError CBezier(bpts=[[-1, -1], [1, 1]], cpts=[[-1, 1]]) # Number of control points must be equal to 2(# base points - 1)
            end
        end

        @testset "getpoints" begin
            @test getpoints(CBezier(bpts=[[-1, -1], [1, 1]], cpts=[[-1, 1], [1, 1]])) == [[-1, -1], [-1, 1], [1, 1], [1, 1]]
        end

        @testset "cubicbeziermax" begin
            @test all(cubicbeziermax([[-1, -1], [-1, 1], [1, 1], [1, 1]]) .== [1, 1])
        end

        @testset "act" begin
            @test compare_structs(act(g, CBezier(bpts=[[-1, -1], [1, 1]], cpts=[[-1, 1], [1, 1]])), CBezier(bpts=[[0, 0], [2, 2]], cpts=[[0, 2], [2, 2]]))
        end
    end
end
