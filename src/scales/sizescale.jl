"""
infersizescale(data, enc)

Returns `scale` for size based on the data.
"""
function infersizescale(ds, enc)
    scale = getnested(enc, [:scale], nothing)
    datatype = getnested(enc, [:datatype], inferdatatype(ds))

    if isnothing(scale)
        if datatype == :n
            dom = unique(ds)
            ran = collect(range(3, 10, length(dom)))

            scaledomain = getnested(enc, [:scale_domain], dom)
            scalerange = getnested(enc, [:scale_range], ran)
            scale = Categorical(; domain=dom, codomain=scalerange)
        elseif datatype == :q
            dom = (minimum(ds), maximum(ds))
            ran = (3, 10)
            scaledomain = getnested(enc, [:scale_domain], dom)
            scalerange = getnested(enc, [:scale_range], ran)
            scale = Linear(; domain=scaledomain, codomain=scalerange)
        elseif datatype == :o
            dom = collect(minimum(ds):maximum(ds))
            ran = collect(range(3, 10, length(dom)))

            scaledomain = getnested(enc, [:scale_domain], dom)
            scalerange = getnested(enc, [:scale_range], ran)
            scale = Categorical(; domain=scaledomain, codomain=scalerange)
        end
    end
end

function infer_sizescale(; data, datatype, domain, codomain)
    if datatype == :n
        domain = isnothing(domain) ? unique(data) : domain
        codomain = isnothing(codomain) ? collect(range(3, 10, length(domain))) : codomain
        scale = Categorical(; domain=domain, codomain=codomain)
    elseif datatype == :q
        domain = isnothing(domain) ? (minimum(data), maximum(data)) : domain
        codomain = isnothing(codomain) ? (3, 10) : codomain
        scale = Linear(; domain=domain, codomain=codomain)
    elseif datatype == :o
        domain = isnothing(domain) ? collect(minimum(data):maximum(data)) : domain
        codomain = isnothing(codomain) ? collect(range(3, 10, length(domain))) : codomain
        scale = Categorical(; domain=domain, codomain=codomain)
    end
end
