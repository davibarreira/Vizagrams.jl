struct Rectangle <: GeometricPrimitive
    h::Real
    w::Real
    c::Vector
    θ::Real
    function Rectangle(h, w, c, θ)
        @assert h ≥ 0.0 "Height must be a positive real number"
        @assert w ≥ 0.0 "Width must be a positive real number"
        return new(h, w, c, θ)
    end
end
Rectangle(; h=1, w=2, c=[0, 0], θ=0) = Rectangle(h, w, c, θ)

"""
CovRectangle
The construction of a rectangle uses the logic that
the first two points are vertices, while the third
point determines the height of the rectangle.
"""
struct CovRectangle
    _1::Vector
    _2::Vector
    _3::Vector
end

act(g::G, x::CovRectangle) = CovRectangle(g(x._1), g(x._2), g(x._3))

width(r::CovRectangle) = norm(r._1 - r._2)
height(r::CovRectangle) = begin
    a, b, c = r._1, r._2, r._3
    u = normalize(b - a)
    v = c - b
    v1 = (v ⋅ u) * u
    v2 = v - v1
    return norm(v2)
end
coordinates(r::CovRectangle) = begin
    a, b, c = r._1, r._2, r._3
    u = normalize(b - a)
    v = c - b
    v1 = (v ⋅ u) * u
    v2 = v - v1
    c = b + v2
    d = a + v2
    return a, b, c, d
end

function ψ(s::CovRectangle)
    h = height(s)
    w = width(s)
    c = sum(coordinates(s)) / 4

    z = s._2 - s._1
    θ = atan(z[2], z[1])
    return Rectangle(h, w, c, θ)
end

function ϕ(p::Rectangle)
    p1 = p.c + rotatevec([-p.w / 2, -p.h / 2], p.θ)
    p2 = p.c + rotatevec([p.w / 2, -p.h / 2], p.θ)
    p3 = p.c + rotatevec([0, p.h / 2], p.θ)
    return CovRectangle(p1, p2, p3)
end
coordinates(r::Rectangle) = coordinates(ϕ(r))

function rectangle(d1::Vector=[0, 0], d2::Vector=[1, 1])
    c = (d1 + d2) / 2
    w = norm(d2[1] - d1[1])
    h = norm(d2[2] - d1[2])
    θ = 0
    return Rectangle(h, w, c, θ)
end
