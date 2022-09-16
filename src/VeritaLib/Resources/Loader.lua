
--- Asynchronous resource loader that loads from a resource defintion file.
local Loader = {}

--- Loads the resources outlined in the resource definition synchronously.
---@param resdef string The file path of the resource definiton (relative to the `res` folder).
---@param pager vlib.Resources.TexturePager The texture pager to use.
function Loader.LoadResNow(resdef, pager)
    local f = io.open("res/" .. resdef, "r")
    if not f then
        error("Could not open file res/" .. resdef)
    end
    local to_load = cjson.decode(f:read("*a"))

    if to_load.tex then
        for k, v in pairs(to_load.tex) do
            lstg.LoadTexture(k, "res/" .. v.file, v.mipmap)
            if not v.nopage then
                pager:add_tex(k)
            end
        end
    end
    pager:prepare_pages()
    if to_load.img then
        for k, v in pairs(to_load.img) do
            if to_load.tex[v.tex].nopage then
                local w, h = lstg.GetTextureSize(v.tex)
                local region = v.region or { x = 0, y = 0, w = w, h = h }
                lstg.LoadImage(k, v.tex, region.x, region.y, region.w, region.h)
            else
                pager:add_img(k, v.tex, v.region)
            end
        end
    end
    if to_load.img_group then
        for k, v in pairs(to_load.img_group) do
            if to_load.tex[v.tex].nopage then
                local w, h = lstg.GetTextureSize(v.tex)
                local region = v.region or { x = 0, y = 0, w = w, h = h }
                local sw, sh = region.w / v.columns, region.h / v.rows
                local idx = 1
                for i = 1, v.rows do
                    for j = 1, v.columns do
                        local subregion = {
                            x = (j - 1) * sw + region.x,
                            y = (i - 1) * sh + region.y,
                            w = sw,
                            h = sh
                        }
                        lstg.LoadImage(
                            k .. "_" .. idx, v.tex,
                            subregion.x, subregion.y,
                            subregion.w, subregion.h
                        )
                        idx = idx + 1
                    end
                end
            else
                pager:add_img_group(k, v.tex, v.rows, v.columns, v.region)
            end
        end
    end
    if to_load.anim then
        for k, v in pairs(to_load.anim) do
            if to_load.tex[v.tex].nopage then
                local w, h = lstg.GetTextureSize(v.tex)
                local region = v.region or { x = 0, y = 0, w = w, h = h }
                local sw, sh = region.w / v.columns, region.h / v.rows
                lstg.LoadAnimation(
                    k, v.tex,
                    region.x, region.y,
                    sw, sh,
                    v.columns, v.rows,
                    v.aniv
                )
            else
                pager:add_anim(k, v.tex, v.rows, v.columns, v.aniv, v.region)
            end
        end
    end
    pager:prepare_images()

    if to_load.bgm then
        for k, v in pairs(to_load.bgm) do
            lstg.LoadMusic(
                k, "res/" .. v.file,
                v.loop_end, v.loop_len
            )
        end
    end

    if to_load.snd then
        for k, v in pairs(to_load.snd) do
            lstg.LoadSound(k, "res/" .. v.file)
        end
    end

    if to_load.fnt then
        for k, v in pairs(to_load.fnt) do
            lstg.LoadFont(k, "res/" .. v.file, v.mipmap)
        end
    end

    if to_load.ttf then
        for k, v in pairs(to_load.ttf) do
            lstg.LoadTTF(k, "res/" .. v.file, v.width, v.height)
        end
    end

    if to_load.fx then
        for k, v in pairs(to_load.fx) do
            lstg.LoadFX(k, "res/" .. v.file)
        end
    end

end

