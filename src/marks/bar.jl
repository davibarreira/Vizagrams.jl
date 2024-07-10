struct Bar <: Mark
    h::Real
    w::Real
    c::Vector
    angle::Real
    orientation::Symbol
    function Bar(h, w, c, angle, orientation)
        @assert orientation in [:h, :v] "Must be either :h or :v"
        return new(h, w, c, angle, orientation)
    end
end

"""
Bar(; h=1, w=2, c=[0, 0], angle=0, orientation=:v)
"""
function Bar(; h=1, w=2, c=[0, 0], angle=0, orientation=:v)
    return Bar(h, w, c, angle, orientation)
end

function ζ(b::Bar)::𝕋{Mark}
    (; h, w, c, angle, orientation) = b

    rect = Rectangle(h, w, c, angle)
    if orientation == :v
        return T(0, rect.h / 2) * rect
    end
    return T(rect.w / 2, 0) * rect
end

# function Base.getproperty(bar::Bar, field::Symbol)
#     if field in [:rect, :orientation]
#         return getfield(bar, field)
#     end
#     return getfield(bar.rect, field)
# end
# Base.propertynames(bar::Bar) = (:rect, :orientation, propertynames(bar.rect)...)
#
# struct VBar <: Mark
#     x::Real
#     top::Real
#     bottom::Real
#     w::Real
# end

# """
# VBar()
# """
# function VBar(; x=0, top=1, bottom=0, w=1)
#     return VBar(x, top, bottom, w)
# end
# function ζ(b::VBar)::𝕋{Mark}
#     (; x, top, bottom, w) = b
#     pt1 = [x + w / 2, top]
#     pt2 = [x - w / 2, bottom]

#     return S()rectangle(pt1, pt2)
# end
