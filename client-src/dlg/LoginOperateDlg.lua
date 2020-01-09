-- LoginOperateDlg.lua
-- Created by zhengjh Sep/2015/19
-- 登录连接确认取消框

local LoginOperateDlg = Singleton("LoginOperateDlg", Dialog)

function LoginOperateDlg:init()
    self:bindListener("ConfrimButton", self.onConfrimButton)
    self:bindListener("ConfrimButton_2", self.onRepairButton)
    self:bindListener("CancelButton", self.onCancelButton)
    self:setTips()
end

function LoginOperateDlg:setRepairDisplay(isVisible)
    --self:setTips(CHS[2000216])
    self:setCtrlVisible("NotePanel", not isVisible)
    self:setCtrlVisible("ConfrimButton_2", isVisible)
    self:setCtrlVisible("NoteLabel_2", isVisible)
    self:setCtrlVisible("NoteLabel_1", isVisible)
end

function LoginOperateDlg:onRepairButton(sender, eventType)
    performWithDelay(gf:getUILayer(), function()
        DlgMgr:sendMsg("UserLoginDlg", "onRepair")
    end, 0)
end

function LoginOperateDlg:onConfrimButton(sender, eventType)
    local aaa =DistMgr:getDistInfoByName(Client:getWantLoginDistName())["aaa"]


    -- Client:connetAAA(aaa, true, true)
    if not string.isNilOrEmpty(Client:getAccount()) then
        Client:checkVersionAndReconnect(aaa)
    else
        DlgMgr:closeDlg("WaitDlg")
    end

    DlgMgr:closeDlg(self.name)
end

function LoginOperateDlg:onCancelButton(sender, eventType)
   DlgMgr:closeDlg(self.name)
   DlgMgr:closeDlg("WaitDlg")

   GameMgr:changeScene('LoginScene', true)
end

function LoginOperateDlg:setTips(errorStr)
    self:setRepairDisplay(false)

    if nil == errorStr then
        errorStr = CHS[3002922]
    end

    local panelCtrl = self:getControl("NotePanel")
    panelCtrl:removeAllChildren()

    -- 生成颜色字符串控件
    local tip = CGAColorTextList:create()
    tip:setFontSize(19)
    tip:setString(errorStr)
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
end

function LoginOperateDlg:onCloseButton()
end


return LoginOperateDlg
