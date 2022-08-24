
local package_path_before = package.path
package.path = package.path .. "src/VeritaLib/Core/?.lua;"

---@class vlib.Core Core libraries for VeritaLib functionality.
local Core = {
    GameClass = require("GameClass"),
    LogicClass = require("LogicClass"),
    GlobalCallbacks = require("GlobalCallbacks"),
    Scene = require("Scene"),
    Task = require("Task"),
    Window = require("Window")
}

package.path = package_path_before

return Core
