# Ratlib Cheat Sheet

Ratlib is a small collection of procedural Lua utilities for Newt.

```lua
local rat = require("ratlib")
```

## API at a glance

```lua
-- maths
rat.maths.clamp(value, minimum_value, maximum_value)
rat.maths.lerp(start_value, end_value, interpolation_amount)
rat.maths.inverse_lerp(start_value, end_value, value)
rat.maths.remap(value, input_minimum, input_maximum, output_minimum, output_maximum)
rat.maths.round(value)
rat.maths.sign(value)
rat.maths.distance(point_a_x, point_a_y, point_b_x, point_b_y)
rat.maths.snap(value, step_size)
rat.maths.approach(current_value, target_value, step_size)

-- geo
rat.geo.point_in_rect(point_x, point_y, rect_x, rect_y, rect_width, rect_height)
rat.geo.rects_overlap(rect_a_x, rect_a_y, rect_a_width, rect_a_height, rect_b_x, rect_b_y, rect_b_width, rect_b_height)

-- res
rat.res.initialise(width, height)
rat.res.update()
rat.res.begin()
rat.res.finish()

-- shape
rat.shape.line(start_x, start_y, end_x, end_y, color)
rat.shape.rect(x, y, width, height, color)
rat.shape.rect_fill(x, y, width, height, color)
rat.shape.rect_dither(x, y, width, height, color_1, color_2, pattern)
rat.shape.circle(center_x, center_y, radius, color)
rat.shape.circle_fill(center_x, center_y, radius, color)
rat.shape.triangle(point_a_x, point_a_y, point_b_x, point_b_y, point_c_x, point_c_y, color)
rat.shape.triangle_fill(point_a_x, point_a_y, point_b_x, point_b_y, point_c_x, point_c_y, color)
rat.shape.polygon(points, color)
rat.shape.polygon_fill(points, color)

rat.shape.dither_checkered
rat.shape.dither_25
rat.shape.dither_75

-- tween
rat.tween.new(duration_seconds)
rat.tween.update(tween_state, delta_time)
rat.tween.reset(tween_state)
rat.tween.time(tween_state)
rat.tween.sine_in(time)
rat.tween.sine_out(time)
rat.tween.sine_in_out(time)
rat.tween.bump(maximum_distance, time)
rat.tween.pulse(minimum_value, maximum_value, time)

-- sprite
rat.sprite.load_sprite_atlas(path, sprite_width, sprite_height)
rat.sprite.set_sprite_atlas(atlas)
rat.sprite.draw_sprite(index, x, y, flip_x, flip_y, colour)
rat.sprite.animate_sprites(first_index, last_index, fps, x, y, flip_x, flip_y, colour)
rat.sprite.swap_colour(from_colour, to_colour)

-- gui
rat.gui.init(dt)
rat.gui.panel(x, y, width, height, color)
rat.gui.centered_text(text, x, y, width, height)
rat.gui.button(id, x, y, width, height)
rat.gui.text_button(id, text, x, y, width, height)
rat.gui.image_button(id, image, x, y, width, height)
rat.gui.text_box(text, x, y, width, height)
rat.gui.text_field(id, x, y, width, height, text)

-- data
rat.data.save(path, data)
rat.data.load(path)

-- camera
rat.camera.new_camera(x, y, zoom)
rat.camera.start_camera(camera)
rat.camera.stop_camera()
rat.camera.move_camera(camera, dx, dy)
rat.camera.set_camera_position(camera, x, y)
rat.camera.zoom_camera(camera, amount)
rat.camera.set_camera_zoom(camera, zoom)
rat.camera.world_to_screen(camera, x, y)
rat.camera.screen_to_world(camera, x, y)
rat.camera.set_camera_bounds(camera, min_x, min_y, max_x, max_y)
rat.camera.clear_camera_bounds(camera)
```

---

## maths

