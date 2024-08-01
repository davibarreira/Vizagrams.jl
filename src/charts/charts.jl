function chart(data, mark::Hist; graphic=mark, kwargs)
    h = fit(Histogram, data; nbins=10)

    # Get the edges of the bins
    edges = h.edges[1]

    # Compute the centers of the bins
    bin_centers = (edges[1:(end - 1)] .+ edges[2:end]) ./ 2
    encodings = NamedTupleTools.rec_merge(encodings


    data = StructArray(; x=bin_centers, h=h.weights)
    return hist = Plot(;
        data=data,
        encodings=(x=(field=:x, datatype=:q), y=(field=:h, datatype=:q)),
        graphic=graphic,
    )
end
