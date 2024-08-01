struct Spec <: Mark # Unit specification taken from Vega-Lite paper
    config::NamedTuple
    encodings::NamedTuple
end

"""
Spec(;
    data=nothing,
    title="",
    figsize=(300, 200),
    encodings=NamedTuple(),
    config=NamedTuple(),
    coordinate=:cartesian,
    kwargs...
)

Creates an specification using `data` to infer the missing encodings.
For example:
```julia
Spec(data=data,encodings=(x=(;field=:y),y=(;field=:y)))
```
The scales for the encodings above are inferred from the data.

```julia
spec = Spec(data=data,x=(;field=:y),y=(;field=:y))
```

"""
function Spec(;
    data=nothing,
    title="",
    figsize=(300, 200),
    encodings=NamedTuple(),
    config=NamedTuple(),
    coordinate=:cartesian,
    kwargs...
)
    default_config = (title=title, figsize=figsize, coordinate=coordinate)
    config = NamedTupleTools.rec_merge(default_config, config)

    if !isnothing(data)
        data = StructArray(Tables.rowtable(data))
        encodings = infer_encodings(; data=data, config=config, encodings=encodings, kwargs...)
    elseif length(kwargs) != 0
        data, encodings = infer_data_encodings(; kwargs...)
        encodings = infer_encodings(; data=data, config=config, encodings=encodings, kwargs...)
    end
    return Spec(unzip(config), unzip(encodings))
end

function ζ(spec::Spec)::𝕋{Mark}
    (; config, encodings) = spec

    title = get(config, :title, NilD())
    if title isa String
        title = Title(
            TextMark(; text=title, fontfamily="Helvetica", fontsize=13, anchor=:e)
        )
    elseif title isa Mark
        title = title
    end

    framesize = get(config, :figsize, (300, 300))

    coordinate = get(config, :coordinate, :cartesian)

    frame = S(:fillOpacity => 0)get(config, :frame, NilD())
    background = S(:stroke => 0)get(config, :frame, NilD())
    if coordinate == :cartesian
        frame = S(:fillOpacity => 0) * get(config, :frame, Frame(; size=framesize))
        background = S(:stroke => 0)get(config, :frame, Frame(; size=framesize))
    end

    axes = NilD()
    grid = NilD()
    if coordinate == :cartesian
        x = get(encodings, :x, nothing)
        xaxis = NilD()
        xgrid = NilD()
        if !isnothing(x)
            scale = get(x, :scale, IdScale())
            tickvalues, ticktexts = get_tickvalues(
                scale; nticks=5, tickvalues=nothing, ticktexts=nothing
            )
            xaxis = inferxaxis(scale; axislength=framesize[1], tickvalues=tickvalues, ticktexts=ticktexts)
            pos = map(t -> [scale(t), 0], tickvalues)
            xgrid = Grid(positions=pos, l=framesize[2], angle=π / 2)
        end
        y = get(encodings, :y, nothing)
        yaxis = NilD()
        ygrid = NilD()
        if !isnothing(y)
            scale = get(y, :scale, IdScale())
            tickvalues, ticktexts = get_tickvalues(
                scale; nticks=5, tickvalues=nothing, ticktexts=nothing
            )
            yaxis = inferyaxis(scale; axislength=framesize[2], tickvalues=tickvalues, ticktexts=ticktexts)
            pos = map(t -> [0, scale(t)], tickvalues)
            ygrid = Grid(positions=pos, l=framesize[1], angle=0)
        end
        grid = xgrid + ygrid
        axes = xaxis + yaxis
    elseif coordinate == :polar
        r = get(encodings, :r, nothing)
        raxis = NilD()
        if !isnothing(r)
            scale = get(r, :scale, IdScale())
            nticks = 5
            tickvalues = scale isa Linear ? range(scale.domain[1], scale.domain[2], nticks) : scale.domain
            ticktexts = showoff(tickvalues)
            raxis = inferraxis(scale, tickvalues=tickvalues, ticktexts=ticktexts)
        end
        angle = get(encodings, :angle, nothing)
        angleaxis = NilD()
        if !isnothing(angle)
            scale = get(angle, :scale, IdScale())
            angleaxis = inferangleaxis(scale)
        end
        axes = angleaxis + raxis
    end

    d = S(:vectorEffect => "none") * (background + grid + frame↑(T(0, 10), title) + axes)
    return d
end


struct Plt <: Mark # Unit specification taken from Vega-Lite paper
    data
    spec::Spec
    graphic::GraphicExpression
end
function Plt(; data=nothing, spec::Spec=Spec(), graphic::Union{GraphicExpression,Function,TMark,Mark,GeometricPrimitive,Prim}=GraphicExpression(x -> NilD()))
    return Plt(data, spec, GraphicExpression(graphic))
end

function ζ(plt::Plt)::𝕋{Mark}
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
