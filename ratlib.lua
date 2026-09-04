rat = {}

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MATHS
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
function rat.maths_clamp(value, minimum_value, maximum_value)
   return math.max(minimum_value, math.min(value, maximum_value))
end

function rat.maths_lerp(start_value, end_value, interpolation_amount)
   return start_value + (end_value - start_value) * interpolation_amount
end

function rat.maths_inverse_lerp(start_value, end_value, value)
   return (value - start_value) / (end_value - start_value)
end

function rat.maths_remap(value, input_minimum, input_maximum, output_minimum, output_maximum)
   local interpolation_amount = rat.maths_inverse_lerp(input_minimum, input_maximum, value)
   return rat.maths_lerp(output_minimum, output_maximum, interpolation_amount)
end

function rat.maths_round(value)
   return math.floor(value + 0.5)
end

function rat.maths_sign(value)
   if value < 0 then
      return -1
   elseif value > 0 then
      return 1
   end

   return 0
end

function rat.maths_distance(point_a_x, point_a_y, point_b_x, point_b_y)
   local distance_x = point_b_x - point_a_x
   local distance_y = point_b_y - point_a_y

   return math.sqrt(distance_x * distance_x + distance_y * distance_y)
end

function rat.maths_snap(value, step_size)
   return rat.maths_round(value / step_size) * step_size
end

function rat.maths_approach(current_value, target_value, step_size)
   if current_value < target_value then
      return math.min(current_value + step_size, target_value)
   elseif current_value > target_value then
      return math.max(current_value - step_size, target_value)
   end

   return target_value
end

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GEOMETRY
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------

function rat.geo_point_in_rect(point_x, point_y, rect_x, rect_y, rect_width, rect_height)
   return point_x >= rect_x
       and point_x <= rect_x + rect_width
       and point_y >= rect_y
       and point_y <= rect_y + rect_height
end

function rat.geo_rects_overlap(rect_a_x, rect_a_y, rect_a_width, rect_a_height, rect_b_x, rect_b_y, rect_b_width,
                               rect_b_height)
   return rect_a_x < rect_b_x + rect_b_width
       and rect_a_x + rect_a_width > rect_b_x
       and rect_a_y < rect_b_y + rect_b_height
       and rect_a_y + rect_a_height > rect_b_y
end

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RESOLUTION
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------

rat.res = {
   width = 1280,
   height = 720,
   scale = 1,
   offset_x = 0,
   offset_y = 0,
   mouse_x = 0,
   mouse_y = 0,
}

function rat.res_initialise(width, height)
   rat.res.width = width
   rat.res.height = height
   rat.res_update()
end

function rat.res_update()
   local window_width, window_height = window.get_size()

   rat.res.scale = math.min(window_width / rat.res.width, window_height / rat.res.height)

   local render_width = rat.res.width * rat.res.scale
   local render_height = rat.res.height * rat.res.scale

   rat.res.offset_x = (window_width - render_width) / 2
   rat.res.offset_y = (window_height - render_height) / 2

   local mouse_x, mouse_y = input.get_mouse_position()

   rat.res.mouse_x = (mouse_x - rat.res.offset_x) / rat.res.scale
   rat.res.mouse_y = (mouse_y - rat.res.offset_y) / rat.res.scale
end

function rat.res_push()
   graphics.begin_transform()
   graphics.set_translation(rat.res.offset_x, rat.res.offset_y)
   graphics.set_scale(rat.res.scale, rat.res.scale)
end

function rat.res_pop()
   graphics.end_transform()
end

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SHAPES
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
local TRANSPARENT = rgba(0, 0, 0, 0)

local scratch_pixelmap = nil
local scratch_image = nil
local scratch_width = 0
local scratch_height = 0

rat.dither_checkered = { { 1, 0 }, { 0, 1 } }
rat.dither_25 = { { 1, 0 }, { 0, 0 } }
rat.dither_75 = { { 1, 1 }, { 1, 0 } }

