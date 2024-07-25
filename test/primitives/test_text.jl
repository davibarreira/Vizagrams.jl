using Vizagrams
import Vizagrams: CovText, ϕ, ψ

@testset "TextGeom" begin
    g = T(1.0, 1.0)
    @testset "Constructor" begin
        # @test_throws AssertionError TextGeom("", [0, 0], -1, 0, "")
        @test TextGeom("", [0, 0], 12, 0, "").text == ""
        @test TextGeom("", [0, 0], 12, 0, "").pos == [0, 0]
        @test TextGeom("", [0, 0], 12, 0, "").fontsize == 12
        @test TextGeom("", [0, 0], 12, 0, "").θ == 0
    end

    @testset "CovText" begin
        @test CovText("", [1, 2], [3, 4], "").text == ""
        @test CovText("", [1, 2], [3, 4], "")._1 == [1, 2]
        @test CovText("", [1, 2], [3, 4], "")._2 == [3, 4]
    end

    @testset "act" begin
        @test act(g, CovText("", [1, 2], [3, 4], "")).text == ""
        @test all(act(g, CovText("", [1, 2], [3, 4], ""))._1 .== [2, 3])
    end

    @testset "ψ" begin
        @test ψ(CovText("", [1, 2], [3, 4], "")).text == ""
        @test ψ(CovText("", [1, 2], [3, 4], "")).pos ≈ [2.0, 3.0]
        @test ψ(CovText("", [1, 2], [3, 4], "")).fontsize ≈ 2√2
        @test ψ(CovText("", [1, 2], [3, 4], "")).θ ≈ π / 4
    end

    @testset "ϕ" begin
        @test ϕ(TextGeom("", [0, 0], 12, 0, "")).text == ""
        @test ϕ(TextGeom("", [0, 0], 12, 0, ""))._1 ≈ [-6.0, 0.0]
        @test ϕ(TextGeom("", [0, 0], 12, 0, ""))._2 ≈ [6.0, 0.0]
    end
end
