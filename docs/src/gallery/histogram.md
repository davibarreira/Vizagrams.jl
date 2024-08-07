# Histogram

A histogram is simply a bar plot. We only need to precompute some characteristics
such as the bins and the amount in each bin. Vizagrams already has some helper
functions to compute bins as well as a histogram mark `Hist`. Let us start by
producing a histogram using the presets in Vizagrams, and then we show
how to do it all manually.

## 1. Creating a Histogram Quickly

Here is the quickest way of creating a histogram. We use the functions
`bindata` that bins the data, and `countbin` which returns the weights for
the bins for each value. We then use the `Hist()` mark.

```@example 1
using Vizagrams
using Random
using StatsBase
using StructArrays

Random.seed!(4)
data = StructArray(x=rand(100),)
hist = Plot(
    data=data,
    x=bindata(data.x),
    y=countbin(data.x),
    graphic=Hist()
)

draw(hist)
```

## 2. Histogram Graphic Expression
Let us now show how we can draw the histogram using only bars.
```@example 1
hist = Plot(
    data = data,
    config=(;
        grid=NilD(),
        xaxis=(;title="Histogram"),
        yaxis=(;title="Count"),
    ),
    encodings=(
        x=(value=bindata(data.x,nbins=5),),
        y=(value=countbin(data.x,nbins=5),datatype=:q),
    ),
    graphic = data-> begin

        # compute the bin width
        w = let 
            u = sort(unique(data.x))
            u[2]-u[1]-1
        end

        # draw each bar
        ∑(i=:x) do row
                S(:fillOpacity=>0.9,:fill=>:steelblue)*
                T(row.x[1],0)Bar(w=w,h=row.y[1],orientation=:v)
        end(data)
    end
)

draw(hist)
```

## 3. Computing the Histogram Manually
Next, let us compute the histogram bins manually and draw them.

```@example 1
Random.seed!(4)
# Create a histogram
h = fit(Histogram, rand(100), nbins=10)

# Get the edges of the bins
edges = h.edges[1]

# Compute the centers of the bins
bin_centers = (edges[1:end-1] .+ edges[2:end]) ./ 2

data = StructArray(x=bin_centers, h=h.weights)

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
