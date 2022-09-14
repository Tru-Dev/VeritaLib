
local vlib = require("VeritaLib")
local Scene = require("VeritaLib.Core.Scene")
local Loader = require("VeritaLib.Resources.Loader")
local TexturePager = require("VeritaLib.Resources.TexturePager")

return Scene.New {
    init = function(self)
        lstg.LoadTTF("Arial", "C:/Windows/Fonts/arial.ttf", 64, 64)
        self.pager = TexturePager("res_01")
        self.loader = Loader.LoadResAsync("test_res.json", self.pager)
        self.segment_val = 0
    end,
    frame = function(self)
        if coroutine.status(self.loader) ~= "dead" then
            _, self.segment_val = coroutine.resume(self.loader)
        end
    end,
    render = function(self)
        if coroutine.status(self.loader) == "dead" then
            self.pager:make_pages()
        end
        lstg.RenderClear(lstg.Color(0xFF222222))
        lstg.RenderTTF(
            "Arial", "Async Resource Loading\nCurrent Segment Value: " .. self.segment_val,
            vlib.screen.width / 2, vlib.screen.width / 2,
            vlib.screen.height / 2, vlib.screen.height / 2,
            5, lstg.Color(0xFFFFFFFF), 2
        )
    end
}
