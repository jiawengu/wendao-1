-- ConfirmDlg.lua
-- created by cheny Nov/29/2014
-- 确认框

local ConfirmDlg = Singleton("ConfirmDlg", Dialog)
local MARGIN = 30
local TAG_TIP = 100

local FONT_HIGHT = 26

function ConfirmDlg:init()
    -- 设置层次
    self.blank:setLocalZOrder(Const.ZORDER_DIALOG_CONFORM)

    -- 绑定事件
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("ConfirmButton2", self.onConfirmButton)
    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("CancelButton2", self.onCancelButton)
    self:bindListener("CloseButton", self.onCloseButton)

    self.inputField = self:createEditBox("Panel_19", "InputPanel")
    self.inputField:setPlaceholderFont(CHS[3003794], 20)
    self.inputField:setFont(CHS[3003794], 20)
    self.inputField:setFontColor(cc.c3b(0, 0, 0))
    self.inputField:setPlaceHolder(CHS[2000115])
    self.inputField:setPlaceholderFontColor(cc.c3b(102, 102, 102))

    self.backInitSize = self.backInitSize or self:getControl("ContentPanel"):getContentSize()
    self.backPanelSize = self.backPanelSize or self:getControl("BackPanel"):getContentSize()
    self.bkPanelSize = self.bkPanelSize or self:getControl("BKPanel"):getContentSize()

    self.image_1Size = self.image_1Size or self:getControl("Image_1"):getContentSize()
    self.image_2Size = self.image_2Size or self:getControl("Image_2"):getContentSize()

    self.showMode = CONFIRM_MODE.NORMAL
    self.hourglassTime = 0
    self.needClose = nil

    self.cancelButton2 = self:getControl("CancelButton2")
end

function ConfirmDlg:cleanup()
    self.showMode = nil
    self.needClose = nil
    self.countDownTips = nil
    self.confirm_type = nil
end

-- 设置层级
function ConfirmDlg:setGlobalZorder(zorder)
    self.blank:setLocalZOrder(Const.ZORDER_TOPMOST + 1)
    self.blank:setGlobalZOrder(Const.ZORDER_TOPMOST + 1)
    self:getControl("ConfirmButton"):setLocalZOrder(Const.ZORDER_TOPMOST + 1)
    self:getControl("ConfirmButton"):setGlobalZOrder(Const.ZORDER_TOPMOST + 1)
    self:getControl("CancelButton"):setLocalZOrder(Const.ZORDER_TOPMOST + 1)
    self:getControl("CancelButton"):setGlobalZOrder(Const.ZORDER_TOPMOST + 1)
    self:getControl("CancelButton2"):setLocalZOrder(Const.ZORDER_TOPMOST + 1)
    self:getControl("CancelButton2"):setGlobalZOrder(Const.ZORDER_TOPMOST + 1)
    self:getControl("CloseButton"):setLocalZOrder(Const.ZORDER_TOPMOST + 1)
    self:getControl("CloseButton"):setGlobalZOrder(Const.ZORDER_TOPMOST + 1)
end

-- 设置确认按钮文本
function ConfirmDlg:setConfirmLabel(text)
    self:setLabelText("Label_1", text, "ConfirmButton")
    self:setLabelText("Label_2", text, "ConfirmButton")
end

-- 设置取消按钮文本
function ConfirmDlg:setCancelLabel(text)
    self:setLabelText("Label_1", text, "CancelButton")
    self:setLabelText("Label_2", text, "CancelButton")
end

function ConfirmDlg:setCombatOpenType()
    self.showMode = CONFIRM_MODE.IN_COMBAT
end

function ConfirmDlg:setNormalOpenType()
    self.showMode = CONFIRM_MODE.NORMAL
end

function ConfirmDlg:setCombatAlwaysOpenType()
    self.showMode = CONFIRM_MODE.ALWAYS_SHOW_IN_COMBAT
end

function ConfirmDlg:getDlgMode()
    return self.showMode
end

function ConfirmDlg:setDlgMode(showMode)
    self.showMode = showMode or CONFIRM_MODE.NORMAL
end

function ConfirmDlg:setEnterCombatIsNeedClose(needClose)
    self.needClose = needClose
end

function ConfirmDlg:getEnterCombatIsNeedClose()
    if self.needClose then
        return true
    end
end

function ConfirmDlg:needAutoCancelWhenEnterCombat()
    if self.showMode ~= CONFIRM_MODE.ALWAYS_SHOW then
        return true
    end
end

-- 是否仅在战斗中显示
function ConfirmDlg:isFightDlg()
    if self.showMode == CONFIRM_MODE.ALWAYS_SHOW_IN_COMBAT or
       self.showMode == CONFIRM_MODE.IN_COMBAT then
        return true
    end
end

-- 回合结束时需关闭界面
function ConfirmDlg:needCloseWhenRoundOver()
    if self.showMode == CONFIRM_MODE.IN_COMBAT then
        return true
    end
end

-- 换线时调用
function ConfirmDlg:onSwitchServer()
    if self.confirm_type == "accept_count_down" then
        DlgMgr:closeDlg(self.name)
    end
