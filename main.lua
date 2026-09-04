local rat = require("ratlib")

local WHITE = rgba(255, 255, 255, 255)
local GREY = rgba(120, 120, 120, 255)
local RED = rgba(200, 80, 80, 255)
local GREEN = rgba(100, 180, 100, 255)
local YELLOW = rgba(200, 180, 80, 255)

local hop_tween = rat.tween_new(1.0)
local bump_tween = rat.tween_new(1.0)
local pulse_tween = rat.tween_new(1.0)

local polygon_points = {
   { 600, 200 },
   { 650, 175 },
   { 700, 200 },
   { 680, 250 },
   { 620, 250 },
}


function runtime.init()
   rat.res_initialise(1280, 720)
end

function runtime.update(dt)
   rat.res_update()

   graphics.clear(rgba(0, 0, 0, 255))

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

   local hop_time = rat.tween_time(hop_tween)
   local bump_time = rat.tween_time(bump_tween)
   local pulse_time = rat.tween_time(pulse_tween)
   local hop_height = rat.tween_hop(40, hop_time)
   local bump_distance = rat.tween_bump(60, bump_time)
   local pulse_radius = rat.tween_pulse(10, 30, pulse_time)

   rat.res_push()

   rat.shape_line(100, 100, 200, 150, WHITE)
   rat.shape_rect(250, 100, 100, 75, WHITE)
   rat.shape_rect_fill(400, 100, 100, 75, GREY)
   rat.shape_circle(150, 250, 40, WHITE)
   rat.shape_circle_fill(300, 250, 40, GREY)
   rat.shape_triangle(400, 300, 450, 200, 500, 300, WHITE)
   rat.shape_triangle_fill(525, 300, 575, 200, 625, 300, GREY)
   rat.shape_polygon(polygon_points, WHITE)

   local filled_polygon_points = {
      { 750, 200 },
      { 800, 175 },
      { 850, 200 },
      { 830, 250 },
      { 770, 250 },
   }

   rat.shape_polygon_fill(filled_polygon_points, GREY)

   rat.shape_circle_fill(150, 450 - hop_height, 20, GREEN)
   rat.shape_circle_fill(300 + bump_distance, 450, 20, RED)
   rat.shape_circle_fill(500, 450, pulse_radius, YELLOW)

   local mouse_inside_rect = rat.geo_point_in_rect(rat.res.mouse_x, rat.res.mouse_y, 700, 400, 150, 100)

   if mouse_inside_rect then
      rat.shape_rect_fill(700, 400, 150, 100, GREEN)
   else
      rat.shape_rect(700, 400, 150, 100, WHITE)
   end

   local rectangles_overlap = rat.geo_rects_overlap(900, 400, 100, 100, 950, 450, 100, 100)

   if rectangles_overlap then
      rat.shape_rect_fill(900, 400, 100, 100, RED)
      rat.shape_rect(950, 450, 100, 100, WHITE)
   end

   rat.res_pop()
end