```lua
rat.maths.clamp(value, minimum_value, maximum_value)
rat.maths.lerp(start_value, end_value, interpolation_amount)
rat.maths.inverse_lerp(start_value, end_value, value)
rat.maths.remap(value, input_minimum, input_maximum, output_minimum, output_maximum)
rat.maths.round(value)
rat.maths.sign(value)
rat.maths.distance(point_a_x, point_a_y, point_b_x, point_b_y)
rat.maths.snap(value, step_size)
rat.maths.approach(current_value, target_value, step_size)
```

### clamp

Clamp a value between a minimum and maximum.

```lua
value = rat.maths.clamp(value, 0, 100)
```

### lerp

Linearly interpolate between two values.

```lua
x = rat.maths.lerp(0, 100, 0.5)
```

Returns:

```text
50
```

### inverse_lerp

Find where a value lies between two endpoints.

```lua
time = rat.maths.inverse_lerp(0, 100, 25)
```

Returns:

```text
0.25
```

### remap

Convert a value from one range into another.

```lua
volume = rat.maths.remap(mouse_x, 0, 1280, 0, 1)
```

### round

Round to the nearest integer.

```lua
value = rat.maths.round(4.7)
```

### sign

Return `-1`, `0`, or `1`.

```lua
direction = rat.maths.sign(target_x - player_x)
```

### distance

Calculate Euclidean distance between two points.

```lua
distance = rat.maths.distance(player.x, player.y, enemy.x, enemy.y)
```

### snap

Snap a value to the nearest interval.

```lua
x = rat.maths.snap(mouse_x, 32)
```

### approach

Move a value toward another value without overshooting.

```lua
x = rat.maths.approach(x, target_x, speed * dt)
```

---

## geo

```lua
rat.geo.point_in_rect(point_x, point_y, rect_x, rect_y, rect_width, rect_height)
rat.geo.rects_overlap(rect_a_x, rect_a_y, rect_a_width, rect_a_height, rect_b_x, rect_b_y, rect_b_width, rect_b_height)
```

### point_in_rect

Test whether a point is inside a rectangle.

```lua
if rat.geo.point_in_rect(mouse_x, mouse_y, 100, 100, 200, 50) then
   -- mouse is inside
end
```

### rects_overlap

Test whether two rectangles overlap.

```lua
if rat.geo.rects_overlap(
   player.x, player.y, player.width, player.height,
   enemy.x, enemy.y, enemy.width, enemy.height
) then
   -- collision
end
```

---

## res

Virtual resolution and letterboxing.

```lua
rat.res.initialise(width, height)
rat.res.update()
rat.res.begin()
rat.res.finish()
```

### initialise

Set the virtual resolution.

Usually called once during startup.

```lua
rat.res.initialise(1280, 720)
```

### update

Update scaling, letterboxing, and virtual mouse coordinates.

Call once per frame before using virtual coordinates.

```lua
rat.res.update()
```

### begin / finish

Draw inside virtual-resolution space.

```lua
rat.res.begin()

rat.sprite.draw_sprite(1, 100, 100)
rat.shape.circle_fill(300, 200, 16, rgba("#ffffff"))

rat.res.finish()
```

Typical frame:

```lua
function runtime.update(dt)
   rat.res.update()

   graphics.clear(0, 0, 0, 255)

   rat.res.begin()

   -- game drawing

   rat.res.finish()
end
```

---

## shape

Primitive drawing helpers.

```lua
rat.shape.line(start_x, start_y, end_x, end_y, color)

rat.shape.rect(x, y, width, height, color)
rat.shape.rect_fill(x, y, width, height, color)
rat.shape.rect_dither(x, y, width, height, color_1, color_2, pattern)

rat.shape.circle(center_x, center_y, radius, color)
rat.shape.circle_fill(center_x, center_y, radius, color)

rat.shape.triangle(point_a_x, point_a_y, point_b_x, point_b_y, point_c_x, point_c_y, color)
rat.shape.triangle_fill(point_a_x, point_a_y, point_b_x, point_b_y, point_c_x, point_c_y, color)

rat.shape.polygon(points, color)
rat.shape.polygon_fill(points, color)
```

### line

