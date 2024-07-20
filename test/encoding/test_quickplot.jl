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
    # Check if diagram "compiles"
    @test string(draw(plt)) isa String


    # Check if encoding is correct
    @test keys(plt.encodings) == (:y, :x)
    @test map(k -> plt.encodings[k].field, keys(plt.encodings)) == (:_y, :x)

    # Testing other variations
    data = StructArray(x=range(0, 10, 20), y=range(0, 10, 20), z=rand(["a", "b"], 20))
    plt = plot(
        data,
        x=(value=collect(range(0, 20, 20)), datatype=:q),
        y=row -> row.x^2,
        color=(field=:z,),
        size=(value=rand(20),),
    )

    # Check if diagram "compiles"
    @test string(draw(plt)) isa String

    # Check if encoding is correct
    @test keys(plt.encodings) == (:color, :y, :size, :x)
    @test map(k -> plt.encodings[k].field, keys(plt.encodings)) == (:z, :_y, :size, :_x)

    #
    data = StructArray(x=range(0, 10, 20), y=range(0, 10, 20), z=rand(["a", "b"], 20))
    plt = plot(
        data,
        x=(value=collect(range(0, 20, 20)), datatype=:q),
        y=(value=row -> row.x^2,),
        color=(field=:z,),
    )

    # Check if diagram "compiles"
    @test string(draw(plt)) isa String

    # Check if encoding is correct
    @test map(k -> plt.encodings[k].field, keys(plt.encodings)) == (:z, :_y, :_x)
    @test keys(plt.encodings) == (:color, :y, :x)
end

