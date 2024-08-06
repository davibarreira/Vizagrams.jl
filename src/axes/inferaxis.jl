"""
cartesian_axes_grid_config(config, encodings)

Auxiliar function that computes the x and y axes, as well as the grids
for the cartesian coordinate system given in the config and encodings.
"""
function cartesian_axes_grid_config(config, encodings)
    framesize = get(config, :figsize, (300, 300))
    coordinate = get(config, :coordinate, nothing)

    x = get(encodings, :x, nothing)
    xaxis = NilD()
    xgrid = NilD()

    if typeof(get(config, :xaxis, nothing)) <: Union{Mark,TMark}
        ax = get(config, :xaxis, nothing)
        config = NamedTupleTools.merge_recursive(config, (; xaxis=(; mark=ax)))
    end
    if typeof(get(config, :xgrid, nothing)) <: Union{Mark,TMark}
        xg = get(config, :xgrid, nothing)
        config = NamedTupleTools.merge_recursive(config, (; xgrid=(; mark=xg)))
    end
    if typeof(get(config, :yaxis, nothing)) <: Union{Mark,TMark}
        ax = get(config, :yaxis, nothing)
        config = NamedTupleTools.merge_recursive(config, (; yaxis=(; mark=ax)))
    end
    if typeof(get(config, :ygrid, nothing)) <: Union{Mark,TMark}
        yg = get(config, :ygrid, nothing)
        config = NamedTupleTools.merge_recursive(config, (; ygrid=(; mark=yg)))
    end

    if !isnothing(x)
        title = getnested(config, [:xaxis, :title], get(encodings, :field, :x))
        titleangle = getnested(config, [:xaxis, :titleangle], 0)
        tickvalues = getnested(config, [:xaxis, :tickvalues], nothing)
        ticktexts = getnested(config, [:xaxis, :ticktexts], nothing)
        nticks = getnested(config, [:xaxis, :nticks], 5)
        ticktextangle = getnested(config, [:xaxis, :ticktextangle], 0)
        axislength = getnested(config, [:xaxis, :axislength], framesize[1])
        axis_style = getnested(config, [:xaxis, :axis_style], S())
        axisarrow = getnested(config, [:xaxis, :axisarrow], nothing)
        tickmark = getnested(config, [:xaxis, :tickmark], Rectangle(; w=1.0, h=4))

        scale = get(x, :scale, IdScale())
        tickvalues, ticktexts = get_tickvalues(
            scale; nticks=nticks, tickvalues=tickvalues, ticktexts=ticktexts
        )
        xaxis =
            axis_style * inferxaxis(
                scale;
                axislength=axislength,
                tickvalues=tickvalues,
                ticktexts=ticktexts,
                title=title,
                ticktextangle=ticktextangle,
                axisarrow=axisarrow,
                tickmark=tickmark,
                titleangle=titleangle,
            )
        pos = map(t -> [scale(t), 0], tickvalues)
        grid_style = getnested(
            config,
            [:xgrid, :style],
            S(
                :opacity => 0.6,
                :stroke => :grey,
                :strokeDasharray => 2,
                :strokeWidth => 0.8,
            ),
        )
        xgrid = Grid(; positions=pos, l=framesize[2], angle=π / 2, style=grid_style)
    end

    y = get(encodings, :y, nothing)
    yaxis = NilD()
    ygrid = NilD()

    if !isnothing(y)
        title = getnested(config, [:yaxis, :title], get(encodings, :field, :y))
        titleangle = getnested(config, [:yaxis, :titleangle], 0)
        tickvalues = getnested(config, [:yaxis, :tickvalues], nothing)
        ticktexts = getnested(config, [:yaxis, :ticktexts], nothing)
        nticks = getnested(config, [:yaxis, :nticks], 5)
        ticktextangle = getnested(config, [:yaxis, :ticktextangle], 0)
        axislength = getnested(config, [:yaxis, :axislength], framesize[2])
        axis_style = getnested(config, [:yaxis, :axis_style], S())
        axisarrow = getnested(config, [:yaxis, :axisarrow], nothing)
        tickmark = getnested(config, [:yaxis, :tickmark], Rectangle(; w=4.0, h=1))

        scale = get(y, :scale, IdScale())
        tickvalues, ticktexts = get_tickvalues(
            scale; nticks=nticks, tickvalues=tickvalues, ticktexts=ticktexts
        )
        yaxis =
            axis_style * inferyaxis(
                scale;
                axislength=axislength,
                tickvalues=tickvalues,
                ticktexts=ticktexts,
                title=title,
                ticktextangle=ticktextangle,
                axisarrow=axisarrow,
                tickmark=tickmark,
                titleangle=titleangle,
            )
        pos = map(t -> [0, scale(t)], tickvalues)

        grid_style = getnested(
            config,
            [:yaxis, :grid_style],
            S(
                :opacity => 0.6,
                :stroke => :grey,
                :strokeDasharray => 2,
                :strokeWidth => 0.8,
            ),
        )
        ygrid = Grid(; positions=pos, l=framesize[1], angle=0, style=grid_style)
    end

    xgrid = getnested(config, [:xgrid, :mark], xgrid)
    xaxis = getnested(config, [:xaxis, :mark], xaxis)
    ygrid = getnested(config, [:ygrid, :mark], ygrid)
    yaxis = getnested(config, [:yaxis, :mark], yaxis)

    grid = xgrid + ygrid
    axes = xaxis + yaxis
    return axes, grid
end

"""
polar_axes_grid_config(config, encodings)

Auxiliar function that computes the radial and angular axes, as well as the grids
for the polar coordinate system given in the config and encodings.
"""
function polar_axes_grid_config(config, encodings)
    r = get(encodings, :r, nothing)
    raxisangle = getnested(config, [:raxis, :angle], π / 2)
    raxis = NilD()
    if !isnothing(r)
        scale = get(r, :scale, IdScale())
        nticks = 5
        tickvalues = if scale isa Linear
            range(scale.domain[1], scale.domain[2], nticks)
        else
            scale.domain
        end

        tickvalues = getnested(config, [:raxis, :tickvalues], tickvalues)
        if !(tickvalues isa Vector{<:AbstractString})
            ticktexts = showoff(tickvalues)
        else
            ticktexts = tickvalues
        end
        ticktexts = getnested(config, [:raxis, :ticktexts], ticktexts)

        raxis = inferraxis(
            scale; tickvalues=tickvalues, ticktexts=ticktexts, angle=raxisangle
        )
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
                S(:stroke => :grey, :strokeOpacity => 0.3)Line([[xinit, yinit], [x, y]])
            end,
            +,
            scale.(tickvalues),
        )
    end

    rgrid = getnested(config, [:rgrid, :mark], rgrid)
    raxis = getnested(config, [:raxis, :mark], raxis)
    anglegrid = getnested(config, [:anglegrid, :mark], anglegrid)
    angleaxis = getnested(config, [:angleaxis, :mark], angleaxis)

    axes = angleaxis + raxis
    grid = rgrid + anglegrid
    return axes, grid
end
