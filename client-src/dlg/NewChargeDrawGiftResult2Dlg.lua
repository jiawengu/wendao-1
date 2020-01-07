-- NewChargeDrawGiftResult2Dlg.lua
-- Created by huangzz July/12/2018
-- 新充值好礼结果界面(第二版)

local NewChargeDrawGiftResult2Dlg = Singleton("NewChargeDrawGiftResult2Dlg", Dialog)

local RewardContainer = require("ctrl/RewardContainer")

local LEVEL_STR = {
    [0] = CHS[5410162],
    [1] = CHS[5410163],
    [2] = CHS[5410164],
    [3] = CHS[5410165],
    [4] = CHS[5410166],
}

-- drawType  1 普通抽取、2 大额抽取、3 普通十连抽、4 大额十连抽
function NewChargeDrawGiftResult2Dlg:init(drawType)
    self:bindListener("AgainButton", self.onAgainButton)
    self:bindListener("LeaveButton", self.onCloseButton)

    self.drawType = drawType
    self.canClickButton = true

    local num = self:isTenDraw() and 10 or 1
    self:setLabelText("Label_147", string.format(CHS[5400608], gf:changeNumber(num)), "AgainButton")
    self:setLabelText("Label_148", string.format(CHS[5400608], gf:changeNumber(num)), "AgainButton")

    self:setLabelText("TitleLabel", CHS[5420260] .. Me:queryBasicInt("lottery_times"), "DrawTimesPanel")

    self:initCards()

    -- self:hookMsg("MSG_NEW_LOTTERY_DRAW")
    -- self:hookMsg("MSG_NEW_LOTTERY_DRAW_FAIL")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_NEW_LOTTERY_FETCH_DONE")
    -- self:hookMsg("MSG_NEW_LOTTERY_DRAW_DONE")
end

function NewChargeDrawGiftResult2Dlg:isTenDraw()
    return self.drawType > 2
end

function NewChargeDrawGiftResult2Dlg:isBigDraw()
    return self.drawType % 2 == 0
end

function NewChargeDrawGiftResult2Dlg:getDrawTimes()
    return self:isTenDraw() and 10 or 1
end

function NewChargeDrawGiftResult2Dlg:onAgainButton(sender, eventType)
    if not self.canClickButton then
        return
    end

    if not self:judge() then
        self:onCloseButton()
        return
    end

    DlgMgr:sendMsg("NewChargeDrawGiftDlg", "clearRewardQue")

    self:initCards()

    self:startDraw()

    sender:stopAllActions()
    performWithDelay(sender, function() 
        self.canClickButton = true
    end, 5)

    self.canClickButton = false
end

function NewChargeDrawGiftResult2Dlg:onLeaveButton(sender, eventType)
end

-- 翻牌
function NewChargeDrawGiftResult2Dlg:startDraw()
    gf:frozenScreen(5000)

    gf:CmdToServer("CMD_NEW_LOTTERY_DRAW", {type = self.drawType})
end

function NewChargeDrawGiftResult2Dlg:onItemImage(sender)
    RewardContainer:imagePanelTouch(sender, ccui.TouchEventType.ended)
end

function NewChargeDrawGiftResult2Dlg:judge()
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[5000228])
        return
    end

    local drawCou = self:isTenDraw() and 10 or 1
    local times = self:isBigDraw() and 10 or 1
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
        return
    end

    return true
end

function NewChargeDrawGiftResult2Dlg:initCards()
    -- 显示卡牌的背面
    if self:isTenDraw() then
        for i = 1, 10 do
            local panel = self:getCurCardPanel(i)
            -- self:showBackCard(panel)
            self:hideCard(panel)
        end

        self:setCtrlVisible("OneResultPanel", false)
        self:setCtrlVisible("TenResultPanel", true)
    else
        local panel = self:getCurCardPanel()
        -- self:showBackCard(panel)
        self:hideCard(panel)

        self:setCtrlVisible("OneResultPanel", true)
        self:setCtrlVisible("TenResultPanel", false)
    end
end

