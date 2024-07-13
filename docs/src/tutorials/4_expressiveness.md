# Graphic Expressions

It is time to move to more complex graphics. This can be achieved
through the use of graphic expressions which are contained in the
`graphic` parameter of the plot specification.

In data visualization, our goal is to represet data as a diagram
(drawing) such that we can infer information about the data from the
image generated. For this to work, we need a "sensible" way of mapping
data to graphical marks. This "sensible" way of converting data to
diagrams is done in Vizagrams through *graphic expressions*. The ideia
of a graphic expression is that the way we draw graphics can be divided
in three components:

- Coalgebra - This describes how to traverse the data, e.g. we can traverse the data row by row, or we can group it by a given column;

- Expression - This is a function that says how to take a portion of the data (e.g. a row) and express it as a diagram;

- Algebra - This describes how to combine the diagrams produced by each chunk of data.

The graphic expression can be written in a mathematical notation as:

```math
\begin{aligned}
    &expr : \text{Data}\to \text{Diagram} \\
    &alg : \text{[Diagram]}\to \text{Diagram} \\
    &coalg : \text{Data}\to \text{[Data]}
\end{aligned}
```

For those without a mathematical mindset, this might look awfully
complicated, but hopefully we can dispel some of the confusion with some
examples.

```@example 1
using Vizagrams
using DataFrames
using Statistics
using Random
using VegaDatasets
df = DataFrame(dataset("cars"));

# We need to drop missing values, as Vizagrams does not handle them yet.
df = dropmissing(df);

nothing #hide
```

## 1. Scatter Plots v.s. Line Plots

In a scatter plot, the process of drawing the graphic is distinct from
that of a line plot. How so? Suppose we have a dataset with x, y and
color values. For the scatter plot, we traverse the dataset row by row,
drawing a circle in position (x,y) with a given color for each row.
Hence, the number of circles (or any other mark used to represent a
point) will be drawn N times, where N is the number of rows in the
dataset. For the line plot, what we actually want is to group the rows
in the dataset with the same color value, and then, draw a line with
such color passing through all these rows.

In terms of graphic expressions, for the scatter plot we have:
```math
    \sum_{\text{iterate by row}}^{+} \text{S(:stroke=>row.color)}*\text{Circle(c=[row.x,row.y])},
```
where we iterate over each row, creating a circle mark and then
summing them together. Note that the result of the above equation is
equal to:
```math
\text{S(:stroke=>data[1,:color])}*\text{Circle(c=[data[1,:x],data[1,y])} + \\
... \\ 
+\text{S(:stroke=>data[N,:color])}*\text{Circle(c=[data[N,:x],data[N,y])} 
```
The idea is that `data[n,:x]` means picking row `n` column `:x` for
the dataset.

Now, for the line plot, we have:
```math
    \sum^{+}_{\text{group by color}}\text{S(:stroke=>rows.color[1])}*\text{Line(rows.x,rows.y)}.
```
Note that, in this case, we are not iterating over each row, instead,
we are grouping the data by the color values. Each iteration contains
many rows, thus, `rows.x` is actually a list of values in column `x`.
Since each iteration has the same value for color, we use
`rows.color[1]` to get a single color value, and use it to color the
whole line.

In tutorial 3, we have shown how to create scatter plots and line plots
simply by picking a mark such as `Circle` or `Line`. Under the hood,
what Vizagrams was doing was to infer the graphic expressions for such
marks. Now, let us instead pass the actual graphic expression:

```@example 1
gdf = combine(groupby(df,[:Year,:Origin]),:Horsepower=>mean,:Miles_per_Gallon=>mean)

plt = Plot(
    config=(xaxis=(ticktextangle=π/2,),),
    data=gdf,
    encodings=(
        x=(field=:Year,),
        y=(field=:Horsepower_mean,),
        color=(field=:Origin,),
    ),
    graphic = ∑() do row
        S(:fill=>row.color)Circle(r=5,c=[row.x,row.y])
    end
)
draw(plt)
```


Note that in our `graphic` parameter we passed:

``` julia
∑() do row
    S(:fill=>row.color)Circle(r=5,c=[row.x,row.y])
end
```

This is how we write that summation notation for the graphic expression.
In the case above, the sum `∑()` is doing the job of
``\sum^{+}_{\text{iterate by row}}``.

Let us now show how to do the lineplot.

