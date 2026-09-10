--- Small procedural utility library for Newt.
-- @module rat
rat = {}

-- ---------------------------------------------------------------------------------------------------------------------
-- MATHS
-- ---------------------------------------------------------------------------------------------------------------------

--- Numeric helper functions.
-- @table rat.maths
rat.maths = {}
--- Clamp a value between a minimum and maximum.
-- @param value number: Value to clamp.
-- @param minimum_value number: Minimum value.
-- @param maximum_value number: Maximum value.
-- @return number: Clamped value.
function rat.maths.clamp(value, minimum_value, maximum_value)
   return math.max(minimum_value, math.min(value, maximum_value))
end

--- Linearly interpolate between two values.
-- @param start_value number: Starting value.
-- @param end_value number: Ending value.
-- @param interpolation_amount number: Interpolation amount, normally from 0 to 1.
-- @return number: Interpolated value.
function rat.maths.lerp(start_value, end_value, interpolation_amount)
   return start_value + (end_value - start_value) * interpolation_amount
end

--- Return the interpolation amount of a value between two endpoints.
-- @param start_value number: Starting value.
-- @param end_value number: Ending value.
-- @param value number: Value to measure.
-- @return number: Interpolation amount.
function rat.maths.inverse_lerp(start_value, end_value, value)
   return (value - start_value) / (end_value - start_value)
end

--- Remap a value from one numeric range to another.
-- @param value number: Value to remap.
-- @param input_minimum number: Input range minimum.
-- @param input_maximum number: Input range maximum.
-- @param output_minimum number: Output range minimum.
-- @param output_maximum number: Output range maximum.
-- @return number: Remapped value.
function rat.maths.remap(value, input_minimum, input_maximum, output_minimum, output_maximum)
   local interpolation_amount = rat.maths.inverse_lerp(input_minimum, input_maximum, value)
   return rat.maths.lerp(output_minimum, output_maximum, interpolation_amount)
end

--- Round a number to the nearest integer.
-- @param value number: Value to round.
-- @return number: Rounded value.
function rat.maths.round(value)
   return math.floor(value + 0.5)
end

--- Return the sign of a number.
-- @param value number: Value to inspect.
-- @return number: -1, 0, or 1.
function rat.maths.sign(value)
   if value < 0 then
      return -1
   elseif value > 0 then
      return 1
   end

   return 0
end

--- Calculate Euclidean distance between two points.
-- @param point_a_x number: First point x coordinate.
-- @param point_a_y number: First point y coordinate.
-- @param point_b_x number: Second point x coordinate.
-- @param point_b_y number: Second point y coordinate.
-- @return number: Distance between the points.
function rat.maths.distance(point_a_x, point_a_y, point_b_x, point_b_y)
   local distance_x = point_b_x - point_a_x
   local distance_y = point_b_y - point_a_y

   return math.sqrt(distance_x * distance_x + distance_y * distance_y)
end

--- Snap a value to the nearest step.
-- @param value number: Value to snap.
-- @param step_size number: Snap interval.
-- @return number: Snapped value.
function rat.maths.snap(value, step_size)
   return rat.maths.round(value / step_size) * step_size
end

--- Move a value toward a target without overshooting.
-- @param current_value number: Current value.
-- @param target_value number: Target value.
-- @param step_size number: Maximum change.
-- @return number: Updated value.
function rat.maths.approach(current_value, target_value, step_size)
   if current_value < target_value then
      return math.min(current_value + step_size, target_value)
   elseif current_value > target_value then
      return math.max(current_value - step_size, target_value)
   end

   return target_value
end

-- ---------------------------------------------------------------------------------------------------------------------
-- GEOMETRY
-- ---------------------------------------------------------------------------------------------------------------------

--- Geometry helper functions.
-- @table rat.geo
rat.geo = {}

--- Test whether a point lies inside a rectangle.
-- @param point_x number: Point x coordinate.
-- @param point_y number: Point y coordinate.
-- @param rect_x number: Rectangle x coordinate.
-- @param rect_y number: Rectangle y coordinate.
-- @param rect_width number: Rectangle width.
-- @param rect_height number: Rectangle height.
-- @return boolean: True when the point lies inside the rectangle.
function rat.geo.point_in_rect(point_x, point_y, rect_x, rect_y, rect_width, rect_height)
   return point_x >= rect_x
       and point_x <= rect_x + rect_width
       and point_y >= rect_y
       and point_y <= rect_y + rect_height
