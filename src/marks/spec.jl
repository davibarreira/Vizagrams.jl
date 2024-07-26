struct Spec <: Mark # Unit specification taken from Vega-Lite paper
    config::NamedTuple
    encodings::NamedTuple
end

function Spec(;
    title="", figsize=(300, 200), encodings=Dict(), config=Dict(), coordinate=:cartesian
)
    default_config = (
        title=title, figsize=figsize, frame=Frame(; size=figsize), coordinate=coordinate
    )
    config = NamedTupleTools.rec_merge(default_config, config)

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
    frame = get(config, :frame, NilD())

    coordinate = get(config, :coordinate, :cartesian)

    axes = NilD()
    if coordinate == :cartesian
        x = get(encodings, :x, nothing)
        xaxis = NilD()
        if !isnothing(x)
            xaxis = Arrow(; pts=[[0, 0], [framesize[1], 0]], headsize=0)
        end
        y = get(encodings, :y, nothing)
        yaxis = NilD()
        if !isnothing(y)
            yaxis = Arrow(; pts=[[0, 0], [0, framesize[2]]], headsize=0)
        end
        axes = xaxis + yaxis
    end

    return frame↑(T(0, 10), title) + axes

    # title_config = getnested(
    #     config, [:title], (fontfamily="Helvetica", fontsize=13, anchor=:e)
    # )
    # title = Title(mlift(TextMark(; text=title, title_config...)))

    # frame_style = getnested(config, [:frame_style], S())
    # xaxis_style = getnested(config, [:xaxis, :style], S())
    # yaxis_style = getnested(config, [:yaxis, :style], S())
    # xgrid_flag = getnested(config, [:xaxis, :grid, :flag], false)
    # xgrid_style = getnested(
    #     config,
    #     [:xaxis, :grid, :style],
    #     S(:opacity => 0.6, :stroke => :grey, :strokeDasharray => 2),
    # )
    # ygrid_flag = getnested(config, [:yaxis, :grid, :flag], false)
    # ygrid_style = getnested(
    #     config,
    #     [:yaxis, :grid, :style],
    #     S(:opacity => 0.6, :stroke => :grey, :strokeDasharray => 2),
    # )

    # frame = Frame(; size=figsize, s=frame_style)

    # x = get(encodings, :x, nothing)
    # xaxis = NilD()
    # gridx = NilD()
    # if !(isnothing(x))
    #     xaxis_config = getnested(config, [:xaxis], ())
    #     xaxis = XAxis(inferaxis(spec, :x, figsize[1]; xaxis_config...))
    #     xaxis = xaxis_style * xaxis
    #     if xgrid_flag
    #         tickposs = map(x -> x.pos, getmark([XAxis, Tick], xaxis))
    #         gridx = Grid(; positions=tickposs, l=figsize[2], angle=π / 2, style=xgrid_style)
    #     end
    # end
    # y = get(encodings, :y, nothing)
    # yaxis = NilD()
    # gridy = NilD()
    # if !(isnothing(y))
    #     default_yxaxis_config = (
    #         titleplacement=:n,
    #         titleangle=0,
    #         ticktextangle=-π / 2,
    #         ticktextplacement=:top,
    #         ticktextanchor=:w,
    #         tickmark=T([0, 2])Rectangle(; h=4, w=1),
    #     )
    #     yaxis_config = getnested(config, [:yaxis], ())
    #     yaxis_config = merge(default_yxaxis_config, yaxis_config)
    #     yaxis = YAxis(inferaxis(spec, :y, figsize[2]; yaxis_config...))
    #     yaxis = yaxis_style * yaxis
    #     if ygrid_flag
    #         # transforms = map(x -> x._1._1[1], getmarkpath(Tick, getmark([YAxis], yaxis)[1]))
    #         transforms = map(x -> x._1[1], getmarkpath(Tick, getmark([YAxis], yaxis)[1]))
    #         tickposs = map(
    #             x -> x[1](x[2].pos), zip(transforms, getmark([YAxis, Tick], yaxis))
    #         )
    #         gridy = Grid(; positions=tickposs, l=figsize[1], angle=0, style=ygrid_style)
    #     end
    # end

    # # legends = generatelegends(spec)
    # legends = NilD()

    # if !isnothing(getnested(config, [:frame], nothing))
    #     context = getnested(config, [:frame], nothing)
    #     return (context)↑(T(0, 10), title) → (T(10, frame.size[2]), legends)
    # end
    # return (frame + gridx + gridy + xaxis + yaxis)↑(T(0, 10), title) →
    #        (T(10, frame.size[2]), legends)
end
