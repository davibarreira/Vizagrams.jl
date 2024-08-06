"""
    inferxaxis(scale::Linear, var::Symbol; nticks=10, tickvalues=nothing, ticktexts=nothing)

Infer the x-axis for a given scale and variable.
"""
function inferxaxis(
    scale::Scale;
    title="x",
    nticks=10,
    tickvalues=nothing,
    ticktexts=nothing,
    axislength=nothing,
    ticktextangle=0,
    ticktextsize=7,
    titlefontsize=7,
    axisarrow=nothing,
    titleangle=0,
    tickmark=Rectangle(; w=1.0, h=5),
)
    (; domain, codomain) = scale

    tickvalues, ticktexts = get_tickvalues(
        scale; nticks=nticks, tickvalues=tickvalues, ticktexts=ticktexts
    )
    if !(ticktexts isa Vector{<:AbstractString})
        ticktexts = showoff(ticktexts)
    end

    axis = Arrow(; pts=[[0, 0], [axislength, 0]])
    if isnothing(axislength)
        axis = Arrow(; pts=[[codomain[begin], 0], [codomain[end], 0]])
    end
    if !isnothing(axisarrow)
        axis = axisarrow
    end

    ticks = mapreduce(
        z -> begin
            tickvalue, ticktext = z
            x = scale(tickvalue)
            T(x, -2) * (
                tickmark↓(
                    T(0, -2),
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
    return d↓(T(0, -10), acenter(d, title) * title)
end
