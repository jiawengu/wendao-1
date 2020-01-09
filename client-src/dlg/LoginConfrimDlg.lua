-- LoginConfrimDlg.lua
-- Created by zhengjh Apr/2/2015
-- 登录重连界面

local LoginConfrimDlg = Singleton("LoginConfrimDlg", Dialog)

function LoginConfrimDlg:init()
    self:bindListener("ConfrimButton_1", self.onConfrimButton)
    self.root:setLocalZOrder(10)
end

function LoginConfrimDlg:onConfrimButton(sender, eventType)
    --Client:init()
    local aaa =DistMgr:getDistInfoByName(Client:getWantLoginDistName())["aaa"]
    Client:connetAAA(aaa, true, false)
    DlgMgr:closeDlg(self.name)
end

return LoginConfrimDlg
