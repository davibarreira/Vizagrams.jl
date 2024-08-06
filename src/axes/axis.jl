function get_tickvalues(scale::Linear; nticks=10, tickvalues=nothing, ticktexts=nothing)
    (; domain, codomain) = scale
    if isnothing(tickvalues)
        tickvalues = scale.domain
        if scale isa Linear
            tickvalues = generate_tick_labels(domain[1], domain[2], nticks)
        end
    end
    tickvalues = filter(x -> codomain[begin] ≤ scale(x) ≤ codomain[end], tickvalues)
    if isnothing(ticktexts)
        if !(tickvalues isa Vector{<:AbstractString})
            ticktexts = showoff(tickvalues)
        end
        ticktexts = tickvalues
    end

    return tickvalues, ticktexts
end
function get_tickvalues(
    scale::Categorical; nticks=10, tickvalues=nothing, ticktexts=nothing
)
    (; domain, codomain) = scale
    if isnothing(tickvalues)
        tickvalues = scale.domain
    end
    if isnothing(ticktexts)
        if !(tickvalues isa Vector{<:AbstractString})
            ticktexts = showoff(tickvalues)
        end
        ticktexts = tickvalues
    elseif ticktexts isa AbstractString
        ticktexts = map(t -> ticktexts, 1:length(tickvalues))
    end

    return tickvalues, ticktexts
end
