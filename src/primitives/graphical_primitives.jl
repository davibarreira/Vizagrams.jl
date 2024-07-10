abstract type GeometricPrimitive end

# G = Transformation group
struct G
    g::Transformation
    function G(g=IdentityTransformation())
        return new(g)
    end
end
function (g::G)(x)
    return g.g(x)
end

struct S # using S instead of Style to avoid naming confusion with Hyperscript
    d::Dict
end
S(d::Pair) = S(Dict(d))
S(args...) = S(Dict(args))
S(nt::NamedTuple) = S(Dict(pairs(nt)))

H = Tuple{G,S}
struct Prim{T<:GeometricPrimitive}
    geom::T
    s::S
end

Prim(g::GeometricPrimitive) = Prim(g, S(Dict()))

"""
Monoidal properties of Style, G, and (G,Style)
"""
⋄(s1::S, s2::S) = S(merge(s1.d, s2.d))
neutral(::Type{S}) = S()

⋄(g1::G, g2::G) = G(g1.g ∘ g2.g)
Base.:∘(g1::G, g2::G) = G(g1.g ∘ g2.g)
neutral(::Type{G}) = G(IdentityTransformation())

neutral(::Type{Tuple{E,T}}) where {E,T} = (neutral(E), neutral(T))
⋄(e1::Tuple{G,S}, e2::Tuple{G,S}) = (e1[1] ⋄ e2[1], e1[2] ⋄ e2[2])

⋄(v1::Vector, v2::Vector) = vcat(v1, v2)
neutral(::Type{Vector{T}}) where {T} = T[]

"""
Remapping functions. By default the remapping
functions are the identity
"""
ϕ(x::GeometricPrimitive) = x
ψ(x) = x
act(g::G, x::GeometricPrimitive) = ψ(act(g, ϕ(x))) # (ψ ∘ (y->act(T,y)) ∘ ϕ)(x)

"""
coordx(t::GeometricPrimitive) = [x[1] for x in coordinates(t)]
"""
coordx(t::GeometricPrimitive) = [x[1] for x in coordinates(t)]

"""
coordy(t::Geometry) = [x[2] for x in coordinates(t)]
"""
coordy(t::GeometricPrimitive) = [x[2] for x in coordinates(t)]

function act(gs::Tuple{G,S}, x::Prim)
    return Prim(ψ(act(gs[1], ϕ(x.geom))), S(merge(gs[2].d, x.s.d)))
end
act(g::G, x::Prim) = Prim(ψ(act(g, ϕ(x.geom))), x.s)
act(s::S, x::Prim) = Prim(x.geom, S(merge(s.d, x.s.d)))
