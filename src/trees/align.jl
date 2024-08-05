"""
align_transform(d1::𝕋, d2::𝕋, v::Vector)

Computes alignment transformation.
"""
function align_transform(d1::𝕋, d2::𝕋, v::Vector)
    e1 = envelope(d1, v)
    e2 = envelope(d2, v)
    if isnothing(e1) || isnothing(e2)
        return G(IdentityTransformation())
    end
    return T((e1 - e2) * v)
end

# """
# align(
#     d1::𝕋,
#     d2::𝕋,
#     v::Vector;
#     g::G=G(IdentityTransformation()),
#     h::G=G(IdentityTransformation()),
# )

# Returns `h * d1 + g * T((e1 - e2) * v) * d2` where
# `e1` and `e2` are the envelopes.
# """
# function align(
#     d1::𝕋,
#     d2::𝕋,
#     v::Vector;
#     g::G=G(IdentityTransformation()),
#     h::G=G(IdentityTransformation()),
# )
#     e1 = envelope(d1, v)
#     e2 = envelope(d2, v)
#     if isnothing(e1) || isnothing(e2)
#         return d1 + d2
#     end
#     return h * d1 + g * T((e1 - e2) * v) * d2
# end

# acenter(d1::Valid, d2::Valid) = align_transform(dmlift(d1), dmlift(d2), [1 / 2, 0]) #\uparrow
# amiddle(d1::Valid, d2::Valid) = align_transform(dmlift(d1), dmlift(d2), [0, 1 / 2]) #\uparrow
function acenter(d1::Valid, d2::Valid)
    e1 = envelope(dmlift(d1), [1, 0])
    e_1 = envelope(dmlift(d1), [-1, 0])
    e2 = envelope(dmlift(d2), [1, 0])
    e_2 = envelope(dmlift(d2), [-1, 0])
    if nothing in [e1, e_1, e2, e_2]
        return T(0, 0)
    end
    m1 = (e1 - e_1) / 2
    m2 = (e2 - e_2) / 2
    return T(m1 - m2, 0)
end

function amiddle(d1::Valid, d2::Valid)
    e1 = envelope(dmlift(d1), [0, 1])
    e_1 = envelope(dmlift(d1), [0, -1])
    e2 = envelope(dmlift(d2), [0, 1])
    e_2 = envelope(dmlift(d2), [0, -1])
    if nothing in [e1, e_1, e2, e_2]
        return T(0, 0)
    end
    m1 = (e1 - e_1) / 2
    m2 = (e2 - e_2) / 2
    return T(0, m1 - m2)
end

# function acenter(d1::Valid, d2::Valid)
#     m1 = (envelope(dmlift(d1), [1, 0]) - envelope(dmlift(d1), [-1, 0])) / 2
#     m2 = (envelope(dmlift(d2), [1, 0]) - envelope(dmlift(d2), [-1, 0])) / 2
#     return T(m1 - m2, 0)
# end
# function amiddle(d1::Valid, d2::Valid)
#     m1 = (envelope(dmlift(d1), [0, 1]) - envelope(dmlift(d1), [0, -1])) / 2
#     m2 = (envelope(dmlift(d2), [0, 1]) - envelope(dmlift(d2), [0, -1])) / 2
#     return T(0, m1 - m2)
# end

aright(d1::Valid, d2::Valid) = align_transform(dmlift(d1), dmlift(d2), [1, 0]) #\rightarrow
# function aright(d1::Tuple{G,Valid}, d2::Tuple{G,Valid})
#     return align(dmlift(d1[2]), dmlift(d2[2]), [1, 0]; g=d2[1], h=d1[1])
# end #\rightarrow
# function aright(d1::Valid, d2::Tuple{G,Valid})
#     return align(dmlift(d1), dmlift(d2[2]), [1, 0]; g=d2[1])
# end #\rightarrow
# function aright(d1::Tuple{G,Valid}, d2::Valid)
#     return align(dmlift(d1[2]), dmlift(d2), [1, 0]; h=d1[1])
# end #\rightarrow

aleft(d1::Valid, d2::Valid) = align_transform(dmlift(d1), dmlift(d2), [-1, 0])#\leftarrow
# function aleft(d1::Tuple{G,Valid}, d2::Tuple{G,Valid})
#     return align(dmlift(d1[2]), dmlift(d2[2]), [-1, 0]; g=d2[1], h=d1[1])
# end#\leftarrow
# function aleft(d1::Valid, d2::Tuple{G,Valid})
#     return align(dmlift(d1), dmlift(d2[2]), [-1, 0]; g=d2[1])
# end#\leftarrow
# function aleft(d1::Tuple{G,Valid}, d2::Valid)
#     return align(dmlift(d1[2]), dmlift(d2), [-1, 0]; h=d1[1])
# end#\leftarrow

atop(d1::Valid, d2::Valid) = align_transform(dmlift(d1), dmlift(d2), [0, 1]) #\uparrow
# function atop(d1::Tuple{G,Valid}, d2::Tuple{G,Valid})
#     return align(dmlift(d1[2]), dmlift(d2[2]), [0, 1]; g=d2[1], h=d1[1])
# end #\uparrow
# function atop(d1::Valid, d2::Tuple{G,Valid})
#     return align(dmlift(d1), dmlift(d2[2]), [0, 1]; g=d2[1])
# end #\uparrow
# function atop(d1::Tuple{G,Valid}, d2::Valid)
#     return align(dmlift(d1[2]), dmlift(d2), [0, 1]; h=d1[1])
# end #\uparrow

abottom(d1::Valid, d2::Valid) = align_transform(dmlift(d1), dmlift(d2), [0, -1])#\downarrowk
# function abottom(d1::Tuple{G,Valid}, d2::Tuple{G,Valid})
#     return align(dmlift(d1[2]), dmlift(d2[2]), [0, -1]; g=d2[1], h=d1[1])
# end#\downarrowk
# function abottom(d1::Valid, d2::Tuple{G,Valid})
#     return align(dmlift(d1), dmlift(d2[2]), [0, -1]; g=d2[1])
# end#\downarrowk
# function abottom(d1::Tuple{G,Valid}, d2::Valid)
#     return align(dmlift(d1[2]), dmlift(d2), [0, -1]; h=d1[1])
# end#\downarrowk
