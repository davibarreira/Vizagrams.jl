"""
inferdomain(ds, datatype)

Infers the scale domain based on the input data
and datatype.
"""
function inferdomain(ds, datatype)
    if datatype == :n
        return unique(ds)
    elseif datatype == :o
        return collect(minimum(ds):maximum(ds))
    end
    return (minimum(ds), maximum(ds))
end

"""
inferscaletype(datatype)

Infers whether the scale is Categorical or Linear.
"""
function inferscaletype(datatype)
    if datatype in [:n, :o]
        return :Categorical
    end
    return :Linear
end

"""
inferscale(spec::PlotSpec, variable::Symbol)

Given the encoding variable (e.g. :x, :y, :color, :size,...),
it infers the scale to be used.
"""
function inferscale(spec::PlotSpec, variable::Symbol)
    (; data, figsize, encodings) = spec

    enc = encodings[variable]
    ds = Tables.getcolumn(data, enc[:field])

    scale = get(enc, :scale, nothing)
    if !isnothing(scale)
        if scale isa Function
            return GenericScale(scale)
        end
        return scale
    elseif variable == :x
        enc = merge(get(spec.config, :xaxis, NamedTuple()), enc)
        return inferaxisscale(ds, enc, figsize[1])
    elseif variable == :y
        enc = merge(get(spec.config, :yaxis, NamedTuple()), enc)
        return inferaxisscale(ds, enc, figsize[2])
    elseif variable == :color
        enc = merge(get(spec.config, :color, NamedTuple()), enc)
        return infercolorscale(ds, enc)
    elseif variable == :size
        enc = merge(get(spec.config, :size, NamedTuple()), enc)
        return infersizescale(ds, enc)
    end

    datatype = getnested(enc, [:datatype], inferdatatype(ds))
    scaletype = getnested(enc, [:scale_type], inferscaletype(datatype))
    scaledomain = getnested(enc, [:scale_domain], inferdomain(ds, datatype))
    scalerange = getnested(enc, [:scale_range], (0, 1))

    if scaletype == :Categorical
        return Categorical(; domain=scaledomain, codomain=scalerange)
    elseif scaletype == :Linear
        return Linear(; domain=scaledomain, codomain=scalerange)
    end
end
