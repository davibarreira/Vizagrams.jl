# Nightingale's Rose Diagram

This example recreates the famous rose diagram by Florence Nightingale.
You can read about this plot [here](https://www.historyofinformation.com/detail.php?entryid=3815).

## 1. Importing the Data

Let us begin simply by importing the data into two dataframes.
We have already adjusted the data for our plots.

```@example 1
using Vizagrams
using DataFrames
using Random
using CSV
using Dates

path = joinpath(pkgdir(Vizagrams), "docs", "src", "assets", "nightingale1.csv")
df1 = DataFrame(CSV.File(path));
path = joinpath(pkgdir(Vizagrams), "docs", "src", "assets", "nightingale2.csv")
df2 = DataFrame(CSV.File(path));

nothing #hide
```

## 2. Initial Polar Plot

With the data adjusted, let us create a single plot in order to get a better sense for the final diagram.

```@example 1
# The colors close to the original diagram
colors = ["#93bee2ff","#f2a4abff","#808080ff"]

plt = Plot(
    data=df1,
    config=(
        raxis=(angle=3π/4,tickvalues=[0,20,40,60,80,100]),
        coordinate=:polar,
        figsize=(300,300),
        ),
    encodings=(
        r = (
            field=:countsqr,
            datatype=:q,
            scale_domain =(0,100),),
        angle = (
            field=:month,
            datatype=:n,
            scale_domain = Dates.LOCALES["english"].months,
            ),
        cause=(field=:order,scale=IdScale()),
        color = (field=:cause,scale_range=colors),
        date = (field=:datetime,scale=IdScale()),
    ),
    graphic = ∑(i=:date,orderby=:cause,descend=false) do rows
        rmaj = cumsum(rows.r)
        rmin = vcat(0,rmaj[begin:end-1])
        ∑() do row
            S(:fill=>row.color,:opacity=>1.0)*
            Slice(rmajor=row.rmaj,rminor=row.rmin,θ=row.angle+π/2-π/12,ang=π/6)
        end(hconcat(rows,rmaj=rmaj,rmin=rmin))
    end
);

draw(plt, height=500)
```

## 3. Rose Diagram

The plot above is very close to the original plot, but there are still some modifications we must do.
For example, we must remove the axes, and write the months next to each slice.
Since we want to create two rose diagrams, let us define a function that takes the
data as input and produces our plot. The function is mostly just passing the plot complete specification
with the data as an argument.

```@example 1
function roseplot(data; title="",legends=true, legend_transform=T(0,0))
    if legends == false
        legends = NilD()
    else
        legends = (;transform=legend_transform)
    end
    return Plot(
        data=data,
        title=T(0,100)TextMark(text=title, fontsize=8),
        config=(
            coordinate=:polar,
            frame=NilD(),
            grid=NilD(),
            axes=NilD(),
            legends=legends,
            ),
        encodings=(
            r = (
                field=:countsqr,
                datatype=:q,
                scale_domain =(0,100), scale_range=(1,150)),
            angle = (
                field=:month,
                datatype=:n,
                scale_domain = Dates.LOCALES["english"].months,
                scale_range = collect(range(0, -2π; length=12 + 1))[begin:(end-1)]
                ),
            month=(field=:month, datatype=:n,scale=IdScale()),
            cause=(field=:order,scale=IdScale()),
            color = (field=:cause,scale_range=colors),
            date = (field=:datetime,scale=IdScale()),
        ),
        graphic = data->
        R(-π/2)*∑(i=:date,orderby=:cause,descend=false) do rows
            rmaj = cumsum(rows.r)
            rmin = vcat(0,rmaj[begin:end-1])
            slices = ∑() do row
                S(:fill=>row.color,:opacity=>1.0)*
                Slice(rmajor=row.rmaj,rminor=row.rmin,θ=row.angle-1.5π-π/12,ang=π/6)
            end(hconcat(rows,rmaj=rmaj,rmin=rmin))
    
            r_text = max(rmaj[end]+5,50)
            x = cos(rows.angle[1]) * r_text
            y = sin(rows.angle[1]) * r_text
            return slices +
                   T(x,y)TextMark(text=rows.month[1],angle=rows.angle[1]-π/2,fontsize=4)
        end(data)
    );
end
```

With this function implemented, we can create the two diagrams.

```@example 1
rose1 = roseplot(df1, title="April 1854 to March 1855",legends=false)
rose2 = roseplot(df2, title="April 1855 to March 1856",
                legends=true,legend_transform=T(-50,-90)U(0.7))

draw(rose2 + T(300,0)rose1,height=400,width=800)
```

## 4. Complete Rose Diagram
The previous diagram is very close to the original rose diagram, but we can make it even closer to the original.
In the original, there is a line between each rose that is used to indicate where the first rose ends and the other begins.
We can also add a title over the whole diagram. 

```@example 1
ang = -π/2 + π/12 + getscale(rose1,:angle)("April")
x = cos(ang)*90
y = sin(ang)*90

posrose1 = [x,y]
posrose1 = T(300,0)(posrose1)

ang = -π/2 + π/12 + getscale(rose2,:angle)("April")
x = cos(ang)*60
y = sin(ang)*60
posrose2 = [x,y]

l = S(:strokeDasharray=>5)Line([posrose1,[100,-50],posrose2])
d = rose2 + T(300,0)rose1 + l

maintitle = TextMark(text="Diagram of the Causes of Mortality",fontfamily="monospace")
subtitle = TextMark(text="in the Army in the East",fontfamily="monospace")
title = maintitle ↓ (T(0,-5),subtitle)

d = d + T(0,150)acenter(d,title)*title

draw(d,height=400,width=800)
```
