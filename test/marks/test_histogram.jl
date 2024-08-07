using Vizagrams
using Random
using StatsBase
using StructArrays

@testset "Hist" begin
    @testset "Constructor" begin
        @test_throws AssertionError Hist(xs=[1, 2], ys=[0])
    end
    @testset "Diagram" begin
        @test_throws AssertionError Hist(xs=[1, 2], ys=[0])
        hist = Hist(xs=[1, 2], ys=[0.5, 1])
        bars = getmark(Bar, ζ(hist))
        @test length(bars) == 2
        @test (bars[1].h, bars[2].h) == (1.0, 0.5)
    end
    @testset "Graphic Expression" begin
        Random.seed!(4)
        # Create a histogram
        h = fit(Histogram, rand(100), nbins=10)

        # Get the edges of the bins
        edges = h.edges[1]

        # Compute the centers of the bins
        bin_centers = (edges[1:end-1] .+ edges[2:end]) ./ 2

        data = StructArray(x=bin_centers, h=h.weights)

        plt = Plot(
            data=data,
            encodings=(
                x=(field=:x, datatype=:q),
                y=(field=:h, datatype=:q),
            ),
            graphic=Hist()
        )

        # Checking if the drawing function works
        @test string(draw(plt)) isa String

        # Checking the number of drawn bars
        @test length(getmark([Hist, Bar], plt)) == 10
    end
    @testset "bindata and countbin functions" begin

        @test countbin([1, 1, 10, 10]) == [2, 2, 2, 2]
        @test bindata([1, 1, 10, 10]) == [1.5, 1.5, 9.5, 9.5]

        Random.seed!(4)
        data = StructArray(x=rand(100))
        plt = Plot(
            data=data,
            x=bindata(data.x),
            y=countbin(data.x),
            graphic=Hist()
        )

        @test string(draw(plt)) isa String
        @test length(getmark([Hist, Bar], plt)) == 10
    end
end
