using Vizagrams

@testset "Polygons" begin
    r = R(π / 2)
    t = T(1.0, 2.0)
    s = U(3.0)
    g = T(1.0, 1.0)
    @testset "Polygon" begin
        @testset "Constructor" begin
            @test Polygon([[0, 0], [1, 1]]).pts == [[0, 0], [1, 1]]
            @test Polygon([[-2, -2], [3, 3], [4, 4]]).pts == [[-2, -2], [3, 3], [4, 4]]
        end

        @testset "act" begin
            @test act(g, Polygon([[1, 1], [2, 2]])).pts == [[2, 2], [3, 3]]
            @test act(g, Polygon([[3, 3], [4, 4], [5, 5]])).pts == [[4, 4], [5, 5], [6, 6]]
        end

        @testset "coordinates" begin
            @test all(coordinates(Polygon([[1, 1], [2, 2]])) .== [[1, 1], [2, 2]])
        end
    end

    @testset "RegularPolygon" begin
        @testset "Constructor" begin
            @test RegularPolygon(n=5, c=[0, 0], r=1, θ=0).n == 5
            @test all(RegularPolygon(n=6, c=[1, 1], r=2, θ=π / 6).c .≈ [1, 1])
        end

        @testset "act" begin
            @test act(g, RegularPolygon(n=5, c=[0, 0], r=1, θ=0)).n == 5
            @test all(act(g, RegularPolygon(n=6, c=[1, 1], r=2, θ=π / 6)).c .≈ [2, 2])
        end

        @testset "coordinates" begin
            coord = [[6.123233995736766e-17, 1.0],
                [-0.9510565162951535, 0.3090169943749475],
                [-0.5877852522924732, -0.8090169943749473],
                [0.5877852522924729, -0.8090169943749476],
                [0.9510565162951536, 0.3090169943749472]]
            @test all(coordinates(RegularPolygon(n=5, c=[0, 0], r=1, θ=0)) .≈ coord)
        end
    end

    @testset "QBezierPolygon" begin
        @testset "Constructor" begin
            @test all(QBezierPolygon([[0.2, 0], [1, 0]], [[1.0, 1], [0.5, -1]]).bpts .== [[0.2, 0.0], [1, 0]])
            @test all(QBezierPolygon([[0.2, 0], [1, 0]], [[1.0, 1], [0.5, -1]]).cpts .== [[1.0, 1], [0.5, -1]])
        end

        @testset "act" begin
            @test all(act(g, QBezierPolygon([[0.2, 0], [1, 0]], [[1.0, 1], [0.5, -1]])).bpts .== [[1.2, 1], [2, 1]])
            @test all(act(g, QBezierPolygon([[0.2, 0], [1, 0]], [[1.0, 1], [0.5, -1]])).cpts .== [[2, 2], [1.5, 0]])
        end
    end

    @testset "CBezierPolygon" begin
        @testset "Constructor" begin
            @test all(CBezierPolygon([[0, 0], [0, 1], [0, 0]], [[-1, 0.8], [0, 1], [1, 1], [1, 1], [0, 1], [1, 0.8]]).bpts .== [[0, 0], [0, 1], [0, 0]])
            @test all(CBezierPolygon([[0, 0], [0, 1], [0, 0]], [[-1, 0.8], [0, 1], [1, 1], [1, 1], [0, 1], [1, 0.8]]).cpts .== [[-1, 0.8], [0, 1], [1, 1], [1, 1], [0, 1], [1, 0.8]])
        end

        @testset "act" begin
            @test all(act(g, CBezierPolygon([[0, 0], [0, 1], [0, 0]], [[-1, 0.8], [0, 1], [1, 1], [1, 1], [0, 1], [1, 0.8]])).bpts .== [[1, 1], [1, 2], [1, 1]])
            @test all(act(g, CBezierPolygon([[0, 0], [0, 1], [0, 0]], [[-1, 0.8], [0, 1], [1, 1], [1, 1], [0, 1], [1, 0.8]])).cpts .== [[-0, 1.8], [1, 2], [2, 2], [2, 2], [1, 2], [2, 1.8]])
        end
    end
end
