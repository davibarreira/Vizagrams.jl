struct Tick <: Mark
    pos::Vector
    text::String
    textplacement::Symbol
    fontsize::Int
    textangle::Real
    textanchor::Symbol
    mark
    ticktext_style::S
    # function Tick(ticklen, tickwidth, pos, text, textpos, fontsize, textangle)
    function Tick(
        pos, text, textplacement, fontsize, textangle, textanchor, mark, ticktext_style
    )
        # @assert ticklen ≥ 0 "Ticklen must be positive"
        # @assert tickwidth ≥ 0 "Tickwidth must be positive"
        @assert fontsize ≥ 0 "Font size must be positive"
        @assert textplacement in [:top, :bottom, :left, :right] "textplacement must be either :top, :bottom, :left or :right"
        @assert textanchor in [:c, :s, :n, :e, :w, :se, :sw, :ne, :nw]
        # new(ticklen, tickwidth, pos, text, textplacement, fontsize, textangle)
        return new(
            pos, text, textplacement, fontsize, textangle, textanchor, mark, ticktext_style
        )
    end
end
# Tick(; ticklen=4, tickwidth=1, pos=[0, 0], text="", textplacement=:bottom, fontsize=7, textangle=0) = Tick(ticklen, tickwidth, pos, string(text), textplacement, fontsize, textangle)
function Tick(;
    pos=[0, 0],
    text="",
    textplacement=:bottom,
    fontsize=7,
    textangle=0,
    ticklen=4,
    tickwidth=1,
    textanchor=:c,
    mark=Rectangle(; h=ticklen, w=tickwidth),
    ticktext_style=S(),
)
    return Tick(
        pos,
        string(text),
        textplacement,
        fontsize,
        textangle,
        textanchor,
        mark,
        ticktext_style,
    )
end

function ζ(tick::Tick)::𝕋{Mark}
    ticktext =
        tick.ticktext_style * TextMark(;
            text=tick.text,
            pos=tick.pos,
            fontsize=tick.fontsize,
            angle=tick.textangle,
            anchor=tick.textanchor,
        )
    # expr = T(0, 0) * Rectangle(tick.ticklen, tick.tickwidth, tick.pos, 0)
    expr = T(tick.pos) * tick.mark

    if tick.textplacement == :bottom
        expr = expr↓(T(0, -2), ticktext)
    elseif tick.textplacement == :top
        expr = expr↑(T(0, 2), ticktext)
    elseif tick.textplacement == :left
        expr = expr ← (T(-2, 0), ticktext)
    elseif tick.textplacement == :right
        expr = expr → (T(2, 0), ticktext)
    end
    return expr
end
