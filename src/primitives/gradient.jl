struct LinearGradient <: GeometricPrimitive
    id::String
    pts::Vector
    offsets::Vector
    colors::Vector
    function LinearGradient(id, pts, offsets, colors)
        @assert length(offsets) == length(colors)
        if length(pts) == 1
            return new(id, [pts[1], pts[1]], offsets, colors)
        end
        return new(id, pts, offsets, colors)
    end
end

act(g::G, x::LinearGradient) = LinearGradient(x.id, map(g, x.pts), x.offsets, x.colors)

coordinates(l::LinearGradient) = l.pts
function LinearGradient(;
    id="lgrad_bluesreds",
    pts=[[0, 0], [1, 0]],
    offsets=[0, 0.5, 1],
    colors=["#00008B", "#CCD9CC", "#8B0000"],
)
    return LinearGradient(id, pts, offsets, colors)
end
