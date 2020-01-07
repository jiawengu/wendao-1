-- TMFollowNpc.lua
-- Created by haungzz, Dec/21/2017
-- 只能与玩家自己交流的跟随 NPC
-- T talk，M me

local FollowNpc = require("obj/FollowNpc")
local Npc = require("obj/Npc")
local TMFollowNpc = class("TMFollowNpc", FollowNpc)

function TMFollowNpc:setOwner(player)
    self.owner = player
end

function TMFollowNpc:isCanTouch()
    if not self.owner or self.owner:queryBasic("gid") ~= Me:queryBasic("gid") then
        return false
    end
    
    return FollowNpc.isCanTouch(self)
end

-- 绑定事件
function TMFollowNpc:onClickChar()
    Npc.onClickChar(self)
end

return TMFollowNpc
