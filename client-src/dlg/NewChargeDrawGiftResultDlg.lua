-- NewChargeDrawGiftResultDlg.lua
-- Created by huang Dec/12/2017
-- 新充值好礼翻牌界面

local NewChargeDrawGiftResultDlg = Singleton("NewChargeDrawGiftResultDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

local LEVEL_STR = {
    [0] = CHS[5410162],
    [1] = CHS[5410163],
    [2] = CHS[5410164],
    [3] = CHS[5410165],
    [4] = CHS[5410166],
}

function NewChargeDrawGiftResultDlg:init(drawType)
    self:bindListener("LeaveButton", self.onLeaveButton)
    self:bindListener("RetryButton", self.onRetryButton)
    self:bindListener("CardPanel1", self.onCardPanel)

    self:bindListener("ItemImage", self.onItemImage, "CardPanel2")

    self.rewardStr = nil           -- 奖品
    self.drawType = drawType or 1  -- 抽奖类型 1 普通抽取  2大额抽取
    self.rewardLevel = 4           -- 奖品等级
    self.clickDrawPanel = nil

    self:startDraw()

    self:createArmatureAction()

    self:setLabelText("TimeLabel", CHS[5420260] .. Me:queryBasicInt("lottery_times"), "ResultPanel")

    local winSize = self:getWinSize()
    self.root:setContentSize(winSize.width / Const.UI_SCALE, winSize.height / Const.UI_SCALE)

    self:hookMsg("MSG_NEW_LOTTERY_DRAW")
    self:hookMsg("MSG_NEW_LOTTERY_DRAW_FAIL")
    self:hookMsg("MSG_UPDATE")
end

-- 离开
function NewChargeDrawGiftResultDlg:onLeaveButton(sender, eventType)
    self:onCloseButton()
end

-- 再来一次
function NewChargeDrawGiftResultDlg:onRetryButton(sender, eventType)
    if not self:judge() then
        self:onCloseButton()
        return
    end

    self:startDraw()

    self:onCardPanel()
end

function NewChargeDrawGiftResultDlg:judge()
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[5000228])
        return
    end

    local cou = self.drawType == 1 and 1 or 10
    if Me:queryBasicInt("lottery_times") < cou then
        gf:ShowSmallTips(CHS[5450052])
        return
    end

    if not InventoryMgr:getFirstEmptyPos() then
        gf:ShowSmallTips(CHS[7000176])
        return
    end

    if PetMgr:getFreePetCapcity() <= 0  then
        gf:ShowSmallTips(CHS[3002310])
        return
    end

    return true
end

-- 翻牌
function NewChargeDrawGiftResultDlg:onCardPanel(sender, eventType)
    if self.clickDrawPanel then
        return
    end

    if not self:judge() then
        return
    end

    if self:checkSafeLockRelease("onCardPanel") then
        return
    end

    self.clickDrawPanel = true
    self.root:stopAction(self.drawPanelDelay)
    self.drawPanelDelay = performWithDelay(self.root, function()
        self.clickDrawPanel = false
    end, 3)

     gf:CmdToServer("CMD_NEW_LOTTERY_DRAW", {type = self.drawType})
end

function NewChargeDrawGiftResultDlg:onItemImage(sender)
    RewardContainer:imagePanelTouch(sender, ccui.TouchEventType.ended)
end

function NewChargeDrawGiftResultDlg:createArmatureAction()
    local magic = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.charge_draw_fanpai.name)
    local panel = self:getControl("CardPanel1", nil, "ResultPanel")

    magic:setAnchorPoint(0.5, 0.5)
    local size = panel:getContentSize()
    local x, y = panel:getPosition()
    magic:setPosition(x + size.width / 2, y + size.height / 2)
    panel:getParent():addChild(magic, 0, 0)
    magic:setVisible(false)

    local function func(sender, etype, id)
        if self.magic ~= magic then return end
        if etype == ccs.MovementEventType.start then
            magic:setVisible(true)
            self:setCtrlVisible("CardPanel1", false, "ResultPanel")
            self:setCtrlVisible("CardPanel2", false, "ResultPanel")

            performWithDelay(magic, function()
                gf:CmdToServer("CMD_NEW_LOTTERY_FETCH", {})
                self:showReward()
            end, 0.5)
        elseif etype == ccs.MovementEventType.complete then
            magic:setVisible(false)
        end
    end

    magic:getAnimation():setMovementEventCallFunc(func)
    self.magic = magic
