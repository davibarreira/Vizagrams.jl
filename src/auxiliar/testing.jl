"""
compare_structs(s1::T, s2::T) where {T}
Compares if two structs are the same by checking if
each field is equal.
"""
function compare_structs(s1::T, s2::T; eq=(x, y) -> x == y) where {T}
    fields = fieldnames(typeof(s1))
    return all(map(x -> eq(getfield(s1, x), getfield(s2, x)), fields))
end

function compare_structs(h1::Tuple{G,S}, h2::Tuple{G,S})
    bool_translation = h1[1].g.translation == h2[1].g.translation
    s1 = h1[2]
    s2 = h2[2]

    bool_style = all(
        map(k -> all([k[1] == k[2], s1.d[k[1]] == s1.d[k[2]]]), zip(keys(s1.d), keys(s2.d)))
    )
    return all([bool_translation, bool_style])
end

"""
compare_primitives(p1::Prim, p2::Prim)
"""
function compare_primitives(p1::Prim, p2::Prim; eq=(x, y) -> x == y)
    return all([
        compare_structs(p1.geom, p2.geom; eq=eq), compare_structs(p1.s, p2.s; eq=eq)
    ])
end

"""
compare_trees(s1::𝕋, s2::𝕋)
Flattens the trees into lists of primitives and compares them.
"""
function compare_trees(s1::𝕋, s2::𝕋; eq=(x, y) -> x == y)
    p1 = flatten(s1)
    p2 = flatten(s2)
    return all(map(x -> compare_primitives(x[1], x[2]), zip(p1, p2)))
end
