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
