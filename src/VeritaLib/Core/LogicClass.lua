
--- A logic object.
---@class vlib.Core.LogicObject
--
--- The object's class.
---@field class vlib.Core.LogicClass
--
--- Access the instance methods of the object's base class.  
--- Example:
--- ```
--- -- in class definition
--- init = function(self, ...)
---    self.as_base:init(...)
--- end,
--- ```
---@field as_base vlib.Core.LogicObject
--
--- Initializer/constructor.  
--- Called on object creation (when you run the class constructor).
---@field init fun(self: vlib.Core.LogicObject, ...)


--- Logic class definition table.
---@class vlib.Core.LogicClass.classdef
--
--- The static definition area.
---@field [1] vlib.Core.LogicClass.staticdef

--- Game Class static definition table.
---@class vlib.Core.LogicClass.staticdef
--
--- Specifies base class.
---@field [1] vlib.Core.LogicClass

-------------------------------------------------

-- Forward declarations

---@type vlib.Core.LogicClass
local BaseLogicObject

local clsmeta, objmeta

--- Builds a logic class, which does not hook into game callbacks by default.  
--- The layout of the table that you pass in should include the functions that will be run,
--- and an optional table at index [1] that specifies class static fields
--- and its base class (at index [1] of this subtable).  
--- See the [core module readme](README.md) for more information.
---@param classdef vlib.Core.LogicClass.classdef The table of class definitions.
---@return vlib.Core.LogicClass
local function LogicClass(classdef)
    --- A logic class.
    ---@class vlib.Core.LogicClass
    --
    --- Class constructor (calls obj:init(...))
    ---@operator call(...): vlib.Core.LogicObject
    local cls = { is_logic_class = true }

    if type(classdef[1]) == "table" then
        if classdef[1][1] then
            if not classdef[1][1].is_logic_class then
                error("The base class is not a logic class!")
            end
            ---@type vlib.Core.LogicClass
            cls.base = classdef[1][1]
            classdef[1][1] = nil
        end
        for k, v in pairs(classdef[1]) do
            cls[k] = v
        end
    end
    classdef[1] = nil

    ---@type vlib.Core.LogicClass
    cls.base = cls.base or BaseLogicObject

    local methods = {}

    if cls.base then
        for k, fn in pairs(cls.base.methods) do
            methods[k] = fn
        end
    end

    for k, fn in pairs(classdef) do
        if type(fn) == "function" then
            methods[k] = fn
        end
    end

    ---@type function[]
    cls.methods = methods

    setmetatable(cls, clsmeta)

    return cls
end

---@type vlib.Core.LogicClass
BaseLogicObject = LogicClass {
    init = function(self) end,
}

clsmeta = {
    __name = "LogicClass",
    __index = function(self, k)
        return rawget(self, "base") and self.base[k]
    end,
    __call = function(self, ...)
        ---@type vlib.Core.LogicObject
        local obj = { class = self }
        setmetatable(obj, objmeta)
        if self.newinst then
            self:newinst()
        end
        obj:init(...)
        return obj
    end,
}

objmeta = {
    __name = "LogicObject",
    __index = function(self, k)
        if k == "as_base" then
            local base_view = { class = self.class.base }
            setmetatable(base_view, {
                __newindex = self,
                __index = function(bv, k2)
                    if k2 == "as_base" then
                        local base_view2 = { class = bv.class.base }
                        setmetatable(base_view2, getmetatable(bv))
                        return base_view2
                    end
                    return bv.class.methods[k2] or rawget(self, k2)
                end
            })
            return base_view
        end
        return self.class.methods[k]
    end,
    __call = function(self, ...)
        return self:call(...)
    end,
    __tostring = function(self)
        if not self.tostring then
            return "LogicObject"
        end
        return self:tostring()
    end,
    __unm = function(self)
        return self:unm()
    end,
    __add = function(self, other)
        if self.add then return self:add(other) end
        return other:add(self)
    end,
    __sub = function(self, other)
        if self.sub then return self:sub(other) end
        return other:sub(self)
    end,
    __mul = function(self, other)
        if self.mul then return self:mul(other) end
        return other:mul(self)
    end,
    __div = function(self, other)
        if self.div then return self:div(other) end
        return other:div(self)
    end,
    __mod = function(self, other)
        if self.mod then return self:mod(other) end
        return other:mod(self)
    end,
    __pow = function(self, other)
        if self.pow then return self:pow(other) end
        return other:pow(self)
    end,
    __concat = function(self, other)
        if self.concat then return self:concat(other) end
        return other:concat(self)
    end,
    __eq = function(self, other)
        if self.eq then return self:eq(other) end
        return other:eq(self)
    end,
    __lt = function(self, other)
        if self.lt then return self:lt(other) end
        return not other:le(self)
    end,
    __le = function(self, other)
        if self.le then return self:le(other) end
        return not other:lt(self)
    end,
}

return LogicClass
