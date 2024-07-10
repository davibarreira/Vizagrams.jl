struct Face <: Mark
    center::Vector
    size::Real
    eyestyle::S
    headstyle::S
    smile::Real
    smilestyle::S
    function Face(center, size, eyestyle, headstyle, smile, smilestyle)
        @assert -1 ≤ smile ≤ 1 "Smile is a parameter between -1 and 1"
        return new(center, size, eyestyle, headstyle, smile, smilestyle)
    end
end
function Face(; center=[0, 0], size=1, eyestyle=S(), headstyle=S(), smile=0, smilestyle=S())
    return Face(center, size, eyestyle, headstyle, smile, smilestyle)
end

function ζ(face::Face)::𝕋{Mark}
    (; eyestyle, headstyle, smilestyle) = face
    eyestyle = S(:fill => :blue) * eyestyle
    headstyle = S(:fill => :white, :stroke => :black, :opacity => 0.5) * headstyle
    smilestyle = S(:fill => "none") * smilestyle

    S1 = U(5)
    S2 = U(2)

    head = S1 * Prim(Circle())

    T1 = T([2, 2])
    T2 = T([-2, 2])
    T3 = T([0, -1.5])
    eyes = T1 * Prim(Circle()) + T2 * Prim(Circle())

    smile =
        T(0, face.smile) *
        T3 *
        S2 *
        QBezier(; bpts=[[-1.3, 0], [1.3, 0]], cpts=[[0, -face.smile]])

    t = T(face.center)
    s = U(face.size / 5)
    d = (t * s) * (headstyle * head + eyestyle * eyes + smilestyle * smile)
    return d
end
