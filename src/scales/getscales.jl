"""
getscales(plt::Union{Spec,Plot})

Returns a list of tuples with the encoder and the scale, e.g.
```
[(:x, Linear{Vector{Float64}, Tuple{Int64, Int64}}([9.0, 50.0], (0, 200))),
 (:y, Linear{Vector{Float64}, Tuple{Int64, Int64}}([46.0, 250.0], (0, 200)))]
```
"""
function getscales(spec::Spec)
    return map(k -> (k, spec.encodings[k][:scale]), keys(spec.encodings))
end

getscales(plt::Plot) = getscales(plt.spec)

"""
getscale(plt::Union{Spec,Plot}, scale::Symbol=:x)

Given a `plot` mark, it returns the scale for a corresponding
enconding variable. If the encoding is not in the plotspec, then
it returns an identity scale.
"""
function getscale(spec::Spec, scale::Symbol=:x)
    return getnested(spec.encodings, [scale, :scale])
end
function getscale(plt::Plot, scale::Symbol=:x)
    return getnested(plt.spec.encodings, [scale, :scale])
end

"""
scaledata(plt::Plot)

Gets the scales from a plot and applies to the data according to
the encoding specification.
Returns a `StructArray` with column names corresponding to the encoders.
```
"""
function scaledata(plt::Plot)
    scales = getscales(plt)
    data = map(
        scale -> scale[2].(Tables.getcolumn(plt.data, plt.encodings[scale[1]][:field])),
        scales,
    )
    return StructArray(NamedTuple{tuple(map(x -> x[1], scales)...)}(data))
end

function scaledata(spec::Spec, data)
    data = map(var -> var.scale.(Tables.getcolumn(data, var.field)), spec.encodings)
    return StructArray(data)
end
