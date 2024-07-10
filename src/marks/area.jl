struct Area <: Mark
    pts::Vector
    areastyle::S
    linestyle::S
    level::Real
    orientation::Symbol
end

function Area(;
    pts=[[0, 0], [1, 1]],
    color="red",
    opacity=0.4,
    areastyle=S(:fillOpacity => opacity, :fill => color),
    linestyle=S(:stroke => color),
    level=0,
    orientation=:h,
)
    return Area(pts, areastyle, linestyle, level, orientation)
end
function ζ(area::Area)::𝕋{Mark}
    (; pts, areastyle, linestyle, level, orientation) = area
    areamark =
        S(:fillOpacity => 0.2, :fill => :red, :strokeWidth => 0)areastyle *
        Polygon(vcat(vcat((pts[begin][1], level), pts), (pts[end][1], level)))
    linemark = linestyle * Line(pts)
    return areamark + linemark
end