end

--- Test whether two rectangles overlap.
-- @param rect_a_x number: First rectangle x coordinate.
-- @param rect_a_y number: First rectangle y coordinate.
-- @param rect_a_width number: First rectangle width.
-- @param rect_a_height number: First rectangle height.
-- @param rect_b_x number: Second rectangle x coordinate.
-- @param rect_b_y number: Second rectangle y coordinate.
-- @param rect_b_width number: Second rectangle width.
-- @param rect_b_height number: Second rectangle height.
-- @return boolean: True when the rectangles overlap.
function rat.geo.rects_overlap(rect_a_x, rect_a_y, rect_a_width, rect_a_height, rect_b_x, rect_b_y, rect_b_width,
                               rect_b_height)
   return rect_a_x < rect_b_x + rect_b_width
       and rect_a_x + rect_a_width > rect_b_x
       and rect_a_y < rect_b_y + rect_b_height
       and rect_a_y + rect_a_height > rect_b_y
end

-- ---------------------------------------------------------------------------------------------------------------------
-- RESOLUTION
-- ---------------------------------------------------------------------------------------------------------------------

--- Virtual-resolution state and helpers.
-- @field width Virtual canvas width.
-- @field height Virtual canvas height.
-- @field scale Current window-to-virtual scale.
-- @field offset_x Horizontal letterbox offset.
-- @field offset_y Vertical letterbox offset.
-- @field mouse_x Mouse x coordinate in virtual space.
-- @field mouse_y Mouse y coordinate in virtual space.
-- @table rat.res
rat.res = {
   width = 1280,
   height = 720,
   scale = 1,
   offset_x = 0,
   offset_y = 0,
   mouse_x = 0,
   mouse_y = 0,
}

--- Initialise the virtual resolution.
-- @param width number: Virtual width.
-- @param height number: Virtual height.
function rat.res.initialise(width, height)
   rat.res.width = width
   rat.res.height = height
   rat.res.update()
end

--- Update virtual-resolution scale, letterbox offsets, and virtual mouse coordinates.
function rat.res.update()
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

--- Begin drawing in virtual-resolution space.
function rat.res.begin()
   graphics.begin_transform()
   graphics.set_translation(rat.res.offset_x, rat.res.offset_y)
   graphics.set_scale(rat.res.scale, rat.res.scale)
end

--- Finish drawing in virtual-resolution space.
function rat.res.finish()
   graphics.end_transform()
end

-- ---------------------------------------------------------------------------------------------------------------------
-- SHAPES
-- ---------------------------------------------------------------------------------------------------------------------
--- Primitive shape drawing utilities.
-- @table rat.shape
-- @field dither_checkered 50% checkerboard dither pattern.
-- @field dither_25 25% dither pattern.
-- @field dither_75 75% dither pattern.
rat.shape = {}

rat.shape.dither_checkered = { { 1, 0 }, { 0, 1 } }
rat.shape.dither_25 = { { 1, 0 }, { 0, 0 } }
rat.shape.dither_75 = { { 1, 1 }, { 1, 0 } }

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

   if scratch_image then free(scratch_image) end

   if scratch_pixelmap then free(scratch_pixelmap) end

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

--- Draw a one-pixel line.
-- @param start_x number: Start x coordinate.
-- @param start_y number: Start y coordinate.
-- @param end_x number: End x coordinate.
-- @param end_y number: End y coordinate.
-- @param color number: Packed RGBA colour.
function rat.shape.line(start_x, start_y, end_x, end_y, color)
   local minimum_x = math.min(start_x, end_x)
   local minimum_y = math.min(start_y, end_y)
   local maximum_x = math.max(start_x, end_x)
   local maximum_y = math.max(start_y, end_y)

   local width = maximum_x - minimum_x + 1
   local height = maximum_y - minimum_y + 1

   ensure_scratch(width, height)
   clear_scratch()

   raster.blit_line(scratch_pixelmap, start_x - minimum_x, start_y - minimum_y, end_x - minimum_x, end_y - minimum_y,
      color)

   draw_scratch(minimum_x, minimum_y, width, height)
end

