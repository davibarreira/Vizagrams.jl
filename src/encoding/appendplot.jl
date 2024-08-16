# """
#     replot(plt::Plot,graphic::Union{GeometricPrimitive,Prim,Mark,𝕋{Mark}})
# return Plot(plt.data, plt.spec,plt.graphic + graphic)
# """
# function replot(plt::Plot, graphic::Union{GeometricPrimitive,Prim,Mark,𝕋{Mark}})
#     return Plot(plt.data, plt.spec, plt.graphic + graphic)
# end
# function Base.:∘(plt::Plot, graphic::Union{GeometricPrimitive,Prim,Mark,𝕋{Mark}})
#     return replot(plt, graphic)
# end

# """
#     replot(plt::Plot, data::Union{StructArray,DataFrame,NamedTuple}; rescale=true)

# It vertically concatenates `plt.data` and `data` and creates a new plot.
# If `rescale` is true, it recomputes the scales, otherwise, it uses
# the scales from the original plot.
# """
# function replot(
#     plt::Plot, data::Union{StructArray,NamedTuple}; enc=nothing, rescale=true, fill=nothing
# )
#     # turn data into StructArray
#     data = StructArray(Tables.rowtable(data))
#     data = vconcat(plt.data, data; fill=fill)
#     if !isnothing(enc)
#         scales = NamedTuple(
#             map(zip(keys(enc), values(enc))) do (k, v)
#                 datatype = get(v, :datatype, infer_datatype(data))
#                 scale = infer_encoding_scale(;
#                     data=data,
#                     coordinate=plt.spec.config.coordinate,
#                     framesize=plt.spec.config.figsize,
#                     variable=k,
#                     partial_encoding=v,
#                 )
#                 return (k => (datatype=datatype, scale=scale))
#             end,
#         )
#         enc = NamedTupleTools.rec_merge(unzip(enc), scales)
#     else
#         enc = NamedTuple()
#     end
#     encodings = NamedTupleTools.rec_merge(plt.spec.encodings, enc)

#     if rescale
#         enc_no_scale = NamedTuple(
#             map(zip(keys(plt.spec.encodings), values(plt.spec.encodings))) do (k, v)
#                 k => @delete v.scale
#             end,
#         )

#         encodings = NamedTupleTools.rec_merge(enc_no_scale, enc)

#         return Plot(; data=data, encodings=encodings, graphic=plt.graphic)
#     end

#     spec = plt.spec
#     spec = @set spec.encodings = encodings
#     return Plot(data, spec, plt.graphic)
# end
# function Base.:∘(plt::Plot, data::Union{StructArray,NamedTuple})
#     return replot(plt, data; rescale=true)
# end

"""
    replot(plt1::Plot, plt2::Plot)

Place the graphic of `plt2` over `plt1`.
"""
function replot(plt1::Plot, plt2::Plot)
    encodings = NamedTupleTools.rec_merge(plt1.spec.encodings, plt2.spec.encodings)
    plt2 = @set plt2.spec.encodings = encodings
    plt2 = @set plt2.spec.config = (; guide=NilD())
    return plt1 + plt2
end
function Base.:∘(plt1::Plot, plt2::Plot)
    return replot(plt1, plt2)
end
