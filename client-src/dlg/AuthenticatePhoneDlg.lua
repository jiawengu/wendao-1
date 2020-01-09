-- AuthenticatePhoneDlg.lua
-- Created by huangzz Dec/07/2016
-- 手机验证界面

local AuthenticatePhoneDlg = Singleton("AuthenticatePhoneDlg", Dialog)

local VERIFY_CODE_RESEND_INTERVAL = 120

function AuthenticatePhoneDlg:init()
    self:bindListener("SendVerifyCodeButton_1", self.onSendVerifyCodeButton_1)
    self:setCtrlEnabled("SendVerifyCodeButton_2", false, self.relatedPanel)
    self:setCtrlVisible("SendVerifyCodeButton_2", false)
    self:bindEditField("InputPanel", 6, self:getControl("VerifyCodePanel"))
    self:bindListener("ConfrimButton", self.onConfrimButton)
end

function AuthenticatePhoneDlg:setData(data)
    self:setColorText(data.fuzzy_phone, "InputPanel", self:getControl("PhonePanel"), 10, 10)
    
    if data.last_take_code_time and data.last_take_code_time > 0 then
        self:MSG_OPEN_SMS_VERIFY_DLG(data)
    end
end

-- 绑定数字键盘
function AuthenticatePhoneDlg:bindEditField(textFieldName, lenLimit, root)
    local inputPanel = self:getControl(textFieldName, nil, root)
    self:bindNumInput(textFieldName, root, nil, { root = root, panel = inputPanel, lenLimit = lenLimit }, true)
end

function AuthenticatePhoneDlg:stopSchedule()
    if tonumber(self.leftTimeSchedulId) then
        gf:Unschedule(self.leftTimeSchedulId)
        self.leftTimeSchedulId = nil
    end
end

-- 可再次获取验证码倒计时
function AuthenticatePhoneDlg:refreshLeftSendTime(lastSendTime)
    local btnCtrl = self:getControl("SendVerifyCodeButton_2")
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
            self:setCtrlVisible("SendVerifyCodeButton_1", true)
            self:setCtrlVisible("SendVerifyCodeButton_2", false)
        end
    end, 1)
end

function AuthenticatePhoneDlg:onSendVerifyCodeButton_1(sender, eventType)
    gf:CmdToServer("CMD_SMS_TAKE_CHECK_CODE", {})
end

function AuthenticatePhoneDlg:onSendVerifyCodeButton_2(sender, eventType)
end

function AuthenticatePhoneDlg:onConfrimButton(sender, eventType)
    local verifyCode = self:getLabelText("InputLabel", self:getControl("VerifyCodePanel"))

    if 6 ~= string.len(verifyCode) then
        gf:ShowSmallTips(CHS[2000083])
        return
    end

    Log:D("SendBindMsg, verifyCode:" .. verifyCode)

    gf:CmdToServer("CMD_SMS_VERIFY_CHECK_CODE", {verifyCode = verifyCode})
end

function AuthenticatePhoneDlg:insertNumber(num, key)
    Log:D("insertNum, num:" .. num)

    local panel = key.panel
    local root = key.root
    local lenLimit = key.lenLimit
    self:setCtrlVisible("DefaultLabel", false, root)
    local str = tostring(num)
    if gf:getTextLength(str) > lenLimit then
        gf:ShowSmallTips(CHS[4000224])
        num = tostring(self:getLabelText("InputLabel", panel))
    end

    self:setLabelText("InputLabel", 0 ~= num and tostring(num) or "", panel)

    -- 更新键盘数据
    local dlg = DlgMgr:getDlgByName("SmallNumInputDlg")
    if dlg then
        dlg:setInputValue(num)
    end
end

function AuthenticatePhoneDlg:cleanup()
    self:stopSchedule()
end

function AuthenticatePhoneDlg:MSG_OPEN_SMS_VERIFY_DLG(data)
    Log:D("MSG_OPEN_SMS_VERIFY_DLG")

    self:setCtrlVisible("SendVerifyCodeButton_1", false)
    self:setCtrlVisible("SendVerifyCodeButton_2", true)

    self:refreshLeftSendTime(gf:getServerTime())

    self:setColorText(string.format(CHS[2000081], VERIFY_CODE_RESEND_INTERVAL), "NotePanel", nil, 0, 0)
end

return AuthenticatePhoneDlg
