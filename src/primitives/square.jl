struct Square <: GeometricPrimitive
    l::Real
    c::Vector
    θ::Real
    function Square(l, c, θ)
        @assert l > 0.0 "Length must be a positive real number"
        return new(l, c, θ)
    end
end
Square(; l=1, c=[0, 0], θ=0) = Square(l, c, θ)

struct CovSquare
    _1::Vector
    _2::Vector
end
function ψ(s::CovSquare)
    l = norm(s._1 - s._2)
    c = (s._1 + s._2) / 2

    z = s._2 - s._1
    θ = atan(z[2], z[1])

    return Square(l, c, θ)
end

function ϕ(p::Square)
    return CovSquare(p.c - rotatevec([p.l / 2, 0], p.θ), p.c + rotatevec([p.l / 2, 0], p.θ))
end

act(g::G, x::CovSquare) = CovSquare(g(x._1), g(x._2))

coordinates(s::Square) = begin
    covs = ϕ(s)
    p1, p2 = covs._1, covs._2
    u = p2 - p1
    v = rotatevec(u, π / 2)
    a = p1 + v / 2
    b = p1 - v / 2
    c = p2 - v / 2
    d = p2 + v / 2
    return a, b, c, d
end
