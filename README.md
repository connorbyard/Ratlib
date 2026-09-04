```text
██████╗  █████╗ ████████╗██╗     ██╗  ██████╗
██╔══██╗██╔══██╗╚══██╔══╝██║     ██║  ██╔══██╗
██████╔╝███████║   ██║   ██║     ██║  ██████╔╝
██╔══██╗██╔══██║   ██║   ██║     ██║  ██╔══██╗
██║  ██║██║  ██║   ██║   ███████╗██║  ██████╔╝
╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═════╝
        Not quite as good as Raylib.
```

A small collection of Lua utilities for [Newt](https://github.com/Quillwyrm/newt/tree/main).
Maths, geometry, resolution scaling, primitive shapes, tweens, sprite helpers, and whatever else I end up needing.

Small, explicit, boring.
Copy it, modify it, delete the bits you don't need.

## Use

Drop `ratlib.lua` into your project.

```lua
local rat = require("ratlib")

local attack_tween = rat.tween_new(0.15)

function update(dt)
   rat.tween_update(attack_tween, dt)

   local time = rat.tween_time(attack_tween)
   local offset = rat.tween_bump(12, time)

   rat.shape_circle_fill(100 + offset, 100, 8, rgba("#ffffff"))
end
```

## API

```text
maths_*     maths helpers
geo_*       geometry tests
res_*       virtual resolution
shape_*     primitive drawing
tween_*     easing and simple motion
sprite_*    sprite atlas helpers
```

See `ratlib_cheatsheet.lua` for the complete API.