```lua
rat.shape.line(10, 10, 100, 100, rgba("#ffffff"))
```

### rectangle

Outline:

```lua
rat.shape.rect(100, 100, 200, 80, rgba("#ffffff"))
```

Filled:

```lua
rat.shape.rect_fill(100, 100, 200, 80, rgba("#ffffff"))
```

### dithered rectangle

Built-in patterns:

```lua
rat.shape.dither_checkered
rat.shape.dither_25
rat.shape.dither_75
```

Example:

```lua
rat.shape.rect_dither(
   100, 100, 200, 80,
   rgba("#ffffff"),
   rgba("#000000"),
   rat.shape.dither_checkered
)
```

Custom pattern:

```lua
local pattern = {
   { 1, 0 },
   { 0, 1 },
}

rat.shape.rect_dither(100, 100, 200, 80, colour_a, colour_b, pattern)
```

### circle

Outline:

```lua
rat.shape.circle(320, 180, 32, rgba("#ffffff"))
```

Filled:

```lua
rat.shape.circle_fill(320, 180, 32, rgba("#ffffff"))
```

### triangle

```lua
rat.shape.triangle(100, 200, 150, 100, 200, 200, rgba("#ffffff"))
```

Filled:

```lua
rat.shape.triangle_fill(100, 200, 150, 100, 200, 200, rgba("#ffffff"))
```

### polygon

Points are supplied as `{ x, y }` pairs.

```lua
local points = {
   { 100, 100 },
   { 160, 80 },
   { 200, 130 },
   { 150, 180 },
}

rat.shape.polygon(points, rgba("#ffffff"))
```

Filled:

```lua
rat.shape.polygon_fill(points, rgba("#ffffff"))
```

---

## tween

Simple tween state, easing, and motion helpers.

```lua
rat.tween.new(duration_seconds)
rat.tween.update(tween_state, delta_time)
rat.tween.reset(tween_state)
rat.tween.time(tween_state)

rat.tween.sine_in(time)
rat.tween.sine_out(time)
rat.tween.sine_in_out(time)

rat.tween.bump(maximum_distance, time)
rat.tween.pulse(minimum_value, maximum_value, time)
```

### create

```lua
local tween = rat.tween.new(0.25)
```

### update

```lua
rat.tween.update(tween, dt)
```

### time

Get normalised tween time from `0` to `1`.

```lua
local time = rat.tween.time(tween)
```

### reset

```lua
rat.tween.reset(tween)
```

### easing

```lua
local eased = rat.tween.sine_in(time)
local eased = rat.tween.sine_out(time)
local eased = rat.tween.sine_in_out(time)
```

Typical interpolation:

```lua
local time = rat.tween.time(move_tween)
local eased = rat.tween.sine_out(time)

x = rat.maths.lerp(start_x, target_x, eased)
```

### bump

Move outward and return.

Useful for attacks, recoil, UI movement, etc.

```lua
local time = rat.tween.time(attack_tween)
local offset = rat.tween.bump(12, time)

rat.sprite.draw_sprite(player.sprite, player.x + offset, player.y)
```

### pulse

Pulse between two values.

```lua
local time = rat.tween.time(pulse_tween)
local alpha = rat.tween.pulse(64, 255, time)
```

---

## sprite

Sprite atlas loading, drawing, animation, and palette replacement.

Sprite indices are **zero-based**.

```lua
rat.sprite.load_sprite_atlas(path, sprite_width, sprite_height)
rat.sprite.set_sprite_atlas(atlas)

rat.sprite.draw_sprite(index, x, y, flip_x, flip_y, colour)
rat.sprite.animate_sprites(first_index, last_index, fps, x, y, flip_x, flip_y, colour)

rat.sprite.swap_colour(from_colour, to_colour)
```

### load atlas

```lua
local atlas = rat.sprite.load_sprite_atlas("assets/things.png", 16, 24)
```

The returned atlas contains:

```lua
atlas.pixelmap
atlas.image
atlas.sprite_width
atlas.sprite_height
atlas.columns
atlas.rows
```