--- Draw a one-pixel rectangle outline.
-- @param x number: Left coordinate.
-- @param y number: Top coordinate.
-- @param width number: Width.
-- @param height number: Height.
-- @param color number: Packed RGBA colour.
function rat.shape.rect(x, y, width, height, color)
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

--- Draw a filled rectangle.
-- @param x number: Left coordinate.
-- @param y number: Top coordinate.
-- @param width number: Width.
-- @param height number: Height.
-- @param color number: Packed RGBA colour.
function rat.shape.rect_fill(x, y, width, height, color)
   if width <= 0 or height <= 0 then
      return
   end

   ensure_scratch(width, height)
   clear_scratch()

   raster.blit_rect(scratch_pixelmap, 0, 0, width, height, color)

   draw_scratch(x, y, width, height)
end

--- Draw a dithered rectangle using two colours and a repeating pattern.
-- @param x number: Left coordinate.
-- @param y number: Top coordinate.
-- @param width number: Width.
-- @param height number: Height.
-- @param color_1 number: First packed RGBA colour.
-- @param color_2 number: Second packed RGBA colour.
-- @param pattern table: Two-dimensional dither pattern.
function rat.shape.rect_dither(x, y, width, height, color_1, color_2, pattern)
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

--- Draw a one-pixel circle outline.
-- @param center_x number: Centre x coordinate.
-- @param center_y number: Centre y coordinate.
-- @param radius number: Radius in pixels.
-- @param color number: Packed RGBA colour.
function rat.shape.circle(center_x, center_y, radius, color)
   if radius < 0 then
      return
   end

   local diameter = radius * 2 + 1

   ensure_scratch(diameter, diameter)
   clear_scratch()

   raster.blit_circle_pixel_outline(scratch_pixelmap, radius, radius, radius, color)

   draw_scratch(center_x - radius, center_y - radius, diameter, diameter)
end

--- Draw a filled circle.
-- @param center_x number: Centre x coordinate.
-- @param center_y number: Centre y coordinate.
-- @param radius number: Radius in pixels.
-- @param color number: Packed RGBA colour.
function rat.shape.circle_fill(center_x, center_y, radius, color)
   if radius < 0 then
      return
   end

   local diameter = radius * 2 + 1

   ensure_scratch(diameter, diameter)
   clear_scratch()

   raster.blit_circle(scratch_pixelmap, radius, radius, radius, color)

   draw_scratch(center_x - radius, center_y - radius, diameter, diameter)
end

--- Draw a triangle outline.
-- @param point_a_x number: First point x coordinate.
-- @param point_a_y number: First point y coordinate.
-- @param point_b_x number: Second point x coordinate.
-- @param point_b_y number: Second point y coordinate.
-- @param point_c_x number: Third point x coordinate.
-- @param point_c_y number: Third point y coordinate.
-- @param color number: Packed RGBA colour.
function rat.shape.triangle(point_a_x, point_a_y, point_b_x, point_b_y, point_c_x, point_c_y, color)
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

--- Draw a filled triangle.
-- @param point_a_x number: First point x coordinate.
-- @param point_a_y number: First point y coordinate.
-- @param point_b_x number: Second point x coordinate.
-- @param point_b_y number: Second point y coordinate.
-- @param point_c_x number: Third point x coordinate.
-- @param point_c_y number: Third point y coordinate.
-- @param color number: Packed RGBA colour.
function rat.shape.triangle_fill(point_a_x, point_a_y, point_b_x, point_b_y, point_c_x, point_c_y, color)
   local minimum_x = math.min(point_a_x, point_b_x, point_c_x)
   local minimum_y = math.min(point_a_y, point_b_y, point_c_y)
   local maximum_x = math.max(point_a_x, point_b_x, point_c_x)
   local maximum_y = math.max(point_a_y, point_b_y, point_c_y)

   local width = maximum_x - minimum_x + 1
   local height = maximum_y - minimum_y + 1

   ensure_scratch(width, height)
   clear_scratch()

   raster.blit_triangle(scratch_pixelmap, point_a_x - minimum_x, point_a_y - minimum_y,
      point_b_x - minimum_x, point_b_y - minimum_y, point_c_x - minimum_x, point_c_y - minimum_y, color)

   draw_scratch(minimum_x, minimum_y, width, height)
end

--- Draw a closed polygon outline.
-- @param points table: Array of {x, y} points.
-- @param color number: Packed RGBA colour.
function rat.shape.polygon(points, color)
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

