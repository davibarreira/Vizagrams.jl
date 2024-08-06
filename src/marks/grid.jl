struct Grid <: Mark
    positions
    l
    angle
    style::S
end

function Grid(;
    positions=[[0, 0]],
    l=1,
    angle=π / 2,
    style=S(:opacity => 0.6, :stroke => :grey, :strokeDasharray => 2, :strokeWidth => 0.8),
)
    return Grid(positions, l, angle, style)
end

function ζ(grid::Grid)::𝕋{Mark}
    (; positions, l, angle, style) = grid
    return style *
           reduce(+, map(x -> Line([x, x + l * [cos(angle), sin(angle)]]), positions))
end
