using Vizagrams

@testset "drawsvg" begin
    @test string(drawsvg(Circle())) isa String
    @test string(drawsvg(CBezier())) isa String
    @test string(drawsvg(QBezier())) isa String
    @test string(drawsvg(Arc())) isa String
    @test string(drawsvg(Rectangle())) isa String
    @test string(drawsvg(Line())) isa String
    @test string(drawsvg(Polygon())) isa String
    @test string(drawsvg(RegularPolygon())) isa String
    @test string(drawsvg(QBezierPolygon())) isa String
    @test string(drawsvg(CBezierPolygon())) isa String
    @test string(drawsvg(Ellipse())) isa String
    @test string(drawsvg(TextGeom(text="ok"))) isa String
end