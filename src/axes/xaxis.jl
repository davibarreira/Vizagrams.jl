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
)
    (; domain, codomain) = scale

    tickvalues, ticktexts = get_tickvalues(
        scale; nticks=nticks, tickvalues=tickvalues, ticktexts=ticktexts
    )

    axis = Arrow(; pts=[[0, 0], [axislength, 0]])
    if isnothing(axislength)
        axis = Arrow(; pts=[[codomain[begin], 0], [codomain[end], 0]])
    end

    ticks = mapreduce(
        z -> begin
            tickvalue, ticktext = z
            x = scale(tickvalue)
            T(x, -2) *
            (Rectangle(; w=1.0, h=5)↓(T(0, -2), TextMark(; text=ticktext, fontsize=7)))
        end,
        +,
        zip(tickvalues, ticktexts),
    )

    title = TextMark(; text=title)

    d = axis + ticks
    return d↓(T(0, -10), acenter(d, title) * title)
end

# function inferxaxis(
#     scale::Categorical; title="x", nticks=10, tickvalues=nothing, ticktexts=nothing
# )
#     (; domain, codomain) = scale

#     tickvalues, ticktexts = get_tickvalues(
#         scale; nticks=nticks, tickvalues=tickvalues, ticktexts=ticktexts
#     )

#     init_pad = (scale(sort(tickvalues)[begin + 1]) - scale(sort(tickvalues)[begin])) / 2
#     end_pad = (scale(sort(tickvalues)[end]) - scale(sort(tickvalues)[end - 1])) / 2
#     axis = Arrow(; pts=[[codomain[begin] - init_pad, 0], [codomain[end] + end_pad, 0]])

#     ticks = mapreduce(
#         z -> begin
#             tickvalue, ticktext = z
#             x = scale(tickvalue)
#             T(x, -2) *
#             (Rectangle(; w=1, h=4)↓(T(0, -2), TextMark(; text=ticktext, fontsize=7)))
#         end,
#         +,
#         zip(tickvalues, ticktexts),
#     )

#     title = TextMark(; text=title)

#     d = axis + ticks
#     return d↓(T(0, -10), acenter(d, title) * title)
# end
