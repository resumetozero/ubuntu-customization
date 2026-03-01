require 'cairo'

function conky_draw_bg()

    if conky_window == nil then return end

    local w = conky_window.width
    local h = conky_window.height

    local cs = cairo_xlib_surface_create(
        conky_window.display,
        conky_window.drawable,
        conky_window.visual,
        w, h)

    local cr = cairo_create(cs)

    -- SETTINGS
    local radius = 10        -- corner curve
    local bg_alpha = 0.3     -- background transparency
    local border_width = 1   -- border thickness
    local border_alpha = 0.6 -- border visibility

    ---------------------------------------------------
    -- DRAW ROUNDED BACKGROUND
    ---------------------------------------------------
    cairo_set_source_rgba(cr, 0, 0, 0, bg_alpha)

    cairo_new_path(cr)
    cairo_arc(cr, w-radius, radius, radius, -math.pi/2, 0)
    cairo_arc(cr, w-radius, h-radius, radius, 0, math.pi/2)
    cairo_arc(cr, radius, h-radius, radius, math.pi/2, math.pi)
    cairo_arc(cr, radius, radius, radius, math.pi, 3*math.pi/2)
    cairo_close_path(cr)

    cairo_fill_preserve(cr)

    ---------------------------------------------------
    -- DRAW ROUNDED BORDER
    ---------------------------------------------------
    cairo_set_source_rgba(cr, 1, 1, 1, border_alpha) -- white border
    cairo_set_line_width(cr, border_width)
    cairo_stroke(cr)

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end
