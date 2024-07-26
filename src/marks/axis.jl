"""
    inferxaxis(scale::Linear, var::Symbol; nticks=10, tickvalues=nothing, ticktexts=nothing)

Infer the x-axis for a given scale and variable.
"""
function inferxaxis(
    scale::Linear; title="x", nticks=10, tickvalues=nothing, ticktexts=nothing
)
    # How this function works:
    # It generates tick values based on Wilks algo. The user can instead
    # pass the tickvalues and ticktexts directly
    # It then constructs the axis as an Arrow mark, together with the ticks
    # using each tickvalue and the scale to place it properly.
    # The size of the axis is given by the codomain (range) of the scale
    # At last, the title is placed.

    (; domain, codomain) = scale

    if isnothing(tickvalues)
        tickvalues = generate_tick_labels(domain[1], domain[2], nticks)
    end
    if isnothing(ticktexts)
        ticktexts = showoff(tickvalues)
    end

    axis = Arrow(; pts=[[codomain[1], 0], [codomain[2], 0]])

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

"""
    inferyaxis(scale::Linear, var::Symbol; nticks=10, tickvalues=nothing, ticktexts=nothing)

Infer the y-axis for a given scale and variable.
"""
function inferyaxis(
    scale::Linear; title="y", nticks=10, tickvalues=nothing, ticktexts=nothing
)
    # How this function works:
    # It generates tick values based on Wilks algo. The user can instead
    # pass the tickvalues and ticktexts directly
    # It then constructs the axis as an Arrow mark, together with the ticks
    # using each tickvalue and the scale to place it properly.
    # The size of the axis is given by the codomain (range) of the scale
    # At last, the title is placed.

    (; domain, codomain) = scale
    if isnothing(tickvalues)
        tickvalues = generate_tick_labels(domain[1], domain[2], nticks)
    end
    if isnothing(ticktexts)
        ticktexts = showoff(tickvalues)
    end

    axis = Arrow(; pts=[[0, codomain[1]], [0, codomain[2]]])

    ticks = mapreduce(
        z -> begin
            tickvalue, ticktext = z
            y = scale(tickvalue)
            T(-2, y) *
            (Rectangle(; w=4, h=1) ← (T(-2, 0), TextMark(; text=ticktext, fontsize=7)))
        end,
        +,
        zip(tickvalues, ticktexts),
    )

    title = TextMark(; text=title)

    d = axis + ticks
    return d ← (T(-10, 0), amiddle(d, title) * title)
end
