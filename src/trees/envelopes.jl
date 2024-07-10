envelope(d::𝕋, v::Vector) = mapreduce(x -> envelope(x, v), fmax, flatten(d); init=nothing)

function boundingbox(d::Mark)
    return boundingbox(dmlift(d))
end
function boundingbox(d::𝕋)
    return boundingbox(flatten(d))
end

"""
rectboundingbox(d::𝕋)

Gets a diagram `d::𝕋` and returns a `𝕋Prim`
of a rectangle consisting in the bounding box
of `d`.


`Style(:fillOpacity => 0, :stroke => :blue) * Prim(Rectangle(boundingbox(d)...))` 
"""
function rectboundingbox(p::Valid, s::S=S(:fillOpacity => 0, :stroke => :blue))
    d = dlift(p)
    bbox = boundingbox(d)
    if isnothing(bbox)
        return S() * NilD()
    end
    return s * rectangle(bbox...)
end
