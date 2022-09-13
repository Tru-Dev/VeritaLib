
-- From http://lua-users.org/wiki/SlightlyLessSimpleLuaPreprocessor (Enhanced Version)
-- Modified to accept the config table by default, and to optionally remove comments or minify.

--- Export preprocess and preprocessAll
local M = {}

-- Count number of chars c in string s.
local function countchar(s, c)
    local count = 0
    local i = 1
    while true do
        i = string.find(s, c, i)
        if i then count = count + 1;
        i = i + 1
        else break end
    end
    return count
end

-- In error message string, translate line numbers from
-- processed file to source file.
-- linenums is translation array (processed line number ->
-- source line number) or source line number.
local function fix_linenums(message, linenums)
    message = message:gsub("(%b[]:)(%d+)", function(a, n)
        n = tonumber(n)
        local source_linenum =
        type(linenums) == "table" and (linenums[n] or '?') or
            type(linenums) == "number" and linenums + n - 1 or
            '?'
        return a .. source_linenum
    end)
    return message
end

-- Expands $(...) syntax.
local function parse_dollar_paren(pieces, chunk, name, linenum)
    local is = 1
    for ibegin, iend in chunk:gmatch("()$%b()()") do
        local text = chunk:sub(is, ibegin - 1)
        local executed = chunk:sub(ibegin + 2, iend - 2) -- remove parens

        local name2 = name .. ":" .. executed
        linenum = linenum + countchar(text, '\n')
        local may_have_comment = executed:find("%-%-")
        local nl = may_have_comment and "\n" or ""

        pieces[#pieces + 1] = ("_put(%q)"):format(text)
        if load("return " .. executed, name2) then -- is expression list
            pieces[#pieces + 1] = "_put(" .. executed .. nl .. ")"
        else -- assume chunk
            local status, message = load(executed, name2)
            if not status then -- unrecognized
                if message then
                    message = fix_linenums(message, linenum)
                end
                return status, message
            end
            pieces[#pieces + 1] = " " .. executed .. nl .. " "
            linenum = linenum + countchar(executed, '\n')
        end
        is = iend
    end
    pieces[#pieces + 1] = ("_put(%q)"):format(chunk:sub(is))
    return true
end

-- Expands #... syntax.
local function parse_hash_lines(chunk, name, env)
    local pieces = {}

    local luas = {} -- for improved error reporting
    local linenums = {}
    local linenum = 1

    pieces[#pieces + 1] = "local _put, config = ... "

    local is = 1
    while true do
        local _, ie, lua = chunk:find("^#+([^\n]*\n?)", is)
        if not ie then
            local iss;
            iss, ie, lua = chunk:find("\n#+([^\n]*\n?)", is)
            local text = chunk:sub(is, iss)
            local status, message = parse_dollar_paren(pieces, text, name, linenum)
            if not status then return status, message end
            if not ie then break end
            linenum = linenum + countchar(text, '\n')
        end

        luas[#luas + 1] = lua
        linenums[#linenums + 1] = linenum
        linenum = linenum + 1

        pieces[#pieces + 1] = ' ' .. lua .. ' '

        is = ie + 1
    end

    local code = table.concat(pieces, ' ')
    -- print(code)

    -- Attempt to compile.
    local f, message = load(code, name, 't', env)
    if not f then
        -- Attempt to compile only user-written Lua
        -- (for cleaner error message)
        local lua = table.concat(luas)
        local f2, message2 = load(lua, name, 't', env)
        if not f2 then
            message = fix_linenums(message2, linenums)
        else -- unexpected
            message = fix_linenums(message, nil)
        end
    end

    return f, message
end

-- Abstraction of string output stream.
local function string_writer()
    local t = {}
    local function write(...)
        local n = select('#', ...)
        if n > 0 then
            t[#t + 1] = tostring((...))
            write(select(2, ...))
        end
    end

    local function close()
        return table.concat(t)
    end

    return { write = write, close = close }
end

-- Abstraction of file output stream.
local function file_writer(fh, is_close)
    local function write(...)
        local n = select('#', ...)
        if n > 0 then
            fh:write(tostring((...)))
            write(select(2, ...))
        end
    end

    local function close()
        if is_close then fh:close() end
    end

    return { write = write, close = close }
end

-- Convert output specification to output stream.
-- A helper function for C<preprocess>.
local function make_output(output)
    if type(output) == 'string' then
        output = string_writer()
    elseif type(output) == 'table' then
        assert(#output == 1, 'table size must be 1')
        local filename = output[1]
        local fh, message = io.open(filename, 'w')
        if not fh then return false, message end
        output = file_writer(fh, true)
    elseif io.type(output) == 'file' then
        output = file_writer(output, false)
    else
        error('unrecognized', 2)
    end
    return output
end

-- Convert input specification to input stream.
-- A helper function for C<preprocess>.
local function make_input(input)
    if type(input) == 'string' then
        input = { text = input, name = 'source' }
    elseif type(input) == 'table' then
        assert(#input == 1, 'table size must be 1')
        local filename = input[1]
        local fh, message = io.open(filename)
        if not fh then return false, message end
        input = { text = fh:read '*a', name = filename }
        fh:close()
    elseif io.type(input) == 'file' then
        input = { text = input:read '*a', name = nil }
    else
        error('unrecognized', 2)
    end
    return input
end

function M.preprocess(t)
    if type(t) == 'string' then t = { input = t } end
    local input = t.input or io.stdin
    local output = t.output or
        (type(input) == 'string' and 'string') or io.stdout
    local lookup = t.lookup or _G
    local strict = t.strict;
    if strict == nil then strict = true end

    local err;
    input, err = make_input(input)
    if not input then error(err, 2) end

    local name = input.name or "<source>"

    local mt = {}
    if strict then
        function mt.__index(t, k)
            local v = lookup[k]
            if v == nil then
                error("Undefined global variable " .. tostring(k), 2)
            end
            return v
        end
    else
        mt.__index = lookup
    end

    local env = {}
    setmetatable(env, mt)

    local f, message = parse_hash_lines(input.text, name, env)
    if not f then return f, message end

    output = make_output(output)

    local status, message = pcall(f, output.write, config)

    local result = output.close()
    if not result then result = true end

    if not status then
        return false, message
    else
        return result
    end
end

local lfs
local function preparePaths(in_path, out_path, current_suffix)
    local out_cd = ""
    for dir in out_path:gmatch("[^/]+") do
        out_cd = out_cd .. dir .. "/"
        lfs.mkdir(out_cd)
    end

    current_suffix = current_suffix or ""

    local ret = ""
    for path_node in lfs.dir(in_path .. current_suffix) do
        if path_node ~= "." and path_node ~= ".." then
            local mode = lfs.attributes(path_node, "mode")
            if mode == "directory" then
                local cs = path_node:gsub(in_path, "", 1)
                lfs.mkdir(out_path .. cs)
                ret = ret .. preparePaths(in_path, out_path, cs)
            elseif mode == "file" then
                local o = path_node:gsub(in_path, out_path, 1)
                if o:sub(-5, -1) == ".luap" then
                    o = o:sub(1, -2)
                end
                ret = ret .. path_node .. ";" .. o .. "\n"
            end
        end
    end
    return ret
end

local function removeComments(chunk)
    return chunk
        :gsub("(%s*%-%-%[(=*)%[.*%]%2%])", "")
        :gsub("(%s*%-%-[^\n]*\n)", "\n"):gsub("\n\n+", "\n")
        :gsub("(%s*%-%-[^\n]*)$", "")
end

local function removeWhitespace(chunk)
    return chunk:gsub("%s+", " ")
end

function M.preprocessAll(in_path, out_path, config_path)
    if not config_path then
        config_path = "vlib_conf.lua"
    end
    config = dofile(config_path)
    lfs = require("lfs")
    local paths = preparePaths(in_path, out_path)
    local errors = ""
    if config.minify or config.no_comments then
        local transform_func = removeComments
        if config.minify then
            function transform_func(c)
                return removeWhitespace(removeComments(c))
            end
        end
        for i, o in paths:gmatch("([^;]*);([^\n]*)\n") do
            if i:sub(-5, -1) == ".luap" then
                local result, err = M.preprocess({ input = { i }, output = "string" })
                if result then
                    local out_file = io.open(o, "w+")
                    if out_file then
                        result = transform_func(result)
                        out_file:write(result)
                        out_file:close()
                    end
                else
                    errors = errors .. "\n" .. err
                end
            else
                local in_file = io.open(i, "r")
                local out_file = io.open(o, "w+")
                if in_file and out_file then
                    local result = transform_func(in_file:read("*a"))
                    out_file:write(result)
                    in_file:close()
                    out_file:close()
                end
            end
        end
    else
        for i, o in paths:gmatch("([^;]*);([^\n]*)\n") do
            if i:sub(-5, -1) == ".luap" then
                local result, err = M.preprocess({ input = { i }, output = { o } })
                if not result then
                    errors = errors .. "\n" .. err
                end
            else
                local in_file = io.open(i, "r")
                local out_file = io.open(o, "w+")
                if in_file and out_file then
                    local result = in_file:read("*a")
                    out_file:write(result)
                    in_file:close()
                    out_file:close()
                end
            end
        end
    end

    if #errors > 0 then
        print("Preprocessor errors occurred:\n" .. errors)
        local preprocessor_log = io.open("preprocessor.log", "w+")
        if preprocessor_log then
            preprocessor_log:write(errors)
            preprocessor_log:close()
        end
    end
end

return M
