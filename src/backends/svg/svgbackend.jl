SVG = Hyperscript.Node{Hyperscript.HTMLSVG}
⋄(x::SVG, y::SVG) = x(y)
⋄(x::Nothing, y::SVG) = y
⋄(x::SVG, y::Nothing) = x

"""
dicttostring(d::Dict)

Given a dictionary, turns it into a string, e.g.
```
Dict(:strokeWidth=>1)

"stroke-width: 1"
```
"""
function dicttostring(d::Dict)
    result = ""
    for (key, value) in d
        # change camelCase to hyphen , e.g. strokeWidth -> stroke-width
        key = camelcase_to_hyphen(string(key))
        if value isa Color
            value = "#" * hex(value)
        end
        result *= key * ": " * string(value) * "; "
    end
    return result
end

"""
split_style_attributes(s::S) -> (Dict, Dict)

Splits the style attributes of a given object `s` into two separate dictionaries.

# Arguments
- `s::S`: An object containing a dictionary `d` with style attributes.

# Returns
A tuple of two dictionaries:
1. `sty::Dict`: A dictionary containing the style attributes that do not start with `__`.
2. `attr::Dict`: A dictionary containing the attributes whose keys start with `__`. The `__` prefix is removed from the keys in this dictionary.
"""
function split_style_attributes(s::S)
    d = s.d
    attr = Dict()
    sty = Dict()
    for (key, value) in d
        if startswith(string(key), "__")
            adjusted_key = Symbol(string(key)[3:end])
            attr[adjusted_key] = value
        else
            sty[key] = value
        end
    end
    return sty, attr
end


"""
vectostring(v::Vector{Tuple{T, T}}) where T

Converts a vector of 2-tuples into a single string, where each tuple's elements are 
concatenated with a space in between. The resulting string contains all tuples' 
elements separated by spaces.
"""
vectostring(v) = foldl((x, y) -> x * string(y[1]) * " " * string(y[2]) * " ", v; init="")

"""
function primtosvg(p::Prim, heightcanvas::Int)

We use the height of the SVG canvas in order to adjust the
coordinate system, i.e.

.->---------
↓           |
|           |         
|           |
|           | 
↑           | 
.->---------
"""
function primtosvg(p::Prim)
    geom = p.geom
    # Applies the `non-scaling-stroke` to all elements by default. This makes
    # strokes properly scale
    s = S(:vectorEffect => "non-scaling-stroke") ⋄ p.s

    return primtosvg(geom, s)
end

"""
primtosvg(g::Circle, s::Style) = m("circle", cx=p.geom.c[1], cy=p.geom.c[2], r=p.geom.r, style=dicttostring(p.s.d))
"""
function primtosvg(geom::Circle, s::S)
    sty, attr = split_style_attributes(s)
    return m(
        "circle";
        cx=geom.c[1],
        cy=geom.c[2],
        r=geom.r,
        style=dicttostring(sty),
        transform="scale(1,-1)",
        attr...,
    )
end

"""
primtosvg(geom::Line, s::Style) = m("polyline", points= vectostring(geom.pts), style=dicttostring(s.d))
"""
function primtosvg(geom::Line, s::S)
    # Polyline in SVG has fill, hence the 
    s = S(:fill => "none", :stroke => :black) ⋄ s
    pts = map(x -> [x[1], x[2]], geom.pts)
    sty, attr = split_style_attributes(s)
    return m(
        "polyline";
        points=vectostring(pts),
        style=dicttostring(sty),
        transform="scale(1,-1)",
        attr...,
    )
end

