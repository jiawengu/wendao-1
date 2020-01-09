-- SystemAccManageDlg.lua
-- Created by zhengjh Mar/18/2016
-- 管理界面

local SystemAccManageDlg = Singleton("SystemAccManageDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

--认证类型（首次认证：1，再次认证：2，更换手机第一次认证：3，更换手机第二次认证：4，身份认证：5）
local VERIFY_TYPE = {
    VERIFY          = 1,
    REVERIFY        = 2,
    VERIFY_CHANGE   = 3,
    REVERIFY_CHANGE = 4,
    NAME_VERIFY     = 5,
}

local VERIFY_CODE_RESEND_INTERVAL = 120

function SystemAccManageDlg:init()
    self:bindListener("LockButton_1", self.onLockButton, "OfficialChannelButtonPanel")
    self:bindListener("LockButton2", self.onLockButton, "OtherChannelButtonPanel")
    self:bindListener("LockButton3", self.onLockButton, "YingybOPPOChannelButtonPanel")
    self:bindListener("DelCharButton", self.onDelCharButton, "OfficialChannelButtonPanel")
    self:bindListener("DelCharButton", self.onDelCharButton, "OtherChannelButtonPanel")
    self:bindListener("DelCharButton", self.onDelCharButton, "YingybOPPOChannelButtonPanel")
    self:bindListener("ServiceButton", self.onServiceButton, "OfficialChannelButtonPanel")
    self:bindListener("TribuneButton", self.onTribuneButton, "YingybOPPOChannelButtonPanel")
    self:bindListener("ExitGameButton", self.onExitGameButton, "OfficialChannelButtonPanel")
    self:bindListener("ExitGameButton", self.onExitGameButton, "OtherChannelButtonPanel")
    self:bindListener("ExitGameButton", self.onExitGameButton, "YingybOPPOChannelButtonPanel")


    self.isSpecialChannel = LeitingSdkMgr:isSpecialRealNameChannel()

    self:bindListener("ContentPanel_3", function (self, sender )
        if sender.textNode then
            gf:onCGAColorText(sender.textNode, nil, nil, true)
        end
    end, "OfficialChannelPanel")


    self:bindListener("ContentPanel_4", function (self, sender )
        if sender.textNode then
            gf:onCGAColorText(sender.textNode, nil, nil, true)
        end
    end, "OfficialChannelPanel")

    self.officalPanel = self:getControl("OfficalChannelPanel", Const.UIPanel)
    self.otherPanel = self:getControl("OtherChannelPanel", Const.UIPanel)

    if not self.isSpecialChannel then
        self.officalPanel = self:getControl("OfficialChannelPanel", Const.UIPanel)
        self.officePhonePanel = self:getControl("AuthenticatePhonePanel", Const.UIPanel, self.officalPanel)
        self.officeRealNamePanel = self:getControl("AuthenticateRealNamePanel", Const.UIPanel, self.officalPanel)
    else
        self.officalPanel = self:getControl("OtherOfficialChannelPanel", Const.UIPanel)
        self.officePhonePanel = self:getControl("AuthenticatePhonePanel", Const.UIPanel, "OfficialChannelPanel")
        self.officePhonePanel:setVisible(false)
        self.officeRealNamePanel = self:getControl("AuthenticateRealNamePanel", Const.UIPanel, self.officalPanel)
        self.officeRealNamePanel:setVisible(true)
    end

    self.relatedPanel = self:getControl("AuthenticatePanel", Const.UIPanel, self.officePhonePanel)
    self:bindEditField("InputPanel", 11, self.relatedPanel)
    self:bindEditField("InputPanel", 6, self:getControl("VerifyCodePanel", nil, self.relatedPanel))
    self:bindListener("SendVerifyCodeButton_1", self.onSendVerifyCodeButton_1, self.relatedPanel)
    self:setCtrlEnabled("SendVerifyCodeButton_2", false, self.relatedPanel)
    self:bindListener("RelatedPhoneButton", self.onRelatePhoneButton, self.relatedPanel)
    self.afterRelatedPanel = self:getControl("AfterAuthenticatedPanel", Const.UIPanel, self.officePhonePanel)

    self.relatedPhoneAgainPanelInARP = self:getControl("AuthenticateAgainPanel", nil, self.afterRelatedPanel)
    self:bindEditField("InputPanel", 11, self:getControl("PhoneCodePanel", nil, self.relatedPhoneAgainPanelInARP))
    self:bindEditField("InputPanel", 6, self:getControl("VerifyCodePanel", nil, self.relatedPhoneAgainPanelInARP))
    self:bindListener("AuthenticateAgainButton", self.onRelatePhoneButton, self.relatedPhoneAgainPanelInARP)
    self:bindListener("SendVerifyCodeButton_1", self.onSendVerifyCodeButton_2, self.relatedPhoneAgainPanelInARP)
    self:setCtrlEnabled("SendVerifyCodeButton_2", false, self.relatedPhoneAgainPanelInARP)
    self:bindListener("ChangePhoneButton", self.onRelatePhoneButton, self.relatedPhoneAgainPanelInARP)
    self.changePhonePanel = self:getControl("ChangePhonePanel", nil, self.afterRelatedPanel)
    self:bindEditField("InputPanel", 11, self:getControl("PhoneCodePanel", nil, self.changePhonePanel))
    self:bindEditField("InputPanel", 6, self:getControl("VerifyCodePanel", nil, self.changePhonePanel))
    self:bindListener("ChangePhoneButton", self.onRelatePhoneButton, self.changePhonePanel)
    self:bindListener("SendVerifyCodeButton_1", self.onSendVerifyCodeButton_4, self.changePhonePanel)
    self:setCtrlEnabled("SendVerifyCodeButton_2", false, self.changePhonePanel)

    -- 实名认证部分
    self.authenticatNamePanel = self:getControl("AuthenticatePanel", Const.UIPanel, self.officeRealNamePanel)
    self.afterAuthenticateNamePanel = self:getControl("AfterAuthenticatedPanel", Const.UIPanel, self.officeRealNamePanel)
    self:setCtrlVisible("DelButton", false, self:getControl("NamePanel", Const.UIPanel, self.authenticatNamePanel))
    self:bindListener("DelButton", self.onDelNameButton, self:getControl("NamePanel", Const.UIPanel, self.authenticatNamePanel))
    self.newNameEdit = self:createEditBox("InputPanel", self:getControl("NamePanel", Const.UIPanel, self.authenticatNamePanel), nil, function(sender, type)
            if type == "end" then
            elseif type == "changed" then
                local newName = self.newNameEdit:getText()
                if gf:getTextLength(newName) > 18 then
                    newName = gf:subString(newName, 18)
                    self.newNameEdit:setText(newName)
                    gf:ShowSmallTips(CHS[5400041])
                end

            self:setCtrlVisible("DelButton", #newName > 0, self:getControl("NamePanel", Const.UIPanel, self.authenticatNamePanel))
            end
    end)
    self.newNameEdit:setFont(CHS[3002184], 23)
    self.newNameEdit:setFontColor(COLOR3.TEXT_DEFAULT)
    self.newNameEdit:setPlaceholderFont(CHS[3002184], 23)
    self.newNameEdit:setPlaceHolder(CHS[2000170])
    self.newNameEdit:setPlaceholderFontColor(COLOR3.GRAY)
    self:setCtrlVisible("DefaultLabel", false, self:getControl("NamePanel", Const.UIPanel, self.authenticatNamePanel))
    self:setCtrlVisible("DelButton", false, self:getControl("IdentityCardCodePanel", Const.UIPanel, self.authenticatNamePanel))
    self:bindListener("DelButton", self.onDelIdButton, self:getControl("IdentityCardCodePanel", Const.UIPanel, self.authenticatNamePanel))
    self.newIdEdit = self:createEditBox("InputPanel", self:getControl("IdentityCardCodePanel", Const.UIPanel, self.authenticatNamePanel), nil, function(sender, type)
            if type == "end" then
            elseif type == "changed" then
                local newId = self.newIdEdit:getText()
                if gf:getTextLength(newId) > 18 then
                    newId = gf:subString(newId, 18)
                    self.newIdEdit:setText(newId)
                    gf:ShowSmallTips(CHS[5400041])
                end

            self:setCtrlVisible("DelButton", #newId > 0, self:getControl("IdentityCardCodePanel", Const.UIPanel, self.authenticatNamePanel))
            end
    end)
    self.newIdEdit:setFont(CHS[3002184], 23)
    self.newIdEdit:setFontColor(COLOR3.TEXT_DEFAULT)
    self.newIdEdit:setPlaceholderFont(CHS[3002184], 23)
    self.newIdEdit:setPlaceHolder(CHS[2000171])
    self.newIdEdit:setPlaceholderFontColor(COLOR3.GRAY)
    self:setCtrlVisible("DefaultLabel", false, self:getControl("IdentityCardCodePanel", Const.UIPanel, self.authenticatNamePanel))
    self:bindEditField("InputPanel", 18, self:getControl("IdentityCardCodePanel", Const.UIPanel, self.authenticatNamePanel))
    self:bindEditField("InputPanel", 6, self:getControl("VerifyCodePanel", nil, self.authenticatNamePanel))
    self:bindListener("SendVerifyCodeButton_1", self.onSendVerifyCodeButton_5, self:getControl("VerifyCodePanel", nil, self.authenticatNamePanel))
    self:setCtrlVisible("SendVerifyCodeButton_1", true, self:getControl("VerifyCodePanel", Const.UIPanel, self.authenticatNamePanel))
    self:setCtrlVisible("SendVerifyCodeButton_2", false, self:getControl("VerifyCodePanel", Const.UIPanel, self.authenticatNamePanel))
    self:setCtrlEnabled("SendVerifyCodeButton_2", false, self:getControl("VerifyCodePanel", Const.UIPanel, self.authenticatNamePanel))
    self:bindListener("AuthenticateRealNameButton", self.onAuthenticateRealNameButton, self.authenticatNamePanel)

    -- 是否官方渠道
    self.leftTimeSchedulId = nil
    self.lastSendRelateCmdTime = 0
    self.isOfficial = LeitingSdkMgr:isLeiting()
    self.isOverseas = LeitingSdkMgr:isOverseas()
    self.isYyb = LeitingSdkMgr:isYYB() and gf:gfIsFuncEnabled(FUNCTION_ID.YYB_SDK_BBS) and LeitingSdkMgr:isYybBBSEnabled()
    self.isOppo = LeitingSdkMgr:isOPPO() and gf:gfIsFuncEnabled(FUNCTION_ID.OPPO_SDK_BBS) and LeitingSdkMgr:isOppoBBSEnabled()
    -- self.isOfficial = true
    -- self.isOverseas = true

    self.offContentPanel_3Size = self:getCtrlContentSize("ContentPanel_3", "OfficialChannelPanel")


    self:setCtrlVisible("OfficialChannelButtonPanel", self.isOfficial or self.isOverseas, "CharInfoPanel")
    self:setCtrlVisible("OtherChannelButtonPanel", not self.isOfficial and not self.isOverseas and not self.isYyb and not self.isOppo, "CharInfoPanel")
    self:setCtrlVisible("YingybOPPOChannelButtonPanel", self.isYyb or self.isOppo, "CharInfoPanel")
    local tribuneButton = self:getControl("TribuneButton", nil, self:getControl("YingybOPPOChannelButtonPanel", nil, "CharInfoPanel"))
    self:setCtrlVisible("Image_1", self.isYyb, tribuneButton)
    self:setCtrlVisible("Image_2", self.isOppo, tribuneButton)
    self:setCtrlVisible("OfficialChannelPanel", self.isOfficial)
    self:setCtrlVisible("OtherOfficialChannelPanel", self.isSpecialChannel)
    self:setCtrlVisible("OtherChannelPanel", not self.isOfficial and not self.isSpecialChannel)

    self.phoneRadioGroup = RadioGroup.new()
    self.phoneRadioGroup:setItems(self, {"AuthenticateAgainCheckBox", "ChangePhoneCheckBox"}, self.onSwitchRadio, self.afterRelatedPanel)

    if not self.isSpecialChannel then
        self.radioGroup = RadioGroup.new()
        self.radioGroup:setItems(self, {"AuthenticatePhoneCheckBox", "AuthenticateRealNameCheckBox"}, self.onSwitchPanel, self.officalPanel)
        self.radioGroup:selectRadio(1)
    end

    if self.isOfficial then
        self:initOfficialPanel()
    elseif self.isSpecialChannel then
        self.afterRelatedPanel:setVisible(false)
        self.changePhonePanel:setVisible(false)
        self:initOfficalRealNamePanel()
    else
        self:initOtherChannelPanel()
    end

    self:initData()

    self:hookMsg("MSG_ASK_CLIENT_SECRET")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_PHONE_VERIFY_CODE")
    self:hookMsg("MSG_CHECK_OLD_PHONENUM_SUCC")
    self:hookMsg("MSG_FUZZY_IDENTITY")

    gf:CmdToServer('CMD_REQUEST_FUZZY_IDENTITY', {force_request = 0})

end

function SystemAccManageDlg:cleanup()
    self:stopSchedule()
    self.lastSelectPanel = nil
    self.isOfficial = nil
    self.isOverseas = nil
end

function SystemAccManageDlg:stopSchedule()
    if tonumber(self.leftTimeSchedulId) then
        gf:Unschedule(self.leftTimeSchedulId)
        self.leftTimeSchedulId = nil
    end
end

function SystemAccManageDlg:initData()
    self:setLabelText("NameLabel_2", Me:getShowName())
    self:setLabelText("LevelLabel", Me:queryBasic("level") .. CHS[3003672])
    self:setLabelText("IDLabel_2", gf:getShowId(Me:queryBasic("gid")))
    self:setLabelText("DistLabel_2", Client:getWantLoginDistName())
    self:setImage("PlayerImage", ResMgr:getSmallPortrait(Me:queryBasicInt("org_icon")))
    self:setItemImageSize("PlayerImage")
    self:MSG_UPDATE()
end

function SystemAccManageDlg:initOfficialPanel()
    if not self.isSpecialChannel then
        if not Me.bindData or not Me.bindData.isBindPhone then
            -- 未绑定手机
            self:setCtrlVisible("AuthenticatePanel", true, self.officePhonePanel)
            self:setCtrlVisible("AfterAuthenticatedPanel", false, self.officePhonePanel)
            self:setCtrlVisible("SendVerifyCodeButton_1", true, self:getControl("AuthenticatePanel", Const.UIPanel, self.relatedPanel))
            self:setCtrlVisible("SendVerifyCodeButton_2", false, self:getControl("AuthenticatePanel", Const.UIPanel, self.relatedPanel))
            -- self:setLabelText("NoteLabel", CHS[2000178], self.relatedPanel)
            self:setColorText(CHS[2000178], "NotePanel", self.relatedPanel, 0, 0)
        else
            -- 已绑定手机
            self:setCtrlVisible("AuthenticatePanel", false, self.officePhonePanel)
            self:setCtrlVisible("AfterAuthenticatedPanel", true, self.officePhonePanel)
            self:setCtrlVisible("SendVerifyCodeButton_1", true, self.relatedPhoneAgainPanelInARP)
            self:setCtrlVisible("SendVerifyCodeButton_2", false, self.relatedPhoneAgainPanelInARP)
            self.phoneRadioGroup:selectRadio(1)
        end
    end

    self:stopSchedule()

    --富文本框
    self:setColorText(CHS[2000099], "ContentPanel_1", self.officalPanel, 0, 0)
    self:setColorText(CHS[2000100], "ContentPanel_2", self.officalPanel, 0, 0)
    self:setColorText(CHS[2000101], "ContentPanel_3", self.officalPanel, 0, 0)


    self:setCtrlContentSize("ContentPanel_3", self.offContentPanel_3Size.width, self.offContentPanel_3Size.height, "OfficialChannelPanel")

    self:setCtrlVisible("NumLabel_4", false, self.officalPanel)
    self:setCtrlVisible("ContentPanel_4", false, self.officalPanel)

    self:setCtrlVisible("AuthenticateAgainCheckBox", true, self.afterRelatedPanel)
    self:setCtrlVisible("ChangePhoneCheckBox", true, self.afterRelatedPanel)
end

function SystemAccManageDlg:initOtherChannelPanel()
    self:setColorText(CHS[2000087], "ContentPanel_1", "OtherChannelPanel", 0, 0)
    self:setColorText(CHS[2000088], "ContentPanel_2", "OtherChannelPanel", 0, 0)
    self:setColorText(CHS[2000089], "ContentPanel_3", "OtherChannelPanel", 0, 0)
    self:setColorText(CHS[2000090], "ContentPanel_4", "OtherChannelPanel", 0, 0)

    self:stopSchedule()
end

function SystemAccManageDlg:initOfficalRealNamePanel()
    if Me.bindData and Me.bindData.isBindName then
        -- 已实名认证
        self.authenticatNamePanel:setVisible(false)
        self.afterAuthenticateNamePanel:setVisible(true)

        self:setLabelText("NameLabel", Me.bindData.bindName, self:getControl("NamePanel", Const.UIPanel, self.afterAuthenticateNamePanel))
        self:setLabelText("IdentityCardCodeLabel", Me.bindData.bindId, self:getControl("IdentityCardCodePanel", Const.UIPanel, self.afterAuthenticateNamePanel))
    else
        -- 未实名认证
        self.authenticatNamePanel:setVisible(true)
        self.afterAuthenticateNamePanel:setVisible(false)
        self:setColorText(CHS[2000177], "NotePanel", self.authenticatNamePanel, 0, 0)
        self:setCtrlVisible("SendVerifyCodeButton_1", true, self:getControl("VerifyCodePanel", Const.UIPanel, self.authenticatNamePanel))
        self:setCtrlVisible("SendVerifyCodeButton_2", false, self:getControl("VerifyCodePanel", Const.UIPanel, self.authenticatNamePanel))
    end

    self:stopSchedule()

    --富文本框
    self:setColorText(CHS[2000168], "ContentPanel_2", self.officalPanel, 0, 0)
    self:setColorText(CHS[5120011], "ContentPanel_3", self.officalPanel, 0, 0)

    self:setCtrlContentSize("ContentPanel_3", self.offContentPanel_3Size.width, self.offContentPanel_3Size.height, "OfficialChannelPanel")


    if not self.isSpecialChannel then
        self:setColorText(CHS[2000167], "ContentPanel_1", self.officalPanel, 0, 0)

        if Me.antiaddictionData and Me.antiaddictionData["switch5"] == 1 then
            self:setColorText(CHS[5120012], "ContentPanel_4", self.officalPanel, 0, 0)
            self:setCtrlVisible("NumLabel_4", true, self.officalPanel)
            self:setCtrlVisible("ContentPanel_4", true, self.officalPanel)
        else
            self:setColorText(CHS[2000169], "ContentPanel_4", self.officalPanel, 0, 0)
            self:setCtrlVisible("NumLabel_4", true, self.officalPanel)
            self:setCtrlVisible("ContentPanel_4", true, self.officalPanel)
        end
    else
        self:setColorText(CHS[5430029], "ContentPanel_1", self.officalPanel, 0, 0)

        local time = gf:getTimeByServerZone({year = 2019, month = 06, day = 13, hour = 05, min = 00, sec = 00})
        if Me.antiaddictionData and Me.antiaddictionData["switch5"] == 1 and gf:getServerTime() > time then
            self:setColorText(CHS[5420360], "ContentPanel_4", self.officalPanel, 0, 0)
            self:setCtrlVisible("NumLabel_4", true, self.officalPanel)
            self:setCtrlVisible("ContentPanel_4", true, self.officalPanel)
        else
            self:setCtrlVisible("NumLabel_4", false, self.officalPanel)
            self:setCtrlVisible("ContentPanel_4", false, self.officalPanel)
        end
    end
end

function SystemAccManageDlg:bindEditField(textFieldName, lenLimit, root)
    local inputPanel = self:getControl(textFieldName, nil, root)
    self:bindNumInput(textFieldName, root, nil, { root = root, panel = inputPanel, lenLimit = lenLimit }, true)

    -- 绑定一下清除按钮
    local cleanButton = self:getControl("DelAllButton", nil, root)
    if cleanButton then
        cleanButton:setVisible(false)
        local function func()
            cleanButton:setVisible(false)
            self:setCtrlVisible("DefaultLabel", true, root)
            self:setPanelValue(inputPanel, "")
            if self.panelNum and self.panelNum[root] then
                self.panelNum[root] = nil
            end
        end

        self:bindTouchEndEventListener(cleanButton, func)
    end
end

function SystemAccManageDlg:clearInput()
    self.panelNum = nil
    local phoneCodePanel = self:getControl("PhoneCodePanel", nil, "AuthenticateAgainPanel")
    local verifyCodePanel = self:getControl("VerifyCodePanel", nil, "AuthenticateAgainPanel")
    self:setCtrlVisible("DefaultLabel", true, phoneCodePanel)
    self:setCtrlVisible("DelAllButton", false, phoneCodePanel)
    self:setCtrlVisible("DefaultLabel", true, verifyCodePanel)
    self:setCtrlVisible("DelAllButton", false, verifyCodePanel)
end

function SystemAccManageDlg:doWhenOpenNumInput(ctrlName, root)
    -- 记忆上一次打开该对话框时输入的数值
    if self.panelNum and self.panelNum[root] then
        local num = self.panelNum[root]
        self:setPanelValue(self:getControl(ctrlName, nil, root), num)

        -- 更新键盘数据
        local dlg = DlgMgr:getDlgByName("SmallNumInputDlg")
        if dlg then
            dlg:setInputValue(num)
        end
    end
end

function SystemAccManageDlg:refreshLeftSendTime(root, lastSendTime)
    local btnCtrl = self:getControl("SendVerifyCodeButton_2", nil, root)
    local time1 = self:getControl("TimeLabel_1", nil, btnCtrl)
    local time2 = self:getControl("TimeLabel_2", nil, btnCtrl)
    local elapse = 0
    local timeDesc = string.format("%d%s", VERIFY_CODE_RESEND_INTERVAL - elapse, CHS[2000086])
    time1:setText(timeDesc)
    time2:setText(timeDesc)

    self:stopSchedule()
    self.leftTimeSchedulId = gf:Schedule(function()
        elapse = math.max(0, gf:getServerTime() - lastSendTime)
        if elapse < VERIFY_CODE_RESEND_INTERVAL then
            local timeDesc = string.format("%d%s", VERIFY_CODE_RESEND_INTERVAL - elapse, CHS[2000086])
            time1:setText(timeDesc)
            time2:setText(timeDesc)
        else
            self:stopSchedule()
            self:setCtrlVisible("SendVerifyCodeButton_1", true, root)
            self:setCtrlVisible("SendVerifyCodeButton_2", false, root)
        end
    end, 1)
end

function SystemAccManageDlg:retainVerifyCode(verifyType, phone)
    if not DistMgr:checkCrossDist() then return end

    Log:D(string.format("Retain verifyCode, type: %s, phone:%s", verifyType, tostring(phone)))

    gf:CmdToServer("CMD_PHONE_VERIFY_CODE", { type = verifyType, phone = phone or "" })
    return true
end

function SystemAccManageDlg:isValidPhoneNum(phone)
    if 11 == string.len(phone) then
        return true
    end

    return false
end

function SystemAccManageDlg:getPanelValue(panel)
    local label = self:getControl("InputLabel", nil, panel)
    return label:getStringValue()
end

function SystemAccManageDlg:setPanelValue(panel, value)
    local label = self:getControl("InputLabel", nil, panel)
    return label:setString(value)
end

function SystemAccManageDlg:insertNumber(num, key)
    Log:D("insertNum, num:" .. num)

    local panel = key.panel
    local root = key.root
    local lenLimit = key.lenLimit
    if num == 0 or num == "" then
        self:setCtrlVisible("DefaultLabel", true, root)
        self:setCtrlVisible("DelAllButton", false, root)
    else
    self:setCtrlVisible("DefaultLabel", false, root)
        self:setCtrlVisible("DelAllButton", true, root)
    end

    local str = tostring(num)
    if gf:getTextLength(str) > lenLimit then
        gf:ShowSmallTips(CHS[4000224])
        num = tostring(self:getPanelValue(panel))
    end

    self:setPanelValue(panel, 0 ~= num and tostring(num) or "")
    if not self.panelNum then
        self.panelNum = {}
    end

    self.panelNum[root] = num

    -- 更新键盘数据
    local dlg = DlgMgr:getDlgByName("SmallNumInputDlg")
    if dlg then
        dlg:setInputValue(num)
    end
end

function SystemAccManageDlg:onLockButton(sender, eventType)
    DlgMgr:openDlg("SafeLockMainDlg")
    self:onCloseButton()
end

function SystemAccManageDlg:onDelCharButton(sender, eventType)
    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    if not DistMgr:checkCrossDist() then return end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3003673])
        return
    end

    if Me:queryBasicInt("to_be_deleted") == 1 then
        gf:confirm(CHS[3004435], function ()
            gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_CANCEL_DELETE_CHAR)
        end, nil)
    else
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_DELETE_CHAR)
    end
