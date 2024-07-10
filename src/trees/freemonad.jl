# Geometric Scene Description
# F is the expression Functor
@data F{a} begin
    Comp(::a, ::a)
    Act(::H, ::a)
end

fmap(f::Function, x::Comp) = Comp(f(x._1), f(x._2))
fmap(f::Function, x::Act) = Act(x._1, f(x._2))

# This is a quick fix for the case when the subtype of the vector prim is different
function Comp(x::T1 where {T1<:Vector{<:Prim}}, y::T2 where {T2<:Vector{<:Prim}})
    return Comp{Vector{Prim}}(x, y)
end

# The FreeF is the free algebra over functor F
@data FreeF{a} begin
    Pure(::a)
    FreeComp(::FreeF{a}, ::FreeF{a})
    FreeAct(::H, ::FreeF{a})
end

# The FreeF is the 𝕋 endofunctor that constructs tree expressions
𝕋 = FreeF

# Auxiliary functions to construct FreeF instances
# FreeLeaf(x::Union{FreeAct,FreeComp,FreeLeaf,FreeNil}) = x
# FreeLeaf(x::Union{FreeAct,FreeComp,FreeLeaf}) = x
FreeAct(ts::H, x::FreeAct) = FreeAct(ts * x._1, x._2)
Comp(a::𝕋, b::𝕋) = Comp{𝕋}(a, b)
Act(ts::H, b::a) where {a<:𝕋} = Act{𝕋}(ts, b)
Act(ts::H, x::FreeAct) = Act{𝕋}(ts * x._1, x._2)

# In the category of endofunctors, a monad is a monoid.
# The Free monad is a functor similar to `[]`, but in the category of endofunctors
# so that Free F is a functor that can be represented by the set
# of {1, F, FF, FFF, FFFF,...}
# The (𝕋 ∅, free) is the initial algebra of F-algebra so that
# free: F 𝕋 ∅ -> 𝕋 ∅
# Note that 𝕋 ∅ is the initial object (carrier) and free is the evaluator
unfree(x::Pure) = x._1
unfree(x::FreeComp) = Comp{𝕋}(x._1, x._2)
unfree(x::FreeAct) = Act{𝕋}(x._1, x._2)
free(x::Comp) = FreeComp(x._1, x._2)
free(x::Act) = FreeAct(x._1, x._2)

# The existence of the fmap shows that Free is a functor
fmap(f::Function, x::Pure) = Pure(f(x._1))
fmap(f::Function, x::𝕋) = free(fmap(y -> fmap(f, y), unfree(x)))

# λ: Id → G
# ρ: F∘G→ G
mcata(λ, ρ, x::Pure) = λ(x._1)
mcata(λ, ρ, x::𝕋) = ρ(fmap(y -> mcata(λ, ρ, y), unfree(x)))

# cata is the same as mcata, but for G = Id.
# The catamorphism is the universal homomorphism from (𝕋 ∅, free) to (F, eval)
# It can thus be used to evaluate the 𝕋 tree
cata(alg::Function, x::Pure) = x._1
cata(alg::Function, x::𝕋) = alg(fmap(y -> cata(alg, y), unfree(x)))

# The η and μ make 𝕋 a monad
η(x) = Pure(x)
μ(x::Pure{<:𝕋}) = x._1
μ(x::𝕋{<:𝕋}) = free(fmap(μ, unfree(x)))
