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

"""
title_config(config)

Creates the title based on the config spec. 
"""
function title_config(config)
    title = get(config, :title, NilD())
    if !(title isa Union{Mark,TMark})
        title = Title(
            TextMark(; text=title, fontfamily="Helvetica", fontsize=13, anchor=:e)
        )
    elseif title isa Mark
        title = title
    end
    return title
end

"""
frame_background_config(config)

Creates the frame and background based on the config spec. 
The frame is just the stroke and the background is only the filled part.
Hence, when drawing the Spec, one can place the background before the
frame, in order to get the proper order of rendering.

By default, if no coordinate system is present in the config, the
frame output is a transparent rectangle with size correspoding to
the figsize and centered at the origin.
"""
function frame_background_config(config)
    framesize = get(config, :figsize, (300, 300))
    framestyle = get(config, :frame_style, S())
    coordinate = get(config, :coordinate, nothing)

    frame = get(config, :frame, S(:opacity => 0)Rectangle(; w=framesize[1], h=framesize[2]))
    if coordinate == :cartesian
        frame = get(config, :frame, Frame(; size=framesize, s=framestyle))
    end
    background = S(:stroke => 0) * framestyle * frame
    frame = S(:fillOpacity => 0) * framestyle * frame
    return frame, background
end

function ζ(spec::Spec)::𝕋{Mark}
    (; config, encodings) = spec

    title = title_config(config)
    framesize = get(config, :figsize, (300, 300))
    coordinate = get(config, :coordinate, nothing)
    guide = get(config, :guide, nothing)

    if typeof(guide) <: Union{Mark,TMark}
        return dmlift(guide)
    end

    axes = NilD()
    grid = NilD()
    if coordinate == :cartesian
        axes, grid = cartesian_axes_grid_config(config, encodings)
        axes = get(config, :axes, axes)
        grid = get(config, :grid, grid)

    elseif coordinate == :polar
        axes, grid = polar_axes_grid_config(config, encodings)
        axes = get(config, :axes, axes)
        grid = get(config, :grid, grid)
    end

    if typeof(get(config, :legends, nothing)) <: Union{Mark,TMark}
        legends = get(config, :legends, generatelegends(spec))
        legends_transform = nothing
    else
        legends = generatelegends(spec)
        legends_transform = getnested(config, [:legends, :transform], nothing)
    end

    frame, background = frame_background_config(config)
    frame = get(config, :frame, frame)
    background = get(config, :background, background)

    frame_axes = background + grid + axes

    default_transform = atop(frame_axes, legends) * bright(frame_axes, legends) * T(20, 0)
    legends_transform = isnothing(legends_transform) ? default_transform : legends_transform
    d = frame_axes + frame_axes↑(T(0, 10), title) + legends_transform * legends
    return d
end
