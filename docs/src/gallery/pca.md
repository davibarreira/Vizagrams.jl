# PCA Plot

This visualization is present in the "Scientific Visualization: Python + Matplotlib" (Nicolas P. Rougier, Bordeaux, November 2021)
book.

It consists in fitting a PCA line through the data, and then drawing the error histogram for such PCA.

## 1. Generating the Data and Computing the PCA

We start creating a dataset by sampling a multivariate normal distribution.
After that, we apply the PCA.

```@example 1
using Vizagrams
using Distributions
using Random
using MultivariateStats
using DataFrames

# Generate data from Multivariate Normal
dist = MvNormal([0,0],[1 0.5; 0.5 1.0])
Random.seed!(4)
samples = rand(dist,100)
x = samples[1,:]
y = samples[2,:];

# Perform PCA
M = fit(PCA, samples; maxoutdim = 1)
transformed_data = MultivariateStats.transform(M, samples)
lsample = reconstruct(M,[-3.,3.0]')

# M = fit(PCA, samples; maxoutdim=2)
samples_pca = reconstruct(M, transformed_data)
pca_x = samples_pca[1,:]
pca_y = samples_pca[2,:];

# DataFrame
df = DataFrame(x=x,y=y,pca_x=pca_x,pca_y=pca_y);
df[!,:err] = map(row->sign(row[:y]-row[:pca_y])√((row[:x]-row[:pca_x])^2 + (row[:y]-row[:pca_y])^2),eachrow(df));

# PCA Equation
lsample = reconstruct(M,[-0.,1.0]')
x1 = lsample[1,1]
y1 = lsample[2,1]
x2 = lsample[1,2]
y2 = lsample[2,2]
α = (y1-y2)/(x1-x2)
β = y1 - α*x1

pcaeq(x) = α*x + β
```

## 2. Creating the Plots

Next, let us create our two main plots that compose the visualization.
We have a scatter plot showing the data:
```@example 1
plt = Plot(
    config =(
        frame_style=S(:strokeWidth=>0),
        grid=NilD(),
    ),
    data = df,
    x=:x,
    y=:y,
    graphic = S(:fill=>:steelblue,:opacity=>0.8,:strokeOpacity=>1,:stroke=>:white)Circle(r=3)
)

draw(plt)
```

Next, we draw the PCA line passing through the data.

```@example 1
lx = [-2.8,4.0]
ly = pcaeq.(lx)
line_pca = S(:stroke=>:grey,:strokeWidth=>2,:strokeDasharray=>5)Line(getscale(plt,:x)(lx),getscale(plt,:y)(ly))

plt_line = plt + line_pca
draw(plt_line)
```

The other plot is the histogram for the error around the PCA fit.
```@example 1
hist = Plot(
    data=df,
    config=(;
        grid=NilD(),
        xaxis=(;ticktexts="",title=""),
        yaxis=NilD(),
        frame=NilD(),
        ),
    x=bindata(df.err),
    y=countbin(df.err),
    h=(value=countbin(df.err),scale=IdScale(),),
    graphic = Hist() + ∑(i=:x) do rows
        S(:fill=>:steelblue)T(rows.x[1],rows.y[1]+10)TextMark(text=rows.h[1])
    end
)

draw(hist)
```

## 3. Combinig the Plots

Our final visualization consists in placing the histogram inside the scatter plot.
To do so, we must scale the histogram so that its size matches the scale in the scatter plot.
Moreover, we need to rotate and translate the histogram. The rotation angle is the
angle for the PCA line, while the translation should be a value large enough so the histogram
falls outside the points in the scatter plot.

```@example 1
# Compute the maximum error from the PCA line
maxerr = findmax(identity,abs.(df.err))[2]
error_width = getscale(plt,:y)(pcaeq(df[maxerr,:x])) - getscale(plt,:y)(df[maxerr,:y])

# Compute the PCA angle
Δx = getscale(plt,:x)(lx)[2] - getscale(plt,:x)(lx)[1] 
Δy = getscale(plt,:y)(ly)[2] - getscale(plt,:y)(ly)[1] 
ang = atan(Δy/Δx)

# Compute the histogram pixel size
hbb= boundingwidth(hist)/2

# Compute the scaling factor so that the histogram
# width matches the error_width width
rel = cos(ang)*error_width/hbb

# Compute where to place the histogram
px = 2.5
py = pcaeq.(px)
px = getscale(plt,:x)(px)
py = getscale(plt,:y)(py)

viz = plt_line + T(px,py)R(-π/2 + ang)U(rel)T(-hbb,0)hist

draw(viz, height=500)
```
