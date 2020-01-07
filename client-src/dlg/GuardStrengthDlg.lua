-- GuardStrengthDlg.lua
-- Created by liuhb Feb/3/2015
-- 守护强化界面

local GUARD_MAX_STRENGTH = 80

local GuardStrengthDlg = Singleton("GuardStrengthDlg", Dialog)

function GuardStrengthDlg:init()
    self:bindListener("StrengthButton", self.onStrengthButton)

    self:cleanAllControlUp()
    local guard = DlgMgr:sendMsg("GuardListChildDlg", "getCurrentGuard")
    if nil ~= guard then
        self:setGuardStrengthInfo(guard:queryBasicInt("id"))
    else
        local ctrl = self:getControl("StrengthButton")
        ctrl:setTouchEnabled(false)
        gf:grayImageView(ctrl)      
    end
    
    local dlg = DlgMgr.dlgs["GuardListChildDlg"]

    if dlg then
        dlg:setVisible(true)
    end
    
    local guard = DlgMgr:sendMsg("GuardListChildDlg", "getCurrentGuard")
    if guard then
        self:setGuardStrengthInfo(guard:queryBasicInt("id"))
    end

    self:hookMsg("MSG_GUARDS_REFRESH")
    self:hookMsg("MSG_INVENTORY")

    -- 刷新道具数量
end

function GuardStrengthDlg:cleanup()
    self.guardId = nil
end

-- 强化点击事件
function GuardStrengthDlg:onStrengthButton(sender, eventType)
    local meLevel = Me:queryBasicInt("level")
    local limitLevel = 35
    if limitLevel > meLevel then
        gf:ShowSmallTips(string.format(CHS[3002814], limitLevel))
        return
    end
    
    -- 进度条动画是否完成
    if self.isUpgradeCD then 
        return
    end
    self.isUpgradeCD = true
    
    if nil == self.guardId then return end

    -- 进行判断是否达到等级上限
    local guardStrength = GuardMgr:getStrengthById(self.guardId)
    if guardStrength.strengthlev >= GUARD_MAX_STRENGTH then
        gf:ShowSmallTips(CHS[5000054])
        self.isUpgradeCD = false
    elseif guardStrength.strengthlev >= guardStrength.level then
        gf:ShowSmallTips(string.format(CHS[5000053], guardStrength.level + 1))
        self.isUpgradeCD = false
    elseif 0 >= InventoryMgr:getAmountByName(CHS[5000048]) then
        gf:askUserWhetherBuyItem(CHS[5000048])
        self.isUpgradeCD = false
    else
        GuardMgr:upStrengthNormal(self.guardId)
    end
end

-- 初始化界面上的所有控件的值
function GuardStrengthDlg:cleanAllControlUp()
    self:setLabelText("GuardNameLabel", "", self.root)
    
    local beforePanelCtrl = self:getControl("BeforeValuePanel")
    self:setLabelText("StrengthLevelValueLabel", 0, beforePanelCtrl)
    --local polarPanelCtrl = self:getControl("PolarPanel", nil, beforePanelCtrl)
    self:setLabelText("PolarValueLabel", 0, beforePanelCtrl)
   -- local powerPanelCtrl = self:getControl("PowerPanel", nil, beforePanelCtrl)
    self:setLabelText("PowerValueLabel", 0, beforePanelCtrl)
   -- local ScorePanelCtrl = self:getControl("ScorePanel", nil, beforePanelCtrl)
    self:setLabelText("ScoreValueLabel", 0, beforePanelCtrl)

    local afterPanelCtrl = self:getControl("AfterValuePanel")
    self:setLabelText("StrengthLevelValueLabel", 0, afterPanelCtrl)
    --polarPanelCtrl = self:getControl("PolarPanel", nil, afterPanelCtrl)
    self:setLabelText("PolarValueLabel", 0, afterPanelCtrl)
   -- powerPanelCtrl = self:getControl("PowerPanel", nil, afterPanelCtrl)
    self:setLabelText("PowerValueLabel", 0, afterPanelCtrl)
    --ScorePanelCtrl = self:getControl("ScorePanel", nil, afterPanelCtrl)
    self:setLabelText("ScoreValueLabel", 0, afterPanelCtrl)
    self:getControl("GuardShapeImage"):setVisible(false)
    

    -- 1. 获取材料图标及数量
    self:setItem()

    -- 2. 清空完成度
    self:setComPercent(0, 0)
end

-- 设置守护强化的信息
function GuardStrengthDlg:setGuardStrengthInfo(guardId, isAction)
    if not isAction and guardId == self.guardId then return end
    if nil == guardId then return end
    local ctrl = self:getControl("StrengthButton")
    ctrl:setTouchEnabled(true)
    gf:resetImageView(ctrl)   
    
    self.guardId = guardId

    -- 获取本等级守护的信息
    local guardStrength = GuardMgr:getStrengthById(guardId)
    local guardStrengthPanelCtrl = self:getControl("BeforeValuePanel")
    self:setGuardStrengthPanel(guardStrength, guardStrengthPanelCtrl)
    
    -- 设置守护名字
    self:setLabelText("GuardNameLabel", guardStrength.name)
    
    self:updateLayout("GuardStrengthPanel")
    
    -- 设置守护图标
    local iconPath = ResMgr:getSmallPortrait(guardStrength.icon)
    self:setImage("GuardShapeImage", iconPath)
    self:setItemImageSize("GuardShapeImage", iconPath)
    self:getControl("GuardShapeImage"):setVisible(true)

    -- 获取下一等级守护的信息
    local guardNextStrength = GuardMgr:getNextStrengthById(guardId)
    local guardNextStrengthPanelCtrl = self:getControl("AfterValuePanel")
    self:setGuardStrengthPanel(guardNextStrength, guardNextStrengthPanelCtrl)
    
    

    -- 设置消耗材料信息及完成度
    -- 1. 获取材料图标及数量
    self:setItem()

    -- 2. 设置完成度
    self:setComPercent(guardStrength.complete, guardStrength.comCount, isAction, guardStrength.strengthlev)
