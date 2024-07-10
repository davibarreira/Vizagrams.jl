struct Trail <: Mark
    pts::Vector
    ws::Union{Real,Vector,Tuple}
    function Trail(pts, ws)
        @assert length(ws) == 1 || length(ws) == length(pts) "Width must either have length(ws)==1 or length(ws)==length(pts)"
        return new(pts, ws)
    end
end

Trail(; pts=[[0, 0], [1, 1]], ws=1) = Trail(pts, ws)

"""
compute_perpendicular_points(pts, ang=π / 2)

Helper function for drawing trail. It takes a collection of points
and obtains the points perpendicular to them (or another angle, given the
parameter `ang`).
"""
function compute_perpendicular_points(pts, angles, ws, ang=π / 2)
    perps = []
    for i in 1:length(pts)
        if i == 1
            anglein = angles[i] + ang
            vin = pts[i] + R(anglein)([ws[i], 0])
            push!(perps, vin)
            continue
        elseif i == length(pts)
            anglein = angles[i - 1] + ang
            vin = pts[i] + R(anglein)([ws[i], 0])
            push!(perps, vin)
            continue
        end
        anglein = angles[i - 1] + ang
        angleout = angles[i] + ang
        vin = pts[i] + R(anglein)([ws[i], 0])
        vout = pts[i] + R(angleout)([ws[i], 0])
        push!(perps, vin, vout)
    end
    return perps
end

"""
compute_point_line_extension(r::Real, a::Line, b::Line)

Helper function. It takes two lines and the radius, and extend them
by 5 times the radius. The first line is extended by the final point,
while the second is extended by the first. If the two lines intersect after the extension,
it then returns the intersection point. Otherwise, it returns the two
non-extended points.
"""
function compute_point_line_extension(r::Real, a::Line, b::Line)
    ae = a.pts[2] + 5r * normalize(a.pts[2] - a.pts[1])
    ae = Line([a.pts[2], ae])

    be = b.pts[1] - 5r * normalize(b.pts[2] - b.pts[1])

    be = Line([b.pts[1], be])
    flag, ipt = intersects(ae, be)
    if flag
        return [ipt]
    end
    return [a.pts[2], b.pts[1]]
end

"""
compute_extension_or_cutoff(r::Real,a::Line,b::Line,pt)

Given two lines and the radius, it computes the intersection point, which
can be achieved by cutting off the lines, or by extending them and finding the intersection.
"""
function compute_extension_or_cutoff(r::Real, a::Line, b::Line, pt)
    flag, ipt = intersects(a, b)
    if flag
        return [ipt]
    end
    return compute_point_line_extension(r, a, b)
end

function ζ(trail::Trail)::𝕋{Mark}
    (; pts, ws) = trail

    # Turn vector oftuples into vector of vectors
    pts = map(x -> [x...], pts)

    # Adjusting in case of single value for trail
    if length(ws) == 1
        ws = map(x -> ws, pts)
    end

    # Compute angles
    angles = collect(
        Map(v -> atan(v[2], v[1]))(Map(x -> x[2] - x[1])(Partition(2; step=1)(pts)))
    )

    # Compute points perpendicular to the line
    pts_pos = compute_perpendicular_points(pts, angles, ws)
    pts_neg = compute_perpendicular_points(pts, angles, ws, -π / 2)

    # Create list of extruded line segments by pairing each points.
    ls_pos = collect(
        Map(x -> [Line([x[1], x[2]]), Line([x[3], x[4]])])(Partition(4; step=2)(pts_pos))
    )
    ls_neg = collect(
        Map(x -> [Line([x[1], x[2]]), Line([x[3], x[4]])])(Partition(4; step=2)(pts_neg))
    )

    # Compute the intersections between segments, obtaining new points for the trail
    new_pts_neg = []
    new_pts_pos = []
    for i in 1:length(ls_neg)
        npt = compute_extension_or_cutoff(ws[i + 1], ls_neg[i]..., pts[i + 1])
        push!(new_pts_neg, npt...)

        ppt = compute_extension_or_cutoff(ws[i + 1], ls_pos[i]..., pts[i + 1])
        push!(new_pts_pos, ppt...)
    end

    # Concatenate new points with initial and final points
    new_pts_neg = [pts_neg[begin], new_pts_neg..., pts_neg[end]]
    new_pts_pos = [pts_pos[begin], new_pts_pos..., pts_pos[end]]

    linep = S()Polygon(vcat(new_pts_pos, reverse(new_pts_neg)))
    return linep
end
