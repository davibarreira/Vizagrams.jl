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
    ticktextangle=0,
    ticktextsize=7,
    titlefontsize=7,
    axisarrow=nothing,
    titleangle=0,
    tickmark=Rectangle(; w=4.0, h=1),
)
    (; domain, codomain) = scale

    tickvalues, ticktexts = get_tickvalues(
        scale; nticks=nticks, tickvalues=tickvalues, ticktexts=ticktexts
    )

    if !(ticktexts isa Vector{<:AbstractString})
        ticktexts = showoff(ticktexts)
    end

    axis = Arrow(; pts=[[0, 0], [0, axislength]])
    if isnothing(axislength)
        axis = Arrow(; pts=[[0, codomain[1]], [0, codomain[2]]])
    end
    if !isnothing(axisarrow)
        axis = axisarrow
    end

    ticks = mapreduce(
        z -> begin
            tickvalue, ticktext = z
            y = scale(tickvalue)
            T(-2, y) * (
                tickmark ← (
                    T(-2, 0),
                    TextMark(; text=ticktext, fontsize=ticktextsize, angle=ticktextangle),
                )
            )
        end,
        +,
        zip(tickvalues, ticktexts),
    )

    if !(title isa Union{Mark,TMark})
        title = TextMark(; text=title, fontsize=titlefontsize, angle=titleangle)
    else
        title = title
    end

    d = axis + ticks
    return d ← (T(-10, 0), amiddle(d, title) * title)
end
