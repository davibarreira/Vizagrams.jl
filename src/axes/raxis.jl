"""
    inferraxis(scale::Scale; title="r", nticks=10, tickvalues=nothing, ticktexts=nothing, angle=π / 2)

Create a radius axis for a polar plot.

# Arguments
- `scale::Scale`: The scale used to map data values to radius values.
- `title::String`: The title of the radius axis. Default is "r".
- `nticks::Int`: The number of ticks on the radius axis. Default is 10.
- `tickvalues::Union{Nothing, AbstractVector}`: The specific tick values to use on the radius axis. Default is `nothing`.
- `ticktexts::Union{Nothing, AbstractVector}`: The labels for the tick values on the radius axis. Default is `nothing`.
- `angle::Float64`: The angle at which the radius axis is positioned. Default is π / 2.

# Returns
- `Group`: A group of graphical elements representing the radius axis.
"""
function inferraxis(
    scale::Scale; title="r", nticks=10, tickvalues=nothing, ticktexts=nothing, angle=π / 2
)
    (; domain, codomain) = scale

    tickvalues, ticktexts = get_tickvalues(
        scale; nticks=nticks, tickvalues=tickvalues, ticktexts=ticktexts
    )

    out_circ = S(:fillOpacity => 0, :stroke => :black)Circle(; r=codomain[end])
    in_circ = S(:fillOpacity => 0, :stroke => :black)Circle(; r=codomain[begin])
    # Radius Axis
    ticks = mapreduce(
        z -> begin
            tickvalue, ticktext = z
            r = scale(tickvalue)
            x = cos(angle) * r
            y = sin(angle) * r
            text = TextMark(; text=ticktext, fontsize=7)
            h = boundingheight(text)
            w = boundingwidth(text)
            box = S(:fill => :white)U(1.4)Rectangle(; h=h, w=w)
            T(x, y) * (box + text)
        end,
        +,
        zip(tickvalues, ticktexts),
    )

    return out_circ + in_circ + ticks
end
