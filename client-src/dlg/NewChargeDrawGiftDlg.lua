-- NewChargeDrawGiftDlg.lua
-- Created by huangzz Sep/20/2017
-- 新充值好礼界面

local NewChargeDrawGiftDlg = Singleton("NewChargeDrawGiftDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

-- 好礼一览
local SMALL_ITEM_SPACE = 15

local SMALL_ITEM_NUM = 9  -- 每行显示的道具数目

function NewChargeDrawGiftDlg:init()
    self:bindListener("AddButton", self.onAddButton)

    self:bindListener("OneDrawButton", self.onSmallOneDraw, "LeftPanel")
    self:bindListener("TenDrawButton", self.onSmallTenDraw, "LeftPanel")

    self:bindListener("OneDrawButton", self.onBigOneDraw, "RightPanel")
    self:bindListener("TenDrawButton", self.onBigTenDraw, "RightPanel")

    self:bindListener("InfoButton", self.onInfoButton)

    self.lastSelectButton = nil
    for i = 1, 2 do
        local button = self:getControl("SelectButton" .. i, nil, "SelectPanel")
        button:setTag(i)
        self:bindTouchEndEventListener(button, self.onSelectButton)

        if i == 1 then
            -- 默认选中第一个
            self:onSelectButton(button)
        end
    end

    self.rewardQue = {}
    self.canClickButton = true

    -- 好礼一览相关
    self.viewGiftPanel = self:retainCtrl("ViewGiftItemPanel")
    local giftPanel = self:getControl("GiftPanel1", nil, self.viewGiftPanel)
    self.giftPanelSize = giftPanel:getContentSize()
    local listPanel = self:getControl("ItemListPanel", nil, giftPanel)
    self.listPanelSize = listPanel:getContentSize()
    local x, y = listPanel:getPosition()
    self.listPanelPos = {x = x, y = y}
    local scrollView = self:getControl("ViewGiftScrollView")
    scrollView:addEventListener(function(sender, eventType) self:updateDownArrow(sender, eventType) end)
    self:initGiftScrollView()

    self:setDrawTime()

    gf:CmdToServer("CMD_NEW_LOTTERY_INFO", {})

    self:hookMsg("MSG_NEW_LOTTERY_INFO")
    self:hookMsg("MSG_UPDATE")

    self:hookMsg("MSG_NEW_LOTTERY_DRAW")
    self:hookMsg("MSG_NEW_LOTTERY_DRAW_DONE")
    self:hookMsg("MSG_NEW_LOTTERY_DRAW_FAIL")

    local timePanel = self:getControl("DrawTimesPanel")
    self:setLabelText("TitleLabel", CHS[3002313] .. Me:queryBasicInt("lottery_times") .. CHS[3002314], timePanel)
end

-- 更新向下提示
function NewChargeDrawGiftDlg:updateDownArrow(sender, eventType)
    if ccui.ScrollviewEventType.scrolling == eventType then
        -- 获取控件
        local scrollViewCtrl = sender

        local listInnerContent = scrollViewCtrl:getInnerContainer()
        local innerSize = listInnerContent:getContentSize()
        local scrollViewSize = scrollViewCtrl:getContentSize()

        -- 计算滚动的百分比
        local totalHeight = innerSize.height - scrollViewSize.height

        local innerPosY = listInnerContent:getPositionY()
        local persent = 1 - (-innerPosY) / totalHeight
        persent = math.floor(persent * 100)

        local name = sender:getParent():getName()
        if persent < 85 then
            self:setCtrlVisible("ArrowImage", true, name)
        else
            self:setCtrlVisible("ArrowImage", false, name)
        end
    end
end

function NewChargeDrawGiftDlg:onSelectButton(sender, eventType)
    if self.lastSelectButton == sender then
        return
    end

    local tag = sender:getTag()
    if self.lastSelectButton then
        local selectTag = self.lastSelectButton:getTag()
        self:setCtrlVisible("SelectImage" .. selectTag, false, "SelectPanel")
    end

    self:setCtrlVisible("SelectImage" .. tag, true, "SelectPanel")
    self.lastSelectButton = sender
    if tag == 1 then
        -- 抽奖
        self:setCtrlVisible("DrawMainPanel", true)
        self:setCtrlVisible("ViewGiftPanel", false)
    elseif tag == 2 then
        -- 好礼一览
        self:setCtrlVisible("DrawMainPanel", false)
        self:setCtrlVisible("ViewGiftPanel", true)
    end
end

function NewChargeDrawGiftDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("NewChargeDrawGiftRuleDlg")
end

-- 大额抽取
function NewChargeDrawGiftDlg:onBigOneDraw(sender, eventType)
    if not self.canClickButton then
        return
    end

    self.drawType = 2

    self:onDraw()
end

-- 大额抽取-十连抽
function NewChargeDrawGiftDlg:onBigTenDraw(sender, eventType)
    if not self.canClickButton then
        return
    end

    self.drawType = 4

    self:onDraw()
end

-- 普通抽取-
function NewChargeDrawGiftDlg:onSmallOneDraw(sender, eventType)
    if not self.canClickButton then
        return
    end

    self.drawType = 1

    self:onDraw()
end

-- 普通抽取-十连抽
function NewChargeDrawGiftDlg:onSmallTenDraw(sender, eventType)
    if not self.canClickButton then
        return
    end

    self.drawType = 3

    self:onDraw()
end

function NewChargeDrawGiftDlg:onDraw()
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[5000228])
        return
    end

    local drawCou = self.drawType < 3 and 1 or 10
    local times = self.drawType % 2 == 1 and 1 or 10
    local totalTimes = times * drawCou
    if Me:queryBasicInt("lottery_times") < totalTimes then
        if totalTimes > 1 then
            gf:ShowSmallTips(string.format(CHS[5400610], totalTimes))
        else
            gf:ShowSmallTips(CHS[5450052])
        end
        return
    end

    local count = InventoryMgr:getEmptyPosCount()
    if count < drawCou then
        gf:ShowSmallTips(CHS[7000176])
        return
    end

    if PetMgr:getFreePetCapcity() <= 0  then
        gf:ShowSmallTips(CHS[3002310])
        return false
    end

    if self:checkSafeLockRelease("onDraw") then
        return
    end

    self.canClickButton = false
    gf:frozenScreen(5000)
    gf:CmdToServer("CMD_NEW_LOTTERY_DRAW", {type = self.drawType})
