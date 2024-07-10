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
normalize_graphic(t::TMark)::TMark

Takes a mark tree, centralizes it and then
scale it to 1x1 size.
"""
function normalize_graphic(t::TMark)::TMark
    t = centralize_graphic(t)
    bb = boundingbox(t)
    w, h = bb[2] - bb[1]
    s = 2min(1 / w, 1 / h)
    return U(s) * t
end
