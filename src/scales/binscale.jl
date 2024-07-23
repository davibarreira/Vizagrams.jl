struct BinScale <: Scale
    f # aggregate the value and the codomain
    domain # bins edges
    codomain # linear codomain
end

function BinScale(reducer=nothing; data, codomain=[0, 100], nbins=10)
    h = fit(Histogram, data; nbins=nbins)
    bins = collect(h.edges[begin])
    if isnothing(reducer)
        return BinScale(x -> binscale(x, bins), bins, codomain)
    end
    ids = map(x -> searchsortedlast(bins, x), data)
    binneddata = map(i -> data[findall(x -> x == i, ids)], 1:length(bins))
    w = map(data -> reducer(data), binneddata)
    domain = [minimum(w), maximum(w)]
    return BinScale(x -> reducerbinscale(x, bins, w), domain, codomain)
end

function reducerbinscale(x::Real, bins::Vector{<:Real}, w::Vector{<:Real})
    bins = sort(bins)
    if x <= minimum(bins)
        return 0
    elseif x >= maximum(bins)
        return 0
    end
    greater_or_equal = findall(y -> y >= x, bins)
    # If there are no elements greater than or equal to x, return nothing or a suitable indicator
    if isempty(greater_or_equal)
        return Inf
    end
    # Return the minimum of the filtered elements
    i = minimum(greater_or_equal) - 1
    return w[i]
end

"""
binscale(x::Real, v::Vector{<:Real})

Given a value `x` and a list of values `[y1,y2,...,yn]`, computes the bins
and returns the center of the bin containing `x`, for example:
```
x = 1.2
v = [1,2,3]
binscale(x,v) # returns 1.5
```
"""
function binscale(x::Real, v::Vector{<:Real})
    v = sort(v)
    centers = collect(Map(x -> (x[2] + x[1]) / 2)(Consecutive(2; step=1)(collect(v))))
    if x <= minimum(v)
        return centers[begin]
    elseif x >= maximum(v)
        return centers[end]
    end
    greater_or_equal = findall(y -> y >= x, v)
    # If there are no elements greater than or equal to x, return nothing or a suitable indicator
    if isempty(greater_or_equal)
        return Inf
    end
    # Return the minimum of the filtered elements
    i = minimum(greater_or_equal) - 1
    return centers[i]
end

function applyscale(x, scale::BinScale)
    (; f, domain, codomain) = scale
    # x = binscale(x, domain)
    x = f(x)
    lin_domain = [minimum(domain), maximum(domain)]
    linscale = Linear(lin_domain, codomain)
    return linscale(x)
end

function (scale::BinScale)(x::Vector)
    return scale.(x)
end
