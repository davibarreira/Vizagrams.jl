"""
savesvg(plt::𝕋{Mark};filename::String, directory::String="./", height=400, pad=0)

Saves the graphic as an svg figure. The function wraps the whole graphic into an
svg tag with a given view height equal to `height` + `pad`. The `pad` is just
some white space added around the figure. The use of padding is recommended
in order to guarantee that the image is fully displayed.
"""
function savesvg(
    plt::Union{Mark,𝕋{Mark}}; filename::String, directory::String="./", height=300, pad=10
)
    img = string(drawsvg(plt; height=height, pad=pad))
    fname = filename
    dirpath = directory
    fpath = joinpath(dirpath, fname)

    open(fpath, "w") do file
        write(file, img)
    end
end

"""
savefig(plt::𝕋{Mark}; filename::String, directory::String="./", height=300, pad=10)

Saves the graphic as inferring the extension from the filename. The function wraps the whole graphic into an
svg tag with a given view height equal to `height` + `pad`. The `pad` is just
some white space added around the figure. The use of padding is recommended
in order to guarantee that the image is fully displayed. For raster images
such as `.png`, the height is used to determine the number of pixels in the image.
"""
function savefig(
    plt::Union{Prim, Mark,𝕋{Mark}}; filename::String, directory::String="./", height=300, pad=10
)
    extension = filename[(end - 2):end]
    if extension == "svg"
        return savesvg(plt; filename=filename, directory=directory, height=height, pad=pad)
    end

    img = string(drawsvg(plt; height=height, pad=pad))
    # Extract viewBox height from SVG string
    viewbox_match = match(r"viewBox=\"[^\"]*\s+[^\"]*\s+[^\"]*\s+([^\"]*)", img)
    viewbox_height = parse(Float64, viewbox_match[1])

    # Recompute the height to fix the stroke width
    img = string(drawsvg(U(300/viewbox_height) * plt; height=height, pad=pad))

    fname = filename
    dirpath = directory
    fpath = joinpath(dirpath, fname)

    if extension == "pdf"
        return mktemp() do path, io
            write(io, img)
            close(io)
            run(`$(rsvg_convert()) $path -h $height -f $extension -o $fpath`)
        end
    end

    return mktemp() do path, io
        write(io, img)
        close(io)
        run(`$(rsvg_convert()) $path -h $height -f $extension -o $fpath`)
    end
end
