# Basics of Diagram Drawing

In this tutorial, we show how Vizagrams can be used to produce diagrams.
We start from a simple example, and gradually present more complex
examples.

## 1. Drawing a simple diagram

The basic building blocks for any diagram are graphical marks and
graphical transformations. We can think of graphical marks as graphical
objects that can be drawn in the screen, while the graphical
transformations are actions such as translations, rotations, change of
color, and so on. Vizagrams provides some ready to use marks, but users
can define their own marks, yet, we leave this topic to another
tutorial.

Let us start with a very simple example:

```@example 1
using Vizagrams
# My first Diagram
d = Circle()

draw(d)
```

In the code above, we simply define a diagram `d` as containing a
`Circle`. Note that this circle has a default radius of `1` and center
`[0,0]`. By calling `draw(d)`, we turn the diagram `d` into an SVG file,
which can then be rendered by the browser. Note that the `draw` also
scales the drawing to fit a specific height. In this case, the default
height is 500. We can pass another height in order to get either a
smaller or larger diagram, or we can use a `pad` to apply some padding
to the output SVG.

```@example 1
d = Circle()
draw(d,height=100, pad=20)
```
## 2. Applying Transformations

Graphical transformations can be either geometric or aesthetic. The
geometric transformations are translations (`T(x,y)`), rotations
(`R(θ)`), uniform scaling (`U(s)`), and reflection (`M(p)`). For aesthetic (stylistic)
transformations, we use `S(attr)`, where `attr` is something like
`:fill=>:red`, which will apply the fill color of red.

The way we apply transformations follows a mathematical notation. We use
`*` to represent the action of applying a transformation to a mark.
Moreover, we can compose transformations also using `*` or by simply
stacking transformations side by side. Let us do some examples to
clarify.

```@example 1
d = Square()
draw(d,height=100)
```

```@example 1
d = R(π/4)*Square()
draw(d,height=100)
```
```@example 1
d = S(:fill=>:red,:stroke=>:blue,:strokeWidth=>2)*Square()
draw(d,height=100)
```
```@example 1
d = S(:fill=>:red,:stroke=>:blue,:strokeWidth=>2)R(π/4)*Square()
draw(d,height=100)
```

## 3. Combining Marks for more complex Diagrams

A diagram with a single graphical mark is not very interesting. We can
construct more complex diagrams by "adding" marks together. The process
of adding marks is akin to drawing a mark one on top of the other,
similar to how in an SVG file we write the tag for a different geometry
one after another.

```@example 1
d = S(:fill=>:blue)Circle() + S(:fill=>:red)RegularPolygon(n=3) +S(:fill=>:green)Square()
draw(d,height=100)
```

We now have the tools to create very complex diagrams, it is just a
matter of adding marks and applying transformations.

```@example 1
d = T(3,0)Circle() + T(0,2)RegularPolygon(n=3) +R(π/10)U(2)Square()
draw(d,height=100)
```

Note also that our `*` operator is distributive, hence, we can apply the
same transformations to several marks at once.

```@example 1
d = S(:fill=>:blue)*(T(3,0)Circle() + T(0,2)RegularPolygon(n=3) +
    R(π/10)U(2)Square()) +
    T(2,-2)S(:stroke=>:red,:strokeWidth=>5)Line([[0,0],[3,0],[3,3]])
draw(d,height=100)
```

## 4. Combining Diagrams

We can combine marks and apply transformations. Similarly, we can
combine previously created diagrams to create new diagrams.

```@example 1
d1 = Circle() + T(2,0)*Circle()
d2 = S(:fill=>:blue)*(T(3,0)Circle() + T(0,2)RegularPolygon(n=3) +R(π/10)U(2)Square())
d  = d1 + T(5,0)R(π/5)*d2

draw(d,height=100)
```

## 5. Stacking Diagrams

The basic geometric transformations are translations, rotations, reflections, and scaling.
Yet, Vizagrams provides some stacking transformations to ease the
process of diagram drawing. The process of stacking consists in placing
two marks one right next to the other given a certain direction. This is
done by computing the envelope (similar to bounding box) of each mark,
and then translating the marks accordingly.

```@example 1
d = Circle() → Circle() ↑ Square()

draw(d,height=100)
```

We can add some spacing between the stacking by passing a tuple
containing the mark and a translation transformation.

```@example 1
d = Circle() → (T(0.5,0),Circle() → (T(0.5,0),Circle()))

draw(d,height=100)
```

One has to pay attention to the parenthesis, as the order matters. Yet,
we can use mapping functions to reduce the clutter. For example, let us
stack several circles side by side with a 0.5 spacing.

```@example 1
d = mapreduce(c->Circle(), (x,y)-> x → (T(0.5,0),y), 1:5)
draw(d,height=100)
```

### 6. Text and LaTeX

Text is also a mark. Hence, we can apply geometric and aesthetic
transformations.

```@example 1
d = S(:fontFamily=>"Futura")TextMark(text="My Text",anchor=:c,fontsize=1)

draw(d,height=100)
```

Let is alter the anchor values to show how it behaves. We draw a cross
around the center of the canvas, in order to make clear how the text
moves.

```@example 1
cross = Line([[-3,0],[3,0]]) + R(π/2)Line([[-3,0],[3,0]])

anchors = [:c, :s, :n, :e, :w, :se, :sw, :ne, :nw]
d = mapreduce(a ->cross + TextMark(text=uppercase("$a"),anchor=a,fontsize=1),
    (x,y)-> x → (T(0.5,0),y),anchors)

draw(d,height=80)
```

Vizagrams also provides the possibility of writing LaTeX. For this, the
user must import `LaTeXStrings`:

```@example 1
using LaTeXStrings
d = S(:fill=>:blue)*
    TextMark(text=L"e^x = \sum^\infty_{i=0}\frac{x^n}{n!} = 1 + x + \frac{x^2}{2} + \cdots")
draw(d,height=100)
```


## 6. A Final Example

We end this tutorial with a fractal diagram.

```@example 1
function sierpinski(n)
    if n == 0
        return Polygon([(1,0), (0,0), (1/2, 1)])
    else
        t = sierpinski(n - 1)
        return U(0.5) * (T(-1/2,0)t + T(0,1)t + T(1/2,0)t)
    end
end

d = sierpinski(5)
draw(d)
```