end

function SystemAccManageDlg:onServiceButton(sender, eventType)
    if not GameMgr:isServiceEnabled() then
        gf:ShowSmallTips(CHS[5420262])
    else
        LeitingSdkMgr:helper()
    end
end

function SystemAccManageDlg:onTribuneButton(sender, eventType)
    if self.isYyb then
        LeitingSdkMgr:startService("Ysdkbbs", '')
    elseif self.isOppo then
        LeitingSdkMgr:startService("Oppobbs", '')
    end
end

function SystemAccManageDlg:onExitGameButton(sender, eventType)
    if GameMgr.isAntiCheat then
        gf:ShowSmallTips(CHS[2000085])
        return
    end
    RecordLogMgr:sendAllTouchLog()
    gf:confirm(CHS[4000380], function ()

        RecordLogMgr:endCGPluginOnce()

        gf:CmdToServer("CMD_LOGOUT", {reason = LOGOUT_CODE.LGT_BACK_LOGIN})
        CommThread:stop()
        local map = {}
        Client:clientDisconnectedServer(map)
    end)
end

-- 获取验证码(首次)
function SystemAccManageDlg:onSendVerifyCodeButton_1(sender, eventType)
    local phone = self:getPanelValue(self:getControl("InputPanel", nil, self:getControl("PhoneCodePanel", nil, self.relatedPanel)))
    self.lastSelectPanel = self.relatedPanel
    self:retainVerifyCode(VERIFY_TYPE.VERIFY, phone)
