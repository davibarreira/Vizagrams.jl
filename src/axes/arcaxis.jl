function inferarcaxis(
    scale::Union{Linear,Categorical};
    title="angle",
    nticks=10,
    tickvalues=nothing,
    ticktexts=nothing,
    rmajor=100,
    rminor=0,
)
    (; domain, codomain) = scale

    tickvalues, ticktexts = get_tickvalues(
        scale; nticks=nticks, tickvalues=tickvalues, ticktexts=ticktexts
    )

    # Axis
    axis =
        S(
            :fillOpacity => 0, :stroke => :black
        )Slice(;
            θ=codomain[begin] + π / 2,
            ang=codomain[end] - codomain[begin],
            rminor=rminor,
            rmajor=rmajor,
        )

    # Ticks
    ticks = mapreduce(
        z -> begin
            tickvalue, ticktext = z
            angle = scale(tickvalue)
            x = cos(angle) * (rmajor)
            y = sin(angle) * (rmajor)
            tickmark = R(angle - π / 2)Rectangle(; h=4, w=1)
            tickmark = T(x, y) * tickmark

            x = cos(angle) * (rmajor + 10)
            y = sin(angle) * (rmajor + 10)
            ticktext = T(x, y) * TextMark(; text=ticktext, fontsize=7)

            tickmark + ticktext
        end,
        +,
        zip(tickvalues, ticktexts),
    )

    return axis + ticks
end
