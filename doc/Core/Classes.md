# Object-oriented design
Classes work as one would expect from a language like Python, as there is no true encapsulation.  
However, features such as single inheritance, operator overloading, and static fields are implemented.

- [Two types of classes](#two-types-of-classes)
  - [Game Classes](#game-classes)
  - [Logic Classes](#logic-classes)
- [OOP features (with examples):](#oop-features-with-examples)
  - [Inheritance (with proper base class resolution courtesy of `as_base`):](#inheritance-with-proper-base-class-resolution-courtesy-of-as_base)
  - [Static fields:](#static-fields)
  - [Operator overloading:](#operator-overloading)

## Two types of classes

### [Game Classes](GameClass.lua)
Game classes hook into LuaSTG's default object callback system, while extending it with more OOP features.

Example usage:
```lua
local GameClass = require("VeritaLib.Core.GameClass")

local Example = GameClass {
    init = function(self, x, y)
        self.x = x
        self.y = y
        self.img = "Example"
    end
}

-- spawns an example object at the origin
local obj = Example(0, 0)
```
Note: game objects should be instantiated by calling the class, like in Python. This differs from
the usual LuaSTG syntax, `lstg.New()`, which is called under the hood.

Note: the collision callback has been changed to `collsion` as there is an object field with the
key `colli`. 

Tip: there are 2 static fields on game classes that have meaning to LuaSTG:
- Setting `render = true` means that objects created from this class are render objects, and have
  the following extra fields:
  - `_blend`: The blend mode of the object.
  - `_color`: The object's color (`lstg.Color`).
  - `_a`: The object's color's alpha value (0 - 255).
  - `_r`: The object's color's red value (0 - 255).
  - `_g`: The object's color's green value (0 - 255).
  - `_b`: The object's color's blue value (0 - 255).
- `default_function` tells LuaSTG to not search for the callbacks specified on the objects of this
  class. This is useful as an optimization when you do not have either or both callbacks defined in
  your class.
  - `0x00`: The default value, search for frame and render callbacks on this class.
  - `0x08`: Do not search for a frame callback on this class (optimize frame callback).
  - `0x10`: Do not search for a render callback on this class (optimize render callback, behaves
    like `lstg.DefaultRenderFunc(self)`).
  - `0x18`: Combines `0x08` and `0x10`, both frame and render callbacks are optimized.

### [Logic Classes](LogicClass.lua)

Example usage:
```lua
local LogicClass = require("VeritaLib.Core.LogicClass")

local Example2 = LogicClass {
    init = function(self, a)
        self.a = a
        print(a)
    end
}

-- prints "Hello, World!" and stores it to the object
local obj = Example2("Hello, World!")
```

## OOP features (with examples):

### Inheritance (with proper base class resolution courtesy of `as_base`):
```lua
-- does not inherit any classes
local InheritanceExample1 = LogicClass {
    init = function(self)
        print("The base class constructor was called!")
    end
}
local InheritanceExample2 = LogicClass {
    -- inherit from InheritanceExample1
    { InheritanceExample1 };
    init = function(self)
        -- as_base carries over the current object's state, but calls the base class's methods
        self.as_base:init()
        print("The second class constructor was called!")
    end
}
local InheritanceExample3 = LogicClass {
    -- inherit from InheritanceExample2
    { InheritanceExample2 };
    init = function(self)
        self.as_base:init()
        print("The third class constructor was called!")
    end
}
-- should print 3 lines
-- wheras under other libraries it would recurse infinitely
local obj = InheritanceExample3()
```
### Static fields:
```lua
-- a partial example implementation of a boss class that can track multiple active bosses
local Boss = GameClass {
    {
        -- not shown here
        EnemyBase;
        active_bosses = {},
    };
    init = function(self)
        self.as_base:init()
        -- this works even when subclassing
        table.append(self.class.active_bosses, self)
    end
}

local boss1 = Boss()
local boss2 = Boss()
print(Boss.active_bosses[1] == boss1) -- true
```
### Operator overloading:
```lua
-- a partial example implementation of a vector with 2 components
local Vector2 = LogicClass {
    init = function(self, x, y)
        self.x = x
        self.y = y
    end,
    add = function(self, other)
        -- type checks omitted
        return Vector2(self.x + other.x, self.y + other.y)
    end
    -- ...
}

local v1 = Vector2(10, 5)
local v2 = Vector2(15, -30)
local v3 = v1 + v2
print(v3.x, v3.y) -- 25    -25
```
Most Lua metamethods are supported, the exceptions are `index` and `newindex`.
See [the Lua manual](https://www.lua.org/manual/5.1/manual.html#2.8) for more information.
