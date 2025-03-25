using Vizagrams
using Random
using Statistics
using DataFrames

@testset "BoxPlot" begin
    @testset "Constructor" begin
        @test BoxPlot().box_width == 1
        @test BoxPlot().data == [-3, -1, 0, 1, 4]
    end

    @testset "Diagram" begin
        # check if the output drawing has two rectangles
        @test length(getmark(Rectangle, Vizagrams.ζ(BoxPlot()))) == 2
        # check if the output drawing has three lines
        @test length(getmark(Line, Vizagrams.ζ(BoxPlot()))) == 3
    end
    @testset "Graphic Expression" begin
        Random.seed!(4)
        df = DataFrame(;
            x=[1, 2, 3, 5, 1, 2],
            y=[10, 10, 20, 10, 20, 30],
            c=["a", "b", "a", "a", "b", "a"],
            d=rand([0, 1], 6),
            e=rand([1, 2, 3], 6),
        )

        plt = plot(df; x=:c, y=:y, color=:c, graphic=BoxPlot())

        # check if draw compiles
        @test string(draw(plt)) isa String

        # check number of boxplot marks
        @test length(getmark(BoxPlot, plt)) == 2
    end
end
