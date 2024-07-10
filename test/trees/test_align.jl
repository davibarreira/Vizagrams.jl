using Test
using Vizagrams
import Vizagrams: compare_structs, flatten
using CoordinateTransformations

@testset "Align" begin
    @testset "align_transform" begin
        d1 = dlift(Prim[])
        d2 = dlift(Prim[])
        v = [1, 0]
        g = G(IdentityTransformation())
        @test align_transform(d1, d2, v) == g

        d1 = dlift(Circle())
        d2 = dlift(Circle(c=[2, 2]))

        t = align_transform(d1, d2, [1, 0])
        @test t.g.translation == Translation(-2.0, -0.0).translation
    end

    # @testset "align" begin
    #     d1 = TDiagram()
    #     d2 = TDiagram()
    #     v = [1, 2]
    #     g = G(IdentityTransformation())
    #     h = G(IdentityTransformation())
    #     expected = d1 + d2
    #     @test align(d1, d2, v, g, h) == expected
    # end

    @testset "acenter" begin
        d1 = dlift(Square())
        d2 = dlift(Circle(c=[2, 2]))
        d = d1 + acenter(d1, d2) * d2
        @test flatten(d)[2].geom.c == [0.0, 2.0]
    end

    @testset "amiddle" begin
        d1 = dlift(Square())
        d2 = dlift(Circle(c=[2, 2]))
        d = d1 + amiddle(d1, d2) * d2
        @test flatten(d)[2].geom.c == [2.0, 0.0]
    end

    @testset "aright" begin
        d1 = dlift(Square())
        d2 = dlift(Circle(c=[2, 2]))
        d = d1 + aright(d1, d2) * d2
        @test flatten(d)[2].geom.c == [-0.5, 2.0]
    end

    @testset "aleft" begin
        d1 = dlift(Square())
        d2 = dlift(Circle(c=[2, 2]))
        d = d1 + aleft(d1, d2) * d2
        @test flatten(d)[2].geom.c == [0.5, 2.0]
    end

    @testset "atop" begin
        d1 = dlift(Square())
        d2 = dlift(Circle(c=[2, 2]))
        d = d1 + atop(d1, d2) * d2
        @test flatten(d)[2].geom.c == [2.0, -0.5]
    end

    @testset "abottom" begin
        d1 = dlift(Square())
        d2 = dlift(Circle(c=[2, 2]))
        d = d1 + abottom(d1, d2) * d2
        @test flatten(d)[2].geom.c == [2.0, 0.5]
    end
end