end

-- 获取验证码(再次)
function SystemAccManageDlg:onSendVerifyCodeButton_2(sender, eventType)
    local phone = self:getPanelValue(self:getControl("InputPanel", nil, self:getControl("PhoneCodePanel", nil, self.relatedPhoneAgainPanelInARP)))
    self.lastSelectPanel = self.relatedPhoneAgainPanelInARP
    if 1 == self.phoneRadioGroup:getSelectedRadioIndex() then
        self:retainVerifyCode(VERIFY_TYPE.REVERIFY, phone)
    else
        self:retainVerifyCode(VERIFY_TYPE.VERIFY_CHANGE, phone)
    end
end

-- 获取验证码(更换手机再次)
function SystemAccManageDlg:onSendVerifyCodeButton_4(sender, eventyType)
    local phone = self:getPanelValue(self:getControl("InputPanel", nil, self:getControl("PhoneCodePanel", nil, self.changePhonePanel)))
    self.lastSelectPanel = self.changePhonePanel
    self:retainVerifyCode(VERIFY_TYPE.REVERIFY_CHANGE, phone)
end

-- 获取验证码(身份)
function SystemAccManageDlg:onSendVerifyCodeButton_5(sender, eventyType)
    if not self.isSpecialChannel and (not Me.bindData or not Me.bindData.isBindPhone) then
        gf:ShowSmallTips(CHS[2000172])
        return
    end

    -- self.lastSelectPanel = self:getControl("VerifyCodePanel", nil, self.authenticatNamePanel)
    self.lastSelectPanel = self.authenticatNamePanel
    self:retainVerifyCode(VERIFY_TYPE.NAME_VERIFY)
