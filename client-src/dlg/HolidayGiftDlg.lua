-- HolidayGiftDlg.lua
-- Created by songce Sep/12/2016
-- 节日活动界面

local HolidayGiftDlg = Singleton("HolidayGiftDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

local open_icon = {
    [1] = ResMgr.ui.reward_box1,
    [2] = ResMgr.ui.reward_box2,
    [3] = ResMgr.ui.reward_box2,
    [4] = ResMgr.ui.reward_box4,
}

function HolidayGiftDlg:init()
    GiftMgr.lastIndex = "WelfareButton0"
    GiftMgr:setLastTime()

    for i = 1, 4 do
        local box = self:getControl("ChestPanel" .. i)
        box:setTag(i)
        self:bindTouchEndEventListener(box, self.onGiftBox)
        box:setVisible(false)
    end

    self:setLabelText("BoughNumbertLabel", "")
    self:setProgressBar("ConsumeProgressBar", 0, 0)
    self.rewardPanel = self:getControl("ItemPanel")
    self.rewardPanel:retain()
    self.rewardPanel:removeFromParent()
    self.rewardPanelSize = self.rewardPanel:getContentSize()

    GiftMgr:questHolidayData()
    self:MSG_MY_FESTIVAL_GIFT_INFO()
    self:hookMsg("MSG_MY_FESTIVAL_GIFT_INFO")
end

-- 清理资源
function HolidayGiftDlg:cleanup()
    self:releaseCloneCtrl("rewardPanel")
end

function HolidayGiftDlg:onGiftBox(sender, eventType)
    local data = GiftMgr:getHoidayGiftData()
    if not data then
        self:onCloseButton()
        return
    end

    local tag = sender:getTag()
    local tip = data.boxs[tag].boxIntro
    gf:showTipInfo(tip, sender)

    -- sender.isCanGet == 1达到领取条件
    if sender.isCanGet == 1 then
        GiftMgr:getRewardBox(tag)
    end
end

function HolidayGiftDlg:onBuyButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    local giftName = sender.name
    if sender.isNeedVip == 1 and Me:queryBasicInt("vip_type") <= 0 then
        gf:ShowSmallTips(CHS[4300113])
        return
    end

    if sender.costType <= 3 then
        if self:checkSafeLockRelease("onBuyButton", sender) then
            return
        end
    end

    local str = ""
    if sender.costType == 1 then
        if not gf:checkEnough("cash", sender.curPrice) then return end
    elseif sender.costType == 2 then -- 银元宝
        if not gf:checkEnough("silver", sender.curPrice) then return end
        if Me:queryInt("silver_coin") < sender.curPrice then
            local realUseSilver = Me:queryInt("silver_coin")
            if realUseSilver < 0 then realUseSilver = 0 end
            str = string.format(CHS[4300112] , sender.curPrice, sender.curPrice - realUseSilver, giftName)
        else
            str = string.format(CHS[4300111], sender.curPrice, giftName)
        end
    elseif sender.costType == 3 then -- 金元宝
        if not gf:checkEnough("gold", sender.curPrice) then return end
        str = string.format(CHS[4300110], sender.curPrice, giftName)
    end

    if str ~= "" then
        gf:confirm(str, function ()
            GiftMgr:buyHolidayGift(giftName)
        end)
    else
        GiftMgr:buyHolidayGift(giftName)
    end
end

function HolidayGiftDlg:setIntroduce(data)
    local intro = data.introduce
    local dateTime = data.time

    local panel = self:getControl("IntroducePanel")
    self:setLabelText("Label1", intro, panel)
    self:setLabelText("Label2", gf:getServerDate(CHS[4300109], dateTime), panel)
end

function HolidayGiftDlg:setCanGetGift(data)
    local max = 0
    local cur = 0
    for i = 1, data.giftCount do
        max = max + data.gifts[i].buyTimeMax
        cur = cur + data.gifts[i].buyTimeCur
    end

    self:setProgressBar("ConsumeProgressBar", cur, max)
    if max == 0 then return end
    local bar = self:getControl("ConsumeProgressBar")
    for i = 1, 4 do
        if data.boxs[i] then
            local panel = self:getControl("ChestPanel" .. i)
            panel:setVisible(true)
            panel:setAnchorPoint(cc.p(0.5, 0))
            local posx = bar:getContentSize().width * (data.boxs[i].openCount / max)
            panel:setPositionX(posx)
            self:setLabelText("NumberLabel", data.boxs[i].openCount, panel)
    
            local image = self:getControl("ChestImage", nil, panel)
            if cur >= data.boxs[i].openCount and data.boxs[i].isGeted == 0 then
                local roA = cc.RotateTo:create(0.1, 6)
                local spRoA = cc.EaseSineOut:create(roA)
                local roB = cc.RotateTo:create(0.1, -6)
                local spRoB = cc.EaseSineOut:create(roB)
                local orderAct = cc.Sequence:create(spRoA, spRoB)
                image:runAction(cc.RepeatForever:create(orderAct))
    
                panel.isCanGet = 1
            else
                panel.isCanGet = 0
                image:stopAllActions()
            end
    
            if data.boxs[i].isGeted == 1 then
                image:loadTexture(open_icon[i])
            end
        else
            self:setCtrlVisible("ChestPanel" .. i, false)
        end
    end

    -- 已购礼包
    self:setLabelText("BoughNumbertLabel", cur)
end

function HolidayGiftDlg:initDataInfo(data)
    local container = ccui.Layout:create()

    local giftListCtrl = self:getControl("GiftListScrollView")
    giftListCtrl:removeAllChildren()
    giftListCtrl:addChild(container, 1, 766)

    container:setPosition(-1, -2)
    local count = data.giftCount
    for i = 1, count do
        local rewardInfo = data.gifts[i]
        local rewardPanel = self:createOneRewardPanel(rewardInfo, data)
        rewardPanel:setPosition(0, (count - i) * self.rewardPanelSize.height + 1)
        container:addChild(rewardPanel, 1, i)
    end

    container:setContentSize(self.rewardPanelSize.width, self.rewardPanelSize.height * count)
    giftListCtrl:setInnerContainerSize(container:getContentSize())
end

-- 创建奖励条目
function HolidayGiftDlg:createOneRewardPanel(rewardInfo, data)
    local rewardPanel = self.rewardPanel:clone()

    -- 礼包名称
    self:setLabelText("NameLabel", rewardInfo.name, rewardPanel)

    -- 限购次数
    self:setLabelText("LimitLabel", string.format(CHS[4300108], rewardInfo.buyTimeCur, rewardInfo.buyTimeMax), rewardPanel)

    -- 原价
    local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(rewardInfo.orgPrice))
    self:setNumImgForPanel("OrgValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 15, rewardPanel)

    -- 现价
    local cashText1, fontColor1 = gf:getArtFontMoneyDesc(tonumber(rewardInfo.curPrice))
    self:setNumImgForPanel("CurValuePanel", fontColor1, cashText1, false, LOCATE_POSITION.MID, 17, rewardPanel)

    -- 消耗类型
    local originalPricePanel = self:getControl("OriginalPricePanel", nil, rewardPanel)
    local currentPricePanel = self:getControl("CurrentPricePanel", nil, rewardPanel)
    currentPricePanel:setVisible(false)
    originalPricePanel:setVisible(true)
    local freePanel = self:getControl("FreePanel", nil, rewardPanel)

    if rewardInfo.orgType == 1 then
        self:setImagePlist("MoneyIconImage", ResMgr.ui.small_cash, originalPricePanel)
    elseif rewardInfo.orgType == 2 then
        self:setImagePlist("MoneyIconImage", ResMgr.ui.small_reward_silver, originalPricePanel)
    elseif rewardInfo.orgType == 3 then
        self:setImagePlist("MoneyIconImage", ResMgr.ui.small_reward_glod, originalPricePanel)
    end

    if rewardInfo.costType == 1 then -- 金钱
        currentPricePanel:setVisible(true)
        self:setImagePlist("MoneyIconImage", ResMgr.ui.small_cash, currentPricePanel)
    elseif rewardInfo.costType == 2 then -- 银元宝
        currentPricePanel:setVisible(true)
        self:setImagePlist("MoneyIconImage", ResMgr.ui.small_reward_silver, currentPricePanel)
    elseif rewardInfo.costType == 3 then -- 金元宝
        currentPricePanel:setVisible(true)
        self:setImagePlist("MoneyIconImage", ResMgr.ui.small_reward_glod, currentPricePanel)
    elseif rewardInfo.costType == 4 then -- 活跃
        freePanel:setVisible(true)
        if data.active >= rewardInfo.curPrice then
            self:setLabelText("Label_1", CHS[4000115], freePanel)
            self:setLabelText("Label_2", CHS[4000115], freePanel)
        else
            self:setLabelText("Label_1", string.format(CHS[4300107], data.active, rewardInfo.curPrice), freePanel)
            self:setLabelText("Label_2", string.format(CHS[4300107], data.active, rewardInfo.curPrice), freePanel)
        end
    elseif rewardInfo.costType == 5 then -- 登入
        freePanel:setVisible(true)
        if data.loginTime >= rewardInfo.curPrice then
            self:setLabelText("Label_1", CHS[4000115], freePanel)
            self:setLabelText("Label_2", CHS[4000115], freePanel)
        else
            self:setLabelText("Label_1", string.format(CHS[4300106], data.loginTime, rewardInfo.curPrice), freePanel)
            self:setLabelText("Label_2", string.format(CHS[4300106], data.loginTime, rewardInfo.curPrice), freePanel)
        end
    end

    if rewardInfo.buyTimeCur >= rewardInfo.buyTimeMax then
        self:setCtrlVisible("BuyButton", false, rewardPanel)
        originalPricePanel:setVisible(false)
        self:setCtrlVisible("SellOutImage", true, rewardPanel)
    end

    local btn = self:getControl("BuyButton", nil, rewardPanel)
    btn.name = rewardInfo.name
    btn.costType = rewardInfo.costType
    btn.curPrice = rewardInfo.curPrice
    btn.isNeedVip = rewardInfo.isNeedVip
    self:bindTouchEndEventListener(btn, self.onBuyButton)

    -- 设置物品图标
    local itemListPanel = self:getControl("ItemListPanel", Const.UIPanel, rewardPanel)
    itemListPanel:removeAllChildren(true)
    local rewardContainer  = RewardContainer.new(rewardInfo.reward, itemListPanel:getContentSize(), nil, nil, true, 10, true)
    rewardContainer:setAnchorPoint(0, 0.5)
    rewardContainer:setScale(0.8)
    rewardContainer:setPosition(10, itemListPanel:getContentSize().height / 2)
    itemListPanel:addChild(rewardContainer)

    return rewardPanel
end

function HolidayGiftDlg:MSG_MY_FESTIVAL_GIFT_INFO()
    local data = GiftMgr:getHoidayGiftData()
    
    if not data then
        return
    end
    
    self:setIntroduce(data)

    self:initDataInfo(data)

    self:setCanGetGift(data)
end


return HolidayGiftDlg
