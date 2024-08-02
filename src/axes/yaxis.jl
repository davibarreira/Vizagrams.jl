"""
    inferyaxis(scale::Linear, var::Symbol; nticks=10, tickvalues=nothing, ticktexts=nothing)

Infer the y-axis for a given scale and variable.
"""
function inferyaxis(
    scale::Scale;
    title="y",
    nticks=10,
    tickvalues=nothing,
    ticktexts=nothing,
    axislength=nothing,
)
    (; domain, codomain) = scale

    tickvalues, ticktexts = get_tickvalues(
        scale; nticks=nticks, tickvalues=tickvalues, ticktexts=ticktexts
    )

    if !(ticktexts isa Vector{<:AbstractString})
        ticktexts = showoff(tickvalues)
    end

    axis = Arrow(; pts=[[0, 0], [0, axislength]])
    if isnothing(axislength)
        axis = Arrow(; pts=[[0, codomain[1]], [0, codomain[2]]])
    end

    ticks = mapreduce(
        z -> begin
            tickvalue, ticktext = z
            y = scale(tickvalue)
            T(-2, y) * (
                Rectangle(; w=4, h=1.0) ← (T(-2, 0), TextMark(; text=ticktext, fontsize=7))
            )
        end,
        +,
        zip(tickvalues, ticktexts),
    )

    title = TextMark(; text=title)

    d = axis + ticks
    return d ← (T(-10, 0), amiddle(d, title) * title)
end
