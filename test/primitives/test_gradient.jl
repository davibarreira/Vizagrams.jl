using Vizagrams
import Vizagrams: coordinates

@testset "LinearGradient" begin
    @testset "Constructor" begin
        @test LinearGraident().pts == [[0, 0], [1, 0]]
        @test LinearGradient().id == "lgrad_bluesreds"
        @test LinearGradient().offsets == [0, 0.5, 1],
        @test LinearGradient().colors == ["#00008B", "#CCD9CC", "#8B0000"]
    end

    @testset "act" begin
        r = R(π / 2)
        t = T(1.0, 2.0)
        s = U(3.0)
        @test act(r, LinearGradient()).pts[1] ≈ [0, 0]
        @test act(r, LinearGradient()).pts[2] ≈ [-1, 1]
        @test act(t, LinearGradient()).pts[1] ≈ [1, 2]
        @test act(t, LinearGradient()).pts[2] ≈ [2, 3]
        @test act(s, LinearGradient()).pts[1] ≈ [0, 0]
        @test act(s, LinearGradient()).pts[2] ≈ [3, 3]
        @test LinearGradient([[1, 2]]).pts == [[1, 2], [1, 2]]
    end
end
