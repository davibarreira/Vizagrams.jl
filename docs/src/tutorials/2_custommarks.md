# Working with Graphical Marks

In Vizagrams, every drawing is, in final analysis, just a collection of
graphical primitives. These primitives are geometric shapes such as
circles, lines, polygons, and so on. A graphical mark is a subtype of
the abstract type `Mark` for which there exists a function that turns it
into a diagram, in other words, a mark is a data type for which we can
represent as a diagram.

Note that, according to this definition, every primitive shape is itself
a mark, since the output diagram is just themselves. Hence, when we
define a diagram using primitives, this is equivalent to be using marks.

## 1. Introducing Existing Marks

Vizagrams already comes with several graphical marks ready to use. Some
of these graphical marks are just the primitive geometric shapes such as
circles, lines, polygons, Bezier curves, while others are more complex,
such as arrows, faces, and so on.

Let us start by listing all the available marks that come with
Vizagrams. Some of them are used internally, hence one does not need to
worry about it.

```@example 1
using Vizagrams
using InteractiveUtils
subtypes(Mark)
```

Note that many of the existing marks involve data visualization
components, such as ticks, axes, legen and so on. We are not going to
use them now, as our goal is not to introduce the data visualization
aspects of Vizagram. Let us instead start with some simpler examples:

```@example 1
d = Arrow()

draw(d, height=100)
```

When we draw an instance of `Arrow`, we are drawing a line together with
a triangle. The advantage of encapsulating into a mark is that we can
specify how to parametrize in order to get the desired behavior. This
becomes clearer in the next example:

```@example 1
d = Face() →
    Face(eyestyle=S(:fill=>:red)) →
    Face(smile=1) →
    Face(smilestyle=S(:strokeDasharray=>2),smile=-1) →
    Face(headstyle=S(:fill=>:grey))
draw(d, height=100)
```

Note that the mark `Face` has parameters that allows us to modify some
of its features, but not everything. The overall "shape" of the face is
kept.

We can combine different marks in the same diagram.

```@example 1
angles = 0:π/10:π
d = Face(smile=0.5) +
    mapreduce(a->R(a)Arrow(pts=[[1,0],[2,0]],headsize=a/10),+, angles) +
    S(:fill=>:grey)T(0,-1.5)*Rectangle(h=1,w=2)

draw(d,height=200)
```

## 2. Creating Custom Marks

Besides the marks provided in Vizagrams, users can create their own
marks and use them to create diagrams. The process of mark creation can
be divided in two steps. First, the user must create a new data type and
make it a subtype of `Mark`, which is the abstract type provided by
Vizagrams. Secondly, the user must define a function `ζ`
(`\zeta`). This `ζ` function is the one responsible for turning
the new mark into a diagram.

```@example 1
import Vizagrams: ζ

struct Tree <: Mark
    h #parameter that specifies the height of the tree
end
Tree(;h=2) = Tree(h)

# Specifying how to draw a tree
function ζ(tree::Tree)
    # grabbing the height for the tree
    height = tree.h

    # defining a diagram for the trunk
    trunk = S(:fill=>:brown)T(0,height/2)*Rectangle(h=height,w=0.5)

    # drawing the leaves
    angles = collect(0:0.7:2π)
    leaves = S(:fill=>:green)*(
        Circle(r=0.5)+
        mapreduce(x->T(cos(x)*(0.5),sin(x)*(0.5))Circle(r=0.3),+,angles)
        )
    
    # combining the trunk and the leaves to draw the tree
    return trunk + T(0,height)leaves
end

d = Tree(h=2) → Tree(h=4)
draw(d)
```


The power of creating marks is that we can now use them to create other
marks. Hence, we can gradually increase the complixity of our marks. Let
us use our tree mark to define a forest.

```@example 1
using Random

struct Forest <: Mark
    n
end

Forest(;n=2) = Forest(n)
function ζ(m::Forest)
    Random.seed!(4)
    n = m.n
    pos = 2 .* rand(n,2).-1
    pos = pos[sortperm(pos[:,2],rev=true),:]
    trees = mapreduce(x->T(x...)U(0.1)*Tree(),+, eachrow(pos))
    return trees+S(:fillOpacity=>0.1)*(Square(l=2.5))

end

draw(Forest(50))
```