end

function NewChargeDrawGiftDlg:onAddButton(sender, eventType)
    local dlg = DlgMgr:getDlgByName("OnlineRechargeDlg")
    if dlg then
        dlg:reopen()
        DlgMgr:reopenRelativeDlg("OnlineRechargeDlg")
    else
        OnlineMallMgr:openOnlineMall("OnlineRechargeDlg")
    end
end

-- 设置好礼一览奖品列表
function NewChargeDrawGiftDlg:setGiftPanel(cell, rewards)
   if not rewards then
        return self.giftPanelSize.height
    end

    local rewardCou = 0
    local panelCou = 1
    local rewardStr = ""
    local listPanel = self:getControl("ItemListPanel", nil, cell)
    local titleBackPanel = self:getControl("TitleBackImage", nil, cell)
    listPanel:retain()
    titleBackPanel:retain()
    cell:removeAllChildren()
    cell:addChild(titleBackPanel)
    listPanel:removeAllChildren()
    local size = self.listPanelSize
    local pos = self.listPanelPos
    local cou = #rewards
    local row = math.floor(cou / SMALL_ITEM_NUM)
    local leftNum = cou % SMALL_ITEM_NUM
    if leftNum > 0 then
        row = row + 1
    end

    for i = 1, cou do
        rewardCou = rewardCou + 1
        rewards[i].desc = string.gsub(rewards[i].desc, "$1$0", "")
        rewardStr = rewardStr .. rewards[i].desc
        if rewardCou % SMALL_ITEM_NUM == 0 or rewardCou == cou  then
            local panel = listPanel:clone()
            local rewardContainer  = RewardContainer.new(rewardStr, size, nil, nil, true, SMALL_ITEM_SPACE, true, panel:getScale())
            rewardContainer:setAnchorPoint(0, 0.5)
            rewardContainer:setPosition(0, size.height / 2)
            panel:addChild(rewardContainer)

            panel:setPosition(pos.x, pos.y + (row - panelCou) * size.height)
            cell:addChild(panel)

            panelCou = panelCou + 1
            rewardStr = ""
        end
    end

    listPanel:release()
    titleBackPanel:release()

    local addHeight = (row - 1) * size.height
    -- 重设父控件高度
    cell:setContentSize(self.giftPanelSize.width, self.giftPanelSize.height + addHeight)

    -- 重设标题位置
    local titleX, titleY  = titleBackPanel:getPosition()
    titleBackPanel:setPosition(titleX, 84 + addHeight)

    return self.giftPanelSize.height + addHeight
