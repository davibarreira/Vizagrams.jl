"""

infer_xy_axis_domain_q(data)

Given a dataset, it infers the domain
"""
function infer_xy_axis_domain_q(data)
    dmin, dmax = minimum(data), maximum(data)
    data_range = dmax - dmin

    # Add some extra spacing so that data does not touch the axis
    dmin = dmin - data_range / 10
    dmax = dmax + data_range / 10

    nticks = 5
    tickvalues = generate_tick_labels(dmin, dmax, nticks)

    # Compute the domains based on the tickvalue and 
    domain_min = min(dmin, tickvalues[begin])
    domain_max = max(dmax, tickvalues[end])

    # Compute the domains based on the tickvalue and 
    if abs(dmin - tickvalues[begin]) < data_range / 20
        domain_min = tickvalues[begin]
    end
    if abs(dmax - tickvalues[end]) < data_range / 20
        domain_max = tickvalues[end]
    end
    domain = (domain_min, domain_max)

    return domain
end

"""
infer_datatype(data)

Given a column of data, it tries to infer the datype
as either :q, :o or :n.
"""
function infer_datatype(data)
    if typeof(data) <:
       Union{Vector{<:AbstractChar},Vector{<:AbstractString},PooledArrays.PooledVector}
        return :n
    elseif typeof(data) <: Vector{<:Int} && length(minimum(data):1:maximum(data)) < 10
        return :o
    end
    return :q
end

"""
infer_domain(; data, domain, datatype, variable, coordinate)

Infers the scale domain.
"""
function infer_domain(; data, domain, datatype, variable, coordinate)
    domain = @match (domain, datatype, variable, coordinate) begin
        (nothing, :q, _, _) => (minimum(data), maximum(data))
        (nothing, :n, _, _) => string.(sort(unique(data)))
        (nothing, :o, _, _) => collect(minimum(data):maximum(data))

        (nothing, :q, :x, :cartesian) => infer_xy_axis_domain_q(data)
        (nothing, :q, :y, :cartesian) => infer_xy_axis_domain_q(data)

        (nothing, :q, :r, :polar) => infer_xy_axis_domain_q(data)
        (nothing, :q, :angle, :polar) => infer_xy_axis_domain_q(data)

        (_, _, _, _) => domain
    end
end


"""
infer_codomain(; domain, codomain, datatype, variable, coordinate, framesize)

Infers the scale codomain.
"""
function infer_codomain(; domain, codomain, datatype, variable, coordinate, framesize)
    codomain = @match (codomain, datatype, variable, coordinate) begin
        (nothing, :q, :x, :cartesian) => (0, framesize[1])
        (nothing, :n, :x, :cartesian) => ((framesize[1] / length(domain)) / 2, framesize[1] - (framesize[1] / length(domain)) / 2)
        (nothing, :o, :x, :cartesian) => (0, framesize[1])

        (nothing, :q, :y, :cartesian) => (0, framesize[2])
        (nothing, :n, :y, :cartesian) => ((framesize[2] / length(domain)) / 2, framesize[2] - (framesize[2] / length(domain)) / 2)
        (nothing, :o, :y, :cartesian) => (0, framesize[2])

        (nothing, :q, :r, :polar) => (0, minimum(framesize) / 2)
        (nothing, :n, :r, :polar) => ((minimum(framesize) / length(domain)) / 4, minimum(framesize) / 2 - (minimum(framesize) / length(domain)) / 4)
        (nothing, :o, :r, :polar) => (0, minimum(framesize) / 2)

        (nothing, :q, :angle, :polar) => (0, 2π)
        (nothing, :n, :angle, :polar) => collect(range(0, 2π; length=length(domain) + 1))[begin:(end-1)]
        (nothing, :o, :angle, :polar) => collect(range(0, 2π; length=length(domain) + 1))[begin:(end-1)]

        (nothing, :q, :size_) => (3, 10)
        (nothing, :n, :size_) => collect(range(3, 10, length(domain)))
        (nothing, :o, :size_) => collect(range(3, 10, length(domain)))

        (nothing, :q, :color, _) => :hawaii
        (nothing, :n, :color, _) => :tableau_superfishel_stone
        (nothing, :o, :color, _) => :jblue
        (nothing, _, _, _) => (0, 1)
        (_, _, _, _) => codomain
    end
end
"""
infer_scaletype(datatype)

Infers whether the scale is Categorical or Linear.
"""
function infer_scaletype(datatype)
    if datatype in [:n, :o]
        return :Categorical
    end
    return :Linear
end


"""
infer_scale(;data, framesize, coordinate=:cartesian, variable=nothing, datatype=nothing)

"""
function infer_scale(;
    data,
    codomain_length,
    coordinate=:cartesian,
    variable=nothing,
    datatype=nothing,
    domain=nothing,
    codomain=nothing,
)

    datatype = isnothing(datatype) ? infer_datatype(data) : datatype

    if datatype == :q
        domain = isnothing(domain) ? infer_xy_axis_domain_q(data) : domain
        codomain = isnothing(codomain) ? (0, codomain_length) : codomain
        scale = Linear(; domain=domain, codomain=codomain)
        return scale
    elseif datatype == :n
        domain = isnothing(domain) ? string.(sort(unique(data))) : domain
        interval = codomain_length / length(domain)

        codomain =
            isnothing(codomain) ? (interval / 2, codomain_length - interval / 2) : codomain
        scale = Categorical(; domain=domain, codomain=codomain)
    end
    codomain = isnothing(codomain) ? (0, codomain_length) : codomain
    return Linear(; domain=domain, codomain=codomain)
end
