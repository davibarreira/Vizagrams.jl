"""
scatter(; x=:x, y=:y, θ=:θ, s=:size, color=:color, opacity=0.6, mark::Union{Mark,Prim,𝕋{Mark},GeometricPrimitive}=Circle(r=3))

```julia
    ∑(row -> Style(:fill => get(row, color, ""), :opacity => opacity) * T(get(row, x, 0), get(row, y, 0)) * R(get(row, θ, 0)) * U(get(row, s, 1)) * m)
```
"""
function scatter(;
    x=:x,
    y=:y,
    θ=:θ,
    s=:size,
    color=:color,
    opacity=0.6,
    mark::Union{Mark,Prim,𝕋{Mark},GeometricPrimitive}=Circle(; r=3),
    style=S(),
)
    m = mlift(mark)
    return ∑(
        row ->
            S(:fill => get(row, color, ""), :opacity => opacity) *
            style *
            T(get(row, x, 0), get(row, y, 0)) *
            R(get(row, θ, 0)) *
            U(get(row, s, 1)) *
            m,
    )
end

"""
scatter(markexpr::Function; x=:x, y=:y, θ=:θ, s=:size, color=:color, opacity=0.6)

```julia
    ∑(row -> Style(:fill => get(row, color, ""), :opacity => opacity) * T(get(row, x, 0), get(row, y, 0)) * R(get(row, θ, 0)) * U(get(row, s, 1)) * markexpr(row))
```
"""
function scatter(markexpr::Function; x=:x, y=:y, θ=:θ, s=:size, color=:color, opacity=0.6)
    return ∑(
        row ->
            S(:fill => get(row, color, ""), :opacity => opacity) *
            T(get(row, x, 0), get(row, y, 0)) *
            R(get(row, θ, 0)) *
            U(get(row, s, 1)) *
            markexpr(row),
    )
end

"""
lineplot(;x=:x, y=:y, s=:size, opacity=0.6, detail=:color, orderby=nothing, style=S())
"""
function lineplot(;
    x=:x,
    y=:y,
    s=:size,
    opacity=0.6,
    detail=:color,
    orderby=nothing,
    style=S(),
    expr=(data) -> Line(data.x, data.y),
)
    if isnothing(detail)
        return data -> S(:stroke => :blue)style * expr(data)
    end
    if detail == :color
        return ∑(; i=:color, orderby=orderby) do row
            S(:stroke => row.color[1], :strokeWidth => 2)style * expr(row)
        end
    end
    return ∑(; i=detail, orderby=orderby) do row
        S(:stroke => :blue, :strokeWidth => 2)style * expr(row)
    end
end

```
Creating deafults for GraphicExpression
```
GraphicExpression(c::Union{TMark,Mark,Prim,GeometricPrimitive}) = scatter(; mark=c)
GraphicExpression(c::MPrim{T}) where {T} = GraphicExpression(c._1)

## Graphic Expression for Mark Trees
function GraphicExpression(act::FreeAct{Mark})
    ge = GraphicExpression(act._2)
    return act._1 ▷ ge
end
function GraphicExpression(comp::FreeComp{Mark})
    return GraphicExpression(comp._1) + GraphicExpression(comp._2)
end
GraphicExpression(p::Pure{Mark}) = GraphicExpression(unfree(p))

function GraphicExpression(l::Union{Line,MPrim{Line}})
    GraphicExpression(data -> begin
        cols = Tables.columnnames(data)
        if :color in cols
            return lineplot()(data)
        end
        return lineplot(; detail=nothing)(data)
    end)
end

function GraphicExpression(b::Bar)
    expr = data -> begin
        cols = Tables.columnnames(data)
        b = @set b.h = data[:y]
        b = @set b.c = [data[:x], 0]
        if :color in cols
            return S(:fill => data[:color])b
        end
        return b
    end
    return ∑(
        ∑(∑(expr); i=:color, op=↑, orderby=:color, descend=false, group_all=true);
        i=:x,
        op=+,
    )
end

# function GraphicExpression(b::VBar)
#     expr = data -> begin
#         cols = Tables.columnnames(data)
#         b = @set b.x = data[:x]
#         b = @set b.top = data[:y]
#         b = @set b.bottom = 0
#         if :color in cols
#             return S(:fill => data[:color])b
#         end
#         return b
#     end
#     return ∑(∑(∑(expr); i=:color, op=↑, orderby=:color, descend=false); i=:x, op=+)
# end

function GraphicExpression(a::Area)
    return lineplot(;
        expr=data -> begin
            setfields(
                a,
                (
                    pts=data.x ⊗ data.y,
                    areastyle=a.areastyle ⋄ S(:fill => data.color[1]),
                    linestyle=a.linestyle ⋄ S(:stroke => data.color[1]),
                ),
            )
        end,
    )
end

function GraphicExpression(p::Pizza)
    return ∑(; i=:all, group_all=true) do row
        Pizza(;
            rmajor=getcol(row, :r, p.rmajor),
            angles=row.angle,
            colors=getcol(row, :color, map(x -> :steelblue, row.angle)),
            rminor=getcol(row, :rminor, p.rminor),
            angleinit=p.angleinit,
        )
    end
end
