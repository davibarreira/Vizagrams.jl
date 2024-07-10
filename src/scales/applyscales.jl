"""
applyscales(scales, encoding, data, coord)

Given a set a data, a dictionary of scales, coordinates, and encodings,
it then applies the scales, then computes :x and :y with the appropriate
coordinate transformation. The final result is a scaled dataset.

```julia
f(x) = sin(x)
g(x) = cos(√x)
x = 0:0.01:10
y = f.(x)
z = g.(x)

data=StructArray(x=x,b=y,z=z)

scales = Dict(
    :x=>Linear(domain=[-1,1],codomain=[1,1]),
    :r => Linear(domain=[-1,1],codomain=[0,10]),
    :angle => Linear(domain=[-1,1],codomain=[0,2π]),
)

encoding = Dict(:r=>:z,:angle=>:b)

polar(;r,angle) = r .* [cos(angle), sin(angle)]
coord = Dict(:enc=>(:r,:angle),:map=>polar)

applyscales(scales, encoding, data, coord)
```
"""
function applyscales(scales, encoding, data, coord)
    # collect the corresponding key values from the encoding
    encoding_keys = sort(collect(keys(encoding)))

    # apply scales
    sdata = map(
        key -> get(scales, key, identity).(Tables.getcolumn(data, encoding[key])),
        encoding_keys,
    )
    # turn sdata into StructArray
    sdata = StructArray(NamedTuple{tuple(encoding_keys...)}(sdata))

    if !isnothing(get(coord, :enc, nothing)) && !isnothing(get(coord, :map, nothing))

        # Get data columns according to the coordinates encoding variables
        subdata = map(k -> Tables.getcolumn(sdata, k), (coord[:enc]))
        subdata = StructArray(NamedTuple{tuple(coord[:enc]...)}(subdata))

        #
        new_xy = map(row -> begin
            x, y = coord[:map](row...)
            return (x=x, y=y)
        end, Tables.rows(subdata))

        new_xy = StructArray(new_xy)

        return hconcat(sdata, new_xy)
    end

    return sdata
end
