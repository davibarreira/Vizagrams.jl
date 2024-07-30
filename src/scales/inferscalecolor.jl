"""
infercolorscale(data, enc)

Returns `scale` for color based on the data.
"""
function infer_colorscale(;
    data, variable=nothing, datatype=nothing, domain=nothing, codomain=nothing
)
    datatype = isnothing(datatype) ? inferdatatype(data)) : datatype
    if isnothing(scale)
        if datatype == :n
            defaultcolorscheme = :tableau_superfishel_stone
            colorscheme = getnested(enc, [:colorscheme], defaultcolorscheme)
            scale = Categorical(; domain=unique(data), codomain=colorscheme)
        elseif datatype == :q
            defaultcolorscheme = :hawaii
            colorscheme = getnested(enc, [:colorscheme], defaultcolorscheme)
            scale = Linear(; domain=[minimum(data), maximum(data)], codomain=colorscheme)

        elseif datatype == :o
            defaultcolorscheme = :jblue
            colorscheme = getnested(enc, [:colorscheme], defaultcolorscheme)
            scale = Categorical(;
                domain=collect(minimum(data):maximum(data)), codomain=colorscheme
            )
        end
    end
    return scale
end
