module RLSPanels

greet() = print("Hello World!")

using QML
using Observables
# using GLFW
# using ModernGL
using Luxor
using Serde
# using Random
using FileIO
using ImageIO
using Colors
using FixedPointNumbers
using Distributions
using TOML



# data structures

struct LineSegment
    p1::Vector{Float64}
    p2::Vector{Float64}
end

struct RectData
    width::Float64
    height::Float64
    lines::Vector{LineSegment}
end

# data generation logic

const rect_dims::Vector{Tuple{Float64, Float64}} = [
    (45.0, 69.0), (45.0, 69.0), (45.0, 69.0), (45.0, 69.0), # Row 1
    (24, 69), (24, 69),                     # Row 2
    (38, 60), (46, 60)                      # Row 3
]

# in this function all units will be in inches
function generate_rect_data(w, h; 
    num_lines=20,  # total lines
    num_full_lines_top=5, 
    supp_margin=2.5, # support frame
    parts_to_leave_bottom=8, 
    parts_to_leave_top=30, 
    mid_supp_margin=1.5,
    y_step = 1.5, # gap between full lines at the top in inches
    parts_len_lower_limit = 6 # = n means min len = w/n
)
    # # debugging
    # @show parts_len_lower_limit

    # start function
    lines_data = LineSegment[]

    # current_h = supp_margin + (h/parts_to_leave_top)
    current_h = max(supp_margin, (h/parts_to_leave_top))

    for _ in 1:num_full_lines_top
        x_left = supp_margin
        x_right = w - supp_margin
        y = current_h
        
        if w > 30 
            push!(lines_data, LineSegment([x_left, y], [w/2 - mid_supp_margin/2, y]))
            push!(lines_data, LineSegment([w/2 + mid_supp_margin/2, y], [x_right, y]))
        else
            push!(lines_data, LineSegment([x_left, y], [x_right, y]))
        end
        
        current_h += y_step
    end

    yt = current_h + y_step # top y limit for random line
    yb = h - max(supp_margin, (h/parts_to_leave_bottom)) # bottom y limit for random line

    for _ in 1:num_lines - num_full_lines_top
        line_seg_len = rand(Uniform(w/parts_len_lower_limit, w - 2*supp_margin))
        current_y = rand(Uniform(yt, yb))
        x_left = rand(Uniform(supp_margin, w - supp_margin - line_seg_len))
        x_right = x_left + line_seg_len
        
        if w > 30 && x_left < w/2 && x_right > w/2
            if x_left < w/2 - mid_supp_margin/2
                push!(lines_data, LineSegment([x_left, current_y], [w/2 - mid_supp_margin/2, current_y]))
            end
            if x_right > w/2 + mid_supp_margin/2
                push!(lines_data, LineSegment([w/2 + mid_supp_margin/2, current_y], [x_right, current_y]))
            end
        else
            push!(lines_data, LineSegment([x_left, current_y], [x_right, current_y]))
        end
    end

    return RectData(w, h, lines_data)
end

function rect_mirror_image(rect::RectData)
    # mirror image 
    # it is same as reflection about x = w/2
    w, h = rect.width, rect.height
    linesegs = LineSegment[]

    # reflection about x = w/2 is (x, y) --> (w - x, y)
    for lseg in rect.lines
        push!(linesegs, LineSegment([w - lseg.p1[1], lseg.p1[2]], [w - lseg.p2[1], lseg.p2[2]]) )
    end

    return RectData(w, h, linesegs)
end

function generate_rect_panel!(all_data::Dict{String, RectData})
    filepath = "config.toml"
    config = Dict{String, Any}() # Initialize an empty dictionary

    # Check if the file exists before attempting to read
    if isfile(filepath)
        println("Found '$filepath'. Loading parameters...")
        config = TOML.parsefile(filepath)
    else
        println("File '$filepath' not found. Relying on function defaults...")
    end

    # CRITICAL STEP: Convert String keys to Symbol keys
    # TOML parses keys as Strings, but Julia requires Symbols to splat them as keyword arguments.
    kwargs = Dict{Symbol, Any}(Symbol(k) => v for (k, v) in config)
    for idx in 1:length(rect_dims)
        w, h = rect_dims[idx]

        all_data[string(idx)] = generate_rect_data(w, h; kwargs...)
    end
end

# Luxor drawing logic

