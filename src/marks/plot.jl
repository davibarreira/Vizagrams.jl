struct Plot <: Mark # Unit specification taken from Vega-Lite paper
    spec::PlotSpec
    graphic::GraphicExpression
end
Plot(spec::PlotSpec; graphic::Function=x -> NilD()) = Plot(spec, GraphicExpression(graphic))

function Plot(;
    graphic::Union{GraphicExpression,Function,TMark,Mark,GeometricPrimitive,Prim}=GraphicExpression(
        x -> NilD()
    ),
    title="",
    figsize=(300, 200),
    encodings=NamedTuple(),
    config=NamedTuple(),
    data,
)
    return Plot(
        PlotSpec(title, figsize, data, unzip(encodings), unzip(config)),
        GraphicExpression(graphic),
    )
end

function Base.getproperty(plot::Plot, field::Symbol)
    if field in [:spec, :graphic]
        return getfield(plot, field)
    end
    return getfield(plot.spec, field)
end
Base.propertynames(plt::Plot) = (:spec, :graphic, propertynames(plt.spec)...)

# Necessary for using `set(plt, PropertyLens(:spec), spec)`
function Accessors.setproperties(obj::Plot, patch::NamedTuple)
    n = keys(patch)
    for i in zip(n, patch)
        if n[1] == :spec
            obj = Plot(i[2], obj.graphic)
        elseif n[1] == :graphic
            obj = Plot(obj.spec, i[2])
        end
    end
    return obj
end

# @memoize function ζ(plt::Plot)
function ζ(plt::Plot)::𝕋{Mark}
    (; spec, graphic) = plt
    sdata = scaledata(spec)
    marks = graphic(sdata)
    coord = getnested(spec.config, [:coordinate], :cartesian)
    if coord == :polar
        spec = PolarFrame(spec)
    end
    return spec + marks
end

"""
graphic(plt::Plot)
Returns the graphic part in a plot, i.e.
return plt.graphic(scaledata(plt))
```
"""
function graphic(plt::Plot)
    return plt.graphic(scaledata(plt))
end

# function Plot(;
#     mark::Union{Mark,TMark,Prim,GeometricPrimitive}=GraphicExpression(x -> NilD()),
#     kwargs...,
# )
#     return Plot(; graphic=GraphicExpression(graphic), kwargs)
# end
