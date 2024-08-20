# Composite Visualizations

Composite visualizations are those that combine distinct plots to form a single visualization.
A simple example of this are subplots, where one stacks plots together either vertically or
horizontally. There are several ways to produce composite plots. Let us explore how to do them
using Vizagrams.


## 1. Facet Plots

Facet plots are those where the data is broken into distinct columns.
In Vizagrams, this kind of plot can be done in different ways.
One way consists in using the plot specification with another plot
specification inside. The second way involves grouping the data and then
combining the plots using the diagramming operations.

## 1.1 Facet Plot via Diagramming
Let us start with the diagramming way.

```@example 1
using Vizagrams
using StatsBase
using DataFrames
using Random
using VegaDatasets

df = DataFrame(dataset("cars"));
df[!,:Year] = map(x->parse(Int,x[3:4]),df.Year)
df = dropmissing(df);

facet = ∑(i=:Origin,op=→) do gdf
    Plot(
        title=gdf.Origin[1],
        config=(;legends=NilD()),
        data=gdf,
        x=(field=:Horsepower,scale_domain=(40,250)),
        y=(field=:Miles_per_Gallon,scale_domain=(0,50)),
    )
end(df)

draw(facet,width=800)
```
Note that, in the code above, we are using the `∑` operator to group the dataset `df` using
the column `Origin`. Once the dataset is grouped, we create a plot. Then, each plot
is combined using the beside operator `→`.

One might wish to apply different colors to each plot. This can be done by creating a
scale function, as shown next:

```@example 1
colorscale = infer_scale(data=df.Origin, variable=:color)
facet = ∑(i=:Origin,op=→) do gdf
    Plot(
        title=gdf.Origin[1],
        config=(;legends=NilD()),
        data=gdf,
        x=(field=:Horsepower,scale_domain=(40,250)),
        y=(field=:Miles_per_Gallon,scale_domain=(0,50)),
        color=(value=row->colorscale(row.Origin),scale=IdScale()),
    )
end(df)

draw(facet,width=800)
```

## 1.2 Facet Plot via Plot Specification

It is also possible to create a facet plot using a plot specification.

```@example 1
facet = Plot(
    config=(
        figsize=(300,200),
        coordinate=nothing,
        frame=NilD(),
        legends=(;transform=T(1030,200)),
        ),
    data=df,
    x=(field=:Horsepower,scale=IdScale()),
    y=(field=:Miles_per_Gallon,scale=IdScale()),
    color=(field=:Origin,),
    origin=(field=:Origin,scale=IdScale()),

    graphic= data->begin
        ∑(i=:color,op=(x,y)->x→(T(10,0),y)) do gdf
            Plot(
                title=gdf.origin[1],
                config=(legends=NilD(),xaxis=(;title="")),
                data=gdf,
                x=(field=:x,scale_domain=(0,250)),
                y=(field=:y,scale_domain=(0,50)),
                color=(field=:color,scale=IdScale()))
        end(data)↓(T(0,-10),TextMark(text="Horsepower",pos=[150,0]))
    end
)
draw(facet,width=800)
```

## 2. Nesting

Nested visualizations are those where we place a plot inside another plot. In a sense,
we can think of the previous facet plots as a nested visualization, as can be more clearly
seen in the example using a single plot specification.

Let us start with a common example. We do a pizza plot nested inside a scatter plot.
```@example 1
plt = Plot(
    data=df,
    figsize=(500,300),
    x=(field=:Year,scale_domain=(68,84)),
    y=:Cylinders,
    color = (field=:Origin,datatype=:n,),
    angle = (field=:Origin, scale=IdScale()),
    size = (field=:Acceleration, scale_range=(2.0,20)),
    graphic= ∑(i=:x,∑(i=:y) do rows
            acc = mean(rows.size)
            countvalues = sort(countmap(rows.color))
            colors = collect(keys(countvalues))
            angles = 2π.*values(countvalues)./length(rows.angle)
            T(rows.x[1],rows.y[1])U(acc)*
            Pizza(angles=angles,colors=colors,style=S(:strokeWidth=>0.5))
    end)
)

draw(plt)
```

Next, we do a more complex example, showcasing the customization capabilities.

