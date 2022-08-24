
local ctx_stack = {}
local view_stacks = {
    view_mode = {},
    view_data = {},
    viewport = {},
    scissor_rect = {},
    image_scale = {},
}

---@alias vlib.Graphics.ViewMode
---| "2d"
---| "3d"

---@alias vlib.Graphics.ClearType
---| "local"
---| "full"

---@class vlib.Graphics.Context.Initializer
--
--- Specifies the view mode of the context, or nil to pass through. 
---@field view_mode vlib.Graphics.ViewMode|nil
--
--- The context's default view data (must be specified with view_mode).
---@field view_data number[]|nil
--
--- The context's viewport (nil to not set).
---@field viewport number[]|nil
--
--- The context's crop rectangle (nil to not set).
---@field scissor_rect number[]|nil
--
--- The context's clear color.
---@field clear_color lstg.Color
--
--- Determines how the context clears the screen (nil to not clear).
---@field clear_type vlib.Graphics.ClearType|nil
--
--- Determines the fog for this context.  
--- (follows parameter overloads - empty table disables fog, nil does not call `lstg.SetFog()`)
---@field fog {}|{ [1]: number, [2]: number, [3]: lstg.Color }|nil
--
--- The context's image scaling (nil to not set).
---@field image_scale number|nil
--
--- If true, creates a render target with the context's name. Defaults to false.
---@field capture boolean|nil
--
--- If `capture` is true, creates an image associated with the render target.
---@field create_image boolean|nil
--
--- If `capture` is true, the render target created will be that width.
---@field width integer|nil
--
--- If `capture` is true, the render target created will be that height.
---@field height integer|nil

