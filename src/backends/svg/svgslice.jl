"""
arc(xstart, ystart, r, xend, yend, largearcflag; anginit=0, sweepflag=1)

Generates an SVG path string for an arc segment starting at `(xstart, ystart)` and ending at `(xend, yend)` 
with radius `r`. The `largearcflag` and `sweepflag` control the arc's appearance. Optional `anginit` specifies 
the initial angle of the arc.
"""
function arc(xstart, ystart, r, xend, yend, largearcflag; anginit=0, sweepflag=1)
    return d = "M $(xstart) $(ystart) A $(r) $(r) $(anginit) $(largearcflag) $(sweepflag) $(xend) $(yend)"
end

"""
Note that the M is to "move the pen". Hence, if we wish to continuosly draw a figure in SVG
so that the stroke does not break, then we can't move the pen from where it is.
Lastly, we finish the figure with the `Z` which represents close-path.
"""
function arccontinue(r, xend, yend, largearcflag; anginit=0, sweepflag=1)
    return d = "A $(r) $(r) $(anginit) $(largearcflag) $(sweepflag) $(xend) $(yend)"
end

"""
arcendpoint(ang, xstart, ystart, r)

Computes the endpoint `(x, y)` of an arc segment given the angle `ang`, 
starting coordinates `(xstart, ystart)`, and radius `r`.
"""
function arcendpoint(ang, xstart, ystart, r)
    xend = r * sin(ang) + xstart
    yend = r - r * cos(ang) + ystart
    return (xend, yend)
end

"""
svgslice(; ang=π / 2, rminor=0, rmajor=100, center=[0, 0], anginit=0)

Generates an SVG path string representing a circular slice (or sector) with specified parameters:
- `ang`: Angle of the slice in radians.
- `rminor`: Inner radius of the slice.
- `rmajor`: Outer radius of the slice.
- `center`: Center coordinates of the slice.
- `anginit`: Initial angle offset in radians.

Returns a string defining the SVG path for the slice.
"""
function svgslice(; ang=π / 2, rminor=0, rmajor=100, center=[0, 0], anginit=0)
    if ang ≈ 2π || ang ≥ 2π
        ang = 2π * 0.999999
    end

    largearcflag = 0
    if ang > π
        largearcflag = 1
    end

    pin = [center[1], center[2] - rmajor]
    x₀ = rmajor * sin(anginit) + pin[1]
    y₀ = rmajor - rmajor * cos(anginit) + pin[2]
    pstart = [x₀, y₀]

    ang = ang + anginit
    x₁ = rmajor * sin(ang) + pin[1]
    y₁ = rmajor - rmajor * cos(ang) + pin[2]
    d = arc(pstart[1], pstart[2], rmajor, x₁, y₁, largearcflag)

    x₂ = rminor * sin(ang) + pin[1]
    y₂ = rmajor - rminor * cos(ang) + pin[2]

    pin2 = [center[1], center[2] - rminor]
    x₃ = rminor * sin(anginit) + pin2[1]
    y₃ = rminor - rminor * cos(anginit) + pin2[2]
    dmin = arccontinue(rminor, x₃, y₃, largearcflag; sweepflag=0)

    l1 = "L $(x₂) $(y₂)"
    dnew = d * l1 * dmin * "Z"
    return dnew
end