end

function SystemAccManageDlg:onRelatePhoneButton(sender, eventType)
    local phoneNum
    local verifyCode
    local verifyType

    if gf:getServerTime() - self.lastSendRelateCmdTime < 3 then
        gf:ShowSmallTips(CHS[2000084])
        return
    end

    if self.relatedPanel:isVisible() then
        phoneNum = self:getPanelValue(self:getControl("InputPanel", nil, self.relatedPanel))
        verifyCode = self:getPanelValue(self:getControl("InputPanel", nil, self:getControl("VerifyCodePanel", nil, self.relatedPanel)))
        verifyType = 1
    elseif self.relatedPhoneAgainPanelInARP:isVisible() then
        if 1 == self.phoneRadioGroup:getSelectedRadioIndex() then
            verifyType = 2
        else
            verifyType = 3
        end

        phoneNum = self:getPanelValue(self:getControl("InputPanel", nil, self:getControl("PhoneCodePanel", nil, self.relatedPhoneAgainPanelInARP)))
        verifyCode = self:getPanelValue(self:getControl("InputPanel", nil, self:getControl("VerifyCodePanel", nil, self.relatedPhoneAgainPanelInARP)))
    elseif self.changePhonePanel:isVisible() then
        phoneNum = self:getPanelValue(self:getControl("InputPanel", nil, self.changePhonePanel))
        verifyCode = self:getPanelValue(self:getControl("InputPanel", nil, self:getControl("VerifyCodePanel", nil, self.changePhonePanel)))
        verifyType = 4
    end

    if 6 ~= string.len(verifyCode) then
        gf:ShowSmallTips(CHS[2000083])
        return
    end

    Log:D("SendBindMsg, phone:" .. phoneNum .. ", verifyCode:" .. verifyCode)
    local data = { type = verifyType, phone = phoneNum or "", verifyCode = verifyCode }
    gf:CmdToServer("CMD_PHONE_BIND", data)

    self.lastSendRelateCmdTime = gf:getServerTime()
