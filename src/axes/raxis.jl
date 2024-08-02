function inferraxis(
    scale::Scale; title="r", nticks=10, tickvalues=nothing, ticktexts=nothing, angle=π / 2
)
    (; domain, codomain) = scale

    # tickvalues, ticktexts = get_tickvalues(
    #     scale; nticks=nticks, tickvalues=tickvalues, ticktexts=ticktexts
    # )

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
