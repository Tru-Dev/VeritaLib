
local vlib = require("VeritaLib")
local Scene = require("VeritaLib.Core.Scene")
local Loader = require("VeritaLib.Resources.Loader")
local TexturePager = require("VeritaLib.Resources.TexturePager")

return Scene.New {
    init = function(self)
        lstg.LoadTTF("Arial", "C:/Windows/Fonts/arial.ttf", 64, 64)
        self.pager = TexturePager("res_01")
        Loader.LoadResNow("test_res.json", self.pager)
    end,
    render = function(self)
        self.pager:make_pages()
        lstg.RenderClear(lstg.Color(0xFF222222))
        lstg.RenderTTF(
            "Arial", "Normal Resource Loading\nCheck the resource debug window",
            vlib.screen.width / 2, vlib.screen.width / 2,
            vlib.screen.height / 2, vlib.screen.height / 2,
            5, lstg.Color(0xFFFFFFFF), 2
        )
    end
}