end

-- 显示好礼一览
function NewChargeDrawGiftDlg:initGiftScrollView()
    local data = GiftMgr.newChargeDrawGiftDlgData
    if not data or not next(data.rewards) then
        return
    end

    local scrollView = self:getControl("ViewGiftScrollView")
    scrollView:removeAllChildren()

    local totalHeight = 0
    for i = 0, 4 do
        local giftPanel = self:getControl("GiftPanel" .. (i + 1), nil, self.viewGiftPanel)
        totalHeight = totalHeight + self:setGiftPanel(giftPanel, data.rewards[i]) + 10
    end

    local size = self.viewGiftPanel:getContentSize()
    self.viewGiftPanel:setContentSize(size.width ,152 + totalHeight)
    scrollView:addChild(self.viewGiftPanel)
    scrollView:setInnerContainerSize(self.viewGiftPanel:getContentSize())
end

-- 显示活动时间
function NewChargeDrawGiftDlg:setDrawTime()
    local data = GiftMgr.newChargeDrawGiftDlgData
    if not data then
        return
    end

    local panel = self:getControl("InfoPanel", nil, "DrawMainPanel")
    self:setLabelText("TitleLabel", CHS[3002311] .. gf:getServerDate("%Y-%m-%d %H:%M", tonumber(data.start_time)) .. CHS[3002312] .. gf:getServerDate("%Y-%m-%d %H:%M", tonumber(data.end_time)), panel)
end

function NewChargeDrawGiftDlg:MSG_NEW_LOTTERY_INFO(data)
    self:initGiftScrollView()
    self:setDrawTime()
end

function NewChargeDrawGiftDlg:MSG_UPDATE(data)
    local timePanel = self:getControl("DrawTimesPanel")
    self:setLabelText("TitleLabel", CHS[3002313] .. Me:queryBasicInt("lottery_times") .. CHS[3002314], timePanel)
end

function NewChargeDrawGiftDlg:cleanup()
    DlgMgr:closeDlg("NewChargeDrawGiftResult2Dlg")

    gf:unfrozenScreen()
end

function NewChargeDrawGiftDlg:clearRewardQue()
    self.rewardQue = {}
end

function NewChargeDrawGiftDlg:getNextReward()
    if #self.rewardQue <= 0 then return end
    return table.remove(self.rewardQue, 1)
end

function NewChargeDrawGiftDlg:MSG_NEW_LOTTERY_DRAW(data)
    table.insert(self.rewardQue, data)
end

function NewChargeDrawGiftDlg:MSG_NEW_LOTTERY_DRAW_FAIL(data)
    self.canClickButton = true
    if #self.rewardQue > 0 then
        local dlg = DlgMgr:openDlgEx("NewChargeDrawGiftResult2Dlg", self.drawType)
        dlg:doAction(1)
    else
        DlgMgr:closeDlg("NewChargeDrawGiftResult2Dlg")
        gf:unfrozenScreen()
    end
end

function NewChargeDrawGiftDlg:MSG_NEW_LOTTERY_DRAW_DONE(data)
    local dlg = DlgMgr:openDlgEx("NewChargeDrawGiftResult2Dlg", self.drawType)
    dlg:doAction(1)
    self.canClickButton = true
end

return NewChargeDrawGiftDlg