local function ensure_scratch(width, height)
   if width <= scratch_width and height <= scratch_height then
      return
   end

   local new_width = math.max(width, scratch_width)
   local new_height = math.max(height, scratch_height)

   if scratch_image then
      free(scratch_image)
   end

   if scratch_pixelmap then
      free(scratch_pixelmap)
   end

   scratch_width = new_width
   scratch_height = new_height

   scratch_pixelmap = raster.new_pixelmap(scratch_width, scratch_height)
   scratch_image = graphics.new_image_from_pixelmap(scratch_pixelmap)
end

local function clear_scratch()
   raster.blit_rect(scratch_pixelmap, 0, 0, scratch_width, scratch_height, TRANSPARENT, "replace")
end

local function draw_scratch(x, y, width, height)
   graphics.update_image_from_pixelmap(scratch_image, scratch_pixelmap)
   graphics.draw_image_region(scratch_image, 0, 0, width, height, x, y)
end

local function get_bounds(points)
   local minimum_x = points[1][1]
   local minimum_y = points[1][2]
   local maximum_x = minimum_x
   local maximum_y = minimum_y

   for i = 2, #points do
      local point_x = points[i][1]
      local point_y = points[i][2]

      minimum_x = math.min(minimum_x, point_x)
      minimum_y = math.min(minimum_y, point_y)
      maximum_x = math.max(maximum_x, point_x)
      maximum_y = math.max(maximum_y, point_y)
   end

   return minimum_x, minimum_y, maximum_x, maximum_y
end

function rat.shape_line(start_x, start_y, end_x, end_y, color)
   local minimum_x = math.min(start_x, end_x)
   local minimum_y = math.min(start_y, end_y)
   local maximum_x = math.max(start_x, end_x)
   local maximum_y = math.max(start_y, end_y)

   local width = maximum_x - minimum_x + 1
   local height = maximum_y - minimum_y + 1

   ensure_scratch(width, height)
   clear_scratch()

   raster.blit_line(
      scratch_pixelmap,
      start_x - minimum_x,
      start_y - minimum_y,
      end_x - minimum_x,
      end_y - minimum_y,
      color
   )

   draw_scratch(minimum_x, minimum_y, width, height)
end

function rat.shape_rect(x, y, width, height, color)
   if width <= 0 or height <= 0 then
      return
   end

   ensure_scratch(width, height)
   clear_scratch()

   raster.blit_line(scratch_pixelmap, 0, 0, width - 1, 0, color)
   raster.blit_line(scratch_pixelmap, width - 1, 0, width - 1, height - 1, color)
   raster.blit_line(scratch_pixelmap, width - 1, height - 1, 0, height - 1, color)
   raster.blit_line(scratch_pixelmap, 0, height - 1, 0, 0, color)

   draw_scratch(x, y, width, height)
end

function rat.shape_rect_fill(x, y, width, height, color)
   if width <= 0 or height <= 0 then
      return
   end

   ensure_scratch(width, height)
   clear_scratch()

   raster.blit_rect(scratch_pixelmap, 0, 0, width, height, color)

   draw_scratch(x, y, width, height)
end

function rat.shape_rect_dither(x, y, width, height, color_1, color_2, pattern)
   if width <= 0 or height <= 0 then
      return
   end

   ensure_scratch(width, height)
   clear_scratch()

   local pattern_height = #pattern
   local pattern_width = #pattern[1]

   for pixel_y = 0, height - 1 do
      local pattern_y = ((y + pixel_y) % pattern_height) + 1
      for pixel_x = 0, width - 1 do
         local pattern_x = ((x + pixel_x) % pattern_width) + 1
         if pattern[pattern_y][pattern_x] == 1 then
            raster.set_pixel(scratch_pixelmap, pixel_x, pixel_y, color_1)
         else
            raster.set_pixel(scratch_pixelmap, pixel_x, pixel_y, color_2)
         end
      end
   end

   draw_scratch(x, y, width, height)
end

