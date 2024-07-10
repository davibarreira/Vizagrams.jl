"""
function ζreduction(M::Type, x::Mark; f::Function=ζ)::TMark

It checks the type of the mark. If it matches with `M`,
then it applies `f`. To guarantee that the function
returns a `TMark`, we use the `dmlift` function
to lift the output result into a `TMark`.

By default the function applies the ζ function, which
unwraps the mark.
"""
function ζreduction(M::Type{<:Mark}, x::Mark; f::Function=ζ)::TMark
    if typeof(x) <: M
        return dmlift(f(x))
    end
    return dmlift(x)
end
function ζreduction(M::Type, x::Mark; f::Function=ζ)::TMark
    return ζreduction(mlift(M), x; f)
end

"""
function ζreduction(M::Type, d::TMark; f::Function=ζ)::TMark

Given a `TMark`, the function traverses the expression tree
and applies the ζreduction only if the leaf has the corresponding
mark `M`.

For example:
```
d = Face() + Circle()

ζreduction(Face, d, f=x->Square()) 

# Square() + Circle()
```
"""
function ζreduction(M, d::TMark; f::Function=ζ)::TMark
    return μ(fmap(x -> ζreduction(M, x; f=f), d))
end

"""
function ζreduction(M::Vector{DataType}, d::TMark; f::Function=ζ)::TMark

The ζ reduction consists in applying the ζ function over a diagram
only over an specific mark. For example, consider
```
d = Face() + Axis()
```
Note that `ζAxis()` returns a mark `Arrow`, `Ticks` and `Title`. 
We might want to modify the diagram by erasing the Arrow inside the
Axis. We can do so by
```
ζreduction([Axis,Arrow],d, f= x->NilD())
```
"""
function ζreduction(M::Vector{DataType}, x::Mark; f::Function=ζ)::TMark

    # This function iterates over the mark. If the type of x
    # is not equal to the first mark type in the vector, then
    # the function returns dmlift(x).
    # Otherwise, it applies ζreduction over `x` using the first mark type.
    # If there is only one mark type left, it then applies
    # the ζreduction with the `f` function. Otherwise,
    # it removes the first mark type from the vector of marks, and restarts the process.  
    if typeof(x) <: M[begin]
        d = ζreduction(M[begin], x)
        if length(M[(begin + 1):end]) == 1
            return ζreduction(M[end], d; f=f)
        end
        return ζreduction(M[(begin + 1):end], d; f=f)
    end
    return dmlift(x)
end
# function ζreduction(M::Vector{DataType}, d::TMark; f::Function=ζ)::TMark
#     d = foldl((acc,s)->ζreduction(s,acc), M[begin:end-1];init=d)
#     ζreduction(M[end], d, f=f)
# end
