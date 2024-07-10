function generatelegends(spec::PlotSpec)::𝕋{Mark}
    (; figsize, data, encodings, config) = spec

    legends = Legend[]
    for (k, v) in pairs(encodings)
        if k == :color && getnested(v, [:legend, :flag], true)
            scale = inferscale(spec, k)
            fmark = getnested(v, [:legend, :fmark], x -> S(:fill => x)Circle(; r=3))
            title = getnested(v, [:legend, :title], v[:field])
            push!(legends, Legend(; scale=scale, fmark=fmark, title=title))
            continue
        end
        if k == :size && getnested(v, [:legend, :flag], true)
            scale = inferscale(spec, k)
            fmark = getnested(v, [:legend, :fmark], x -> U(x)Circle(; r=1))
            title = getnested(v, [:legend, :title], v[:field])
            push!(legends, Legend(; scale=scale, fmark=fmark, title=title))
            continue
        end
        if !isnothing(get(v, :legend, nothing)) && getnested(v, [:legend, :flag], true)
            title = getnested(v, [:legend, :title], v[:field])
            scale = inferscale(spec, k)
            fmark = getnested(v, [:legend, :fmark], x -> Circle())
            n = getnested(v, [:legend, :n], 5)
            pad = getnested(v, [:legend, :pad], 5)
            push!(
                legends,
                Legend(; scale=scale, fmark=fmark, title=title, extra=(n=n, pad=pad)),
            )
        end
    end
    fv = (s, acc) -> s↓(T(0, -25), aleft(s, acc) * acc)
    fh = (s, acc) -> s → (T(25, 0), acc)
    # foldr((s, acc) -> s↓(T(0, -25), aleft(s, acc) * acc), legends, init=dmlift(NilD()))
    return (x -> foldr(fh, x; init=NilD()))(
        collect(Map(x -> foldr(fv, x; init=NilD()))(Partition(2; flush=true)(legends)))
    )
end
