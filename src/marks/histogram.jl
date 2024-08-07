struct Hist <: Mark
    xs::Vector
    ys::Vector
    style::S
    function Hist(xs, ys, style)
        @assert length(xs) == length(ys) throw "xs and ys must have the same number of elements."
        return new(xs, ys, style)
    end
end

Hist(; xs=[1, 2, 3, 4, 5], ys=[2, 2, 3, 1, 2], style=S()) = Hist(xs, ys, style)

function ζ(hist::Hist)::𝕋{Mark}
    (; xs, ys, style) = hist
    data = StructArray(; x=xs, y=ys)
    data = sort(StructArray(unique(data)))
    bar_width = (data.x[2] - data.x[1]) * 0.95
    bars = ∑() do row
        T(row[:x], 0) *
        S(:fillOpacity => 0.9, :fill => :steelblue) *
        style *
        Bar(; w=bar_width, h=row[:y])
    end(
        data,
    )

    return bars
end

function GraphicExpression(hist::Hist)
    return ge = data -> begin
        Hist(; xs=data.x, ys=data.y)
    end
end

"""
    bindata(x::Real, v::Vector{<:Real})
Given a value `x` and vector `v` representing the histogram bin edges,
it computes under which bin the `x` values falls in.
"""
function bindata(x::Real, v::Vector{<:Real})
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

"""
    bindata(data::Vector; nbins=10, kwargs...)

Compute the histogram for a collection and data, then computes
the respective bin position for each data point.
"""
function bindata(data::Vector; nbins=10, kwargs...)
    h = fit(Histogram, data; nbins=nbins, kwargs...)
    edges = collect(h.edges[1])
    return map(x -> bindata(x, edges), data)
end

"""
    countbin(x::Real, bins::Vector{<:Real}, w::Vector{<:Real})

Given a collection of bins and weights `w`, returns the respective weight
for the bin in which `x` falls into.
"""
function countbin(x::Real, bins::Vector{<:Real}, w::Vector{<:Real})
    bins = sort(bins)
    if x <= minimum(bins)
        return w[begin]
    elseif x >= maximum(bins)
        return w[end]
    end
    less_or_equal = findall(y -> y <= x, bins)
    # If there are no elements greater than or equal to x, return nothing or a suitable indicator
    if isempty(less_or_equal)
        return Inf
    end
    i = maximum(less_or_equal)
    return w[i]
end

"""
    countbin(data::Vector; nbins=10, kwargs...)

Given a collection of data, computes the histogram and returns the
respective count value for each data point.
"""
function countbin(data::Vector; nbins=10, kwargs...)
    h = fit(Histogram, data; nbins=nbins, kwargs...)
    edges = collect(h.edges[1])
    w = h.weights
    return map(y -> countbin(y, edges, w), data)
end

"""
    binedges(data;nbins=10,kwargs...)

Given a collection of data, computes the bins edges for the histogram.
"""
function bin_edges(data; nbins=10, kwargs...)
    h = fit(Histogram, data; nbins=nbins, kwargs...)
    edges = h.edges[1]
    return collect(edges)
end
