
--- Stores VeritaLib configuration, such as debug mode behaviors and target resolution.
---@class vlib_conf
local vlib_conf = {
    --------- Debug ---------

    --- Controls VeritaLib debug behaviors.
    debug = {
        --- Whether to enable VeritaLib debug behaviors.
        enable = true,

        --- The rest of the fields in this table will be ignored if enable is false.

        --- Whether to show the debug UI by default. It can be toggled by F12 in debug mode.
        show_ui = false,
    },


    --------- General ---------

    --- Game-specific default values for `config.json`.
    default_config = {},

    --------- Viewport ---------

    --- Game target resolution.
    target_res = {
        width = 1920,
        height = 1080,
    },
}

return vlib_conf
