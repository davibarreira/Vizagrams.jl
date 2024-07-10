"""
nominalscale(data, posencoding, axislength; tickvalues=nothing)

Compute tickvalues and scale for nominal.
Returns `tickvalues, scale`.
"""
function nominalscale(data, posencoding, axislength; tickvalues=nothing)
    tickvalues = isnothing(tickvalues) ? String.(sort(unique(data))) : tickvalues
    tickpad = getnested(
        posencoding, [:guide, :tickpad], axislength / (length(tickvalues) + 2)
    )
    scale = Categorical(; domain=tickvalues, codomain=(tickpad, axislength - tickpad))
    return tickvalues, scale
end

"""
ordinalscale(data, posencoding, axislength; tickvalues=nothing)

Compute tickvalues and scale for ordinal data.
Returns `tickvalues, scale`.
"""
function ordinalscale(data, posencoding, axislength; tickvalues=nothing)
    dmin, dmax = minimum(data), maximum(data)
    tickvalues = isnothing(tickvalues) ? collect(dmin:dmax) : tickvalues
    tickpad = getnested(
        posencoding, [:guide, :tickpad], axislength / (length(tickvalues) + 2)
    )
    scale = Categorical(; domain=tickvalues, codomain=(tickpad, axislength - tickpad))
    return tickvalues, scale
end

"""
quantitativescale(data, posencoding, axislength; tickvalues=nothing)

Compute tickvalues and scale for quantitative data.
Returns `tickvalues, scale`.
"""
function quantitativescale(data, posencoding, axislength; tickvalues=nothing)
    dmin, dmax = minimum(data), maximum(data)
    data_range = dmax - dmin

    # Add some extra spacing so that data does not touch the axis
    dmin = dmin - data_range / 10
    dmax = dmax + data_range / 10

    nticks = getnested(posencoding, [:guide, :n_ticks], 5)

    #Compute initial ticks
    tickvalues_preset = isnothing(tickvalues) ? false : true
    tickvalues = if isnothing(tickvalues)
        generate_tick_labels(dmin, dmax, nticks)
    else
        tickvalues
    end

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
    domain = [domain_min, domain_max]
    domain[1] = getnested(posencoding, [:guide, :minlim], domain[1])
    domain[2] = getnested(posencoding, [:guide, :maxlim], domain[2])
    domain = getnested(posencoding, [:guide, :lim], domain)

    #Recompute initial ticks in case the domain is set by the user
    if !tickvalues_preset
        tickvalues = generate_tick_labels(domain[1], domain[2], nticks)
        tickvalues = filter(t -> domain[1] ≤ t ≤ domain[2], tickvalues)
    end

    scale = Linear(; codomain=(0, axislength), domain=domain)
    return tickvalues, scale
end

"""
inferaxiscale(ds, datatype, enc, axislength, tickvalues)

Uses either quantitative, ordinal or nominal scale.
"""
function inferaxisscale(ds, enc, axislength)
    return inferaxisscale_and_tickvalues(ds, enc, axislength)[end]
end

"""
inferaxiscale_and_tickvalues(ds, enc, axislength)

The inference of the axis scale requires infering the tick values
and recomputing the scale. Hence, it is necessary to compute
both together.
"""
function inferaxisscale_and_tickvalues(ds, enc, axislength)
    tickvalues = getnested(enc, [:guide, :tickvalues], nothing)
    axislength = getnested(enc, [:guide, :length], axislength)
    datatype = getnested(enc, [:datatype], inferdatatype(ds))

    if datatype == :n
        return tickvalues, scale = nominalscale(ds, enc, axislength; tickvalues=tickvalues)
    elseif datatype == :q
        return tickvalues, scale = quantitativescale(
            ds, enc, axislength; tickvalues=tickvalues
        )
    elseif datatype == :o
        return tickvalues, scale = ordinalscale(ds, enc, axislength; tickvalues=tickvalues)
    end

    return tickvalues, scale = nominalscale(ds, enc, axislength; tickvalues=tickvalues)
end