function rat.shape_circle(center_x, center_y, radius, color)
   if radius < 0 then
      return
   end

   local diameter = radius * 2 + 1

   ensure_scratch(diameter, diameter)
   clear_scratch()

   raster.blit_circle_pixel_outline(scratch_pixelmap, radius, radius, radius, color)

   draw_scratch(center_x - radius, center_y - radius, diameter, diameter)
end

function rat.shape_circle_fill(center_x, center_y, radius, color)
   if radius < 0 then
      return
   end

   local diameter = radius * 2 + 1

   ensure_scratch(diameter, diameter)
   clear_scratch()

   raster.blit_circle(scratch_pixelmap, radius, radius, radius, color)

   draw_scratch(center_x - radius, center_y - radius, diameter, diameter)
end

function rat.shape_triangle(point_a_x, point_a_y, point_b_x, point_b_y, point_c_x, point_c_y, color)
   local minimum_x = math.min(point_a_x, point_b_x, point_c_x)
   local minimum_y = math.min(point_a_y, point_b_y, point_c_y)
   local maximum_x = math.max(point_a_x, point_b_x, point_c_x)
   local maximum_y = math.max(point_a_y, point_b_y, point_c_y)

   local width = maximum_x - minimum_x + 1
   local height = maximum_y - minimum_y + 1

   ensure_scratch(width, height)
   clear_scratch()

   local point_a_local_x = point_a_x - minimum_x
   local point_a_local_y = point_a_y - minimum_y
   local point_b_local_x = point_b_x - minimum_x
   local point_b_local_y = point_b_y - minimum_y
   local point_c_local_x = point_c_x - minimum_x
   local point_c_local_y = point_c_y - minimum_y

   raster.blit_line(scratch_pixelmap, point_a_local_x, point_a_local_y, point_b_local_x, point_b_local_y, color)
   raster.blit_line(scratch_pixelmap, point_b_local_x, point_b_local_y, point_c_local_x, point_c_local_y, color)
   raster.blit_line(scratch_pixelmap, point_c_local_x, point_c_local_y, point_a_local_x, point_a_local_y, color)

   draw_scratch(minimum_x, minimum_y, width, height)
end

function rat.shape_triangle_fill(point_a_x, point_a_y, point_b_x, point_b_y, point_c_x, point_c_y, color)
   local minimum_x = math.min(point_a_x, point_b_x, point_c_x)
   local minimum_y = math.min(point_a_y, point_b_y, point_c_y)
   local maximum_x = math.max(point_a_x, point_b_x, point_c_x)
   local maximum_y = math.max(point_a_y, point_b_y, point_c_y)

   local width = maximum_x - minimum_x + 1
   local height = maximum_y - minimum_y + 1

   ensure_scratch(width, height)
   clear_scratch()

   raster.blit_triangle(
      scratch_pixelmap,
      point_a_x - minimum_x,
      point_a_y - minimum_y,
      point_b_x - minimum_x,
      point_b_y - minimum_y,
      point_c_x - minimum_x,
      point_c_y - minimum_y,
      color
   )

   draw_scratch(minimum_x, minimum_y, width, height)
end

function rat.shape_polygon(points, color)
   if #points < 2 then
      return
   end

   local minimum_x, minimum_y, maximum_x, maximum_y = get_bounds(points)
   local width = maximum_x - minimum_x + 1
   local height = maximum_y - minimum_y + 1

   ensure_scratch(width, height)
   clear_scratch()

   for point_index = 1, #points do
      local next_point_index = point_index + 1

      if next_point_index > #points then
         next_point_index = 1
      end

      local current_point = points[point_index]
      local next_point = points[next_point_index]

      raster.blit_line(
         scratch_pixelmap,
         current_point[1] - minimum_x,
         current_point[2] - minimum_y,
         next_point[1] - minimum_x,
         next_point[2] - minimum_y,
         color)
   end

   draw_scratch(minimum_x, minimum_y, width, height)
end

