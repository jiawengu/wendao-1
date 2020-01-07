-- AccountInputDlg.lua
-- Created by zhengjh Sep/15/2015
--账号登录

local AccountInputDlg = Singleton("AccountInputDlg", Dialog)

function AccountInputDlg:init()
    self:bindListener("LoginButton", self.onLoginButton)

    -- 账号
    self.accoutnEditBox = self:createEditBox("AccountInputPanel", nil, nil, function(dlg, event, sender)
        if 'ended' == event then
            local account = sender:getText()
            account = string.gsub(account, " ", "")
            sender:setText(account)
        elseif 'changed' == event then
            local account = sender:getText()
            account = string.gsub(account, " ", "")
            sender:setText(account)
        end
    end)

    self.accoutnEditBox:setPlaceholderFont(CHS[3002184], 30)
    self.accoutnEditBox:setFont(CHS[3002184], 30)
    self.accoutnEditBox:setFontColor(COLOR3.BLACK)
    self.accoutnEditBox:setPlaceHolder(CHS[3002185])
    self.accoutnEditBox:setPlaceholderFontColor(COLOR3.GRAY)

    -- 密码
    self.pwdEditBox = self:createEditBox("PasswordInputPanel")
    self.pwdEditBox:setFontColor(COLOR3.BLACK)
    self.pwdEditBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self.pwdEditBox:setPlaceholderFont(CHS[3002184], 30)
    self.pwdEditBox:setFont(CHS[3002184], 30)
    self.pwdEditBox:setPlaceHolder(CHS[3002186])
    self.pwdEditBox:setPlaceholderFontColor(COLOR3.GRAY)

    -- 获取上次登录信息
    local userDefault = cc.UserDefault:getInstance()
    local user = userDefault:getStringForKey("user", "")
    local password = userDefault:getStringForKey("password", "")
    self.accoutnEditBox:setText(user)
    self.pwdEditBox:setText(password)
end

function AccountInputDlg:editBoxListner(event, sender)
    if event == "return" then
        self:sendMessage()
    elseif event == "changed" then
        local text = self.editBox:getText()
        local len = string.len(text)
        self:checkStringLength()

        if len > 0 then
            self.deleteBtn:setVisible(true)
        end
    elseif event == "ended" then
    end
end


function AccountInputDlg:onLoginButton(sender, eventType)
    local account = self.accoutnEditBox:getText()
    local password = self.pwdEditBox:getText()
    if string.len(account) == 0 or string.len(password) == 0 then
        gf:ShowSmallTips(CHS[3002187])
        return
    end

    Client:setNameAndPassword(account, password)
    DlgMgr:closeDlg(self.name)

    -- 保存登录信息
    local userDefault = cc.UserDefault:getInstance()
    userDefault:setStringForKey("user", account)
    userDefault:setStringForKey("password", password)

    -- 显示欢迎信息
    DlgMgr:sendMsg('UserLoginDlg', 'showWelcome')
end

return AccountInputDlg
