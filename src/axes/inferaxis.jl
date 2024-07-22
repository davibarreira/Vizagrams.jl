"""
inferaxis(data, enc, axislength; titleplacement=:s, titleangle=0, ticktextangle=0,

Returns an `Axis` mark based on the data and encoding.
"""
function inferaxis(
    spec,
    variable,
    axislength;
    titleplacement=:s,
    titleangle=0,
    ticktextangle=0,
    ticktextplacement=:bottom,
    ticktextanchor=:c,
    tickmark=T(0, -2)Rectangle(; h=4, w=1),
    axisarrow=nothing,
    kwargs...,
)
    enc = spec.encodings[variable]
    title = getnested(enc, [:guide, :title], string(enc[:field]))
    title = get(kwargs, :title, title)
    titlefontsize = get(kwargs, :titlefontsize, 10)
    titlemark = TextMark(; text=title, angle=titleangle, fontsize=titlefontsize)
    titlemark = get(kwargs, :titlemark, titlemark)

    titleplacement = getnested(enc, [:guide, :titleplacement], titleplacement)
    titleangle = getnested(enc, [:guide, :title_angle], titleangle)
    axislength = getnested(enc, [:guide, :length], axislength)
    ticktextangle = getnested(enc, [:guide, :ticktextangle], ticktextangle)
    tickvalues = getnested(enc, [:guide, :tickvalues], inferaxistickvalues(spec, variable))
    scale = getnested(enc, [:scale], inferscale(spec, variable))
    if scale isa Function
        scale = GenericScale(scale)
    end
    # axisarrow = getnested(enc, [:scale], inferscale(spec, variable))

    ticktexts = getnested(enc, [:guide, :ticktexts], tickvalues)
    ticktexts = get(kwargs, :ticktexts, ticktexts)
    if ticktexts isa String
        ticktexts = [ticktexts for v in tickvalues]
    end

    return Axis(;
        axislength=axislength,
        # titlemark=TextMark(; text=title, angle=titleangle, fontsize=titlefontsize),
        titlemark=titlemark,
        titleplacement=titleplacement,
        tickvalues=tickvalues,
        scale=scale,
        tick=Tick(;
            textangle=ticktextangle,
            textplacement=ticktextplacement,
            textanchor=ticktextanchor,
            mark=tickmark,
        ),
        axisarrow=axisarrow,
        ticktexts=ticktexts,
    )
end
