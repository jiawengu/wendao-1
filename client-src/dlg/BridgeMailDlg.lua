-- BridgeMailDlg.lua
-- Created by huangzz Nov/24/2017
-- 水岚之缘信封界面

local BridgeMailDlg = Singleton("BridgeMailDlg", Dialog)

function BridgeMailDlg:init()
    self:setFullScreen()
    self:bindListener("ConfirmButton", self.onConfirmButton)
    
    self:setLabelText("NameLabel", Me:getShowName() .. CHS[7000078], "InfoPanel")
end

function BridgeMailDlg:onConfirmButton(sender, eventType)
    gf:CmdToServer("CMD_TASK_SHUILZY_CCJM_LETTER", {})
    self:close()
end

return BridgeMailDlg
