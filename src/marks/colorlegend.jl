function getcolorbar(scale, h=150, w=20, n=50, nticks=3)
    values = collect(range(scale.domain[1], scale.domain[2], n))
    colors = scale.(values)
    cbar = foldr(
        (s, acc) ->
            S(:fill => s, :stroke => s)Rectangle(; h=h / n, w=20, c=[10, -h / (2n)])↓acc,
        colors;
        init=NilD(),
    )
    tickvalues = showoff(range(scale.domain[1], scale.domain[2], nticks))
    pos = collect(range(0, -h, nticks))
    ticks = foldr(
        (s, acc) -> T(0, s[2]) * TextMark(; text=s[1], anchor=:c, fontsize=7) + acc,
        zip(tickvalues, pos);
        init=NilD(),
    )
    return cbar → ticks
end
function infercolorbardiagram(scale::Linear)
    ncolorbars = 50
    values = range(scale.domain[1], scale.domain[2], ncolorbars)
    singlebarheight = 150 / ncolorbars
    colors = scale.(values)
    return cbar = getcolorbar(scale)
end
function infercolorbardiagram(scale::Categorical)
    tickvalues = scale.domain
    colors = scale.(scale.domain)
    return colorbar = foldr(
        (s, acc) -> begin
            (
                S(:fill => s[2], :stroke => s)Circle(; r=5, c=[5, 0]) →
                (T(5, 0.5), TextMark(; text=s[1], anchor=:e, fontsize=7))
            )↓(T(0, -5), acc)
        end,
        zip(tickvalues, colors);
        init=NilD(),
    )
end