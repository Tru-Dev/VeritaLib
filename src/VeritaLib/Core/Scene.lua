
--- A wrapper for global state, such as the main menu, gameplay, staff roll, etc.
---@class vlib.Core.Scene: vlib.Core.LogicObject

local Class = require(".LogicClass")
local Graphics = require("<Graphics")

---@class vlib.Core.Scene.Class: vlib.Core.LogicClass
--
--- The current scene.
---@field current vlib.Core.Scene
---@operator call(...): vlib.Core.Scene
local Scene = Class {
    {
        newinst = function(self, obj)
            lstg.ResetPool()
            lstg.RemoveResource("stage")
            lstg.RemoveResource("global")
            Graphics.Init()
            self.current = obj
        end,
    };
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
