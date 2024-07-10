struct Legend <: Mark
    title
    titleplacement::Symbol
    scale::Scale
    fmark
    extra
end

function Legend(; title="", titleplacement=:se, fmark=x -> U(x)Circle(), scale, extra=())
    return Legend(title, titleplacement, scale, fmark, extra)
end

function setcolorbar(scale, h=150, w=20, n=50, nticks=3)
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
    return cbar → (T(5, 0), ticks)
end

# COLORBAR
function inferlegendmark(fmark::Function, scale::Union{GenericScale,IdScale}, args...)
    return dmlift(NilD())
end

function inferlegendmark(
    fmark::Function, scale::Linear{<:Any,<:Union{Symbol,Tuple{Symbol,Symbol}}}, args...
)
    return setcolorbar(scale, args...)
end

function inferlegendmark(fmark::Function, scale::Linear; pad=5, n::Int=5)
    tickvalues = showoff(range(scale.domain[1], scale.domain[2], n))
    values = scale.(range(scale.domain[1], scale.domain[2], n))
    marks_bbox = rectboundingbox(
        foldr(
            (s, acc) -> fmark(s[2])↓(T(0, -pad), acc), zip(tickvalues, values); init=NilD()
        ),
    )
    return foldr(
        (s, acc) -> begin
            (
                fmark(s[2]) +
                bright(
                    marks_bbox,
                    (T(3, 0.5), TextMark(; text=s[1], anchor=:e, fontsize=7)),
                ) * TextMark(; text=s[1], anchor=:e, fontsize=7)
            )↓(T(0, -pad), acc)
        end,
        zip(tickvalues, values);
        init=NilD(),
    )
end

function inferlegendmark(fmark::Function, scale::Categorical; pad=5, n::Int=5)
    tickvalues = scale.domain
    values = scale.(scale.domain)
    marks_bbox = rectboundingbox(
        foldr((s, acc) -> fmark(s[2])↓(T(0, -5), acc), zip(tickvalues, values); init=NilD())
    )
    return foldr(
        (s, acc) -> begin
            (
                fmark(s[2]) +
                bright(
                    marks_bbox,
                    (T(3, 0.5), TextMark(; text=s[1], anchor=:e, fontsize=7)),
                ) * TextMark(; text=s[1], anchor=:e, fontsize=7)
            )↓(T(0, -pad), acc)
        end,
        zip(tickvalues, values);
        init=NilD(),
    )
end
function ζ(legend::Legend)::𝕋{Mark}
    (; title, titleplacement, scale, fmark, extra) = legend
    legendmarks = inferlegendmark(fmark, scale; extra...)
    legendtitle =
        S(
            :fontWeight => "bold"
        )TextMark(; text=title, anchor=titleplacement, fontfamily="Helvetica", fontsize=8)
    return aleft(legendmarks, legendtitle) * legendtitle + T(0, -15) * legendmarks
end
