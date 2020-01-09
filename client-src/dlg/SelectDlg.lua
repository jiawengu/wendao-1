-- SelectDlg.lua
-- Created by liuhb Oct/19/2015
-- 通天塔选择框

local SelectDlg = Singleton("SelectDlg", Dialog)

function SelectDlg:init()
    self:bindListener("TaoBonusButton", self.onTaoBonusButton, nil, true)
    self:bindListener("ExpBonusButton", self.onExpBonusButton, nil, true)
    self:bindListener("CancelButton", self.onCancelButton)
    self.source = nil
end

-- override
function SelectDlg:onCloseButton()
    gf:CmdToServer("CMD_SELECT_BONUS_RESULT", { source = self.source, select = "cancel" })
    Dialog.onCloseButton(self)
end

function SelectDlg:setData(tipStr, hourglassTime, source)
    if nil == tipStr then
        DlgMgr:closeDlg(self.name)
    end

    local panelCtrl = self:getControl("ContentPanel")
    self:setCtrlVisible("ContentLabel", false)

    -- 生成颜色字符串控件
    local tip = CGAColorTextList:create()
    tip:setFontSize(19)
    tip:setString(tipStr)
    tip:setContentSize(panelCtrl:getContentSize().width, 0)
    tip:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    tip:updateNow()
    local w, h = tip:getRealSize()
    tip:setContentSize(w, h)
    if panelCtrl then
        local colorLayer = tolua.cast(tip, "cc.LayerColor")
        panelCtrl:addChild(colorLayer)
        gf:align(colorLayer, panelCtrl:getContentSize(), ccui.RelativeAlign.centerInParent)
    end

    -- 小于70级的角色经验需要显示 "#R（推荐）#n"
    local expLabel = self:getControl("NameLabel", nil, "ExpBonusPanel")
    if Me:getLevel() >= Const.RECOMMEND_EXP_LEVEL then
        expLabel:setString(CHS[7100212])
    else
        expLabel:setString("")
        local panel = self:getControl("ExpBonusPanel", Const.UIPanel)
        local size = panel:getContentSize()
        local textCtrl = CGAColorTextList:create()
        textCtrl:setFontSize(17)
        textCtrl:setString(CHS[7100212] .. CHS[7100213])
        textCtrl:setContentSize(size.width, 0)
        textCtrl:setDefaultColor(COLOR3.WHITE.r, COLOR3.WHITE.g, COLOR3.WHITE.b)
        textCtrl:updateNow()

        local textW, textH = textCtrl:getRealSize()
        textCtrl:setPosition((size.width - textW) / 2, textH + 5)
        panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
    end

    -- 设置倒计时
    if nil ~= hourglassTime and 0 < hourglassTime then
        self:setHourglass(hourglassTime)
    end

    -- 设置来源
    self.source = source
end

function SelectDlg:setHourglass(hourglassTime)
    if not hourglassTime then return end
    
    self.hourglassTime = hourglassTime
    self:setLabelText("CountdownLabel", string.format(CHS[5400437], hourglassTime))
    self:stopSchedule(self.countDownSch)
    self.countDownSch = self:startSchedule(function() self:updateHourglass() end, 1)
end

function SelectDlg:updateHourglass()
    if self.hourglassTime > 0 then
        self.hourglassTime = self.hourglassTime - 1
        self:setLabelText("CountdownLabel", string.format(CHS[5400437], self.hourglassTime))
    else
        self:stopSchedule(self.countDownSch)
        self.countDownSch = nil
        self.hourglassTime = 0

        self:onCancelButton()
    end
end

function SelectDlg:onExpBonusButton(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        self:setCtrlVisible("ChoosingEffectPanel", true, sender:getParent())
    elseif eventType == ccui.TouchEventType.ended then
        gf:CmdToServer("CMD_SELECT_BONUS_RESULT", { source = self.source, select = "exp" })
        DlgMgr:closeDlg(self.name)
    elseif eventType == ccui.TouchEventType.canceled then
        self:setCtrlVisible("ChoosingEffectPanel", false, sender:getParent())
    end
end

function SelectDlg:onTaoBonusButton(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        self:setCtrlVisible("ChoosingEffectPanel", true, sender:getParent())
    elseif eventType == ccui.TouchEventType.ended then
        gf:CmdToServer("CMD_SELECT_BONUS_RESULT", { source = self.source, select = "tao" })
        DlgMgr:closeDlg(self.name)
    elseif eventType == ccui.TouchEventType.canceled then
        self:setCtrlVisible("ChoosingEffectPanel", false, sender:getParent())
    end
end

function SelectDlg:onCancelButton(sender, eventType)
    gf:CmdToServer("CMD_SELECT_BONUS_RESULT", { source = self.source, select = "cancel" })

    DlgMgr:closeDlg(self.name)
end

return SelectDlg
