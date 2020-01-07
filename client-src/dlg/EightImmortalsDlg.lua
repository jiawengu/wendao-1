
-- EightImmortalsDlg.lua
-- Created by songcw Jan/18/2016
-- 

local EightImmortalsDlg = Singleton("EightImmortalsDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

local BX_STATE = {
    PASS = 1,      -- 通关
    NO_OPEN = 2,   -- 未开启
    LIMIT = 3,     -- 未开放 
    CUR_NO_PASS = 4,
    CUR_PASS = 5,
}

local REWARD_INFO = {
    [1] = CHS[3002393], -- 吕洞宾
    [2] = CHS[3002393], -- 韩湘子
    [3] = CHS[3002393], -- 张果老
    [4] = CHS[3002393], -- 何仙姑
}

local POS_ARM_MAGIC = {
    [1] = "Top01",
    [2] = "Top02",
    [3] = "Top03",
    [4] = "Top04",
    [5] = "Top05",
}

local MAX_PANEL = 9

function EightImmortalsDlg:init()    
    self:onCloseRule()
    
    self:bindListener("BKPanel", self.onCloseRule)
    self:bindListener("RulePanel", self.onCloseRule)
    self:bindListener("ResetButton", self.onResetButton)
    self:bindListener("EnterButton", self.onEnterButton)
    self:bindListener("RuleButton", self.onRuleButton)
    self:bindListener("RollButton", self.onRollButton)
    self:bindListener("DiceImage", self.onDiceImage)    
    
    self:hookMsg("MSG_BAXIAN_DICE")
   
    self.curIndex = nil
    self:initDice()
end

function EightImmortalsDlg:setBtnsEnble(isEnble)
    self:setCtrlEnabled("RollButton", isEnble)
    self:setCtrlEnabled("ResetButton", isEnble)
    self:setCtrlEnabled("EnterButton", isEnble)
end

function EightImmortalsDlg:cleanup()
    self.isWaiting = false
    if self.isNeedGetReward then
        TaskMgr:cmdBaxianDiceFinish()        
    end
    self.isNeedGetReward = false
end

function EightImmortalsDlg:initDice()
    -- 骰子初始化
    local retInitPanel = self:getControl("DicePositionPanel")
    retInitPanel:setVisible(true)
    for i = 1, 5 do
        local panel = self:getControl("PositionPanel_" .. i, nil, retInitPanel)
        panel:setVisible(true)
        for j = 1, 6 do
            self:setCtrlVisible("DiceImage_" .. j, false, panel)
        end
    end
    
    for i = 1, 9 do
        local panel = self:getControl("CheckPointPanel_" .. i)
        local choseImagex, choseImagey = self:getControl("ChoseImage", nil, panel):getPosition()
        panel.choseImagex = choseImagex
        panel.choseImagey = choseImagey
    end
end

-- 设置对话框信息
function EightImmortalsDlg:setDataInfo(data)
    self.data = data
    local curNum = -1
    for i = 0, 8 do
        local state = BX_STATE.LIMIT
        if i < data.openMax then
            -- 此关已经开放
            state = BX_STATE.NO_OPEN
            if i < data.curCheckpoint then
                -- 小于当前关，必然已通关
                state = BX_STATE.PASS
            elseif i == data.curCheckpoint then
                if data.mainState == 2 then
                    -- 当前任务关卡完成
                    state = BX_STATE.PASS
                else
                    -- 进行中或者可以开启
                    curNum = i
                end
            elseif i == data.curCheckpoint + 1 then
                if data.mainState == 2 then
                    -- 上一关已经完成
                    curNum = i
                end
            end
        end

        local panel = self:getControl("CheckPointPanel_" .. (i + 1))
        panel:setTag(i + 1)
        self:setTaskByState(state, panel, (curNum == i))
    end
    
    self.curIndex = curNum + 1
    --
    for i = 1, 4 do
        local panel = self:getControl("ItemPanel_" .. i)
        if panel then panel:removeFromParent() end
    end
    
    if data.data ~= 8 and REWARD_INFO[1] then
        local rewardPanel = self:getControl("RewardPanel")
        local rewardContainer  = RewardContainer.new(REWARD_INFO[1], rewardPanel:getContentSize(), nil, nil, true)
        rewardContainer:setAnchorPoint(0, 0.5)
        rewardContainer:setPosition(30, rewardPanel:getContentSize().height / 2 + 10)
        rewardPanel:addChild(rewardContainer)
    end
    --]]
    -- 剩余通关次数    
    self:setLabelText("RemainderLabel", string.format(CHS[3002394], data.times))
    
    self:setDiceCount()
end

