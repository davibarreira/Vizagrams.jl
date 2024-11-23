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
        DataFrame(coalg_pairwise(gdf[!,:Column1]),[:label_low,:label_high]),
        DataFrame(coalg_pairwise(gdf[!,:value]),[:low_temp,:high_temp])
    )
end
df[!,:label_temp] = df[!,:label_low] .* " | " .* df[!,:label_high]
df
```

We can now use Vizagrams to express the graphic.

```@example 1
plt = Plot(
    config = (;yaxis=(;title="Temperature (°C)")),
    data=df,
    x = :location,
    y = (field=:high_temp,scale_domain=(-10,40), scale_range=(0,200)),
    low_y = (field=:low_temp,scale_domain=(-10,40), scale_range=(0,200)),
    color = (field=:label_temp,scale_range=["#F28E2B","#4E79A7","#FFBE7D","#A0CBE8"]),
    graphic =
        ∑() do row
            S(:fill=>row.color,:stroke=>:white)*
            Trail([[row.x,row.low_y],[row.x,row.y]],20)
        end
)

draw(plt, height=400)
```
