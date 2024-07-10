# Tree Operations
Base.:+(p1::Valid, p2::Valid) = FreeComp(dmlift(p1), dmlift(p2))

Base.:*(ts::H, d::Valid) = FreeAct(ts, dmlift(d))
Base.:*(ts::H, d::FreeAct) = FreeAct(ts ⋄ d._1, dmlift(d._2))

Base.:*(t::G, d::Valid) = (t, neutral(S)) * dmlift(d)
Base.:*(s::S, d::Valid) = (neutral(G), s) * dmlift(d)

Base.:*(t::G, s::S) = (t, s)
Base.:*(s::S, t::G) = (t, s)

Base.:*(t1::G, t2::G) = (t1 ⋄ t2, neutral(S))
Base.:*(s1::S, s2::S) = (neutral(G), s1 ⋄ s2)
Base.:*(s::S, gs::H) = (gs[1], s ⋄ gs[2])
Base.:*(gs::H, s::S) = (gs[1], gs[2] ⋄ s)
Base.:*(gs1::H, gs2::H) = (gs1[1] ⋄ gs2[1], gs1[2] ⋄ gs2[2])

Base.:*(g::G, gs::H) = (g ⋄ gs[1], gs[2])
Base.:*(gs::H, g::G) = (gs[1] ⋄ g, gs[2])

## Operation for overriding style
# ▷ \triangleright
▷(s1::S, s2::S) = s2 ⋄ s1
▷(s1::S, d::Valid) = μ(fmap(x -> s1 * x, dmlift(d)))
▷(ts::H, d::FreeAct) = FreeAct((ts[1] ⋄ d._1[1], ts[2] ▷ d._1[2]), dmlift(d._2))
▷(ts::H, d::Valid) = FreeAct(ts, dmlift(d))
▷(ts::S, d::FreeComp) = FreeComp(ts ▷ d._1, ts ▷ d._2)
▷(ts::H, d::FreeComp) = FreeComp(ts ▷ d._1, ts ▷ d._2)

### OLD VERSION
# ▷(s1::Style, s2::Style) = s2 ⋄ s1
# ▷(s1::Style, d::FreeAct) = (neutral(G), s1) ▷ d
# ▷(s1::Style, d::Valid) = FreeAct((neutral(G), s1), dmlift(d))

"""
function beside(d1::𝕋, d2::𝕋, v::Vector)
"""
function beside(
    d1::𝕋,
    d2::𝕋,
    v::Vector;
    g::G=G(IdentityTransformation()),
    h::G=G(IdentityTransformation()),
)
    e1 = envelope(d1, v)
    e2 = envelope(d2, -v)
    if isnothing(e1) || isnothing(e2)
        return d1 + d2
    end
    return h * d1 + g * T((e1 + e2) * v) * d2
end

function beside_transform(
    d1::𝕋, d2::𝕋, v::Vector; g::G=G(IdentityTransformation())
)::Tuple{<:G,S}
    e1 = envelope(d1, v)
    e2 = envelope(d2, -v)
    if isnothing(e1) || isnothing(e2)
        return g * S()
    end
    return g * T((e1 + e2) * v)
end

→(d1::Valid, d2::Valid) = beside(dmlift(d1), dmlift(d2), [1, 0]) #\rightarrow
←(d1::Valid, d2::Valid) = beside(dmlift(d1), dmlift(d2), [-1, 0])#\leftarrow
↑(d1::Valid, d2::Valid) = beside(dmlift(d1), dmlift(d2), [0, 1]) #\uparrow
↓(d1::Valid, d2::Valid) = beside(dmlift(d1), dmlift(d2), [0, -1])#\downarrowk

function →(d1::Tuple{G,Valid}, d2::Tuple{G,Valid})
    return beside(dmlift(d1[2]), dmlift(d2[2]), [1, 0]; g=d2[1], h=d1[1])
end #\rightarrow
function ←(d1::Tuple{G,Valid}, d2::Tuple{G,Valid})
    return beside(dmlift(d1[2]), dmlift(d2[2]), [-1, 0]; g=d2[1], h=d1[1])
end#\leftarrow
function ↑(d1::Tuple{G,Valid}, d2::Tuple{G,Valid})
    return beside(dmlift(d1[2]), dmlift(d2[2]), [0, 1]; g=d2[1], h=d1[1])
end #\uparrow
function ↓(d1::Tuple{G,Valid}, d2::Tuple{G,Valid})
    return beside(dmlift(d1[2]), dmlift(d2[2]), [0, -1]; g=d2[1], h=d1[1])
