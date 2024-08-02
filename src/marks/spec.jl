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
    coordinate=nothing,
    kwargs...,
)
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

    default_config = (title=title, figsize=figsize, coordinate=nothing)
    if !isnothing(get(encodings, :x, nothing))
        default_config = (title=title, figsize=figsize, coordinate=:cartesian)
    end
    config = NamedTupleTools.rec_merge(default_config, config)

    return Spec(unzip(config), unzip(encodings))
end

function ζ(spec::Spec)::𝕋{Mark}
    (; config, encodings) = spec

    title = get(config, :title, NilD())
    if !(title isa Union{Mark,TMark})
        title = Title(
            TextMark(; text=title, fontfamily="Helvetica", fontsize=13, anchor=:e)
        )
    elseif title isa Mark
        title = title
    end

    framesize = get(config, :figsize, (300, 300))

    coordinate = get(config, :coordinate, nothing)

    frame = get(config, :frame, S(:opacity => 0)Rectangle(; w=framesize[1], h=framesize[2]))
    if coordinate == :cartesian
        frame = get(config, :frame, Frame(; size=framesize))
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
            xaxis = inferxaxis(
                scale; axislength=framesize[1], tickvalues=tickvalues, ticktexts=ticktexts
            )
            pos = map(t -> [scale(t), 0], tickvalues)
            xgrid = Grid(; positions=pos, l=framesize[2], angle=π / 2)
        end
        y = get(encodings, :y, nothing)
        yaxis = NilD()
        ygrid = NilD()
        if !isnothing(y)
            scale = get(y, :scale, IdScale())
            tickvalues, ticktexts = get_tickvalues(
                scale; nticks=5, tickvalues=nothing, ticktexts=nothing
            )
            yaxis = inferyaxis(
                scale; axislength=framesize[2], tickvalues=tickvalues, ticktexts=ticktexts
            )
            pos = map(t -> [0, scale(t)], tickvalues)
            ygrid = Grid(; positions=pos, l=framesize[1], angle=0)
        end
        grid = xgrid + ygrid
        axes = xaxis + yaxis

    elseif coordinate == :polar
        r = get(encodings, :r, nothing)
        raxis = NilD()
        if !isnothing(r)
            scale = get(r, :scale, IdScale())
            nticks = 5
            tickvalues = if scale isa Linear
                range(scale.domain[1], scale.domain[2], nticks)
            else
                scale.domain
            end

            if !(tickvalues isa Vector{<:AbstractString})
                ticktexts = showoff(tickvalues)
            end
            ticktexts = tickvalues
            raxis = inferraxis(scale; tickvalues=tickvalues, ticktexts=ticktexts)
            rgrid = mapreduce(
                r ->
                    S(:fillOpacity => 0, :stroke => :grey, :strokeOpacity => 0.5) *
                    Circle(; r=r),
                +,
                scale.(tickvalues),
            )
        end
        angle = get(encodings, :angle, nothing)
        angleaxis = NilD()
        if !isnothing(angle)
            scale = get(angle, :scale, IdScale())
            rscale = get(r, :scale, IdScale())
            rmin = rscale.codomain[begin]
            rmax = rscale.codomain[end]
            tickvalues, ticktexts = get_tickvalues(
                scale; nticks=5, tickvalues=nothing, ticktexts=nothing
            )
            angleaxis = inferangleaxis(
                scale; tickvalues=tickvalues, ticktexts=ticktexts, radius=rmax
            )
            anglegrid = mapreduce(
                a -> begin
                    xinit, yinit = rmin * cos(a), rmin * sin(a)
                    x, y = rmax * cos(a), rmax * sin(a)
                    S(
                        :stroke => :grey, :strokeOpacity => 0.3
                    )Line([[xinit, yinit], [x, y]])
                end,
                +,
                scale.(tickvalues),
            )
        end

        axes = angleaxis + raxis
        grid = rgrid + anglegrid
    end

    legends = generatelegends(spec)

    background = S(:stroke => 0)frame
    frame = S(:fillOpacity => 0)frame

    # d = S(:vectorEffect => "none") * (background + grid + frame↑(T(0, 10), title) + axes)
    d = background + grid + frame↑(T(0, 10), title) + axes
    d = d + atop(frame, legends) * bright(frame, legends) * T(20, 0) * legends
    return d
end
