# Basics of Data Visualization

Vizagrams is more than a diagram drawing package, it is also a tool for
data visualization. The main idea is to integrate diagramming with data
visualization, hence increasing the kind of visualizations we can
express. This integration is made possible mainly due to the way we
coded graphical marks.

The way Vizagrams defines graphical marks allows us to create marks such
as axes, grids, legends, and so on, which help us assemble a plot. All
this elements are used by a more general mark called `Plot`. The
parameters used to create an instance of `Plot` is what we call a
graphic specification.

Vizagrams is a visualization grammar in the sense that it provides a
graphic specification. Moreover, the specification follows the
specification style of Vega-Lite, with some slight modifications. If you
know Vega-Lite, the way Vizagrams defines plots will be very familiar to
you. Yet, for those that are not used to visualization grammars,
Vizagrams also provides some quick functions to produce plots.

```@example 3
using Vizagrams
using DataFrames
using Statistics
using Random
```

## 1. First Data Visualization

We start with a very simple example. We generate some random values, and
then create a plot using the function, you guessed it, `plot`. This
function is just a quick way to specify a plot without having to write
the whole specification.

```@example 3
Random.seed!(4)
plt = plot(x=rand(10),y=rand(10))
# plt = S(:vectorEffect=>"none")plt
draw(plt,height=300)
```

And we have a plot. More interestingly, the `plt` object is a diagram,
thus, we can manipulate and compose with other marks.

```@example 3
d1 = plt↑S(:fontWeight => :bold)TextMark(; text="This is my plot", anchor=:e, fontsize=14)
d2 =
    R(π / 5) * (
        plt↑(
            S(:fontWeight => :bold) *
            TextMark(; text="This is my plot rotated", anchor=:e, fontsize=14)
        )
    )

d = d1 → (T(50, 0), d2)
draw(d)
```

## 2. Graphic Specification

For more control over a data visualization, one can use a graphic
specification. A specification is a description of the plot, which
contains information such as how to map the data to the visual
variables, which type of graphical marks one must use, how to scale the
data, and so on. As we have stated, Vizagrams follows the specification
style from Vega-Lite.

First, let us import a dataframe to be visualized.

```@example 3
using VegaDatasets
df = DataFrame(dataset("cars"));

# We need to drop missing values, as Vizagrams does not handle them yet.
df = dropmissing(df);
nothing # hide
```

```@example 3
plt = Plot(
    data=df,
    encodings=(
        x=(field=:Horsepower,),
        y=(field=:Miles_per_Gallon,),
        color=(field=:Origin,)
    ),
    graphic=Circle(r=5)
)
draw(plt)
```

Note that in the example above, Vizagrams tries to infer the proper
scaling and axes for the given plot based on the underlying data. For
example, Vizgrams is guessing that both :Horsepower and
:Miles_per_Gallon are quantitative data, while :Origin is nominal.

Users can provide more parameters to the graphic specifcation in order
to get a graphic closer to ones preferences. For example, besides
`data`, `encoding` and `graphic`, one can use parameters such as
`title`, `figsize` and `config`.

Below we increment the previous plot with more parameters.

```@example 3
p = Plot(
    title="Plot",
    figsize=(500,300),
    config=(
        xgrid=(flag=true,),
        ygrid=(flag=true,)
        ),
    data=df,
    encodings=(
        x=(field=:Horsepower,datatype=:q),
        y=(field=:Miles_per_Gallon,),
        color=(field=:Acceleration,colorscheme=(:red,:blue)),
        size = (field = :Cylinders,datatype=:o, scale_range=(1,3)),
    ),
    graphic=S(:stroke=>:black)Circle(r=3)
)

draw(p, height=300)
```

Let us explore a bit of our specification:

``` julia
p = Plot(
    title="Plot",
    figsize=(300,300),
    config=(
        xgrid=(flag=true,),
        ygrid=(flag=true,)
        ),
    data=df,
    encodings=(
        x=(field=:Horsepower,datatype=:q),
        y=(field=:Miles_per_Gallon,),
        color=(field=:Acceleration,colorscheme=(:red,:blue)),
        size = (field = :Cylinders,datatype=:o, scale_range=(1,3)),
    ),
    graphic=S(:stroke=>:black)Circle(r=3)
)
```