end#\downarrowk

→(d1::Valid, d2::Tuple{G,Valid}) = beside(dmlift(d1), dmlift(d2[2]), [1, 0]; g=d2[1]) #\rightarrow
←(d1::Valid, d2::Tuple{G,Valid}) = beside(dmlift(d1), dmlift(d2[2]), [-1, 0]; g=d2[1])#\leftarrow
↑(d1::Valid, d2::Tuple{G,Valid}) = beside(dmlift(d1), dmlift(d2[2]), [0, 1]; g=d2[1]) #\uparrow
↓(d1::Valid, d2::Tuple{G,Valid}) = beside(dmlift(d1), dmlift(d2[2]), [0, -1]; g=d2[1])#\downarrowk

→(d1::Tuple{G,Valid}, d2::Valid) = beside(dmlift(d1[2]), dmlift(d2), [1, 0]; h=d1[1]) #\rightarrow
←(d1::Tuple{G,Valid}, d2::Valid) = beside(dmlift(d1[2]), dmlift(d2), [-1, 0]; h=d1[1])#\leftarrow
↑(d1::Tuple{G,Valid}, d2::Valid) = beside(dmlift(d1[2]), dmlift(d2), [0, 1]; h=d1[1]) #\uparrow
↓(d1::Tuple{G,Valid}, d2::Valid) = beside(dmlift(d1[2]), dmlift(d2), [0, -1]; h=d1[1])#\downarrowk

bright(d1::Valid, d2::Valid) = beside_transform(dmlift(d1), dmlift(d2), [1, 0]) #\rightarrow
function bright(d1::Tuple{G,Valid}, d2::Tuple{G,Valid})
    return beside_transform(dmlift(d1[2]), dmlift(d2[2]), [1, 0]; g=d2[1], h=d1[1])
end #\rightarrow
function bright(d1::Valid, d2::Tuple{G,Valid})
    return beside_transform(dmlift(d1), dmlift(d2[2]), [1, 0]; g=d2[1])
end #\rightarrow
function bright(d1::Tuple{G,Valid}, d2::Valid)
    return beside_transform(dmlift(d1[2]), dmlift(d2), [1, 0]; h=d1[1])
end #\rightarrow

bleft(d1::Valid, d2::Valid) = beside_transform(dmlift(d1), dmlift(d2), [-1, 0])#\leftarrow
function bleft(d1::Tuple{G,Valid}, d2::Tuple{G,Valid})
    return beside_transform(dmlift(d1[2]), dmlift(d2[2]), [-1, 0]; g=d2[1], h=d1[1])
end#\leftarrow
function bleft(d1::Valid, d2::Tuple{G,Valid})
    return beside_transform(dmlift(d1), dmlift(d2[2]), [-1, 0]; g=d2[1])
end#\leftarrow
function bleft(d1::Tuple{G,Valid}, d2::Valid)
    return beside_transform(dmlift(d1[2]), dmlift(d2), [-1, 0]; h=d1[1])
end#\leftarrow

btop(d1::Valid, d2::Valid) = beside_transform(dmlift(d1), dmlift(d2), [0, 1]) #\uparrow
function btop(d1::Tuple{G,Valid}, d2::Tuple{G,Valid})
    return beside_transform(dmlift(d1[2]), dmlift(d2[2]), [0, 1]; g=d2[1], h=d1[1])
end #\uparrow
function btop(d1::Valid, d2::Tuple{G,Valid})
    return beside_transform(dmlift(d1), dmlift(d2[2]), [0, 1]; g=d2[1])
end #\uparrow
function btop(d1::Tuple{G,Valid}, d2::Valid)
    return beside_transform(dmlift(d1[2]), dmlift(d2), [0, 1]; h=d1[1])
end #\uparrow

bbottom(d1::Valid, d2::Valid) = beside_transform(dmlift(d1), dmlift(d2), [0, -1])#\downarrowk
function bbottom(d1::Tuple{G,Valid}, d2::Tuple{G,Valid})
    return beside_transform(dmlift(d1[2]), dmlift(d2[2]), [0, -1]; g=d2[1], h=d1[1])
end#\downarrowk
function bbottom(d1::Valid, d2::Tuple{G,Valid})
    return beside_transform(dmlift(d1), dmlift(d2[2]), [0, -1]; g=d2[1])
end#\downarrowk
function bbottom(d1::Tuple{G,Valid}, d2::Valid)
    return beside_transform(dmlift(d1[2]), dmlift(d2), [0, -1]; h=d1[1])
end#\downarrowk
