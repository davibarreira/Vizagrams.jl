using Vizagrams
using StructArrays

@testset "Helper Functions" begin
    @testset "vconcat" begin
        d1 = StructArray(; x=[1, 2], c=["a", "b"])
        d2 = StructArray(; y=[10, 10, 10], x=[10, 10, 10], z=[1, 1, 1])
        d = vconcat(d1, d2)

        d = vconcat(d1, d2)
        @test d.x == vcat(d1.x, d2.x)
        @test d.c == vcat(d1.c, [nothing, nothing, nothing])
        @test d.y == vcat([nothing, nothing], d2.y)
        @test d.z == vcat([nothing, nothing], d2.z)
    end
end
