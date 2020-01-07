-- DaysRewardDlg.lua
-- Created by songcw Feb/17/2016
-- 每天登入奖励界面

local DaysRewardDlg = Singleton("DaysRewardDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

local Days = {
    [1] = "第一天",
    [2] = "第二天",
    [3] = "第三天",
    [4] = "第四天",
    [5] = "第五天",
    [6] = "第六天",
    [7] = "第七天",
}

local SCROLLVIEW_CONTAINNER = 766

function DaysRewardDlg:init()
    self.rewardPanel = self:getControl("ItemPanel")
    self.rewardPanel:retain()
    self.rewardPanel:removeFromParent()
    self.rewardPanelContentSize = self.rewardPanel:getContentSize()

    self.isInitDone = false
    if self:getGiftData() then
        self.isInitDone = true
        self:initDataInfo()
    end

    -- 请求礼包，更新数据信息
    self:requestRewardData()

    GiftMgr:setLastTime()
end

function DaysRewardDlg:getCfgFileName()
    return ResMgr:getDlgCfg("SevenDaysRewardDlg")
end

function DaysRewardDlg:cleanup()
    self:releaseCloneCtrl("rewardPanel")
end

-- 获取礼包数据
function DaysRewardDlg:getGiftData()
    -- 子类继承
    assert(false)
end

-- 请求奖励数据
function DaysRewardDlg:requestRewardData()
    -- 子类继承
    assert(false)
end

-- 领取奖励
function DaysRewardDlg:takeReward(index)
    -- 子类继承
    assert(false)
end

function DaysRewardDlg:undateButtonState()
    local contPanel = self:getControl("GiftListScrollView"):getChildByTag(SCROLLVIEW_CONTAINNER)
    local rewards = self:getGiftData()
    for i = 1, #rewards do
        local panel = contPanel:getChildByTag(i)
        self:setButtonState(rewards[i], i, (rewards.loginDays >= i), panel)
    end
end

function DaysRewardDlg:initDataInfo()
    -- 设置panel信息
    local rewards = self:getGiftData()
    local container = ccui.Layout:create()
    local giftListCtrl = self:getControl("GiftListScrollView")
    giftListCtrl:removeAllChildren()
    giftListCtrl:addChild(container, 1, SCROLLVIEW_CONTAINNER)
    container:setPosition(4, 0)
    local count = #rewards
    for i = 1, count do
        local reward = rewards[i]
        local rewardPanel = nil
        rewardPanel = self:createOneRewardPanel(reward, i, (rewards.loginDays >= i))
        if i % 2 ~= 0 then
            self:setCtrlVisible("BackImage1", false, rewardPanel)
            self:setCtrlVisible("BackImage2", true, rewardPanel)
        else
            self:setCtrlVisible("BackImage2", false, rewardPanel)
            self:setCtrlVisible("BackImage1", true, rewardPanel)
        end

        rewardPanel:setPosition(0, (count - i) * self.rewardPanelContentSize.height + 1)
        container:addChild(rewardPanel, 1, i)
    end

    container:setContentSize(self.rewardPanelContentSize.width, self.rewardPanelContentSize.height * count)
    giftListCtrl:setInnerContainerSize(container:getContentSize())
end

function DaysRewardDlg:setButtonState(rewardInfo, days, isCanGet, rewardPanel)
-- 设置按钮状态
    local noReachBtn = self:getControl("NoReachButton", nil, rewardPanel)
    local getBtn = self:getControl("GetButton", nil, rewardPanel)
    local gotBtn = self:getControl("GotButton", nil, rewardPanel)

    noReachBtn:setVisible(false)
    getBtn:setVisible(false)
    gotBtn:setVisible(false)

    if not isCanGet then
        noReachBtn:setVisible(true)
        self:setCtrlEnabled("NoReachButton", false, rewardPanel)
    elseif 0 == rewardInfo.flag then
        getBtn:setVisible(true)
    elseif 1 == rewardInfo.flag then
        gotBtn:setVisible(true)
        self:setCtrlEnabled("GotButton", false, rewardPanel)
    end

    self:bindTouchEndEventListener(getBtn, function()
        if not DistMgr:checkCrossDist() then return end

        -- 领取奖励
        self:takeReward(rewardInfo.index)
    end)
end

function DaysRewardDlg:getDay(days)
    return Days[days]
end

-- 创建奖励条目
function DaysRewardDlg:createOneRewardPanel(rewardInfo, days, isCanGet)
    local rewardPanel = self.rewardPanel:clone()

    self:setLabelText("DaysLabel", self:getDay(days), rewardPanel)

    -- 设置物品图标
    local itemListPanel = self:getControl("ItemListPanel", Const.UIPanel, rewardPanel)
    itemListPanel:removeAllChildren(true)
    local rewardContainer  = RewardContainer.new(rewardInfo.desc, itemListPanel:getContentSize(), nil, nil, true, nil, true)
    rewardContainer:setAnchorPoint(0, 0.5)
    rewardContainer:setScale(0.8)
    rewardContainer:setPosition(10, itemListPanel:getContentSize().height / 2)
    itemListPanel:addChild(rewardContainer)


    self:setButtonState(rewardInfo, days, isCanGet, rewardPanel)
    return rewardPanel
end

return DaysRewardDlg