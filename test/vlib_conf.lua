
--- Stores VeritaLib preprocessor configuration, such as debug mode behaviors and target resolution.
---@class vlib_conf
local vlib_conf = {
    --------- Debug ---------

    --- Controls VeritaLib debug behaviors.
    debug = {
        --- Whether to enable VeritaLib debug behaviors.
        enable = true,

        --- The rest of the fields in this table will be ignored if `enable` is false.

        --- Debug controls, keyboard only.  
        --- Resides in the `debug` input context.
        input_commands = {
            show_ui = "F12",
        },
    },


    --------- General ---------

    --- Game-specific default values for `config.json`.
    default_config = {
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
        deadzone = 0.25,
        dir_threshold = 0.35,
    },

    --------- Resources ---------

    --- Size of one texture page.
    texpage_size = {
        width = 4096,
        height = 4096,
    },

    --- Default resource folder path
    respath = "res",

    --------- Input ---------

    --- A list of commands used by your game mapped to their default inputs.  
    --- Split into several contexts, which can be checked independently from each other.
    input_commands = {
        test = {
            exit = {
                type = "button",
                keyboard = "Escape"
            },
        },

        menu = {
            dir = {
                type = "directional",
                keyboard = {
                    up = "Up",
                    down = "Down",
                    left = "Left",
                    right = "Right",
                },
                gamepad = {
                    up = "Up",
                    down = "Down",
                    left = "Left",
                    right = "Right",
                },
                joystick = "both",
            },
            accept = {
                type = "button",
                keyboard = "Z",
                gamepad = "A",
            },
            back = {
                type = "button",
                keyboard = "X",
                gamepad = "B",
            },
        },

        game = {
            dir = {
                type = "analog",
                keyboard = {
                    up = "Up",
                    down = "Down",
                    left = "Left",
                    right = "Right",
                },
                joystick = "left",
            },
            shot = {
                type = "button",
                keyboard = "Z",
                gamepad = "A",
            },
            bomb = {
                type = "button",
                keyboard = "X",
                gamepad = "B",
            },
        },
    },

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
