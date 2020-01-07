-- XhqNpc.lua
-- Created by haungzz, Apr/11/2018
-- 寻寒气 NPC

local Npc = require("obj/Npc")
local XhqNpc = class("XhqNpc", Npc)

function XhqNpc:getLoadType()
    return LOAD_TYPE.NPC
end

function XhqNpc:getType()
    return "Npc"
end

function XhqNpc:onActionEnd()
    if self.faAct == Const.FA_YONGBAO_ONE or self.faAct == Const.FA_QINQIN_ONE then
        self:endCartoon()
    end
end

function XhqNpc:setAct(act,callBack)
    local name = self:queryBasic("name")
    if name == CHS[5450142] then
        -- 寻寒气的老手（站立冰冻）
        self:setBasic("isFixDir", 1)
        
        Npc.setAct(self, Const.FA_STAND)
        
        -- 冰冻
        CharMgr:MSG_PLAY_LIGHT_EFFECT({effectIcon = ResMgr.magic.frozen, charId = self:getId()})
    else
        -- 寻寒气的新手（循环5s 站立，1 次法攻）
        self:playAction(Const.SA_STAND)
    end
end

function XhqNpc:playAction(act)
    if self.delayAction then
        self.middleLayer:stopAction(self.delayAction)
    end
    
    if act == Const.SA_STAND or not self.charAction then
        Npc.setAct(self, Const.FA_STAND)
        
        self.delayAction = performWithDelay(self.middleLayer, function() 
            self:playAction(Const.SA_CAST)
            self.delayAction = nil
        end, 5)
    elseif act == Const.SA_CAST then
        self.charAction:playActionOnce(function() 
            CharMgr:MSG_PLAY_LIGHT_EFFECT({effectIcon = ResMgr.magic.water_skill_B3, charId = self:getId()})
            self:playAction(Const.SA_STAND)
        end, act)
    end
end

return XhqNpc