The main fields we have here are `title`,`figsize`,`config`,`data`,
`encodings`, and `graphic`. - `title` is title above the plot; -
`figsize` is pixel size for frame containing the graphic; - `config` is
for extra attributes for manipulating aesthetic aspects of the plot,
such as grids, axes style, and so on' - `data` is picking the dataset; -
`encodings` is mapping the visual variables (positions **x** **y**, and
**color**) to the data columns (**x** goes to *Horsepower*, **y** goes
to *Miles_per_Gallon* and **color** goes to *Field*); - `graphic` is
defininig how to draw the graphic inside the plotting context.

All these parameters are somewhat the same as in Vega-Lite, with the
exception of `graphic`.

In Vega-Lite and other visualization grammars (e.g. ggplot), instead of
this field `graphic` we have a field *mark* or *geom* (stands for
geometry). Their role is very similar to what we have called *graphic*
in the sense that they describe the sort of "graphical mark" to be drawn
in the plotting frame. Yet, as will be shown further, `graphic` contains
what is called *graphic expression*, which are functions that map a set
of data to a diagram.

## 3. More Examples

We end this tutorial presenting some more examples. We do not dive into
the extra capabilities of the `graphic` parameter.

```@example 3
gdf = combine(groupby(df,[:Year,:Origin]),:Horsepower=>mean,:Miles_per_Gallon=>mean)

plt = Plot(
    config=(xaxis=(ticktextangle=π/2,),),
    data=gdf,
    encodings=(
        x=(field=:Year,),
        y=(field=:Horsepower_mean,),
        color=(field=:Origin,),
    ),
    graphic= S(:strokeWidth=>4)Line()
)
draw(plt)
```


If we want to draw the points over the line, we can just add the
circles.

```@example 3
plt = Plot(
    config=(xaxis=(ticktextangle=π/2,),),
    data=gdf,
    encodings=(
        x=(field=:Year,),
        y=(field=:Horsepower_mean,),
        color=(field=:Origin,),
    ),
    graphic= S(:strokeWidth=>4)Line() + S(:opacity=>1)Square(l=10)
)
draw(plt)
```


Vizagrams also has default behavior for marks such as bars.

```@example 3
gdf = combine(groupby(df,[:Year,:Origin]),:Horsepower=>mean,:Miles_per_Gallon=>mean)

plt = Plot(
    config=(xaxis=(ticktextangle=π/2,),),
    data=gdf,
    encodings=(
        x=(field=:Year,),
        y=(field=:Horsepower_mean,),
    ),
    graphic= S(:fill=>:steelblue)Bar(w=20)
)
draw(plt)
```


```@example 3
gdf = combine(groupby(df,[:Year,:Origin]),:Horsepower=>mean,:Miles_per_Gallon=>mean)

plt = Plot(
    config=(xaxis=(ticktextangle=π/2,),),
    data=gdf,
    encodings=(
        x=(field=:Year,),
        y=(field=:Horsepower_mean,guide=(lim=(0,400),)),
        color=(field=:Origin,),
    ),
    graphic= S(:stroke=>:black)Bar(w=20)
)
draw(plt)
```


```@example 3
disasters = DataFrame(dataset("disasters"))
disasters = dropmissing(disasters);
disasters = filter(Cols(:Entity)=>x->x!="All natural disasters", disasters);

plt = Plot(;
    title="Disasters",
    config=(xaxis=(grid=(flag=false,),), yaxis=(grid=(flag=false,),)),
    figsize=(500, 400),
    data=disasters,
    encodings=(
        x=(field=:Year, datatype=:q, guide=(lim=(1900, 2017),)),
        y=(
            field=:Entity,
            datatype=:n,
            guide=(tickvalues=unique(sort(disasters.Entity; rev=true)),),
        ),
        color=(field=:Entity, legend=(flag=false,)),
        size=(
            field=:Deaths,
            datatype=:q,
            scale_domain=(0, maximum(disasters.Deaths)),
            scale_range=(2, 30),
        ),
    ),
    graphic=S(:stroke => :black, :opacity => 0.8)Circle(),
)

draw(plt, height=500)
```