function draw_rect_panel(rects_data::Dict{String, RectData})
    background("antiquewhite")

    sorted_keys = sort(collect(keys(rects_data)), by = k -> parse(Int, k))

    v_gap = 30
    h_gap = 30
    margin = 30
    scale_factor = 2.54

    # for idx in sorted_keys
    for idx in 1:length(sorted_keys)
        rect = rects_data[string(idx)]
        w, h = rect.width, rect.height
        corner_x = margin
        corner_y = margin 

        if idx in 1:4
            # row 1
            corner_x += (idx-1)*(w + h_gap)
        elseif idx in 5:6
            # row 2
            corner_x += (idx-5)*(w + h_gap)
            corner_y += h + v_gap
        else
            # row 3
            corner_x += (idx-7)*(w + h_gap)
            # this height is 60 vs 69 so to compensate add 18
            corner_y += 2*(h + v_gap) + 20
        end

        cx, cy = corner_x + w/2, corner_y + h/2
        center_pt = Point(cx * scale_factor, cy * scale_factor)

        sethue("black")
        box(center_pt, w * scale_factor, h * scale_factor, :fill)

        sethue("white")
        setline(0.3) # first ones at 0.8
        for line_data in rect.lines
            p1 = Point( (corner_x + line_data.p1[1]) * scale_factor, (corner_y + line_data.p1[2]) * scale_factor)
            p2 = Point( (corner_x + line_data.p2[1]) * scale_factor, (corner_y + line_data.p2[2]) * scale_factor)
            line(p1, p2, :stroke)
        end
        
        # rectangle id
        sethue("gray40")
        fontsize(8)
        fontface("Iosevka")
        text("#$idx", Point(cx * scale_factor, (cy - h/2 - 10) * scale_factor), halign=:center, valign=:bottom)
        
        # dimension annotation
        sethue("dodgerblue")
        setline(0.3)
        fontsize(6)
        fontface("Iosevka")
        
        p1_w = Point((cx - w/2)*scale_factor, (cy + h/2)*scale_factor)
        p2_w = Point((cx + w/2)*scale_factor, (cy + h/2)*scale_factor)
        dimension(p2_w, p1_w, offset=-15, format = d -> "$(w) in", arrowlinewidth=0.3, arrowheadlength=3)
        
        p1_h = Point((cx - w/2)*scale_factor, (cy - h/2)*scale_factor)
        p2_h = Point((cx - w/2)*scale_factor, (cy + h/2)*scale_factor)
        dimension(p1_h, p2_h, offset=15, format = d -> "$(h) in", arrowlinewidth=0.3, arrowheadlength=3, textrotation=π)
    end
end

is_hex32(s::AbstractString) =  length(s)==8 && all(isxdigit, s)

function load_panel(hexcode_id::String)
    @assert is_hex32(hexcode_id) "$hexcode_id is not a hex string of length 8"
    file_name = "rectangles_$(hexcode_id)"*".json"
    file_path = joinpath("data", file_name)
    @assert isfile(file_path) "$file_name does not exist in data/ directory"

    # everything is ok. now read json file 
    json_file_content = read(file_path, String)
    rect_data = deser_json(Dict{String, RectData}, json_file_content)
    # println("\n-- read data --")
    return rect_data
end

function redraw_panel(hexcode_id::String)

    rect_data = load_panel(hexcode_id)
    # println("\n-- read data --")
    # println(rect_data)

    dir_name = "redrawn"

    # create data subdirectory if it does not exist
    if !isdir(dir_name)
        mkpath(dir_name)
    end

    pdf_filename = "rectangles_$hexcode_id.pdf"
    pdf_file_path = joinpath(dir_name, pdf_filename)

    preview_w, preview_h = 850, 850
    Drawing(preview_w, preview_h, pdf_file_path)
    # draw_rectangles(current_data[])
    draw_rect_panel(rect_data)
    finish()

end


# Observables for QML binding
const svg_w = Observable(400.0)
const svg_h = Observable(400.0)
const status_msg = Observable("Ready")

# Store the latest drawing in memory so we can save it later
const current_drawing = Ref{Any}(nothing)
current_data = Ref{Dict{String,RectData}}()
status_msg[] = "Click 'Generate Pattern' to begin."

