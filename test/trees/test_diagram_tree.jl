using Test
using Vizagrams

@testset "Diagram Tree" begin
    @testset "dlift" begin
        geom = Rectangle()
        p = Prim(Rectangle())
        v = [Circle(), Rectangle()]
        @test compare_trees(dlift(geom), Pure([Prim(geom)]))
        @test compare_trees(dlift(p), Pure([p]))
        @test compare_trees(dlift([p]), Pure([p]))
        @test compare_trees(dlift([p]), Pure([p]))
        @test compare_trees(dlift(v), Pure(map(Prim, v)))
        @test compare_trees(dlift(dlift(geom)), dlift(geom))
    end
end
