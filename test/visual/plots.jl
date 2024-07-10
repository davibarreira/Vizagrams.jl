using Vizagrams
import Vizagrams: compare_structs
using Statistics
using ColorSchemes
using DataFrames
using Random
using LaTeXStrings
using StructArrays

@testset "Generic 2D Plots" begin
    # Metric for image distance comparison

    Random.seed!(4)
    df = DataFrame(x=[1, 2, 3, 5, 1, 2], y=[10, 10, 20, 10, 20, 30], c=["a", "b", "a", "a", "b", "a"], d=rand([0, 1], 6), e=rand([1, 2, 3], 6))
    @testset "Scatter Plot" begin
        plt = Plot(
            data=df,
            encodings=(
                x=(field=:x, datatype=:q, guide=(lim=(0, 6),)),
                y=(field=:y, datatype=:q, guide=(lim=(0, 40),)),
                color=(field=:c, datatype=:n, colorscheme=:julia),
            ),
            graphic=∑() do row
                S(:fill => row[:color])T(row[:x], row[:y])Circle(r=5)
            end
        )
        expected = Dict(:x => [50.0, 100.0, 150.0, 250.0, 50.0, 100.0],
            :y => [50.0, 50.0, 100.0, 50.0, 100.0, 150.0],
            :color => ["#1F83FF", "#CA3C32", "#1F83FF", "#1F83FF", "#CA3C32", "#1F83FF"])

        sdata = scaledata(plt)
        @test all(map(x -> getproperty(sdata, x) == expected[x], propertynames(sdata)))
        @test compare_structs(getmark(Frame, ζ(plt.spec))[1].s, Frame().s)
        @test getmark(Frame, ζ(plt.spec))[1].size == Frame().size
        @test all(map(x -> x.geom.c[1], Vizagrams.flatten(plt.graphic(sdata))) .≈ reverse(plt.graphic.coalg(sdata).x))
        @test all(map(x -> x.geom.c[2], Vizagrams.flatten(plt.graphic(sdata))) .≈ reverse(plt.graphic.coalg(sdata).y))

        # Tests whether the `drawsvg` function properly computes.
        @test string(drawsvg(plt)) isa String

    end

    @testset "Scatter with colorbar, grid and frame color" begin

        plt = Plot(
            config=(
                xaxis=(grid=(flag=true, style=S(:stroke => :white, :strokeDasharray => 10)),),
                yaxis=(grid=(flag=true, style=S(:stroke => :white, :strokeDasharray => 10)),),
                frame_style=S(:fill => :black, :fillOpacity => 0.1, :stroke => :white),
            ),
            data=df,
            encodings=(
                x=(field=:x, datatype=:q, guide=(lim=(0, 6),)),
                y=(field=:y, datatype=:q, guide=(lim=(0, 40),)),
                color=(field=:y, datatype=:q, colorscheme=(:red, :blue)),
                size=(field=:c, datatype=:n),
            ),
            graphic=scatter(opacity=1)
        )
        sdata = scaledata(plt)
        @assert all(map(x -> Vizagrams.flatten(x)[1].geom.c[1], getmarkpath(Circle, plt.graphic(sdata))) .≈ reverse(plt.graphic.coalg(sdata).x))
        @assert all(map(x -> Vizagrams.flatten(x)[1].geom.c[2], getmarkpath(Circle, plt.graphic(sdata))) .≈ reverse(plt.graphic.coalg(sdata).y))

        @test string(drawsvg(plt)) isa String
    end

    @testset "Custom Mark" begin
        struct Trip <: Mark
            c::Vector
            r::Real
            colors
        end
        Trip(; c=[0, 0], r=1, colors=(:red, :green, :blue)) = Trip(c, r, colors)
        function Vizagrams.ζ(t::Trip)
            (; c, r, colors) = t
            c1, c2, c3 = (colors, colors, colors)
            if !(colors isa Union{String,Symbol})
                c1, c2, c3 = colors
            end
            x = cos(π / 4) * r
            T(c...) * (
                S(:fill => c1)T(-x, -x)Circle(r=r / 2) +
                S(:fill => c2)T(0, r)Circle(r=r / 2) +
                S(:fill => c3)T(x, -x)Circle(r=r / 2)
            )
        end

        plt = Plot(
            data=df,
            encodings=(
                x=(field=:x, datatype=:q, guide=(lim=(0, 6),)),
                y=(field=:y, datatype=:q, guide=(lim=(0, 40),)),
                color=(field=:c, datatype=:n, colorscheme=:julia),
            ),
            graphic=∑() do row
                Trip(c=[row[:x], row[:y]], r=5, colors=row[:color])
            end
        )
        sdata = scaledata(plt)

        @test all(map(x -> x.c[1], getmark(Trip, plt.graphic(sdata))) .≈ reverse(plt.graphic.coalg(sdata).x))
        @test all(map(x -> x.c[2], getmark(Trip, plt.graphic(sdata))) .≈ reverse(plt.graphic.coalg(sdata).y))
        @test all(map(x -> x.colors, getmark(Trip, plt.graphic(sdata))) .== reverse(plt.graphic.coalg(sdata).color))

        @test all(map(x -> x.geom.r, Vizagrams.flatten(Trip())) .≈ 0.5)
        @test all(map(x -> x.geom.r, Vizagrams.flatten(getmark(Trip, plt.graphic(sdata))[1])) .≈ 2.5)

        # Tests whether the `drawsvg` function properly computes.
        @test string(drawsvg(plt)) isa String


        # usin scatter function implicitly
        plt = Plot(
            data=df,
            encodings=(
                x=(field=:x, datatype=:q, guide=(lim=(0, 6),)),
                y=(field=:y, datatype=:q, guide=(lim=(0, 40),)),
                color=(field=:c, datatype=:n, colorscheme=:julia),
            ),
            graphic=Circle(r=20)
        )
        sdata = scaledata(plt)
        @assert all(map(x -> Vizagrams.flatten(x)[1].geom.c[1], getmarkpath(Circle, plt.graphic(sdata))) .≈ reverse(plt.graphic.coalg(sdata).x))
        @assert all(map(x -> Vizagrams.flatten(x)[1].geom.c[2], getmarkpath(Circle, plt.graphic(sdata))) .≈ reverse(plt.graphic.coalg(sdata).y))

        @test string(drawsvg(plt)) isa String

    end
    @testset "Bar Plot" begin
        gdf = combine(groupby(df, :c), :x => sum, :y => sum, renamecols=false)
        plt = Plot(
            data=gdf,
            encodings=(
                x=(field=:c, datatype=:n),
                y=(field=:y, datatype=:q, guide=(lim=(0, 80),)),
                color=(field=:c, datatype=:n),
            ),
            graphic=∑() do row
                S(:fill => row[:color])T(row[:x], 0.2) * Bar(h=row[:y], w=80)
            end
        )

        sdata = scaledata(plt)

        @test all(map(x -> Vizagrams.flatten(x)[1].geom.c[1], getmarkpath(Bar, plt.graphic(sdata))) .≈ reverse(plt.graphic.coalg(sdata).x))
        @test all(map(x -> Vizagrams.flatten(x)[1].geom.h, getmarkpath(Bar, plt.graphic(sdata))) .≈ reverse(plt.graphic.coalg(sdata).y))

        # Tests whether the `drawsvg` function properly computes.
        @test string(drawsvg(plt)) isa String
    end

    @testset "Line Plot" begin
        plt = Plot(
            data=df,
            encodings=(
                x=(field=:x, datatype=:q, guide=(lim=(0, 6),)),
                y=(field=:y, datatype=:q, guide=(lim=(0, 40),)),
                color=(field=:c, datatype=:n, colorscheme=:julia),
            ),
            graphic=∑(i=:color, orderby=:x) do row
                S(:stroke => row.color[1], :strokeWidth => 2)Line(row.x, row.y)
            end
        )
        expected = Dict(:x => [50.0, 100.0, 150.0, 250.0, 50.0, 100.0],
            :y => [50.0, 50.0, 100.0, 50.0, 100.0, 150.0],
            :color => ["#1F83FF", "#CA3C32", "#1F83FF", "#1F83FF", "#CA3C32", "#1F83FF"])

        sdata = scaledata(plt)
        @test all(map(x -> x.geom.pts, Vizagrams.flatten(plt.graphic(sdata))) .== map(i -> map(x -> [x.x, x.y], i), reverse(plt.graphic.coalg(sdata))))

        # Tests whether the `drawsvg` function properly computes.
        @test string(drawsvg(plt)) isa String
    end

    @testset "Face Plot" begin
        plt = Plot(
            title="MyPlot",
            data=df,
            config=(
                frame_style=S(:stroke => :white),
                xaxis=(axisarrow=S(:stroke => :red)Arrow(pts=[[0, 0], [300, 0]], headsize=5),),
            ),
            encodings=(
                x=(field=:x, datatype=:q, guide=(lim=(0, 6),)),
                y=(field=:y, datatype=:q, guide=(lim=(0, 35),)),
                color=(field=:c, datatype=:n),
                size=(field=:e, datatype=:o, scale_range=(8, 15)),
                smile=(field=:d, scale=Linear(domain=[0, 1], codomain=[-1, 1])),
            ),
            graphic=∑(row ->
                T(row[:x], row[:y]) * U(row[:size]) *
                Face(
                    headstyle=S(:fill => row[:color]),
                    eyestyle=S(:fill => :black),
                    smile=row[:smile])
            )
        )

        # @test compare_structs(getmark([XAxis, Arrow], plt.spec)[1], Arrow(Vector[[0, 0], [300, 0]], 5))

        @test all(map(x -> x.smile, getmark(Face, plt)) .≈ [-1.0, -1.0, 1.0, 1.0, 1.0, 1.0])
        @test string(drawsvg(plt)) isa String
    end

    @testset "Stacked Bar Plot" begin

        gdf = combine(groupby(df, [:c, :d]), :x => sum, :y => sum, renamecols=false)
        plt = Plot(
            data=gdf,
            encodings=(
                x=(field=:c,),
                y=(field=:y, datatype=:q, guide=(lim=(0, 80),)),
                color=(field=:d, datatype=:n),
                text=(field=:y, scale=x -> x)
            ),
            graphic=∑(i=:x, op=+,
                ∑(i=:color, op=↑, orderby=:color, descend=false,
                    ∑(row -> begin
                        S(:fill => row[:color])T(row[:x], 0.5)Bar(h=row[:y], w=40) +
                        S(:fill => :white) * T(row[:x], row[:y] / 2) * TextMark(text=row[:text], fontsize=7)
                    end
                    )))
        )

        @test all(map(x -> x.w, getmark(Bar, plt)) .== 40)
        @test all(map(x -> x.h, getmark(Bar, plt)) .== [50, 25, 75, 100])
        @test string(drawsvg(plt)) isa String
    end

    @testset "Pizza Scatter Plot" begin
        gdf = combine(groupby(df, [:c, :d]), :x => sum, :y => sum, renamecols=false)
        plt = Plot(
            title="",
            figsize=(300, 300),
            data=gdf,
            config=(frame_style=S(:stroke => nothing),),
            encodings=(
                x=(field=:c,),
                y=(field=:y, datatype=:q, guide=(lim=(0, 80),)),
                color=(field=:d, datatype=:n),
                θ=(field=:x, datatype=:q, scale=Linear(domain=(0, sum(gdf[!, :x])), codomain=(0, 2π))),
                text=(field=:x, scale=x -> x)
            ),
            graphic=∑(i=:x, row -> begin
                r = plt.figsize[1] / 10
                T(row.:x[1], row.:y[1]) * Pizza(rmajor=r, angles=row.:θ, colors=row.:color)
            end
            )
        )

        @test all(map(x -> x.angles[1], getmark(Pizza, plt)) .≈ [0.8975979010256552, 4.039190554615448])

        @test string(drawsvg(plt)) isa String
    end

    @testset "Area Plot and ordering" begin
        plt = Plot(
            data=df,
            encodings=(
                x=(field=:x, datatype=:q, guide=(lim=(0, 6),)),
                y=(field=:y, datatype=:q, guide=(lim=(0, 40),)),
                color=(field=:c, datatype=:n, colorscheme=:julia),
            ),
            graphic=∑(i=:color, orderby=:color, descend=true, ∑(i=:color, orderby=:x) do row
                Area(pts=row.x ⊗ row.y, color=row.color[1],
                    linestyle=S(:stroke => row.color[1], :strokeWidth => 10))
            end)
        )


        # Checks if there are two area marks, with the respective correct coloring.
        @test getmark(Area, plt)[1].areastyle.d[:fill] == "#1F83FF"
        @test getmark(Area, plt)[2].areastyle.d[:fill] == "#CA3C32"

        @test string(drawsvg(plt)) isa String
    end
    @testset "Two Line Plots" begin
        f(x) = sin(x)
        g(x) = cos(√x)
        x = 0:0.01:10
        y = f.(x)
        z = g.(x)

        plt = Plot(
            data=StructArray(x=x, y=y, z=z),
            config=(
                xaxis=(grid=(flag=true,),),
                yaxis=(grid=(flag=true,),),),
            encodings=(
                x=(field=:x, datatype=:q, guide=(lim=(-1.5, 11),)),
                y=(field=:y, datatype=:q, guide=(lim=(-1.5, 1.5),)),
                z=(field=:z, datatype=:q, scale=IdScale()),
            ),
            graphic=data -> begin
                xscale = getscale(plt, :x)
                yscale = getscale(plt, :y)
                T(xscale(0), yscale(-0.2)) * (S(:fill => :white)Rectangle(w=40, h=20) + TextMark(text=L"sin(x)", anchor=:c)) +
                T(xscale(0), yscale(1.2)) * (S(:fill => :white)Rectangle(w=40, h=20) + TextMark(text=L"cos(\sqrt{x})", anchor=:c)) +
                S(:stroke => :red)Line(data.x, data.y) +
                S(:stroke => :blue)Line(data.x, yscale(data.z))
            end
        )
        @test length(getmark(Line, plt)) == 2
        @test string(drawsvg(plt)) isa String
    end

    @testset "Penguin Plot" begin

        struct PenguinBill <: Mark
            species
            bill_length::Real
            bill_depth::Real
        end
        PenguinBill(; species="Adelie", bill_length=40, bill_depth=20) = PenguinBill(species, bill_length, bill_depth)
        function Vizagrams.ζ(p::PenguinBill)::TMark
            (; species, bill_depth, bill_length) = p
            bill = R(-π / 2)U(1 / 30)Polygon([[-bill_depth, 0], [0, bill_length], [bill_depth, 0]])
            bill = S(:fill => :orange)T(0.5, 0) * bill
            splash = T(-0.2, 0) * QBezierPolygon([[0.2, 0], [1, 0]], [[1.0, 1], [0.5, -1]])
            splash = R(π / 4)T(-0.1, 0.1)S(:fill => :white) * splash
            eye = T(0.3, 0.3)S(:fill => :orange)Circle(r=0.1) + T(0.3, 0.3)Circle(r=0.05)
            return bill + Circle() + splash + eye
        end

        plt = Plot(
            data=df,
            encodings=(
                x=(field=:x, datatype=:q, guide=(lim=(0, 7),),),
                y=(field=:y, datatype=:q, guide=(lim=(0, 35),),),
                bill_d=(field=:d, datatype=:q, scale_range=(4, 20)),
                bill_l=(field=:e, datatype=:q, scale_range=(30, 50)),
                color=(field=:c, datatype=:n, colorscheme=:julia),
            ),
            graphic=∑() do row
                S(:fill => row[:color], :opacity => 1.0)T(row[:x], row[:y])U(20)PenguinBill(bill_length=row[:bill_l], bill_depth=row[:bill_d])
            end
        )


        @test length(getmark(PenguinBill, plt)) == 6
        @test string(drawsvg(plt)) isa String

    end

    @testset "plot" begin
        p = plot(x=[1, 2, 3], y=[1, 2, 3], color=[1, 2, 3], opacity=1)
        @test length(getmark(Circle, p)) == 3

        p = plot(x=[1, 2, 3], y=[1, 2, 3], color=[1, 2, 3], opacity=1, mark=Line())
        @test length(getmark(Line, p)) == 3

        p = plot(x=[1, 2, 3, 1, 2, 3], y=[1, 2, 3, 3, 2, 1], mark=Line(), color=[1, 1, 1, 2, 2, 2])
        @test length(getmark(Line, p)) == 2

        p = plot(x=[1, 2, 3, 1, 2, 3], y=[1, 2, 3, 3, 2, 1], mark=Line(), detail=[1, 1, 1, 2, 2, 2], style=S(:stroke => :red))
        @test length(getmark(Line, p)) == 2
    end
end
