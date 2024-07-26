function get_tickvalues(
    scale::Union{Linear,Categorical}; nticks=10, tickvalues=nothing, ticktexts=nothing
)
    (; domain, codomain) = scale
    if isnothing(tickvalues)
        tickvalues = scale.domain
        if scale isa Linear
            tickvalues = generate_tick_labels(domain[1], domain[2], nticks)
        end
    end
    if isnothing(ticktexts)
        ticktexts = showoff(tickvalues)
    end

    return tickvalues, ticktexts
end

"""
    inferxaxis(scale::Linear, var::Symbol; nticks=10, tickvalues=nothing, ticktexts=nothing)

Infer the x-axis for a given scale and variable.
"""
function inferxaxis(
    scale::Linear; title="x", nticks=10, tickvalues=nothing, ticktexts=nothing
)
    (; domain, codomain) = scale

    tickvalues, ticktexts = get_tickvalues(
        scale; nticks=nticks, tickvalues=tickvalues, ticktexts=ticktexts
    )

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
    (; domain, codomain) = scale

    tickvalues, ticktexts = get_tickvalues(
        scale; nticks=nticks, tickvalues=tickvalues, ticktexts=ticktexts
    )

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

function inferraxis(
    scale::Linear; title="r", nticks=10, tickvalues=nothing, ticktexts=nothing, angle=π / 2
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

    # Axis
    axis = S(:fillOpacity => 0, :stroke => :black)Circle(; r=radius)

    # Ticks
    # Ticks
    ticks = mapreduce(
        z -> begin
            tickvalue, ticktext = z
            angle = scale(tickvalue)
            x = cos(angle) * (radius)
            y = sin(angle) * (radius)
            tickmark = R(angle - π / 2)Rectangle(; h=4, w=1)
            tickmark = T(x, y) * tickmark

            x = cos(angle) * (radius + 10)
            y = sin(angle) * (radius + 10)
            ticktext = T(x, y) * TextMark(; text=ticktext, fontsize=7)

            tickmark + ticktext
        end,
        +,
        zip(tickvalues, ticktexts),
    )

    return axis + ticks
end

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