--- Draw a filled polygon.
-- @param points table: Array of {x, y} points.
-- @param color number: Packed RGBA colour.
function rat.shape.polygon_fill(points, color)
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

-- ---------------------------------------------------------------------------------------------------------------------
-- TWEENS
-- ---------------------------------------------------------------------------------------------------------------------

--- Tween state, easing, and motion helpers.
-- @table rat.tween
rat.tween = {}

--- Create tween state.
-- @param duration_seconds number: Tween duration in seconds.
-- @return table: New tween state.
function rat.tween.new(duration_seconds)
   return {
      duration = duration_seconds,
      elapsed = 0,
      finished = false,
   }
end

--- Advance tween state.
-- @param tween_state table: Tween state.
-- @param delta_time number: Elapsed time in seconds.
function rat.tween.update(tween_state, delta_time)
   if tween_state.finished then
      return
   end

   tween_state.elapsed = tween_state.elapsed + delta_time

   if tween_state.elapsed >= tween_state.duration then
      tween_state.elapsed = tween_state.duration
      tween_state.finished = true
   end
end

--- Reset tween state to its beginning.
-- @param tween_state table: Tween state.
function rat.tween.reset(tween_state)
   tween_state.elapsed = 0
   tween_state.finished = false
end

--- Return normalised tween time.
-- @param tween_state table: Tween state.
-- @return number: Normalised time from 0 to 1.
function rat.tween.time(tween_state)
   return math.max(0, math.min(tween_state.elapsed / tween_state.duration, 1))
end

-- TWEEN EASING
--- Apply linear easing.
-- @param time number: Normalised time from 0 to 1.
-- @return number: Eased value.
function rat.tween.linear(time)
   return time
end

--- Apply sine-in easing.
-- @param time number: Normalised time from 0 to 1.
-- @return number: Eased value.
function rat.tween.sine_in(time)
   return 1 - math.cos((time * math.pi) / 2)
end

--- Apply sine-out easing.
-- @param time number: Normalised time from 0 to 1.
-- @return number: Eased value.
function rat.tween.sine_out(time)
   return math.sin((time * math.pi) / 2)
end

--- Apply sine-in-out easing.
-- @param time number: Normalised time from 0 to 1.
-- @return number: Eased value.
function rat.tween.sine_in_out(time)
   return -(math.cos(math.pi * time) - 1) / 2
end

-- TWEEN MOTION
--- Return a parabolic hop offset.
-- @param maximum_height number: Maximum hop height.
-- @param time number: Normalised time from 0 to 1.
-- @return number: Hop offset.
function rat.tween.hop(maximum_height, time)
   return 4 * maximum_height * time * (1 - time)
end

--- Return an out-and-back sine offset.
-- @param maximum_distance number: Maximum distance.
-- @param time number: Normalised time from 0 to 1.
-- @return number: Bump offset.
function rat.tween.bump(maximum_distance, time)
   if time <= 0.5 then
      return maximum_distance * rat.tween.sine_out(time * 2)
   end

   return maximum_distance * rat.tween.sine_in((1 - time) * 2)
end

--- Pulse between a minimum and maximum value.
-- @param minimum_value number: Minimum value.
-- @param maximum_value number: Maximum value.
-- @param time number: Normalised time from 0 to 1.
-- @return number: Pulsed value.
function rat.tween.pulse(minimum_value, maximum_value, time)
   local value_range = maximum_value - minimum_value

   if time <= 0.5 then
      return minimum_value + value_range * rat.tween.sine_out(time * 2)
   end

   return minimum_value + value_range * rat.tween.sine_in((1 - time) * 2)
end

-- ---------------------------------------------------------------------------------------------------------------------
-- SPRITES
-- ---------------------------------------------------------------------------------------------------------------------

--- Sprite-atlas loading, drawing, animation, and palette replacement.
-- @field atlas Active sprite atlas, or nil when none is set.
-- @table rat.sprite
rat.sprite = {
   atlas = nil,
}