-- 设置关卡开启状态
function EightImmortalsDlg:setTaskByState(state, panel, isCur)
    if not panel  then return end
    
    if isCur then
        local pickImage = self:getControl("ChoseImage", nil, panel)
        pickImage:setVisible(true)     
        pickImage:stopAllActions()
        pickImage:setPosition(panel.choseImagex, panel.choseImagey)        
        local time = 0.6
        local high = 8
        local moveUp = cc.MoveBy:create(time, cc.p(0, high))
        local moveDown = cc.MoveBy:create(time, cc.p(0, -high))
        local act = cc.Sequence:create(moveUp, moveDown)                
        pickImage:runAction(cc.RepeatForever:create(act))
        pickImage:setVisible(true)        
        
        if state == BX_STATE.PASS then
            state = BX_STATE.CUR_PASS
        else
            state = BX_STATE.CUR_NO_PASS
        end
    end  
 
    
    if state == BX_STATE.PASS then
        -- 通关
        self:setImageResume("PersonImage", panel)
        self:setCtrlVisible("PersonImage", true, panel)
        self:setCtrlEnabled("PersonImage", true, panel)
        self:setCtrlVisible("NameImage", true, panel)
        self:setCtrlVisible("NameImage_1", true, panel)
        self:setCtrlVisible("ChoseImage", false, panel)
        self:setCtrlVisible("SuccessImage", true, panel)
    elseif state == BX_STATE.NO_OPEN then
        -- 未开启
        self:setImageResume("PersonImage", panel)
        self:setCtrlVisible("PersonImage", true, panel)
        self:setCtrlEnabled("PersonImage", false, panel)
        self:setCtrlVisible("NameImage", false, panel)
        self:setCtrlVisible("NameImage_1", false, panel)
        self:setCtrlVisible("ChoseImage", false, panel)
        self:setCtrlVisible("SuccessImage", false, panel)
    elseif state == BX_STATE.LIMIT then 
        -- 未开放
        self:setImageResume("PersonImage", panel)
        self:setImageShadow("PersonImage", panel)
        self:setCtrlVisible("NameImage", false, panel)
        self:setCtrlVisible("NameImage_1", false, panel)
        self:setCtrlVisible("ChoseImage", false, panel)
        self:setCtrlVisible("SuccessImage", false, panel)
    elseif state == BX_STATE.CUR_NO_PASS then
        self:setImageResume("PersonImage", panel)
        self:setCtrlEnabled("PersonImage", true, panel)
        self:setCtrlVisible("NameImage", true, panel)
        self:setCtrlVisible("NameImage_1", true, panel)
        self:setCtrlVisible("ChoseImage", true, panel)
        self:setCtrlVisible("SuccessImage", false, panel) 
    elseif state == BX_STATE.CUR_PASS then
        self:setImageResume("PersonImage", panel)
        self:setCtrlVisible("NameImage", true, panel)
        self:setCtrlVisible("NameImage_1", true, panel)
        self:setCtrlVisible("ChoseImage", true, panel)
        self:setCtrlVisible("SuccessImage", true, panel) 
    end
end

-- 还原图片设置
function EightImmortalsDlg:setImageResume(ctrlName, panel)
    local hero = self:getControl(ctrlName, Const.UIImage, panel)
    hero:resume()
end

-- 设置图片剪影效果
function EightImmortalsDlg:setImageShadow(ctrlName, panel)
    local hero = self:getControl(ctrlName, nil, panel)
    hero:setOpacity(125)
    hero:setColor(COLOR3.BLACK)
end

function EightImmortalsDlg:onSelect(sender, eventType)
    if Me:queryBasicInt("level") < 60 then
        gf:ShowSmallTips(CHS[3002395])
        return
    end
    
    if TeamMgr:inTeamEx(Me:getId()) then
        gf:ShowSmallTips(CHS[3002396])
        return
    end
    
    -- 今日完成次数有服务器判断
    
    -- 通关判断
    if self.data and self.data.curCheckpoint == 8 and self.data.mainState == 2 then
        gf:ShowSmallTips(CHS[3002397])
        return
    end
    
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_BAXIAN_ENTER)
end

function EightImmortalsDlg:onResetButton(sender, eventType)
    self:onCloseRule()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_BAXIAN_RESET)
end

function EightImmortalsDlg:onEnterButton(sender, eventType)
    self:onCloseRule()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_BAXIAN_ENTER)
end

function EightImmortalsDlg:onCloseRule(sender, eventType)
    local rulePanel = self:getControl("RulePanel")
    rulePanel:setVisible(false)
end

function EightImmortalsDlg:onRuleButton(sender, eventType)
    local rulePanel = self:getControl("RulePanel")
    rulePanel:setVisible(rulePanel:isVisible() == false)
end

function EightImmortalsDlg:onDiceImage(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(CHS[4200337], rect)
end

-- 点击投掷按钮
function EightImmortalsDlg:onRollButton(sender, eventType)
    if self.isWaiting then return end    

    self:initDice()
    
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3002430])
        return
    end

    if Me:queryBasicInt("level") < 60 then
        gf:ShowSmallTips(CHS[4200338])
        return
    end

    if Me:isRedName() then
        gf:ShowSmallTips(CHS[4200339])
        return
    end

    if self.data.times <= 0 then
        gf:ShowSmallTips(CHS[4200340])
        return
    end
    
    local amount = InventoryMgr:getAmountByName(CHS[4200337])
    if amount <= 0 then
        gf:ShowSmallTips(CHS[4200343])
        return
    end
    local cash = math.max(Me:queryBasicInt("cash"), 0)
    local moneyStr = gf:getMoneyDesc(5000000)
    
    if cash < 5000000 then
        gf:ShowSmallTips(string.format(CHS[4200344], moneyStr))
        return
    end
    local str = CHS[4200345]
    if self.data.times < 6 then
        str = str .. CHS[4200346]
    end
  
    gf:confirm(string.format(str, moneyStr, self.data.times),
        function ()
            self.isWaiting = true            
            self:setBtnsEnble(false) 
            TaskMgr:cmdBaxianDice()    	
        end)  
