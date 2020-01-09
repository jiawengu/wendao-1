-- AccountVerifyFailedDlg.lua
-- Created by zhengjh Oct/28/2015
-- 账号登录失败

local AccountVerifyFailedDlg = Singleton("AccountVerifyFailedDlg", Dialog)

function AccountVerifyFailedDlg:init()
    self:bindListener("ConfrimButton", self.onConfrimButton)
end

function AccountVerifyFailedDlg:setTips(errorStr)
    if nil == errorStr then
        errorStr = CHS[3002188]
    end

    local panelCtrl = self:getControl("NotePanel")

    -- 生成颜色字符串控件
    local tip = CGAColorTextList:create(true)
    tip:setFontSize(19)
    tip:setString(errorStr)
    tip:setContentSize(panelCtrl:getContentSize().width, 0)
    tip:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    tip:updateNow()
    local w, h = tip:getRealSize()
    --tip:setContentSize(w, h)
    if panelCtrl then
        local colorLayer = tolua.cast(tip, "cc.LayerColor")
        panelCtrl:addChild(colorLayer)
        gf:align(colorLayer, panelCtrl:getContentSize(), ccui.RelativeAlign.centerInParent)
    end
end

function AccountVerifyFailedDlg:onConfrimButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
    DlgMgr:closeDlg("WaitDlg")
    DlgMgr:closeDlg("CreateCharDlg")
    local dlg = DlgMgr.dlgs["LoginChangeDistDlg"]
    if dlg  and self.isCreatCharTips then
        local aaa =DistMgr:getDistInfoByName(Client:getWantLoginDistName())["aaa"]
        Client:connetAAA(aaa, true, false)
        self.isCreatCharTip = nil
    else
        DlgMgr:closeDlg("LoginChangeDistDlg")
        DlgMgr:setVisible("UserLoginDlg", true)

        if GameMgr.scene and "LoginScene" ~= GameMgr.scene:getType() then
            -- 不出在登录界面下，退回登录界面
            CommThread:stop()
            Client:clientDisconnectedServer({})
        end
    end
end

function AccountVerifyFailedDlg:setIsCreatCharTips(isCreatCharTips)
    self.isCreatCharTips = isCreatCharTips
end

return AccountVerifyFailedDlg
