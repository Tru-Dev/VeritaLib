
--- A LuaSTG object.
---@class vlib.Core.GameObject: lstg.GameObject
--
--- The object's class.
---@field class vlib.Core.GameClass
--
--- Access the instance methods of the object's base class.  
--- Example:
--- ```
--- -- in class definition
--- init = function(self, ...)
---    self.as_base:init(...)
--- end,
--- ```
---@field as_base vlib.Core.GameObject
--
--- Initializer/constructor.  
--- Called on object creation (when you run the class constructor).
---@field init fun(self: vlib.Core.GameObject, ...)
--
--- Deletion callback.  
--- Called when you run `lstg.Del(obj)` or when the object goes out of bounds.
---@field del fun(self: vlib.Core.GameObject)
--
--- Frame callback.  
--- Called in `lstg.ObjFrame()`.
---@field frame fun(self: vlib.Core.GameObject)
--
--- Render callback.  
--- Called in `lstg.ObjRender()`
---@field render fun(self: vlib.Core.GameObject)
--
--- Collision callback.
---@field collision fun(self: vlib.Core.GameObject, other: vlib.Core.GameObject)
--
--- Kill callback.
--- Called when you run `lstg.Kill(obj)`.
---@field kill fun(self: vlib.Core.GameObject)


--- Game class definition table.
---@class vlib.Core.GameClass.classdef
--
--- The static definition area.
---@field [1] vlib.Core.GameClass.staticdef

--- Game class static definition table.
---@class vlib.Core.GameClass.staticdef
--
--- Specifies base class.
---@field [1] vlib.Core.GameClass
--
--- Specifies which functions are engine managed and optimized.
---@field default_function vlib.Core.GameClass.default_function
--
--- Determines if the object is a render object or not (can set blendmode and color values on it)
---@field render boolean


--- LuaSTG engine-managed default functions bitflag.
---@alias vlib.Core.GameClass.default_function
---| 0x00 # no engine optimizations
---| 0x08 # frame callback optimized
---| 0x10 # render callback optimized
---| 0x18 # render and frame callbacks optimized

-------------------------------------------------

-- Forward declarations

---@type vlib.Core.GameClass
local BaseGameObject

local clsmeta, objmeta

--- Builds a LuaSTG game class.  
--- The layout of the table that you pass in should include the functions that will be run,
--- and an optional table at index [1] that specifies class static fields and other metadata,
--- such as its base class (at index [1] of this subtable), renderobject status,
--- and LuaSTG default function optimizations.  
--- See the [classes readme](../../../doc/Core/Classes.md) for more information.
---@param classdef vlib.Core.GameClass.classdef The table of class definitions.
---@return vlib.Core.GameClass
local function GameClass(classdef)
    --- A LuaSTG game object class.
    ---@class vlib.Core.GameClass: lstg.Class
    --
    --- Class constructor (calls obj:init(...))
    ---@operator call(...): vlib.Core.GameObject
    local cls = { is_class = true }

    if type(classdef[1]) == "table" then
        if classdef[1][1] then
            if not classdef[1][1].is_class then
                error("The base class is not a game class!")
            end
            ---@type vlib.Core.GameClass
            cls.base = classdef[1][1]
            classdef[1][1] = nil
        end
        if cls.base and cls.base[".render"] then
            cls[".render"] = cls.base[".render"]
        end
        if cls.base and cls.base.default_function then
            cls.default_function = cls.base.default_function
        end
        if classdef[1].render ~= nil then
            cls[".render"] = classdef[1].render
            classdef[1].render = nil
        end
        for k, v in pairs(classdef[1]) do
            cls[k] = v
        end
    end
    classdef[1] = nil

    ---@type vlib.Core.GameClass
    cls.base = cls.base or BaseGameObject

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

    cls[1] = function(_) end
    cls[2] = methods.del
    cls[3] = methods.frame
    cls[4] = methods.render
    cls[5] = methods.collision
    cls[6] = methods.kill

    ---@type function[]
    cls.methods = methods

    setmetatable(cls, clsmeta)

    return cls
end

---@type vlib.Core.GameClass
BaseGameObject = GameClass {
    init = function(self) end,
    del = function(self) end,
    frame = function(self) end,
    render = lstg.DefaultRenderFunc,
    collision = function(self, other) end,
    kill = function(self) end,
}

clsmeta = {
    __name = "GameClass",
    __index = function(self, k)
        return rawget(self, "base") and self.base[k]
    end,
    __call = function(self, ...)
        ---@type lstg.GameObject|vlib.Core.GameObject
        local obj = lstg.New(self)
        setmetatable(obj, objmeta)
        if self.newinst then
            self:newinst(obj)
        end
        obj:init(...)
        return obj
    end
}

objmeta = {
    __name = "GameObject",
    __newindex = lstg.SetAttr,
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
        return lstg.GetAttr(self, k) or self.class.methods[k]
    end,
    __call = function(self, ...)
        return self:call(...)
    end,
    __tostring = function(self)
        if not self.tostring then
            return "GameObject"
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

return GameClass