### set atlas

```lua
rat.sprite.set_sprite_atlas(atlas)
```

Or:

```lua
rat.sprite.set_sprite_atlas(
   rat.sprite.load_sprite_atlas("assets/things.png", 16, 24)
)
```

### draw sprite

```lua
rat.sprite.draw_sprite(0, 100, 100)
```

Horizontal flip:

```lua
rat.sprite.draw_sprite(0, 100, 100, true)
```

Vertical flip:

```lua
rat.sprite.draw_sprite(0, 100, 100, false, true)
```

Both:

```lua
rat.sprite.draw_sprite(0, 100, 100, true, true)
```

Optional colour modulation:

```lua
rat.sprite.draw_sprite(0, 100, 100, false, false, rgba("#ff8080"))
```

Sprite coordinates are **pixel/world coordinates**.

For a grid game:

```lua
rat.sprite.draw_sprite(
   player.sprite,
   player.x * cell_width,
   player.y * cell_height
)
```

### animate sprites

Animate a contiguous range of atlas indices.

```lua
rat.sprite.animate_sprites(4, 7, 8, 100, 100)
```

This means:

```text
sprites 4 → 7
8 frames per second
position 100, 100
```

Optional flipping and colour work the same as `draw_sprite`.

```lua
rat.sprite.animate_sprites(4, 7, 8, 100, 100, true, false, rgba("#ffffff"))
```

### swap colour

Replace one exact colour throughout the active atlas.

```lua
rat.sprite.swap_colour(rgba("#ff0000"), rgba("#00ff00"))
```

This modifies the loaded atlas itself.

It is different from draw colour modulation:

```lua
rat.sprite.draw_sprite(0, 100, 100, false, false, rgba("#ff8080"))
```

`swap_colour` changes matching source pixels.

The optional draw colour temporarily modulates the sprite when rendering.

---

## gui

Immediate-mode GUI helpers.

```lua
rat.gui.init(dt)

rat.gui.panel(x, y, width, height, color)
rat.gui.centered_text(text, x, y, width, height)

rat.gui.button(id, x, y, width, height)
rat.gui.text_button(id, text, x, y, width, height)
rat.gui.image_button(id, image, x, y, width, height)

rat.gui.text_box(text, x, y, width, height)
rat.gui.text_field(id, x, y, width, height, text)
```

### init

Call once per GUI frame.

```lua
rat.gui.init(dt)
```

### panel

```lua
rat.gui.panel(100, 100, 300, 200)
```

Optional colour:

```lua
rat.gui.panel(100, 100, 300, 200, rgba("#202020"))
```

### centered text

```lua
rat.gui.centered_text("Continue", 100, 100, 200, 40)
```

### button

Buttons use explicit non-zero IDs.

```lua
if rat.gui.button(1, 100, 100, 200, 40) then
   print("pressed")
end
```

### text button

```lua
if rat.gui.text_button(1, "New Game", 100, 100, 200, 40) then
   start_game()
end
```

### image button

```lua
if rat.gui.image_button(2, icon, 100, 100, 32, 32) then
   use_item()
end
```

### text box

Draw wrapped text inside a panel.

```lua
rat.gui.text_box(
   "The road disappears into the northern hills.",
   100, 100, 400, 160
)
```

### text field

```lua
player_name = rat.gui.text_field(3, 100, 100, 300, 40, player_name)
```

Returns the updated string.

---

## data

Simple Lua data serialization.

```lua
rat.data.save(path, data)
rat.data.load(path)
```

### save

```lua
local save_data = {
   player_x = 10,
   player_y = 15,
   gold = 27,
}

rat.data.save("save.lua", save_data)
```

### load

```lua
local save_data, error_message = rat.data.load("save.lua")

if save_data then
   player.x = save_data.player_x
   player.y = save_data.player_y
else
   print(error_message)
end
```

Data should contain plain serializable Lua values.

---

## camera

Simple 2D world-space camera transforms.