end

function ConfirmDlg:onConfirmButton()
    if self.confirm_type == "tick_confirm_not_auto" and self.hourglassTime > 0 then
        -- 倒计时结束之后才能确认的确认框，当前倒计时未结束，不能确认
        if not string.isNilOrEmpty(self.countDownTips) then
            -- 有倒计时期间点击的提示
            gf:ShowSmallTips(self.countDownTips)
        end

        return
    end

    local input = self.inputField:getText()
    DlgMgr:closeDlg("ConfirmDlg")
    if self.onConfirm ~= nil and type(self.onConfirm) == "function" then
        self.onConfirm(input)
    end
end

function ConfirmDlg:onCancelButton()
    local input = self.inputField:getText()
    DlgMgr:closeDlg("ConfirmDlg")
    if self.onCancel ~= nil and type(self.onCancel) == "function" then
        self.onCancel(input)
    end
    DlgMgr:preventDlg()
end

function ConfirmDlg:onCloseButton()

    if self.confirm_type == "AnniversaryPetAdventureDlgStartGame" then
        DlgMgr:closeDlg("ConfirmDlg")
        return
    end

    local input = self.inputField:getText()
    DlgMgr:closeDlg("ConfirmDlg")

    if self.onCancel ~= nil and type(self.onCancel) == "function" then
        self.onCancel(input, true)
    end

    DlgMgr:preventDlg()
end

function ConfirmDlg:setConfirmText(strTip)
    if not strTip then
        self:setLabelText("Label_1", CHS[3002360], "ConfirmButton")
        self:setLabelText("Label_2", CHS[3002360], "ConfirmButton")
    else
        self:setLabelText("Label_1", strTip, "ConfirmButton")
        self:setLabelText("Label_2", strTip, "ConfirmButton")
    end
end

function ConfirmDlg:setCancleText(strTip)
    if not strTip then
        self:setLabelText("Label_1", CHS[3002361], "CancelButton")
        self:setLabelText("Label_2", CHS[3002361], "CancelButton")
    else
        self:setLabelText("Label_1", strTip, "CancelButton")
        self:setLabelText("Label_2", strTip, "CancelButton")
    end
end

function ConfirmDlg:setTip(str)
    local back = self:getControl("ContentPanel")
    local size = self.backInitSize
    local tip = back:getChildByTag(TAG_TIP)
    if tip then
        back:removeAllChildren()
        tip = nil
    end

    -- 生成颜色字符串控件
    if tip == nil then
        tip = CGAColorTextList:create()
        tip:setFontSize(20)
        tip:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
        tip:setContentSize(size.width, 0)
        self.tip = tip
    end

    local tipLayer = tolua.cast(tip, "cc.LayerColor")
    back:addChild(tipLayer, 0, TAG_TIP)

    tip:setString(str or "")
    tip:updateNow()
    self:setConfirmText()
    self:setCancleText()
    --[[
    local w, h = tip:getRealSize()
    --back:setContentSize(size.width, size.height - h - MARGIN)
    tip:setPosition(0, h)
    --]]

    -- 如果高度大于原始高度，需要自适应
    local w, h = tip:getRealSize()
    if math.floor(h / FONT_HIGHT) > 2 then
        local disH = (math.floor(h / FONT_HIGHT) - 2) * 20
        back:setContentSize(self.backInitSize.width, self.backInitSize.height + disH)

        self:setCtrlContentSize("BackPanel", nil, self.backPanelSize.height + disH)
        self:setCtrlContentSize("BKPanel", nil, self.bkPanelSize.height + disH)

        self:setCtrlContentSize("Image_1", nil, self.image_1Size.height + disH)
        self:setCtrlContentSize("Image_2", nil, self.image_2Size.height + disH)
    else
        back:setContentSize(self.backInitSize)
        self:setCtrlContentSize("BackPanel", self.backPanelSize.width, self.backPanelSize.height)
        self:setCtrlContentSize("BKPanel", self.bkPanelSize.width, self.bkPanelSize.height)
        self:setCtrlContentSize("Image_1", nil, self.image_1Size.height)
        self:setCtrlContentSize("Image_2", nil, self.image_2Size.height)
    end

    back:getParent():requestDoLayout()
    self.root:requestDoLayout()
end

function ConfirmDlg:setConfirmType(type)
    self.confirm_type = type

    if type == "tick_confirm_not_auto" then
        -- 倒计时结束之后才能确认的确认框 需要隐藏"X"按钮
        self:setCtrlVisible("CloseButton", false)

        -- 倒计时结束之后才能确认的确认框，需要倒计时按钮居中
        local panelSize = self:getControl("ButtonPanel"):getContentSize()
        self:getControl("ConfirmButton2"):setPositionX(panelSize.width / 2)
    end
end

function ConfirmDlg:setCloseButtonVisible(enable)
    self:setCtrlVisible("CloseButton", enable)
end