```@example 1
plt = Plot(
    config=(xaxis=(ticktextangle=π/2,),),
    data=gdf,
    encodings=(
        x=(field=:Year,),
        y=(field=:Horsepower_mean,),
        color=(field=:Origin,),
    ),
    graphic= ∑(i=:color) do rows
        S(:stroke=>rows.color[1],:strokeWidth=>3)Line(rows.x,rows.y)
    end
)
draw(plt)
```


This time, we used the following graphic expression:

``` julia
∑(i=:color) do rows
    S(:stroke=>rows.color[1],:strokeWidth=>2)Line(rows.x,rows.y)
end
```

Here, the `∑(i=:color)` is how we define that the data must be grouped
by `:color`. The `i` is to invoke the idea of indexing, in other words,
this is a summation where we are indexing the data by the color value.

## 2. Exploring Graphic Expressions

Note that the graphic expressions for the scatter plot and the line plot
can easily be modified to produce other plots. Consider, for example,
that we wish to create a scatter plot with a mark `Face`. The
specification is almost the same as the one for the scatter plot with
circles:

```@example 1
plt = Plot(
    title="MyPlot",
    data=df,
    encodings=(
        x = (field = :Horsepower,),
        y = (field = :Displacement,),
        color = (field = :Origin, colorscheme=:tableau_superfishel_stone),
        smile = (field = :Cylinders, scale_range=(-1,1),),
    ),
    graphic = ∑() do row
        T(row[:x],row[:y])U(5)Face(headstyle=S(:fill=>row[:color]),smile=row[:smile])
    end
)


draw(plt, height=400)
```


The graphic expression is very straightforward. We simply iterate over
each row, drawing the face mark. Instead of passing the x and y
positions to the mark, we are using a translation transformation. We
also use the scaling `U(5)` in order to enlarge the mark.

``` julia
∑() do row
    T(row[:x],row[:y])U(5)Face(headstyle=S(:fill=>row[:color]),smile=row[:smile])
end
```

For the encoding specification, the main difference is the `smile`
variable.

``` julia
smile = (field = :Cylinders, scale_range=(-1,1),),
```

In the specifcation above, we are encoding the data columns `Cylinders`
and applying a linear scaling function where the cylinder values are
mapped to values between -1 and 1.

```@example 1
plt = Plot(
    config=(xaxis=(ticktextangle=π/2,),),
    data=gdf,
    encodings=(
        x=(field=:Year,),
        y=(field=:Horsepower_mean,),
        color=(field=:Origin,),
    ),
    graphic= ∑(i=:color) do rows
        S(:stroke=>rows.color[1],:strokeWidth=>2)*
        Arrow(rows.x,rows.y,headsize=5,headstyle=S(:fill=>rows.color[1]))
    end
)
draw(plt)
```


```@example 1
gdf = combine(groupby(df,[:Year,:Origin]),:Horsepower=>mean,:Miles_per_Gallon=>mean)

gdf = sort(gdf,:Year)

plt = Plot(
    title="MyPlot",
    config=(
            xaxis=(ticktextangle=π/2,),
            yaxis=(ticktextangle=0,ticktextanchor=:c),
        ),
    data = gdf,
    encodings=(
        x=(field=:Year,),
        y=(field=:Horsepower_mean,),
        color=(field=:Origin,),
    ),
    graphic = ∑(i=:color,orderby=:color,descend=true) do row
        S(:strokeWidth=>5)Area(pts=row.x ⊗ row.y,color=row.color[1])
    end
)

draw(plt)
```


```@example 1
gdf = combine(groupby(df,[:Origin]),nrow,)
gdf = rename(gdf, :nrow=>:Total_Cars);

plt = Plot(
    data=gdf,
    encodings=(
        x=(field=:Origin,),
        y=(field=:Total_Cars,),
        text=(field=:Total_Cars,scale=IdScale()),
    ),
    graphic= ∑() do row
        bar = S(:fill=>:steelblue)*Bar(h=row[:y],c=[row[:x],0],w=40)
        text= TextMark(text=row[:text])
        return bar ↑ (T(row[:x],5),text)
    end
)
draw(plt)
```


As we have stated, a graphic expression has a coalgebra (how to iterate
over the data), an expression (how to turn sections of the data into
diagrams) and an algebra (how to combine diagrams). In our previous
example, both graphic expressions use the `+` operator as the algebra.
Yet, different operations could be used, such as stacking. For example:
```math
\sum^{\uparrow}_{\text{iterate by row}} Circle(r=row.size)
```
is equal to
```math
Circle(r=data[1,:size]) \uparrow Circle(r=data[2,:size])  \uparrow ... \uparrow Circle(r=data[N,:size]).
```

