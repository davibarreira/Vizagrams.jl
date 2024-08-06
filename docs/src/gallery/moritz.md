# Replicating OECD Better Life Visualization

In this notebook, we show how Vizagrams can be use to produce
the [OECD Better Life visualization](https://www.oecdbetterlifeindex.org).

## 1. Creating Petal
We start by creating the Petal mark.

```@example 1
using Vizagrams
import Vizagrams: ζ, θ;

using DataFrames
using CSV
using ColorSchemes
using Colors
using Statistics
import Random

# Creating a colorscheme
rainbow_12 = ColorScheme(colourschemes[:rainbow][reverse(vcat(1:2:17,2,8,14))]);

struct Petal <: Mark
    height::Real
    width::Real
    color::String
end

# Default Petal
Petal(;height=1, width=0.5, color="steelblue") = Petal(height, width,color)

function θ(p::Petal)
    (;height, width, color) = p
    return η([
                Prim(CBezierPolygon(
                    [[0,0],[0,height],[0,0]],
                    [[-width,height*0.8],[0,height],[0,height],[width,height*0.8],[0,0],[0,0]]),
                S(:fill=>color, :strokeWidth=>0))
            ])
end
draw(Petal())
```

## 2. Creating Flower

The next step is to use the Petal to create the Flower. This is done by passing the respective heights,
widths and colors for each petal. The flower is then produced by rotating each petal accordingly.

```@example 1
struct Flower <: Mark
    heights::Vector{Real}
    widths::Vector{Real}
    colors::Vector{String}
end

function ζ(flower::Flower)
    (;heights, widths, colors) = flower
    numberpetals = length(heights)
    angles = range(0,2π,numberpetals+1)[begin:end-1]
    reduce(+,map(x->R(-x[1])* Petal(x[2],x[3],x[4]),
            zip(angles,heights, widths, colors)))
end


Random.seed!(4)
npetals = 8
heights = rand(npetals);
widths = heights * 0.35
colors = map(x->"#"*hex(get(colourschemes[:rainbow], rand())),1:npetals)
flower = Flower(heights, widths,colors)

draw(flower)
```

## 3. Creating Stem
The Stem consisting in a vertical bar together with a text.

```@example 1
struct Stem <: Mark
    height::Real
    text::String
end

function ζ(stem::Stem)
    (;height, text) = stem
    stem_bar = T(0,height) * T(0,-height)Bar(h=height,w=0.05)
    
    t = TextMark(text=text,angle=π/2,fontsize=7)
    textbox = U(1.2)rectboundingbox(t,S(:fill=>:white)) + t
    textbox = U(0.05) * textbox
    textbox = amiddle(stem_bar,textbox)*textbox
    return stem_bar + textbox
end
stem_height = 5
stem_text = "Text"

stem = Stem(stem_height, stem_text)
draw(stem)
```

## 4. Creating Plant
With the Flower and Stem, we can create the Plant mark as shown in the OECD Better Life Index visualization.

```@example 1
struct Plant <: Mark
    flower_heights::Vector{Real}
    flower_widths::Vector{Real}
    flower_colors::Vector{String}
    stem_height::Real
    stem_text::String
end
Plant(;flower_heights, flower_widths, flower_colors, stem_height, stem_text) = Plant(flower_heights, flower_widths, flower_colors, stem_height, stem_text) 

function ζ(plant::Plant)
    (;flower_heights, flower_widths, flower_colors, stem_height, stem_text) = plant

    flower = Flower(flower_heights, flower_widths, flower_colors)
    stem = Stem(stem_height, stem_text)
    d = stem + T(0,stem_height) * flower
end

stem_height = 5
stem_text = "Text"
plant = Plant(heights, widths, colors, stem_height, stem_text)

draw(plant)
```
## 5. Making the Plot

We use the OECD Better Life Index found in ["https://stats.oecd.org/Index.aspx?DataSetCode=BLI"](https://stats.oecd.org/Index.aspx?DataSetCode=BLI).

First, let us fix the dataset. We are using the OECD Better Life Index, the one used by
Moritz. The original dataset is not in the proper format for the visualization. We need
to do some transformations in order to get something more similar to the data used by Moritz.

Thus, we do some data normalization in order to compute the indexes for each topic.
We do no claim that index values we compute are the actual correct indexes. But this
does not matter to us, as our goal is just to replicate the visualization, not the
dataset.

```@example 1
path = joinpath(pkgdir(Vizagrams), "docs", "src", "assets", "oecd.csv")
df = DataFrame(CSV.File(path));
df[!,:BLI_Index] = map(x->split(x,"_")[1], df.INDICATOR)

df = leftjoin(df,combine(groupby(df, :Indicator), :Value => maximum, :Value=> minimum), on=:Indicator)
df[!,:Norm_Value] = map(row->(row[:Value] - row[:Value_minimum])/(row[:Value_maximum] - row[:Value_minimum]),eachrow(df))
df = combine(groupby(df,[:Country,:BLI_Index]),:Norm_Value=>mean)
df = rename(df,:BLI_Index => :Topic, :Norm_Value_mean => :Value)
df = leftjoin(df,combine(groupby(df,:Country),:Value=>sum),on=:Country)
df = filter(row->row[:Country]!="OECD - Total",df)
df[!,:Country] = map(x->x == "Korea" ? "South Korea" : x ,df.Country)
df[!,:Country] = map(x->x == "Türkiye" ? "Turkey" : x ,df.Country)
df[!,:Country] = map(x->x == "Slovak Republic" ? "Slovakia" : x ,df.Country);
nothing #hide
```

### 5.1 Scatter Plot
We start with a simple scatter plot.
```@example 1
scatter_plt = Plot(
    title="Scatter Plot",
    figsize=(1000,200),
    data=df,
    config=(
        xaxis=(title="Countries", ticktextangle=π/2),
        yaxis=(title="Value in Topics",),
        ),
    encodings=(
        x = (field = :Country, datatype = :n),
        y = (field = :Value, datatype = :q),
        color = (field = :Topic, datatype=:n,scale_domain=unique(df.Topic),scale_range=rainbow_12),
    ),
    graphic = ∑(row->begin
            T(row[:x],row[:y])*S(:fill=>row[:color],:opacity=>0.8)*Circle(r=3)
        end)
);

draw(scatter_plt, width=800)
```

### 5.2 Flower Plot
Next, we use the Flower mark as a nested plot that aggregates the values in the same country.

```@example 1
flowerplt = Plot(
    title="MyPlot",
    figsize=(1000,200),
    data=df,
    config=(
        xaxis=(title="Countries", ticktextangle=π/2),
        yaxis=(title="Value in Topics",),
        ),
    encodings=(
        x = (field = :Country, datatype = :n),
        y = (field = :Value_sum, datatype = :q),
        color = (field = :Topic, datatype=:n,scale_domain=unique(df.Topic),scale_range=rainbow_12),
        h = (field=:Value, datatype=:q, scale=IdScale()),
    ),
    graphic= ∑(i=:x,orderby=:x, row-> begin
                T(first(row.:x),first(row.:y))U(20)Flower(row.h, 0.30*row.h,row.color)
            end
            )
);

draw(flowerplt,width=800)
```
### 5.3 Plant Plot
We finish with the OECD Better Index Plot using our Plant mark.

```@example 1
plt = Plot(
        figsize=(1000,200),
        data=df,
        config=(
            frame=NilD(),
            grid=NilD(),
            xaxis=(ticktexts="",tickmark=NilD()),
            yaxis=(axisarrow=NilD(),title=""),
            ),
        encodings=(
            x = (field = :Country, datatype = :n),
            y = (field = :Value_sum, datatype = :q, scale_domain=(0,8)),
            color = (field = :Topic, datatype=:n,scale_domain=unique(df.Topic),scale_range=rainbow_12),
            h = (field=:Value, datatype=:q, scale=IdScale(),),
            text=(field=:Country,datatype=:n, scale=IdScale()),
        ),
        graphic = ∑(i=:x, rows-> begin
                    T(rows.:x[1],0) * U(20)*
                    Plant(
                        flower_heights=rows.h,
                        flower_widths =0.30rows.h,
                        flower_colors=rows.color,
                        stem_height=rows.y[1]/20,
                        stem_text=rows.text[1]
                    )
            end)
    )
draw(plt,width=800)
```
