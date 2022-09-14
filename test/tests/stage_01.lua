
local vlib = require("VeritaLib")
local Input = require("VeritaLib.Core.Input")
local Scene = require("VeritaLib.Core.Scene")
local Stage = require("VeritaLib.Core.Stage")

local stage1, stage2, stage3

stage1 = Stage.New {
    frame = function(self)
        if Input.IsPressed("menu", "accept") then
            Stage.Set(stage2)
        end
    end,
    render = function(self)
        lstg.RenderTTF(
            "Arial", "Stage 1 / 3\nPress Z to move to the next...",
            vlib.screen.width / 2, vlib.screen.width / 2,
            vlib.screen.height / 2, vlib.screen.height / 2,
            5, lstg.Color(0xFFFFFFFF), 2
        )
    end
}

stage2 = Stage.New {
    frame = function(self)
        if Input.IsPressed("menu", "accept") then
            Stage.Set(stage3)
        end
    end,
    render = function(self)
        lstg.RenderTTF(
            "Arial", "Stage 2 / 3\nPress Z to move to the next...",
            vlib.screen.width / 2, vlib.screen.width / 2,
            vlib.screen.height / 2, vlib.screen.height / 2,
            5, lstg.Color(0xFFFFFFFF), 2
        )
    end
}

stage3 = Stage.New {
    frame = function(self)
        if Input.IsPressed("menu", "accept") then
            Stage.Set(stage1)
        end
    end,
    render = function(self)
        lstg.RenderTTF(
            "Arial", "Stage 3 / 3\nPress Z to move to the next...",
            vlib.screen.width / 2, vlib.screen.width / 2,
            vlib.screen.height / 2, vlib.screen.height / 2,
            5, lstg.Color(0xFFFFFFFF), 2
        )
    end
}

return Scene.New {
    init = function(self)
        lstg.LoadTTF("Arial", "C:/Windows/Fonts/arial.ttf", 64, 64)
        Stage.Set(stage1)
    end,
    frame = function(self)
        Input.UpdateContext("menu")
        Stage.current:frame()
    end,
    render = function(self)
        lstg.RenderClear(lstg.Color(0xFF222222))
        Stage.current:render()
    end
}
