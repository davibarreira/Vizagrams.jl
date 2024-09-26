struct Ellipse <: GeometricPrimitive
    rx::Real  # Semi-major axis
    ry::Real  # Semi-minor axis
    c::Vector  # Center of the ellipse
    ang::Real
end

# Constructor for Ellipse with default values
Ellipse(; rx=2, ry=1, c=[0, 0], ang=0) = Ellipse(rx, ry, c, ang)

# Covariant representation of an Ellipse (CovEllipse)
# <rx_vec, ry_vec> = 0 (inner product is zero, both vectors are perpendicular)
struct CovEllipse
    _1::Vector # rx_vec
    _2::Vector # ry_vec
    _3::Vector # center
end

# Action of a transformation group on CovEllipse
act(g::G, x::CovEllipse) = CovEllipse(g(x._1), g(x._2), g(x._3))

# Mapping from CovEllipse to Ellipse
ψ(p::CovEllipse) = Ellipse(norm(p._1 - p._3), norm(p._2 - p._3), p._3, atan2pi(p._1 - p._3))

# Mapping from Ellipse to CovEllipse
function ϕ(p::Ellipse)
    return CovEllipse(
        rotatevec([p.rx, 0], p.ang) + p.c, rotatevec([0, p.ry], p.ang) + p.c, p.c
    )
end

# """
#     coordinates(p::Ellipse)
# Generate points in the ellipse.
# """
# function coordinates(p::Ellipse)
#     a = p.rx
#     b = p.ry
#     c = p.c
#     ang = p.ang
#     return pts = [R(ang)([a * cos(θ), b * sin(θ)]) + c for θ in 0:(2π / 100):(2π)]
# end

# Function to compute a point on the ellipse for a given angle
function point_on_ellipse(angle, rx, ry, c)
    x = rx * cos(angle)
    y = ry * sin(angle)
    return c .+ [x, y]
end
