-- LyzmNpc.lua
-- Created by haungzz, July/23/2018
-- 灵音镇魔 Npc

local Npc = require("obj/Npc")
local LyzmNpc = class("LyzmNpc", Npc)
local Progress = require('ctrl/Progress')

local LIFE_OFFSET_Y = 30

function LyzmNpc:init()
    self.isSleep = false
    self.showLife = false
    self.lifeProgress = nil
    Npc.init(self)
end

function LyzmNpc:playAction()
    self.isSleep = false
    local function func()
        -- 物理攻击
       -- self:setAct(Const.FA_ACTION_PHYSICAL_ATTACK, function() 
        --    self:setAct(Const.FA_ACTION_ATTACK_FINISH, function()
                -- 魔法攻击
                self:setAct(Const.FA_ACTION_CAST_MAGIC, function()
                    if self.faAct ~= Const.FA_ACTION_CAST_MAGIC then
                        return
                    end

                    self:setAct(Const.FA_ACTION_CAST_MAGIC_END, function()
                        if self.faAct ~= Const.FA_ACTION_CAST_MAGIC_END then
                            return
                        end

                        func()
                    end)
                end)
        --    end)
       -- end)
    end

    func()

    self:deleteMagic(ResMgr.magic.sleep)
end

function LyzmNpc:playSleep()
    self.isSleep = true
    self:setAct(Const.SA_STAND)

    self:addMagicOnWaist(ResMgr.magic.sleep, false, ResMgr.magic.sleep)
end

function LyzmNpc:playDie()
    if self.isDie then return end

    self.isDie = true

    self:setActAndCB(Const.FA_DIE_NOW, function()
        if self.faAct == Const.FA_DIE_NOW then
            self:setActAndCB(Const.FA_DIED, function()
                if self.middleLayer then
                    self.middleLayer:setCascadeOpacityEnabled(true)
                    local action = cc.Sequence:create(
                        cc.Blink:create(0.5, 2),
                        cc.CallFunc:create(function()
                            self:fadeOut(0.25)
                        end)
                    )

                    self.middleLayer:runAction(action)
                end
            end)
        end
    end)

    self:deleteMagic(ResMgr.magic.sleep)
end

function LyzmNpc:update()
    self:updateLifeProgress()
end

function LyzmNpc:addMagicOnHead(icon, behind, magicKey, armatureType, extraPara, callback, layerFlag, offsetY)
    if self.charAction then
        offsetY = offsetY or 0
        local x, y = self.charAction:getHeadOffset()
        local magic = self:addMagic(x, y + offsetY, icon, behind, magicKey, armatureType, extraPara, callback, layerFlag)
        magic.getPosFunc = "getHeadOffset"
        return magic
    end
end

-- 显示血条及光效
function LyzmNpc:setShowLife(isCur, canShow)
    if self.showLife == isCur or self.showLife == (isCur and canShow) then
        return
    end

    self.showLife = (isCur and canShow)
    if self.showLife then
        if LingyzmMgr:isClickShakeType(self.shakeType) then
            self:addMagicOnFoot(ResMgr.magic.circle_purple, true, ResMgr.magic.circle_purple, nil, nil, nil, 3)
            self:addMagicOnHead(ResMgr.magic.head_tip_purple, true, ResMgr.magic.head_tip_purple, nil, nil, nil, nil, 50)
        else
            self:addMagicOnFoot(ResMgr.magic.circle_golden, true, ResMgr.magic.circle_golden, nil, nil, nil, 3)
            self:addMagicOnHead(ResMgr.magic.head_tip_golden, true, ResMgr.magic.head_tip_golden, nil, nil, nil, nil, 50)
        end
    else
        if LingyzmMgr:isClickShakeType(self.shakeType) then
            self:deleteMagic(ResMgr.magic.circle_purple)
            self:deleteMagic(ResMgr.magic.head_tip_purple)
        else
            self:deleteMagic(ResMgr.magic.circle_golden)
            self:deleteMagic(ResMgr.magic.head_tip_golden)
        end
    end

    if self.showLife then
        DlgMgr:sendMsg("LingyzmDlg", "changeShakeType")
    end
end

-- 更新血条
function LyzmNpc:updateLifeProgress()
    if not self.charAction then
        return
    end

    if not self.showLife then
        if self.lifeProgress then
            self.lifeProgress:setVisible(false)
        end

        return
    end

    if not self.lifeProgress then
        self.lifeProgress = Progress.new(ResMgr.ui.fight_progress_back, ResMgr.ui.fight_progress_life)
        self.lifeProgress:setLocalZOrder(Const.CHAR_PROGRESS_ZORDER)
        self:addToMiddleLayer(self.lifeProgress)

        local headX, headY = self.charAction:getHeadOffset()
        self.lifeProgress:setPosition(0, headY + LIFE_OFFSET_Y)
    end

    self.lifeProgress:setVisible(true)
    local max = self:queryInt('max_life')

    local percent = 0
    if max > 0 then
        percent = self:queryInt('life') * 100 / max
    end

    self.lifeProgress:setPercent(percent)
end

function LyzmNpc:isCanTouch()
    return false
end

return LyzmNpc
