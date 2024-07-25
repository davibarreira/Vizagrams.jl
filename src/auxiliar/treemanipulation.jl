function dtreeθ(m::Act)
    g = Prim(TextGeom(; text="g,s", fontsize=1.0))
    lines = Prim(Line([[0, -1], [0, -8]]))
    return g + lines + T(0, -10) * m._2
end

function dtreeθ(m::Comp)
    cdot = Prim(Circle(), S(:stroke => :black, :fill => :white))
    lines = Prim(Line([[-1, -1], [-6, -8]])) + Prim(Line([[1, -1], [6, -8]]))
    return cdot + lines + T(-6, -10) * m._1 + T(6, -10) * m._2
end

function markname(m::Mark)
    return dlift(TextMark(; text=string(typeof(m)), fontsize=0.7))
end

"""
dtreeθ(m::Act)

Draws the tree.

```
       ∘
     ↙   ↘
    g     s
   ↙ ↘    ↓
  m1  n   m2
```
"""
dtreeθ(d::TMark) = cata(dtreeθ, fmap(markname, d))

listmarks(m::Act) = m._2
listmarks(m::Comp) = vcat(m._1, m._2)

"""
listmarks(d::Union{TMark,Mark})

Lists the marks in the leafs of a given tree, e.g.
```
       ∘
     ↙   ↘
    g     s
   ↙ ↘    ↓
  m1  n   m2
```
returns `[m1,n,m2]`.
"""
listmarks(d::TMark) = cata(listmarks, fmap(x -> Mark[x], d))
listmarks(d::Mark) = listmarks(ζ(d))

function getmarkvec(M::Type, m::Mark)
    if typeof(m) <: M
        return M[m]
    end
    return M[]
end

"""
getmark(M::Type, d::TMark) = cata(x -> getmark(M, x), d)

Given a TMark tree, this function extracts a `Vector{M}`
where the elements are of type `M`. For example,
given a mark `Plt` where `ζ(plt::Plt) = Frame() + XAxis() + YAxis()`,
we can extract the `XAxis` by
```
plt = Plt()
getmark(XAxis, ζ(plt)) # Returns XAxis()
```
E.g. let `m1::M`, `m2::M` and `n` of another type. Then:

```
       ∘
     ↙   ↘
    g     s
   ↙ ↘    ↓
  m1  n   m2
```

Returns
```
[M, M]
```

"""
getmark(M::Type{<:Mark}, d::TMark) = cata(listmarks, fmap(x -> getmarkvec(M, x), d))
getmark(M::Type{<:Mark}, d::Mark) = getmark(M, ζ(d))
getmark(M::Type{<:Mark}, d::Vector) = vcat(getmark.(M, d)...)
getmark(M::Type{<:GeometricPrimitive}, d::Union{Mark,Vector,TMark}) = getmark(MPrim{M}, d)
"""
getmark(M::Vector{DataType}, d::Union{TMark,Mark,Vector}) = foldl((acc, s) -> getmark(s, acc), M, init=d)

Pass list of Mark types in order to extract nested mark.
"""
getmark(M::Vector{DataType}, d::Union{TMark,Mark,Vector}) =
    foldl((acc, s) -> getmark(s, acc), M; init=d)

function applytomark(f::Function, M::Type, x)
    if typeof(x) <: M
        return mlift(f(x))
    end
    return x
end

"""
applytomark(f::Function, M::Type, d::TMark)

Applies a function to an specific mark in a diagram.
Note that `f` must return a result of type `Mark`.
For example, given `d = T([1,1])Frame() + Circle()`, then
```
applytomark(x->NilD(), Frame, d)
## Returns => T([1,1])*NilD() + Circle()
```
This is the same as erasing the `Frame` mark from the diagram.

"""
applytomark(f::Function, M::Type, d::TMark) = fmap(x -> applytomark(f, M, x), d)

"""
replacemark(M::Type, newmark::Mark, d::TMark)

Changes the mark in a diagram `d::TMark`. For example,
given `d = T([1,1])Frame() + Circle()`, then
```
replacemark(Frame, Face(), d)
## Returns => T([1,1])*Face() + Circle()
```

"""
replacemark(M::Type, newmark::Mark, d::TMark) = applytomark(x -> newmark, M, d)

"""
insertgs(M::Type, gs::Union{Tuple{G,Style},G,Style}, d::TMark)

Inserts a transformation (G,Style) before the mark in a diagram `d::TMark`. For example,
given `d = T([1,1])Frame() + Circle()`, then
```
insertgs(Frame, T([2,2]), d)
## Returns => T([1,1])*T([2,2])*Face() + Circle()
```

"""
insertgs(M::Type, gs::Union{Tuple{G,S},G,S}, d::TMark) = applytomark(x -> gs * x, M, d)

"""
modifymark(M::Type, nt::NamedTuple, d::TMark) = applytomark(x -> set(M, newmark, x), d)

Modifies the current mark in a diagram `d::TMark`. For example,
given `d = T(1,1)Frame(size=(10,10)) + Circle()`, then
```
modifymark(Frame, (size=(20,20),), d)
## Returns => T([1,1])*Frame(size=(20,20)) + Circle()
```

"""
modifymark(M::Type, nt::NamedTuple, d::TMark) = applytomark(x -> setfields(x, nt), M, d)

"""
getmarkpathvec(M::Type, m::Mark)

Helper function that prunes tree removing marks that are not
of a given type.
"""
function getmarkpathvec(M::Type, m::Mark)
    if typeof(m) <: M
        return TMark[dlift(m)]
    end
    return TMark[]
end

function getmarkpath(M::Type, m::Comp)
    return vcat(m._1, m._2)
end
function getmarkpath(M::Type, m::Act)
    return TMark[m._1 * i for i in m._2]
end

"""
getmarkpath(M::Type, d::TMark) = cata(x -> getmarkpath(M, x), d)

Given a TMark tree, this function extracts a `Vector{TMark}`
where the elements diagrams corresponding to marks of type `M` and the
transformations acting on them.

E.g. let `m1::M`, `m2::M` and `n` of another type. Then:

```
       ∘
     ↙   ↘
    g     s
   ↙ ↘    ↓
  m1  n   m2
```

Returns
```
[g*m1, s*m2]
```
"""
# getmarkpath(M::Type, d::TMark) = cata(x -> getmarkpath(M, x), fmap(x -> Mark[x], d))
function getmarkpath(M::Type, d::TMark)
    return cata(x -> getmarkpath(M, x), fmap(x -> getmarkpathvec(M, x), d))
end
getmarkpath(M::Type, d::Mark) = getmarkpath(M, ζ(d))
getmarkpath(M::Type{<:GeometricPrimitive}, d::TMark) = getmarkpath(mlift(M), d)
getmarkpath(M::Type{<:GeometricPrimitive}, d::Mark) = getmarkpath(mlift(M), ζ(d))

function getmarkpath(M::Type, d::Union{TMark,Mark}, g::Type{G})
    return map(x -> x._1[1], getmarkpath(M, d))
end
function getmarkpath(M::Type, d::Union{TMark,Mark}, g::Type{S})
    return map(x -> x._1[2], getmarkpath(M, d))
end
