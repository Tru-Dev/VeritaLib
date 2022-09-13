
--- A wrapper for local gameplay state.
local Stage = {}

function Stage.New(stagedef)
    local function noop() end

    stagedef = stagedef or {}
    local stage = {
        init = stagedef.init or noop,
        frame = stagedef.frame or noop,
        render = stagedef.render or noop,
        del = stagedef.del or noop,
    }
    return stage
end

function Stage.Set(stage)
    if Stage.current then
        Stage.current:del()
        lstg.ResetPool()
        lstg.RemoveResource("stage")
    end
    lstg.SetResourceStatus("stage")
    stage:init()
    Stage.current = stage
end

return Stage
