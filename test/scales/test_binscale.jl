using Vizagrams
using Random

@testset "BinScale" begin
    Random.seed!(4)
    data = rand(100)

    scale = BinScale(; data=data, codomain=[0, 300])
    correct_values = [
        15.0, 15.0, 45.0, 75.0, 105.0, 135.0, 165.0, 195.0, 225.0, 255.0, 285.0
    ]
    @test scale.(0:0.1:1) ≈ correct_values

    correct_values = [
        0.0, 70.0, 105.0, 105.0, 175.0, 227.5, 245.0, 245.0, 105.0, 315.0, 0.0
    ]
    scale = BinScale(length; data=data, codomain=[0, 315])
    @test scale.(0:0.1:1) ≈ correct_values
end
