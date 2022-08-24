-- From LuaSTG Sub

---@class vlib.Core.Task Coroutine managment
local Task = {}

---@return vlib.Core.Task.Manager
function Task.Manager()
    ---@class vlib.Core.Task.Manager
    local Manager = {}

    Manager.size = 0

    --- Note: `thread`s in Lua are actually coroutines.
    ---@param f function
    ---@return thread
    function Manager:add(f)
        local co = coroutine.create(f)
        self.size = self.size + 1
        self[self.size] = co
        return co
    end

    --- Resumes all not "dead" coroutines.
    function Manager:resume_all()
        local n = self.size
        for i = 1, n do
            if coroutine.status(self[i]) ~= "dead" then
                assert(coroutine.resume(self[i]))
            end
        end
    end

    --- Removes all "dead" coroutines.
    function Manager:remove_dead()
        local j = 1
        local n = self.size
        for i = 1, n do
            if coroutine.status(self[i]) ~= "dead" then
                if i > j then
                    self[j] = self[i]
                end
                j = j + 1
            end
        end
        for k = j, n do
            self[k] = nil
        end
        self.size = j - 1
    end

    --- Remove all coroutines.
    function Manager:clear()
        local n = self.size
        for i = 1, n do
            self[i] = nil
        end
        self.size = 0
    end

    return Manager
end

---@param frames number
function Task.wait(frames)
    for _ = 1, frames do
        coroutine.yield()
    end
end

return Task
