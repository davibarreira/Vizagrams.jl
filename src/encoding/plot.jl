function plot(
    data;
    x=:x,
    y=:y,
    mark=Circle(; r=3),
    style=S(),
    config=NamedTuple(),
    opacity=0.6,
    figsize=(300, 200),
    title="",
    kwargs...,
)
    config = NamedTupleTools.rec_merge(
        (xaxis=(grid=(flag=true,),), yaxis=(grid=(flag=true,),)), config
    )

    if isa(x, Symbol)
        x = (field=x,)
    end
    if isa(y, Symbol)
        y = (field=y,)
    end
    # encodings = Dict(:x => Dict(:field => :x), :y => Dict(:field => :y))
    encodings = Dict(:x => Dict(pairs(x)), :y => Dict(pairs(y)))
    for (k, v) in kwargs
        if isa(v, Symbol)
            v = (field=v,)
        end
        encodings[k] = Dict(pairs(v))
    end

    detail = nothing
    if :color in keys(kwargs)
        detail = :color
    elseif :detail in keys(kwargs)
        detail = :detail
    end
    return Plot(;
        figsize=figsize,
        data=data,
        title=title,
        config=config,
        encodings=encodings,
        graphic=infergraphic(mark; style=style, opacity=opacity, detail=detail),
    )
end

"""
plot(x::Vector,y::Vector;mark=Circle(r=3),style=S(),
    config=(xaxis=(grid=(flag=true,),), yaxis=(grid=(flag=true,),)),
    opacity=0.6,
    kwargs...,
"""
function plot(
    x::Vector,
    y::Vector;
    mark=Circle(; r=3),
    style=S(),
    config=NamedTuple(),
    opacity=0.6,
    kwargs...,
)
    return plot(;
        x=x, y=y, mark=mark, style=style, config=config, opacity=opacity, kwargs...
    )
end
function plot(;
    x::Vector,
    y::Vector,
    mark=Circle(; r=3),
    style=S(),
    config=NamedTuple(),
    opacity=0.6,
    figsize=(300, 200),
    title="",
    kwargs...,
)
    config = NamedTupleTools.rec_merge(
        (xaxis=(grid=(flag=true,),), yaxis=(grid=(flag=true,),)), config
    )
    data = StructArray(; x=x, y=y)
    data = insertcol(data, kwargs)

    encodings = Dict(:x => Dict(:field => :x), :y => Dict(:field => :y))
    for (k, v) in kwargs
        encodings[k] = Dict(:field => k)
    end

    detail = nothing
    if :color in keys(kwargs)
        detail = :color
    elseif :detail in keys(kwargs)
        detail = :detail
    end
    return Plot(;
        figsize=figsize,
        data=data,
        title=title,
        config=config,
        encodings=encodings,
        graphic=infergraphic(mark; style=style, opacity=opacity, detail=detail),
    )
end

"""
infergraphic(mark::Circle; style, opacity, kwargs...)
Given a mark, infer the graphic expression.
"""
function infergraphic(mark; style, opacity, kwargs...)
    return scatter(; mark=mark, opacity=opacity, style=style)
end
function infergraphic(mark::Line; style, opacity, detail, kwargs...)
    return lineplot(; opacity=opacity, style=style, detail=detail)
end
