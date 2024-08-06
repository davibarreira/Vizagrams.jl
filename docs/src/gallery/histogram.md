# Histogram

A histogram is simply a bar plot. We only need to precompute some characteristics
such as the bins and the amount in each bin.

```@example 1
using Random
using StatsBase
using StructArrays

Random.seed!(4)
# Create a histogram
h = fit(Histogram, rand(100), nbins=10)

# Get the edges of the bins
edges = h.edges[1]

# Compute the centers of the bins
bin_centers = (edges[1:end-1] .+ edges[2:end]) ./ 2

data = StructArray(x=bin_centers, h=h.weights)
nothing #hide
```

## 1. Using Hist Mark
Once we have computed the bins and heights, we can now use Vizagrams
to draw the histogram. The most direct way is by using the mark `Hist`.

We then use Vizagrams to draw the histogram.
```@example 1
using Vizagrams

hist = Plot(
    data = data,
    encodings=(
        x=(field=:x,datatype=:q),
        y=(field=:h,datatype=:q),
    ),
    graphic = Hist()
)

draw(hist)
```

## 2. Explicit Graphic Expression

By using the `Hist` mark, we hide the graphic construction process. We can
construct the histogram using only rectangle bars. Let us also use the
edge values to draw the tick values.

```@example 1
using Vizagrams

hist = Plot(
    data = data,
    config=(;xaxis=(;tickvalues=collect(h.edges[1])),),
    encodings=(
        x=(field=:x,datatype=:q,guide=(tickvalues=collect(h.edges[1]),)),
        y=(field=:h,datatype=:q),
    ),
    graphic = data->begin
        bar_width = (data.x[2] - data.x[1])*0.95
        ∑() do row
            T(row[:x],0)*
            S(:fillOpacity=>0.9,:fill=>:steelblue)*
            Bar(w=bar_width,h=row[:y])
        end(data)
    end
)

draw(hist)
```

The benefit of having the complete specification is that we can modify in order to customize our visualization.
For example, we can remove the y-axis and add the values above the bars.


```@example 1
hist2 = Plot(
    config =(
        frame=NilD(),
        yaxis=NilD(),
        grid=NilD(),
    ),
    data = data,
    encodings=(
        x=(field=:x,datatype=:q),
        y=(field=:h,datatype=:q),
        h=(field=:h,datatype=:q,scale=IdScale(),),
    ),
    graphic = sdata->begin
        w = (sdata.x[2] - sdata.x[1])*0.95
        ∑() do row
            T(row[:x],0)*
            S(:fillOpacity=>0.9,:fill=>:steelblue)*
            (
                Bar(w=w,h=row[:y]) ↑
                (T(0,4),TextMark(fontsize=14,text=row[:h]))
            )
        end(sdata)
    end
)

draw(hist2)
```
