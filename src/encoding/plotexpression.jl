"""
PlotExpression

Computes (spec,data)->T{Mark}
"""
struct PlotExpression
    f::Function # (PlotSpec,Data) -> TMark
end

function PlotExpression(graphic::GraphicExpression)
    return PlotExpression((spec, data) -> begin
        graphic(scaledata(spec))
    end)
end

function (pexpr::PlotExpression)(spec, data)
    return pexpr.f(spec, data)
end

function plotexpression(graphic::GraphicExpression)
    return PlotExpression((spec, data) -> begin
        graphic(scaledata(spec))
    end)
end
