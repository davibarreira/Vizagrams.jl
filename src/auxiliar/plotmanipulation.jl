"""
getaxes(plt::Union{PlotSpec, Plot})

Get a vector containing `Axis` type marks inside a `Union{PlotSpec, Plot}`
"""
function getaxes(plt::Union{PlotSpec,Plot})
    return getmark(Union{XAxis,YAxis}, ζ(plt))
end

"""
getaxis(plt::Union{PlotSpec, Plot}, axistype=XAxis)

Get the x-axis in the plot.
"""
function getaxis(plt::Union{PlotSpec,Plot}, axistype)
    axis = getmark(axistype, ζ(plt))
    if length(axis) > 0
        axis[begin].axis
    end
end

"""
getyaxis(plt::Union{PlotSpec, Plot})

Get the y-axis in the plot.
"""
function getyaxis(plt::Union{PlotSpec,Plot})
    return getaxis(plt, YAxis)
end
"""
getxaxis(plt::Union{PlotSpec, Plot})

Get the x-axis in the plot.
"""
function getxaxis(plt::Union{PlotSpec,Plot})
    return getaxis(plt, XAxis)
end

function getaxisscale(plt::Plot, axistype)
    return getaxisscale(plt.spec, axistype)
end
function getaxisscale(plt::PlotSpec, axistype)
    axis = getaxis(plt, axistype)
    if !isnothing(axis)
        return axis.scale
    end
    return Linear(; domain=plt.figsize, codomain=plt.figsize)
end

function getyscale(plt::Union{PlotSpec,Plot})
    return getaxisscale(plt, YAxis)
end
function getxscale(plt::Union{PlotSpec,Plot})
    return getaxisscale(plt, XAxis)
end

# """
# getcolorscale(plt::Union{PlotSpec, Plot}) = getmark(ColorLegend, ζ(plt))[1].scale

# Get the color scale.
# """
# getcolorscale(plt::Union{PlotSpec,Plot}) = getmark(ColorLegend, ζ(plt))[1].scale

# """
# getsizescale(plt::Union{PlotSpec, Plot}) = getmark(SizeLegend, ζ(plt))[1].scale

# Get the size scale.
# """
# getsizescale(plt::Union{PlotSpec,Plot}) = getmark(SizeLegend, ζ(plt))[1].scale
