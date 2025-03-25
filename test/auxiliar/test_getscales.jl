using Vizagrams
using StructArrays
using Random

@testset "Auxiliar Functions" begin
    @testset "getscale" begin
        Random.seed!(4)
        data = StructArray(; x=rand(10), y=rand(10))
        plt = Plot(; data=data, x=:x, y=:y)
        @test getscale(plt, :x) == Linear((0.2, 1.0), (0, 300))
        @test isnothing(getscale(plt.spec, :z))
    end
    @testset "getscales" begin
        Random.seed!(4)
        data = StructArray(; x=rand(10), y=rand(10))
        plt = Plot(; data=data, x=:x, y=:y)

        @test length(getscales(plt)) == 2
        @test length(getscales(plt.spec)) == 2
        @test all(map(x -> x[1] in [:x, :y], getscales(plt)))
    end
end
