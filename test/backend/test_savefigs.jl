using Vizagrams

@testset "savefig" begin
    d = U(1)S(:stroke=>:red,:strokeWidth=>10)Circle(r=1)
    
    @testset "SVG output" begin
        mktempdir() do dir
            filename = joinpath(dir, "test.svg")
            savefig(d, filename=filename)
            @test isfile(filename)
            content = read(filename, String)
            @test occursin("vector-effect: non-scaling-stroke", content)
            @test occursin("stroke: red", content)
        end
    end
    
    @testset "PDF output" begin
        mktempdir() do dir
            filename = joinpath(dir, "test.pdf")
            savefig(d, filename=filename)
            @test isfile(filename)
        end
    end
    
    @testset "PNG output" begin
        mktempdir() do dir
            filename = joinpath(dir, "test.png")
            savefig(d, filename=filename)
            @test isfile(filename)
        end
    end
end