end

-- 设置守护强化的面板属性
function GuardStrengthDlg:setGuardStrengthPanel(guardStrength, panelCtrl)
    if nil == guardStrength then return end

    -- 设置守护等级
    local lev = "Lv."..math.min(guardStrength.strengthlev, guardStrength.level)
    --self:setLabelText("StrengthLevelValueLabel", lev, panelCtrl)

    -- 设置守护属性
    -- 如果守护等级比本身等级高
    if guardStrength.strengthlev > guardStrength.level then
        self:setLabelText("PolarValueLabel", CHS[5000047], panelCtrl, COLOR3.RED)
        self:setLabelText("PowerValueLabel", CHS[5000047], panelCtrl, COLOR3.RED)
        self:setLabelText("ScoreValueLabel", CHS[5000047], panelCtrl, COLOR3.RED)
        self:setLabelText("StrengthLevelValueLabel", CHS[5000047], panelCtrl, COLOR3.RED)
    else
        if panelCtrl:getName() == "BeforeValuePanel" then
            self:setLabelText("StrengthLevelValueLabel", lev, panelCtrl, COLOR3.TEXT_DEFAULT)
            self:setLabelText("PolarValueLabel", guardStrength.polarNum, panelCtrl, COLOR3.TEXT_DEFAULT)
            self:setLabelText("PowerValueLabel", guardStrength.power, panelCtrl, COLOR3.TEXT_DEFAULT)
            self:setLabelText("ScoreValueLabel", guardStrength.grade, panelCtrl, COLOR3.TEXT_DEFAULT)
        else
            self:setLabelText("StrengthLevelValueLabel", lev, panelCtrl, COLOR3.GREEN)
            self:setLabelText("PolarValueLabel", guardStrength.polarNum, panelCtrl, COLOR3.GREEN)
            self:setLabelText("PowerValueLabel", guardStrength.power, panelCtrl, COLOR3.GREEN)
            self:setLabelText("ScoreValueLabel", guardStrength.grade, panelCtrl, COLOR3.GREEN)
        end
    end
end

-- 设置守护强化消耗的材料
function GuardStrengthDlg:setItem()
    local upItemIconPath = InventoryMgr:getIconFileByName(CHS[5000048])
    local upItemCount= InventoryMgr:getAmountByName(CHS[5000048])
    self:setImage("ItemImage", upItemIconPath)
    self:setItemImageSize("ItemImage", upItemIconPath)
    
    if upItemCount > 999 then
        upItemCount = "*"
    end
    
    if tonumber(upItemCount) and 0 >= upItemCount then
        self:setLabelText("OwnNumberLabel", upItemCount, nil, COLOR3.RED)
    else
        self:setLabelText("OwnNumberLabel", upItemCount, nil, COLOR3.TEXT_DEFAULT)
    end
end

-- 设置当前守护等级的强化百分比
function GuardStrengthDlg:setComPercent(complete, comCount, isAction, level)
    comCount = comCount or 0
    complete = complete or 0
    complete = math.min(complete, comCount)
    local pcStr = string.format("%d/%d", complete, comCount)
    
    if complete == 0 and comCount == 0 then
        pcStr = ""
    end
    
    if isAction then
        if complete == 0 then
            self:setLabelText("ProgressValueLabel", string.format("%d/%d", self.lastCount or comCount, self.lastCount or comCount), nil, COLOR3.TEXT_DEFAULT)
        end
    end
    
    local function setBarLabel()
        if level and level >= GuardMgr:getStrengthById(self.guardId).level then
            self:setLabelText("ProgressValueLabel", CHS[3002815], nil, COLOR3.RED)
            self:setProgressBar("ProgressBar", 1, 1)
        else
            self:setLabelText("ProgressValueLabel", pcStr, nil, COLOR3.TEXT_DEFAULT)
            self:setProgressBar("ProgressBar", complete, comCount)
        end
        
        self.isUpgradeCD = false
        self.lastCount = comCount
    end
    self:setProgressBar("ProgressBar", complete, comCount, nil, nil, isAction, setBarLabel)
end

function GuardStrengthDlg:MSG_GUARDS_REFRESH(data)
    if nil == self.guardId then return end

    self:setGuardStrengthInfo(self.guardId, true)
end

-- 设置元气丹的数量
function GuardStrengthDlg:MSG_INVENTORY( )
    self:setItem()
--    self.isUpgradeCD = false
end

-- 刷新守护下一级评分
function GuardStrengthDlg:refreshGuardNetLevelScore(guardId, score)
    if self.guardId ~= guardId then return end
    local guardNextStrengthPanelCtrl = self:getControl("AfterValuePanel")
    local guardNextStrength = GuardMgr:getNextStrengthById(guardId)
    
    if guardNextStrength.strengthlev <= guardNextStrength.level then
        self:setLabelText("ScoreValueLabel", score, guardNextStrengthPanelCtrl, COLOR3.GREEN)
    end
end

return GuardStrengthDlg
