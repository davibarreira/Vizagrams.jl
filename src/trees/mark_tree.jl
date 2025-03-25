"""
A type `A <: Mark` must have
θ:A->𝕋{Diagram}. Thus, (A,θ) is how we define a Mark.

It is possible to construct a mark (A,θ) through
ζ:A -> TMark, where:
```
θ(a::A) = (θ ∘ ζ)(a)
```
This can give rise to circular definition. Hence,
the use must ensure that the output of
ζ is a 𝕋{B} where B is a well-define mark (i.e.
with a computable θ:B->𝕋{Diagram})

"""
abstract type Mark end

TMark = 𝕋{Mark}

# Helper function to guarantee that tree of subtypes of Mark
# are T{Mark}.
Comp(a::Mark, b::Mark) = Comp{Mark}(a, b)

dlift(m::Mark) = Pure{Mark}(m)

Valid = Union{ValidPrimitives,TDiagram,Mark,TMark}
dmlift(x::Valid)::TMark = dlift(mlift(x))
dmlift(x::TMark)::TMark = x

flatten(v::Vector{Prim})::Vector{Prim} = v
flatten(m::Mark)::Vector{Prim} = cata(alg, μ(fmap(θ, dlift(m))))
# flatten(dm::𝕋{<:Mark}) = cata(alg, μ(fmap(θ, dm)))

# μ𝕋θ: 𝕋M -> 𝕋[Prim]
# flatten ∘ μ𝕋θ: 𝕋M -> [Prim]
flatten(dm::𝕋{<:Mark})::Vector{Prim} = flatten(fmap(flatten, dm))

Pure(x::T) where {T<:Mark} = Pure{Mark}(x)

##########################################
# Derivable Marks - Lifting Marks #
##########################################

struct TM <: Mark
    _1::𝕋{<:Mark}
end
ζ(dm::TM) = dm._1
# Function to avoid JET error
function TM(x::Pure{Vector{Prim}})
    mlift(x)
end
fmap(f::Function, dm::TM) = TM(f(dm._1))
mlift(::Type{<:𝕋{<:Mark}}) = TM

struct MTDiagram <: Mark
    _1::TDiagram
end
ζ(m::MTDiagram) = dlift(m)
fmap(f::Function, x::MTDiagram) = MTDiagram(f(x._1))
mlift(::Type{<:TDiagram}) = MTDiagram

struct MPrim{T<:GeometricPrimitive} <: Mark
    _1::Prim{T}
end
MPrim(geom::GeometricPrimitive) = MPrim(Prim(geom))
ζ(mp::MPrim) = dlift(mp)
fmap(f::Function, x::MPrim) = MPrim(f(x._1))
mlift(T::Type{Prim}) = MPrim
mlift(T::Type{Prim{W}}) where {W} = MPrim{W}
mlift(T::Type{<:GeometricPrimitive}) = MPrim{T}

mlift(x::Union{GeometricPrimitive,Prim}) = MPrim(x)
mlift(x::Union{TDiagram,Vector{<:Prim},Vector{<:GeometricPrimitive}}) = MTDiagram(dlift(x))
mlift(x::TMark) = TM(x)
mlift(x::Mark) = x

# alias for mlift. The term `Mark` is easier to remmember
function Mark(x)
    return mlift(x)
end

θ(m::MPrim) = dlift(m._1)
θ(m::MTDiagram) = m._1
θ(dprim::TDiagram) = dprim
θ(dm::TMark) = μ(fmap(θ, dm))

θ(p::Union{Vector{<:Prim},T where T<:Prim,GeometricPrimitive}) = dlift(p)
θ(m::Mark) = θ(ζ(m))

NilD() = mlift(Prim[])
