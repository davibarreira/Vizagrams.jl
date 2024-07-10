"""
rotatevec(x::Vector, θ=π / 2) = LinearMap(RotMatrix{2}(θ))(x)
"""
# rotatevec(x::Vector, θ=π / 2) = Vector(LinearMap(RotMatrix{2}(θ))(x))
function rotatevec(x, θ=π / 2)
    return Vector(R(θ)(x))
end

"""
rotate(θ::Real) = LinearMap(RotMatrix{2}(θ))
"""
rotate(θ::Real) = G(LinearMap(RotMatrix{2}(θ)))

"""
R(θ::Real)

Clockwise rotation around the origin.
"""
R(θ::Real) = G(LinearMap(RotMatrix{2}(θ)))
"""
dict_to_string(d::Dict)

Takes a dictionary such as `Dict(:fill=>:blue)` to
"fill: blue; "

"""
function dict_to_string(d::Dict)
    result = ""
    for (key, value) in d
        result *= string(key) * ": " * string(value) * "; "
    end
    return result
end

"""
clockwiseangle(v, u)

Given 2D vectors `v` and `u`, computes the clockwise angle in radians
from `v` to `u`.
"""
function clockwiseangle(v::Vector{<:Real}, u::Vector{<:Real})
    dotprod = v ⋅ u #x1*x2 + y1*y2      # Dot product between [x1, y1] and [x2, y2]
    determinant = u[1] * v[2] - v[1] * u[2]      # Determinant

    ang = atan(determinant, dotprod)  # atan2(y, x) or atan2(sin, cos)

    # Ensure the angle is positive
    if ang < 0
        ang += 2π
    end

    return ang
end

"""
uniformscaling(s, x) = LinearMap(UniformScaling(s)) * x
"""
uniformscaling(s, x) = G(LinearMap(UniformScaling(s))) * x

"""
U(s) = LinearMap(UniformScaling(s))

Uniform scaling.
"""
U(s) = G(LinearMap(UniformScaling(s)))

"""
T(x) = Translation(x)

Translation.
"""
T(x...) = G(Translation(x...))

"""
M(θ) = LinearMap([cos(2θ) sin(2θ);sin(2θ) -cos(2θ)])

Mirror over plane passing through the origin
at angle θ.
"""
M(θ) = G(LinearMap([cos(2θ) sin(2θ); sin(2θ) -cos(2θ)]))

"""
adjust_angle(angle)

Given an angle, it adjusts it to be between
0 and 2π.
"""
function adjust_angle(angle)
    while angle < 0
        angle += 2π
    end
    while angle >= 2π
        angle -= 2π
    end
    return angle
end

"""
angle_in_sector(angle, start_angle, end_angle)

Checks whether a given angle falls within the sector interval.
"""
function angle_in_sector(angle, start_angle, end_angle)
    start_angle = adjust_angle(start_angle)
    end_angle = adjust_angle(end_angle)
    angle = adjust_angle(angle)

    if start_angle ≤ end_angle
        return angle ≥ start_angle && angle ≤ end_angle
    end

    return angle ≥ start_angle || angle ≤ end_angle
end

"""
angle_between_vectors(v1::Vector{T}, v2::Vector{T}) where {T<:Real}
"""
function angle_between_vectors(v1::Vector, v2::Vector)
    angle = atan(v2[2], v2[1]) - atan(v1[2], v1[1])
    angle = angle < 0 ? angle + 2 * π : angle
    return angle
end

# """
# svector2ify(v::Vector{Vector{T}}) where {T}

# Auxiliary function that turns vectors of vectors
# into Vector of SVector{2}.
# """
# function SVector(v::Vector{Vector{T}}) where {T}
#     Vector{SVector{2,T}}(v)
# end
