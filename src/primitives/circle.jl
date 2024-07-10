struct Circle <: GeometricPrimitive
    r::Real
    c::Vector

    function Circle(r, c)
        @assert r > 0.0 "Radius must be a positive real number"
        return new(r, c)
    end
end
Circle(; r=1, c=[0, 0]) = r > 0.0 ? Circle(r, c) : NilD()

struct CovCircle
    _1::Vector
    _2::Vector
end
act(g::G, x::CovCircle) = CovCircle(g(x._1), g(x._2))

ψ(p::CovCircle) = Circle(norm(p._1 - p._2) / 2, (p._1 + p._2) / 2)

ϕ(p::Circle) = CovCircle(p.c - [p.r, 0], p.c + [p.r, 0])

function coordinates(p::Circle)
    r = p.r
    c = p.c
    return [[r * cos(θ) + c[1], r * sin(θ) + c[2]] for θ in 0:(2π / 100):(2π)]
end
