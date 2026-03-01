require 'cairo'

settings_table = {
    { name='time', arg='%I.%M', max=12, bg_colour=0xffffff, bg_alpha=0.1, fg_colour=0xfdcd19, fg_alpha=0.2, x=80, y=120, radius=50, thickness=5, start_angle=0, end_angle=360 },
    { name='time', arg='%M.%S', max=60, bg_colour=0xffffff, bg_alpha=0.1, fg_colour=0xfdcd19, fg_alpha=0.4, x=80, y=120, radius=56, thickness=5, start_angle=0, end_angle=360 },
    { name='time', arg='%S',     max=60, bg_colour=0xffffff, bg_alpha=0.1, fg_colour=0xfdcd19, fg_alpha=0.6, x=80, y=120, radius=62, thickness=5, start_angle=0, end_angle=360 },
    { name='time', arg='%d',     max=31, bg_colour=0xffffff, bg_alpha=0.1, fg_colour=0xfdcd19, fg_alpha=0.8, x=80, y=120, radius=70, thickness=5, start_angle=-90, end_angle=90 },
    { name='time', arg='%m',     max=12, bg_colour=0xffffff, bg_alpha=0.1, fg_colour=0xfdcd19, fg_alpha=1.0, x=80, y=120, radius=76, thickness=5, start_angle=-90, end_angle=90 },
}

clock_r  = 65
clock_x  = 80
clock_y  = 120
show_seconds = true

-------------------------------------------------------
-- UTILITIES
-------------------------------------------------------

local function rgb(colour, alpha)
    return ((colour/0x10000)%0x100)/255,
           ((colour/0x100)%0x100)/255,
           (colour%0x100)/255,
           alpha
end

local function angle(deg)
    return (deg * 2 * math.pi / 360) - math.pi/2
end

-------------------------------------------------------
-- DRAW RING
-------------------------------------------------------

local function draw_ring(cr, pct, pt)
    local sa = angle(pt.start_angle)
    local ea = angle(pt.end_angle)
    local arc = pct * (ea - sa)

    -- background
    cairo_arc(cr, pt.x, pt.y, pt.radius, sa, ea)
    cairo_set_source_rgba(cr, rgb(pt.bg_colour, pt.bg_alpha))
    cairo_set_line_width(cr, pt.thickness)
    cairo_stroke(cr)

    -- foreground
    cairo_arc(cr, pt.x, pt.y, pt.radius, sa, sa + arc)
    cairo_set_source_rgba(cr, rgb(pt.fg_colour, pt.fg_alpha))
    cairo_stroke(cr)
end

-------------------------------------------------------
-- DRAW CLOCK HANDS
-------------------------------------------------------

local function draw_clock_hands(cr)
    local secs  = tonumber(os.date("%S"))
    local mins  = tonumber(os.date("%M"))
    local hours = tonumber(os.date("%I"))

    local secs_arc  = (2*math.pi/60) * secs
    local mins_arc  = (2*math.pi/60) * mins + secs_arc/60
    local hours_arc = (2*math.pi/12) * hours + mins_arc/12

    cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND)

    -- hour
    cairo_set_line_width(cr, 5)
    cairo_set_source_rgba(cr, 0.5,0.5,0.5,1)
    cairo_move_to(cr, clock_x, clock_y)
    cairo_line_to(cr,
        clock_x + 0.7*clock_r*math.sin(hours_arc),
        clock_y - 0.7*clock_r*math.cos(hours_arc))
    cairo_stroke(cr)

    -- minute
    cairo_set_line_width(cr, 3)
    cairo_move_to(cr, clock_x, clock_y)
    cairo_line_to(cr,
        clock_x + clock_r*math.sin(mins_arc),
        clock_y - clock_r*math.cos(mins_arc))
    cairo_stroke(cr)

    -- seconds
    if show_seconds then
        cairo_set_line_width(cr, 1)
        cairo_move_to(cr, clock_x, clock_y)
        cairo_line_to(cr,
            clock_x + clock_r*math.sin(secs_arc),
            clock_y - clock_r*math.cos(secs_arc))
        cairo_stroke(cr)
    end
end

-------------------------------------------------------
-- OPTIONAL: Rounded Background (Enable if needed)
-------------------------------------------------------

local function draw_background(cr, w, h)
    local radius = 30
    local alpha  = 0.4

    cairo_set_source_rgba(cr, 0, 0, 0, alpha)
    cairo_new_path(cr)
    cairo_arc(cr, w-radius, radius, radius, -math.pi/2, 0)
    cairo_arc(cr, w-radius, h-radius, radius, 0, math.pi/2)
    cairo_arc(cr, radius, h-radius, radius, math.pi/2, math.pi)
    cairo_arc(cr, radius, radius, radius, math.pi, 3*math.pi/2)
    cairo_close_path(cr)
    cairo_fill(cr)
end

-------------------------------------------------------
-- MAIN FUNCTION
-------------------------------------------------------
local function draw_separator(cr)
    cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND)

    	-- Glow
	cairo_set_source_rgba(cr, 1, 0.9, 0.2, 0.3)
	cairo_set_line_width(cr, 3)
	cairo_move_to(cr, 85, 189)
	cairo_line_to(cr, 545, 189)
	cairo_stroke(cr)

	-- Main bright line
	cairo_set_source_rgba(cr, 1, 0.95, 0.3, 1)
	cairo_set_line_width(cr, 1)
	cairo_move_to(cr, 85, 189)
	cairo_line_to(cr, 545, 189)
	cairo_stroke(cr)

	-- Soft shadow line
	cairo_set_source_rgba(cr, 0xfd/255, 0xcd/255, 0x19/255, 0.5)
	cairo_set_line_width(cr, 0.5)
	cairo_move_to(cr, 88, 191)
	cairo_line_to(cr, 548, 191)
	cairo_stroke(cr)
end

function conky_clock_rings()

    if conky_window == nil then return end

    local w = conky_window.width
    local h = conky_window.height

    local cs = cairo_xlib_surface_create(
        conky_window.display,
        conky_window.drawable,
        conky_window.visual, w, h)

    local cr = cairo_create(cs)

    local updates = tonumber(conky_parse('${updates}'))

    if updates > 5 then

        -- Uncomment next line if you want rounded background
        -- draw_background(cr, w, h)

        for _, pt in ipairs(settings_table) do
            local value = tonumber(conky_parse(
                string.format('${%s %s}', pt.name, pt.arg)
            ))
            if value then
                draw_ring(cr, value / pt.max, pt)
            end
        end

        draw_clock_hands(cr)
        draw_separator(cr)
    end

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end
