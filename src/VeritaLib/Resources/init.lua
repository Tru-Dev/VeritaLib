

local Resources = {
    TexturePager = require(".TexturePager")
}

-- function ()
    
-- end

function Resources.LoadTexture(name, path, nopage, mipmap)
    lstg.LoadTexture(name, path, mipmap)
    if nopage then
        return
    end
    
end

return Resources
