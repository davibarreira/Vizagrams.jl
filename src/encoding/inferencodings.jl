function infer_without_data(; kwargs...)
    encodings = Dict()
    data = Dict()
    for (k, v) in kwargs
        # This is the case where the variable has only the data as in x=[1,2,4]
        if v isa Vector
            data[k] = v
            encodings[k] = Dict(:field => k)
            continue
        elseif v isa AbstractRange
            data[k] = collect(v)
            encodings[k] = Dict(:field => k)
            continue
        end

        # This is the case where the user passes the data and more x=(data=[1,2,3],datatype=:n,...)
        for (k_, v_) in pairs(v)
            if k_ == :value
                data[k] = v_
                encodings[k] = Dict(:field => k)
                continue
            end
            encodings[k] = merge(encodings[k], Dict(k_ => v_))
        end
    end
    data = StructArray(NamedTuple(data))

    return encodings, data
end

function infer_fields_data(; data, kwargs...)
    if isnothing(data)
        return infer_without_data(; kwargs...)
    end
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
        elseif v isa AbstractRange
            fdata = StructArray(NamedTuple(Dict(k => collect(v))))
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
                elseif v_ isa AbstractRange
                    fdata = StructArray(NamedTuple(Dict(k => collect(v_))))
                end
                data = hconcat(data, fdata, "_")
                field = propertynames(data)[end]
                encodings[k] = Dict(:field => field)
                continue
            end
            encodings[k] = merge(encodings[k], Dict(k_ => v_))
        end
    end
    return unzip(encodings), data
end

function infer_encoding_scale(; data, coordinate, framesize, variable, partial_encoding)
    data = Tables.getcolumn(data, partial_encoding[:field])
    datatype = get(partial_encoding, :datatype, nothing)
    domain = get(partial_encoding, :scale_domain, nothing)

    codomain = get(partial_encoding, :scale_range, nothing)
    codomain = get(partial_encoding, :scale_codomain, codomain)
    scaletype = getnested(partial_encoding, [:scale_type], nothing)
    scale = get(partial_encoding, :scale, nothing)

    return infer_scale(;
        data=data,
        variable=variable,
        scale=scale,
        domain=domain,
        codomain=codomain,
        scaletype=scaletype,
        datatype=datatype,
        coordinate=coordinate,
        framesize=framesize,
    )
end

function infer_encodings_data(; data, config, encodings=NamedTuple(), kwargs...)
    coordinate = get(config, :coordinate, :cartesian)
    framesize = get(config, :figsize, (300, 200))

    if encodings == NamedTuple()
        encodings, data = infer_fields_data(; data=data, kwargs...)
    else
        encodings, data = infer_fields_data(; data=data, encodings...)
    end
    scales = NamedTuple(
        map(zip(keys(encodings), values(encodings))) do (k, v)
            field = get(v, :field, nothing)
            datatype = get(v, :datatype, infer_datatype(Tables.getcolumn(data, field)))
            scale = infer_encoding_scale(;
                data=data,
                coordinate=coordinate,
                framesize=framesize,
                variable=k,
                partial_encoding=v,
            )
            return (k => (datatype=datatype, scale=scale))
        end,
    )

    return NamedTupleTools.rec_merge(unzip(encodings), scales), data
end