end

function NewChargeDrawGiftResultDlg:showReward()
    if self.rewardStr then
        -- 奖品图片
        local classList = TaskMgr:getRewardList(self.rewardStr)
        if #classList > 0 and classList[1] and classList[1][1] then
            local reward = classList[1][1]
            local name = RewardContainer:getTextList(reward)[1]

            -- 奖品图标
            local imgPath, textureResType = RewardContainer:getRewardPath(reward)
            local img = self:getControl("ItemImage", nil, "CardPanel2")
            img:loadTexture(imgPath, textureResType)
            img:setTouchEnabled(true)
            img.reward = reward

            -- 奖品名称
            self:setLabelText("NameLabel", name, "CardPanel2")
        end

        -- 奖品等级
        self:setLabelText("LevelLabel", LEVEL_STR[self.rewardLevel], "CardPanel2")

        -- 卡牌背景图
        if self.drawType == 1 then
            self:setCtrlVisible("CardImage1", true, "CardPanel2")
            self:setCtrlVisible("CardImage2", false, "CardPanel2")
        else
            self:setCtrlVisible("CardImage1", false, "CardPanel2")
            self:setCtrlVisible("CardImage2", true, "CardPanel2")
        end

        self:setCtrlVisible("CardPanel1", false, "ResultPanel")
        self:setCtrlVisible("CardPanel2", true, "ResultPanel")
        self:setCtrlVisible("LeaveButton", true, "ResultPanel")
        self:setCtrlVisible("RetryButton", true, "ResultPanel")
        self:setCtrlVisible("TimeLabel", true, "ResultPanel")
    end
end

function NewChargeDrawGiftResultDlg:startDraw()
    if self.drawType == 1 then
        self:setCtrlVisible("CardImage1", true, "CardPanel1")
        self:setCtrlVisible("CardImage2", false, "CardPanel1")
    else
        self:setCtrlVisible("CardImage1", false, "CardPanel1")
        self:setCtrlVisible("CardImage2", true, "CardPanel1")
    end

    self:setCtrlVisible("CardPanel1", true)
    self:setCtrlVisible("CardPanel2", false)
    self:setCtrlVisible("LeaveButton", false)
    self:setCtrlVisible("RetryButton", false)
    self:setCtrlVisible("TimeLabel", false, "ResultPanel")
end

function NewChargeDrawGiftResultDlg:MSG_NEW_LOTTERY_DRAW(data)
    self.rewardStr = data.name
    self.rewardLevel = data.level

    if self.drawType == 1 then
        self.magic:getAnimation():play("Bottom01")
    else
        self.magic:getAnimation():play("Bottom02")
    end

    self.clickDrawPanel = false
end

function NewChargeDrawGiftResultDlg:MSG_NEW_LOTTERY_DRAW_FAIL(data)
    self.clickDrawPanel = false
end

function NewChargeDrawGiftResultDlg:cleanup()
    gf:CmdToServer("CMD_NEW_LOTTERY_CANCEL", {})
    ArmatureMgr:removeUIArmature(ResMgr.ArmatureMagic.charge_draw_fanpai.name)
    self.drawPanelDelay = nil
end

function NewChargeDrawGiftResultDlg:MSG_UPDATE(data)
    self:setLabelText("TimeLabel", CHS[5420260] .. Me:queryBasicInt("lottery_times"), "ResultPanel")
end

return NewChargeDrawGiftResultDlg
