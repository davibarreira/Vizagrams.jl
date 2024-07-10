# alg_depth(m::Act; sep=1.0) = 1.0 + m._2
# alg_depth(m::Comp; sep=1.0) = 1.0 + sep * max(m._1, m._2)

# """
# dtreedepth(d::TMark) = cata(alg_depth, d)

# Computes the depths of a tree where each
# `Act` and `Comp` increase the depth by 1.
# """
# dtreedepth(d::𝕋; sep=1.0) = cata(x -> alg_depth(x; sep=sep), fmap(x -> 1.0, d))
# dtreedepth(d::Mark; sep=1.0) = 1.0

function treediagram(m::Act)
    ttext = get(m._1[2].d, :text, "g")
    fsize = get(m._1[2].d, :fontsize, 0.5)
    t = TextMark(; text=ttext, fontsize=fsize, fontfamily="monospace")
    act = (t↓(T(0, -0.5), Arrow(; pts=[[0, 0], [0, -0.4]])))↓(T(0, -0.5), m._2)
    return mlift(act)
end

function treediagram(m::Comp)
    comp = S(:fill => :white, :stroke => :black)Circle(; r=0.3)
    mright = T(3, -2) * bright(m._1, m._2) * m._2
    mleft = T(0, -2) * m._1
    marks = mright + mleft + rectboundingbox(mright) + rectboundingbox(mleft)
    tcenter = acenter(comp, mleft + mright)
    mright = tcenter * mright
    mleft = tcenter * mleft

    bb = boundingbox(mleft)
    wl = [(bb[1][1] + bb[2][1]) / 2, bb[2][2]]
    pos = [wl[1] + 1, -1]
    a = Arrow(; pts=[[0, 0], pos])
    g = bbottom(comp, (T(-0.5, 0), a))
    arrowleft = g * a

    bb = boundingbox(mright)
    wr = [(bb[1][1] + bb[2][1]) / 2, bb[2][2]]
    pos = [wr[1] - 1, -1]
    a = Arrow(; pts=[[0, 0], pos])
    g = bbottom(comp, (T(+0.5, 0), a))
    arrowright = g * a

    comptree = comp + mleft + mright + arrowleft + arrowright
    return mlift(comptree)
end

function boundingheight(d)
    bb = boundingbox(d)
    return bb[2][2] - bb[1][2]
end
function boundingwidth(d)
    bb = boundingbox(d)
    return bb[2][1] - bb[1][1]
end
function treediagram_rename(m::Mark)
    bb = boundingbox(dmlift(m))
    if isnothing(bb)
        # return mlift(NilD())
        return mlift(S(:opacity => 0) * Circle(; r=0.5))
    end
    h, w = boundingheight(dmlift(m)), boundingwidth(dmlift(m))
    center = bb[2][1] + bb[1][1]
    middle = bb[2][2] + bb[1][2]
    if m isa TextMark
        return mlift(U(m.fontsize / 180) * T(-center / 2, -middle / 2) * m)
    end
    return mlift(U(1 / max(w, h)) * T(-center / 2, -middle / 2) * m)
end

"""
treediagram(d::TMark)
Draws the diagram tree as a tree diagram, e.g.
```
       ∘
     ↙   ↘
    g     s
   ↙ ↘    ↓
  m1  n   m2
```
"""
treediagram(d::TMark) = cata(treediagram, fmap(treediagram_rename, d))
treediagram(d::Mark) = treediagram(dmlift(d))

# --------------------------------------------------------- #

function fix_treediagram(m::Act)
    ttext = get(m._1[2].d, :text, "g")
    fsize = get(m._1[2].d, :fontsize, 0.5)
    t = TextMark(; text=ttext, fontsize=fsize, fontfamily="monospace")
    act = (t↓(T(0, -0.5), Arrow(; pts=[[0, 0], [0, -0.4]])))↓(T(0, -0.5), m._2)
    return mlift(act)
end

function fix_treediagram(m::Comp)
    comp = S(:fill => :white, :stroke => :black)Circle(; r=0.3)
    pos = [-1, -1]
    t1 = T(2, -2)
    t2 = T(-2, -2)
    a = Arrow(; pts=[[0, 0], pos])
    g = bbottom(comp, (T(-0.5, 0), a))
    comptree = comp + g * a + M(π / 2) * g * a + t1 * m._2 + t2 * m._1
    return mlift(comptree)
end

"""
fix_treediagram(d::TMark)
Draws the diagram tree as a tree diagram, e.g.
```
       ∘
     ↙   ↘
    g     s
   ↙ ↘    ↓
  m1  n   m2
```
"""
fix_treediagram(d::TMark) = cata(fix_treediagram, fmap(treediagram_rename, d))
