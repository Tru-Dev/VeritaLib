
--- Stores VeritaLib preprocessor configuration, such as debug mode behaviors and target resolution.
---@class vlib_conf
local vlib_conf = {
    --------- Debug ---------

    --- Controls VeritaLib debug behaviors.
    debug = {
        --- Whether to enable VeritaLib debug behaviors.
        enable = true,

        --- The rest of the fields in this table will be ignored if enable is false.

    },


    --------- General ---------

    --- Game-specific default values for `config.json`.
    default_config = {},

    --------- Source Result ---------

    --- Whether to remove comments in the output.  
    --- Implied by `minify`.
    no_comments = false,

    --- Whether to minify the Lua files (removes comments + insignificant whitespace).
    minify = false,

    --------- Viewport ---------

    --- Game target resolution.
    target_res = {
        width = 1920,
        height = 1080,
    },
}

return vlib_conf
