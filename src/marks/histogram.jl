struct Hist <: Mark
    xs::Vector
    ys::Vector
    style::S
end

Hist(; xs=[1, 2, 3, 4, 5], ys=[2, 2, 3, 1, 2], style=S()) = Hist(xs, ys, style)

function ζ(hist::Hist)::𝕋{Mark}
    (; xs, ys, style) = hist
    data = StructArray(; x=xs, y=ys)
    bar_width = (data.x[2] - data.x[1]) * 0.95
    bars = ∑() do row
        T(row[:x], 0) *
        S(:fillOpacity => 0.9, :fill => :steelblue) *
        style *
        Bar(; w=bar_width, h=row[:y])
    end(
        data,
    )

    return bars
end

function GraphicExpression(hist::Hist)
    ge =
        data -> begin
            bar_width = (data.x[2] - data.x[1]) * 0.95
            bars = ∑() do row
                T(row[:x], 0) *
                S(:fillOpacity => 0.9, :fill => :steelblue) *
                hist.style *
                Bar(; w=bar_width, h=row[:y])
            end(
                data,
            )
        end
    return GraphicExpression(ge)
end
