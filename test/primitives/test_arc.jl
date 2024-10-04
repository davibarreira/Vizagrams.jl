import Vizagrams: CovArc, ϕ, ψ

# Test creation of Arc with default parameters
@testset "Arc Default Parameters" begin
    arc = Arc()
    @test arc.rx == 1
    @test arc.ry == 1
    @test arc.c == [0, 0]
    @test arc.rot == 0
    @test arc.initangle == 0
    @test arc.finalangle == π / 2
end

# Test creation of Arc with custom parameters
@testset "Arc Custom Parameters" begin
    rx, ry = 2.0, 3.0
    c = [1.0, 1.0]
    rot = π / 4
    initangle = π / 6
    finalangle = π
    arc = Arc(rx=rx, ry=ry, c=c, rot=rot, initangle=initangle, finalangle=finalangle)

    @test arc.rx == rx
    @test arc.ry == ry
    @test arc.c == c
    @test arc.rot == rot
    @test arc.initangle ≈ initangle
    @test arc.finalangle ≈ finalangle
end

# Test Arc with invalid parameters
@testset "Arc Invalid Parameters" begin
    @test_throws AssertionError Arc(-1, 1, [0, 0], 0, 0, π / 2)
    @test_throws AssertionError Arc(1, -1, [0, 0], 0, 0, π / 2)
end

# Test Arc finalangle adjustment
@testset "Arc Final Angle Adjustment" begin
    arc = Arc(1, 1, [0, 0], 0, 0, 2π)
    @test arc.finalangle ≈ 2π
end

# Test conversion between Arc and CovArc
@testset "Arc and CovArc Conversion" begin
    arc = Arc(2.0, 3.0, [1.0, 1.0], π / 4, π / 6, π)
    covarc = ϕ(arc)
    arc_converted = ψ(covarc)

    @test arc.rx ≈ arc_converted.rx
    @test arc.ry ≈ arc_converted.ry
    @test arc.c ≈ arc_converted.c
    @test arc.rot ≈ arc_converted.rot
    @test arc.initangle ≈ arc_converted.initangle
    @test arc.finalangle ≈ arc_converted.finalangle


    # For negative angles
    arc = Arc(c=[0, 0], rx=2, ry=1.0, initangle=-π / 4, finalangle=π + π / 4, rot=0π / 4)
    covarc = ϕ(arc)
    arc_converted = ψ(covarc)
    @test arc.rx ≈ arc_converted.rx
    @test arc.ry ≈ arc_converted.ry
    @test arc.c ≈ arc_converted.c
    @test arc.rot ≈ arc_converted.rot
    @test arc.initangle ≈ arc_converted.initangle
    @test arc.finalangle ≈ arc_converted.finalangle

    arc = Arc(c=[0, 0], rx=1, ry=1.0, initangle=-π / 4, finalangle=-π + π / 4, rot=0π / 4)
    covarc = ϕ(arc)
    arc_converted = ψ(covarc)
    @test arc.rx ≈ arc_converted.rx
    @test arc.ry ≈ arc_converted.ry
    @test arc.c ≈ arc_converted.c
    @test arc.rot ≈ arc_converted.rot
    @test arc.initangle ≈ arc_converted.initangle
    @test arc.finalangle ≈ arc_converted.finalangle
end
