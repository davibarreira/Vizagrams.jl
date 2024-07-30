function infer_encodings_fields(; data, kwargs...)
    encodings = Dict()
    for (k, v) in kwargs

        # This is the case where the variable has only the data as in x=[1,2,4]
        if isa(v, Symbol)
            encodings[k] = Dict(:field => v)
            continue
        elseif v isa Function
            fdata = StructArray(NamedTuple(Dict(k => map(v, data))))
            data = hconcat(data, fdata, "_")
            field = propertynames(data)[end]
            encodings[k] = Dict(:field => field)
            continue
        elseif v isa Vector
            fdata = StructArray(NamedTuple(Dict(k => v)))
            data = hconcat(data, fdata, "_")
            field = propertynames(data)[end]
            encodings[k] = Dict(:field => field)
            continue
        end
        encodings[k] = Dict(:field => k)

        # This is the case where the user passes the data and more x=(data=[1,2,3],datatype=:n,...)
        for (k_, v_) in pairs(v)
            if k_ == :value
                if v_ isa Vector
                    fdata = StructArray(NamedTuple(Dict(k => v_)))
                elseif v_ isa Function
                    fdata = StructArray(NamedTuple(Dict(k => map(v_, data))))
                end
                data = hconcat(data, fdata, "_")
                field = propertynames(data)[end]
                encodings[k] = Dict(:field => field)
                continue
            end
            encodings[k] = merge(encodings[k], Dict(k_ => v_))
        end
    end
    return unzip(encodings)
end

function infer_encoding_scale(; data, coordinate, framesize, variable, partial_encoding)
    data = Tables.getcolumn(data, partial_encoding[:field])
    scale = get(partial_encoding, :scale, nothing)
    domain = get(partial_encoding, :scale_domain, nothing)
    codomain = get(partial_encoding, :scale_range, nothing)
    codomain = get(partial_encoding, :scale_codomain, codomain)

    datatype = get(partial_encoding, :datatype, inferdatatype(data))

    if !isnothing(scale)
        if scale isa Function
            return GenericScale(scale)
        end
        return scale
    elseif coordinate == :cartesian
        if variable in [:x, :y]
            return infer_scale_cartesian(;
                data=data,
                framesize=framesize,
                variable=variable,
                datatype=datatype,
                domain=domain,
                codomain=codomain,
            )
        elseif variable == :color
            return infer_colorscale(;
                data=data, datatype=datatype, domain=domain, codomain=codomain
            )
        elseif variable == :size
            return infer_sizescale(;
                data=data, datatype=datatype, domain=domain, codomain=codomain
            )
        end
    elseif coordinate == :polar
        if variable == :r
            return infer_scale_cartesian(;
                data=data,
                framesize=framesize ./ 2,
                variable=variable,
                datatype=datatype,
                domain=domain,
                codomain=codomain,
            )
        elseif variable == :angle
            domain = isnothing(domain) ? inferdomain(data, datatype) : domain
            if datatype == :q
                codomain = isnothing(codomain) ? (0, 2π) : codomain
            else
                codomain = if isnothing(codomain)
                    collect(range(0, 2π; length=length(domain) + 1))[begin:(end - 1)]
                else
                    codomain
                end
                if datatype == :q
                    codomain = isnothing(codomain) ? (0, 2π) : codomain
                end
            end
        end
    end

    scaletype = getnested(partial_encoding, [:scale_type], inferscaletype(datatype))
    domain = isnothing(domain) ? inferdomain(data, datatype) : domain
    codomain = isnothing(codomain) ? (0, 1) : codomain

    if scaletype == :Categorical
        return Categorical(; domain=domain, codomain=codomain)
    elseif scaletype == :Linear
        return Linear(; domain=domain, codomain=codomain)
    end
end

function infer_encodings(; data, config, encodings)
    coordinate = get(config, :coordinate, :cartesian)
    framesize = get(config, :figsize, (300, 200))
    scales = NamedTuple(
        map(zip(keys(encodings), values(encodings))) do (k, v)
            scale = infer_encoding_scale(;
                data=data,
                coordinate=coordinate,
                framesize=framesize,
                variable=k,
                partial_encoding=v,
            )
            return (k => (scale=scale,))
        end,
    )

    return NamedTupleTools.rec_merge(encodings, scales)
end
