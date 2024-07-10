abstract type Scale end

struct IdScale <: Scale
    domain
    codomain
    function IdScale(domain, codomain)
        @assert domain == codomain "Domain and codomain must be equal"
        return new(domain, codomain)
    end
end
IdScale(domain=nothing) = IdScale(domain, domain)
function (scale::IdScale)(x)
    return x
end

struct GenericScale <: Scale
    f::Function
    domain
    codomain
end
GenericScale(f::Function) = GenericScale(f, nothing, nothing)

struct Linear{D,R} <: Scale
    domain::D
    codomain::R
end
Linear(; domain=(0, 100), codomain=(0, 100)) = Linear(domain, codomain)

struct Categorical{D,R} <: Scale
    domain::D
    codomain::R
end
Categorical(; domain=["a", "b", "c"], codomain=[0, 100]) = Categorical(domain, codomain)

# COLORSCALES are those where the codomain is either a Symbol of Tuple of Symbols

function gethexcolor(cs::ColorScheme, x::Real, domain::Tuple)
    return "#" * hex(get(cs, x, domain))
end
function gethexcolor(cs::ColorScheme, x::Real, domain::Vector)
    return gethexcolor(cs, x, tuple(domain...))
end
function gethexcolor(cs::ColorScheme, x::Nothing, domain::Tuple)
    return "#00000000"
end

function applyscale(x, scale::Linear)
    (; domain, codomain) = scale

    # Changing here the beahaviour for Linear scaling
    # x = max(min(x, maximum(domain)), minimum(domain))

    # Calculate the interpolation
    domain_span = domain[2] - domain[1]
    range_span = codomain[2] - codomain[1]

    if domain_span == 0
        # Avoid division by zero if the domain is a single point
        return codomain[1]
    end

    # Perform linear interpolation
    scaled_value = codomain[1] + ((x - domain[1]) / domain_span) * range_span
    return scaled_value
end

"""
inverse(scale::Linear, y)

Computes the inverse of the linear scale.
"""
function inverse(scale::Linear, y)
    (; domain, codomain) = scale

    # Swap domain and codomain for the inverse operation
    domain, codomain = codomain, domain

    # Calculate the interpolation
    domain_span = domain[2] - domain[1]
    range_span = codomain[2] - codomain[1]

    if range_span == 0
        # Avoid division by zero if the range is a single point
        return domain[1]
    end

    # Perform inverse linear interpolation
    scaled_value = domain[1] + ((y - codomain[1]) / range_span) * domain_span
    return scaled_value
end

# COLOR
function applyscale(x, scale::Linear{<:Union{Tuple,Vector},Symbol})
    (; domain, codomain) = scale
    cs = colorschemes[codomain]
    return gethexcolor(cs, x, domain)
end

# COLOR
function applyscale(x, scale::Linear{<:Union{Vector,Tuple},Tuple{Symbol,Symbol}})
    (; domain, codomain) = scale
    color1 = parse(Colorant, codomain[1])
    color2 = parse(Colorant, codomain[2])
    cs = ColorScheme(range(color1, color2; length=100))
    return gethexcolor(cs, x, domain)
end

function (scale::Linear)(x::Number)
    return applyscale(x, scale)
end

function (scale::Linear)(x::Vector)
    return scale.(x)
end

function applyscale(x, scale::Categorical{<:Vector,<:Tuple{<:Real,<:Real}})
    (; domain, codomain) = scale

    index = findfirst(isequal(x), domain)
    if isnothing(index)
        return nothing
    end

    # Calculate the interpolation
    n = length(domain)
    range_span = codomain[2] - codomain[1]

    if n == 0
        # Avoid division by zero if the domain is a single point
        return nothing
    elseif n == 1
        return (codomain[2] + codomain[1]) / 2
    end

    # Perform linear interpolation
    scaled_value = codomain[1] + (index - 1) * range_span / (n - 1)
    return scaled_value
end

function applyscale(x, scale::Categorical{<:Vector,<:Vector})
    (; domain, codomain) = scale
    i = findfirst(isequal(x), domain)
    if isnothing(i)
        return nothing
    end
    return codomain[i]
end

# COLOR
function applyscale(x, scale::Categorical{<:Vector,Tuple{Symbol,Symbol}})
    (; domain, codomain) = scale
    i = findfirst(isequal(x), domain)
    len = length(domain)
    color1 = parse(Colorant, codomain[1])
    color2 = parse(Colorant, codomain[2])
    cs = ColorScheme(range(color1, color2; length=len))
    return gethexcolor(cs, i, (1, len))
end

# COLOR
function applyscale(x, scale::Categorical{<:Vector,Symbol})
    (; domain, codomain) = scale
    i = findfirst(isequal(x), domain)
    if isnothing(i)
        return "#00000000"
    end
    len = length(domain)
    cs = colorschemes[codomain]

    # Use the function below to return the 
    # colorscheme in order. For example, if cs = [red,yellow,blue,red,black,white]
    # then get(cs, 3, (1,3)) would return white instead of blue.
    # Hence, we use min(i,end) so that if x:= 3, then for cs we get blue. An so on.
    return "#" * hex(colorschemes[codomain][min(i, end)])
end
# COLOR
function applyscale(x, scale::Categorical{<:Vector,<:ColorScheme})
    (; domain, codomain) = scale
    i = findfirst(isequal(x), domain)
    if isnothing(i)
        return "#00000000"
    end
    len = length(domain)
    cs = codomain

    # Use the function below to return the 
    # colorscheme in order. For example, if cs = [red,yellow,blue,red,black,white]
    # then get(cs, 3, (1,3)) would return white instead of blue.
    # Hence, we use min(i,end) so that if x:= 3, then for cs we get blue. An so on.
    return "#" * hex(cs[min(i, end)])
end

function applyscale(x, scale::GenericScale)
    return scale.f(x)
end
function (scale::GenericScale)(x)
    return applyscale(x, scale)
end
function (scale::GenericScale)(x::Vector)
    return scale.(x)
end

function (scale::Categorical)(x)
    return applyscale(x, scale)
end
function (scale::Categorical)(x::Vector)
    return scale.(x)
end