```lua
rat.camera.new_camera(x, y, zoom)

rat.camera.start_camera(camera)
rat.camera.stop_camera()

rat.camera.move_camera(camera, dx, dy)
rat.camera.set_camera_position(camera, x, y)

rat.camera.zoom_camera(camera, amount)
rat.camera.set_camera_zoom(camera, zoom)

rat.camera.world_to_screen(camera, x, y)
rat.camera.screen_to_world(camera, x, y)

rat.camera.set_camera_bounds(camera, min_x, min_y, max_x, max_y)
rat.camera.clear_camera_bounds(camera)
```

Camera position represents the **top-left world coordinate**.

### create camera

```lua
local camera = rat.camera.new_camera(0, 0, 1)
```

Arguments are optional:

```lua
local camera = rat.camera.new_camera()
```

### draw through camera

```lua
rat.camera.start_camera(camera)

draw_world()

rat.camera.stop_camera()
```

UI can then be drawn outside the camera:

```lua
rat.camera.start_camera(camera)

draw_world()

rat.camera.stop_camera()

draw_ui()
```

### move camera

Relative movement:

```lua
rat.camera.move_camera(camera, 10, 0)
```

Absolute position:

```lua
rat.camera.set_camera_position(camera, 100, 200)
```

### zoom

Relative:

```lua
rat.camera.zoom_camera(camera, 0.1)
```

Absolute:

```lua
rat.camera.set_camera_zoom(camera, 2)
```

### world to screen

```lua
local screen_x, screen_y = rat.camera.world_to_screen(camera, enemy.x, enemy.y)
```

### screen to world

Useful for mouse interaction:

```lua
local world_x, world_y = rat.camera.screen_to_world(camera, mouse_x, mouse_y)
```

### camera bounds

```lua
rat.camera.set_camera_bounds(camera, 0, 0, map_width, map_height)
```

Remove bounds:

```lua
rat.camera.clear_camera_bounds(camera)
```

---

# Common setups

## Basic Ratlib project

```lua
local rat = require("ratlib")

function runtime.init()
   rat.res.initialise(1280, 720)
end

function runtime.update(dt)
   rat.res.update()

   graphics.clear(0, 0, 0, 255)

   rat.res.begin()

   -- game

   rat.res.finish()
end
```

---

## Sprite atlas

```lua
function runtime.init()
   rat.sprite.set_sprite_atlas(
      rat.sprite.load_sprite_atlas("assets/things.png", 16, 24)
   )
end

function runtime.update(dt)
   rat.sprite.draw_sprite(0, 100, 100)
end
```

---

## Grid sprite

```lua
cell_width = 16
cell_height = 24

player = {
   x = 5,
   y = 5,
   sprite = 0,
}

rat.sprite.draw_sprite(
   player.sprite,
   player.x * cell_width,
   player.y * cell_height
)
```

---

## Camera + virtual resolution

```lua
local camera

function runtime.init()
   rat.res.initialise(1280, 720)
   camera = rat.camera.new_camera(0, 0, 1)
end

function runtime.update(dt)
   rat.res.update()

   graphics.clear(0, 0, 0, 255)

   rat.res.begin()

   rat.camera.start_camera(camera)

   draw_world()

   rat.camera.stop_camera()

   draw_ui()

   rat.res.finish()
end
```

---

## Tweened attack bump

```lua
local attack_tween = rat.tween.new(0.15)

function attack()
   rat.tween.reset(attack_tween)
end

function runtime.update(dt)
   rat.tween.update(attack_tween, dt)

   local time = rat.tween.time(attack_tween)
   local offset = rat.tween.bump(12, time)

   rat.sprite.draw_sprite(player.sprite, player.x + offset, player.y)
end
```

---

## Mouse to world

```lua
local mouse_x, mouse_y = input.get_mouse_position()
local world_x, world_y = rat.camera.screen_to_world(camera, mouse_x, mouse_y)
```

For a grid:

```lua
local grid_x = math.floor(world_x / cell_width)
local grid_y = math.floor(world_y / cell_height)
```

---
