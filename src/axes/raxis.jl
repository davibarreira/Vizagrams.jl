function inferraxis(
    scale::Scale; title="r", nticks=10, tickvalues=nothing, ticktexts=nothing, angle=π / 2
)
    (; domain, codomain) = scale

    tickvalues, ticktexts = get_tickvalues(
        scale; nticks=nticks, tickvalues=tickvalues, ticktexts=ticktexts
    )

    # axis = Arrow(; pts=[[0, codomain[1]], [0, codomain[2]]])

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

    return ticks
end
