struct PlotSpec <: Mark # Unit specification taken from Vega-Lite paper
    title::AbstractString
    figsize::Tuple
    data
    encodings::NamedTuple
    config::NamedTuple
end

function PlotSpec(; title="", figsize=(300, 200), encodings=Dict(), config=Dict(), data)
    return PlotSpec(title, figsize, data, unzip(encodings), unzip(config))
end

function ζ(spec::PlotSpec)::𝕋{Mark}
    (; title, figsize, data, encodings, config) = spec

    title_config = getnested(
        config, [:title], (fontfamily="Helvetica", fontsize=13, anchor=:e)
    )
    title = Title(mlift(TextMark(; text=title, title_config...)))

    frame_style = getnested(config, [:frame_style], S())
    xaxis_style = getnested(config, [:xaxis, :style], S())
    yaxis_style = getnested(config, [:yaxis, :style], S())
    xgrid_flag = getnested(config, [:xaxis, :grid, :flag], true)
    xgrid_style = getnested(
        config,
        [:xaxis, :grid, :style],
        S(:opacity => 0.6, :stroke => :grey, :strokeDasharray => 2),
    )
    ygrid_flag = getnested(config, [:yaxis, :grid, :flag], true)
    ygrid_style = getnested(
        config,
        [:yaxis, :grid, :style],
        S(:opacity => 0.6, :stroke => :grey, :strokeDasharray => 2),
    )

    x = get(encodings, :x, nothing)
    xaxis = NilD()
    gridx = NilD()
    if !(isnothing(x))
        xaxis_config = getnested(config, [:xaxis], ())
        xaxis = XAxis(inferaxis(spec, :x, figsize[1]; xaxis_config...))
        xaxis = xaxis_style * xaxis
        if xgrid_flag
            tickposs = map(x -> x.pos, getmark([XAxis, Tick], xaxis))
            gridx = Grid(; positions=tickposs, l=figsize[2], angle=π / 2, style=xgrid_style)
        end
    end
    y = get(encodings, :y, nothing)
    yaxis = NilD()
    gridy = NilD()
    if !(isnothing(y))
        default_yxaxis_config = (
            titleplacement=:n,
            titleangle=0,
            ticktextangle=-π / 2,
            ticktextplacement=:top,
            ticktextanchor=:w,
            tickmark=T([0, 2])Rectangle(; h=4, w=1),
        )
        yaxis_config = getnested(config, [:yaxis], ())
        yaxis_config = merge(default_yxaxis_config, yaxis_config)
        yaxis = YAxis(inferaxis(spec, :y, figsize[2]; yaxis_config...))
        yaxis = yaxis_style * yaxis
        if ygrid_flag
            # transforms = map(x -> x._1._1[1], getmarkpath(Tick, getmark([YAxis], yaxis)[1]))
            transforms = map(x -> x._1[1], getmarkpath(Tick, getmark([YAxis], yaxis)[1]))
            tickposs = map(
                x -> x[1](x[2].pos), zip(transforms, getmark([YAxis, Tick], yaxis))
            )
            gridy = Grid(; positions=tickposs, l=figsize[1], angle=0, style=ygrid_style)
        end
    end

    # Defining the Frame
    frame = Frame(; size=figsize, s=frame_style)
    legends = generatelegends(spec)

    if !isnothing(getnested(config, [:frame], nothing))
        frame = getnested(config, [:frame], nothing)
        if isnothing(boundingbox(frame))
            title = Title(setfields(title.textmark, (anchor=:c,)))
            return T(0, figsize[2]) * title + T(10 + figsize[1], figsize[2]) * legends
        end
        return (frame)↑(T(0, 10), title) → (T(10, boundingheight(frame) / 2), legends)
    end

    guide = getnested(config, [:guide], true)

    if guide == false
        return S()NilD()
    end

    if getnested(config, [:coordinate], :cartesian) == :polar
        return polarframe(spec)
    end

    if isnothing(x) && isnothing(y)
        return T(figsize[1] / 2, figsize[2] / 2) * legends
    end

    stroke_frame = S(:fillOpacity => 0) * frame
    background = S(:strokeWidth => 0) * frame
    return (background + gridx + gridy + stroke_frame + xaxis + yaxis)↑(T(0, 10), title) →
           (T(10, frame.size[2]), legends)
end
