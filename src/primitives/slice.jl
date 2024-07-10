struct Slice <: GeometricPrimitive
    rmajor::Real
    rminor::Real
    c::Vector
    ang::Real # internal angle of the slice
    θ::Real # rotation angle of the slice

    function Slice(rmajor, rminor, c, ang, θ)
        @assert rmajor ≥ rminor "Major radius must be ≥ than the minor radius"
        @assert rmajor > 0.0 "Major radius must be a positive real number"
        @assert rminor ≥ 0.0 "Minor radius must be a zero or positive real number"
        @assert ang ≥ 0.0 "Angle must be larger than 0"
        if ang ≈ 2π || ang ≥ 2π
            ang = 2π * 0.999999
        end

        return new(rmajor, rminor, c, ang, adjust_angle(θ))
    end
end
Slice(; rmajor=1, rminor=0, c=[0, 0], ang=π / 2, θ=0) = Slice(rmajor, rminor, c, ang, θ)

struct CovSlice
    _1::Vector
    _2::Vector
    _3::Vector
    _4::Vector
end
act(g::G, x::CovSlice) = CovSlice(g(x._1), g(x._2), g(x._3), g(x._4))

function ψ(p::CovSlice)
    c = p._1
    rmajor = norm(p._1 - p._2)
    rminor = norm(p._1 - p._4)
    v = p._2 - c
    u = p._3 - c
    ang = angle_between_vectors(v, u)
    θ = angle_between_vectors([0, -1], v)
    return Slice(rmajor, rminor, c, ang, θ)
end

function ϕ(p::Slice)
    p₁ = p.c
    p₂ = R(p.θ - π / 2)([p.rmajor, 0]) + p.c
    p₃ = (R(+p.ang - π / 2) ∘ R(p.θ))([p.rmajor, 0]) + p.c
    p₄ = R(p.θ - π / 2)([p.rminor, 0]) + p.c
    return CovSlice(p₁, p₂, p₃, p₄)
end