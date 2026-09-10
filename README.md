# Ratlib

**Ratlib** (Random Assortment of Tools) is a small, raylib-inspired collection of Lua utilities for [Newt](https://github.com/Quillwyrm/newt).

Small, explicit, boring.

Copy it, modify it, delete the bits you don't need.

## Use

Drop `ratlib.lua` into your project and require it:

```lua
local rat = require("ratlib")
```

Ratlib is organised into small modules under the `rat` table:

```lua
rat.maths.clamp(value, minimum, maximum)
rat.geo.point_in_rect(x, y, rect_x, rect_y, rect_width, rect_height)
rat.shape.circle_fill(x, y, radius, colour)
rat.sprite.draw_sprite(index, x, y)
rat.camera.move_camera(camera, dx, dy)
```

Use only the parts you need. Ratlib has no required initialisation of its own; individual modules are set up as needed.

For example:

```lua
local rat = require("ratlib")

local attack_tween = rat.tween.new(0.15)

function update(dt)
   rat.tween.update(attack_tween, dt)

   local time = rat.tween.time(attack_tween)
   local offset = rat.tween.bump(12, time)

   rat.shape.circle_fill(100 + offset, 100, 8, rgba("#ffffff"))
end
```

## Modules

```
- `rat.maths` — maths helpers
- `rat.geo` — geometry tests
- `rat.res` — virtual resolution
- `rat.shape` — primitive drawing
- `rat.tween` — easing and simple motion
- `rat.sprite` — sprite atlas helpers
- `rat.gui` — immediate-mode GUI helpers
- `rat.data` — simple data serialization
- `rat.camera` — 2D camera transforms
```

See the generated LDoc documentation for the complete API.