end

function SystemAccManageDlg:getPhoneNumSafe(phone)
    if not phone or phone == "" then return "" end
    local tempStr = string.sub(phone, 1 ,3)
    local tempStrEnd = string.sub(Me.bindPhone, 8 ,-1)
    return tempStr .. "****" .. tempStrEnd
end

function SystemAccManageDlg:onSwitchPanel(sender, eventType)
    local name = sender:getName()
    if "AuthenticatePhoneCheckBox" == name then
        self.officePhonePanel:setVisible(true)
        self.officeRealNamePanel:setVisible(false)
        self:initOfficialPanel()
    elseif "AuthenticateRealNameCheckBox" == name then
        self.officePhonePanel:setVisible(false)
        self.officeRealNamePanel:setVisible(true)
        self:initOfficalRealNamePanel()
    end

    self:stopSchedule()
end

function SystemAccManageDlg:onSwitchRadio(sender, eventType)
    local name = sender:getName()
    if "AuthenticateAgainCheckBox" == name then
        self:setCtrlVisible("AuthenticateAgainPanel", true, self.afterRelatedPanel)
        self:setCtrlVisible("ChangePhonePanel", false, self.afterRelatedPanel)
        self:setInputText("InputLabel", Me.bindData.bindPhone, self:getControl("CurrentPelatedPhoneCodePanel", nil, self.relatedPhoneAgainPanelInARP))
        self:setCtrlVisible("ChangePhoneButton", false, self:getControl("AuthenticateAgainPanel", Const.UIPanel, self.afterRelatedPanel))
        self:setCtrlVisible("AuthenticateAgainButton", true, self:getControl("AuthenticateAgainPanel", Const.UIPanel, self.afterRelatedPanel))
    elseif "ChangePhoneCheckBox" == name then
        self:setCtrlVisible("ReleatedPhoneAgainPanel", true, self.afterRelatedPanel)
        self:setCtrlVisible("ChangePhonePanel", false, self.afterRelatedPanel)
        self:setInputText("InputLabel", Me.bindData.bindPhone, self:getControl("CurrentPelatedPhoneCodePanel", nil, self.relatedPhoneAgainPanelInARP))
        self:setCtrlVisible("ChangePhoneButton", true, self:getControl("AuthenticateAgainPanel", Const.UIPanel, self.afterRelatedPanel))
        self:setCtrlVisible("AuthenticateAgainButton", false, self:getControl("AuthenticateAgainPanel", Const.UIPanel, self.afterRelatedPanel))
    end

    self:setCtrlVisible("SendVerifyCodeButton_1", true, self.relatedPhoneAgainPanelInARP)
    self:setCtrlVisible("SendVerifyCodeButton_2", false, self.relatedPhoneAgainPanelInARP)
    self:setPanelValue(self:getControl("InputPanel", nil, self:getControl("PhoneCodePanel", nil, self.relatedPhoneAgainPanelInARP)), "")
    self:setPanelValue(self:getControl("InputPanel", nil, self:getControl("VerifyCodePanel", nil, self.relatedPhoneAgainPanelInARP)), "")
    self:stopSchedule()
    self:clearInput()