```@example 1
plt = Plot(
    config=(;
        figsize=(400,170),
        frame=NilD(),
        xaxis=(;axisarrow=NilD(),tickmark=NilD()),
        yaxis=(;axisarrow=NilD(),tickmark=S(:opacity=>0)Circle(r=2),ticktextangle=π/2),
        xgrid=NilD(),
        ygrid=(;style=S(:strokeWidth=>48,:vectorEffect=>"none",:strokeOpacity=>0.03)),
        legends=(;transform=T(420,120)U(0.5))
        ),
    data=df,
    x=(field=:Cylinders),
    y=(field=:Origin),
    color=(field=:Acceleration,),
    horsepower=(field=:Horsepower,scale=IdScale()),
    miles=(field=:Miles_per_Gallon,scale=IdScale()),
    cylinder=(field=:Cylinders,scale=IdScale(),datatype=:o),
    origin=(field=:Origin,scale=IdScale()),

    graphic=
        ∑(i=:cylinder,orderby=:cylinder,descend=true,
            ∑(i=:origin,orderby=:origin,) do gdf
                T(gdf.x[1],gdf.y[1])*
            centralize_graphic(U(0.19)*
                Plot(
                    config=(
                        frame_style=S(:fill=>:white,:fillOpacity=>1.0,),
                        legends=NilD(),
                        yaxis=(;title=""),
                        xaxis=(;title="")),
                    data=gdf,
                    x=(field=:horsepower,scale_domain=(0,250)),
                    y=(field=:miles,scale_domain=(0,50)),
                    color=(field=:color,scale=IdScale())
            ))
            end
    )
)
draw(plt,width=800)
```


## 3. Integrated

Integrated visualizations are those where distinct plots are somehow integrated. A common
example of this would be parallel coordinate plots. The difficulty in creating such
visualizations involves having to coordinate distict scales in order.

Our example is inspired in one of the visualizations presented in the
paper "Dece: Decision explorer with counterfactual explanations for machine learning models"
(2020, Cheng, Furui and Ming, Yao and Qu, Huamin).

Let us start by creating a dataset.
```@example 1
Random.seed!(4)
toefl = 10randn(100) .+ 300
rating = 10randn(100) .+ 100
score = 5rand(100) .+ 5;
accept = rand([0,0,1],100);
df = DataFrame(:toefl=>toefl,:rating=>rating,:score=>score,:accept=>accept);
nothing #hide
```
Next, we create a horizontal bar plot:
```@example 1
plt_accept = Plot(
    title = "Acceptance",
    config=(;grid=NilD(),
        xaxis=(;title="count"),
        yaxis=(;title=""),
        ),
    data=df,
    x=(value=row->sum(df.accept .== row.accept),scale_domain=(0,70)),
    y=:accept,
    graphic=∑(i=:y) do rows
        S(:fill=>:steelblue)T(0,rows.y[1])Bar(w=rows.x[1],h=50,orientation=:h)
    end
)
draw(plt_accept)
```

Our goal next is to create histograms for the other variables and stack them
horizontally. For this, we define a function `tohist` to envelope our histogram specification.
```@example 1
function tohist(data, title)
    Plot(
        title = title,
        config=(;
            grid=NilD(),
            xaxis=(;title="count"),
            yaxis=(;tickvalues=bin_edges(data),title=""),
            ),
        y = bindata(data),
        x = (value=countbin(data),scale_domain=(0,maximum(countbin(data))+2)),

        graphic = data-> begin
        # compute the bin width
        w = let
            u = sort(unique(data.y))
            u[2]-u[1]-1
        end

        # draw each bar
        ∑(i=:y) do row
                S(:fillOpacity=>0.9,:fill=>:steelblue)*
                T(0,row.y[1])Bar(h=w,w=row.x[1],orientation=:h)
        end(data)
    end
    )
end

data = [toefl,rating,score]
plts = map(x->tohist(x[1],x[2]),zip(data,["TOEFL","RATING","SCORE"]));
plts = vcat(plts,plt_accept)
plt = reduce((x,y)->x→(T(10,0),y),plts);

draw(plt,width=800)
```

Up until now, this visualization is simply a sort of facet plot.
The next step is to draw lines accross this plot in order to illustrate
how a single observed row varies accross these different dimensions.

```@example 1
gs = getmarkpath(Plot,plt,G)
lines = mapreduce(+,1:10) do i
    pts = map(zip(plts,[:toefl,:rating,:score,:accept],gs)) do row
        y = getscale(row[1],:y)(df[i,row[2]])
        pos = row[3]([0.0,y])
        pos = row[3]([0.0,y])
    end
    S(:stroke=>:orange)Line(pts)
end

d = plt + lines
draw(d,width=800)
```

To draw the lines we must obtain the position in each axis and apply the same translation
as used in each plot. To do this, we must do two things. First, we must get the scale in each
plot, and apply it to the `y` value in our lines. Secondly, we must get how much
each plot is translated left, and use this in the `x` value.
The first task is done using the `getscale` function, while the second is done using the
`getmarkpath` function.
