-- BiggerConfirmDlg.lua
-- Created by zhengjh Apr/15/2016
-- 免责声明

local BiggerConfirmDlg = Singleton("BiggerConfirmDlg", Dialog)

function BiggerConfirmDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("CancelButton", self.onCancelButton)

    local title = CHS[6000235] .. "\n" .. CHS[6000236]
    local panelCtrl = self:getControl("ContentPanel")
    panelCtrl:removeAllChildren()
    local size = panelCtrl:getContentSize()
    local titleCtrl = CGAColorTextList:create(true)
    titleCtrl:setFontSize(19)
    titleCtrl:setString(title)
    titleCtrl:setContentSize(size.width, 0)
    titleCtrl:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    titleCtrl:updateNow()
    local textW, textH = titleCtrl:getRealSize()
    local layer = tolua.cast(titleCtrl, "cc.LayerColor")
    layer:setPosition(size.width/2, size.height / 2)
    layer:setAnchorPoint(0.5, 0.5)

    panelCtrl:addChild(layer)
    self.blank:setLocalZOrder(Const.ZORDER_BIGCONFIRDLG)
end

function BiggerConfirmDlg:onConfirmButton(sender, eventType)
    gf:ShowSmallTips(CHS[6000238])
    DlgMgr:closeDlg(self.name)
end

function BiggerConfirmDlg:onCancelButton(sender, eventType)
    self:setVisible(false)
    gf:confirm(CHS[6000237],
        function ()
            gf:CmdToServer("CMD_LOGOUT", {reason = LOGOUT_CODE.LGT_REFUSE_AGREEMENT})
            CommThread:stop()
            Client:clientDisconnectedServer({})
            DlgMgr:closeDlg(self.name)
        end,
        function ()
            return self:setVisible(true)
        end)
    --DlgMgr:closeDlg(self.name)
end


return BiggerConfirmDlg
