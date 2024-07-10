struct Frame <: Mark
    size::Tuple{Int,Int}
    s::S
    function Frame(size, s)
        @assert size[1] ≥ 0 "Size must be positive"
        @assert size[2] ≥ 0 "Size must be positive"
        return new(size, s)
    end
end
Frame(; size=(300, 200), s=S()) = Frame(size, s)

function ζ(frame::Frame)::𝕋{Mark}
    return S(
               :fill => :white,
               :stroke => :lightgrey,
               :strokeWidth => 1.5,
               :fillOpacity => 0,
           ) *
           frame.s *
           rectangle([0, 0], [frame.size...])
end
