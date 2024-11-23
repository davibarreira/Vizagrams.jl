# The Chart Missing From ALL Spreadsheet Software

This example is inspired in the video (https://www.youtube.com/watch?v=5zBg9pH_6bE)
by the Minute Physics channel.
The idea is to used floating stacked bars to represent data such as temperature
ranges. Check the video for a discussion on this specific visualization.

```@example 1
using Vizagrams
using DataFrames
using CSV
path = joinpath(pkgdir(Vizagrams), "docs", "src", "assets", "weather.csv")
df = DataFrame(CSV.File(path))
```

Once we import the data, we must transform the dataframe such that
each row contains a pair of temperature values for a given range.

```@example 1
df = stack(df, [:Ontario, :England, :Kentucky], variable_name=:location, value_name=:value)

coalg_pairwise(lst) = [(lst[i],lst[i+1]) for i in 1:length(lst)-1]
df = combine(groupby(df,:location)) do gdf
    hcat(
        DataFrame(coalg_pairwise(gdf[!,:Column1]),[:low,:high]),
        DataFrame(coalg_pairwise(gdf[!,:value]),[:l,:h])
    )
    
end
df[!,:low_high] = df[!,:low] .* "_" .* df[!,:high]
df
```

We can now use Vizagrams to express the graphic.

```@example 1
plt = Plot(
    config = (;yaxis=(;title="Temperature (°C)")),
    data=df,
    x = :location,
    y = (field=:h,scale_domain=(-10,40), scale_range=(0,200)),
    low_y = (field=:l,scale_domain=(-10,40), scale_range=(0,200)),
    color = (field=:low_high,scale_range=["#F28E2B","#4E79A7","#FFBE7D","#A0CBE8"]),
    graphic = ∑(i=:x) do rows
        ∑() do row
            S(:fill=>row.color,:stroke=>:white)*
            Trail([[row.x,row.low_y],[row.x,row.y]],20)
        end(rows)
    end
)

draw(plt, height=400)
```
