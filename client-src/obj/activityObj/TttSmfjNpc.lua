-- TttSmfjNpc.lua
-- Created by songcw, July/23/2018
-- 通天塔神秘房间变戏法怪物NPC

local Char = require("obj/Char")
local TttSmfjNpc = class("TttSmfjNpc", Char)

function TttSmfjNpc:init()
    Char.init(self)
end

function TttSmfjNpc:update()
    Char.update(self)
end

-- 点击角色
function TttSmfjNpc:onClickChar()
    gf:ShowSmallTips(self:queryBasicInt("boxId"))
end

function TttSmfjNpc:setDestPos(pos)
    self.destPos = pos
end

function TttSmfjNpc:setAct(act, callBack, notCheck)
    Char.setAct(self, act, callBack)

    if act == Const.SA_STAND and not notCheck then
        if DlgMgr:getDlgByName("NoneDlg") then
            -- 变戏法，兔子移动到目的箱子时
            local x, y = gf:convertToClientSpace(self.destPos.x, self.destPos.y)
            if math.abs(self.curX - x) <= 1 and math.abs(self.curY - y) <= 1 then
                TttSmfjMgr:deleteRabbit(self:queryBasicInt("id"))
                TttSmfjMgr:addRabbitByBox(self:queryBasicInt("boxId"))
            end
        elseif DlgMgr:getDlgByName("SpeclalRoomStrollDlg") then
            if not self.destPos then return end
            if self:queryBasicInt("id") == 10 then return end

            local x, y = gf:convertToClientSpace(self.destPos.x, self.destPos.y)
            if math.abs(self.curX - x) <= 1 and math.abs(self.curY - y) <= 1 then
                -- 幽灵漫步         
                DlgMgr:sendMsg("SpeclalRoomStrollDlg", "showwrongWay", self)
                self.destPos = nil
            end
        end
    end
end


function TttSmfjNpc:isCanTouch()
    return true
end

return TttSmfjNpc













