-- DwwNpc.lua
-- Created by lixh Jun/10/2018
-- 中秋大胃王npc

local Npc = require("obj/Npc")
local DwwGuest = class("DwwGuest", Npc)

function DwwGuest:init()
    Npc.init(self)

    self.needFrozon = true
end

function DwwGuest:getType()
    return OBJECT_NPC_TYPE.DWW_NPC
end

function DwwGuest:updateAfterLoadAction()    
    Npc.updateAfterLoadAction(self, true)

    if self.needFrozon then
        -- 大胃王npc在加载完后需要停止动作
        self.charAction:pausePlay()
        self.needFrozon = false
    end
end

return DwwGuest
