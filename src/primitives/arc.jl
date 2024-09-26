struct Arc <: GeometricPrimitive
    rx::Real      # Semi-major axis
    ry::Real      # Semi-minor axis
    c::Vector     # Center of the arc
    rot::Real     # Rotation angle for the ellipse
    initangle::Real  # Initial sector angle for the arc
    finalangle::Real # Final sector angle for the arc
    function Arc(rx, ry, c, rot, initangle, finalangle)
        @assert rx > 0.0 "Radius must be a positive real number"
        @assert ry ≥ 0.0 "Radius must be a positive real number"
        if finalangle ≈ 2π || finalangle ≥ 2π
            finalangle = 2π * 0.999999
        end

        return new(rx, ry, c, rot, initangle, finalangle)
    end
end

"""
    Arc(; rx=1, ry=1, c=[0, 0], rot=0, initangle=0, finalangle=π / 2)

Creates an `Arc` object with the specified parameters.

# Arguments
- `rx::Float64`: The x-radius of the arc. Default is `1`.
- `ry::Float64`: The y-radius of the arc. Default is `1`.
- `c::Vector{Float64}`: The center coordinates of the arc as a 2-element vector. Default is `[0, 0]`.
- `rot::Float64`: The rotation angle of the arc in radians. Default is `0`.
- `initangle::Float64`: The initial angle of the arc in radians. Default is `0`.
- `finalangle::Float64`: The final angle of the arc in radians. Default is `π / 2`.

# Returns
- An `Arc` object with the specified parameters.
"""
function Arc(; rx=1, ry=1, c=[0, 0], rot=0, initangle=0, finalangle=π / 2)
    return Arc(rx, ry, c, rot, initangle, finalangle)
end

struct CovArc
    _1::Vector # ellipse rx
    _2::Vector # ellipse ry
    _3::Vector # center
    _4::Vector # point1
    _5::Vector # point2
end

act(g::G, x::CovArc) = CovArc(g(x._1), g(x._2), g(x._3), g(x._4), g(x._5))

function ψ(p::CovArc)
    rx = norm(p._1 - p._3)
    ry = norm(p._2 - p._3)
    c = p._3
    rot = atan2pi(p._1 - p._3)
    initangle = atan2pi(p._4) - rot
    finalangle = atan2pi(p._5) - rot
    return Arc(rx, ry, c, rot, initangle, finalangle)
end

function ϕ(p::Arc)
    p1 = rotatevec([p.rx, 0], p.rot) + p.c
    p2 = rotatevec([0, p.ry], p.rot) + p.c
    p3 = p.c
    p4 = rotatevec(point_on_ellipse(p.initangle, p.rx, p.ry, p.c), p.rot)
    p5 = rotatevec(point_on_ellipse(p.finalangle, p.rx, p.ry, p.c), p.rot)
    return CovArc(p1, p2, p3, p4, p5)
end

# function coordinates(p::Arc)
#     a = p.rx
#     b = p.ry
#     c = p.c
#     ang = p.rot
#     return pts = [
#         R(ang)([a * cos(θ), b * sin(θ)]) + c for
#         θ in range(p.initangle + ang, p.finalangle + ang, 100)
#     ]
# end
