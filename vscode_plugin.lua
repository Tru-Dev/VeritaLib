local config = dofile("./vlib_conf.lua")

function OnSetText(uri, text)
    if uri:sub(-5, -1) ~= '.luap' then
        return nil
    end
    local diffs = {}
    local s = 1
    while true do
        local ss, e, lua = text:find("^#+([^\n]*\n?)", s)
        if not e then
            ss, e, lua = text:find("\n#+([^\n]*\n?)", s)
            local is = 1
            local text2 = text:sub(s, ss)
            for ibegin, iend in text2:gmatch("()$%b()()") do
                local executed = text2:sub(ibegin + 2, iend - 2)
                if executed:sub(1, 6) == "config" then
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
                        finish = s + iend - 1,
                        text = ""
                    })
                end
            end
            if not e then break end
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
