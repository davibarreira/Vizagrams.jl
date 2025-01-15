"""
envelope(t::GeometricPrimitive, s::S, v::Vector)

Given a geometric primitive `t`, a style `s` and a direction vector `v`,
the function computes the envelope for such geometric primitive
"""
function envelope(t::GeometricPrimitive, s::S, v::Vector)
    v = normalize(v)
    return mapreduce(p -> dot(p, v), max, coordinates(t))
end

function envelope(t::Circle, s::S, v::Vector)
    v = normalize(v)
    p = t.c + t.r * v
    return dot(p, v)
end

function envelope(t::Slice, s::S, v::Vector)
    v = normalize(v)
    vang = atan(v[2], v[1])
    if angle_in_sector(vang, t.θ - π / 2, t.ang + t.θ - π / 2)
        # if t.ang + t.θ ≥ vang ≥ t.θ
        p = t.c + t.rmajor * v
        return dot(p, v)
    end
    cov = ϕ(t)
    return mapreduce(p -> dot(p, v), max, [cov._1, cov._2, cov._3])
end

function envelope(t::Bezier, s::S, v::Vector)
    v = normalize(v)
    return mapreduce(p -> dot(p, v), max, vcat(t.bpts, t.cpts))
end

"""
envelope(t::QBezier, s::Style, v::Vector)

The envelope rotates the bezier curve by the angle
prescribed by `v`, then, it uses the method of finding
the maximum of a Bézier curve, which is simply taking
the derivating, equalling to zero and comparing with
the marginal points. For the case of several
quadratic Bézier functions stich together, it simply
compares the max of each segment.
"""
function envelope(t::QBezier, s::S, v::Vector)
    v = normalize(v)
    ang = clockwiseangle([0, 1], v)
    bez = QBezier(map(x -> rotatevec(x, ang), getpoints(t)))
    return dot(rotatevec(quadbeziermax(bez), -ang), v)
end

function envelope(t::CBezier, s::S, v::Vector)
    v = normalize(v)
    ang = clockwiseangle([0, 1], v)
    bez = CBezier(map(x -> rotatevec(x, ang), getpoints(t)))
    return dot(rotatevec(cubicbeziermax(bez), -ang), v)
end

function envelope(t::QBezierPolygon, s::S, v::Vector)
    return envelope(QBezier(vcat(t.bpts, [t.bpts[1]]), t.cpts), s, v)
end
function envelope(q::CBezierPolygon, s::S, v::Vector)
    bpts = collect(Consecutive(2; step=1)(vcat(q.bpts, [q.bpts[1]])))
    cpts = collect(Consecutive(2)(vcat(q.cpts, [q.cpts[1]])))
    d = map(x -> Prim(CBezier([x[1]...], [x[2]...])), zip(bpts, cpts))
    return envelope(d, v)
end

"""
inkbox(face, char)

Computes the inkboundingbox for a char given an specific `face` (font
obtained using the FreeTypeAbstraction).
"""
function inkbox(face::FTFont, char::Char)
    extent = FreeTypeAbstraction.get_extent(face, char)
    hb = FreeTypeAbstraction.inkboundingbox(extent)
    p1 = Vector(hb.origin)
    p2 = [p1[1] + hb.widths[1], p1[2] + hb.widths[2]]
    hadv = FreeTypeAbstraction.hadvance(extent)
    return p1, p2, hadv
end

"""
stringinkbox(face, str::String)

Given a face (fontfamily), computes the inkboundingbox for the
whole string by computing the boundingbox for each individual char.
"""
function stringinkbox(face::FTFont, str::String)
    v = [inkbox(face, x) for x in str]
    v, hadv = map(x -> [x[1], x[2]], v), map(x -> x[3], v)
    hadv = vcat(0, hadv[begin:(end - 1)])

    xmin = v[1][1][1]
    xmax = sum(hadv) + v[end][2][1]
    ymin = mapreduce(x -> x[1][2], min, v)
    ymax = mapreduce(x -> x[2][2], max, v)

    @assert !isnan(xmin) && !isnan(ymin) && !isnan(xmax) && !isnan(ymax) "inkbox computation resulted in NaNs (the font may be broken)"
    return [xmin, ymin], [xmax, ymax]
end