"""
primtosvg(g::QBezier, s::Style)
"""
function primtosvg(geom::QBezier, s::S)
    # Polyline in SVG has fill, hence the 
    s = S(:fill => "none", :stroke => :black) ⋄ s
    bpts = map(x -> [x[1], x[2]], geom.bpts)
    cpts = map(x -> [x[1], x[2]], geom.cpts)
    dpath = "M$(bpts[1][1]) $(bpts[1][2]) Q $(cpts[1][1]) $(cpts[1][2]), $(bpts[2][1]) $(bpts[2][2]) "
    for i in 3:length(bpts)
        dpath *=
            string(cpts[i - 1][1]) *
            " " *
            string(cpts[i - 1][2]) *
            " " *
            string(bpts[i][1]) *
            " " *
            string(bpts[i][2]) *
            " "
    end
    sty, attr = split_style_attributes(s)
    return m("path"; d=dpath, style=dicttostring(sty), transform="scale(1,-1)", attr...)
end

function primtosvg(geom::CBezier, s::S)
    # Polyline in SVG has fill, hence the 
    s = S(:fill => "none", :stroke => :black) ⋄ s
    bpts = map(x -> [x[1], x[2]], geom.bpts)
    cpts = map(x -> [x[1], x[2]], geom.cpts)
    dpath = "M$(bpts[1][1]) $(bpts[1][2]) C $(cpts[1][1]) $(cpts[1][2]) $(cpts[2][1]) $(cpts[2][2]) $(bpts[2][1]) $(bpts[2][2]) "
    for i in 3:length(bpts)
        path1 =
            string(cpts[2(i - 1) - 1][1]) *
            " " *
            string(cpts[2(i - 1) - 1][2]) *
            " " *
            string(cpts[2(i - 1)][1]) *
            " " *
            string(cpts[2(i - 1)][2]) *
            " "
        dpath *= path1 * string(bpts[i][1]) * " " * string(bpts[i][2]) * " "
    end
    sty, attr = split_style_attributes(s)
    return m("path"; d=dpath, style=dicttostring(sty), transform="scale(1,-1)", attr...)
end

function primtosvg(geom::QBezierPolygon, s::S)
    # Polyline in SVG has fill, hence the 
    bpts = map(x -> [x[1], x[2]], vcat(geom.bpts, [geom.bpts[1]]))
    cpts = map(x -> [x[1], x[2]], geom.cpts)
    dpath = "M$(bpts[1][1]) $(bpts[1][2]) Q $(cpts[1][1]) $(cpts[1][2]) $(bpts[2][1]) $(bpts[2][2]) "
    for i in 3:length(bpts)
        dpath *=
            string(cpts[i - 1][1]) *
            " " *
            string(cpts[i - 1][2]) *
            " " *
            string(bpts[i][1]) *
            " " *
            string(bpts[i][2]) *
            " "
    end
    sty, attr = split_style_attributes(s)
    return m(
        "path"; d=dpath * " Z", style=dicttostring(sty), transform="scale(1,-1)", attr...
    )
end

function primtosvg(geom::CBezierPolygon, s::S)
    # Polyline in SVG has fill, hence the 
    s = S(:fill => "none", :stroke => :black) ⋄ s
    bpts = map(x -> [x[1], x[2]], geom.bpts)
    cpts = map(x -> [x[1], x[2]], geom.cpts)

    bpts = collect(Consecutive(2; step=1)(vcat(bpts, [bpts[1]])))
    cpts = collect(Consecutive(2)(vcat(cpts, [cpts[1]])))

    dpath = ""
    for i in 1:length(bpts)
        if i == 1
            dpath *= "M $(bpts[i][1][1]) $(bpts[i][1][2]) C $(cpts[i][1][1]) $(cpts[i][1][2]) $(cpts[i][2][1]) $(cpts[i][2][2]) $(bpts[i][2][1]) $(bpts[i][2][2]) "
            continue
        elseif i == length(bpts)
            dpath *= "C $(cpts[i][1][1]) $(cpts[i][1][2]) $(cpts[i][2][1]) $(cpts[i][2][2]) $(bpts[i][2][1]) $(bpts[i][2][2]) "
            continue
        end
        dpath *= "$(cpts[i][1][1]) $(cpts[i][1][2]) $(cpts[i][2][1]) $(cpts[i][2][2]) $(bpts[i][2][1]) $(bpts[i][2][2]) "
    end
    sty, attr = split_style_attributes(s)
    return m(
        "path"; d=dpath * " Z", style=dicttostring(sty), transform="scale(1,-1)", attr...
    )
