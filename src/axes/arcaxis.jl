# EXPERIMENTAL
# """
#     inferarcaxis(scale::Union{Linear,Categorical}; title="angle", nticks=10, tickvalues=nothing, ticktexts=nothing, rmajor=100, rminor=0)

# Create an arc axis based on the given scale.

# # Arguments
# - `scale::Union{Linear,Categorical}`: The scale used to determine the domain and codomain of the axis.
# - `title::String`: The title of the axis. Default is "angle".
# - `nticks::Int`: The number of ticks on the axis. Default is 10.
# - `tickvalues::Union{Nothing, Vector}`: The specific tick values to be displayed on the axis. Default is `nothing`.
# - `ticktexts::Union{Nothing, Vector}`: The labels for the tick values. Default is `nothing`.
# - `rmajor::Int`: The radius of the major ticks. Default is 100.
# - `rminor::Int`: The radius of the minor ticks. Default is 0.

# # Returns
# - `axis::S`: The axis element.
# - `ticks::Any`: The ticks element.

# # Example
# """
# function inferarcaxis(
#     scale::Union{Linear,Categorical};
#     title="angle",
#     nticks=10,
#     tickvalues=nothing,
#     ticktexts=nothing,
#     rmajor=100,
#     rminor=0,
# )
#     (; domain, codomain) = scale

#     tickvalues, ticktexts = get_tickvalues(
#         scale; nticks=nticks, tickvalues=tickvalues, ticktexts=ticktexts
#     )

#     # Axis
#     axis =
#         S(
#             :fillOpacity => 0, :stroke => :black
#         )Slice(;
#             θ=codomain[begin] + π / 2,
#             ang=codomain[end] - codomain[begin],
#             rminor=rminor,
#             rmajor=rmajor,
#         )

#     # Ticks
#     ticks = mapreduce(
#         z -> begin
#             tickvalue, ticktext = z
#             angle = scale(tickvalue)
#             x = cos(angle) * (rmajor)
#             y = sin(angle) * (rmajor)
#             tickmark = R(angle - π / 2)Rectangle(; h=4, w=1)
#             tickmark = T(x, y) * tickmark

#             x = cos(angle) * (rmajor + 10)
#             y = sin(angle) * (rmajor + 10)
#             ticktext = T(x, y) * TextMark(; text=ticktext, fontsize=7)

#             tickmark + ticktext
#         end,
#         +,
#         zip(tickvalues, ticktexts),
#     )

#     return axis + ticks
# end
