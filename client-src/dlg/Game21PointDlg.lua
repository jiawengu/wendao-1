-- Game21PointDlg.lua
-- Created by huangzz Sep/05/2017
-- 培育巨兽运气测试界面（21点）

local Game21PointDlg = Singleton("Game21PointDlg", Dialog)

function Game21PointDlg:init()
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("FightButton", self.onFightButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("ExitButton", self.onExitButton)
    self:bindListener("RetryButton", self.onRetryButton)
    
    self:createArmature()
    self.isPlayingMagic = false
    self.data = nil
    self.lastPoint = 0
    self.finish = nil
    
    self:setLabelText("NumLabel2", 0, "ResultPanel1")
    
    self:hookMsg("MSG_PARTY_YQCS_RESULT")
end

-- 播放骨骼动画
function Game21PointDlg:createArmature()
    self.magic = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.bobing_toutouzi.name)
    self.magic:setVisible(false)
    local function func(sender, etype)
        if etype == ccs.MovementEventType.complete then
            self.isPlayingMagic = false
            self.magic:setVisible(false)
            if self.data then
                self:MSG_PARTY_YQCS_RESULT(self.data)
                self.data = nil
            end
        end
    end

    local showPanel = self:getControl("BowlImage")
    self.magic:setAnchorPoint(0.5, 0.5)
    local size = showPanel:getContentSize()
    self.magic:setPosition(size.width / 2, size.height / 2)
    showPanel:addChild(self.magic)

    self.magic:getAnimation():setMovementEventCallFunc(func)
end

-- 加点
function Game21PointDlg:onBuyButton(sender, eventType)
    if self.isPlayingMagic or self.finish or not self.magic then
        return
    end
    
    self.isPlayingMagic = true
    gf:CmdToServer("CMD_PARTY_YQCS_ADD_POINT", {})
end

-- 一决胜负
function Game21PointDlg:onFightButton(sender, eventType)
    if self.isPlayingMagic or self.finish then
        return
    end
    
    self.finish = true
    gf:CmdToServer("CMD_PARTY_YQCS_GET_RESULT", {})
end

-- 规则
function Game21PointDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("Game21PointRuleDlg")
end

-- 退出
function Game21PointDlg:onExitButton(sender, eventType)
    self:close()
    local task = TaskMgr:getTaskByShowName(CHS[5400244])
    if task then
        gf:doActionByColorText(task.task_prompt, task)
    end
end

-- 再来一次
function Game21PointDlg:onRetryButton(sender, eventType)
    gf:CmdToServer("CMD_PARTY_YQCS_REPLAY", {})
    self.isPlayingMagic = false
    self.finish = false 
    self.lastPoint = 0
end

-- 隐藏所有骰子
function Game21PointDlg:setTouziVisible()
    for i = 1, 6 do
        self:setCtrlVisible("Image_" .. i, false, "BowlImage")
    end
end

function Game21PointDlg:MSG_PARTY_YQCS_RESULT(data)
    if data.sysPoint == -1 then
        -- 游戏终止
        self:onCloseButton() 
        return
    end
    
    if self.isPlayingMagic then
        self.data = data
        if self.magic then
            self.magic:getAnimation():play("Bottom")
            self.magic:setVisible(true)
        end
        
        self:setTouziVisible()
        return
    end
    
    self:setCtrlVisible("TaklLabelPanel1", false)
    self:setCtrlVisible("TaklLabelPanel2", false)
    self:setCtrlVisible("TaklLabelPanel3", false)
    self:setCtrlVisible("TaklLabelPanel4", false)
    self:setCtrlVisible("BuyButton", false)
    self:setCtrlVisible("FightButton", false)
    self:setCtrlVisible("RetryButton", false)
    self:setCtrlVisible("ExitButton", false)
    self:setCtrlVisible("ResultImage1", false, "ResultPanel2")
    self:setCtrlVisible("ResultImage2", false, "ResultPanel2")
    self:setCtrlVisible("ResultPanel1", false)
    self:setCtrlVisible("ResultPanel2", false)
    local addPoint = data.myPoint - self.lastPoint
    if addPoint > 0 and self.lastPoint > 0 then
        self:setTouziVisible()
        self:setCtrlVisible("Image_" .. addPoint, true, "BowlImage")
    end
    
    self.lastPoint = data.myPoint
    self:setImage("BackImage2", ResMgr:getSmallPortrait(data.icon), "PortraitPanel")
    
    if data.sysPoint > 0 then
        self:setCtrlVisible("ResultPanel2", true)
        self:setLabelText("NumLabel1", CHS[5410128] .. data.myPoint, "ResultPanel2")
        
        if data.myPoint > 21 then
            self:setCtrlVisible("TaklLabelPanel4", true)
            self:setCtrlVisible("ResultImage2", true, "ResultPanel2")
            self:setCtrlVisible("RetryButton", true)
        elseif data.myPoint > data.sysPoint then
            self:setCtrlVisible("TaklLabelPanel2", true)
            self:setCtrlVisible("ResultImage1", true, "ResultPanel2")
            self:setLabelText("TaklLabel2", data.sysPoint, "TaklLabelPanel2")
            self:setCtrlVisible("ExitButton", true)
        else
            self:setCtrlVisible("TaklLabelPanel3", true)
            self:setCtrlVisible("ResultImage2", true, "ResultPanel2")
            self:setLabelText("TaklLabel2", data.sysPoint, "TaklLabelPanel3")
            self:setCtrlVisible("RetryButton", true)
        end
        
        gf:CmdToServer("CMD_PARTY_YQCS_CONFIRM_RESULT", {})
    else
        self:setCtrlVisible("TaklLabelPanel1", true)
        self:setCtrlVisible("ResultPanel1", true)
        self:setLabelText("NumLabel2", data.myPoint, "ResultPanel1")
        
        self:setCtrlVisible("BuyButton", true)
        self:setCtrlVisible("FightButton", true)
    end
end

function Game21PointDlg:cleanup()
    ArmatureMgr:removeUIArmature(ResMgr.ArmatureMagic.bobing_toutouzi.name)
    
    DlgMgr:closeDlg("Game21PointRuleDlg")
    
    gf:CmdToServer("CMD_PARTY_YQCS_QUIT", {})
    
    self.magic = nil
    self.data = nil
end

return Game21PointDlg
