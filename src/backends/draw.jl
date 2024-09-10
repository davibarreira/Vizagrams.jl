"""
draw(
    d::::Union{GeometricPrimitive,Prim,Vector{Prim},Mark,𝕋{Mark}};
    backend::Symbol=:svg,
    height=300,
    pad=10,
    kwargs...,
)

"""
function draw(
    d::Union{GeometricPrimitive,Prim,Vector{Prim},Mark,𝕋{Mark}};
    backend::Symbol=:svg,
    kwargs...,
)
    if backend == :svg
        return drawsvg(d; kwargs...)
    end
    throw("Backend $backend not found.")
end

function Base.show(
    io::IO, ::MIME"image/svg+xml", drawing::Hyperscript.Node{Hyperscript.HTMLSVG}
)
    print(io, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
    return print(io, drawing)
end

# Opted for not displaying diagrams without the `draw`.
# Might change in the future.
# function Base.show(
#     io::IO, ::MIME"image/svg+xml", d::Union{𝕋{Mark},Mark,Prim,GeometricPrimitive}
# )
#     svg_str = draw(d)
#     print(io, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
#     return print(io, svg_str)
# end
