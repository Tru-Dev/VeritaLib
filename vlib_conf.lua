
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

    --- Whether to enable Dear ImGui in the result.  
    --- Implied by `debug.enable`.
    enable_imgui = true,

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
        -- Example configuration

        -- Example menu context
        menu = {
            dir = {
                -- In this case, creates boolean inputs dir.up, dir.down, dir.left, and dir.right
                type = "directional",
                keyboard = {
                    -- See lstg.Input.Keyboard module

                    up = "Up",
                    down = "Down",
                    left = "Left",
                    right = "Right",
                },
                gamepad = {
                    -- See xinput module

                    up = "Up",
                    down = "Down",
                    left = "Left",
                    right = "Right",
                },
                -- Does not create analog input for joysticks, joysticks are mapped to boolean inputs.
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

        -- Example game context
        game = {
            dir = {
                -- In this case, creates analog inputs dir.x and dir.y, and creates boolean inputs
                -- dir.up, dir.down, dir.left, and dir.right.  
                -- Boolean inputs are checked for keyboard only.
                type = "analog",
                keyboard = {
                    -- See lstg.Input.Keyboard

                    up = "Up",
                    down = "Down",
                    left = "Left",
                    right = "Right",
                },
                -- Set gamepad to nil as dpad will not be used.

                -- Creates analog input for joysticks, digital buttons are mapped to analog inputs.
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
