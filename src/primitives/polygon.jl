struct Polygon <: GeometricPrimitive
    pts::Vector
end

act(g::G, x::Polygon) = Polygon(map(g, x.pts))
function Polygon(
    pts::Union{Vector{<:Tuple},StructVector{<:Tuple,<:Tuple}}=[
        [-1, -1], [-1, 1], [1, 1], [1, -1]
    ],
)
    return Polygon(map(x -> vcat(x...), pts))
end
Polygon(x::Vector, y::Vector) = Polygon(x ⊗ y)

coordinates(p::Polygon) = p.pts

struct RegularPolygon <: GeometricPrimitive
    n::Int
    c::Vector
    r::Real
    θ::Real
    function RegularPolygon(n, c, r, θ)
        @assert r ≥ 0.0 "Inscription radius must be a positive real number"
        @assert n ≥ 3 "Number of sides must be ≥ 3"
        return new(n, c, r, θ)
    end
end

struct CovRegularPolygon
    pts::Vector
end
act(g::G, x::CovRegularPolygon) = CovRegularPolygon(map(g, x.pts))

RegularPolygon(; n=5, c=[0, 0], r=1, θ=0) = RegularPolygon(n, c, r, θ)

function ψ(p::CovRegularPolygon)
    n = length(p.pts)
    c = mean(p.pts)
    r = norm(p.pts[1] - c)

    v = p.pts[1] - c
    θ = π / 2
    if iseven(n)
        θ = π / n
    end
    θ = atan(v[2], v[1]) - θ
    return RegularPolygon(n, c, r, θ)
end

function ϕ(p::RegularPolygon)
    return CovRegularPolygon(coordinates(p))
end

function coordinates(p::RegularPolygon)
    pts = []
    φ = 2π / p.n

    θ = π / 2
    if iseven(p.n)
        θ = π / p.n
    end

    for i in 1:(p.n)
        push!(pts, [p.r * cos(θ + p.θ), p.r * sin(θ + p.θ)] + p.c)
        θ += φ
    end
    return pts
end

# act(g::G, x::RegularPolygon) = Polygon(map(g, coordinates(x)))

struct QBezierPolygon <: GeometricPrimitive
    bpts::Vector
    cpts::Vector
    function QBezierPolygon(bpts, cpts)
        @assert length(bpts) ≥ 1 "Number of base points must be at least 1"
        @assert length(bpts) - length(cpts) == 0 "Number of control points must be equal to the number of base points"
        return new(bpts, cpts)
    end
end
act(g::G, x::QBezierPolygon) = QBezierPolygon(map(g, x.bpts), map(g, x.cpts))

struct CBezierPolygon <: GeometricPrimitive
    bpts::Vector
    cpts::Vector
    function CBezierPolygon(bpts, cpts)
        @assert length(bpts) ≥ 2 "Number of base points must be at least 2"
        @assert 2(length(bpts)) == length(cpts) "Number of control points must be equal to 2(# base points)"
        return new(bpts, cpts)
    end
end
act(g::G, x::CBezierPolygon) = CBezierPolygon(map(g, x.bpts), map(g, x.cpts))