Moreover, we can compose graphic expressions in order to perform a
nested iteration. For example,
```math
\sum^{alg = +}_{i=\text{:x}}\sum^{alg=\uparrow}_{j=\text{:color}} expr
```
In this graphic expression, we first group the data by values of
`:x`, then each group if further grouped by values of `:color`. Think of
this as nested for-loops.

The example we just gave is actually how we can construct stacked bar
plots. Note:

```@example 1
gdf = combine(groupby(df,[:Origin, :Cylinders]),:Miles_per_Gallon=>mean,:Horsepower=>mean);
plt = Plot(
    data=gdf,
    encodings=(
        x=(field=:Cylinders,),
        y=(field=:Miles_per_Gallon_mean,guide=(lim = (0,100),)),
        color=(field=:Origin,datatype=:n),
    ),
    graphic =
        ∑(i=:x,op=+,
            ∑(i=:color,op=↑,orderby=:color, descend=false,
                ∑() do row
                    S(:fill=>row[:color])Bar(h=row[:y],c=[row[:x],0], w = 40) 
                end
            )
        )
    )
draw(plt, height=400)
```


The process of drawing the stacked bars can be described as follows:

    Group data by values of x
        Group data by values of color
            Iterate over each row drawing bar
        Stack bars vertically
    Sum the stacked bars

This process of grouping and combining is exactly what the graphic
expression is doing.

``` julia
∑(i=:x,op=+,
    ∑(i=:color,op=↑,orderby=:color, descend=false,
        ∑() do row
            S(:fill=>row[:color])Bar(h=row[:y],c=[row[:x],0], w = 40) 
        end
    )
)
```

Here is where things start to get interesting. Suppose now we want to
add a text with the value of each bar as a label. We can simply
increment the previous graphic expression with a

```@example 1
gdf = combine(
    groupby(df, [:Origin, :Cylinders]), :Miles_per_Gallon => mean, :Horsepower => mean
);
plt = Plot(;
    data=gdf,
    encodings=(
        x=(field=:Cylinders,),
        y=(field=:Miles_per_Gallon_mean, guide=(lim=(0, 100),)),
        color=(field=:Origin, datatype=:n),
        text=(field=:Miles_per_Gallon_mean, scale=x -> x),
    ),
    graphic=∑(
        i=:x,
        op=+,
        ∑(
            i=:color,
            op=↑,
            orderby=:color,
            descend=false,
            ∑() do row
                S(:fill => row[:color])Bar(; h=row[:y], c=[row[:x], 0], w=40) +
                S(:fill => :white) * TextMark(;
                    text=round(row[:text]; digits=1), pos=[row[:x], row[:y] / 2], fontsize=7
                )
            end,
        ),
    ),
)
draw(plt; height=400)
```

```@example 1
gdf = combine(
    groupby(df, [:Origin, :Cylinders]), :Miles_per_Gallon => mean, :Horsepower => mean
);
plt = Plot(;
    data=gdf,
    encodings=(
        x=(field=:Cylinders,),
        y=(field=:Miles_per_Gallon_mean, guide=(lim=(0, 100),)),
        color=(field=:Origin, datatype=:n),
        text=(field=:Miles_per_Gallon_mean, scale=IdScale()),
        w=(
            field=:Horsepower_mean,
            scale_domain=(75, 160),
            scale_range=(20, 50),
            legend=(fmark=x -> Bar(; h=1, w=x),),
        ),
        textw=(field=:Horsepower_mean, scale=IdScale()),
    ),
    graphic=∑(
        i=:x,
        op=+,
        ∑(
            i=:color,
            op=↑,
            orderby=:color,
            descend=false,
            ∑() do row
                S(:fill => row[:color])Bar(; h=row[:y], c=[row[:x], 0], w=row[:w]) +
                S(:fill => :white) * TextMark(;
                    text=round(row[:text]; digits=1),
                    pos=[row[:x] + row[:w] / 2 - 2, row[:y] / 2],
                    fontsize=5,
                    angle=π / 2,
                    anchor=:s,
                ) +
                S(:fill => :white) * TextMark(;
                    text=round(row[:textw]; digits=1),
                    pos=[row[:x], 2],
                    fontsize=5,
                    anchor=:s,
                )
            end,
        ),
    ),
)
draw(plt; height=400)
```
