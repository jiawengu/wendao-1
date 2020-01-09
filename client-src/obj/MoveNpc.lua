-- GatherNpc.lua
-- Created by zhengjh Jun27/2016
-- 移动npc(不能点击)

local Npc = require("obj/Npc")
local MoveNpc = class("MoveNpc", Npc)
local Object = require("obj/Object")

function MoveNpc:isCanTouch()
    return false
end

return MoveNpc
