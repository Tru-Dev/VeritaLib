
lstg.DoFile("src/loader.lua")

local vlib = require("VeritaLib")

local Core = vlib.Core
local Graphics = vlib.Graphics
local Resources = vlib.Resources

local Debug = vlib.Debug
Debug.show_ui = true

local GlobalCallbacks = Core.GlobalCallbacks

function GlobalCallbacks.Init()
    
end

function GlobalCallbacks.Frame()
    return true
end