end

function SystemAccManageDlg:onAuthenticateRealNameButton(sender, eventType)
    if not self.isSpecialChannel and (not Me.bindData or not Me.bindData.isBindPhone) then
        gf:ShowSmallTips(CHS[2000172])
        return
    end

    local realName = self.newNameEdit:getText()
    local realId = self.newIdEdit:getText()
    local verifyCode = self:getPanelValue(self:getControl("InputPanel", nil, self:getControl("VerifyCodePanel", nil, self.authenticatNamePanel)))

    -- 安全锁判断
    if self:checkSafeLockRelease("onAuthenticateRealNameButton") then
        return
    end

    if not realName or "" == realName then
        gf:ShowSmallTips(CHS[2000173])
        return
    end

    if not realId or ""== realId or not gf:isValidIdCode(realId) then
        gf:ShowSmallTips(CHS[2000174])
        return
    end

    if not self.isSpecialChannel and not tonumber(verifyCode) then
        gf:ShowSmallTips(CHS[2000175])
        return
    end

    if gf:getServerTime() - (self.lastSendBindIdentityCmdTime or 0) < 3 then
        gf:ShowSmallTips(CHS[2000084])
        return
    end

    gf:CmdToServer("CMD_IDENTITY_BIND", {
        ["name"] = realName,
        ["id"] = realId,
        ["verifyCode"] = verifyCode or "",
    })

    self.lastSendBindIdentityCmdTime = gf:getServerTime()