end

function primtosvg(geom::T, s::S) where {T<:Union{Polygon,RegularPolygon,Square,Rectangle}}
    coords = map(x -> [x[1], x[2]], coordinates(geom))
    sty, attr = split_style_attributes(s)
    return m(
        "polygon";
        points=vectostring(coords),
        style=dicttostring(sty),
        transform="scale(1,-1)",
        attr...,
    )
end

function primtosvg(geom::TextGeom, s::S)
    if !isnothing(get(s.d, :fontSize, nothing))
        # s.d[:fontSize] = string(s.d[:fontSize]) * "pt"
        delete!(s.d, :fontSize)
    end
    s =
        S(
            :fontSize => string(geom.fontsize) * "pt",
            :textAnchor => :start,
            :fontFamily => geom.fontfamily,
        ) ⋄ s
    posx = geom.pos[1]
    # posy = h - geom.pos[2]
    posy = geom.pos[2]

    sty, attr = split_style_attributes(s)
    return m(
        "text",
        geom.text;
        x=posx,
        y=posy,
        transform="translate(0 $(-2posy)) rotate($(rad2deg(-geom.θ)), $(posx), $(posy))",
        style=dicttostring(sty),
        attr...,
    )
end

function primtosvg(geom::Slice, s::S)
    s = S(:fill => :blue, :stroke => "black") ⋄ s
    # c = [geom.c[1], h - geom.c[2]]
    c = [geom.c[1], geom.c[2]]

    dpath = svgslice(;
        ang=geom.ang, rmajor=geom.rmajor, rminor=geom.rminor, center=c, anginit=geom.θ
    )

    sty, attr = split_style_attributes(s)
    return m("path"; d=dpath, style=dicttostring(sty), transform="scale(1,-1)", attr...)
end

"""
primtosvg(geom::LinearGradient, s::Style) = m("polyline", points= vectostring(geom.pts), style=dicttostring(s.d))
"""
function primtosvg(geom::LinearGradient, s::S)
    x1, y1 = geom.pts[1]
    x2, y2 = geom.pts[2]

    stops = map(v -> m("stop"; offset=v[1], stopColor=v[2]), zip(geom.offsets, geom.colors))

    return m(
        "defs",
        m(
            "linearGradient",
            stops...;
            transform="scale(1,-1)",
            id=geom.id,
            x1=x1,
            y1=y1,
            x2=x2,
            y2=y2,
        ),
    )
end

"""
primtosvg(g::Ellipse, s::Style) =
m("ellipse", cx=p.geom.c[1], cy=p.geom.c[2], rx=p.geom.rx, ry=p.geom.ry, transform="rotate(\$(r.ang))", style=dicttostring(p.s.d))
"""
function primtosvg(geom::Ellipse, s::S)
    sty, attr = split_style_attributes(s)
    return m(
        "ellipse";
        cx=geom.c[1],
        cy=geom.c[2],
        rx=geom.rx,
        ry=geom.ry,
        style=dicttostring(sty),
        transform="scale(1,-1) rotate($(rad2deg(geom.ang)) $(geom.c[1]) $(geom.c[2]))",
        attr...,
    )
end

function primtosvg(geom::Arc, s::S)
    s = S(:fill => "none", :stroke => :black) ⋄ s
    sty, attr = split_style_attributes(s)
    # Compute the start and stop points on the unrotated ellipse
    start_point =
        rotatevec(point_on_ellipse(geom.initangle, geom.rx, geom.ry, [0, 0]), geom.rot) +
        geom.c
    stop_point =
        rotatevec(point_on_ellipse(geom.finalangle, geom.rx, geom.ry, [0, 0]), geom.rot) +
        geom.c
    if start_point ≈ stop_point
        return nothing
    end

    # SVG uses degrees for rotation
    rot_degrees = rad2deg(geom.rot)

    # Calculate flags for large arc and sweep (clockwise vs counterclockwise)
    large_arc_flag = abs(geom.finalangle - geom.initangle) > π ? 1 : 0
    sweep_flag = geom.finalangle > geom.initangle ? 1 : 0
    # SVG path command for the elliptical arc
    path_data = "M $(start_point[1]) $(start_point[2]) A $(geom.rx) $(geom.ry) $rot_degrees $large_arc_flag $sweep_flag $(stop_point[1]) $(stop_point[2])"

    # Return the complete SVG path element
    return m(
        "path";
        d=path_data,
        style=dicttostring(sty),
        transform="scale(1,-1)",  # Flips y-axis
        attr...,
    )
