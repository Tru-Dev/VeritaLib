
--- Wraps a table in a way that ensures type safety and easy debugging.
local JsonTable = {}

-- Forward declarations of metatable methods

local json_index, json_newindex, json_check_table_recursive

-- JsonTable methods

--- Constructs a JsonTable.
---@generic T: table
---@param t table|nil The initial value of the table that is to be serialized.
---@param def T|nil A defintion table, usually for methods.
---@return vlib.Core.JsonTable|T
function JsonTable.New(t, def)
    t = t or {}
    ---@class vlib.Core.JsonTable
    def = def or {}
    return setmetatable(def, {
        __ref = t,
        __index = json_index,
        __newindex = json_newindex,
    })
end

--- Constructs a JsonTable and initializes it from a file.
---@generic T: table
---@param f string The JSON file's path.
---@param def T|nil A defintion table, usually for methods.
---@return vlib.Core.JsonTable|T|nil @Returns nil if the JSON file could not be loaded.
function JsonTable.FromFile(f, def)
    local json_file = io.open(f, "r")
    if json_file == nil then
        return nil
    end
    local t = cjson.decode(json_file:read("*a"))
    json_file:close()
    def = def or {}
    return setmetatable(def, {
        __ref = t,
        __index = json_index,
        __newindex = json_newindex,
    })
end

--- Saves a JsonTable to the specified file path.
---@param jt vlib.Core.JsonTable
---@param f string
---@return boolean @Returns true on success, false on failure
function JsonTable.ToFile(jt, f)
    local json_file = io.open(f, "w+")
    if json_file == nil then
        return false
    end
    json_file:write(cjson.encode(getmetatable(jt).__ref))
    json_file:close()
    return true
end

-- Metatable methods

function json_index(self, k)
    local mt = getmetatable(self)
    local v = mt.__ref[k]
    if type(v) == "table" then
        return setmetatable({}, {
            __ref = v,
            __index = json_index,
            __newindex = json_newindex,
        })
    end
    return v
end

function json_newindex(self, k, v)
    if type(v) == "function" then
        error("Storing functions in JSON is not allowed.")
    end
    if type(v) == "thread" then
        error("Storing coroutine objects in JSON is not allowed.")
    end
    if type(v) == "userdata" and v ~= cjson.null then
        error("Storing userdata in JSON is not allowed.")
    end
    if type(v) == "table" then
        json_check_table_recursive(v)
    end
    getmetatable(self).__ref[k] = v
end

function json_check_table_recursive(t)
    if t.is_class or t.is_logic_class then
        lstg.Log(3, "Attempt to store a class in JSON detected.")
        lstg.Log(3, "You'll probably get an error complaining about a function.")
        lstg.Log(3,
            "If you want to store a class, make a function to " ..
            "convert it to a standard table first."
        )
    end
    if type(t.class) == "table" then
        lstg.Log(3, "Attempt to store an object in JSON detected.")
        if t.class.is_class then
            lstg.Log(3, "You'll probably get an error complaining about a userdata.")
        end
        if t.class.is_logic_class then
            lstg.Log(3, "You'll most likely get weird and unexpected behavior.")
        end
        lstg.Log(3,
            "If you want to store an object, make a function to " ..
            "convert it to a standard table first."
        )
    end
    for _, v in pairs(t) do
        if type(v) == "function" then
            error("Storing functions in JSON is not allowed.")
        end
        if type(v) == "thread" then
            error("Storing coroutine objects in JSON is not allowed.")
        end
        if type(v) == "userdata" and v ~= cjson.null then
            error("Storing userdata in JSON is not allowed.")
        end
        if type(v) == "table" then
            json_check_table_recursive(v)
        end
    end
end

return JsonTable
