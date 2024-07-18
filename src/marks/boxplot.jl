struct BoxPlot <: Mark
    data
    box_width::Real
end
BoxPlot(; data=[-3, -1, 0, 1, 4], box_width=1) = BoxPlot(data, box_width)
function ζ(boxplot::BoxPlot)
    (; data, box_width) = boxplot

    # Computing Statistics
    m = median(data)
    q1 = quantile(data, 0.25)
    q3 = quantile(data, 0.75)
    iqr = q3 - q1
    li = max(q1 - 1.5 * iqr, minimum(data))
    ls = min(q3 + 1.5 * iqr, maximum(data))

    # Drawing box elements
    boxbottom = T(0, m)T(0, -(m - q1) / 2)Rectangle(; h=m - q1, w=box_width)
    boxtop = T(0, m)T(0, (q3 - m) / 2)Rectangle(; h=q3 - m, w=box_width)
    linetop = S(:strokeWidth => 1) * Line([[0, q3], [0, ls]])
    linebottom = S(:strokeWidth => 1) * Line([[0, q1], [0, li]])
    linem =
        S(:strokeWidth => 2, :stroke => :white) *
        Line([[-box_width / 2, m], [box_width / 2, m]])
    return boxtop + boxbottom + linem + linetop + linebottom
end

function GraphicExpression(box::BoxPlot)
    return ∑(; i=:x) do rows
        S(:fill => rows.color[1])T(rows.x[1], 0)BoxPlot(; data=rows.y, box_width=40)
    end
end
