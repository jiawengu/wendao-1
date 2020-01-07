-- QTNpc.lua
-- Created by sujl, Jul/25/2017
-- 薛之谦和童童

local Char = require("obj/Char")
local QTNpc = class("QTNpc", Char)

local SHOW_DIR = 5
local ACTION_TIME = 60
local SHOW_TIME = 1.5

function QTNpc:getLoadType()
    return LOAD_TYPE.NPC
end

function QTNpc:getDir()
    return SHOW_DIR
end

function QTNpc:getShadow()
    return nil
end

function QTNpc:isCanTouch()
    return false
end

function QTNpc:onActionEnd()
    if self.faAct == Const.FA_SHOW_BEGIN then
        self:setAct(Const.FA_SHOW_END)
        self:setChat({msg = CHS[2200049], show_time = SHOW_TIME}, nil, true)
    elseif self.faAct == Const.FA_SHOW_END then
        local charXZQ, charTT
        charXZQ = CharMgr:getNpcByName(CHS[2200050])
        if charXZQ then
            charXZQ.charAction:setVisible(true)
            charXZQ:setCanTouch(true)
            charXZQ.charAction:pausePlay()
            charXZQ.charAction:continuePlay()
            --charXZQ.bottomLayer:setVisible(true)
        end

        charTT = CharMgr:getNpcByName(CHS[2200051])
        if charTT then
            charTT.charAction:setVisible(true)
            charTT:setCanTouch(true)
            charTT.charAction:pausePlay()
            charTT.charAction:continuePlay()
            --charTT.bottomLayer:setVisible(true)
        end
        Me:setCanTouch(true)

        self:setBasic("isHide", 1)
        self:setVisible(false)
        local curTime = gf:getServerTime()
        local delayTime = math.floor((curTime + ACTION_TIME) / ACTION_TIME) * ACTION_TIME - curTime
        performWithDelay(self.middleLayer, function()
            --Log:D("--------------->2:" .. tostring(gf:getServerTime()) .. "/" .. tostring(delayTime) .. "/" .. tostring(curTime))
            self:onAction()
        end, delayTime)
    end
end

function QTNpc:onAction()
    self:setVisible(true)
    self:setBasic("isHide", 0)
    self:setAct(Const.FA_SHOW_BEGIN)

    local charXZQ, charTT
    charXZQ = CharMgr:getNpcByName(CHS[2200050])
    if charXZQ then
        charXZQ.charAction:setVisible(false)
        charXZQ:setCanTouch(false)
        --charXZQ.bottomLayer:setVisible(false)
    end

    charTT = CharMgr:getNpcByName(CHS[2200051])
    if charTT then
        charTT.charAction:setVisible(false)
        charTT:setCanTouch(false)
        --charTT.bottomLayer:setVisible(false)
    end
    Me:setCanTouch(false)
end

-- 点击对象时添加选中特效
function QTNpc:addFocusMagic()
end

-- 当角色失去焦点时移除光效
function QTNpc:removeFocusMagic()
end

return QTNpc
