"""
get_encoding_variable(encodings, field_var)

For an encoding such as `(x=(field=a), y=(field=b))`,
the function takes a `field_var` and returns the respective
encoding variable. For example,
```julia
enc = (x=(field=a), y=(field=b))
get_encoding_variable(enc, :a) # returns `:x`.
```
"""
function get_encoding_variable(encodings, field_var)
    ks = collect(keys(encodings))
    return mapreduce(k -> encodings[k][:field] == field_var ? k : [], vcat, ks)
end

"""
context(plt, data, var, enc)

Given a `plot`, 

For an encoding such as `(x=(field=a), y=(field=b))`,
the function takes a `field_var` and returns the respective
encoding variable. For example,
```julia
enc = (x=(field=a), y=(field=b))
get_encoding_variable(enc, :a) # returns `:x`.
```
"""
function context(plt, data, var, enc)
    context_scale = getscale(plt, enc)
    return context_scale(Tables.getcolumn(data, var))
end

function context(plt::Plot, data, var)
    enc = plt.spec.encodings
    enc_var = get_encoding_variable(enc, var)
    context_scale = map(s -> getscale(plt, s), enc_var)
    if length(context_scale) == 1
        return context_scale[1](Tables.getcolumn(data, var))
    end
    return map(s -> s(Tables.getcolumn(data, var)), context_scale)
end

function (plt::Plot)(data, var)
    return context(plt, data, var)
end
function (plt::Plot)(data, var, enc)
    return context(plt, data, var, enc)
end
