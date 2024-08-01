using Vizagrams
using StructArrays

@testset "Auxiliar Functions" begin

    @testset "getmark" begin
        d = Circle() + Circle() + Rectangle() + T(1, 1)Face() + S(:fill => :red)Face()

        @test length(listmarks(d)) == 5
        @test length(getmark(Circle, d)) == 2
        @test length(getmark(Face, d)) == 2
        @test length(getmark([Face, Circle], d)) == 6

        @test length(listmarks(ζ(Face()))) == 4

        @test length(getmarkpath(Face, d)) == 2

        @test length(getmarkpath(Face, d, G)) == 2
        @test all(getmarkpath(Face, d, G)[1]([1, 1]) .== [2, 2])
        @test length(getmarkpath(Face, d, S)) == 2
        @test getmarkpath(Face, d, S)[2].d[:fill] == :red

        plt = plot(x=rand(10), y=rand(10))
        @test getmarkpath([Plot], plt) == []
        @test getmarkpath([Plot, PlotSpec], plt) == []
        d = plt → plt
        @test length(getmarkpath([Plot, PlotSpec, XAxis], d)) == 2
    end
end
