using Vizagrams
import Vizagrams: beside_transform, flatten, compare_trees, compare_primitives

@testset "Tree Operations" begin
    @testset "Addition" begin
        @test all(map(x -> compare_primitives(x[1], x[2]), zip(flatten(Circle() + Circle()), map(Prim, [Circle(), Circle()]))))
    end
    # @testset "Addition" begin
    #     p1 = Valid()
    #     p2 = Valid()
    #     result = p1 + p2
    #     @test typeof(result) == FreeComp
    # end

    @testset "Multiplication" begin
        @test compare_primitives(flatten(S() * Circle())[1], Prim(Circle()))
        @test compare_primitives(flatten(T(1, 1) * Circle())[1], Prim(Circle(c=[1, 1])))
        @test compare_structs(T(0, 0) * S(), (T(0, 0), S(Dict{Any,Any}())))
        @test compare_structs(T(0, 0) * T(0, 0), (T(0, 0), S(Dict{Any,Any}())))
        @test compare_structs(S() * T(0, 0), (T(0, 0), S(Dict{Any,Any}())))
        @test compare_structs(S() * S() * T(0, 0), (T(0, 0), S(Dict{Any,Any}())))
    end
    @testset "Beside" begin
        @test compare_structs(beside_transform(dmlift(Circle()), dmlift(Square()), [1, 0]), T(1.5, 0.0) * S())
        @test all(map(x -> compare_primitives(x[1], x[2]), zip(flatten(Circle() → Square()), map(Prim, [Circle(1.0, [0.0, 0.0]), Square(1.0, [1.5, 0.0], 0.0)]))))
        @test all(map(x -> compare_primitives(x[1], x[2]), zip(flatten(Circle() ← Square()), map(Prim, [Circle(1.0, [0.0, 0.0]), Square(1.0, [-1.5, 0.0], 0.0)]))))
        @test all(map(x -> compare_primitives(x[1], x[2]), zip(flatten(Circle()↑Square()), map(Prim, [Circle(1.0, [0.0, 0.0]), Square(1.0, [0.0, 1.5], 0.0)]))))
        @test all(map(x -> compare_primitives(x[1], x[2]), zip(flatten(Circle()↓Square()), map(Prim, [Circle(1.0, [0.0, 0.0]), Square(1.0, [0.0, -1.5], 0.0)]))))
        @test compare_structs(bright(Circle(), Square()), T(1.5, 0.0) * S())

        c = Circle(r=1.0, c=[0.0, 0.0])
        d1 = c → (T(1, 0), c)
        d2 = c + T(3, 0) * c
        d3 = c + T(1, 0)bright(c, c) * c
        @test compare_trees(d1, d2)
        @test compare_trees(d1, d3)

        d1 = c ← (T(1, 0), c)
        d2 = c + T(-1, 0) * c
        d3 = c + T(1, 0)bleft(c, c) * c
        @test compare_trees(d1, d2)
        @test compare_trees(d1, d3)

        d1 = c↑(T(1, 0), c)
        d2 = c + T(1, 2) * c
        d3 = c + T(1, 0)btop(c, c) * c
        @test compare_trees(d1, d2)
        @test compare_trees(d1, d3)

        d1 = c↓(T(1, 0), c)
        d2 = c + T(1, -2) * c
        d3 = c + T(1, 0)bbottom(c, c) * c
        @test compare_trees(d1, d2)
        @test compare_trees(d1, d3)
    end
    # @testset "Multiplication" begin
    #     ts = H()
    #     d = Valid()
    #     result1 = ts * d
    #     result2 = ts * (ts ⋄ d)
    #     @test typeof(result1) == FreeAct
    #     @test typeof(result2) == FreeAct
    # end

    # @testset "Composition" begin
    #     t1 = G()
    #     t2 = G()
    #     s1 = S()
    #     s2 = S()
    #     result1 = t1 * t2
    #     result2 = s1 * s2
    #     @test typeof(result1) == Tuple{G,G}
    #     @test typeof(result2) == Tuple{S,S}
    # end

    # @testset "Transformation" begin
    #     s1 = S()
    #     s2 = S()
    #     d = Valid()
    #     result1 = s1 ▷ s2
    #     result2 = s1 ▷ d
    #     @test typeof(result1) == S
    #     @test typeof(result2) == S
    # end

    # @testset "Beside" begin
    #     d1 = 𝕋()
    #     d2 = 𝕋()
    #     v = [1, 0]
    #     result = beside(d1, d2, v)
    #     @test typeof(result) == 𝕋
    # end

    # @testset "Beside Transform" begin
    #     d1 = 𝕋()
    #     d2 = 𝕋()
    #     v = [1, 0]
    #     result = beside_transform(d1, d2, v)
    #     @test typeof(result) == Tuple{<:G,S}
    # end

    # @testset "Arrows" begin
    #     d1 = Valid()
    #     d2 = Valid()
    #     result1 = d1 → d2
    #     result2 = d1 ← d2
    #     result3 = d1↑d2
    #     result4 = d1↓d2
    #     @test typeof(result1) == 𝕋
    #     @test typeof(result2) == 𝕋
    #     @test typeof(result3) == 𝕋
    #     @test typeof(result4) == 𝕋
    # end

    # @testset "Arrow Composition" begin
    #     d1 = Tuple{G,Valid}(G(), Valid())
    #     d2 = Tuple{G,Valid}(G(), Valid())
    #     result1 = d1 → d2
    #     result2 = d1 ← d2
    #     result3 = d1↑d2
    #     result4 = d1↓d2
    #     @test typeof(result1) == 𝕋
    #     @test typeof(result2) == 𝕋
    #     @test typeof(result3) == 𝕋
    #     @test typeof(result4) == 𝕋
    # end

    # @testset "Arrow Composition with Transformation" begin
    #     d1 = Valid()
    #     d2 = Tuple{G,Valid}(G(), Valid())
    #     result1 = d1 → d2
    #     result2 = d1 ← d2
    #     result3 = d1↑d2
    #     result4 = d1↓d2
    #     @test typeof(result1) == 𝕋
    #     @test typeof(result2) == 𝕋
    #     @test typeof(result3) == 𝕋
    #     @test typeof(result4) == 𝕋
    # end

    # @testset "Bright and Bleft" begin
    #     d1 = Valid()
    #     d2 = Valid()
    #     result1 = bright(d1, d2)
    #     result2 = bleft(d1, d2)
    #     @test typeof(result1) == Tuple{<:G,S}
    #     @test typeof(result2) == Tuple{<:G,S}
    # end

    # @testset "Bright and Bleft with Transformation" begin
    #     d1 = Tuple{G,Valid}(G(), Valid())
    #     d2 = Tuple{G,Valid}(G(), Valid())
    #     result1 = bright(d1, d2)
    #     result2 = bleft(d1, d2)
    #     @test typeof(result1) == Tuple{<:G,S}
    #     @test typeof(result2) == Tuple{<:G,S}
    # end

    # @testset "Btop and Bbottom" begin
    #     d1 = Valid()
    #     d2 = Valid()
    #     result1 = btop(d1, d2)
    #     result2 = bbottom(d1, d2)
    #     @test typeof(result1) == Tuple{<:G,S}
    #     @test typeof(result2) == Tuple{<:G,S}
    # end

    # @testset "Btop and Bbottom with Transformation" begin
    #     d1 = Tuple{G,Valid}(G(), Valid())
    #     d2 = Tuple{G,Valid}(G(), Valid())
    #     result1 = btop(d1, d2)
    #     result2 = bbottom(d1, d2)
    #     @test typeof(result1) == Tuple{<:G,S}
    #     @test typeof(result2) == Tuple{<:G,S}
    # end

    # @testset "Bright and Bleft with Valid" begin
    #     d1 = Valid()
    #     d2 = Tuple{G,Valid}(G(), Valid())
    #     result1 = bright(d1, d2)
    #     result2 = bleft(d1, d2)
    #     @test typeof(result1) == Tuple{<:G,S}
    #     @test typeof(result2) == Tuple{<:G,S}
    # end

    # @testset "Btop and Bbottom with Valid" begin
    #     d1 = Valid()
    #     d2 = Tuple{G,Valid}(G(), Valid())
    #     result1 = btop(d1, d2)
    #     result2 = bbottom(d1, d2)
    #     @test typeof(result1) == Tuple{<:G,S}
    #     @test typeof(result2) == Tuple{<:G,S}
    # end

    # @testset "Bright and Bleft with Transformation" begin
    #     d1 = Tuple{G,Valid}(G(), Valid())
    #     d2 = Valid()
    #     result1 = bright(d1, d2)
    #     result2 = bleft(d1, d2)
    #     @test typeof(result1) == Tuple{<:G,S}
    #     @test typeof(result2) == Tuple{<:G,S}
    # end

    # @testset "Btop and Bbottom with Transformation" begin
    #     d1 = Tuple{G,Valid}(G(), Valid())
    #     d2 = Valid()
    #     result1 = btop(d1, d2)
    #     result2 = bbottom(d1, d2)
    #     @test typeof(result1) == Tuple{<:G,S}
    #     @test typeof(result2) == Tuple{<:G,S}
    # end

    # @testset "Bright and Bleft with Valid and Transformation" begin
    #     d1 = Tuple{G,Valid}(G(), Valid())
    #     d2 = Tuple{G,Valid}(G(), Valid())
    #     result1 = bright(d1, d2)
    #     result2 = bleft(d1, d2)
    #     @test typeof(result1) == Tuple{<:G,S}
    #     @test typeof(result2) == Tuple{<:G,S}
    # end

    # @testset "Btop and Bbottom with Valid and Transformation" begin
    #     d1 = Tuple{G,Valid}(G(), Valid())
    #     d2 = Tuple{G,Valid}(G(), Valid())
    #     result1 = btop(d1, d2)
    #     result2 = bbottom(d1, d2)
    #     @test typeof(result1) == Tuple{<:G,S}
    #     @test typeof(result2) == Tuple{<:G,S}
    # end
end
