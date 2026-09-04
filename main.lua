local rat = require("ratlib")

local BLACK = rgba(0, 0, 0, 255)
local WHITE = rgba(255, 255, 255, 255)
local GREY = rgba(70, 70, 70, 255)
local LIGHT_GREY = rgba(110, 110, 110, 255)
local RED = rgba(180, 70, 70, 255)
local GREEN = rgba(80, 160, 90, 255)
local YELLOW = rgba(190, 170, 70, 255)

local hop_tween = rat.tween_new(1.0)
local bump_tween = rat.tween_new(1.0)
local pulse_tween = rat.tween_new(1.0)

local text_field_value = "RATLIB"
local button_press_count = 0

local data_status = "NOT TESTED"

local test_data_path = "ratlib_test_data.lua"

local polygon_points = {
   { 580, 80 },
   { 630, 60 },
   { 680, 85 },
   { 665, 135 },
   { 600, 140 },
}

local test_data = {
   name = "RATLIB",
   version = 1,
   enabled = true,

   position = {
      x = 120,
      y = 240,
   },

   values = {
      10,
      20,
      30,
      40,
   },
}


local function update_tweens(dt)
   rat.tween_update(hop_tween, dt)
   rat.tween_update(bump_tween, dt)
   rat.tween_update(pulse_tween, dt)

   if hop_tween.finished then
      rat.tween_reset(hop_tween)
   end

   if bump_tween.finished then
      rat.tween_reset(bump_tween)
   end

   if pulse_tween.finished then
      rat.tween_reset(pulse_tween)
   end
end


local function draw_math_tests()
   local x = 32
   local y = 32

   graphics.draw_text("MATHS", x, y, WHITE)

   y = y + 24

   graphics.draw_text("clamp(12, 0, 10) = " .. rat.maths_clamp(12, 0, 10), x, y, WHITE)
   y = y + 18

   graphics.draw_text("lerp(0, 100, .5) = " .. rat.maths_lerp(0, 100, 0.5), x, y, WHITE)
   y = y + 18

   graphics.draw_text("inverse_lerp(0, 100, 25) = " .. rat.maths_inverse_lerp(0, 100, 25), x, y, WHITE)
   y = y + 18

   graphics.draw_text("remap(5, 0, 10, 0, 100) = " .. rat.maths_remap(5, 0, 10, 0, 100), x, y, WHITE)
   y = y + 18

   graphics.draw_text("round(4.6) = " .. rat.maths_round(4.6), x, y, WHITE)
   y = y + 18

   graphics.draw_text("sign(-20) = " .. rat.maths_sign(-20), x, y, WHITE)
   y = y + 18

   graphics.draw_text("distance(0,0,3,4) = " .. rat.maths_distance(0, 0, 3, 4), x, y, WHITE)
   y = y + 18

   graphics.draw_text("snap(37,16) = " .. rat.maths_snap(37, 16), x, y, WHITE)
   y = y + 18

   graphics.draw_text("approach(0,10,3) = " .. rat.maths_approach(0, 10, 3), x, y, WHITE)
end


local function draw_shape_tests()
   graphics.draw_text("SHAPES", 330, 32, WHITE)

   rat.shape_line(330, 65, 430, 105, WHITE)

   rat.shape_rect(455, 65, 70, 45, WHITE)
   rat.shape_rect_fill(545, 65, 70, 45, GREY)

   rat.shape_circle(375, 160, 28, WHITE)
   rat.shape_circle_fill(465, 160, 28, GREY)

   rat.shape_triangle(535, 190, 575, 130, 615, 190, WHITE)
   rat.shape_triangle_fill(635, 190, 675, 130, 715, 190, GREY)

   rat.shape_polygon(polygon_points, WHITE)

   rat.shape_rect_dither(330, 225, 110, 50, BLACK, WHITE, rat.dither_25)
   rat.shape_rect_dither(450, 225, 110, 50, BLACK, WHITE, rat.dither_checkered)
   rat.shape_rect_dither(570, 225, 110, 50, BLACK, WHITE, rat.dither_75)

   rat.shape_rect(330, 225, 110, 50, WHITE)
   rat.shape_rect(450, 225, 110, 50, WHITE)
   rat.shape_rect(570, 225, 110, 50, WHITE)

   graphics.draw_text("25%", 370, 242, WHITE)
   graphics.draw_text("50%", 490, 242, WHITE)
   graphics.draw_text("75%", 610, 242, BLACK)
end


