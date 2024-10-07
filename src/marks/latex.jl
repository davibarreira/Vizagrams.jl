struct LaTeX <: Mark
    text::LaTeXString
    pos::Vector
    fontsize::Real
    angle::Real
    anchor::Symbol
    function LaTeX(text, pos, fontsize, angle, anchor)
        @assert fontsize > 0.0 "Size must be a positive real number"
        return new(text, pos, fontsize, angle, anchor)
    end
end
function LaTeX(; text=L"x", pos=[0, 0], fontsize=12, angle=0, anchor=:se)
    return LaTeX(text, pos, fontsize, angle, anchor)
end

"""
function getfontstyleweight(font)
The type for `font` must be `FreeTypeAbstraction.FTFont`.
The function returns a tuple with the style
which is either "italic" or "", and the weight
which is either "bold" or "".
"""
function getfontstyleweight(font::FTFont)
    fontstyle = ""
    fontweight = ""
    fs = font.style_name
    if occursin("Italic", fs)
        fontstyle = "italic"
    end
    if occursin("Bold", fs)
        fontweight = "bold"
    end
    return fontstyle, fontweight
end
"""
    rawlatexboundingbox(lstr::LaTeXString, font_size=1)

Helper function that returns the coordinate points
of the bounding box containing the specific LaTeX text.
"""
function rawlatexboundingbox(lstr::LaTeXString)
    sentence = generate_tex_elements(lstr)
    els = filter(x -> x[1] isa TeXChar, sentence)
    texchars = [x[1] for x in els]
    pos_x = [x[2][1] for x in els]
    pos_y = [x[2][2] for x in els]
    scales = [x[3] for x in els]
    textw = maximum(MathTeXEngine.inkwidth.(texchars) .* scales .+ pos_x)
    bottom = MathTeXEngine.bottominkbound.(texchars)
    left = minimum(MathTeXEngine.leftinkbound.(texchars) .+ pos_x)
    right = maximum(MathTeXEngine.rightinkbound.(texchars) .+ pos_x)
    bottom_pt = [left, -maximum(-bottom .* scales .- pos_y)]
    top_pt = [
        right, maximum(MathTeXEngine.inkheight.(texchars) .* scales .+ pos_y .+ bottom)
    ]

    return (bottom_pt, top_pt)
end

"""
parse_word(s::T where {T<:Tuple{<:MathTeXEngine.TeXChar,<:Any,<:Any}})::TMark

Turns a tuple from the `generate_tex_elements` containing a TeXChar into a TMark.
"""
function parse_word(s::T where {T<:Tuple{<:MathTeXEngine.TeXChar,<:Any,<:Any}})::TMark
    char = string(s[1].represented_char)
    italic, weight = getfontstyleweight(s[1].font)
    fontfamily = s[1].font.family_name
    pos = s[2]
    scale = s[3] * 3 / 4 #adjust font due to difference in pt to pixel

    # Small fix for summation
    if s[1].represented_char == '∑'
        scale = s[3]
        pos = s[2] - [0, 0.1]

        # big fix for sqrt
    elseif s[1].represented_char == '√'
        pos = s[2] + [0.0, 0.79]
        t =
            S(:fontFamily => fontfamily, :fontWeight => weight, :fontStyle => italic) *
            TextMark(; text=char, pos=[0, 0], fontsize=scale, anchor=:se)

        return U(4 / 3)T(pos) * (t + Rectangle(; c=[1.08, 0.023], w=0.5, h=0.038))
    end

    t =
        S(:fontFamily => fontfamily, :fontWeight => weight, :fontStyle => italic) *
        TextMark(; text=char, pos=[0, 0], fontsize=scale, anchor=:se)

    return U(4 / 3)T(pos) * t
end

"""
parse_word(s::T where {T<:Tuple{<:MathTeXEngine.HLine,<:Any,<:Any}})::TMark

Turns a tuple from the `generate_tex_elements` containing a HLine into a TMark.
"""
function parse_word(s::T where {T<:Tuple{<:MathTeXEngine.HLine,<:Any,<:Any}})::TMark
    p1 = s[2] - [0, s[1].thickness]
    p2 = [p1[1] + s[1].width, p1[2] + s[1].thickness]
    return U(4 / 3)T(0, 0)Vizagrams.rectangle(Vector(p1), Vector(p2))
end

"""
latex_to_text(text::LaTeXString)
"""
function latex_to_text(text::LaTeXString)
    sentence = generate_tex_elements(text)
    return mapreduce(parse_word, +, sentence)
end

function ζ(latex::LaTeX)::𝕋{Mark}
    (; text, pos, fontsize, angle, anchor) = latex
    p1, p2 = 4 / 3 * fontsize .* rawlatexboundingbox(text)
    text = U(fontsize)latex_to_text(text)

    w = p2[1] - p1[1]
    h = p2[2] - p1[2]
    t = T(0, 0)
    if anchor == :w
        t = T(-p2[1], 0)
    elseif anchor == :c
        t = T(-w / 2, -h / 2 - p1[2])
    elseif anchor == :ce
        t = T(0, -h / 2 - p1[2])
    elseif anchor == :cw
        t = T(-p2[1], -h / 2 - p1[2])
    elseif anchor == :n
        t = T(-w / 2, -p2[2])
    elseif anchor == :ne
        t = T(0, -p2[2])
    elseif anchor == :nw
        t = T(-p2[1], -p2[2])
    elseif anchor == :s
        t = T(-w / 2, 0)
    elseif anchor == :se
        t = T(0, 0)
    elseif anchor == :sw
        t = T(-p2[1], 0)
    end
    return t * (text + S(:fillOpacity => 0)rectangle(p1, p2))
end
