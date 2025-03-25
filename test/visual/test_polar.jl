using Vizagrams
using DataFrames
using Random

@testset "Polar Plots" begin
    Random.seed!(4)
    df = DataFrame(;
        x=[1, 2, 3, 5, 1, 2],
        y=[10, 10, 20, 10, 20, 30],
        c=["a", "b", "a", "a", "b", "a"],
        d=rand([0, 1], 6),
        e=rand([1, 2, 3], 6),
        k=["key1", "key2", "key3", "key4", "key5", "key6"],
    )
    @testset "Pizza Plot" begin
        plt = Plot(;
            figsize=(300, 250),
            data=df,
            encodings=(
                color=(field=:k, datatype=:n),
                angle=(
                    field=:x, datatype=:q, scale_domain=(0, sum(df.x)), scale_range=(0, 2π)
                ),
                r=(field=:y, scale_range=(80, 120)),
            ),
            graphic=Pizza(),
        )

        # Tests whether diagram compiles
        @test string(drawsvg(plt)) isa String

        # Counting slices 
        @test length(getmark([Pizza, Slice], plt)) == 6
    end
    @testset "Radar Plot" begin
        plt = Plot(;
            figsize=(300, 300),
            data=df,
            config=(coordinate=:polar,),
            encodings=(
                r=(
                    field=:y,
                    datatype=:q,
                    scale_domain=(0, maximum(df[!, :y])),
                    scale_range=(0, 150),
                ),
                angle=(
                    field=:k,
                    datatype=:n,
                    scale_range=collect(range(0, 2π; length=length(unique(df.k)) + 1))[begin:(end - 1)],
                ),
            ),
            graphic=Polygon() + S(:fill => :steelblue, :opacity => 1)Circle(; r=10),
        )
        # Tests whether diagram compiles
        @test string(drawsvg(plt)) isa String

        # Counting Marks 
        @test length(getmark(Circle, plt)) == 6
        @test length(getmark(Polygon, plt)) == 1
    end
    @testset "Line Radar Plot" begin
        plt = Plot(;
            figsize=(300, 300),
            data=df,
            config=(guide=(a_tick_flag=:in,), coordinate=:polar),
            encodings=(
                r=(
                    field=:y,
                    datatype=:q,
                    scale_domain=(0, maximum(df[!, :y]) + 10),
                    scale_range=(70, 150),
                ),
                angle=(
                    field=:k,
                    datatype=:n,
                    scale_range=collect(range(0, 2π; length=length(unique(df.k)) + 1))[begin:(end - 1)],
                ),
                color=(field=:d, datatype=:n),
                size=(field=:e, datatype=:q),
            ),
            graphic=Line() + S(:opacity => 1)Circle(),
        )

        # Tests whether diagram compiles
        @test string(drawsvg(plt)) isa String

        # Counting Marks 
        @test length(getmark(Circle, plt)) == 6
        @test length(getmark(Line, plt)) == 2
    end
end
