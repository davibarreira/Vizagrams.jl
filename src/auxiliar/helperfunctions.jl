"""
⊗(x,y) = collect(zip(x,y))

Used to turn two lists into a list
of tuples, e.g.
```

([1,2,3],[4,5,6]) -> [(1,4),(2,5),(3,6)]
```
"""
⊗(x, y) = collect(zip(x, y))

"""
getnested(d::Dict, symbolslist::Vector{Symbol}, default=nothing)
    value = foldl((acc, s) -> get(acc, s, Dict()), symbolslist, init=d)
    if value == Dict()
        return default
    end
    return value
end


getnested(d::NamedTuple, symbolslist::Vector{Symbol}, default=nothing)
    value = foldl((acc, s) -> get(acc, s, NamedTuple()), symbolslist, init=d)
    if value == NamedTuple()
        return default
    end
    return value
end
"""
function getnested(d::Dict, symbolslist::Vector{Symbol}, default=nothing)
    value = foldl((acc, s) -> get(acc, s, Dict()), symbolslist; init=d)
    if value == Dict()
        return default
    end
    return value
end

function getnested(d::NamedTuple, symbolslist::Vector{Symbol}, default=nothing)
    value = foldl((acc, s) -> get(acc, s, NamedTuple()), symbolslist; init=d)
    if value == NamedTuple()
        return default
    end
    return value
end

"""
set(obj, nt::NamedTuple) = foldl((acc, s) -> set(acc, PropertyLens(s[1]), s[2]), pairs(nt), init=obj)

Extension of the `set` function in Accessors.jl using named tuples.
```
r = Rectangle(h=1,w=1)
v = (h=10,w=10)
set(r,v)
# Returns a rectangle struct with `h=10` and `w=10`.
```
Note that is does not modify the original `r`.
"""
setfields(obj, nt::NamedTuple) =
    foldl((acc, s) -> set(acc, PropertyLens(s[1]), s[2]), pairs(nt); init=obj)

# """
# select(t::Tuple, v::Union{Vector,Int}) = tuple(collect(t)[v]...)
# Given a tuple and a list of indices, it returns the subtuple.
# """
# select(t::Tuple, v::Union{Vector,Int}) = tuple(collect(t)[v]...)

# """
# getcols(x, i) = foldr((s, acc) -> vcat(acc, select(s, i)), x, init=[])
# Given a vector of tuples, it selects the "columns" given a list
# of the columns.
# """
# getcols(x, i) = foldr((s, acc) -> vcat(acc, select(s, i)), x, init=[])
"""
getcol(data::StructArray, col) = StructArray(getproperty(data, Meta.parse(string(col))))
"""
function getcol(data::StructArray, col, default=nothing)
    cols = propertynames(data)
    if !(col in cols)
        return default
    end
    return getproperty(data, Meta.parse(string(col)))
end

"""
getcols(data::StructArray, cols) = StructArray(tuple(map(x -> getproperty(data, Meta.parse(string(x))), cols)...))
"""
getcols(data::StructArray, cols) =
    StructArray(tuple(map(x -> getproperty(data, Meta.parse(string(x))), cols)...))
getcols(data, indices) =
    map(data) do row
        (i -> row[i]).(indices)
    end

"""
insertcol(data::StructArray, col::Pair) = insert(data, PropertyLens(col[1]), col[2])

Adds a column to a StructArray.
"""
insertcol(data::StructArray, col::Pair) = insert(data, PropertyLens(col[1]), col[2])

"""
addcol(data::StructArray, cols) = foldl((acc, s) -> insert(acc, PropertyLens(s[1]), s[2]), cols, init=data)

Adds columns to a StructArray.
The `cols` must be a tuple of pairs, e.g. `(:a=>[1,2],:b=>[1,2])`.
"""
insertcol(data::StructArray, cols) =
    foldl((acc, s) -> insert(acc, PropertyLens(s[1]), s[2]), cols; init=data)

