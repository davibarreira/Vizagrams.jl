# Penguins Plot

Let us explore how customized marks can be used in data visualization within Vizagrams.
For this, we will use the famous Palmer Penguins dataset.

```@example 1
using Vizagrams
using PalmerPenguins
using DataFrames
using Statistics

df = DataFrame(PalmerPenguins.load())
df = dropmissing(df);
nothing #hide
```

## 1. Creating our Penguin Mark

First, we create a penguin mark.

```@example 1
struct PenguinBill <: Mark
    bill_length::Real
    bill_depth::Real
end
PenguinBill(;bill_length=40, bill_depth=20) = PenguinBill(bill_length, bill_depth)

function Vizagrams.ζ(p::PenguinBill)::TMark
    (;bill_depth, bill_length) = p
    bill = R(-π/2)U(1/30)Polygon([[-bill_depth,0],[0,bill_length],[bill_depth,0]])
    bill = S(:fill=>:orange)T(0.5,0)*bill
    splash = T(-0.2,0)*QBezierPolygon([[0.2,0],[1,0]],[[1.,1],[0.5,-1]])
    splash = R(π/4)T(-0.1,0.1)S(:fill=>:white)*splash
    eye = T(0.3,0.3)S(:fill=>:orange)Circle(r=0.1) + T(0.3,0.3)Circle(r=0.05)
    return bill + Circle() + splash + eye
end

draw(PenguinBill(),height=200)
```

## 2. A Simple Plot

We start with a simple plot:

```@example 1
plt = plot(df,x=:island,y=:species,graphic = PenguinBill())
draw(plt)
```
The mark is too small and has transparency. Let us fix it:
```@example 1
plt = plot(df;
    x=:island,
    y=:species,
    graphic=Mark(
        U(20)S(:opacity => 1)PenguinBill())
)
draw(plt)
```

This plot is not making use of the parameters specified in the penguin mark. Let us
use them:

```@example 1
plt = plot(df,
    x=:island,
    y=:species,
    color=:species,
    bill_length= (field=:bill_length_mm,scale=IdScale()),
    bill_depth= (field=:bill_depth_mm,scale=IdScale()),
    graphic= ∑(i=:x, ∑(i=:y) do row
        T(row.x[1],row.y[1])U(20)*
        S(:fill=>row.color[1])*
        PenguinBill(
            bill_length=median(row.bill_length),
            bill_depth=median(row.bill_depth)
        )
    end)
)
draw(plt)
```

## 3. More Complex Example

Our previous plot compared penguins in terms of bill length and depth for different species in different islands.
We can modify the specification in order to also compare penguins in terms of `sex`.

```@example 1
plt = plot(df,
    x=:island,
    y=:species,
    sex=(field=:sex,scale=IdScale()),
    color=:species,
    bill_length= (field=:bill_length_mm,scale_range=[10,100],),
    bill_depth= (field=:bill_depth_mm,scale_range=[10,30]),
    
    graphic= ∑(i=:x, ∑(i=:y,orderby=:sex, descend=true, ∑(i=:sex,op=↑) do row
                T(0,-10)*
                T(row.x[1],row.y[1])U(10)*
                S(:fill=>row.color[1])*
                (
                    PenguinBill(bill_length=median(row.bill_length),bill_depth=median(row.bill_depth))
                    ←
                    (T(-0.5,0),S(:fill=>:grey)TextMark(text=row.sex[1],fontsize=0.7,fontfamily="monospace"))
                )
    end
    ))
)
draw(plt,height=500)
```
