struct Title <: Mark
    textmark::Mark
end

function Title(; text="", fontsize=10, pos=[0, 0], kwargs...)
    return Title(TextMark(; text=text, fontsize=fontsize, pos=pos, kwargs...))
end

function ζ(title::Title)::𝕋{Mark}
    return η(title.textmark)
end
