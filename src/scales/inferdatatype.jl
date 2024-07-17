"""
inferdatatype(ds)

Given a column of data, it tries to infer the datype
as either :q, :o or :n.
"""
function inferdatatype(ds)
    if typeof(ds) <: Union{Vector{<:AbstractString},PooledArrays.PooledVector}
        return :n
    elseif typeof(ds) <: Vector{<:Int} && length(minimum(ds):1:maximum(ds)) < 10
        return :o
    end
    return :q
end
