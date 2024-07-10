function coverage(dmin, dmax, lmin, lmax)
    return 1.0 - 0.5 * ((dmax - lmax)^2 + (dmin - lmin)^2) / (0.1 * (dmax - dmin))^2
end

function coverage_max(dmin, dmax, span)
    drange = dmax - dmin
    if span > drange
        return 1.0 - (0.5 * (span - drange))^2 / (0.1 * drange)^2
    else
        return 1.0
    end
end

function density(k, m, dmin, dmax, lmin, lmax)
    r = (k - 1.0) / (lmax - lmin)
    rt = (m - 1.0) / (max(lmax, dmax) - min(lmin, dmin))
    return 2.0 - max(r / rt, rt / r)
end

function density_max(k, m)
    if k >= m
        return 2.0 - (k - 1.0) / (m - 1.0)
    else
        return 1.0
    end
end

function simplicity(q, Q, j, lmin, lmax, lstep)
    # eps = 1e-10
    n = length(Q)
    i = findfirst(x -> x == q, Q)
    v = 0

    # if (abs(lmin % lstep) < eps) || ((abs((lstep - lmin) % lstep) < eps) && (lmin <= 0) && (lmax >= 0))
    if (abs(lmin % lstep) ≈ 0) ||
        ((abs((lstep - lmin) % lstep) ≈ 0) && (lmin <= 0) && (lmax >= 0))
        v = 1
    else
        v = 0
    end

    return 1 - (i - 1) / (n - 1) - j + v
    # return (n - i) / (n - 1.0) + v - j
end

function simplicity_max(q, Q, j)
    n = length(Q)
    i = findfirst(x -> x == q, Q)

    # This is necessary in case no match
    # is found i the findfirst
    if isnothing(i)
        return 0
    end

    v = 1
    return 1 - (i - 1) / (n - 1) - j + v
    # return (n - i) / (n - 1.0) + v - j
end

function legibility(lmin, lmax, lstep)
    return 1.0
end

function score(weights, simplicity, coverage, density, legibility)
    return weights[1] * simplicity +
           weights[2] * coverage +
           weights[3] * density +
           weights[4] * legibility
end

"""
wilk_ext(dmin, dmax, m, only_inside=0, Q=[1, 5, 2, 2.5, 4, 3], w=[0.2, 0.25, 0.5, 0.05])

Method for estimating ticks based on paper
"An Extension of Wilkinson’s Algorithm for Positioning Tick Labels on Axes"

Q: numbers that are considered as 'nice'. Ticks will be
                multiples of these

`only_inside`: controls if the first and last label include the data range.
                0  : doesn't matter
                >0 : label range must include data range
                <0 : data range must be larger than label range

w : list of weights that control the importance of the four
                criteria: simplicity, coverage, density and legibility

The code is based on the implementation found 
at `https://github.com/quantenschaum/ctplot/blob/master/ctplot/ticks.py`
"""
function wilk_ext(
    dmin::Real,
    dmax::Real,
    m::Real,
    only_inside=0,
    Q::Vector{<:Real}=[1, 5, 2, 2.5, 4, 3],
    w::Vector{<:Real}=[0.2, 0.25, 0.5, 0.05],
)
    if (dmin >= dmax) || (m < 1)
        return (dmin, dmax, dmax - dmin, 1, 0, 2, 0)
    end

    n = float(length(Q))
    best_score = -1.0
    result = nothing

    j = 1.0
    while j < Inf
        for q in map(Float64, Q)
            sm = simplicity_max(q, Q, j)

            if score(w, sm, 1, 1, 1) < best_score
                j = Inf
                break
            end

            k = 2.0
            while k < Inf
                dm = density_max(k, m)

                if score(w, sm, 1, dm, 1) < best_score
                    break
                end

                delta = (dmax - dmin) / (k + 1.0) / j / q
                z = ceil(log10(delta))

                while z < Inf
                    step = j * q * 10.0^z
                    cm = coverage_max(dmin, dmax, step * (k - 1.0))

                    if score(w, sm, cm, dm, 1) < best_score
                        break
                    end

                    min_start = floor(dmax / step) * j - (k - 1.0) * j
                    max_start = ceil(dmin / step) * j

                    if min_start > max_start
                        z += 1
                        break
                    end

                    for start in min_start:max_start
                        lmin = start * (step / j)
                        lmax = lmin + step * (k - 1.0)
                        lstep = step

                        s = simplicity(q, Q, j, lmin, lmax, lstep)
                        c = coverage(dmin, dmax, lmin, lmax)
                        d = density(k, m, dmin, dmax, lmin, lmax)
                        l = legibility(lmin, lmax, lstep)
                        scr = score(w, s, c, d, l)

                        if (scr > best_score) &&
                            ((only_inside <= 0) || ((lmin >= dmin) && (lmax <= dmax))) &&
                            ((only_inside >= 0) || ((lmin <= dmin) && (lmax >= dmax)))
                            best_score = scr
                            # println("s: $s c: $c d: $d l: $l")
                            result = (lmin, lmax, lstep, j, q, k, scr)
                        end
                    end
                    z += 1
                end
                k += 1
            end
        end
        j += 1
    end

    return result
end

"""
function generate_tick_labels(dmin, dmax, m; kwargs...)

Infer tick values based on the range of the data (`dmin`, `dmax`)
and `m` as an approximate number of ticks one wishes to use.
"""
function generate_tick_labels(dmin, dmax, m; kwargs...)
    lmin, lmax, lstep, j, q, k, scr = wilk_ext(dmin, dmax, m, kwargs...)
    if lstep == 0
        return [lmin]
    end
    return collect(lmin:lstep:lmax)
end
