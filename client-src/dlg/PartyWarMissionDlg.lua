-- PartyWarMissionDlg.lua
-- Created by liuhb Apr/7/2015
-- 帮战小窗口

local PartyWarMissionDlg = Singleton("PartyWarMissionDlg", Dialog)

function PartyWarMissionDlg:init()
    self:bindListener("PartyWarButton", self.onPartyWarButton)
    
    -- 初始化界面UI
    self:initViewControl()
end

function PartyWarMissionDlg:initViewControl()
    -- 绑定监听更新数据
    self:bindListener("ActiveCompareProgressBar", self.onRequestUpdateData)    -- 进度条
    self:bindListener("FightImage", self.onRequestUpdateData)    -- 中间图标
end

-- 设置数据
function PartyWarMissionDlg:updateInfo(data)
    if nil == data then return end
    
    -- 设置自身数据
    self:setLabelText("StaminaValueLabel", string.format(CHS[5000108], data.myAction))
    self:setLabelText("ActiveValueLabel", string.format(CHS[5000108], data.myActive))
    
    -- 设置帮战敌我双方总体进度条
    local acCtrl = self:getControl("ActiveCompareProgressBar")
    if data.ourActive ~= data.otherActive then
        local percent = data.ourActive / (data.ourActive + data.otherActive)
        acCtrl:setPercent(percent * 100)
    else
        acCtrl:setPercent(50)
    end
end

-- 获取更新数据
function PartyWarMissionDlg:onRequestUpdateData(sender, eventType)
    PartyWarMgr:requesetPartyWarActiveInfo()
end

function PartyWarMissionDlg:onPartyWarButton(sender, eventType)
end

return PartyWarMissionDlg
