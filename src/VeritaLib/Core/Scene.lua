
local Stage = require(".Stage")
local Graphics = require("<Graphics")

--- A wrapper for global state, such as the main menu, gameplay, staff roll, etc.
local Scene = {}

function Scene.New(scenedef)
    local function noop() end

    scenedef = scenedef or {}
    local scene = {
        init = scenedef.init or noop,
        frame = scenedef.frame or noop,
        render = scenedef.render or noop,
        del = scenedef.del or noop,
    }
    return scene
end

function Scene.Set(scene)
    if Scene.current then
        Scene.current:del()
        lstg.ResetPool()
        lstg.RemoveResource("stage")
        lstg.RemoveResource("global")
    end
    if Stage.current then
        Stage.current:del()
        Stage.current = nil
    end
    lstg.SetResourceStatus("global")
    if GAME_INIT then
        Graphics.Init()
        scene:init()
    end
    Scene.current = scene
end

function Scene.Init()
    if not Scene.current then
        error("You must set a scene before game init")
    end
    Graphics.Init()
    Scene.current:init()
end

return Scene
