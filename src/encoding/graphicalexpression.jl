"""
GraphicExpression

Computes data->T{Mark} as using:
```
(alg ∘ (s->map(expr,s)) ∘ coalg)(x)
```
"""
struct GraphicExpression
    expr::Function  # S->T
    coalg::Function # S->[S]
    alg::Function   # [T] -> T
end

# Lifts a single function to a GraphicExpression by using the
# x->[x] and list_x -> list_x[begin]
# as coalgebra and algebra
GraphicExpression(f::Function) = GraphicExpression(f, x -> [x], list_x -> list_x[begin])
GraphicExpression(f::GraphicExpression) = f

function GraphicExpression(graphic::GraphicExpression, coalg, alg)
    return GraphicExpression(s -> graphic(s), coalg, alg)
end

function (graphic::GraphicExpression)(x)
    (; expr, coalg, alg) = graphic
    return (alg ∘ (s -> map(expr, s)) ∘ coalg)(x)
end
# ∑(graphic::GraphicExpression=x -> dmlift(NilD()), coalg=table_coalg(), alg=op_alg()) = GraphicExpression(s -> graphic(s), coalg, alg)

"""
table_coalg(;
    i::Union{Symbol,Nothing}=nothing,
    orderby::Union{Symbol,Nothing}=nothing,
    descend::Bool=false,
    group_all::Bool=false,
)

Helper function to create coalgebra for list functor, using indexes to groupby and order data.
Parameter:
 - `i`:  The indexing for groupby;
 - `orderby`: Whether to order the data by a given column;
 - `descend`: Whether to order by descending or ascending;
 - `group_all`: If the index `i` is not in the dataset, it returns the whole dataset, otherwise, returns each row wrapped on `[]`.
Note a coalgebra is a function that takes a dataset S and returns [S].
"""
function table_coalg(;
    i::Union{Symbol,Nothing}=nothing,
    orderby::Union{Symbol,Nothing}=nothing,
    descend::Bool=false,
    group_all::Bool=false,
)
    # This form always returns a StructArray. It is more consistent,
    # but has a noisier syntax
    # coalg = s -> map(x -> StructArray([x]), s)

    coalg = s -> map(x -> x, Tables.rows(s))
    if !isnothing(i)
        coalg = s -> begin
            cols = Tables.columnnames(Tables.columns(s))
            if i in cols
                return collect(@map(StructArray(_))(@groupby(_[i])(s)))
            end
            if group_all
                return [s]
            end
            return map(x -> StructArray([x]), s)
        end
    end
    if !isnothing(orderby)
        ordering = s -> begin
            cols = Tables.columnnames(Tables.columns(s))
            if orderby in cols
                if descend
                    return @orderby_descending(_[orderby])(s)
                end
                return @orderby(_[orderby])(s)
            end
            return s
        end
        coalg = coalg ∘ ordering
    end
    return coalg
end
# # Safe Indexing
# cols = Tables.columnnames(Tables.columns(s))
# if i in cols
#     return collect(@map(StructArray(_))(@groupby(_[i])(s)))
# end
# return map(x -> x, s)

"""
op_alg(op::Function = +;init=NilD()) = x->foldl((acc,s)->op(s,acc), x, init=NilD())

Lifts binary `op` into a foldl.
"""
op_alg(op::Function=+; init=NilD()) = x -> foldl((acc, s) -> op(s, acc), x; init=init)

"""
∑(expr = x -> dmlift(NilD()); op =+, i=nothing, orderby=nothing,descend=false)

Computes graphic expression using `op` for generating the algera,
and `i` for the coalgebra.
"""
function ∑(
    expr::Union{Function,GraphicExpression}=x -> dmlift(NilD());
    op::Function=+,
    i::Union{Symbol,Nothing}=nothing,
    orderby::Union{Symbol,Nothing}=nothing,
    descend::Bool=false,
    init=NilD(),
    group_all=false,
)
    return GraphicExpression(
        expr,
        table_coalg(; i=i, orderby=orderby, descend=descend, group_all=group_all),
        op_alg(op; init=init),
    )
end

function Base.:∘(Σ₂::GraphicExpression, Σ₁::GraphicExpression)
    return GraphicExpression(s -> Σ₁(s), Σ₂.coalg, Σ₂.alg)
end

function Base.:+(Σ₂::GraphicExpression, Σ₁::GraphicExpression)
    return GraphicExpression(s -> Σ₂(s) + Σ₁(s), x -> [x], x -> x[begin])
end

function Base.:*(t::Union{G,S,H}, Σ₁::GraphicExpression)
    return GraphicExpression(s -> t * Σ₁.expr(s), Σ₁.coalg, Σ₁.alg)
end
function ▷(t::Union{G,S,H}, Σ₁::GraphicExpression)
    return GraphicExpression(s -> t ▷ Σ₁.expr(s), Σ₁.coalg, Σ₁.alg)
end

function Base.:+(t::Union{GeometricPrimitive,Prim,Mark,𝕋{Mark}}, Σ₁::GraphicExpression)
    # return GraphicExpression(s -> dmlift(t) + Σ₁.expr(s), Σ₁.coalg, Σ₁.alg)
    return GraphicExpression(t) + Σ₁
end

function Base.:+(Σ₁::GraphicExpression, t::Union{GeometricPrimitive,Prim,Mark,𝕋{Mark}})
    # return GraphicExpression(s -> Σ₁.expr(s) + dmlift(t), Σ₁.coalg, Σ₁.alg)
    return Σ₁ + GraphicExpression(t)
end
