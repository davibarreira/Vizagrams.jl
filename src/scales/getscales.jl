"""
getscales(plt::PlotSpec)

Returns a list of tuples with the encoder and the scale, e.g.
```
[(:x, Linear{Vector{Float64}, Tuple{Int64, Int64}}([9.0, 50.0], (0, 200))),
 (:y, Linear{Vector{Float64}, Tuple{Int64, Int64}}([46.0, 250.0], (0, 200)))]
```
"""
function getscales(spec::PlotSpec)
    return map(
        x -> (x, inferscale(spec, x), spec.encodings[x][:field]), keys(spec.encodings)
    )
end

getscales(plt::Plot) = getscales(plt.spec)

"""
getscale(plt::Union{PlotSpec,Plot}, scale::Symbol=:x)

Given a `plot` mark, it returns the scale for a corresponding
enconding variable. If the encoding is not in the plotspec, then
it returns an identity scale.
"""
function getscale(plt::Union{PlotSpec,Plot}, scale::Symbol=:x)
    for s in getscales(plt)
        if s[1] == scale
            return s[2]
        end
    end
    return IdScale()
end

"""
scaledata(plt::Union{PlotSpec,Plot})

Gets the scales from a plot and applies to the data according to
the encoding specification.
Returns a `StructArray` with column names corresponding to the encoders.
```
"""
function scaledata(plt::Union{PlotSpec,Plot})
    scales = getscales(plt)
    data = map(
        scale -> scale[2].(Tables.getcolumn(plt.data, plt.encodings[scale[1]][:field])),
        scales,
    )
    return StructArray(NamedTuple{tuple(map(x -> x[1], scales)...)}(data))
end