--- Load a sprite atlas and retain both its CPU pixelmap and GPU image.
-- @param path string: Image path.
-- @param sprite_width number: Sprite width in pixels.
-- @param sprite_height number: Sprite height in pixels.
-- @return table: Loaded sprite atlas.
function rat.sprite.load_sprite_atlas(path, sprite_width, sprite_height)
   local pixelmap, image_width, image_height = raster.load_pixelmap(path)

   if not pixelmap then
      error("Failed to load sprite atlas '" .. path .. "'")
   end

   local image = graphics.new_image_from_pixelmap(pixelmap)

   return {
      pixelmap = pixelmap,
      image = image,
      sprite_width = sprite_width,
      sprite_height = sprite_height,
      columns = math.floor(image_width / sprite_width),
      rows = math.floor(image_height / sprite_height),
   }
end

--- Set the active sprite atlas.
-- @param atlas table|nil: Atlas to use, or nil to clear it.
function rat.sprite.set_sprite_atlas(atlas)
   rat.sprite.atlas = atlas
end

--- Draw a sprite from the active atlas.
-- @param index number: Zero-based sprite index.
-- @param x number: Destination x coordinate in pixels.
-- @param y number: Destination y coordinate in pixels.
-- @param flip_x boolean|nil: Flip horizontally when true.
-- @param flip_y boolean|nil: Flip vertically when true.
-- @param colour number|nil: Optional packed RGBA modulation colour.
function rat.sprite.draw_sprite(index, x, y, flip_x, flip_y, colour)
   local atlas = rat.sprite.atlas

   if not atlas then
      error("No sprite atlas set")
   end

   local atlas_x = index % atlas.columns
   local atlas_y = math.floor(index / atlas.columns)
   local source_x = atlas_x * atlas.sprite_width
   local source_y = atlas_y * atlas.sprite_height

   colour = colour or 0xFFFFFFFF

   if flip_x or flip_y then
      local centre_x = x + atlas.sprite_width / 2
      local centre_y = y + atlas.sprite_height / 2

      graphics.begin_transform()
      graphics.set_translation(centre_x, centre_y)
      graphics.set_scale(flip_x and -1 or 1, flip_y and -1 or 1)
      graphics.set_origin(centre_x, centre_y)
   end

   graphics.draw_image_region(atlas.image, source_x, source_y, atlas.sprite_width, atlas.sprite_height, x, y, colour)

   if flip_x or flip_y then
      graphics.end_transform()
   end
end

--- Draw a frame from a contiguous sprite animation.
-- @param first_index number: First zero-based sprite index.
-- @param last_index number: Last zero-based sprite index.
-- @param fps number: Animation speed in frames per second.
-- @param x number: Destination x coordinate.
-- @param y number: Destination y coordinate.
-- @param flip_x boolean|nil: Flip horizontally when true.
-- @param flip_y boolean|nil: Flip vertically when true.
-- @param colour number|nil: Optional packed RGBA modulation colour.
function rat.sprite.animate_sprites(first_index, last_index, fps, x, y, flip_x, flip_y, colour)
   local frame_count = last_index - first_index + 1
   local frame = math.floor(os.clock() * fps) % frame_count
   local index = first_index + frame

   rat.sprite.draw_sprite(index, x, y, flip_x, flip_y, colour)
end

--- Replace every exact occurrence of one colour in the active sprite atlas.
-- @param from_colour number: Packed RGBA colour to replace.
-- @param to_colour number: Replacement packed RGBA colour.
function rat.sprite.swap_colour(from_colour, to_colour)
   local atlas = rat.sprite.atlas

   if not atlas then
      error("No sprite atlas set")
   end

   local width, height = raster.get_pixelmap_size(atlas.pixelmap)

   for y = 0, height - 1 do
      for x = 0, width - 1 do
         if raster.get_pixel(atlas.pixelmap, x, y) == from_colour then
            raster.set_pixel(atlas.pixelmap, x, y, to_colour)
         end
      end
   end

   graphics.update_image_from_pixelmap(atlas.image, atlas.pixelmap)
end

-- ---------------------------------------------------------------------------------------------------------------------
-- GUI
-- ---------------------------------------------------------------------------------------------------------------------

--- Immediate-mode GUI state and widgets.
-- @field hot_id Widget currently under the mouse.
-- @field active_id Widget currently active.
-- @field mouse_x Mouse x coordinate in GUI space.
-- @field mouse_y Mouse y coordinate in GUI space.
-- @field mouse_pressed True on the frame mouse button 1 is pressed.
-- @field mouse_released True on the frame mouse button 1 is released.
-- @field color_outline GUI outline colour.
-- @field color_panel Default panel colour.
-- @field color_cold Default idle widget colour.
-- @field color_hot Default hovered widget colour.
-- @field color_image_cold Idle image-button overlay colour.
-- @field color_image_hot Hovered image-button overlay colour.
-- @field color_active Active widget colour.
-- @field color_text Default text colour.
-- @field text_padding Text padding in pixels.
-- @table rat.gui
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

