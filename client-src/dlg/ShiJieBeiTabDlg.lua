-- ShiJieBeiTabDlg.lua
-- Created by
--

local TabDlg = require('dlg/TabDlg')
local ShiJieBeiTabDlg = Singleton("ShiJieBeiTabDlg", TabDlg)

-- 按钮与对话框的映射表
ShiJieBeiTabDlg.dlgs = {
    SaiShiDlgCheckBox = "ShiJieBeiDlg",
    GuiZeDlgCheckBox = "ShiJieBeiRuleDlg",
}


function ShiJieBeiTabDlg:onPreCallBack(sender, idx)
    local name = sender:getName()
    local data = ActivityMgr:getShijiebeiData()

    if name == "SaiShiDlgCheckBox" and not data then
        gf:CmdToServer('CMD_WORLD_CUP_2018_PLAY_TABLE')
        return
    end
    return true
end


return ShiJieBeiTabDlg
