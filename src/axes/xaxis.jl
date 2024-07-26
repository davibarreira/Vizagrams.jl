"""
    inferxaxis(scale::Linear, var::Symbol; nticks=10, tickvalues=nothing, ticktexts=nothing)

Infer the x-axis for a given scale and variable.
"""
function inferxaxis(
    scale::Scale; title="x", nticks=10, tickvalues=nothing, ticktexts=nothing
)
    (; domain, codomain) = scale

    tickvalues, ticktexts = get_tickvalues(
        scale; nticks=nticks, tickvalues=tickvalues, ticktexts=ticktexts
    )

    axis = Arrow(; pts=[[codomain[begin], 0], [codomain[end], 0]])

    ticks = mapreduce(
        z -> begin
            tickvalue, ticktext = z
            x = scale(tickvalue)
            T(x, -2) *
            (Rectangle(; w=1, h=4)↓(T(0, -2), TextMark(; text=ticktext, fontsize=7)))
        end,
        +,
        zip(tickvalues, ticktexts),
    )

    title = TextMark(; text=title)

    d = axis + ticks
    return d↓(T(0, -10), acenter(d, title) * title)
end