function ConfirmDlg:setOnlyConfirm()
    local cancelButton = self:getControl("CancelButton")
    local cancelButton2 = self:getControl("CancelButton2")
    local confirmButton = self:getControl("ConfirmButton")
    local confirmButton2 = self:getControl("ConfirmButton2")
    cancelButton:setVisible(false)
    cancelButton2:setVisible(false)
    if self.confirm_type == "tick_confirm_not_auto" then
        confirmButton:setVisible(false)
        confirmButton2:setVisible(true)
    else
        confirmButton:setVisible(true)
        confirmButton2:setVisible(false)
    end

    local panelSize = self:getControl("ButtonPanel"):getContentSize()
    confirmButton:setPositionX(panelSize.width / 2)
end

function ConfirmDlg:updateLayout()
    if self.tip == nil then return end
    local back = self:getControl("ContentPanel")
    local size = self.backInitSize
    local w, h = self.tip:getRealSize()
    local inputPanel = self:getControl("InputPanel")

    if not self.input then
        -- 没有输入，扣除输入框的位置
        inputPanel:setVisible(false)
        self.tip:setPosition((size.width - w) / 2, back:getContentSize().height- (back:getContentSize().height - h) / 2)

    else
        inputPanel:setVisible(true)
        self.tip:setPosition(0, back:getContentSize().height)
    end

    self:getControl("BackPanel"):requestDoLayout()
end

function ConfirmDlg:setInput(need)
    self.input = need
end

function ConfirmDlg:setMaxLen(len)
    local input = self:getControl("InputTextField", Const.UITextField)
    input:setMaxLengthEnabled(true)
    input:setMaxLength(len)
end

function ConfirmDlg:setPassword(isPassword)
    local input = self:getControl("InputTextField", Const.UITextField)
    input:setPasswordEnabled(isPassword)
end

function ConfirmDlg:setDefaultInput(text)
    self:setInputText("InputTextField", text)
end

function ConfirmDlg:setMinLen(max)
----todo
end

function ConfirmDlg:setMax(max)
----todo
end

function ConfirmDlg:setNumberOnly(isNumber)
----todo
end

function ConfirmDlg:getHourglass()
    return self.hourglassTime or 0
end

function ConfirmDlg:setHourglass(hourglassTime)
    if not hourglassTime then
        self:setHourglassCommon("ConfirmButton", nil)
        self:setHourglassCommon("CancelButton", nil)
        return
    end

    if self.confirm_type == "confirm_leave_zhanchang"
        or self.confirm_type == "csc_arrive_auto_match"
        or self.confirm_type == "accept_count_down"
        or self.confirm_type == "tick_confirm_not_auto" then
        self:setHourglassCommon("ConfirmButton", hourglassTime)
        self:setDownCountVisible("CancelButton", false)
    else
        self:setHourglassCommon("CancelButton", hourglassTime)
        self:setDownCountVisible("ConfirmButton", false)
    end
end

function ConfirmDlg:setDownCountVisible(ctrlName, visible)
        self:setCtrlVisible(ctrlName, not visible)
        self:setCtrlVisible(ctrlName .. "2", visible)
end

function ConfirmDlg:setCountDownTips(countDownTips)
    self.countDownTips = countDownTips
end

function ConfirmDlg:setHourglassCommon(ctrlName, hourglassTime)
    if not hourglassTime then
        -- 取消倒计时
        self:setDownCountVisible(ctrlName, false)
        local btn = self:getControl(ctrlName .. "2")
        btn:stopAllActions()
        self:setLabelText("TimeLabel", "", btn)
        self:setLabelText("Time2Label", "", btn)

        self.hourglassTime = 0
        return
    end

    self:setDownCountVisible(ctrlName, true)

    self.hourglassTime = hourglassTime
    local btn = self:getControl(ctrlName .. "2")
    self:setLabelText("TimeLabel", "(" .. self.hourglassTime .. ")", btn)
    self:setLabelText("Time2Label", "(" .. self.hourglassTime .. ")", btn)

    if self.cancelButton2 then
        self.cancelButton2:stopAllActions()
        schedule(self.cancelButton2, function() self:updateHourglass(ctrlName .. "2") end, 1)
    end
end

function ConfirmDlg:updateHourglass(ctrlName)
    if self.hourglassTime > 1 or (self.confirm_type ~= "tick_confirm_not_auto"
        and self.hourglassTime > 0) then
        -- 非tick_confirm_not_auto 类型的确认框需要倒计时为0才停止

        self.hourglassTime = self.hourglassTime - 1
        self:setLabelText("TimeLabel", "(" .. self.hourglassTime .. ")", ctrlName)
        self:setLabelText("Time2Label", "(" .. self.hourglassTime .. ")", ctrlName)
    else
        if self.cancelButton2 then
            self.cancelButton2:stopAllActions()
        end
        self.hourglassTime = 0

        if self.confirm_type == "tick_confirm_not_auto" then
            -- 倒计时结束之后才能确认的确认框，倒计时结束后需要玩家自己点确认
            self:setCtrlVisible("ConfirmButton", true)
            self:setCtrlVisible("ConfirmButton" .. "2", false)
            return
        end

        if ctrlName == "ConfirmButton2" then
            self:onConfirmButton()
        else
            self:onCancelButton()
        end
    end
end

return ConfirmDlg