end

function EightImmortalsDlg:MSG_BAXIAN_DICE(data)
    local posIndex = math.random(1, 5)
   
    local data2 = {posIndex = posIndex, resultIndex = math.min(data.result, self.data.times), display = data.result}
 --   local data2 = {posIndex = posIndex, resultIndex = data.result, display = data.result}

    self.addIndex = data2.resultIndex
    -- 增加光效
    gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.eightgod.name, POS_ARM_MAGIC[posIndex], self.root, self.showResult, self, data2)
end

-- 骰子滚动结束
function EightImmortalsDlg:showResult(data)
    local retInitPanel = self:getControl("DicePositionPanel")
    local panel = self:getControl("PositionPanel_" .. data.posIndex, nil, retInitPanel)
    local displayImage = self:getControl("DiceImage_" .. data.display, nil, panel)
    self:setCtrlVisible("DiceImage_" .. data.display, true, panel)

    self.isNeedGetReward = true

    performWithDelay(self.root, function()
        self:setPassMagic(self.curIndex, data.resultIndex)
    end, 0.3)
    
    performWithDelay(self.root, function()
        displayImage:setVisible(false)
    end, 3)
end

-- 骰子滚动结束通过光效
function EightImmortalsDlg:setPassMagic(start, addCount)
    if start + addCount <= MAX_PANEL then
        -- 不需要跳跃
        for i = start, (start + addCount - 1) do
            local panel = self:getControl("CheckPointPanel_" .. i)
            if panel then
                local image = self:getControl("SuccessImage", nil, panel)
                local x, y = image:getPosition()
                self.showNext = 1
                gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.eightgod.name, "Top06", panel, self.setResultMagic, self, panel, x, y)
            else
                self:setAllNoOpen() -- 全部通过情况
            end
        end
        
        if (start + addCount - 1) == 0 then
            local tag = 1
            local nextPanel = self:getControl("CheckPointPanel_" .. tag)
            self:setTaskByState(BX_STATE.NO_OPEN, nextPanel, true)
            self.isWaiting = false
            self.isNeedGetReward = false
            self:setBtnsEnble(true) 
            TaskMgr:cmdBaxianDiceFinish()
            self.showNext = nil
        end
    else    
        self.showNext = 2
    
        for i = start, MAX_PANEL do
            local panel = self:getControl("CheckPointPanel_" .. i)
            local image = self:getControl("SuccessImage", nil, panel)
            local x, y = image:getPosition()
            gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.eightgod.name, "Top06", panel, self.setResultMagic, self, panel, x, y)
        end
    end
end



-- 骰子滚动结束通过光效 回调
function EightImmortalsDlg:setResultMagic(panel)
    self:setTaskByState(BX_STATE.PASS, panel, false)
    if self.showNext == 1 then
        local tag = self.curIndex + self.addIndex
        local nextPanel = self:getControl("CheckPointPanel_" .. tag)
        self:setTaskByState(BX_STATE.NO_OPEN, nextPanel, true)
        self.isWaiting = false
        self.isNeedGetReward = false
        self:setBtnsEnble(true) 
        TaskMgr:cmdBaxianDiceFinish()
        self.showNext = nil
    elseif self.showNext == 2 then    
        self.showNext = nil        
        local allNoOpenfunc = cc.CallFunc:create(function()  
            self:setAllNoOpen()
        end)

        local setPassfunc = cc.CallFunc:create(function()     
            self.addIndex = self.curIndex + self.addIndex - MAX_PANEL - 1
            self.curIndex = 1
            self.showNext = 1
            self:setPassMagic(1, self.addIndex)
        end)

        local delayAct = cc.DelayTime:create(0.5)
        local action = cc.Sequence:create(delayAct, allNoOpenfunc, setPassfunc)
        self.root:runAction(action)
    end    
end

function EightImmortalsDlg:setDiceCount()
    local amount = InventoryMgr:getAmountByName(CHS[4200337])

    if amount > 999 then
        self:setNumImgForPanel("SilverValuePanel", ART_FONT_COLOR.DEFAULT, "*", false, LOCATE_POSITION.MID, 23)
    else
        self:setNumImgForPanel("SilverValuePanel", ART_FONT_COLOR.DEFAULT, amount, false, LOCATE_POSITION.MID, 23)
    end    
end

function EightImmortalsDlg:setAllNoOpen()
    for i = 1, MAX_PANEL do
        local panel = self:getControl("CheckPointPanel_" .. i)
        self:setTaskByState(BX_STATE.NO_OPEN, panel, false)
    end
end

return EightImmortalsDlg
