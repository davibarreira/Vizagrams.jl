function inferangleaxis(
    scale::Union{Linear,Categorical};
    title="angle",
    nticks=10,
    tickvalues=nothing,
    ticktexts=nothing,
    radius=100,
)
    (; domain, codomain) = scale

    tickvalues, ticktexts = get_tickvalues(
        scale; nticks=nticks, tickvalues=tickvalues, ticktexts=ticktexts
    )

    # Ticks
    ticks = mapreduce(
        z -> begin
            tickvalue, ticktext = z
            angle = scale(tickvalue)
            x = cos(angle) * (radius)
            y = sin(angle) * (radius)
            tickmark = R(angle - π / 2)Rectangle(; h=4, w=1)
            tickmark = T(x, y) * tickmark

            x = cos(angle) * (radius + 15)
            y = sin(angle) * (radius + 15)
            ticktext = T(x, y) * TextMark(; text=ticktext, anchor=:c, fontsize=7)

            tickmark + ticktext
        end,
        +,
        zip(tickvalues, ticktexts),
    )

    return ticks
end
