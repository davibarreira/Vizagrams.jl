using Vizagrams
import Vizagrams: MPrim, TM, MTDiagram, ζ, θ, compare_primitives, compare_trees, flatten, FreeComp

@testset "Mark Tree" begin
    @testset "Lifting Marks and Diagrams" begin
        @test mlift(Circle()) isa Vizagrams.MPrim{Circle}

        @test compare_trees(dlift(Circle()), Pure{Vector{Prim}}(Prim[Prim{Circle}(Circle(1, [0, 0]), S(Dict{Any,Any}()))]))
        @test Comp(mlift(Circle()), mlift(Circle())) isa Comp{Mark}
        @test compare_trees(dmlift(Circle()), dmlift(dmlift(Circle())))

        @test mlift(dmlift(Circle())) isa TM
        @test mlift(dlift(Circle())) isa MTDiagram

        @test compare_trees(ζ(mlift(Circle())), Pure{Mark}(MPrim{Circle}(Prim{Circle}(Circle(1, [0, 0]), S(Dict{Any,Any}())))))
    end

    @testset "mlift" begin
        @test mlift(TDiagram) == MTDiagram
        @test mlift(Prim) == MPrim
        @test mlift(Circle) == MPrim{Circle}
        @test compare_trees(dlift(NilD()), dmlift(Prim[]))
    end
    @testset "flatten, θ, ζ" begin
        @test flatten(NilD()) == Prim[]
        @test compare_trees(θ(ζ(Face())), θ(Face()))

        struct MyTestMark <: Mark end
        Vizagrams.ζ(m::MyTestMark)::TMark = dmlift([Circle(), Square()])
        @test all(map(x -> compare_primitives(x[1], x[2]), zip(flatten(MyTestMark()), [Prim(Circle()), Prim(Square())])))

        d = Circle() + Circle()
        @test ζ(mlift(d)) == d

        # test fmap of TM
        @test fmap(x -> 0, d) == FreeComp(Pure(0), Pure(0))

        # test MPrim
        @test compare_primitives(fmap(x -> Square(), mlift(Prim(Circle())))._1, Prim(Square()))
    end

    @testset "Pure" begin
        @test Pure(mlift(Circle())) isa Pure{Mark}
        @test compare_trees(θ(Pure(mlift(Circle()))), Pure{Vector{Prim}}(Prim[Prim{Circle}(Circle(1, [0, 0]), S(Dict{Any,Any}()))]))
    end
end
