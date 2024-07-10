"""
idraw(d; id="vizagrams", kwargs...)

Wraps the output of the `drawsvg` into an html tag with some
javascript functionality in order to provide interactivity.

It returns an HTML{String}.

To provide zoom and pan, we use the `svg-pan-zoom` minified javascript package.
"""
function idraw(d; id=nothing, kwargs...)
    svg_pan_zoom = joinpath(@__DIR__, "svg-pan-zoom.min.js")
    id = isnothing(id) ? string(UUIDs.uuid1()) : id
    svg = string(drawsvg(d; id=id, kwargs...))
    svg_mini_js = read(svg_pan_zoom, String)
    html_s = """
    $svg

    <script>

        $svg_mini_js

        // Add pan and zoom functionality to the SVG
        var svgElement = document.getElementById('$id');
        var panZoomInstance = svgPanZoom(svgElement, {
            zoomEnabled: true,
            dblClickZoomEnabled: false,
            controlIconsEnabled: false,
            fit: true,
            center: true,
            zoomScaleSensitivity: 0.15,
            minZoom: 0.1
        });

        // Reset zoom and pan on double click
        svgElement.addEventListener('dblclick', function() {
            panZoomInstance.resetZoom();
            panZoomInstance.center();
        });
    </script>
"""
    return HTML(html_s)
end

# """
# idraw(d; id="vizagrams", kwargs...)

# Wraps the output of the `drawsvg` into an html tag with some
# javascript functionality in order to provide interactivity.

# It returns an HTML{String}.

# To provide zoom and pan, we use the `svg-pan-zoom` minified javascript package.
# """
# function idraw(d; id=nothing, kwargs...)
#     id = isnothing(id) ? string(uuid1()) : id
#     svg = string(drawsvg(d; id=id, kwargs...))
#     svg_mini_js = read("svg-pan-zoom.min.js", String)
#     js = """
# <script><![CDATA[

#     $svg_mini_js

#     // Add pan and zoom functionality to the SVG
#     var svgElement = document.getElementById('$(id)');
#     var panZoomInstance = svgPanZoom(svgElement, {
#         zoomEnabled: true,
#         dblClickZoomEnabled: false,
#         controlIconsEnabled: false,
#         fit: true,
#         center: true,
#         zoomScaleSensitivity: 0.15,
#         minZoom: 0.1
#     });

#     // Reset zoom and pan on double click
#     svgElement.addEventListener('dblclick', function() {
#         panZoomInstance.resetZoom();
#         panZoomInstance.center();
#     });
# ]]></script>
# """
#     return HTML(svg[begin:(end - 6)] * js * svg[(end - 5):end])
# end

# html_s = """
# <!DOCTYPE html>
# <html>
# <body>
# 
# $svg

# <script>

#     $svg_mini_js

#     // Add pan and zoom functionality to the SVG
#     var svgElement = document.getElementById('$id');
#     var panZoomInstance = svgPanZoom(svgElement, {
#         zoomEnabled: true,
#         dblClickZoomEnabled: false,
#         controlIconsEnabled: false,
#         fit: true,
#         center: true,
#         zoomScaleSensitivity: 0.15,
#         minZoom: 0.1
#     });

#     // Reset zoom and pan on double click
#     svgElement.addEventListener('dblclick', function() {
#         panZoomInstance.resetZoom();
#         panZoomInstance.center();
#     });
# </script>
# 
# </body>
# </html>
# """

# """
#     <script>
#     var bars = document.getElementsByTagName("circle");
#     function mouseColor() {
#         this.setAttribute("fill","red")
#     }
#     function mouseOverEffect() {
#         this.setAttribute("r",5)
#     }
#     function mouseOutEffect() {
#         this.setAttribute("r",1)
#     }
#     for (var i = 0; i < bars.length; i++) {
#         bars[i].addEventListener('mouseover', mouseOverEffect);
#         bars[i].addEventListener('mouseout', mouseOutEffect);
#     }
#     
#         function displayName(name) {
#             document.getElementById('tooltip').firstChild.data = name;
#     }

#     
#     </script>
# """
