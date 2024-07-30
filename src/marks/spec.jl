struct Spec <: Mark # Unit specification taken from Vega-Lite paper
    config::NamedTuple
    encodings::NamedTuple
end

function Spec(;
    data,
    title="",
    figsize=(300, 200),
    encodings=(x=(; field=:x), y=(; field=:y)),
    config=NamedTuple(),
    coordinate=:cartesian,
)
    default_config = (title=title, figsize=figsize, coordinate=coordinate)
    config = NamedTupleTools.rec_merge(default_config, config)

    encodings = infer_encodings_fields(; data=data, encodings...)
    encodings = infer_encodings(; data=data, config=config, encodings=encodings)
    return Spec(unzip(config), encodings)
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

    frame = get(config, :frame, NilD())
    if coordinate == :cartesian
        frame = get(config, :frame, Frame(; size=framesize))
    end

    axes = NilD()
    if coordinate == :cartesian
        x = get(encodings, :x, nothing)
        xaxis = NilD()
        if !isnothing(x)
            scale = get(x, :scale, IdScale())
            xaxis = inferxaxis(scale; axislength=framesize[1])
        end
        y = get(encodings, :y, nothing)
        yaxis = NilD()
        if !isnothing(y)
            scale = get(y, :scale, IdScale())
            yaxis = inferyaxis(scale; axislength=framesize[2])
        end
        axes = xaxis + yaxis
    elseif coordinate == :polar
        r = get(encodings, :r, nothing)
        raxis = NilD()
        if !isnothing(r)
            scale = get(r, :scale, IdScale())
            raxis = inferraxis(scale)
        end
        angle = get(encodings, :angle, nothing)
        angleaxis = NilD()
        if !isnothing(angle)
            scale = get(angle, :scale, IdScale())
            angleaxis = inferangleaxis(scale)
        end
        axes = angleaxis + raxis
    end

    return frame↑(T(0, 10), title) + axes
end
