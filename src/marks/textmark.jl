struct TextMark <: Mark
    text::AbstractString
    pos::Vector
    fontsize::Real
    angle::Real
    anchor::Symbol
    fontfamily::String
    style::S
    function TextMark(text, pos, fontsize, angle, anchor, fontfamily, style)
        # @assert fontsize > 0.0 "Size must be a positive real number"
        @assert anchor in [:c, :s, :n, :e, :w, :se, :sw, :ne, :nw]
        return new(text, pos, fontsize, angle, anchor, fontfamily, style)
    end
end

"""
TextMark(; text="", pos=[0, 0], fontsize=12, angle=0, anchor=:c)

The text can be a number, which will be turned into a string.
The anchor values are:
```
ne ______n______ nw
  |             |
e |      c      | w
  |_____________|
se       s       sw
```
"""
# TextMark(; text="", pos=[0, 0], fontsize=10, angle=0, anchor=:c, fontfamily="Helvetica") =
#     TextMark(string(text), pos, fontsize, angle, anchor, fontfamily)

function TextMark(;
    text::Union{AbstractString,Number,Symbol,Char}="",
    pos=[0, 0],
    fontsize=10,
    angle=0,
    anchor=:c,
    fontfamily="Helvetica",
    style=S(),
)
    if text isa Number || text isa Symbol || text isa Char
        return TextMark(string(text), pos, fontsize, angle, anchor, fontfamily, style)
    end
    return TextMark(text, pos, fontsize, angle, anchor, fontfamily, style)
end

function ζ(textmark::TextMark)::𝕋{Mark}
    (; text, pos, fontsize, angle, anchor, fontfamily, style) = textmark # Destruct textmark

    if text isa LaTeXString
        return dmlift(
            LaTeX(; text=text, pos=pos, fontsize=fontsize, angle=angle, anchor=anchor)
        )
    end
    textgeom = TextGeom(text, pos, fontsize, 0, fontfamily)
    expr = T(-pos...)textgeom

    if anchor == :c
        expr = S(:textAnchor => :middle) * R(angle) * T(0, -fontsize / 2) * expr
    elseif anchor == :e
        expr = S(:textAnchor => :start) * R(angle) * T(0, -fontsize / 2) * expr
    elseif anchor == :w
        expr = S(:textAnchor => :end) * R(angle) * T(0, -fontsize / 2) * expr
    elseif anchor == :s
        expr = S(:textAnchor => :middle) * R(angle) * T(0, 0) * expr
    elseif anchor == :se
        expr = S(:textAnchor => :start) * R(angle) * T(0, 0) * expr
    elseif anchor == :sw
        expr = S(:textAnchor => :end) * R(angle) * T(0, 0) * expr
    elseif anchor == :n
        expr = S(:textAnchor => :middle) * R(angle) * T(0, -fontsize) * expr
    elseif anchor == :ne
        expr = S(:textAnchor => :start) * R(angle) * T(0, -fontsize) * expr
    elseif anchor == :nw
        expr = S(:textAnchor => :end) * R(angle) * T(0, -fontsize) * expr
    end
    return style * T(pos...) * expr
end
