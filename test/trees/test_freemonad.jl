using Vizagrams
import Vizagrams: Pure, FreeComp, FreeAct, unfree, free, compare_structs

@testset "FreeMonad" begin
    @testset "Functor F" begin
        @test fmap(x -> x + 1, Comp(2, 3)) == Comp(3, 4)

        a1 = Act((T(0, 0), S()), 1)
        a2 = Act((T(0, 0), S()), 2)
        @test compare_structs(fmap(x -> x + 1, a1)._1, a2._1)
        @test compare_structs(fmap(x -> x + 1, a1)._2, a2._2)
    end

    @testset "Auxiliary functions" begin
        @test unfree(Pure(1)) == 1
        @test fmap(x -> x + 1, Pure(2)) == Pure(3)
        @test fmap(x -> x + 1, FreeComp(Pure(1), Pure(2))) == FreeComp{Int64}(Pure{Int64}(2), Pure{Int64}(3))
    end

    @testset "Monadic operations" begin
        @test η(2) == Pure(2)
        @test μ(Pure(Pure(2))) == Pure(2)
        @test μ(η(Pure(1))) == Pure(1)
    end
end
