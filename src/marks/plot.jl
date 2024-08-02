struct Plot <: Mark # Unit specification taken from Vega-Lite paper
    data
    spec::Spec
    graphic::GraphicExpression
end
function Plot(
    data,
    spec::Spec,
    graphic::Union{GraphicExpression,Function,TMark,Mark,GeometricPrimitive,Prim},
)
    return Plot(data, spec, GraphicExpression(graphic))
end

"""
Plot(;
    data=nothing,
    title="",
    figsize=(300, 200),
    encodings=NamedTuple(),
    config=NamedTuple(),
    coordinate=:cartesian,
    graphic::Union{GraphicExpression,Function,TMark,Mark,GeometricPrimitive,Prim}=Circle(;
        r=3
    ),
    kwargs...,
)

Creates a plot.
```julia
plt = Plot(x=rand(10),y=rand(10))

data = StructArray(x=rand(10),y=rand(10))
plt = Plot(data, x=:x,y=:y)

plt = Plot(data, x=:x,y=:y)
```

"""
function Plot(;
    data=nothing,
    title="",
    figsize=(300, 200),
    encodings=NamedTuple(),
    config=NamedTuple(),
    coordinate=:cartesian,
    graphic::Union{GraphicExpression,Function,TMark,Mark,GeometricPrimitive,Prim}=Circle(;
        r=3
    ),
    kwargs...,
)
    # Guess which type of coordinate to use based on the encodings.
    #
    default_config = (title=title, figsize=figsize, coordinate=nothing)
    if !isnothing(get(encodings, :x, nothing)) || haskey(kwargs, :x)
        default_config = (title=title, figsize=figsize, coordinate=:cartesian)
    end

    config = NamedTupleTools.rec_merge(default_config, config)

    if !isnothing(data)
        data = StructArray(Tables.rowtable(data))
        encodings, data = infer_encodings_data(;
            data=data, config=config, encodings=encodings, kwargs...
        )
    elseif length(kwargs) != 0
        encodings, data = infer_encodings_data(;
            data=data, config=config, encodings=encodings, kwargs...
        )
    end

    spec = Spec(unzip(config), unzip(encodings))
    return Plot(data, spec, GraphicExpression(graphic))
end

function Base.getproperty(plot::Plot, field::Symbol)
    if field in [:data, :spec, :graphic]
        return getfield(plot, field)
    end
    return getfield(plot.spec, field)
end
Base.propertynames(plt::Plot) = (:spec, :graphic, propertynames(plt.spec)...)

# Necessary for using `set(plt, PropertyLens(:spec), spec)`
function Accessors.setproperties(obj::Plot, patch::NamedTuple)
    n = keys(patch)
    for i in zip(n, patch)
        if i[1] == :spec
            obj = Plot(obj.data, i[2], obj.graphic)
        elseif i[1] == :graphic
            obj = Plot(obj.data, obj.spec, i[2])
        elseif i[1] == :data
            obj = Plot(i[2], obj.spec, obj.graphic)
        end
    end
    return obj
end

# @memoize function ζ(plt::Plot)
function ζ(plt::Plot)::𝕋{Mark}
    (; data, spec, graphic) = plt

    sdata = scaledata(spec, data)
    coord = getnested(spec.config, [:coordinate], :cartesian)
    if coord == :polar
        x = sdata.r .* cos.(sdata.angle)
        y = sdata.r .* sin.(sdata.angle)
        sdata = hconcat(sdata; x=x, y=y)
    end
    marks = graphic(sdata)
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
