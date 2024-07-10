using Vizagrams
import Vizagrams: compare_structs, compare_primitives

@testset "Envelopes" begin
    @testset "envelope" begin
        envs = [2.0, 1.0, 1.0, 1.0]
        d = Circle() + T(1, 0)Circle()
        for (j, v) in enumerate([[1, 0], [0, 1], [-1, 0], [0, -1]])
            @test envelope(d, v) ≈ envs[j]
        end
    end
    @testset "boundingbox" begin
        d = Circle() + T(1, 0)Circle()
        @test boundingbox(d) == [[-1.0, -1.0], [2.0, 1.0]]
    end
    @testset "rectboundingbox" begin
        d = Circle() + T(1, 0)Circle()
        @test compare_primitives(Vizagrams.flatten(rectboundingbox(d))[1], Prim(Rectangle(2.0, 3.0, [0.5, 0.0], 0.0), S(:stroke => :blue, :fillOpacity => 0)))
    end
end
