-- PartyRedBagRewardDlg.lua
-- Created by zhengjh Aug/28/2016
-- 抢红包界面

local PartyRedBagRewardDlg = Singleton("PartyRedBagRewardDlg", Dialog)

function PartyRedBagRewardDlg:init()
    self:setCtrlVisible("PartyRedBagReadyPanel", true)
    self:setCtrlVisible("PartyRedBagEmptyPanel", false)
    self:setCtrlVisible("PartyRedBagRewardPanel", false)
end

function PartyRedBagRewardDlg:setData(data)
    self:playAction(data)
end

function PartyRedBagRewardDlg:playAction(data)
    local function  playResult()
        self:playResult(data)
    end
    
    local fuc = cc.CallFunc:create(playResult)
    
	local readyImage = self:getControl("PartyRedBagReadyImage")
    readyImage:setScale(0.5)
	local action = cc.ScaleBy:create(0.3, 2)
    readyImage:runAction(cc.Sequence:create(action,  cc.DelayTime:create(0.4),fuc))
end

function PartyRedBagRewardDlg:playResult(data)
    if data.type == 2 then -- 没有抢到
        self:setUnSucceedResult()
    elseif data.type == 3 then -- 抢到了
        self:setSucceedResult(data)
    end
end

function PartyRedBagRewardDlg:setSucceedResult(data)
    self:setCtrlVisible("PartyRedBagReadyPanel", false)
    self:setCtrlVisible("PartyRedBagRewardPanel", true)
    
    local lightEffect = self:getControl("BigLightEffectImage")
    local rotate = cc.RotateBy:create(2, 360)
    local action = cc.RepeatForever:create(rotate)
    lightEffect:runAction(action)
    
    self:setLabelText("MoneyLabel", data.coin)
end

function PartyRedBagRewardDlg:setUnSucceedResult()
    self:setCtrlVisible("PartyRedBagReadyPanel", false)
    self:setCtrlVisible("PartyRedBagEmptyPanel", true)
end

return PartyRedBagRewardDlg
