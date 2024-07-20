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


    # Testing other variations
    data = StructArray(x=range(0, 10, 20), y=range(0, 10, 20), z=rand(["a", "b"], 20))
    plt = plot(
        data,
        x=(value=collect(range(0, 20, 20)), datatype=:q),
        y=row -> row.x^2,
        color=(field=:z,),
        size=(value=rand(20),),
    )
    draw(plt)
    @test string(draw(plt)) isa String
end

