using Vizagrams
using StructArrays

@testset "Encoding Functions" begin
    # Testing whether the using functions in the encoding works
    data = StructArray(x=range(0, 10, 20), y=range(0, 10, 20))
    plt = plot(
        data,
        x=(field=:x, datatype=:q),
        y=row -> row.x^2
    )
    @test string(draw(plt)) isa String
end

