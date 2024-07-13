# Polar Visualizations

At the moment, all our plots have used the typical Cartesian coordinates. In this tutorial,
we explore data visualizations that use the polar coordinate system.

## 1. Pizza Plot

Let us start with the very common pizza plot (pie chart).
To construct such plot, we must map a data column to angles. Moreover,
we need to compute the cumulative angle, in order to rotate the slices by
the right amount. Note that this plot does not have any coordinate axes, as we
don't use x and y when specifying the pizza.

The quick way of producing this plot is by using the preset mark `Pizza`:

```@example 1
using Vizagrams
using DataFrames
using Random

Random.seed!(4)
df = DataFrame(x=[1, 2, 3, 5, 1, 2], y=[10, 10, 20, 10, 20, 30],
    c=["a", "b", "a", "a", "b", "a"],d=rand([0,1],6),e=rand([1,2,3],6),
    k=["key1","key2","key3","key4","key5","key6"]
)

plt = Plot(
    figsize=(300,250),
    data=df,
    encodings=(
        color=(field=:k,datatype=:n),
        angle = (field = :x, datatype=:q, scale_domain=(0,sum(df.x)), scale_range=(0,2π)),
        r = (field=:y, scale_range=(80,120))
    ),
    graphic = Pizza()
)

draw(plt)
```

Note that we must adjust the scale for the angle so that the domain goes from `0` to the sum of values of `x` and
ranging from 0 to 2π. We must also adjust the scale for the radius variable `r`, so that our pizza is large enough
compared to the `figsize`.

We can replicate the pizza plot using Slice marks instead. This makes the construction process more explicit
and allows us to more easily create new types of visualizations.

```@example 1
plt = Plot(
    figsize=(300,250),
    data=df,
    encodings=(
        color=(field=:k,datatype=:n),
        angle = (field = :x, datatype=:q, scale_domain=(0,sum(df.x)), scale_range=(0,2π)),
        r = (field=:y, scale_range=(80,120)),
    ),
    graphic = data -> begin
        acc = cumsum(vcat(0,getscale(plt,:angle)(df.x)[begin:end-1]))
        data = hconcat(data,acc=acc)
        ∑() do row
            S(:fill=>row.color)Slice(rmajor=row.r,ang=row.angle,θ=row.acc,rminor=20)
        end(data)
    end
)

draw(plt)
```

Let us explain the graphic expression:
```julia
graphic = data -> begin
    acc = cumsum(vcat(0,getscale(plt,:angle)(df.x)[begin:end-1]))
    acc = StructArray(acc=acc)
    data = hconcat(data,acc)
    ∑() do row
        S(:fill=>row.color)Slice(rmajor=row.r,ang=row.angle,θ=row.acc,rminor=20)
    end(data)
end
```
The main hurdle to specify the pizza plot is to compute the cumulative angle. This must
be done over the whole dataset, before we draw each slice. To do this, we simply
start our graphic expression with `data -> ...`. Then, we compute the cumulative angle,
and append it to the `data`. We then can simply loop over each row drawing the slices.

The advantage of such approach is that we can now easily add labels. We add a new
variable `text` to our specification, compute the
the x and y positions for the labels, and add the `TextMark`.

```@example 1
plt = Plot(
    figsize=(300,250),
    data=df,
    encodings=(
        color=(field=:k,datatype=:n),
        angle = (field = :x, datatype=:q, scale_domain=(0,sum(df.x)), scale_range=(0,2π)),
        r = (field=:y, scale_range=(80,120)),
        text = (field=:y, scale=IdScale()),
    ),
    graphic = data -> begin
        acc = cumsum(vcat(0,getscale(plt,:angle)(df.x)[begin:end-1]))
        data = hconcat(data,acc=acc)
        ∑() do row
            r = row.r + 15
            x = r*cos(row.acc-π/2+row.angle/2)
            y = r*sin(row.acc-π/2+row.angle/2)
            S(:fill=>row.color,:stroke=>:white)Slice(rmajor=row.r,ang=row.angle,θ=row.acc,rminor=20) +
            S(:fill=>row.color)T(x,y)TextMark(text=row.text,fontsize=8)
        end(data)
    end
)

draw(plt)
```

## 2. Radar Plot

Our next examples are radar plots. These are distinct from pizza plots in the sense that they
actually use polar coordinates. In order to user polar coordinates in a graphic specification,
we must simply pass `coordinate = :polar` to the `config`. While the Cartesian coordinates
require the `x` and `y` encoding variables, the polar coordinate requires the radius variable `r`
and the `angle`. Vizagrams then computes the `x` and `y` values automatically, which can be used
in graphic expressions.

Let us first do a simple example.
```@example 1
plt = Plot(
    figsize=(300,300),
    data=df,
    config=(coordinate=:polar,),
    encodings=(
        r = (field=:y,datatype=:q, scale=Linear(domain=(0,maximum(df[!,:y])), codomain=(0,150))),
        angle = (field = :k, datatype = :n, scale = Categorical(domain=unique(df.k),codomain=collect(range(0,2π,length=length(unique(df.k))+1))[begin:end-1])),
    ),
    graphic = Polygon() + S(:fill=>:steelblue,:opacity=>1)Circle(r=10)
);
draw(plt)
```

Using the Polygon with the Circle marks we can produce the radar plot. Other marks could also be used
in order to produce other types of visualizations. In the next example, we change the radius scale range
so that the frame resembles a donut. Note that we also use `guide=(a_tick_flag=:in,)` within the `config`
in order place the ticks to be in the inner radius.

```@example 1
plt = Plot(
    figsize=(300,300),
    data=df,
    config=(
        guide=(a_tick_flag=:in,),
        coordinate=:polar,),
    encodings=(
        r = (field=:y,datatype=:q, scale_domain=(0,maximum(df[!,:y])+10), scale_range=(70,150)),
        angle = (field = :k, datatype = :n, scale = Categorical(domain=unique(df.k),codomain=collect(range(0,2π,length=length(unique(df.k))+1))[begin:end-1])),
        color=(field=:d,datatype=:n),
        size=(field=:e,datatype=:q),
    ),
    graphic = Line() + S(:opacity=>1)Circle()
);
draw(plt)
```
