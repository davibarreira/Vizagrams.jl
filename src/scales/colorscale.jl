"""
infercolorscale(ds, enc)

Returns `scale` for color based on the data.
"""
function infercolorscale(ds, enc)
    scale = getnested(enc, [:scale], nothing)
    datatype = getnested(enc, [:datatype], inferdatatype(ds))
    if isnothing(scale)
        if datatype == :n
            defaultcolorscheme = :tableau_superfishel_stone
            colorscheme = getnested(enc, [:colorscheme], defaultcolorscheme)
            scale = Categorical(; domain=unique(ds), codomain=colorscheme)
        elseif datatype == :q
            defaultcolorscheme = :hawaii
            colorscheme = getnested(enc, [:colorscheme], defaultcolorscheme)
            scale = Linear(; domain=[minimum(ds), maximum(ds)], codomain=colorscheme)

        elseif datatype == :o
            defaultcolorscheme = :jblue
            colorscheme = getnested(enc, [:colorscheme], defaultcolorscheme)
            scale = Categorical(;
                domain=collect(minimum(ds):maximum(ds)), codomain=colorscheme
            )
        end
    end
    return scale
end

function infer_colorscale(; data, datatype, domain, codomain)
    if datatype == :n
        domain = isnothing(domain) ? unique(data) : domain
        codomain = isnothing(codomain) ? :tableau_superfishel_stone : codomain
        scale = Categorical(; domain=domain, codomain=codomain)
    elseif datatype == :q
        domain = isnothing(domain) ? [minimum(data), maximum(data)] : domain
        codomain = isnothing(codomain) ? :hawaii : codomain
        scale = Linear(; domain=domain, codomain=codomain)

    elseif datatype == :o
        domain = isnothing(domain) ? collect(minimum(data):maximum(data)) : domain
        codomain = isnothing(codomain) ? :jblue : codomain
        scale = Categorical(; domain=domain, codomain=codmain)
    end
    return scale
end