--- Loads the resources outlined in the resource definition asynchronously.
---@param resdef string The file path of the resource definiton (relative to the `res` folder).
---@param pager vlib.Resources.TexturePager The texture pager to use.
---@return thread @The coroutine to call per frame.
function Loader.LoadResAsync(resdef, pager)
    local f = io.open("res/" .. resdef, "r")
    if not f then
        error("Could not open file res/" .. resdef)
    end
    local to_load = cjson.decode(f:read("*a"))

    local segment_val = 0
    local timer = lstg.StopWatch()
    timer:Pause()

    local function yield_for_frame()
        if timer:GetElapsed() >= 0.014 then
            timer:Reset()
            timer:Pause()
            coroutine.yield(segment_val)
            timer:Resume()
        end
    end

    return coroutine.create(function()
        timer:Resume()
        if to_load.tex then
            for k, v in pairs(to_load.tex) do
                lstg.LoadTexture(k, "res/" .. v.file, v.mipmap)
                if not v.nopage then
                    pager:add_tex(k)
                end
                yield_for_frame()
            end
        end
        pager:prepare_pages()

        segment_val = 1
        if to_load.img then
            for k, v in pairs(to_load.img) do
                if to_load.tex[v.tex].nopage then
                    local w, h = lstg.GetTextureSize(v.tex)
                    local region = v.region or { x = 0, y = 0, w = w, h = h }
                    lstg.LoadImage(k, v.tex, region.x, region.y, region.w, region.h)
                else
                    pager:add_img(k, v.tex, v.region)
                end
                yield_for_frame()
            end
        end
        if to_load.img_group then
            for k, v in pairs(to_load.img_group) do
                if to_load.tex[v.tex].nopage then
                    local w, h = lstg.GetTextureSize(v.tex)
                    local region = v.region or { x = 0, y = 0, w = w, h = h }
                    local sw, sh = region.w / v.columns, region.h / v.rows
                    local idx = 1
                    for i = 1, v.rows do
                        for j = 1, v.columns do
                            local subregion = {
                                x = (j - 1) * sw + region.x,
                                y = (i - 1) * sh + region.y,
                                w = sw,
                                h = sh
                            }
                            lstg.LoadImage(
                                k .. "_" .. idx, v.tex,
                                subregion.x, subregion.y,
                                subregion.w, subregion.h
                            )
                            idx = idx + 1
                        end
                    end
                else
                    pager:add_img_group(k, v.tex, v.rows, v.columns, v.region)
                end
                yield_for_frame()
            end
        end

        segment_val = 2
        if to_load.anim then
            for k, v in pairs(to_load.anim) do
                if to_load.tex[v.tex].nopage then
                    local w, h = lstg.GetTextureSize(v.tex)
                    local region = v.region or { x = 0, y = 0, w = w, h = h }
                    local sw, sh = region.w / v.columns, region.h / v.rows
                    lstg.LoadAnimation(
                        k, v.tex,
                        region.x, region.y,
                        sw, sh,
                        v.columns, v.rows,
                        v.aniv
                    )
                else
                    pager:add_anim(k, v.tex, v.rows, v.columns, v.aniv, v.region)
                end
                yield_for_frame()
            end
        end
        pager:prepare_images()

        segment_val = 3
        if to_load.bgm then
            for k, v in pairs(to_load.bgm) do
                lstg.LoadMusic(
                    k, "res/" .. v.file,
                    v.loop_end, v.loop_len
                )
                yield_for_frame()
            end
        end

        segment_val = 4
        if to_load.snd then
            for k, v in pairs(to_load.snd) do
                lstg.LoadSound(k, "res/" .. v.file)
                yield_for_frame()
            end
        end

        segment_val = 5
        if to_load.ps then
            for k, v in pairs(to_load.ps) do
                lstg.LoadPS(k, "res/" .. v.file, v.img)
                yield_for_frame()
            end
        end

        segment_val = 6
        if to_load.fnt then
            for k, v in pairs(to_load.fnt) do
                lstg.LoadFont(k, "res/" .. v.file, v.mipmap)
                yield_for_frame()
            end
        end

        segment_val = 7
        if to_load.ttf then
            for k, v in pairs(to_load.ttf) do
                lstg.LoadTTF(k, "res/" .. v.file, v.width, v.height)
                yield_for_frame()
            end
        end

        segment_val = 8
        if to_load.fx then
            for k, v in pairs(to_load.fx) do
                lstg.LoadFX(k, "res/" .. v.file)
                yield_for_frame()
            end
        end

        return 9
    end)
end

return Loader
