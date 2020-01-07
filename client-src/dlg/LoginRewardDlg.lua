-- LoginRewardDlg.lua

local LoginRewardDlg = Singleton("LoginRewardDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

local CONTAINNER_TAG = 99

function LoginRewardDlg:init()
    self:bindListener("GetButton", self.onGetButton)

    self.rewardPanel = self:retainCtrl("ItemPanel")
    self.rewardPanelContentSize = self.rewardPanel:getContentSize()


    self:initDataInfo(self:getGiftData())
    self:undateButtonState(self:getGiftFlagData())

    self:requestGiftData()
end

function LoginRewardDlg:getCfgFileName()
    return ResMgr:getDlgCfg("ActiveLoginRewardDlg")
end

-- 获取奖励数据
function LoginRewardDlg:getGiftData()
    assert(false)
end

-- 获取奖励数据状态
function LoginRewardDlg:getGiftFlagData()
    assert(false)
end

-- 请求礼包数据
function LoginRewardDlg:requestGiftData()
    assert(false)
end

-- 领取奖励
function LoginRewardDlg:takeReward(index)
    assert(false)
end

function LoginRewardDlg:onGetButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    self:takeReward(sender.day)
end

function LoginRewardDlg:undateButtonState(data)
    if not data then
        return
    end

    local contPanel = self:getControl("GiftListScrollView"):getChildByTag(CONTAINNER_TAG)
    for i = 1, #data do
        local panel = contPanel:getChildByTag(i)
        self:setButtonState(data[i], i, (data.loginDays >= i), panel)
    end
end

function LoginRewardDlg:initDataInfo(data)
    if not data then
        return
    end

    -- 设置panel信息
    local rewards = data
    local container = ccui.Layout:create()
    local giftListCtrl = self:getControl("GiftListScrollView")
    giftListCtrl:removeAllChildren()
    giftListCtrl:addChild(container, 1, CONTAINNER_TAG)
    container:setPosition(4, 0)
    local count = #rewards
    for i = 1, count do
        local reward = rewards[i]
        local rewardPanel = nil
        rewardPanel = self:createOneRewardPanel(reward, i)
        rewardPanel:setTag(rewards[i].day)
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

    -- 活动时间
    if rewards.start_time or rewards.end_time then
        local startTimeStr = gf:getServerDate(CHS[5420147], tonumber(rewards.start_time))
        local endTimeStr = gf:getServerDate(CHS[5420147], tonumber(rewards.end_time))
        self:setLabelText("TitleLabel", CHS[5420137] .. startTimeStr .. " - " .. endTimeStr, "TimePanel")
        self:setCtrlVisible("TitleLabel", true, "TimePanel")
    else
        self:setCtrlVisible("TitleLabel", false, "TimePanel")
    end
end

function LoginRewardDlg:setButtonState(rewardInfo, days, isCanGet, rewardPanel)
    -- 设置按钮状态
    local noReachImg = self:getControl("NoReachImage", nil, rewardPanel)
    local getBtn = self:getControl("GetButton", nil, rewardPanel)
    local gotImg = self:getControl("GotImage", nil, rewardPanel)

    noReachImg:setVisible(false)
    getBtn:setVisible(false)
    gotImg:setVisible(false)

    if 1 == rewardInfo.flag then
        gotImg:setVisible(true)
    elseif not isCanGet then
        noReachImg:setVisible(true)
    elseif 0 == rewardInfo.flag then
        getBtn:setVisible(true)
    end

    getBtn.day = days
end

-- 创建奖励条目
function LoginRewardDlg:createOneRewardPanel(rewardInfo, days)
    local rewardPanel = self.rewardPanel:clone()

    self:setLabelText("DaysLabel", string.format(CHS[5420250], gf:changeNumber(days)), rewardPanel)

    -- 设置物品图标
    local itemListPanel = self:getControl("ItemListPanel", Const.UIPanel, rewardPanel)
    itemListPanel:removeAllChildren(true)
    local rewardContainer = RewardContainer.new(rewardInfo.desc, itemListPanel:getContentSize(), nil, nil, true, nil, true)
    rewardContainer:setAnchorPoint(0, 0.5)
    rewardContainer:setScale(0.8)
    rewardContainer:setPosition(10, itemListPanel:getContentSize().height / 2)
    itemListPanel:addChild(rewardContainer)

    return rewardPanel
end

function LoginRewardDlg:cleanup()
end

return LoginRewardDlg