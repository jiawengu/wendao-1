-- LoadingFailedDlg.lua
-- Created by zhengjh Oct/23/2015
-- 登录失败，需要发送报告

local LoadingFailedDlg = Singleton("LoadingFailedDlg", Dialog)

function LoadingFailedDlg:init()
    self:bindListener("ConfrimButton", self.onConfrimButton)
    self:bindListener("CancelButton", self.onCancelButton)
end

function LoadingFailedDlg:setTips(errorStr)
    if nil == errorStr then
        errorStr = CHS[3002917]
    end

    local panelCtrl = self:getControl("NotePanel")

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

function LoadingFailedDlg:onConfrimButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
    DlgMgr:closeDlg("WaitDlg")
    DlgMgr:closeDlg("LoginChangeDistDlg")
	local aaa =DistMgr:getDistInfoByName(Client:getWantLoginDistName())["aaa"]
    Client:connetAAA(aaa, true, true)
end

function LoadingFailedDlg:onCancelButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
    DlgMgr:closeDlg("WaitDlg")
end


return LoadingFailedDlg
