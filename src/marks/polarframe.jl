struct PolarFrame <: Mark
    rmax::Real
    rmin::Real
    a_tick_angles
    a_tick_texts
    a_tick_flag::Symbol
    r_tick_values
    r_tick_texts
    r_axis_angle
end

"""
```julia
PolarFrame(;
    rmax=150,
    rmin=50,
    a_tick_angles=collect(0:(π / 6):(2π))[begin:(end - 1)],
    a_tick_texts=1:length(a_tick_angles),
    a_tick_flag=:out,
    r_tick_values=range(rmin, rmax, 5),
    r_tick_texts=range(0, 100, 5),
    r_axis_angle=π / 4,
)
```

`rmax` and `rmin` are the radius for the outer and inner circles.
`a_tick_flag` must be either `:out` or `:in`. The `:out`
is for placing the tick for the angular axis in the outer circle, while
`:in` places inside the inner circle.
"""
function PolarFrame(;
    rmax=150,
    rmin=50,
    a_tick_angles=collect(0:(π / 6):(2π))[begin:(end - 1)],
    a_tick_texts=1:length(a_tick_angles),
    a_tick_flag=:out,
    r_tick_values=range(rmin, rmax, 5),
    r_tick_texts=range(0, 100, 5),
    r_axis_angle=π / 4,
)
    return PolarFrame(
        rmax,
        rmin,
        a_tick_angles,
        a_tick_texts,
        a_tick_flag,
        r_tick_values,
        r_tick_texts,
        r_axis_angle,
    )
end

function ζ(polar::PolarFrame)::𝕋{Mark}
    (;
        rmax,
        rmin,
        a_tick_angles,
        a_tick_texts,
        a_tick_flag,
        r_tick_values,
        r_tick_texts,
        r_axis_angle,
    ) = polar

    # Angle Axis
    r_tick = a_tick_flag == :out ? rmax : rmin

    out_circle = S(:fillOpacity => 0, :stroke => :black)Circle(; r=rmax)
    in_circle = rmin > 0 ? S(:fillOpacity => 0, :stroke => :black)Circle(; r=rmin) : NilD()
    a_ticks = mapreduce(t -> R(t)T(r_tick, 0)R(π / 2)U(rmax / 100)Tick(), +, a_tick_angles)

    a_tick_texts = map(t -> TextMark(; text=t, anchor=:c, fontsize=7), a_tick_texts)
    max_tick_texts_width = mapreduce(t -> boundingwidth(t), max, a_tick_texts)

    t_ticks = map(t -> begin
        r = r_tick + max_tick_texts_width
        if a_tick_flag == :in
            r = r_tick - max_tick_texts_width
        end
        x, y = r * cos(t), r * sin(t)
        T(x, y)
    end, a_tick_angles)

    a_tick_texts = reduce(+, t_ticks .* a_tick_texts)
    a_ticks = a_ticks + a_tick_texts
    a_grid = mapreduce(
        a -> begin
            xinit, yinit = rmin * cos(a), rmin * sin(a)
            x, y = rmax * cos(a), rmax * sin(a)
            S(:stroke => :grey, :strokeOpacity => 0.3)Line([[xinit, yinit], [x, y]])
        end,
        +,
        a_tick_angles,
    )

    # Radius Axis
    r_ticks = mapreduce(
        r -> begin
            x, y = r[1] * cos(r_axis_angle), r[1] * sin(r_axis_angle)
            T(x, y) * (
                S(:stroke => :white, :strokeWidth => 14)TextMark(; text=r[2], fontsize=7) + TextMark(; text=r[2], fontsize=7)
            )
        end,
        +,
        zip(r_tick_values, r_tick_texts),
    )

    r_grid = mapreduce(
        r -> S(:fillOpacity => 0, :stroke => :grey, :strokeOpacity => 0.5)Circle(; r=r),
        +,
        r_tick_values,
    )

    # Creating the frame
    d = out_circle + in_circle + a_grid + a_ticks + r_grid + r_ticks
    return d
end

function PolarFrame(spec::PlotSpec)
    angle_scale = getscale(spec, :angle)
    r_scale = getscale(spec, :r)

    # rmax = getnested(spec.config, [:guide, :rmax], min(spec.figsize...) / 2)
    # rmin = getnested(spec.config, [:guide, :rmin], 0)
    rmax = r_scale.codomain[2]
    rmin = r_scale.codomain[1]

    a_tick_angles = angle_scale.codomain
    a_tick_texts = angle_scale.domain

    a_tick_flag = getnested(spec.config, [:guide, :a_tick_flag], :out)

    r_tick_values = getnested(
        spec.config,
        [:guide, :r_tick_values],
        range(
            r_scale.codomain[1],
            r_scale.codomain[2],
            getnested(spec.config, [:guide, :r_n_ticks], 5),
        ),
    )

    r_tick_texts = getnested(
        spec.config,
        [:guide, :r_tick_texts],
        range(
            r_scale.domain[1],
            r_scale.domain[2],
            getnested(spec.config, [:guide, :r_n_ticks], 5),
        ),
    )
    r_axis_angle = getnested(spec.config, [:guide, :r_axis_angle], π / 2)

    return PolarFrame(
        rmax,
        rmin,
        a_tick_angles,
        a_tick_texts,
        a_tick_flag,
        r_tick_values,
        r_tick_texts,
        r_axis_angle,
    )
end
