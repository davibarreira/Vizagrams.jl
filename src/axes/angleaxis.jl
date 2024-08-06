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
    ticktextmarks = map(t -> TextMark(; text=t, anchor=:c, fontsize=7), ticktexts)
    max_tick_texts_width = mapreduce(t -> boundingwidth(t), max, ticktextmarks) * 0.8

    # Ticks
    ticks = mapreduce(
        z -> begin
            tickvalue, ticktext = z
            angle = scale(tickvalue)
            x = cos(angle) * (radius)
            y = sin(angle) * (radius)
            tickmark = R(angle - π / 2)Rectangle(; h=4, w=1)
            tickmark = T(x, y) * tickmark

            x = cos(angle) * (radius + max_tick_texts_width)
            y = sin(angle) * (radius + max_tick_texts_width)
            ticktext = T(x, y) * TextMark(; text=ticktext, anchor=:c, fontsize=7)

            tickmark + ticktext
        end,
        +,
        zip(tickvalues, ticktexts),
    )

    return ticks
end
