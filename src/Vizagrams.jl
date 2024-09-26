module Vizagrams

using Accessors: Accessors, PropertyLens, insert, set, @set, @delete
using Colors: Color, Colorant, hex, RGB
using ColorSchemes: ColorSchemes, ColorScheme, colorschemes
using CoordinateTransformations:
    CoordinateTransformations,
    IdentityTransformation,
    LinearMap,
    Transformation,
    Translation

using FreeTypeAbstraction

using Hyperscript: Hyperscript, Style, m
using Librsvg_jll: Librsvg_jll, rsvg_convert
using LinearAlgebra: LinearAlgebra, UniformScaling, dot, norm, normalize, ⋅, Diagonal
using MLStyle: MLStyle, @data, @match
using Memoize: @memoize
using NamedTupleTools: NamedTupleTools
using Query: Query, @groupby, @map, @orderby, @orderby_descending, key
using Requires: Requires, @require
using Rotations: Rotations, RotMatrix
using Showoff: Showoff, showoff
using Statistics: Statistics, mean
using StructArrays: StructArrays, StructArray, StructVector
using Tables: Tables
using Transducers: Transducers, Consecutive, Map, Partition, Scan
using StatsBase
using PooledArrays

using LaTeXStrings
using MathTeXEngine
using UUIDs

using RelocatableFolders
const FONTS = @path joinpath(@__DIR__, "..", "assets", "fonts")

include("auxiliar/auxiliary_geometric_functions.jl")
export uniformscaling, U, R, T, M, angle_between_vectors
include("auxiliar/generate_ticks_ext_wilkinson.jl")
export generate_tick_labels
include("auxiliar/helperfunctions.jl")
export getnested, setfields, insertcol, getcols, getcol, ⊗, hconcat, vconcat

# PRIMITIVES
include("primitives/graphical_primitives.jl")
export Prim, S, act, GeometricPrimitive, ⋄, neutral, rotatevec, G, H

include("primitives/circle.jl")
include("primitives/square.jl")
include("primitives/rectangle.jl")
include("primitives/line.jl")
include("primitives/ellipse.jl")
include("primitives/arc.jl")
export intersects
include("primitives/bezier.jl")
include("primitives/polygon.jl")
include("primitives/text.jl")
include("primitives/slice.jl")
include("primitives/gradient.jl")

include("primitives/envelopes.jl")
export Circle, Square, Rectangle, Line, Polygon, Ellipse, Arc
export RegularPolygon, TextGeom, Bezier, QBezier, CBezier
export QBezierPolygon, CBezierPolygon, Slice, LinearAlgebra

# Free Monad Diagram Structure
include("trees/freemonad.jl")
include("trees/diagram_tree.jl")
include("trees/mark_tree.jl")
export Act, Comp, cata, mcata, dtreeθ
export θ, ζ, dlift, mlift, dmlift, flatten, fmap, NilD
export Mark, 𝕋, μ, η, TMark, TDiagram, Diagram
include("trees/operations.jl")
export ←, →, ↑, ↓, bleft, bright, btop, bbottom, ▷
include("trees/align.jl")
export aleft, aright, abottom, atop, acenter, amiddle, align_transform

include("trees/envelopes.jl")
export rectboundingbox, boundingbox, envelope, boundingwidth, boundingheight

include("trees/patterns.jl")
export hcheckers, vcheckers

include("encoding/graphicalexpression.jl")
export GraphicExpression, ∑

include("scales/scales.jl")

# Marks
include("marks/textmark.jl")
include("marks/title.jl")
include("marks/area.jl")
include("marks/arrow.jl")
include("marks/frame.jl")
include("marks/bar.jl")

include("marks/ticks.jl")
include("marks/axes.jl")
include("marks/face.jl")

include("encoding/inferencodings.jl")

include("marks/spec.jl")
export Spec
export graphic
# include("marks/plotspec.jl")
include("marks/plot.jl")

include("marks/legend.jl")
include("marks/legends.jl")
include("marks/grid.jl")
include("marks/pizza.jl")
include("marks/latex.jl")
include("marks/trail.jl")
include("marks/histogram.jl")
export countbin, bindata, bin_edges

include("marks/boxplot.jl")
export Area,
    Arrow,
    Axis,
    Bar,
    BoxPlot,
    Categorical,
    Face,
    Frame,
    Grid,
    Hist,
    IdScale,
    LaTeX,
    Legend,
    Linear,
    Pizza,
    Plot,
    Scale,
    TextMark,
    Tick,
    Title,
    Trail,
    XAxis,
    YAxis

include("scales/binscale.jl")
export BinScale

# Backends
include("backends/svgbackend.jl")
include("backends/svgslice.jl")
export drawsvg, tosvg
include("backends/camelfunctions.jl")
export style_string_to_dict
include("backends/savefigs.jl")
export savesvg, savefig

include("backends/draw.jl")
export draw

include("auxiliar/treemanipulation.jl")
export getmark,
    applytomark, replacemark, insertgs, listmarks, modifymark, getmarkpath, unzip

include("auxiliar/zetareduction.jl")
export ζreduction

include("scales/inferscales.jl")
export infer_scale

include("scales/getscales.jl")
export getscales, scaledata, getscale

include("axes/inferaxis.jl")

include("axes/axis.jl")
include("axes/xaxis.jl")
include("axes/yaxis.jl")
include("axes/raxis.jl")
include("axes/angleaxis.jl")
# include("axes/arcaxis.jl")
export inferxaxis, inferyaxis, inferraxis, inferangleaxis

include("encoding/encoding.jl")
export scatter, lineplot

include("encoding/quickplot.jl")
export plot

include("auxiliar/draw_tree_diagram.jl")
export treediagram, fix_treediagram

include("auxiliar/normalize.jl")
export centralize_graphic, normalize_graphic

include("auxiliar/testing.jl")

include("interactive/draw_interactive.jl")
export idraw

include("scales/applyscales.jl")
export applyscales

include("encoding/context.jl")

include("encoding/appendplot.jl")
export replot

end
