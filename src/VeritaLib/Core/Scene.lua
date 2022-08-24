
--- A wrapper for a global state, such as the main menu, gameplay, staff roll, etc.
---@class vlib.Core.Scene: vlib.Core.LogicObject

local Class = require(".LogicClass")

---@class vlib.Core.Scene.Class: vlib.Core.LogicClass
---@operator call(...): vlib.Core.Scene
local Scene = Class {
    init = function(self)
    end,
    frame = function(self)
    end,
    render = function(self)
    end,
    del = function(self)
    end,
}

return Scene