local function draw_geometry_tests()
   graphics.draw_text("GEOMETRY", 760, 32, WHITE)

   local rect_x = 760
   local rect_y = 70
   local rect_width = 160
   local rect_height = 70

   local mouse_inside = rat.geo_point_in_rect(
      rat.res.mouse_x,
      rat.res.mouse_y,
      rect_x,
      rect_y,
      rect_width,
      rect_height
   )

   if mouse_inside then
      rat.shape_rect_fill(rect_x, rect_y, rect_width, rect_height, GREEN)
   else
      rat.shape_rect(rect_x, rect_y, rect_width, rect_height, WHITE)
   end

   graphics.draw_text("MOUSE TEST", rect_x + 28, rect_y + 24, WHITE)

   local overlap = rat.geo_rects_overlap(
      760,
      180,
      100,
      80,
      820,
      220,
      100,
      80
   )

   rat.shape_rect(760, 180, 100, 80, WHITE)
   rat.shape_rect(820, 220, 100, 80, overlap and RED or WHITE)
end


local function draw_tween_tests()
   graphics.draw_text("TWEENS", 32, 340, WHITE)

   local hop_time = rat.tween_time(hop_tween)
   local bump_time = rat.tween_time(bump_tween)
   local pulse_time = rat.tween_time(pulse_tween)

   local hop_height = rat.tween_hop(45, hop_time)
   local bump_distance = rat.tween_bump(70, bump_time)
   local pulse_radius = rat.tween_pulse(10, 28, pulse_time)

   rat.shape_circle_fill(100, 440 - hop_height, 16, GREEN)
   graphics.draw_text("HOP", 80, 475, WHITE)

   rat.shape_circle_fill(240 + bump_distance, 425, 16, RED)
   graphics.draw_text("BUMP", 220, 475, WHITE)

   rat.shape_circle_fill(430, 425, pulse_radius, YELLOW)
   graphics.draw_text("PULSE", 405, 475, WHITE)

   local sine_in = rat.tween_sine_in(hop_time)
   local sine_out = rat.tween_sine_out(hop_time)
   local sine_in_out = rat.tween_sine_in_out(hop_time)

   graphics.draw_text("sine_in: " .. string.format("%.2f", sine_in), 520, 390, WHITE)
   graphics.draw_text("sine_out: " .. string.format("%.2f", sine_out), 520, 414, WHITE)
   graphics.draw_text("sine_in_out: " .. string.format("%.2f", sine_in_out), 520, 438, WHITE)
end


local function draw_gui_tests()
   graphics.draw_text("IMGUI", 760, 340, WHITE)

   rat.gui_panel(760, 375, 300, 250)

   if rat.gui_text_button("test_button", "PRESS ME", 780, 395, 120, 32) then
      button_press_count = button_press_count + 1
   end

   graphics.draw_text("PRESSES: " .. button_press_count, 920, 404, WHITE)

   text_field_value = rat.gui_text_field(
      "test_text_field",
      780,
      450,
      220,
      32,
      text_field_value
   )

   -- graphics.draw_text("TEXT FIELD", 780, 435, WHITE)

   rat.gui_text_box(
      "This is the Ratlib text box.\nIt wraps text and clips vertically.\nDOGS.",
      780,
      505,
      250,
      90
   )
end


local function draw_data_tests()
   graphics.draw_text("DATA", 32, 560, WHITE)

   if rat.gui_text_button("save_data", "SAVE DATA", 32, 590, 110, 32) then
      local ok, err = rat.data_save(test_data_path, test_data)

      if ok then
         data_status = "SAVE OK"
      else
         data_status = "SAVE FAILED: " .. tostring(err)
      end
   end

   if rat.gui_text_button("load_data", "LOAD DATA", 152, 590, 110, 32) then
      local loaded_data, err = rat.data_load(test_data_path)

      if loaded_data then
         data_status = "LOAD OK: " .. loaded_data.name .. " / " .. loaded_data.values[3]
      else
         data_status = "LOAD FAILED: " .. tostring(err)
      end
   end

   graphics.draw_text(data_status, 32, 635, WHITE)
end


local function draw_resolution_debug()
   local text = string.format(
      "RES %dx%d  SCALE %.2f  OFFSET %.1f %.1f  MOUSE %.1f %.1f",
      rat.res.width,
      rat.res.height,
      rat.res.scale,
      rat.res.offset_x,
      rat.res.offset_y,
      rat.res.mouse_x,
      rat.res.mouse_y
   )

   graphics.draw_text(text, 650, 690, WHITE)
end


function runtime.init()
   window.set_flags({ "resizable" })

   rat.res_initialise(1280, 720)

   graphics.set_default_filter("linear")
end

function runtime.update(dt)
   rat.res_update()
   rat.gui_init(dt)
   update_tweens(dt)

   graphics.clear(BLACK)

   rat.res_push()

   draw_math_tests()
   draw_shape_tests()
   draw_geometry_tests()
   draw_tween_tests()
   draw_gui_tests()
   draw_data_tests()
   draw_resolution_debug()

   rat.res_pop()
end