"""
hconcat(d1::StructArray, d2::StructArray)

Makes a wider StructArray by horizontal concatenation. Concatenation is
row_wise. Hence, they must have the same number of rows.

```
d1 = StructArray(x=[1,2],y=[3,4])
d2 = StructArray(x=["a","b"])

hconcat(d1,d2)
# Returns
# StructArray(x_1=[1,2],y=[3,4],x_2=["a","b"])
```

"""
function hconcat(d1::StructArray, d2::StructArray)
    cols1, cols2 = propertynames(d1), propertynames(d2)
    is = intersect(cols1, cols2)
    cols1 = map(x -> x in is ? Symbol("$(x)_1") : x, cols1)
    cols2 = map(x -> x in is ? Symbol("$(x)_2") : x, cols2)
    if !isempty(intersect(cols1, cols2))
        matchcols = intersect(cols1, cols2)
        throw(
            "Columns naming must be distinct. There are two columns with names $matchcols. Note this function attaches _1 and _2 to the end of the names.",
        )
    end
    t1 = map(x -> (getproperty(d1, x)), propertynames(d1))
    t2 = map(x -> (getproperty(d2, x)), propertynames(d2))
    return StructArray(NamedTuple{(cols1..., cols2...)}(t1..., t2...))
end

"""
hconcat(d1::StructArray, d2::StructArray, prepend_name::String)

Makes a wider StructArray by horizontal concatenation. Concatenation is
row_wise. Hence, they must have the same number of rows.

```
d1 = StructArray(x=[1,2],y=[3,4])
d2 = StructArray(x=["a","b"])

hconcat(d1,d2,"_")
# Returns
# StructArray(x=[1,2],y=[3,4],_x=["a","b"])
```
"""
function hconcat(d1::StructArray, d2::StructArray, prepend_name::String)
    cols1, cols2 = propertynames(d1), propertynames(d2)
    is = intersect(cols1, cols2)
    cols2 = map(x -> x in is ? Symbol("$(prepend_name)$(x)") : x, cols2)
    if !isempty(intersect(cols1, cols2))
        matchcols = intersect(cols1, cols2)
        throw(
            "Columns naming must be distinct. There are two columns with names $matchcols. Note this function attaches _1 and _2 to the end of the names.",
        )
    end
    t1 = map(x -> (getproperty(d1, x)), propertynames(d1))
    t2 = map(x -> (getproperty(d2, x)), propertynames(d2))
    return StructArray(NamedTuple{(cols1..., cols2...)}(t1..., t2...))
end

"""
hconcat(d1::StructArray; kwargs...)

To quickly concatenate values to a StructArray, e.g.
```
d1 = StructArray(x=[1,2])
hconcat(x,y=[4,5])
```
"""
function hconcat(d1::StructArray; kwargs...)
    if isempty(kwargs)
        return d1
    end
    return hconcat(d1, StructArray(NamedTuple(kwargs)))
end
"""
unzip(d::Dict)

Turns a nested dictionary into a named tuple.
"""
unzip(d::Dict) = (; (p.first => unzip(p.second) for p in d)...)
unzip(d) = d
# """
# addcol(data::StructArray, col::Pair) = insert(data, PropertyLens(col[1]), col[2])

# Add a column to a StructArray.
# """
# addcol(data::StructArray, col::Pair) = insert(data, PropertyLens(col[1]), col[2])

### Direct Implementation without using `insert` from Accessors
# function addcol(data::StructArray; kwargs...)
#     cols = propertynames(data)
#     newcol = keys(kwargs)
#     @show tuple(values(kwargs)...)
#     StructArray(NamedTuple{(cols..., newcol...)}((map(s -> get(data, s), cols)..., tuple(values(kwargs)...)...)))
# end

# function addcol(data::StructArray, nt::NamedTuple)
#     cols = propertynames(data)
#     newcol = keys(nt)
#     StructArray(NamedTuple{(cols..., newcol...)}((map(s -> get(data, s), cols)..., values(nt)...)))
# end
