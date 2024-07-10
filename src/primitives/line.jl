struct Line <: GeometricPrimitive
    pts::Vector
    function Line(pts=[[0, 0], [1, 1]])
        if length(pts) == 1
            return new([pts[1], pts[1]])
        end
        # @assert length(pts) ≥ 1 "Must have at least one point."
        return new(pts)
    end
end
# function Line(pts::Vector{Vector})
#     return Line(pts...)
# end
# Line(x::Vector, y::Vector) = Line([x, y])

Line(x::Vector, y::Vector) = Line(x ⊗ y)
# Line(; x::Vector, y::Vector) = Line(x ⊗ y)
function Line(pts::Union{Vector{<:Tuple},StructVector{<:Tuple,<:Tuple}})
    return Line(map(x -> vcat(x...), pts))
end

act(g::G, x::Line) = Line(map(g, x.pts))

coordinates(l::Line) = l.pts

# Taken from GeometryBasics.jl
# 2D Line-segment intersection algorithm by Paul Bourke and many others.
# http://paulbourke.net/geometry/pointlineplane/
"""
    intersects(a::Line, b::Line) -> Bool, Point

Intersection of 2 line segments `a` and `b`.
Returns `(intersection_found::Bool, intersection_point::Point)`
"""
function intersects(a::Line, b::Line)
    p0 = [0, 0]

    x1, y1 = a.pts[1]
    x2, y2 = a.pts[2]
    x3, y3 = b.pts[1]
    x4, y4 = b.pts[2]

    denominator = ((y4 - y3) * (x2 - x1)) - ((x4 - x3) * (y2 - y1))
    numerator_a = ((x4 - x3) * (y1 - y3)) - ((y4 - y3) * (x1 - x3))
    numerator_b = ((x2 - x1) * (y1 - y3)) - ((y2 - y1) * (x1 - x3))

    if denominator == 0
        # no intersection: lines are parallel
        return false, p0
    end

    # If we ever need to know if the lines are coincident, we can get that too:
    # denominator == numerator_a == numerator_b == 0 && return :coincident_lines

    # unknown_a and b tell us how far along the line segment the intersection is.
    unknown_a = numerator_a / denominator
    unknown_b = numerator_b / denominator

    # Values between [0, 1] mean the intersection point of the lines rests on
    # both of the line segments.
    if 0 <= unknown_a <= 1 && 0 <= unknown_b <= 1
        # Substituting an unknown back lets us find the intersection point.
        x = x1 + (unknown_a * (x2 - x1))
        y = y1 + (unknown_a * (y2 - y1))
        return true, [x, y]
    end

    # lines intersect, but outside of at least one of these line segments.
    return false, p0
end