--- Creates a new rendering context.  
--- ## Please call `del()` when you don't need the context anymore!
--- This includes if an object has its own context, and it gets deleted.
--- ***
--- See `vlib.Graphics.Context.Initializer` for more info on the parameters it passes.
--- You can leave `init` as nil if you just want to use shaders in this context.  
--- If you don't initialize a value, it will stay nil; however, if you do initialize it,
--- you are allowed to change it.  
--- All fields (except for `view_mode`, `clear_type`, and fields relating to the render target itself)
--- can be changed with setter methods, while fields that are tables (and clear_color) can be modified
--- through their indices as well.  
--- However, a setter method will not be added if that field is initially nil.  
--- If this is a 3D context, then additional setter methods are provided for convenience.
---@param name string The name of the context. Required.
---@param init vlib.Graphics.Context.Initializer|nil The initializer list.
---@return vlib.Graphics.Context
function Context(name, init)
    if not init then init = {} end

    if init.capture == nil then
        init.capture = false
    end
    if init.create_image == nil then
        init.create_image = false
    end

    local w, h
    if init.width ~= nil then
        if init.height == nil then
            error("You must specify width and height together, not one or the other.")
        end
        w, h = init.width, init.height
    else
        if init.height ~= nil then
            error("You must specify width and height together, not one or the other.")
        end
        local vlib_conf = require("vlib_conf")
        w, h = vlib_conf.target_res.width, vlib_conf.target_res.height
    end

    if init.view_mode then
        init.view_mode = string.lower(init.view_mode)
    end

    --- Defines a rendering context. All fields are read-only.
    ---@class vlib.Graphics.Context
    --
    --- The name of the context, which is the name of the render target if `capture` is true,
    --- and is used in naming shader render targets.
    ---@field name string
    --
    --- Whether the context is captured in a render target.
    ---@field capture boolean
    --
    --- Whether an image has been created and associated with this render target.
    ---@field image boolean
    --
    --- The width of the render target.
    ---@field width integer
    --
    --- The height of the render target.
    ---@field height integer
    --
    --- The context's view mode/camera type (nil to pass through).
    ---@field view_mode string|nil
    --
    --- The context's view data (nil when `view_mode` is nil).
    ---@field view_data number[]|nil
    --
    --- The context's viewport (nil to not set).
    ---@field viewport number[]|nil
    --
    --- The context's crop rectangle (nil to not set).
    ---@field scissor_rect number[]|nil
    --
    --- The context's clear color.
    ---@field clear_color lstg.Color
    --
    --- Determines how the context clears the screen (nil to not clear).
    ---@field clear_type vlib.Graphics.ClearType|nil
    --
    --- Determines the fog for this context.  
    --- (follows parameter overloads - empty table disables fog, nil does not call `lstg.SetFog()`)
    ---@field fog {}|{ [1]: number, [2]: number, [3]: lstg.Color }|nil
    --
    --- The context's image scaling (nil to not set).
    ---@field image_scale number|nil
    --
    --- Calls the function specified between `begin` and `apply`.
    ---@operator call(fun()): nil
    local ctx = {
        name = name,
        capture = init.capture,
        image = init.create_image and init.capture --[[@as boolean]] ,
        width = w --[[@as integer]] ,
        height = h --[[@as integer]] ,
        view_mode = init.view_mode,
        view_data = init.view_data,
        viewport = init.viewport,
        scissor_rect = init.scissor_rect,
        clear_color = init.clear_color or lstg.Color(0xFF000000),
        clear_type = init.clear_type,
        fog = init.fog,
        image_scale = init.image_scale,
    }

    local function construct_mt(t)
        return {
            __index = t,
            __newindex = function(_, k, v)
                if type(t[k]) ~= type(v) then
                    error(
                        "Invalid type assignment.\n" ..
                        "You can't change the type of a table element that is" ..
                        "inside a context."
                    )
                end
                t[k] = v
            end
        }
    end

    for k, v in pairs(ctx) do
        if type(v) == "table" then
            ctx[k] = setmetatable({}, construct_mt(v))
        end
    end

    if init.view_mode then
        --- Sets the view data.
        ---@param v number[]
        function ctx.set_view_data(v)
            ctx.view_data = setmetatable({}, construct_mt(v))
        end
    end
    if init.viewport then
        --- Sets the view data.
        ---@param v number[]
        function ctx.set_viewport(v)
            ctx.viewport = setmetatable({}, construct_mt(v))
        end
    end
    if init.scissor_rect then
        --- Sets the view data.
        ---@param v number[]
        function ctx.set_scissor_rect(v)
            ctx.scissor_rect = setmetatable({}, construct_mt(v))
        end
    end
    if init.clear_type then
        --- Sets the view data.
        ---@param v lstg.Color
        function ctx.set_clear_color(v)
            ctx.clear_color = setmetatable({}, construct_mt(v))
        end
    end
    if init.fog then
        --- Sets the view data.
        ---@param v {}|{ [1]: number, [2]: number, [3]: lstg.Color }
        function ctx.set_fog(v)
            ctx.fog = setmetatable({}, construct_mt(v))
        end
    end
    if init.image_scale then
        --- Sets the view data.
        ---@param v number
        function ctx.set_image_scale(v)
            ctx.image_scale = setmetatable({}, construct_mt(v))
        end
    end

    if ctx.view_mode == "2d" then
        ctx.view_data = ctx.view_data or { 0, 1, 0, 1 }
    elseif ctx.view_mode == "3d" then
        ctx.view_data = ctx.view_data or {
            -- at the origin
            0, 0, 0,
            -- looking forwards
            0, 0, 1,
            -- positive y is up
            0, 1, 0,
            -- field of view
            0.6,
            -- aspect is 16:9
            16 / 9,
            -- near and far planes
            1, 100
        }
        --- Sets the position of the camera in 3D.  
        --- This function is only defined for 3D contexts.
        ---@param x number
        ---@param y number
        ---@param z number
        function ctx.set3d_pos(x, y, z)
            ctx.view_data[1] = x
            ctx.view_data[2] = y
            ctx.view_data[3] = z
        end

        --- Sets where the camera is looking in 3D.  
        --- This function is only defined for 3D contexts.
        ---@param x number
        ---@param y number
        ---@param z number
        function ctx.set3d_at(x, y, z)
            ctx.view_data[4] = x
            ctx.view_data[5] = y
            ctx.view_data[6] = z
        end

        --- Sets the up direction for the camera in 3D.  
        --- This function is only defined for 3D contexts.
        ---@param x number
        ---@param y number
        ---@param z number
        function ctx.set3d_up(x, y, z)
            ctx.view_data[7] = x
            ctx.view_data[8] = y
            ctx.view_data[9] = z
        end

        --- Sets the vertical field of view for the camera in 3D.  
        --- This function is only defined for 3D contexts.
        ---@param fov number
        function ctx.set3d_fov(fov)
            ctx.view_data[10] = fov
        end

        --- Sets the aspect ratio for the camera in 3D.  
        --- This function is only defined for 3D contexts.
        ---@param aspect number
        function ctx.set3d_aspect(aspect)
            ctx.view_data[11] = aspect
        end

        --- Sets the near and far planes for the camera in 3D.  
        --- This function is only defined for 3D contexts.
        ---@param near number
        ---@param far number
        function ctx.set3d_near_far(near, far)
            ctx.view_data[12] = near
            ctx.view_data[13] = far
        end
    end

    local shaders = {}

    if ctx.capture then
        ---@cast w -nil
        ---@cast h -nil
        lstg.CreateRenderTarget(name, w, h)
        if init.create_image then
            ---@cast w -nil
            ---@cast h -nil
            lstg.LoadImage(name, name, 0, 0, w, h)
        end
    end

    --- Begins rendering in this context.
    function ctx.begin()
        table.insert(ctx_stack, ctx)
        if ctx.capture then
            lstg.PushRenderTarget(name)
        end
        for _, s in ipairs(shaders) do
            lstg.PushRenderTarget(s[2])
        end

        if ctx.viewport then
            local t = getmetatable(ctx.viewport).__index
            lstg.SetViewport(unpack(t))
            table.insert(view_stacks.viewport, t)
        end
        if ctx.scissor_rect then
            local t = getmetatable(ctx.scissor_rect).__index
            lstg.SetScissorRect(unpack(t))
            table.insert(view_stacks.scissor_rect, t)
        end
        if ctx.clear_type == "full" then
            lstg.RenderClear(ctx.clear_color)
        elseif ctx.clear_type == "local" then
            lstg.SetOrtho(0, 1, 0, 1)
            lstg.RenderRect("render_clear", 0, 1, 0, 1)
        end
        if ctx.image_scale then
            lstg.SetImageScale(ctx.image_scale)
            table.insert(view_stacks.image_scale, ctx.image_scale)
        end
        if ctx.fog then
            local t = getmetatable(ctx.fog).__index
            lstg.SetFog(unpack(t))
        end
        if ctx.view_mode then
            local t = getmetatable(ctx.view_data).__index
            if ctx.view_mode == "2d" then
                lstg.SetOrtho(unpack(t))
            elseif ctx.view_mode == "3d" then
                lstg.SetPerspective(unpack(t))
            end
            table.insert(view_stacks.view_mode, ctx.view_mode)
            table.insert(view_stacks.view_data, t)
        end
    end

    --- Ends rendering in this context.
    --- The result is then determined by the `result` field of the context.  
    --- Throws an error if this context is not at the top of the stack.
    function ctx.apply()
        if table.remove(ctx_stack) ~= ctx then
            error(
                "Applied context did not match the top of the stack!\n" ..
                "Did you forget to apply a previous context?"
            )
        end
        for _, s in ipairs(shaders) do
            lstg.PopRenderTarget()
            lstg.PostEffect(unpack(s))
        end
        if ctx.capture then
            lstg.PopRenderTarget()
        end
        -- now restore the previous state
        if ctx.viewport then
            table.remove(view_stacks.viewport)
            if #view_stacks.viewport > 0 then
                lstg.SetViewport(unpack(view_stacks.viewport[#view_stacks.viewport]))
            end
        end
        if ctx.scissor_rect then
            table.remove(view_stacks.scissor_rect)
            if #view_stacks.scissor_rect > 0 then
                lstg.SetScissorRect(unpack(view_stacks.scissor_rect[#view_stacks.scissor_rect]))
            end
        end
        if ctx.image_scale then
            table.remove(view_stacks.image_scale)
            if #view_stacks.image_scale > 0 then
                lstg.SetImageScale(view_stacks.image_scale[#view_stacks.image_scale])
            end
        end
        if ctx.view_mode then
            table.remove(view_stacks.view_mode)
            table.remove(view_stacks.view_data)
            if #view_stacks.view_mode > 0 then
                if view_stacks.view_mode[#view_stacks.view_mode] == "2d" then
                    lstg.SetOrtho(unpack(view_stacks.view_data[#view_stacks.view_data]))
                elseif view_stacks.view_mode[#view_stacks.view_mode] == "3d" then
                    lstg.SetPerspective(unpack(view_stacks.view_data[#view_stacks.view_data]))
                end
            end
        end
    end

    --- Adds a new shader to the context.
    --- Parameters are analogous to `lstg.PostEffect()`.
    ---@param fxname string
    ---@param samplerstate lstg.PostEffectSamplerState
    ---@param float_params { [1]: number, [2]: number, [3]: number, [4]: number }[]
    ---@param tex_params { [1]: string, [2]: lstg.PostEffectSamplerState }[]
    function ctx.push_shader(fxname, samplerstate, float_params, tex_params)
        local t = name .. "_" .. #shaders
        lstg.CreateRenderTarget(t)
        table.insert(shaders, {
            fxname,
            t,
            samplerstate,
            float_params,
            tex_params
        })
    end

    --- Sets the shader parameters for the shader at the index specified.  
    --- If `nil` is provided for a parameter, it keeps its current value.
    ---@param idx integer
    ---@param float_params { [1]: number, [2]: number, [3]: number, [4]: number }[]|nil
    ---@param tex_params { [1]: string, [2]: lstg.PostEffectSamplerState }[]|nil
    function ctx.set_shader_params(idx, float_params, tex_params)
        if float_params then
            shaders[idx][4] = float_params
        end
        if tex_params then
            shaders[idx][5] = tex_params
        end
    end

    --- Removes a shader from the context.
    function ctx.pop_shader()
        local t = table.remove(shaders)[2]
        local resp = lstg.CheckRes(1, t)
        if resp then
            lstg.RemoveResource(resp, 1, t)
        end
    end

    --- Invalidates the rendering context and frees any render targets that were associated with it.  
    --- **Make sure you free any resources associated with the context!!**  
    --- (includes image sprites, animations, and objects that depend on them)
    function ctx.del()
        for _ = 1, #shaders do
            ctx.pop_shader()
        end
        if ctx.capture then
            if init.create_image then
                local resp = lstg.CheckRes(2, name)
                if resp then
                    lstg.RemoveResource(resp, 2, name)
                end
            end
            local resp = lstg.CheckRes(1, name)
            if resp then
                lstg.RemoveResource(resp, 1, name)
            end
        end
        ---@diagnostic disable-next-line: cast-local-type
        ctx = nil -- destroy the reference
    end

    return setmetatable({}, {
        __index = ctx,
        __newindex = function()
            error("Setting context fields directly is not allowed.")
        end,
        --- Calls the function specified between `begin` and `apply`.
        ---@param _ table
        ---@param fn fun()
        __call = function(_, fn)
            ctx.begin()
            fn()
            ctx.apply()
        end
    })
end

return Context
