
--- Manages basic internally-implemented images.  
--- These images are:
--- - white - 16x16 white square
--- - render_clear - same as "white", used for clearing portions of the screen
--- - black - 16x16 black square
--- - void - 16x16 transparent square
---@class Images
local Images = {}

function Images.Init()
    lstg.CreateRenderTarget("internal:white", 16, 16)
    lstg.CreateRenderTarget("internal:black", 16, 16)
    lstg.CreateRenderTarget("internal:void", 16, 16)
    lstg.LoadImage("white", "internal:white", 0, 0, 16, 16)
    lstg.LoadImage("render_clear", "internal:white", 0, 0, 16, 16)
    lstg.LoadImage("black", "internal:black", 0, 0, 16, 16)
    lstg.LoadImage("void", "internal:void", 0, 0, 16, 16)
end

function Images.Update()
    lstg.PushRenderTarget("internal:white")
    lstg.RenderClear(lstg.Color(0xFFFFFFFF))
    lstg.PopRenderTarget()
    lstg.PushRenderTarget("internal:black")
    lstg.RenderClear(lstg.Color(0xFF000000))
    lstg.PopRenderTarget()
    lstg.PushRenderTarget("internal:void")
    lstg.RenderClear(lstg.Color(0x00000000))
    lstg.PopRenderTarget()
end

return Images
