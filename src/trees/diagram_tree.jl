# Our 𝕋 is a free monad.
Diagram = Vector{<:Prim}
TDiagram = 𝕋{<:Vector{<:Prim}}

# alg:F[Prim] -> [Prim] is an F-Algebra

fmap(f::Function, v::Vector{Prim}) = map(f, v)

alg(x::Comp{Vector{Prim}}) = vcat(x._1, x._2)
alg(x::Act{Vector{Prim}})::Vector{Prim} = map(y -> act(x._1, y), x._2)

# x->cata(alg, x) : 𝕋[Prim] -> [Prim] is a 𝕋-Algebra
"""
flatten(x::TDiagram) = cata(alg, x)

`𝕋[Prim] -> [Prim]`

Flattens 𝕋 into a list of primitives.
"""
flatten(x::TDiagram)::Vector{Prim} = cata(alg, x)

dlift(g::GeometricPrimitive) = η([Prim(g)])
dlift(p::Prim) = η([p])
dlift(p::Vector{<:Prim}) = η(p)
dlift(g::Vector{<:GeometricPrimitive}) = η(map(Prim, g))
# dlift(g::Vector{<:Prim}) = FreeLeaf(η(map(Prim, g)))
dlift(d::𝕋) = d

ValidPrimitives = Union{
    Vector{Prim},Prim,GeometricPrimitive,Vector{<:Prim},Vector{<:GeometricPrimitive}
}
flatten(x::ValidPrimitives)::Vector{Prim} = cata(alg, dlift(x))

# FreeComp(x::FreeF{<:Mark}, y::FreeF{<:Mark}) = FreeComp{Mark}(x, y)
Pure(x::T) where {T<:Vector{<:Prim}} = Pure{Vector{Prim}}(x)
Pure(x::T) where {T<:𝕋} = Pure{FreeF}(x)