function rat.shape_polygon_fill(points, color)
   if #points < 3 then
      return
   end

   local minimum_x, minimum_y, maximum_x, maximum_y = get_bounds(points)
   local width = maximum_x - minimum_x + 1
   local height = maximum_y - minimum_y + 1

   ensure_scratch(width, height)
   clear_scratch()

   local local_points = {}

   for point_index = 1, #points do
      local_points[point_index] = {
         points[point_index][1] - minimum_x,
         points[point_index][2] - minimum_y,
      }
   end

   for scanline_y = 0, height - 1 do
      local intersections = {}

      for point_index = 1, #local_points do
         local next_point_index = point_index + 1

         if next_point_index > #local_points then
            next_point_index = 1
         end

         local current_point = local_points[point_index]
         local next_point = local_points[next_point_index]

         local start_x = current_point[1]
         local start_y = current_point[2]
         local end_x = next_point[1]
         local end_y = next_point[2]

         if (start_y <= scanline_y and end_y > scanline_y) or (end_y <= scanline_y and start_y > scanline_y) then
            local intersection_x = start_x + (scanline_y - start_y) * (end_x - start_x) / (end_y - start_y)
            intersections[#intersections + 1] = intersection_x
         end
      end

      table.sort(intersections)

      for intersection_index = 1, #intersections - 1, 2 do
         local fill_start_x = math.ceil(intersections[intersection_index])
         local fill_end_x = math.floor(intersections[intersection_index + 1])

         if fill_end_x >= fill_start_x then
            raster.blit_line(scratch_pixelmap, fill_start_x, scanline_y, fill_end_x, scanline_y, color)
         end
      end
   end

   draw_scratch(minimum_x, minimum_y, width, height)
end

-- TWEENS
function rat.tween_new(duration_seconds)
   return {
      duration = duration_seconds,
      elapsed = 0,
      finished = false,
   }
end

function rat.tween_update(tween_state, delta_time)
   if tween_state.finished then
      return
   end

   tween_state.elapsed = tween_state.elapsed + delta_time

   if tween_state.elapsed >= tween_state.duration then
      tween_state.elapsed = tween_state.duration
      tween_state.finished = true
   end
end

function rat.tween_reset(tween_state)
   tween_state.elapsed = 0
   tween_state.finished = false
end

function rat.tween_time(tween_state)
   return math.max(0, math.min(tween_state.elapsed / tween_state.duration, 1))
end

-- TWEEN EASING
function rat.tween_linear(time)
   return time
end

function rat.tween_sine_in(time)
   return 1 - math.cos((time * math.pi) / 2)
end

function rat.tween_sine_out(time)
   return math.sin((time * math.pi) / 2)
end

function rat.tween_sine_in_out(time)
   return -(math.cos(math.pi * time) - 1) / 2
end

-- TWEEN MOTION
function rat.tween_hop(maximum_height, time)
   return 4 * maximum_height * time * (1 - time)
end

function rat.tween_bump(maximum_distance, time)
   if time <= 0.5 then
      return maximum_distance * rat.tween_sine_out(time * 2)
   end

   return maximum_distance * rat.tween_sine_in((1 - time) * 2)
end

function rat.tween_pulse(minimum_value, maximum_value, time)
   local value_range = maximum_value - minimum_value

   if time <= 0.5 then
      return minimum_value + value_range * rat.tween_sine_out(time * 2)
   end

   return minimum_value + value_range * rat.tween_sine_in((1 - time) * 2)
end

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SPRITES
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
function rat.sprite_load_atlas(path, sprite_width, sprite_height)
   local image, err = graphics.load_image(path)

   if not image then
      error("Failed to load sprite atlas '" .. path .. "': " .. tostring(err))
   end

   local image_width, image_height = graphics.get_image_size(image)

   return {
      image = image,
      sprite_width = sprite_width,
      sprite_height = sprite_height,
      columns = math.floor(image_width / sprite_width),
      rows = math.floor(image_height / sprite_height),
   }
end

function rat.sprite_draw(atlas, index, gx, gy)
   local zero_index = index - 1

   local atlas_x = zero_index % atlas.columns
   local atlas_y = math.floor(zero_index / atlas.columns)

   local source_x = atlas_x * atlas.sprite_width
   local source_y = atlas_y * atlas.sprite_height

   local draw_x = gx * atlas.sprite_width
   local draw_y = gy * atlas.sprite_height

   graphics.draw_image_region(
      atlas.image,
      source_x,
      source_y,
      atlas.sprite_width,
      atlas.sprite_height,
      draw_x,
      draw_y
   )
end

function rat.sprite_animate_frames(atlas, first_index, last_index, fps, gx, gy)
   local frame_count = last_index - first_index + 1
   local frame = math.floor(os.clock() * fps) % frame_count
   local index = first_index + frame

   rat.sprite_draw(atlas, index, gx, gy)
end

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- IMGUI
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------

rat.gui = {
   hot_id = 0,
   active_id = 0,

   mouse_x = 0,
   mouse_y = 0,
   mouse_pressed = false,
   mouse_released = false,

   color_outline = rgba(100, 100, 100, 255),
   color_panel = rgba(30, 30, 30, 255),

   color_cold = rgba(50, 50, 50, 255),
   color_hot = rgba(75, 75, 75, 255),
   color_image_cold = rgba(0, 0, 0, 51),
   color_image_hot = rgba(0, 0, 0, 26),
   color_active = rgba(100, 100, 100, 255),
   color_text = rgba(255, 255, 255, 255),

   text_padding = 4,
   text_edit_id = 0,
   text_scroll = 0,
   caret = 0,
   caret_timer = 0,
   caret_visible = true,
}

local function gui_require_id(id)
   if id == nil or id == 0 then
      error("GUI widget id must be an explicit non-zero value", 3)
   end
end

local function gui_mouse_in_bounds(x, y, width, height)
   return rat.gui.mouse_x >= x
       and rat.gui.mouse_x < x + width
       and rat.gui.mouse_y >= y
       and rat.gui.mouse_y < y + height
end

function rat.gui_init(dt)
   rat.gui.hot_id = 0
   rat.gui.mouse_x = rat.res.mouse_x
   rat.gui.mouse_y = rat.res.mouse_y
   rat.gui.mouse_pressed = input.pressed("mouse1")
   rat.gui.mouse_released = input.released("mouse1")

   rat.gui.caret_timer = rat.gui.caret_timer + (dt or 0)

   if rat.gui.caret_timer >= 0.5 then
      rat.gui.caret_timer = rat.gui.caret_timer - 0.5
      rat.gui.caret_visible = not rat.gui.caret_visible
   end
end

function rat.gui_panel(x, y, width, height, color)
   color = color or rat.gui.color_panel

   graphics.draw_rect(x, y, width, height, rat.gui.color_outline)

   if width > 2 and height > 2 then
      graphics.draw_rect(x + 1, y + 1, width - 2, height - 2, color)
   end
end

function rat.gui_centered_text(text, x, y, width, height)
   local _, text_height = graphics.measure_text_wrap(text, width)
   local text_y = math.floor(y + (height - text_height) / 2)

   graphics.set_text_alignment("center")
   graphics.draw_text_wrap(text, x, text_y, width, rat.gui.color_text)
   graphics.set_text_alignment("left")
end

function rat.gui_button(id, x, y, width, height)
   gui_require_id(id)

   local pressed = false
   local color = rat.gui.color_cold

   if gui_mouse_in_bounds(x, y, width, height) then
      rat.gui.hot_id = id
   end

   if rat.gui.hot_id == id and rat.gui.mouse_pressed then
      if rat.gui.text_edit_id ~= 0 then
         rat.gui.text_edit_id = 0
         input.stop_text()
      end

      rat.gui.active_id = id
   end

   if rat.gui.active_id == id and rat.gui.mouse_released then
      if rat.gui.hot_id == id then
         pressed = true
      end

      rat.gui.active_id = 0
   end

   if rat.gui.active_id == id then
      color = rat.gui.color_active
   elseif rat.gui.hot_id == id then
      color = rat.gui.color_hot
   end

   rat.gui_panel(x, y, width, height, color)

   return pressed
end

function rat.gui_text_button(id, text, x, y, width, height)
   local pressed = rat.gui_button(id, x, y, width, height)

   rat.gui_centered_text(text, x, y, width, height)

   return pressed
end

function rat.gui_image_button(id, image, x, y, width, height)
   local pressed = rat.gui_button(id, x, y, width, height)
   local image_width, image_height = graphics.get_image_size(image)
   local scale = math.min(width / image_width, height / image_height)

   local draw_width = image_width * scale
   local draw_height = image_height * scale
   local draw_x = math.floor(x + (width - draw_width) / 2)
   local draw_y = math.floor(y + (height - draw_height) / 2)

   graphics.begin_transform()
   graphics.set_translation(draw_x, draw_y)
   graphics.set_scale(scale)
   graphics.draw_image(image, 0, 0)
   graphics.end_transform()

   if rat.gui.active_id == id then
      -- Active image buttons are shown at full brightness.
   elseif rat.gui.hot_id == id then
      graphics.draw_rect(x, y, width, height, rat.gui.color_image_hot)
   else
      graphics.draw_rect(x, y, width, height, rat.gui.color_image_cold)
   end

   return pressed
end

function rat.gui_text_box(text, x, y, width, height)
   local padding = rat.gui.text_padding
   local draw_x = x + padding
   local draw_y = y + padding
   local right = x + width - padding
   local bottom = y + height - padding
   local line_height = graphics.get_font_line_skip()

   rat.gui_panel(x, y, width, height)

   for character_index = 1, #text do
      local character = text:sub(character_index, character_index)
      local character_width = graphics.measure_text(character)

      if character == "\n" then
         draw_x = x + padding
         draw_y = draw_y + line_height
      else
         if draw_x + character_width > right then
            draw_x = x + padding
            draw_y = draw_y + line_height
         end

         if draw_y + line_height > bottom then
            break
         end

         graphics.draw_text(character, draw_x, draw_y, rat.gui.color_text)
         draw_x = draw_x + character_width
      end
   end
end

function rat.gui_text_field(id, x, y, width, height, text)
   gui_require_id(id)

   if type(text) ~= "string" then
      error("GUI text field value must be a string", 2)
   end

   local inside = gui_mouse_in_bounds(x, y, width, height)
   local color = rat.gui.color_cold
   local text_changed = false
   local caret_moved = false

   if inside then
      rat.gui.hot_id = id
   end

   if rat.gui.hot_id == id and rat.gui.mouse_pressed then
      if rat.gui.text_edit_id ~= 0 and rat.gui.text_edit_id ~= id then
         input.stop_text()
      end

      rat.gui.active_id = id
      rat.gui.text_edit_id = id
      rat.gui.caret = #text
      rat.gui.text_scroll = 0
      rat.gui.caret_timer = 0
      rat.gui.caret_visible = true
      input.start_text()
   elseif rat.gui.active_id == id and rat.gui.mouse_pressed and not inside then
      rat.gui.active_id = 0
      rat.gui.text_edit_id = 0
      input.stop_text()
   end

   if rat.gui.active_id == id then
      rat.gui.caret = math.min(rat.gui.caret, #text)

      local entered = input.get_text()
      local backspace = input.pressed("backspace") or input.repeated("backspace")
      local move_left = input.pressed("left") or input.repeated("left")
      local move_right = input.pressed("right") or input.repeated("right")
      local modifier = input.down("lctrl") or input.down("rctrl")
          or input.down("lsuper") or input.down("rsuper")

      if entered ~= "" then
         text = text:sub(1, rat.gui.caret) .. entered .. text:sub(rat.gui.caret + 1)
         rat.gui.caret = rat.gui.caret + #entered
         text_changed = true
         caret_moved = true
      end

      if backspace and rat.gui.caret > 0 then
         if modifier then
            local delete_from = rat.gui.caret

            while delete_from > 0 and text:sub(delete_from, delete_from) == " " do
               delete_from = delete_from - 1
            end

            while delete_from > 0 and text:sub(delete_from, delete_from) ~= " " do
               delete_from = delete_from - 1
            end

            text = text:sub(1, delete_from) .. text:sub(rat.gui.caret + 1)
            rat.gui.caret = delete_from
         else
            text = text:sub(1, rat.gui.caret - 1) .. text:sub(rat.gui.caret + 1)
            rat.gui.caret = rat.gui.caret - 1
         end

         text_changed = true
         caret_moved = true
      end

      if move_left and rat.gui.caret > 0 then
         rat.gui.caret = rat.gui.caret - 1
         caret_moved = true
      end

      if move_right and rat.gui.caret < #text then
         rat.gui.caret = rat.gui.caret + 1
         caret_moved = true
      end

      if input.pressed("return") then
         rat.gui.active_id = 0
         rat.gui.text_edit_id = 0
         input.stop_text()
      end

      if text_changed or caret_moved then
         rat.gui.caret_timer = 0
         rat.gui.caret_visible = true
      end
   end

   if rat.gui.active_id == id then
      color = rat.gui.color_active
   elseif rat.gui.hot_id == id then
      color = rat.gui.color_hot
   end

   rat.gui_panel(x, y, width, height, color)

   local padding = rat.gui.text_padding
   local inner_width = width - padding * 2
   local _, text_height = graphics.measure_text(text ~= "" and text or "A")
   local draw_y = math.floor(y + (height - text_height) / 2)
   local text_scroll = 0

   if rat.gui.text_edit_id == id then
      if rat.gui.caret < rat.gui.text_scroll then
         rat.gui.text_scroll = rat.gui.caret
      end

      while rat.gui.text_scroll < rat.gui.caret do
         local visible_to_caret = text:sub(rat.gui.text_scroll + 1, rat.gui.caret)
         local visible_width = graphics.measure_text(visible_to_caret)

         if visible_width + 1 <= inner_width then
            break
         end

         rat.gui.text_scroll = rat.gui.text_scroll + 1
      end

      while rat.gui.text_scroll > 0 do
         local previous_scroll = rat.gui.text_scroll - 1
         local visible_to_caret = text:sub(previous_scroll + 1, rat.gui.caret)
         local visible_width = graphics.measure_text(visible_to_caret)

         if visible_width + 1 > inner_width then
            break
         end

         rat.gui.text_scroll = previous_scroll
      end

      text_scroll = rat.gui.text_scroll
   end

   local draw_x = x + padding
   local right = x + width - padding

   for character_index = text_scroll + 1, #text do
      local character = text:sub(character_index, character_index)
      local character_width = graphics.measure_text(character)

      if rat.gui.active_id == id and rat.gui.caret == character_index - 1 and rat.gui.caret_visible then
         graphics.draw_rect(draw_x, draw_y, 1, text_height, rat.gui.color_text)
      end

      if draw_x + character_width > right then
         break
      end

      graphics.draw_text(character, draw_x, draw_y, rat.gui.color_text)
      draw_x = draw_x + character_width
   end

   if rat.gui.active_id == id and rat.gui.caret == #text and rat.gui.caret_visible and draw_x < right then
      graphics.draw_rect(draw_x, draw_y, 1, text_height, rat.gui.color_text)
   end

   return text
end

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DATA
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------

local lua_keywords = {
   ["and"] = true,
   ["break"] = true,
   ["do"] = true,
   ["else"] = true,
   ["elseif"] = true,
   ["end"] = true,
   ["false"] = true,
   ["for"] = true,
   ["function"] = true,
   ["if"] = true,
   ["in"] = true,
   ["local"] = true,
   ["nil"] = true,
   ["not"] = true,
   ["or"] = true,
   ["repeat"] = true,
   ["return"] = true,
   ["then"] = true,
   ["true"] = true,
   ["until"] = true,
   ["while"] = true,
}

local function data_serialize_number(value)
   if value ~= value then
      return "(0 / 0)"
   elseif value == math.huge then
      return "(1 / 0)"
   elseif value == -math.huge then
      return "(-1 / 0)"
   end

   return tostring(value)
end

local function data_serialize_value(value, active_tables, indentation)
   local value_type = type(value)

   if value_type == "nil" then
      return "nil"
   elseif value_type == "string" then
      return string.format("%q", value)
   elseif value_type == "number" then
      return data_serialize_number(value)
   elseif value_type == "boolean" then
      return tostring(value)
   elseif value_type ~= "table" then
      error("Cannot serialize data of type '" .. value_type .. "'", 0)
   end

   if getmetatable(value) ~= nil then
      error("Cannot serialize a table with a metatable", 0)
   end

   if active_tables[value] then
      error("Cannot serialize cyclic table data", 0)
   end

   active_tables[value] = true

   local next_indentation = indentation .. "   "
   local entries = {}
   local array_length = 0

   while rawget(value, array_length + 1) ~= nil do
      array_length = array_length + 1
   end

   for array_index = 1, array_length do
      entries[#entries + 1] = next_indentation
          .. data_serialize_value(rawget(value, array_index), active_tables, next_indentation)
   end

   for key, entry_value in next, value do
      local is_array_key = type(key) == "number"
          and key >= 1
          and key <= array_length
          and key == math.floor(key)

      if not is_array_key then
         local key_type = type(key)

         if key_type ~= "string" and key_type ~= "number" and key_type ~= "boolean" then
            error("Cannot serialize table key of type '" .. key_type .. "'", 0)
         end

         local serialized_key

         if key_type == "string" and key:match("^[%a_][%w_]*$") and not lua_keywords[key] then
            serialized_key = key
         else
            serialized_key = "[" .. data_serialize_value(key, active_tables, next_indentation) .. "]"
         end

         entries[#entries + 1] = next_indentation .. serialized_key .. " = "
             .. data_serialize_value(entry_value, active_tables, next_indentation)
      end
   end

   active_tables[value] = nil

   if #entries == 0 then
      return "{}"
   end

   return "{\n" .. table.concat(entries, ",\n") .. ",\n" .. indentation .. "}"
end

local function data_validate(value, active_tables)
   local value_type = type(value)

   if value_type == "nil" or value_type == "string" or value_type == "number" or value_type == "boolean" then
      return
   elseif value_type ~= "table" then
      error("Loaded data contains unsupported type '" .. value_type .. "'", 0)
   end

   if getmetatable(value) ~= nil then
      error("Loaded data contains a table with a metatable", 0)
   end

   if active_tables[value] then
      error("Loaded data contains cyclic table data", 0)
   end

   active_tables[value] = true

   for key, entry_value in next, value do
      local key_type = type(key)

      if key_type ~= "string" and key_type ~= "number" and key_type ~= "boolean" then
         error("Loaded data contains a table key of type '" .. key_type .. "'", 0)
      end

      data_validate(entry_value, active_tables)
   end

   active_tables[value] = nil
end

function rat.data_save(path, data)
   local serialized_data = "return " .. data_serialize_value(data, {}, "") .. "\n"
   return filesystem.write_file(path, serialized_data)
end

function rat.data_load(path)
   local serialized_data, read_error = filesystem.read_file(path)

   if not serialized_data then
      return nil, read_error
   end

   local chunk, load_error = loadstring(serialized_data, "@" .. path)

   if not chunk then
      return nil, load_error
   end

   setfenv(chunk, {})

   local loaded, data = pcall(chunk)

   if not loaded then
      return nil, data
   end

   local valid, validation_error = pcall(data_validate, data, {})

   if not valid then
      return nil, validation_error
   end

   return data
end

return rat
