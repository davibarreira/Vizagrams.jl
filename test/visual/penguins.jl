using Vizagrams
using PalmerPenguins
using DataFrames
using Statistics

@testset "Penguins Plot" begin
    df = DataFrame(PalmerPenguins.load())
    df = dropmissing(df)

    struct Penguin <: Mark
        bill_length::Real
        bill_depth::Real
    end
    Penguin(; bill_length=40, bill_depth=20) = Penguin(bill_length, bill_depth)
    function Vizagrams.ζ(p::Penguin)::TMark
        (; bill_depth, bill_length) = p
        bill = R(-π / 2)U(1 / 30)Polygon([[-bill_depth, 0], [0, bill_length], [bill_depth, 0]])
        bill = S(:fill => :orange)T(0.5, 0) * bill
        splash = T(-0.2, 0) * QBezierPolygon([[0.2, 0], [1, 0]], [[1.0, 1], [0.5, -1]])
        splash = R(π / 4)T(-0.1, 0.1)S(:fill => :white) * splash
        eye = T(0.3, 0.3)S(:fill => :orange)Circle(r=0.1) + T(0.3, 0.3)Circle(r=0.05)
        return bill + Circle() + splash + eye
    end
    plt = plot(df,
        x=:island,
        y=:species,
        color=:species,
        bill_length=(field=:bill_length_mm, scale=IdScale()),
        bill_depth=(field=:bill_depth_mm, scale=IdScale()),
        graphic=∑(i=:x, ∑(i=:y) do row
            T(row.x[1], row.y[1])U(20) *
            S(:fill => row.color[1]) *
            Penguin(bill_length=median(row.bill_length), bill_depth=median(row.bill_depth))
        end)
    )
    @test string(draw(plt)) isa String

    # count number of penguin marks
    @test length(getmark(Penguin, plt)) == 5
end
