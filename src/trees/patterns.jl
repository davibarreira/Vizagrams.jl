"""
hcheckers(l::Vector{<:Valid}, nrows=2) = l |> Partition(nrows, flush=true) |> Map(x -> foldr(↓, x, init=NilD())) |> collect |> x -> foldr(→, x, init=NilD())

Given a vector of valid ``marks`` (i.e. types that can be lifted to 𝕋{Mark}), it arranges the marks 
into a checkers pattern where the size of the rows is fixed.
```
l = map(x->Style(:fill=>x)Circle(),[:red,:blue,:green,:yellow,:purple,:steelblue,:black])
hcheckers(l,2) 

#####DIAGRAM#####
     ○○○○
     ○○○
#################
```
"""
hcheckers(l::Vector{<:Valid}, nrows=2) = (x -> foldr(→, x; init=NilD()))(
    collect(Map(x -> foldr(↓, x; init=NilD()))(Partition(nrows; flush=true)(l)))
)

"""
vcheckers(l::Vector{<:Valid}, ncols=2) = l |> Partition(ncols, flush=true) |> Map(x -> foldr(→, x, init=NilD())) |> collect |> x -> foldr(↓, x, init=NilD())

Given a vector of valid ``marks`` (i.e. types that can be lifted to 𝕋{Mark}), it arranges the marks 
into a checkers pattern where the size of the columns is fixed.
```
l = map(x->Style(:fill=>x)Circle(),[:red,:blue,:green,:yellow,:purple,:steelblue,:black])
vcheckers(l,2) 

#####DIAGRAM#####
     ○○
     ○○
     ○○
     ○
#################
```
"""
vcheckers(l::Vector{<:Valid}, ncols=2) = (x -> foldr(↓, x; init=NilD()))(
    collect(Map(x -> foldr(→, x; init=NilD()))(Partition(ncols; flush=true)(l)))
)
