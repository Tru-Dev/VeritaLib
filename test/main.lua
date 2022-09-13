
lstg.DoFile("src/loader.lua")

-- -- Manual include because tests are external to the main source
-- local vconf = dofile("vlib_conf.lua")

local vlib = require("VeritaLib")

local Core = vlib.Core
local Graphics = vlib.Graphics
local Resources = vlib.Resources

local GlobalCallbacks = Core.GlobalCallbacks
local Input = Core.Input
local Scene = Core.Scene

local imgui = require("imgui")

local Debug = require("VeritaLib.Debug")
Debug.show_ui = true

local scene_init = Scene.New {
    init = function(self)
        lstg.LoadTTF("Arial", "C:/Windows/Fonts/arial.ttf", 64, 64)
    end,
    render = function(self)
        lstg.RenderClear(lstg.Color(0xFF222222))
        lstg.RenderTTF(
            "Arial", "Select a test from the menu at the top...",
            vlib.target_res.width / 2, vlib.target_res.width / 2,
            vlib.target_res.height / 2, vlib.target_res.height / 2,
            5, lstg.Color(0xFFFFFFFF), 2
        )
    end
}

Scene.Set(scene_init)

local tests = {}

for i, f in ipairs(lstg.FileManager.EnumFiles("tests", "lua")) do
    tests[i] = { f[1]:sub(1, -5), lstg.DoFile(f[1]) }
end

function GlobalCallbacks.Frame()
    Scene.current:frame()
    Input.UpdateContext("test")
    if imgui.ImGui.BeginMainMenuBar() then
        if imgui.ImGui.BeginMenu("File") then
            GAME_EXIT = GAME_EXIT or imgui.ImGui.MenuItem("Exit")
            imgui.ImGui.EndMenu()
        end
        if imgui.ImGui.BeginMenu("Tests") then
            for _, t in ipairs(tests) do
                if imgui.ImGui.MenuItem(t[1]) then
                    Scene.Set(t[2])
                end
            end
            imgui.ImGui.EndMenu()
        end
        imgui.ImGui.EndMainMenuBar()
    end
    return GAME_EXIT or Input.state.test.exit
end


