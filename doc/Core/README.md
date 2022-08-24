# VeritaLib core module
Implements core functionality for VeritaLib, such as classes, callbacks, and tasks.

- [Object-oriented design](#object-oriented-design)
- [Global callbacks](#global-callbacks)
- [Window functions](#window-functions)
- [Scenes and Stages](#scenes-and-stages)
- [Tasks](#tasks)
- [JSON wrapper](#json-wrapper)
- [Game configuration](#game-configuration)

Usage:
```lua
local Core = require("VeritaLib.Core")
```
or
```lua
local vlib = require("VeritaLib")
local Core = vlib.Core
```

## Object-oriented design
Classes work as one would expect from a language like Python, as there is no true encapsulation.  
However, features such as single inheritance, operator overloading, and static fields are implemented.

See [Classes.md](Classes.md) for more info.

## Global callbacks
The global LuaSTG callbacks (`GameInit`, `FrameFunc`, `RenderFunc`, etc.) call the respective
functions in the `GlobalCallbacks` table.  
This means that to override one, you can simply set a function in the table:

Example usage:
```lua
local GlobalCallbacks = require("VeritaLib.Core.GlobalCallbacks")
GlobalCallbacks.frame = function()
    lstg.ObjFrame()
    lstg.BoundCheck()
    lstg.UpdateXY()
    lstg.AfterFrame()
    local Keyboard = lstg.Input.Keyboard
    return Keyboard.GetKeyState(Keyboard.Escape)
end
```

## Window functions
The `Window` module provides commonly used functions for accessing the actual width and height of the game window.  
It is recommended to use viewports for most cases, however.

Example usage:
```lua
local Window = require("VeritaLib.Core.Window")
print(Window.width, Window.height, Window.windowed)
```

## Scenes and Stages
> TODO

## Tasks
Tasks work mostly like in THlib, with minor differences.

Example usage:
```lua
local Task = require("VeritaLib.Core.Task")
local manager = Task.Manager()
manager:add(function()
    while true do
        print("This message appears once a second.")
        Task.wait(60)
    end
end)
-- in some frame function:
manager:resume_all()
manager:remove_dead()
-- and if you ever want to stop all tasks:
manager:clear()
```

## JSON wrapper
A JSON wrapper for Lua tables was created to make debugging easier.  
If you try to put something in the JSON table, say, a function, it will spit out an error at that
line, instead of when you try to serialize it.

Example usage:
```lua
local JsonTable = require("VeritaLib.Core.JsonTable")
local to_json = JsonTable.New()
-- then use as a regular table (mostly)
to_json.abc = "def"
to_json.number = 123
-- to_json.fn = function() end -- error!
to_json.data = {
    example = true,
    -- fn = function() end -- still an error!
}
-- save to file
to_json.ToFile("example.json")
---
local from_json = JsonTable.FromFile("example.json")
print(from_json.number = 123) -- true
```

## Game configuration
Game configuration is stored in `config.json` and accessed through a JSON wrapper object. You
can access this object via requiring `VeritaLib.Core.Config`.

You can specify default config options specific to your game in [`vlib_conf.lua`](/src/vlib_conf.lua).
