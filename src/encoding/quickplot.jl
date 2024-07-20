"""
plot(;
    figsize=(300, 200),
    title="",
    config=NamedTuple(),
    graphic=Circle(; r=3),
    kwargs...,
)

Provides a quicker way to specify a plot. For example:
```julia

# creates a scatter plot using columns :island and :species
plot(df,x=:island,y=:species)
```
"""
function plot(
    data;
    graphic=Circle(; r=3),
    style=S(),
    config=NamedTuple(),
    figsize=(300, 200),
    title="",
    kwargs...,
)
    config = NamedTupleTools.rec_merge(
        (xaxis=(grid=(flag=true,),), yaxis=(grid=(flag=true,),)), config
    )

    data = StructArray(Tables.rowtable(data))
    encodings = Dict()
    for (k, v) in kwargs
        if isa(v, Symbol)
            v = (field=v,)
        elseif v isa Function
            fdata = StructArray(NamedTuple(Dict(k => map(v, data))))
            data = hconcat(data, fdata, "_")
            field = propertynames(data)[end]
            v = (field=field,)
        end
        encodings = merge(encodings, Dict(k => Dict(pairs(v))))
    end

    return Plot(;
        figsize=figsize,
        data=data,
        title=title,
        config=config,
        encodings=encodings,
        graphic=GraphicExpression(graphic),
    )
end

"""
plot(;
    figsize=(300, 200),
    title="",
    config=NamedTuple(),
    graphic=Circle(; r=3),
    kwargs...,
)

Provides a quicker way to specify a plot. For example:
```julia

# simple lineplot
p = plot(x=[1, 2, 3], y=[1, 2, 3], graphic=Line())

# more complicated lineplot
p = plot(;
    x=(data=[1, 2, 3, 1], datatype=:q),
    y=[1, 2, 2, 1],
    color=(data=[1, 1, 2, 2], datatype=:n),
    graphic=S(:strokeWidth => 10, :strokeOpacity => 0.9)Line(),
)
```
"""
function plot(;
    figsize=(300, 200), title="", config=NamedTuple(), graphic=Circle(; r=3), kwargs...
)
    config = NamedTupleTools.rec_merge(
        (xaxis=(grid=(flag=true,),), yaxis=(grid=(flag=true,),)), config
    )

    encodings = Dict()
    data = Dict()
    for (k, v) in kwargs
        # This is the case where the variable has only the data as in x=[1,2,4]
        if v isa Vector
            data[k] = v
            encodings[k] = Dict(:field => k)
            continue
        end

        # This is the case where the user passes the data and more x=(data=[1,2,3],datatype=:n,...)
        for (k_, v_) in pairs(v)
            if k_ == :data
                data[k] = v_
                encodings[k] = Dict(:field => k)
                continue
            end
            encodings[k] = merge(encodings[k], Dict(k_ => v_))
        end
    end
    data = StructArray(NamedTuple(data))

    return Plot(;
        figsize=figsize,
        data=data,
        title=title,
        config=config,
        encodings=encodings,
        graphic=GraphicExpression(graphic),
    )
end
