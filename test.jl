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
    graphic=∑(;
        i=:x,
        op=+,
        ∑(;
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