"""
stringinkbox(face::Nothing, str::String)

Estimates boundingbox for string when no font face is given.
"""
function stringinkbox(face::Nothing, str::String)
    l = length(str)
    lupper = sum([isuppercase(t) for t in str])
    llower = l - lupper
    xmax = (lupper / 1.15 + llower / 1.35)
    xmin = 0
    ymin = 0
    ymax = 3 / 4
    return [xmin, ymin], [xmax, ymax]
end

@memoize function load_font(fontfamily)
    face = FreeTypeAbstraction.findfont(fontfamily)
    if isnothing(face)
        fontname = "helvetica.ttf"
        fpath = joinpath(FONTS, fontname)
        face = FreeTypeAbstraction.try_load(fpath)
    end
    return face
end

function envelope(t::TextGeom, s::S, v::Vector)
    face = load_font(t.fontfamily)
    anchor = get(s.d, :textAnchor, :start)
    pos = t.pos
    fontsize = t.fontsize
    text = t.text
    if text == ""
        return nothing
    end
    ang = t.θ
    coord = 4 / 3 * fontsize .* stringinkbox(face, text)
    pinit = coord[1]
    coord = map(x -> x + pos, coord)
    lengthtext = coord[2][1] - coord[1][1]
    heighttext = coord[2][2] - coord[1][2]
    if anchor == :middle
        coord = map(x -> x - [lengthtext / 2 + pinit[1], 0], coord)
    elseif anchor == :end
        coord = map(x -> x - [lengthtext + pinit[1], 0], coord)
    end
    r = T(pos) ⋄ R(ang) ⋄ T(-pos)
    coord = map(r, coord)
    v = normalize(v)
    return mapreduce(p -> dot(p, v), max, coord)
end

function envelope(t::LinearGradient, s::S, v::Vector)
    return nothing
end

function envelope(e::Ellipse, s::S, v::Vector)
    # Normalize the direction vector
    v_global = normalize(v)

    # Compute the rotation matrix for the ellipse
    cosθ = cos(e.ang)
    sinθ = sin(e.ang)
    Rot = [cosθ -sinθ; sinθ cosθ]

    # Compute the covariance matrix of the ellipse
    D = Diagonal([e.rx^2, e.ry^2])
    Se = Rot * D * Rot'

    # Compute the support function (envelope)
    s = sqrt(v_global' * Se * v_global)

    # Return the envelope value
    return dot(e.c, v_global) + s
end

function envelope(a::Arc, s::S, v::Vector)
    v = normalize(v)
    vang = atan2pi(v)
    if angle_in_sector(vang, a.initangle + a.rot, a.finalangle + a.rot)
        return envelope(Ellipse(a.rx, a.ry, a.c, a.rot), v)
    end
    cov = ϕ(a)
    return mapreduce(p -> dot(p, v), max, [cov._4, cov._5])
end

envelope(p::Prim, v::Vector) = envelope(p.geom, p.s, v);
envelope(p::GeometricPrimitive, v::Vector) = envelope(p, S(), v);

# Let's create a function `fmax` that can compute the max when there are `nothing` values.
fmax(x, y) = max(x, y)
fmax(x, y::Nothing) = x
fmax(x::Nothing, y) = y
fmax(x::Nothing, y::Nothing) = nothing

function envelope(d::Vector{<:Prim}, v::Vector)
    return mapreduce(x -> envelope(x, v), fmax, d; init=nothing)
end

# function boundingbox(p::Union{Prim,GeometricPrimitive,Vector{Prim}})
#     v = [-1, 0]

#     e1 = (envelope(p, v)*v)[1]

#     v = [0, -1]
#     e2 = (envelope(p, v)*v)[2]
#     d1 = [e1, e2]

#     v = [1, 0]
#     e3 = (envelope(p, v)*v)[1]

#     v = [0, 1]
#     e4 = (envelope(p, v)*v)[2]
#     d2 = [e3, e4]
#     return [d1, d2]
# end

function boundingbox(p::Union{M where M<:Prim,GeometricPrimitive,Vector{<:Prim}})
    directions = [[-1, 0], [0, -1], [1, 0], [0, 1]]
    e = []
    for (v, i) in zip(directions, [1, 2, 1, 2])
        env = envelope(p, v)
        if isnothing(env)
            return nothing
        end
        push!(e, (env * v)[i])
    end
    d1 = [e[1], e[2]]
    d2 = [e[3], e[4]]
    return [d1, d2]
end
