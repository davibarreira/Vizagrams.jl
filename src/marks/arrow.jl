struct Arrow <: Mark
    pts::Vector
    headsize::Real
    headstyle::Union{S,G,H}
    headmark
    function Arrow(pts, headsize, headstyle, headmark)
        @assert length(pts) > 1 "Must have at least two points."
        @assert headsize ≥ 0 "Head size must be positive"
        return new(pts, headsize, headstyle, headmark)
    end
end

function Arrow(;
    pts=[[0, 0], [1, 1]],
    headsize=0.1,
    headstyle=S(),
    headmark=RegularPolygon(; n=3, θ=0, r=headsize),
)
    return Arrow(pts, headsize, headstyle, headmark)
end
function Arrow(
    x::Vector,
    y::Vector;
    headsize=1,
    headstyle=S(),
    headmark=RegularPolygon(; n=3, θ=0, r=headsize),
)
    return Arrow(; pts=x ⊗ y, headsize=headsize, headstyle=headstyle, headmark=headmark)
end

function ζ(arrow::Arrow)::𝕋{Mark}
    l = Line(arrow.pts)
    v = l.pts[end] - l.pts[end - 1]
    if arrow.headsize == 0
        return dmlift(l)
    end

    ang = atan(v[2], v[1])

    # The increment is an adjusment so that the arrow head stars at the end of the line.
    increment = normalize(v) * arrow.headsize / 2
    t = T(l.pts[end] + increment) * R(-π / 2 + ang) * arrow.headstyle * arrow.headmark
    return l + t
end
