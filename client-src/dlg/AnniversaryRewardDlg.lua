-- AnniversaryRewardDlg.lua
-- Created by huangzz Mar/14/2017
-- 【周年庆】登录礼包界面

local AnniversaryRewardDlg = Singleton("AnniversaryRewardDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

function AnniversaryRewardDlg:init()
    self:bindListener("GetButton", self.onGetButton)

    self.itemPanel = self:getControl("ItemPanel_1")
    self.itemPanel:retain()
    self.itemPanel:removeFromParent()

    AnniversaryMgr:znqOpenLoginGift()

    self:setImage("PetImage", ResMgr:getBigPortrait(6324), "PortraitPanel")
    --[[
    local dbMagic = DragonBonesMgr:createCharDragonBones(ResMgr.DragonBones.anniversary_lingmao_type3, string.format("%05d", ResMgr.DragonBones.anniversary_lingmao_type3))

    if dbMagic then
        local panel = self:getControl("PositionPanel")
        local magic = tolua.cast(dbMagic, "cc.Node")
        magic:setName("charPortrait")
        panel:addChild(magic)
        magic:setRotationSkewY(180)
        DragonBonesMgr:toPlay(dbMagic, "stand", 0)
    end
--]]


    self.znqLoginGift = AnniversaryMgr.znqLoginGift or {}
    if self.znqLoginGift.count and self.znqLoginGift.count > 0 then
        self:initScrollView(self.znqLoginGift)
        self:showEndTime(self.znqLoginGift.end_time)
    end

    -- self:hookMsg("MSG_ZNQ_LOGIN_GIFT")
    self:hookMsg("MSG_ZNQ_LOGIN_GIFT_2019")
end

function AnniversaryRewardDlg:showEndTime(endTime)
    if endTime then
        local endTimeStr = gf:getServerDate(CHS[4300158], tonumber(endTime))
        self:setLabelText("TimeLabel_2", endTimeStr)
    else
        self:setLabelText("TimeLabel_2", "")
    end
end

function AnniversaryRewardDlg:initScrollView(data)
    self.scrollView = self:getControl("GiftListScrollView")
    self.scrollView:removeAllChildren()
    self.scrollView:setBounceEnabled(true)
    local contentLayer = ccui.Layout:create()
    local oneWidth = self.itemPanel:getContentSize().width
    local scrollToTag = -1
    local cou = #data
    local rowSpace = 3
    for i = 1, cou do
        local cell = self.itemPanel:clone()
        cell:setAnchorPoint(0, 0)
        local x = (oneWidth + rowSpace) * (i - 1)
        cell:setPosition(x, 0)
        cell:setTag(i)
        self:setRewardInfo(cell, data[i])
        contentLayer:addChild(cell)

        if scrollToTag == -1 and data[i].flag ~= 2 then
            -- 获取第一个未领取的礼包位置
            scrollToTag = i - 1
        end
    end

    contentLayer:setContentSize((oneWidth + rowSpace) * cou - rowSpace, self.scrollView:getContentSize().height)
    self.scrollView:setInnerContainerSize(contentLayer:getContentSize())
    self.scrollView:addChild(contentLayer, 1, cou * 10)

    if scrollToTag < 0 then
        scrollToTag = 0
    end

    local scrollWidth = scrollToTag * (oneWidth + rowSpace)
    local canScrollWidth = contentLayer:getContentSize().width - self.scrollView:getContentSize().width
    if scrollWidth > canScrollWidth then
        scrollWidth = canScrollWidth
    end

    -- 滑到第一个未领取的礼包位置
    self.scrollView:getInnerContainer():setPositionX(-scrollWidth)
end

-- 显示物品悬浮框
function AnniversaryRewardDlg:onShowItemInfo(sender, eventType)
    RewardContainer:imagePanelTouch(sender, eventType)
end

-- 设置每个礼包奖品的信息
function AnniversaryRewardDlg:setRewardInfo(cell, data)
    local classList = TaskMgr:getRewardList(data.desc)

    if not next(classList) or not next(classList[1]) then
        return
    end

    local panel
    if #classList[1] == 3 then
        -- 3 个物品
        panel = self:getControl("ItemListPanel", nil, cell)
        self:setCtrlVisible("ItemListPanel", true, cell)
        self:setCtrlVisible("ItemListPanel_2", false, cell)
    else
        -- 4 个物品
        panel = self:getControl("ItemListPanel_2", nil, cell)
        self:setCtrlVisible("ItemListPanel", false, cell)
        self:setCtrlVisible("ItemListPanel_2", true, cell)
    end

    for i = 1, #classList[1] do
        local reward = classList[1][i]
        local itemPanel = self:getControl("ItemImagePanel" .. i, nil, panel)
        local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
        local item = TaskMgr:spliteItemInfo(itemInfoList, reward)

        -- 奖品图标
        local imgPath, textureResType = RewardContainer:getRewardPath(reward)
        if textureResType == ccui.TextureResType.plistType then
            self:setImagePlist("ItemImage", imgPath, itemPanel)
        else
            self:setImage("ItemImage", imgPath, itemPanel)
        end


        local imgCtrl = self:getControl("ItemImage", nil, itemPanel)
        if item["limted"] then
            -- 限制交易
            InventoryMgr:addLogoBinding(imgCtrl)
        end

        local num = tonumber(item.number) or 0
        -- 奖品数量
        if num <= 0 then
            self:setNumImgForPanel(imgCtrl, ART_FONT_COLOR.RED, 0, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, itemPanel)
        elseif num > 1 then
            self:setNumImgForPanel(imgCtrl, ART_FONT_COLOR.NORMAL_TEXT, num, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, itemPanel)
        else
            imgCtrl:removeChildByTag(999 * LOCATE_POSITION.RIGHT_BOTTOM)
        end

        -- 绑定显示道具悬浮框
        itemPanel.reward = reward
        self:bindTouchEndEventListener(itemPanel, self.onShowItemInfo)
    end

    self:setButtonState(cell, data)
    self:setLabelText("DaysLabel", string.format(CHS[5400055], data.needDays), cell)
end

function AnniversaryRewardDlg:setButtonState(cell, data)
    if data.flag == 0  then
        -- 未达到领取条件
        self:setCtrlVisible("GetButton", false, cell)
        self:setCtrlVisible("GotButton", false, cell)
        self:setCtrlVisible("NoReachButton", true, cell)
        self:setCtrlEnabled("NoReachButton", false, cell)

        local button = self:getControl("NoReachButton", nil, cell)
        self:setLabelText("Label_3", self.znqLoginGift.loginDays .. "/" .. data.needDays, button)
        self:setLabelText("Label_4", self.znqLoginGift.loginDays .. "/" .. data.needDays, button)
    elseif data.flag == 1 then
        -- 可领取
        self:setCtrlVisible("GetButton", true, cell)
        self:setCtrlVisible("GotButton", false, cell)
        self:setCtrlVisible("NoReachButton", false, cell)
    else
        -- 已领取
        self:setCtrlVisible("GetButton", false, cell)
        self:setCtrlVisible("GotButton", true, cell)
        self:setCtrlVisible("NoReachButton", false, cell)
    end
end

function AnniversaryRewardDlg:updateButtonState(data)
    local cou = #data
    local contentLayer = self.scrollView:getChildByTag(cou * 10)
    for i = 1, cou do
        local cell = contentLayer:getChildByTag(i)
        self:setButtonState(cell, data[i])
    end
end

function AnniversaryRewardDlg:onGetButton(sender, eventType)
    local itemPanel = sender:getParent():getParent()
    local tag = itemPanel:getTag()

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    AnniversaryMgr:fetchZNQLoginGift(tostring(tag))
end

function AnniversaryRewardDlg:MSG_ZNQ_LOGIN_GIFT(data)
    if data.count == 0 then
        if self.scrollView then
            self.scrollView:removeAllChildren()
            self.scrollView = nil
        end

        return
    end

    if self.scrollView then
        -- scrollView 以创建则直接更新按钮状态
        self.znqLoginGift = data
        self:updateButtonState(data)
    else
        self.znqLoginGift = data
        self:initScrollView(data)
    end

    self:showEndTime(self.znqLoginGift.end_time)
end

function AnniversaryRewardDlg:MSG_ZNQ_LOGIN_GIFT_2019(data)
    self:MSG_ZNQ_LOGIN_GIFT(data)
end

function AnniversaryRewardDlg:cleanup()
    self:releaseCloneCtrl("itemPanel")
    self.scrollView = nil

    DragonBonesMgr:removeCharDragonBonesResoure(ResMgr.DragonBones.anniversary_lingmao_type3, string.format("%05d", ResMgr.DragonBones.anniversary_lingmao_type3))
end

return AnniversaryRewardDlg
