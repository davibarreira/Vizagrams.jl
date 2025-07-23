---
title: 'Vizagrams.jl: A Julia-based visualization framework that integrates diagramming and data visualization'
tags:
  - Julia
  - data visualization
  - visualization grammar
  - diagramming
authors:
  - name: Davi Sales Barreira
    orcid: 0000-0002-8005-4118
    corresponding: true
    affiliation: 1
  - name: Asla Medeiros e Sá
    orcid: 0000-0002-3705-9095
    corresponding: false
    affiliation: 2
  - name: Flávio Codeço Coelho
    orcid: 0000-0003-3868-4391
    corresponding: false
    affiliation: 1
affiliations:
 - name: Fundação Getúlio Vargas - School of Applied Mathematics
   index: 1
 - name: IMPA Tech
   index: 2
date: 22 July 2025
bibliography: paper.bib

---

# Summary

Vizagrams.jl is a Julia package that integrates diagramming and data visualization into a single framework.
It implements a diagramming domain-specific language (DSL) together with a visualization grammar,
thus allowing users to create diagrams by combining and transforming plots, as well as to create new visualization
specifications using diagramming operations. The package aims to be able to produce complex,
highly customizable visualizations while also providing intuitive usability.

# Statement of need

A fundamental challenge for every data visualization tool is balancing abstraction and expressiveness.
Expressiveness consists in the ability of a framework to produce a variety of visualizations,
while abstraction consists in simplifying descriptions by omitting details, thus improving usability.
Some tools prioritize high expressiveness at the expense of abstraction (e.g., D3.js [@d3js]),
while others prioritize abstraction over expressiveness by focusing on
ready-to-use chart recipes (e.g., Matplotlib [@Hunter:2007], Seaborn [@Waskom2021],
Makie [@DanischKrumbiegel2021], Plots [@plotsjl]).

A possible solution to this challenge is to use visualization grammars.
These grammars define a structured set of rules for specifying visualizations,
allowing users to construct a wide range of plots by adjusting the components of a specification,
rather than relying on a fixed set of chart types or intricate manual constructions [@mei2018design].

Wilkinson's Grammar of Graphics (GoG) [@wilkinson2012grammar] is one of the most
influential theoretical contributions to visualization grammars,
and has significantly influenced the design of various grammars
[@wickham2007ggplot; @wickham2011ggplot2; @satyanarayan2014vega; @satyanarayan2016vega; @lyi2021gosling;
@pu2020probabilistic; @li2020gotree].
Despite their success, visualization grammars still have limitations in
terms of expressiveness, particularly when dealing with complex visualizations such as those
containing custom marks, composite graphics or intricate layouts.

Vizagrams.jl addresses these limitations by implementing a
novel theoretical framework that integrates diagramming and data visualization.
It does this by creating a visualization grammar over a diagramming DSL,
where plots are treated as graphical objects, and diagramming operations
can be used within graphic specification, thus interweaving both concepts.
Thus, the package is particularly valuable for data scientists, academic researchers,
statisticians and any other user who needs to create complex visualizations
and possesses programming knowledge. Its diagramming capabilities also make it a valuable tool for
educational purposes, such as illustrating mathematical concepts.
Vizagrams.jl has been developed as part of the PhD thesis of the first author [@barreira],
where the theory behind its implementation has been explained in detail.

# Related works

Vizagrams.jl's diagramming DSL was inspired by the work of Yorgey [@yorgey2012monoids],
who provided the theoretical foundation for diagram construction used by the Haskell Diagrams library [@yates2015diagrams].
The Haskell Diagrams library has also inspired other diagramming libraries such as Diagrammar [@granstrom2022diagrammar]
and Compose.jl [@composejl]. There are also diagramming libraries not based on Yorgey's conception,
such as Bluefish [@pollock2023bluefish] and Penrose [@ye2020penrose].

Besides Vizagrams.jl, other packages have used the idea of constructing data visualization tools
on top of diagramming frameworks. For example, the Gadfly.jl [@gadfly] visualization package is
built on the diagramming package Compose.jl [@composejl]. Yet, Gadfly.jl implements
a grammar similar to ggplot2 [@wickham2007ggplot], rather than attempting to integrate
diagramming and data visualization.

When it comes to visualization grammars, Vizagrams.jl implements a graphic
specification based on the one used by Vega-Lite [@satyanarayan2016vega], which is a high-level
visualization grammar built on top of Vega [@satyanarayan2014vega].
The landscape of visualization grammars encompasses low-level implementations that prioritize expressiveness
(e.g., Vega [@satyanarayan2014vega]) and high-level implementations that prioritize user-friendly
specifications (e.g., Vega-Lite [@satyanarayan2016vega], ggplot2 [@wickham2011ggplot2], Polaris [@stolte2002polaris],
Observable Plot [@observable_plot], Atlas [@liu2021atlas]). There are also specialized visualization grammars, such as
Gosling [@lyi2021gosling] for genomics data visualization, GoTree [@li2020gotree] for visualizations with tree layouts,
PGoG [@pu2020probabilistic] for visualizations depicting probabilities.

