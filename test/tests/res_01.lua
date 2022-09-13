
local vlib = require("VeritaLib")
local Scene = require("VeritaLib.Core.Scene")

return Scene.New {
    init = function(self)
        lstg.LoadTTF("Arial", "C:/Windows/Fonts/arial.ttf", 64, 64)
    end,
    render = function(self)
        lstg.RenderClear(lstg.Color(0xFF222222))
        lstg.RenderTTF(
            "Arial", "Empty test for now...",
            vlib.target_res.width / 2, vlib.target_res.width / 2,
            vlib.target_res.height / 2, vlib.target_res.height / 2,
            5, lstg.Color(0xFFFFFFFF), 2
        )
    end
}
