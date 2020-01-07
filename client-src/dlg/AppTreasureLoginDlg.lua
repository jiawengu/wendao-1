-- AppTreasureLoginDlg.lua
-- Created by zhengjh Jun/26/2016
-- 运用宝登录界面

local AppTreasureLoginDlg = Singleton("AppTreasureLoginDlg", Dialog)

function AppTreasureLoginDlg:init()
    self:bindListener("WeChatButton", self.onWeChatButton)
    self:bindListener("QQButton", self.onQQButton)
    local winSize = cc.Director:getInstance():getWinSize()
    self.root:setContentSize(winSize)

    DlgMgr:closeDlg("UserLoginDlg")
end

function AppTreasureLoginDlg:cleanup()
    DlgMgr:openDlg("UserLoginDlg")
end

function AppTreasureLoginDlg:onWeChatButton(sender, eventType)
    LeitingSdkMgr:wxLogin()
end

function AppTreasureLoginDlg:onQQButton(sender, eventType)
    LeitingSdkMgr:qqLogin()
end


function AppTreasureLoginDlg:onCloseButton()
end

return AppTreasureLoginDlg