Besides diagramming and visualization grammars, there are also visualization authoring systems.
These are software platforms or tools that allow users to create visualizations
without the need for programming knowledge. Examples of visualization authoring systems are
Improvise [@improvise], Data Illustrator [@dataillustrator], Charticulator [@charticulator],
and StructGraphics [@structgraphics]. These systems enable users to design and manipulate
custom graphical marks, though they do so within graphical user interfaces rather than
embedded domain-specific languages.

# Overview of functionality

The main features of Vizagrams.jl are:

- Diagramming DSL
- Custom graphical marks
- Visualization grammar for creating data visualizations
- Graphic expressions to create new data visualization specifications
- Ability to manipulate and combine plots using diagramming operations

Diagrams are built by composing graphical marks and applying graphical transformations.
Graphical marks are objects that can be drawn on the screen, while graphical transformations
are actions such as translations, rotations, change of color, and so on.
The package provides a set of ready-to-use marks, such as `Circle`, `Square`, `Line`, `TextMark`,
but users can extend this by creating their own marks.

The main operations for building diagrams are:

- `+` for composing marks and diagrams, e.g., `d1 + d2` creates a new diagram where `d1` is rendered first, followed by `d2`
- `T(x,y)` for translating
- `R(θ)` for rotating
- `U(x)` for uniform scaling
- `M(p)` for reflecting
- `S(:attribute=>value)` for setting style attributes
- `*` for applying transformations, e.g., `T(x,y) * d` translates the diagram `d` by `(x,y)`


The following example shows how to create a simple diagram:
```julia
using Vizagrams

# Composing marks
d = Circle() + T(2,0)*Square()

# Composing previous diagram with a new mark
d = S(:fill=>:white,:stroke=>:black)*Circle(r=2) + Line([[0,0],[3,0]]) + d
draw(d)
```
![A simple diagram.\label{fig:diag}](./figures/diag.pdf){width=50%}

For creating data visualizations, Vizagrams.jl provides a visualization grammar with
a syntax similar to Vega-Lite [@satyanarayan2016vega]. Given a dataset, the user can
create a visualization by mapping columns to visual properties,
and specifying the `graphic` to be used (akin to what Vega-Lite calls `mark`).
This specification is implemented internally
as a mark `Plot`, thus making plots manipulable as any other mark.

Below is an example of a data visualization created with the visualization grammar. We use the
`cars` dataset from the VegaDatasets.jl package together with the DataFrames.jl package [@bouchet2023dataframes].

```julia
using DataFrames
using VegaDatasets
df = DataFrame(dataset("cars"));
df = dropmissing(df);

simple_plot = Plot(
    data=df,
    encodings=(
        x=(field=:Horsepower,),
        y=(field=:Miles_per_Gallon,),
        color=(field=:Origin,),
    ),
    graphic=Circle(r=5)
)
draw(simple_plot)
```
![Scatter plot created with the visualization grammar.\label{fig:simple_plot}](./figures/simple_plot.pdf){width=70%}

One of the ways Vizagrams.jl extends visualization grammars is by allowing the use of
graphic expressions inside the `graphic` component. A graphic expression is a function
that takes a dataset and constructs a diagram using a pattern similar to the split-apply-combine
strategy from Wickham [@wickham2011split]. The following example shows how to use a graphic expression
with our previously created diagram `d`:

```julia
complex_plot = Plot(
    data=df,
    encodings=(
        x=(field=:Horsepower,),
        y=(field=:Miles_per_Gallon,),
        color=(field=:Origin,),
        size=(field=:Weight_in_lbs,),
        rotate=(field=:Acceleration,),
    ),
    graphic=∑() do row
        T(row[:x],row[:y])*
        U(row[:size])*
        S(:fill=>row[:color],:opacity=>0.5)*
        R(row[:rotate])*
        d
    end
)
draw(complex_plot)
```
![Custom scatter plot created with a graphic expression.\label{fig:complex_plot}](./figures/complex_plot.pdf){width=70%}

Lastly, we illustrate how to combine plots using diagramming operations. Since a plot is a mark,
it can be manipulated as any other mark. The following example shows how to combine the two plots
created in the previous examples:

```julia
viz_title = TextMark(text="Showcasing Diagramming Integration",anchor=:c,fontsize=20)
viz_frame = S(:fillOpacity=>0,:stroke=>:black)*T(400,100)*Rectangle(h=370,w=1000)

new_viz = simple_plot + T(470,0)*complex_plot + viz_frame + T(400,250)*viz_title

draw(new_viz)
```
![Combining plots using diagramming operations.\label{fig:new_viz}](./figures/new_viz.pdf){width=100%}

A more detailed overview of the functionality of Vizagrams.jl is provided in the documentation,
where it goes into details about the diagramming DSL, the mark creation process,
the visualization grammar, and the use of graphic expressions.

# References
