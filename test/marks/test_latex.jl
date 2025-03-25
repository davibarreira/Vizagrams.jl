using Vizagrams
using LaTeXStrings

@testset "Latex" begin
    anchors = [:c, :s, :n, :e, :w, :se, :sw, :ne, :nw]
    bbox = [
        [-1.563322901725769, -0.6044739683469136],
        [-1.563322901725769, -0.28580729166666663],
        [-1.563322901725769, -1.196473995844523],
        [0.02734375, -0.28580729166666663],
        [-3.221989552179972, -0.28580729166666663],
        [0.02734375, -0.28580729166666663],
        [-3.221989552179972, -0.28580729166666663],
        [0.02734375, -1.196473995844523],
        [-3.221989552179972, -1.196473995844523],
    ]

    t = map(zip(anchors, bbox)) do (a, bb)
        latex = TextMark(; text=L"X+y", anchor=a, fontsize=1)
        Vizagrams.flatten(latex)[1].geom.text == "X"
        Vizagrams.flatten(latex)[3].geom.text == "y"
        Vizagrams.flatten(latex)[2].geom.text == "+"
        @test boundingheight(latex) ≈ 1.2421875
        @test boundingwidth(latex) ≈ 3.221989552179972
        @test all(boundingbox(latex)[1] .≈ bb)
    end
end
