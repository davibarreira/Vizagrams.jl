"""
centralize_graphic(t::TMark)::TMark

Takes a mark tree and centralizes it in the canvas.
"""
function centralize_graphic(t::TMark)::TMark
    bb = boundingbox(t)
    tw, th = (bb[2] + bb[1]) ./ 2
    return T(-tw, -th) * t
end

"""
normalize_graphic(t::TMark,direction=nothing)::TMark

Takes a mark tree, centralizes it and then
scale it to 1x1 size. The direction specifies
whether the scaling prioritizes the :width, :height or nothing.
If the direction is `nothing`, then the function guarantees
that the larger (width or height) is scaled in order to give 1.
Using `direction=:width`, we guarantee a total width is 1,
and using `:height` we guarantee that the height is 1.
"""
function normalize_graphic(t::TMark, direction=nothing)::TMark
    t = centralize_graphic(t)
    bb = boundingbox(t)
    w, h = bb[2] - bb[1]
    if isnothing(direction)
        s = 2min(1 / w, 1 / h)
    elseif direction == :width
        s = 2 / w
    elseif direction == :height
        s = 2 / h
    end
    return U(s) * t
end