function NewChargeDrawGiftResult2Dlg:getCurCardPanel(index)
    if not self:isTenDraw() then
        -- 一连抽
        return self:getControl("CardPanel1", nil, "OneResultPanel")
    else
        -- 十连抽
        return self:getControl("CardPanel" .. index, nil, "TenResultPanel")
    end
end

-- 显示卡牌背面
function NewChargeDrawGiftResult2Dlg:showBackCard(panel)
    self:hideCard(panel)
    if not self:isBigDraw() then
        -- 普通抽奖
        self:setCtrlVisible("SilverCardImage1", true, panel)
    else
        -- 大额抽奖
        self:setCtrlVisible("GoldCardImage1", true, panel)
    end
end

-- 显示卡牌正面
function NewChargeDrawGiftResult2Dlg:showFrontCard(panel)
    self:hideCard(panel)
    if not self:isBigDraw() then
        -- 普通抽奖
        self:setCtrlVisible("SilverCardImage2", true, panel)
    else
        -- 大额抽奖
        self:setCtrlVisible("GoldCardImage2", true, panel)
    end
end

function NewChargeDrawGiftResult2Dlg:hideCard(panel)
    self:setCtrlVisible("GoldCardImage1", false, panel)
    self:setCtrlVisible("GoldCardImage2", false, panel)
    self:setCtrlVisible("SilverCardImage1", false, panel)
    self:setCtrlVisible("SilverCardImage2", false, panel)
end

function NewChargeDrawGiftResult2Dlg:getCurActionName(index)
    if self.drawType == 1 then
        return string.format("Bottom%02d", 1)
    elseif self.drawType == 3 then
        return string.format("Top%02d", index)
    elseif self.drawType == 2 then
        return string.format("Bottom%02d", 2)
    else
        return string.format("Top%02d", index + 10)
    end
end

-- 十连抽-翻牌光效
function NewChargeDrawGiftResult2Dlg:createTenArmature(index, data)
    local magic = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.charge_draw_fanpai_ten.name)
    local panel = self:getCurCardPanel(index)
    local size = panel:getParent():getContentSize()
    magic:setPosition(size.width / 2, size.height / 2 + 13)
    magic:setAnchorPoint(0.5, 0.5)
    panel:getParent():addChild(magic, 5, 0)

    local function func(sender, etype, id)
        if etype == ccs.MovementEventType.start then
            self:hideCard(panel)
             performWithDelay(panel, function()
                -- 延时处理只为效果
                self:doAction(index + 1)
             end, 0.1)
        elseif etype == ccs.MovementEventType.complete then
            magic:stopAllActions()
            magic:removeFromParent(true)
            self:showReward(panel, data)
        end
    end

    magic:getAnimation():setMovementEventCallFunc(func)
    magic:getAnimation():play(self:getCurActionName(index), -1, 0)
    
    return magic
end

-- 抽一次-翻牌光效
function NewChargeDrawGiftResult2Dlg:createOneArmature(index, data)
    local magic = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.charge_draw_fanpai.name)
    local panel = self:getCurCardPanel(index)
    local size = panel:getContentSize()
    local x, y = panel:getPosition()
    magic:setPosition(x + size.width / 2, y + size.height / 2)
    magic:setAnchorPoint(0.5, 0.5)
    panel:getParent():addChild(magic, 5, 0)


    local function func(sender, etype, id)
        if etype == ccs.MovementEventType.start then
            self:hideCard(panel)

            performWithDelay(panel, function()
                -- 延时处理只为效果
                self:showReward(panel, data)
                self:doAction(index + 1)
            end, 0.5)
        elseif etype == ccs.MovementEventType.complete then
            magic:stopAllActions()
            magic:removeFromParent(true)
        end
    end

    magic:getAnimation():setMovementEventCallFunc(func)
    magic:getAnimation():play(self:getCurActionName(index), -1, 0)
    
    return magic
end

