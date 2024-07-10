struct Pizza <: Mark
    rmajor::Union{Vector,Real}
    rminor::Union{Vector,Real}
    center::Vector
    angles::Vector{Real}
    colors::Vector
    angleinit::Real
    style::S
end

function Pizza(;
    angles=[1, 1],
    colors=map(x -> :steelblue, angles),
    rmajor=1,
    rminor=0,
    center=[0, 0],
    angleinit=0,
    style=S(),
)
    return Pizza(rmajor, rminor, center, angles, colors, angleinit, style)
end
function ζ(pizza::Pizza)::𝕋{Mark}
    (; rmajor, rminor, center, angles, colors, angleinit, style) = pizza
    rmajor = rmajor isa Real ? map(x -> rmajor, angles) : rmajor
    rminor = rminor isa Real ? map(x -> rminor, angles) : rminor
    total_angle = reduce(+, angles)
    angles = map(x -> 2π * x / total_angle, angles)
    acc = collect(Scan(+)(vcat(0, angles[begin:(end - 1)])))
    slicing =
        row -> begin
            if row[:ang] ≈ 0.0
                return NilD()
            end
            S(
                :fill => row[:color],
                :stroke => :white,
                :strokeWidth => 2,
                :strokeLinejoin => "round",
            ) *
            T(center...) *
            style *
            Slice(; rminor=row[:rminor], rmajor=row[:rmajor], ang=row[:ang], θ=row[:acc])
        end

    return R(angleinit) * mapreduce(
        slicing,
        +,
        StructArray(; rmajor=rmajor, rminor=rminor, ang=angles, color=colors, acc=acc),
    )
end