--- Begin a GUI frame and update input state.
-- @param dt number|nil: Frame delta time in seconds.
function rat.gui.init(dt)
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

--- Draw a GUI panel.
-- @param x number: Left coordinate.
-- @param y number: Top coordinate.
-- @param width number: Width.
-- @param height number: Height.
-- @param color number|nil: Optional panel colour.
function rat.gui.panel(x, y, width, height, color)
   color = color or rat.gui.color_panel

   graphics.draw_rect(x, y, width, height, rat.gui.color_outline)

   if width > 2 and height > 2 then
      graphics.draw_rect(x + 1, y + 1, width - 2, height - 2, color)
   end
end

--- Draw text centred inside a rectangle.
-- @param text string: Text to draw.
-- @param x number: Left coordinate.
-- @param y number: Top coordinate.
-- @param width number: Width.
-- @param height number: Height.
function rat.gui.centered_text(text, x, y, width, height)
   local _, text_height = graphics.measure_text_wrap(text, width)
   local text_y = math.floor(y + (height - text_height) / 2)

   graphics.set_text_alignment("center")
   graphics.draw_text_wrap(text, x, text_y, width, rat.gui.color_text)
   graphics.set_text_alignment("left")
end

--- Update and draw a button.
-- @param id number: Explicit non-zero widget id.
-- @param x number: Left coordinate.
-- @param y number: Top coordinate.
-- @param width number: Width.
-- @param height number: Height.
-- @return boolean: True when pressed.
function rat.gui.button(id, x, y, width, height)
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

   rat.gui.panel(x, y, width, height, color)

   return pressed
end

--- Update and draw a text button.
-- @param id number: Explicit non-zero widget id.
-- @param text string: Button label.
-- @param x number: Left coordinate.
-- @param y number: Top coordinate.
-- @param width number: Width.
-- @param height number: Height.
-- @return boolean: True when pressed.
function rat.gui.text_button(id, text, x, y, width, height)
   local pressed = rat.gui.button(id, x, y, width, height)

   rat.gui.centered_text(text, x, y, width, height)

   return pressed
end

--- Update and draw an image button.
-- @param id number: Explicit non-zero widget id.
-- @param image userdata: Newt image.
-- @param x number: Left coordinate.
-- @param y number: Top coordinate.
-- @param width number: Width.
-- @param height number: Height.
-- @return boolean: True when pressed.
function rat.gui.image_button(id, image, x, y, width, height)
   local pressed = rat.gui.button(id, x, y, width, height)
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

--- Draw wrapped text inside a GUI panel.
-- @param text string: Text to draw.
-- @param x number: Left coordinate.
-- @param y number: Top coordinate.
-- @param width number: Width.
-- @param height number: Height.
function rat.gui.text_box(text, x, y, width, height)
   local padding = rat.gui.text_padding
   local draw_x = x + padding
   local draw_y = y + padding
   local right = x + width - padding
   local bottom = y + height - padding
   local line_height = graphics.get_font_line_skip()

   rat.gui.panel(x, y, width, height)

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

--- Update and draw a single-line text field.
-- @param id number: Explicit non-zero widget id.
-- @param x number: Left coordinate.
-- @param y number: Top coordinate.
-- @param width number: Width.
-- @param height number: Height.
-- @param text string: Current text value.
-- @return string: Updated text value.
function rat.gui.text_field(id, x, y, width, height, text)
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

   rat.gui.panel(x, y, width, height, color)

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

