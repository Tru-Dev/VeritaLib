
--- A wrapper for local gameplay state.
---@class vlib.Core.Stage: vlib.Core.LogicObject

local Class = require(".LogicClass")
local Graphics = require("<Graphics")

---@class vlib.Core.Stage.Class: vlib.Core.LogicClass
--
--- The current scene.
---@field current vlib.Core.Stage
---@operator call(...): vlib.Core.Stage
local Stage = Class {
    {
        newinst = function(self, obj)
            lstg.ResetPool()
            lstg.RemoveResource("stage")
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

return Stage