end

function reducesvg(x::Vector{SVG}; style="", kwargs...)
    return reduce(⋄, x; init=m("svg"; kwargs...))
    #     tag = m("svg"; xmlns="http://www.w3.org/2000/svg", version="1.1", kwargs...)
    #     style_tag = m(
    #         "style",
    #         """
    # .mycircle {
    #   fill: gold !important;
    #   stroke: maroon;
    #   stroke-width: 2px;
    # }
    # """,
    #     )
    #     tag = tag ⋄ style_tag
    #     return reduce(⋄, x; init=tag)
end

svg_elements(obj::TDiagram) = map(p -> primtosvg(p), flatten(obj))
svg_elements(obj::Vector{<:Prim}) = map(p -> primtosvg(p), obj)
svg_elements(obj::Prim) = map(p -> primtosvg(p), [obj])
svg_elements(obj::GeometricPrimitive) = map(p -> primtosvg(p), [Prim(obj)])
svg_elements(obj::𝕋{<:Mark}) = map(p -> primtosvg(p), flatten(obj))

"""
tosvg(obj; height=200, width=1000)

Converts various types of objects into an SVG.
"""
function tosvg(obj; height=200, width=1000, kwargs...)
    return reducesvg(svg_elements(obj); height=height, width=width, kwargs...)
end

"""
drawsvg(d::𝕋; height=300, pad=10)
Takes a diagram `𝕋` and returns an SVG with
height 100 using the envelope of the diagram to compute
the width.
"""
function drawsvg(
    d::𝕋;
    height::Union{Real,Nothing}=300,
    pad::Union{Real,Nothing}=10,
    width::Union{Real,Nothing}=nothing,
    adjust_stroke::Bool=false,
    kwargs...,
)
    bb = boundingbox(d)
    if isnothing(bb) || bb ≈ [[0.0, 0.0], [0.0, 0.0]]
        return tosvg(Prim[]; height=height, kwargs...)
    end
    boxwidth = bb[2][1] - bb[1][1]
    boxheight = bb[2][2] - bb[1][2]

    heightproportion = 1
    if !isnothing(height)
        heightproportion = height / boxheight
    end

    widthproportion = 1
    if !isnothing(width)
        widthproportion = width / boxwidth
    end

    height = isnothing(height) ? widthproportion * boxheight : height
    width = isnothing(width) ? boxwidth * heightproportion : width
    pad = pad / heightproportion

    viewBox = "$(bb[1][1]-pad/2) $(-bb[2][2]-pad/2) $(boxwidth+pad) $(boxheight+pad)",
    return tosvg(
        d;
        height=height,
        width=width,
        viewBox="$(bb[1][1]-pad/2) $(-bb[2][2]-pad/2) $(boxwidth+pad) $(boxheight+pad)",
        preserveAspectRatio="xMidYMid meet",
        kwargs...,
    )
end
function drawsvg(
    p::Union{GeometricPrimitive,Prim,Vector{Prim},Mark};
    height::Union{Real,Nothing}=300,
    pad::Union{Real,Nothing}=10,
    width::Union{Real,Nothing}=nothing,
    adjust_stroke::Bool=false,
    kwargs...,
)
    return drawsvg(
        dmlift(p);
        height=height,
        pad=pad,
        width=width,
        adjust_stroke=adjust_stroke,
        kwargs...,
    )
end
