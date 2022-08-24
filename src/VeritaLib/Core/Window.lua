
--- Provides window functions and fields.
---@class vlib.Core.Window
--
--- The window's width. Read-only.
---@field width integer
--
--- The window's height. Read-only.
---@field height integer
--
--- If the game is running windowed or not. Read-only.
---@field windowed boolean
local Window = {}

local Config = require("Config")

local current_video_settings = {}

--- Toggles between windowed and fullscreen modes.
---@return boolean @Whether the switch succeeded.
function Window.ToggleFullscreen()
    local windowed = not current_video_settings.windowed
    local w, h
    if windowed then
        w = Config.window_size.width
        h = Config.window_size.height
    else
        w = Config.fullscreen_resolution.width
        h = Config.fullscreen_resolution.height
    end
    return lstg.ChangeVideoMode(
        w, h, windowed, Config.vsync,
        Config.refresh_rate_numerator, Config.refresh_rate_denominator
    )
end

--- Sets the video mode according to the current configuration.
---@return boolean @Whether the switch succeeded.
function Window.ApplyConfig()
    local w, h
    if Config.windowed then
        w = Config.window_size.width
        h = Config.window_size.height
    else
        w = Config.fullscreen_resolution.width
        h = Config.fullscreen_resolution.height
    end
    return lstg.ChangeVideoMode(
        w, h, Config.windowed, Config.vsync,
        Config.refresh_rate_numerator, Config.refresh_rate_denominator
    )
end

--- ## For internal use only.
function Window.UpdateInternalVideoConfig(width, height, windowed)
    current_video_settings.windowed = windowed
    current_video_settings.width = width
    current_video_settings.height = height
    if Config.window_scaling == "stretch" then
        current_video_settings.main_viewport = { 0, width, 0, height }
    else
        local target_res = require("vlib_conf").target_res
        local target_aspect = target_res.width / target_res.height
        if height == 0 then
            height = 1
        end
        local window_aspect = width / height
        if window_aspect >= target_aspect then -- window is too wide, or is just right
            local scale = height / target_res.height
            current_video_settings.main_viewport = {
                width / 2 - target_res.width * scale / 2,
                width / 2 + target_res.width * scale / 2,
                0,
                height
            }
        else -- window is too narrow
            local scale = width / target_res.width
            current_video_settings.main_viewport = {
                0,
                width,
                height / 2 - target_res.height * scale / 2,
                height / 2 + target_res.height * scale / 2
            }
        end
    end
end

if Config.windowed then
    Window.UpdateInternalVideoConfig(
        Config.window_size.width,
        Config.window_size.height,
        true
    )
else
    Window.UpdateInternalVideoConfig(
        Config.fullscreen_resolution.width,
        Config.fullscreen_resolution.height,
        true
    )
end

setmetatable(Window, {
    __index = current_video_settings,
    __newindex = function()
        error(
            "Setting video settings via index is disallowed. \n" ..
            "Use Window.ToggleWindowed() or Window.ApplyConfig() instead."
        )
    end
})

return Window
