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
