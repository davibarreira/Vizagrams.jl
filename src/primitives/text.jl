struct TextGeom <: GeometricPrimitive
    text::String
    pos::Vector
    fontsize::Real
    θ::Real
    fontfamily::String
    function TextGeom(text, pos, fontsize, θ, fontfamily)
        # @assert fontsize > 0.0 "Size must be a positive real number"
        return new(text, pos, fontsize, θ, fontfamily)
    end
end
struct CovText
    text::String
    _1::Vector
    _2::Vector
    fontfamily::String
end

act(g::G, x::CovText) = CovText(x.text, g(x._1), g(x._2), x.fontfamily)

function TextGeom(; text="", pos=[0, 0], fontsize=12, θ=0, fontfamily="Helvetica")
    return TextGeom(text, pos, fontsize, θ, fontfamily)
end

function ψ(s::CovText)
    l = norm(s._1 - s._2)
    c = (s._1 + s._2) / 2

    z = s._2 - s._1
    θ = atan(z[2], z[1])

    return TextGeom(s.text, c, l, θ, s.fontfamily)
end

function ϕ(p::TextGeom)
    return CovText(
        p.text,
        p.pos - rotatevec([p.fontsize / 2, 0], p.θ),
        p.pos + rotatevec([p.fontsize / 2, 0], p.θ),
        p.fontfamily,
    )
end
