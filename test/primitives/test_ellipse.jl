import Vizagrams: CovEllipse, ϕ, ψ, coordinates, point_on_ellipse

# Test default constructor
@testset "Ellipse Default Constructor" begin
    e = Ellipse()
    @test e.rx == 2
    @test e.ry == 1
    @test e.c == [0, 0]
    @test e.ang == 0
end

# Test custom constructor
@testset "Ellipse Custom Constructor" begin
    e = Ellipse(rx=3, ry=4, c=[1, 2], ang=π/4)
    @test e.rx == 3
    @test e.ry == 4
    @test e.c == [1, 2]
    @test e.ang == π/4
end

# Test CovEllipse to Ellipse mapping
@testset "CovEllipse to Ellipse Mapping" begin
    cov_e = CovEllipse([3, 0], [0, 4], [0, 0])
    e = ψ(cov_e)
    @test e.rx ≈ 3
    @test e.ry ≈ 4
    @test e.c == [0, 0]
    @test e.ang ≈ 0
end

# Test Ellipse to CovEllipse mapping
@testset "Ellipse to CovEllipse Mapping" begin
    e = Ellipse(rx=3, ry=4, c=[1, 2], ang=π/4)
    cov_e = ϕ(e)
    @test cov_e._1 ≈ rotatevec([3, 0], π/4) + [1, 2]
    @test cov_e._2 ≈ rotatevec([0, 4], π/4) + [1, 2]
    @test cov_e._3 == [1, 2]
end

# Test point_on_ellipse function
@testset "Point on Ellipse" begin
    @test point_on_ellipse(0, 3, 4, [1, 2]) == [4, 2]
    @test point_on_ellipse(π, 3, 4, [1, 2]) == [-2, 2]
end