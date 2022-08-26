local config = dofile("./vlib_conf.lua")

function OnSetText(uri, text)
    if uri:sub(-5, -1) ~= '.luap' then
        return nil
    end
    local diffs = {}
    local s = 1
    local dparen_replace = {}
    while true do
        local ss, e, lua = text:find("^#+([^\n]*\n?)", s)
        if not e then
            ss, e, lua = text:find("\n#+([^\n]*\n?)", s)
            local is = 1
            local text2 = text:sub(s, ss)
            for ibegin, iend in text2:gmatch("()$%b()()") do
                local executed = text2:sub(ibegin + 2, iend - 2)
                for k, v in pairs(dparen_replace) do
                    print(k, v, executed)
                    if executed == k then
                        table.insert(diffs, {
                            start = s + ibegin - 1,
                            finish = s + iend - 2,
                            text = v
                        })
                        goto continue
                    end
                end
                if executed:sub(1, 7) == "config." then
                    local to_load = "local config = ...; return " .. executed
                    local loaded = load(to_load)(config)
                    table.insert(diffs, {
                        start = ibegin,
                        finish = iend - 1,
                        text = ("%q"):format(loaded)
                    })
                else
                    table.insert(diffs, {
                        start = s + ibegin - 1,
                        finish = s + iend - 2,
                        text = ""
                    })
                end
                ::continue::
            end
            if not e then break end
        end
        if text:sub(ss, ss + 3) == "#--=" then
            ---@cast text string
            local _, _, line = text:sub(ss, e):find("#--%s*([^\n]*)")
            for k, v in line:gmatch("([_%a][_%w]*)%s*=%s*(%d+)") do
                dparen_replace[k] = v
            end
            for k, v in line:gmatch("([_%a][_%w]*)%s*=%s*([_%a][_%w]*)") do
                dparen_replace[k] = v
            end
            for k, v in line:gmatch("([_%a][_%w]*)%s*=%s*(\"[_%a][_%w]*\")") do
                dparen_replace[k] = v
            end
            for k, v in line:gmatch("([_%a][_%w]*)%s*=%s*('[_%a][_%w]*')") do
                dparen_replace[k] = v
            end
        else
            dparen_replace = {}
        end
        table.insert(diffs, {
            start = ss,
            finish = e,
            text = ""
        })
        s = e + 1
    end
    return diffs
end
