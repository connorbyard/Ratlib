rat = {}

-- MATHS
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

-- GEOMETRY
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

-- RESOLUTION
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

-- SHAPES
local TRANSPARENT = rgba(0, 0, 0, 0)

local scratch_pixelmap = nil
local scratch_image = nil
local scratch_width = 0
local scratch_height = 0

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

-- SPRITES
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

return rat
