struct Axis <: Mark
    titlemark::TextMark
    titleplacement::Symbol
    axislength::T where {T<:Real}
    scale::Scale
    tickvalues::Vector
    tickpos::T where {T<:Union{Vector,Nothing}}
    tickpad::T where {T<:Real}
    tick::Tick
    axisarrow
    ticktexts
    ticktexts_style
end
function Axis(;
    title="",
    titlemark=TextMark(; text=title),
    titleplacement=:s,
    axislength=100,
    scale=Linear(; codomain=[0, axislength]),
    tickvalues=[0, 50, 100],
    tickpos=nothing,
    tickpad=0,
    tick=Tick(),
    axisarrow=nothing,
    ticktexts=tickvalues,
    ticktexts_style=S(),
)
    if isnothing(tickpos)
        return Axis(
            titlemark,
            titleplacement,
            axislength,
            scale,
            tickvalues,
            scale(tickvalues),
            tickpad,
            tick,
            axisarrow,
            ticktexts,
            ticktexts_style,
        )
    end
    @assert length(tickvalues) == length(tickpos) "the vector of tickvalues and tickpos must have the same length."
    return Axis(
        titlemark,
        titleplacement,
        axislength,
        scale,
        tickvalues,
        tickpos,
        tickpad,
        tick,
        axisarrow,
        ticktexts,
        ticktexts_style,
    )
end

function ζ(axis::Axis)::𝕋{Mark}
    (;
        titlemark,
        titleplacement,
        axislength,
        scale,
        tickvalues,
        tickpos,
        tickpad,
        tick,
        axisarrow,
        ticktexts,
        ticktexts_style,
    ) = axis

    (; pos, text, textplacement, fontsize, textangle, textanchor, mark) = tick

    n = length(tickvalues) - 1
    if isnothing(axisarrow)
        axisarrow = Arrow(; pts=[[0, 0], [axislength, 0]], headsize=0)
    end

    if typeof(ticktexts) == Vector{String}
        ticks = foldr(
            +,
            [
                Tick(;
                    pos=[p, -0 / 2],
                    text=v,
                    textangle=textangle,
                    mark=mark,
                    textplacement=textplacement,
                    textanchor=textanchor,
                    ticktext_style=ticktexts_style,
                ) for (v, p) in zip(ticktexts, tickpos)
            ],
        )
    else
        ticks = foldr(
            +,
            [
                Tick(;
                    pos=[p, -0 / 2],
                    text=v,
                    textangle=textangle,
                    mark=mark,
                    textplacement=textplacement,
                    textanchor=textanchor,
                    ticktext_style=ticktexts_style,
                ) for (v, p) in zip(showoff(ticktexts), tickpos)
            ],
        )
    end

    placement = Dict(
        :s => [axislength / 2, -10],
        :se => [0, -10],
        :sw => [axislength, -10],
        :c => [axislength / 2, 0],
        :e => [0, 0],
        :w => [0, 0],
        :n => [axislength / 2, 10],
        :ne => [0, 10],
        :nw => [axislength, 10],
    )
    if titleplacement in [:s, :se, :sw]
        return (
            axisarrow + ticks
        )↓(T(placement[titleplacement] + titlemark.pos), (titlemark))
    elseif titleplacement == :c
        return axisarrow + ticks + T(placement[titleplacement] + titlemark.pos) * titlemark
    elseif titleplacement == :e
        return (axisarrow + ticks) ←
               (T(placement[titleplacement] + titlemark.pos), (titlemark))
    elseif titleplacement == :w
        return (axisarrow + ticks) →
               (T(placement[titleplacement] + titlemark.pos), (titlemark))
    elseif titleplacement in [:n, :ne, :nw]
        return (
            axisarrow + ticks
        )↑(T(placement[titleplacement] + titlemark.pos), (titlemark))
    end

    return (axisarrow + ticks)↓(T([axislength / 2, -10] + titlemark.pos), (titlemark))
end

struct XAxis <: Mark
    axis::Axis
end
function ζ(xaxis::XAxis)::𝕋{Mark}
    return ζ(xaxis.axis)
end

struct YAxis <: Mark
    axis::Axis
end

function ζ(yaxis::YAxis)::𝕋{Mark}
    return R(π / 2) * ζ(yaxis.axis)
end

function Base.getproperty(axis::Union{XAxis,YAxis}, field::Symbol)
    if field == :axis
        return getfield(axis, :axis)
    end
    return getfield(getfield(axis, :axis), field)
end
Base.propertynames(axis::Union{XAxis,YAxis}) = (:axis, propertynames(axis.axis)...)
