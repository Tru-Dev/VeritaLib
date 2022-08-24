
local vlib_conf = require("vlib_conf")

--- Stores the functions that the LuaSTG engine callbacks call.  
--- Minimal default behavior is provided.  
--- An extension library may override these.
---@class vlib.Core.GlobalCallbacks
local GlobalCallbacks = {
    --- Called in `GameInit`.
    Init = function()
        lstg.LoadTTF("Arial", "C:/Windows/Fonts/arial.ttf", 64, 64)
        local Class = require("GameClass")
        -- Anonymous class
        Class {
            {
                default_function = 0x08
            };
            render = function(self)
                lstg.RenderTTF(
                    "Arial", lstg.GetVersionName() .. " with VeritaLib",
                    vlib_conf.target_res.width / 2, vlib_conf.target_res.width / 2,
                    vlib_conf.target_res.height * 0.7, vlib_conf.target_res.height * 0.8,
                    0x05,
                    lstg.HSVColor(100, math.fmod(self.timer / 3, 100), 100, 100),
                    2.5
                )
                lstg.RenderTTF(
                    "Arial", "Nothing loaded!\nPress ESC to exit...",
                    vlib_conf.target_res.width / 2, vlib_conf.target_res.width / 2,
                    vlib_conf.target_res.height * 0.5, vlib_conf.target_res.height * 0.6,
                    0x05, lstg.Color(0xFFFFFFFF), 2
                )
            end
        } () -- instantiate this class as an object
    end,
    --- Called in `FrameFunc`.
    ---@return boolean @Whether to exit the game or not.
    Frame = function()
        local Window = require("Window")
        lstg.ObjFrame()
        lstg.BoundCheck()
        lstg.UpdateXY()
        lstg.AfterFrame()
        local Keyboard = lstg.Input.Keyboard
        if Keyboard.GetKeyState(Keyboard.Control) and Keyboard.GetKeyState(Keyboard.Enter) then
            Window.ToggleFullscreen()
        end
        return Keyboard.GetKeyState(Keyboard.Escape)
    end,
    --- Called in `RenderFunc`, between `lstg.BeginScene` and `lstg.EndScene`.  
    --- This means that you don't need to call those functions in this one.
    Render = function()
        lstg.ObjRender()
    end,
    --- Called in `GameExit`.
    Exit = function()
    end,
    --- Called in `FocusGainFunc`.
    FocusGain = function()
    end,
    --- Called in `FocusLoseFunc`.
    FocusLose = function()
    end,
    --- Called in `ResizeFunc`.
    ---@param width integer
    ---@param height integer
    ---@param windowed boolean
    Resize = function(width, height, windowed)
    end,
}

if not CALLBACKS_INITIALIZED then
    local Context = require("VeritaLib.Graphics.Context")
    local Window = require("Window")
    local global_ctx

    -- Callbacks that don't change with debug status

    function GameInit()
        global_ctx = Context("Global Rendering Context", {
            view_mode = "2d",
            view_data = {
                0, vlib_conf.target_res.width,
                0, vlib_conf.target_res.height
            },
            viewport = {
                0, vlib_conf.target_res.width,
                0, vlib_conf.target_res.height
            },
            scissor_rect = {
                0, vlib_conf.target_res.width,
                0, vlib_conf.target_res.height
            },
            clear_type = "full",
            clear_color = lstg.Color(0xFF222222),
            image_scale = 1,
            fog = {},

            capture = true,
            create_image = true
        })
        GlobalCallbacks.Init()
    end

    function GameExit()
        GlobalCallbacks.Exit()
    end

    function FocusGainFunc()
        GlobalCallbacks.FocusGain()
    end

    function FocusLoseFunc()
        GlobalCallbacks.FocusLose()
    end

    function ResizeFunc(width, height, windowed)
        Window.UpdateInternalVideoConfig(width, height, windowed)
        GlobalCallbacks.Resize(width, height, windowed)
    end

    if vlib_conf.debug.enable then
        local imgui = require("imgui")
        local show_ui = vlib_conf.debug.show_ui
        -- temporary fix until input module is implemented
        local f12_pressed = false

        function FrameFunc()
            imgui.backend.NewFrame()
            imgui.ImGui.NewFrame()
            local Keyboard = lstg.Input.Keyboard
            if Keyboard.GetKeyState(Keyboard.F12) and not f12_pressed then
                show_ui = not show_ui
            end
            f12_pressed = Keyboard.GetKeyState(Keyboard.F12)
            if show_ui then
                imgui.backend.ShowFrameStatistics()
                imgui.backend.ShowResourceManagerDebugWindow()
            end
            local exit = GlobalCallbacks.Frame()
            imgui.ImGui.EndFrame()
            return exit
        end

        function RenderFunc()
            lstg.BeginScene()
            global_ctx.begin()
            GlobalCallbacks.Render()
            global_ctx.apply()
            lstg.RenderClear(lstg.Color(0xFF000000))
            lstg.SetFog()
            lstg.SetScissorRect(0, Window.width, 0, Window.height)
            lstg.SetImageScale(1)
            ---@diagnostic disable-next-line: undefined-field
            lstg.SetViewport(unpack(Window.main_viewport))
            lstg.SetOrtho(0, 1, 0, 1)
            lstg.RenderRect("Global Rendering Context", 0, 1, 0, 1)
            imgui.ImGui.Render()
            imgui.backend.RenderDrawData()
            lstg.EndScene()
        end

        function ResizeFunc(width, height, windowed)
            Window.UpdateInternalVideoConfig(width, height, windowed)
            GlobalCallbacks.Resize(width, height, windowed)
        end
    else
        function FrameFunc()
            return GlobalCallbacks.Frame()
        end

        function RenderFunc()
            lstg.BeginScene()
            global_ctx.begin()
            GlobalCallbacks.Render()
            global_ctx.apply()
            lstg.RenderClear(lstg.Color(0xFF000000))
            lstg.SetFog()
            lstg.SetScissorRect(0, Window.width, 0, Window.height)
            lstg.SetImageScale(1)
            ---@diagnostic disable-next-line: undefined-field
            lstg.SetViewport(unpack(Window.main_viewport))
            lstg.SetOrtho(0, 1, 0, 1)
            lstg.RenderRect("Global Rendering Context", 0, 1, 0, 1)
            lstg.EndScene()
        end
    end

    CALLBACKS_INITIALIZED = true
end

return GlobalCallbacks
