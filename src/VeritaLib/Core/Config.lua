
--- Reads and stores variables in `config.json`.
---@class vlib.Core.Config: vlib.Core.JsonTable
---@field [string] any
local Config = {}

local JsonTable = require(".JsonTable")

--- Saves the current configuration.
---@return boolean
function Config.Save()
    return JsonTable.ToFile(Config, "config.json")
end

--- Loading the config file

-- The config loading requires behavior that is a little
-- more robust than what is found in JsonTable.

local config_table = {}
do
    local config_file = io.open("config.json", "r")
    if config_file then
        config_table = cjson.decode(config_file:read("*a"))
        config_file:close()
    end

    local function merge(t1, t2)
        for k, v in pairs(t2) do
            -- Only overwrite if types differ
            if type(t1[k]) ~= type(t2[k]) then
                if type(v) == "table" then
                    t1[k] = {}
                    t1[k] = merge(t1[k], t2[k])
                else
                    t1[k] = v
                end
            end
        end
        return t1
    end

    local vlib_conf = require("vlib_conf")
    config_table = merge(config_table, {
        dgpu_trick = false,
        gpu = "",
        fullscreen_resolution = {
            width = 1920,
            height = 1080,
        },
        window_size = {
            width = 1600,
            height = 900,
        },
        refresh_rate_numerator = 0,
        refresh_rate_denominator = 0,
        windowed = true,
        vsync = false,
        window_scaling = "aspect",
    })
    config_table = merge(config_table, vlib_conf.default_config)
end

Config = JsonTable.New(config_table, Config) --[[@as vlib.Core.Config]]

return Config
