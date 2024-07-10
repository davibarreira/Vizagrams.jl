abstract type Bezier <: GeometricPrimitive end

struct QBezier <: Bezier # Quadratic Bezier
    bpts::Vector # Base points
    cpts::Vector # Base points
    function QBezier(bpts, cpts)
        @assert length(bpts) ≥ 2 "Number of base points must be at least 2"
        @assert length(bpts) - length(cpts) == 1 "Number of control points must be one less than the number of base points"
        return new(bpts, cpts)
    end
end

QBezier(; bpts=[[-1, -1], [1, 1]], cpts=[[0, 1]]) = QBezier(bpts, cpts)
function QBezier(pts::Union{Vector,Tuple})
    bpts = pts[1:2:end]
    cpts = pts[2:2:end]
    return QBezier(bpts, cpts)
end

"""
getpoints(qb::QBezier)

Gets the `qb.bpts` and `qb.cpts` and returns a vectors
contaninig all of them, but alternating between `bpts`
and `cpts`.
"""
function getpoints(qb::QBezier)
    bpts = qb.bpts
    cpts = qb.cpts

    pts = []
    for i in eachindex(bpts)
        pts = push!(pts, bpts[i])
        if i < length(bpts)
            pts = push!(pts, cpts[i])
        end
    end
    return pts
end

"""
quadbeziermax(B::Tuple)

Given a list of three points representing a quadratic Bézier
curve, it computes the point of max with respect to the y-axis.
"""
function quadbeziermax(B::Union{Tuple,Vector})
    a = B[2] - B[1]
    b = B[3] - B[2]
    t = a[2] / (a[2] - b[2])

    points = Vector{Float64}[B[1], B[3]]
    if 0 ≤ t ≤ 1
        p = (1 - t)^2 * B[1] + 2 * (1 - t) * t * B[2] + t^2 * B[3]
        push!(points, p)
    end
    return points[findmax(x -> x[2], points)[2]]
end

"""
quadbeziermax(quadb::QBezier)

Returns the point of maxium for a QBezier.
"""
function quadbeziermax(b::QBezier)
    return foldl(
        (p, q) -> p[2] > q[2] ? p : q,
        collect(Map(quadbeziermax)(Consecutive(3; step=2)(getpoints(b)))),
    )
end

act(g::G, x::QBezier) = QBezier(map(g, x.bpts), map(g, x.cpts))

struct CBezier <: Bezier # Cubic Bezier
    bpts::Vector # Base points
    cpts::Vector # Control points
    function CBezier(bpts, cpts)
        @assert length(bpts) ≥ 2 "Number of base points must be at least 2"
        @assert 2(length(bpts) - 1) == length(cpts) "Number of control points must be equal to 2(# base points - 1)"
        return new(bpts, cpts)
    end
end

CBezier(; bpts=[[-1, -1], [1, 1]], cpts=[[-1, 1], [1, 1]]) = CBezier(bpts, cpts)

function CBezier(pts::Union{Vector,Tuple})
    bpts = pts[1:3:end]
    cpts = [pts[i] for i in 1:length(pts) if i % 3 != 1]
    return CBezier(bpts, cpts)
end

act(g::G, x::CBezier) = CBezier(map(g, x.bpts), map(g, x.cpts))

function getpoints(cb::CBezier)
    bpts = cb.bpts
    cpts = cb.cpts

    pts = Vector{Float64}[]
    for v in zip(cb.bpts, collect(Consecutive(2)(cb.cpts)))
        push!(pts, v[1])
        push!(pts, v[2]...)
    end
    push!(pts, cb.bpts[end])
    return pts
end

function rootcubicbezier(p0, p1, p2, p3)
    a = (p1 - p0)
    b = (p2 - p1)
    c = (p3 - p2)
    A = (3a - 6b + 3c)[2]
    B = (-6a + 6b)[2]
    C = 3a[2]
    if A ≈ 0
        t = -C / B
        return (t, t)
    end

    Δ = (B^2 - 4 * A * C)
    t1 = 0
    t2 = 0
    if Δ ≥ 0
        t1 = (-B + √Δ) / (2A)
        t2 = (-B - √Δ) / (2A)
    end
    return (t1, t2)
end

function cubicbeziermax(B::Union{Tuple,Vector})
    t₁, t₂ = rootcubicbezier(B...)
    points = Vector{Float64}[B[1], B[4]]
    if 0 ≤ t₁ ≤ 1
        t = t₁
        p = (1 - t)^3 * B[1] + 3 * (1 - t)^2 * t * B[2] + 3(1 - t) * t^2 * B[3] + t^3 * B[4]
        push!(points, p)
    end
    if 0 ≤ t₂ ≤ 1
        t = t₂
        p = (1 - t)^3 * B[1] + 3 * (1 - t)^2 * t * B[2] + 3(1 - t) * t^2 * B[3] + t^3 * B[4]
        push!(points, p)
    end
    return points[findmax(x -> x[2], points)[2]]
end

"""
quadbeziermax(cb::CBezier)

Returns the point of maxium for a CBezier.
"""
function cubicbeziermax(b::CBezier)
    return foldl(
        (p, q) -> p[2] > q[2] ? p : q,
        collect(Map(cubicbeziermax)(Consecutive(4; step=3)(getpoints(b)))),
    )
end
