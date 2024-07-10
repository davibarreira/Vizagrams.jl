using Vizagrams
# import Vizagrams: estimatelengthtext

@testset "Envelopes" begin
    geoms = [
        Rectangle(2, 3, [0, 0], 0),
        Circle(1, [0, 0]),
        Slice(1, 0, [0, 0], π / 2, 0),
        QBezier([[0, 0], [1, 1], [2, 0]]),
        CBezier([[0, 0], [1, 1], [2, 0], [3, 1]]),
        QBezierPolygon([[0.2, 0], [1, 0]], [[1.0, 1], [0.5, -1]]),
        CBezierPolygon(
            [[0, 0], [0, 1], [1, 2], [1, 1]],
            [[0, 0], [0, 1], [0.5, 1], [0.5, 2], [1, 2], [1, 1], [0.5, 1], [0.5, 0]]),
        TextGeom(pos=[0, 0], fontsize=1, text="Hello")
    ]
    envs = [
        [1.5, 1.0, 1.5, 1.0],
        [1.0, 1.0, 1.0, 1.0],
        [1.0, 0.0, 0.0, 1.0],
        [2.0, 0.5, 0.0, 0.0],
        [3.0, 1.0, 0.0, 0.0],
        [1.0, 0.5, -0.2, 0.49999999999999994],
        [1.0, 2.0, 0.0, 0.0],
        [2.9850260416666665, 0.9563802083333333, -0.10481770833333333, 0.025390625]]
    @testset "envelope" begin
        for (i, g) in enumerate(geoms)
            for (j, v) in enumerate([[1, 0], [0, 1], [-1, 0], [0, -1]])
                @test envelope(g, S(:textAnchor => :start), v) ≈ envs[i][j]
            end
        end
    end

    # @testset "estimatelengthtext" begin
    #     @test estimatelengthtext("Hello", 12) ≈ 45.99033816425121
    #     @test estimatelengthtext("World", 10) ≈ 38.32528180354267
    # end

    @testset "boundingbox" begin
        for (i, g) in enumerate(geoms)
            @test all(boundingbox(Prim(g)) .== [-envs[i][3:4], envs[i][1:2]])
        end
    end
end
