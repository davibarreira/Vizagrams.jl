
"""
function inferaxistickvalues(ds, enc, defaultlength)

Uses either quantitative, ordinal or nominal scale.
"""
function inferaxistickvalues(spec::PlotSpec, variable)
    (; data, figsize, encodings) = spec

    enc = encodings[variable]
    ds = Tables.getcolumn(data, enc[:field])
    if variable == :x
        inferaxisscale_and_tickvalues(ds, enc, figsize[1])[begin]
    elseif variable == :y
        inferaxisscale_and_tickvalues(ds, enc, figsize[2])[begin]
    end
end