end

function SystemAccManageDlg:onDelNameButton(sender, eventType)
    self.newNameEdit:setText("")
    self:setCtrlVisible("DelButton", false, self:getControl("NamePanel", Const.UIPanel, self.authenticatNamePanel))
end

function SystemAccManageDlg:onDelIdButton(sender, eventType)
    self.newIdEdit:setText("")
    self:setCtrlVisible("DelButton", false, self:getControl("IdentityCardCodePanel", Const.UIPanel, self.authenticatNamePanel))
end

function SystemAccManageDlg:onDlgOpened(list, param)
    if param == "AuthenticateRealName" and self.radioGroup and not self.isSpecialChannel then
        self.radioGroup:selectRadio(2)
    end
end

function SystemAccManageDlg:MSG_ASK_CLIENT_SECRET(data)
    DlgMgr:openDlg("CharDelDlg")
end

function SystemAccManageDlg:MSG_UPDATE()
    local deletebtn = self:getControl("DelCharButton")
    if Me:queryBasicInt("to_be_deleted") == 1 then
        self:setLabelText("Label_1", CHS[3003675], deletebtn)
        self:setLabelText("Label_2", CHS[3003675], deletebtn)
    else
        self:setLabelText("Label_1", CHS[3003676], deletebtn)
        self:setLabelText("Label_2", CHS[3003676], deletebtn)
    end
end

function SystemAccManageDlg:MSG_PHONE_VERIFY_CODE(data)
    Log:D("MSG_PHONE_VERIFY_CODE")

    if not self.lastSelectPanel then
        return
    end

    self:setCtrlVisible("SendVerifyCodeButton_1", false, self.lastSelectPanel)
    self:setCtrlVisible("SendVerifyCodeButton_2", true, self.lastSelectPanel)
    Me.lastSendVerifyCodeTime = gf:getServerTime()
    self:refreshLeftSendTime(self.lastSelectPanel, Me.lastSendVerifyCodeTime)

    if self.lastSelectPanel == self.relatedPanel then
        self:setColorText(string.format(CHS[2000081], VERIFY_CODE_RESEND_INTERVAL), "NotePanel", self.lastSelectPanel, 0, 0)
    elseif self.lastSelectPanel == self.authenticatNamePanel then
        self:setColorText(string.format(CHS[2000176], VERIFY_CODE_RESEND_INTERVAL), "NotePanel", self.authenticatNamePanel, 0, 0)
    elseif self.lastSelectPanel == self.changePhonePanel then
        self:setColorText(string.format(CHS[2000176], VERIFY_CODE_RESEND_INTERVAL), "NotePanel", self.changePhonePanel, 0, 0)
        self:setCtrlVisible("NotePanel", true, self.changePhonePanel)
    end