function generate_luxor_svg(julia_display::JuliaDisplay)

    preview_w, preview_h = 850, 850

    data = Dict{String,RectData}()

    # current_data[] = data
    generate_rect_panel!(data)
    current_data[] = data

    
    drawing = @drawsvg begin
        # @drawsvg calls origin implicitly  
        # Shift the origin back to the top-left corner
        translate(-preview_w / 2, -preview_h / 2)
        draw_rect_panel(data)
    end preview_w preview_h

    # Store it in our reference
    current_drawing[] = drawing

    # Display it in QML
    display(julia_display, drawing)
    
    # Update properties
    svg_w[] = Float64(preview_w)
    svg_h[] = Float64(preview_h)
    # status_msg[] = "Generated new SVG ($(w)x$(h))"
    status_msg[] = "Pattern generated. Ready to save."
end

function save_pdf_json()
    # if pattern is genrated already
    if !isnothing(current_drawing[])
        
        # sample a 32 bit unsigned int and use its hex represenation as code
        hex_code = string(rand(0x0000:0xFF_FF_FF_FF), base=16, pad=8)
        hex_code = uppercase(hex_code)
        pdf_filename = "rectangles_$hex_code.pdf"
        json_filename = "rectangles_$hex_code.json"

        dir_name = "data"

        # create data subdirectory if it does not exist
        if !isdir(dir_name)
            mkpath(dir_name)
        end

        pdf_file_path = joinpath(dir_name, pdf_filename)
        json_file_path = joinpath(dir_name, json_filename)

         preview_w, preview_h = 850, 850

        # Save PDF
        # Drawing(preview_w, preview_h, pdf_filename)
        Drawing(preview_w, preview_h, pdf_file_path)
        # draw_rectangles(current_data[])
        draw_rect_panel(current_data[])
        finish()

        # Save JSON via Serde
        open(json_file_path, "w") do f
            write(f, to_json(current_data[]))
        end

        # status_msg = "✅ Saved to: $pdf_filename & $json_filename"
        status_msg[] = "✅ Saved to: $pdf_file_path & $json_file_path"

    else
        status_msg[] = "Error: Please generate a pattern first!"
    end
end

function main()
    # Register both functions
    @qmlfunction generate_luxor_svg
    @qmlfunction save_pdf_json

    # Pass the status observable into the property map
	qml_file = joinpath(dirname(@__FILE__), "main.qml")
    loadqml(qml_file,
        svgProps=JuliaPropertyMap(
            "width" => svg_w,
            "height" => svg_h,
            "status" => status_msg
        )
    )

    exec()

end  # function main


function selected_draw()
    file_path = "selected_panel.toml"
    @assert isfile(file_path) "$file_path does not exist. Please create it with the desired parameters."

    config = TOML.parsefile(file_path)
    raw_dict = config["my_panel"]

    panel_data = Dict{String,RectData}()

    # verify keys are 1:8
    for (key_str, val_arr) in raw_dict
        @assert key_str in string.(1:8) "Invalid key: $key_str. Expected keys are '1' to '8'."
        @assert length(val_arr) == 2 "Value for key $key_str should be an array of [hexcode, id]."

        rect_dt = load_panel(val_arr[1])
        panel_data[key_str] = rect_dt[val_arr[2]]
    end

    pdf_filename = "rectangles_sel.pdf"
    json_filename = "rectangles_sel.json"

    dir_name = "selected"

    # create data subdirectory if it does not exist
    if !isdir(dir_name)
        mkpath(dir_name)
    end

    pdf_file_path = joinpath(dir_name, pdf_filename)
    json_file_path = joinpath(dir_name, json_filename)

    preview_w, preview_h = 850, 850

    # Save PDF
    # Drawing(preview_w, preview_h, pdf_filename)
    Drawing(preview_w, preview_h, pdf_file_path)
    # draw_rectangles(current_data[])
    draw_rect_panel(panel_data)
    finish()

    # Save JSON via Serde
    open(json_file_path, "w") do f
        write(f, to_json(panel_data))
    end

    # status_msg = "✅ Saved to: $pdf_filename & $json_filename"
    status = "✅ Saved to: $pdf_file_path & $json_file_path"
    println(status)
end


function main_redraw()
    # redraw_panel("FFCDA06G")
    # redraw_panel("FFFFFFFF")
    redraw_panel("ACE4F080")
end

# main()

# selected_draw()

# main_redraw()


end # module RLSPanels