-- ---------------------------------------------------------------------------------------------------------------------
-- DATA
-- ---------------------------------------------------------------------------------------------------------------------
--- Plain Lua data serialisation helpers.
-- @table rat.data
rat.data = {}

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

         entries[#entries + 1] = next_indentation ..
             serialized_key .. " = " .. data_serialize_value(entry_value, active_tables, next_indentation)
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

--- Serialise plain Lua data and write it to disk.
-- @param path string: Destination path.
-- @param data any: Serializable Lua value.
-- @return any: Result returned by filesystem.write_file.
function rat.data.save(path, data)
   local serialized_data = "return " .. data_serialize_value(data, {}, "") .. "\n"
   return filesystem.write_file(path, serialized_data)
end

--- Load and validate plain Lua data from disk.
-- @param path string: Source path.
-- @return any: Loaded value, or nil followed by an error message.
function rat.data.load(path)
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

-- ---------------------------------------------------------------------------------------------------------------------
-- CAMERA
-- ---------------------------------------------------------------------------------------------------------------------

--- Simple world-space camera transforms.
-- @table rat.camera
rat.camera = {}

local function clamp_camera_to_bounds(camera)
   if camera.min_x == nil then
      return
   end

   camera.x = rat.maths.clamp(camera.x, camera.min_x, camera.max_x)
   camera.y = rat.maths.clamp(camera.y, camera.min_y, camera.max_y)
end

--- Create camera state.
-- @param x number|nil: Initial world x coordinate.
-- @param y number|nil: Initial world y coordinate.
-- @param zoom number|nil: Initial zoom.
-- @return table: New camera state.
function rat.camera.new_camera(x, y, zoom)
   return {
      x = x or 0,
      y = y or 0,
      zoom = zoom or 1,
      min_x = nil,
      min_y = nil,
      max_x = nil,
      max_y = nil,
   }
end

--- Begin drawing through a camera transform.
-- @param camera table: Camera state.
function rat.camera.start_camera(camera)
   graphics.begin_transform()
   graphics.set_translation(-camera.x * camera.zoom, -camera.y * camera.zoom)
   graphics.set_scale(camera.zoom, camera.zoom)
end

--- End the current camera transform.
function rat.camera.stop_camera()
   graphics.end_transform()
end

--- Move a camera by an offset.
-- @param camera table: Camera state.
-- @param dx number: Horizontal movement.
-- @param dy number: Vertical movement.
function rat.camera.move_camera(camera, dx, dy)
   camera.x = camera.x + dx
   camera.y = camera.y + dy
   clamp_camera_to_bounds(camera)
end

--- Set an absolute camera position.
-- @param camera table: Camera state.
-- @param x number: World x coordinate.
-- @param y number: World y coordinate.
function rat.camera.set_camera_position(camera, x, y)
   camera.x = x
   camera.y = y
   clamp_camera_to_bounds(camera)
end

--- Adjust camera zoom by an amount.
-- @param camera table: Camera state.
-- @param amount number: Amount to add to zoom.
function rat.camera.zoom_camera(camera, amount)
   camera.zoom = camera.zoom + amount
end

--- Set camera zoom.
-- @param camera table: Camera state.
-- @param zoom number: New zoom value.
function rat.camera.set_camera_zoom(camera, zoom)
   camera.zoom = zoom
end

--- Convert world coordinates to camera screen coordinates.
-- @param camera table: Camera state.
-- @param x number: World x coordinate.
-- @param y number: World y coordinate.
-- @return number, number: Screen x and y coordinates.
function rat.camera.world_to_screen(camera, x, y)
   local screen_x = (x - camera.x) * camera.zoom
   local screen_y = (y - camera.y) * camera.zoom

   return screen_x, screen_y
end

--- Convert camera screen coordinates to world coordinates.
-- @param camera table: Camera state.
-- @param x number: Screen x coordinate.
-- @param y number: Screen y coordinate.
-- @return number, number: World x and y coordinates.
function rat.camera.screen_to_world(camera, x, y)
   local world_x = x / camera.zoom + camera.x
   local world_y = y / camera.zoom + camera.y

   return world_x, world_y
end

--- Set camera position bounds.
-- @param camera table: Camera state.
-- @param min_x number: Minimum x.
-- @param min_y number: Minimum y.
-- @param max_x number: Maximum x.
-- @param max_y number: Maximum y.
function rat.camera.set_camera_bounds(camera, min_x, min_y, max_x, max_y)
   camera.min_x = min_x
   camera.min_y = min_y
   camera.max_x = max_x
   camera.max_y = max_y
   clamp_camera_to_bounds(camera)
end

--- Remove camera position bounds.
-- @param camera table: Camera state.
function rat.camera.clear_camera_bounds(camera)
   camera.min_x = nil
   camera.min_y = nil
   camera.max_x = nil
   camera.max_y = nil
end

return rat
