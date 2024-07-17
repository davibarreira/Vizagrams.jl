# Grouped Bar Chart

In this example, we produce the grouped bar chart. We start with the
bar chart in the x axis direction.

```@example 1
using Vizagrams
using DataFrames

df = DataFrame(
    :category => ["A", "A", "A", "B", "B", "B", "C", "C", "C"],
    :group => ["x", "y", "z", "x", "y", "z", "x", "y", "z"],
    :value => [0.1, 0.6, 0.9, 0.7, 0.2, 1.1, 0.6, 0.1, 0.2]
);


plt = Plot(
    data=df,
    encodings=(
        x=(field=:category,),
        y=(field=:value,),
        color=(field=:group,datatype=:n),
    ),
    graphic =
        ∑(i=:x,op=+,
            ∑(i=:color,op=→,orderby=:color, descend=false,
                data-> begin
                w = 20
                bars = ∑() do row
                    S(:fill=>row[:color])Bar(h=row[:y],c=[row[:x],0], w = w)
                end(data)
                total_width = boundingwidth(bars)
                T(-total_width/2-w/2,0)bars
            end
            )
        )
)

draw(plt)
```

With some small modifications, we can produce the grouped bar chart in the y axis.

```@example 1
plt = Plot(
    data=df,
    figsize=(400,300),
    encodings=(
        x=(field=:value,),
        y=(field=:category,),
        color=(field=:group,datatype=:n),
    ),
    graphic =
        ∑(i=:y,op=+,
            ∑(i=:color,op=↑,orderby=:color, descend=false,
                data-> begin
                w = 20
                bars = ∑() do row
                    S(:fill=>row[:color])T(0,row[:y])R(-π/2)Bar(h=row[:x], w = w)
                end(data)
                total_height = boundingheight(bars)
                T(0,-total_height/2-w/2)bars
            end
            )
        )
)
draw(plt)
```