end

function SystemAccManageDlg:MSG_FUZZY_IDENTITY(data)
    if self.afterRelatedPanel:isVisible() and self.changePhonePanel:isVisible() then
        -- 返回更换界面
        self.changePhonePanel:setVisible(false)
        self.relatedPhoneAgainPanelInARP:setVisible(true)
        self:setCtrlVisible("AuthenticateAgainCheckBox", true, self.afterRelatedPanel)
        self:setCtrlVisible("ChangePhoneCheckBox", true, self.afterRelatedPanel)
        self:setPanelValue(self:getControl("InputPanel", nil, self:getControl("PhoneCodePanel", nil, self.relatedPhoneAgainPanelInARP)), "")
        self:setPanelValue(self:getControl("InputPanel", nil, self:getControl("VerifyCodePanel", nil, self.relatedPhoneAgainPanelInARP)), "")
        self:setCtrlVisible("SendVerifyCodeButton_1", true, self.relatedPhoneAgainPanelInARP)
        self:setCtrlVisible("SendVerifyCodeButton_2", false, self.relatedPhoneAgainPanelInARP)
        self:setInputText("InputLabel", Me.bindData.bindPhone, self:getControl("CurrentPelatedPhoneCodePanel", nil, self.relatedPhoneAgainPanelInARP))

        self:stopSchedule()
    elseif self.officePhonePanel:isVisible() then
        self:initOfficialPanel()
    elseif self.officeRealNamePanel:isVisible() then
        self:initOfficalRealNamePanel()
    end
end

function SystemAccManageDlg:MSG_CHECK_OLD_PHONENUM_SUCC(data)
    -- 显示更换绑定界面
    self:stopSchedule()
    self.changePhonePanel:setVisible(true)
    self.relatedPhoneAgainPanelInARP:setVisible(false)
    self:setCtrlVisible("AuthenticateAgainCheckBox", false, self.afterRelatedPanel)
    self:setCtrlVisible("ChangePhoneCheckBox", false, self.afterRelatedPanel)
    self:setCtrlVisible("SendVerifyCodeButton_1", true, self.changePhonePanel)
    self:setCtrlVisible("SendVerifyCodeButton_2", false, self.changePhonePanel)
    self:setCtrlVisible("NotePanel", false, self.changePhonePanel)


    RedDotMgr:removeOneRedDot("SystemAccManageDlg", "AuthenticateAgainCheckBox")
    RedDotMgr:removeOneRedDot("SystemAccManageDlg", "ChangePhoneCheckBox")

    RedDotMgr:removeOneRedDot("SystemAccManageDlg", "ChangePhoneButton", "ChangePhonePanel")
    RedDotMgr:removeOneRedDot("SystemAccManageDlg", "ChangePhoneButton", "AuthenticateAgainPanel")

    RedDotMgr:removeOneRedDot("SystemAccManageDlg", "AuthenticateRealNameButton")
    RedDotMgr:removeOneRedDot("SystemAccManageDlg", "RelatedPhoneButton")
    RedDotMgr:removeOneRedDot("SystemAccManageDlg", "AuthenticateAgainButton")
end

function SystemAccManageDlg:getClickBtn()
    if LeitingSdkMgr:isLeiting() then
        return "LockButton_1"
    else
        return "LockButton2"
    end
end

function SystemAccManageDlg:setColorText(str, panelName, root, marginX, marginY, defColor, fontSize, locate, isPunct, isVip)
    marginX = marginX or 0
    marginY = marginY or 0
    root = root or self.root
    fontSize = fontSize or 20
    defColor = defColor or COLOR3.TEXT_DEFAULT

    local panel
    if type(panelName) == "string" then
        panel = self:getControl(panelName, Const.UIPanel, root)
    else
        panel = panelName
    end

    if not panel then return end
    panel:removeAllChildren()
    panel.str = str

    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(fontSize)
    textCtrl:setString(str, isVip)
    textCtrl:setContentSize(size.width - 2 * marginX, 0)
    textCtrl:setDefaultColor(defColor.r, defColor.g, defColor.b)
    if textCtrl.setPunctTypesetting then
        textCtrl:setPunctTypesetting(true == isPunct)
    end
    textCtrl:updateNow()

    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()

    if locate == true or locate == LOCATE_POSITION.MID_BOTTOM then
        textCtrl:setPosition((size.width - textW) / 2, textH + marginY)
    elseif locate == LOCATE_POSITION.RIGHT_BOTTOM then
        textCtrl:setPosition(size.width - textW, textH + marginY)
    else
        textCtrl:setPosition(marginX, size.height)
    end

    panel.textNode = textCtrl
    local textNode = tolua.cast(textCtrl, "cc.LayerColor")


    panel:addChild(textNode, textNode:getLocalZOrder(), Dialog.TAG_COLORTEXT_CTRL)
    local panelHeight = textH + 2 * marginY
 --   panel:setContentSize(size.width, panelHeight)
    return panelHeight, size.height
end

return SystemAccManageDlg