-- 物品栏特效
function NewChargeDrawGiftResult2Dlg:createAroundArmature(cell)
    if not cell then
        return
    end

    local magic = cell:getChildByTag(100)
    if magic then
        return
    end

    magic = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.charge_draw_fanpai_ten.name)
    local size = cell:getContentSize()
    magic:setPosition(size.width / 2, size.height / 2)
    magic:setAnchorPoint(0.5, 0.5)
    cell:addChild(magic, 5, 100)

    magic:getAnimation():play("Top21", -1, 1)
    
    return magic
end

function NewChargeDrawGiftResult2Dlg:showReward(panel, data)
    local rewardStr = data.reward_str
    local rewardLevel = data.level
    if rewardStr then
        local cell
        if self:isBigDraw() then
            cell = self:getControl("GoldCardImage2", nil, panel)
        else
            cell = self:getControl("SilverCardImage2", nil, panel)
        end

        -- 奖品图片
        local classList = TaskMgr:getRewardList(rewardStr)
        if #classList > 0 and classList[1] and classList[1][1] then
            local reward = classList[1][1]
            local name = RewardContainer:getTextList(reward)[1]

            -- 奖品图标
            local imgPath, textureResType = RewardContainer:getRewardPath(reward)
            local img = self:getControl("ItemImage", nil, cell)
            img:loadTexture(imgPath, textureResType)
            img:setTouchEnabled(true)
            img.reward = reward

            if reward[1] == CHS[6000079] then
                self:createAroundArmature(img)
            else
                local magic = img:getChildByTag(100)
                if magic then
                    magic:removeFromParent(true)
                end
            end

            self:bindTouchEndEventListener(img, self.onItemImage)

            -- 奖品名称
            self:setLabelText("NameLabel", name, cell)
        end

        -- 奖品等级
        self:setLabelText("LevelLabel", LEVEL_STR[rewardLevel], cell)

        self:showFrontCard(panel)
    end
end

function NewChargeDrawGiftResult2Dlg:MSG_NEW_LOTTERY_DRAW(data)
    table.insert(self.rewardQue, data)
end

function NewChargeDrawGiftResult2Dlg:MSG_NEW_LOTTERY_DRAW_FAIL(data)
    if #self.rewardQue > 0 then
        gf:frozenScreen(5000)
        self:doAction(1)
    else
        self:onCloseButton()
    end
end

function NewChargeDrawGiftResult2Dlg:MSG_NEW_LOTTERY_DRAW_DONE(data)
    gf:frozenScreen(5000)
    self:doAction(1)
end

function NewChargeDrawGiftResult2Dlg:doAction(index)
    local data = DlgMgr:sendMsg("NewChargeDrawGiftDlg", "getNextReward")
    if not data or index > self:getDrawTimes() then
        self.canClickButton = true

        local time = 0.3
        if self:isTenDraw() then
            time = 0.7
        end

        performWithDelay(self.root, function()
            -- 避免动画未播完就弹出了宠物奖励界面
            gf:unfrozenScreen()
            gf:CmdToServer("CMD_NEW_LOTTERY_FETCH", {})
        end, time)
        return
    end

    gf:frozenScreen(2000)

    -- local data = table.remove(rewardQue, 1)
    if self:isTenDraw() then
        self:createTenArmature(index, data)
    else
        self:createOneArmature(index, data)
    end
end

function NewChargeDrawGiftResult2Dlg:cleanup()
    gf:CmdToServer("CMD_NEW_LOTTERY_CANCEL", {})
    ArmatureMgr:removeUIArmature(ResMgr.ArmatureMagic.charge_draw_fanpai.name)
    ArmatureMgr:removeUIArmature(ResMgr.ArmatureMagic.charge_draw_fanpai_ten.name)
    gf:unfrozenScreen()
end

function NewChargeDrawGiftResult2Dlg:MSG_UPDATE(data)
    self:setLabelText("TitleLabel", CHS[5420260] .. Me:queryBasicInt("lottery_times"), "DrawTimesPanel")
end

function NewChargeDrawGiftResult2Dlg:MSG_NEW_LOTTERY_FETCH_DONE(data)
end

return NewChargeDrawGiftResult2Dlg
