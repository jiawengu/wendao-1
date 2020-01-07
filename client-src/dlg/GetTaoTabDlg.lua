-- GetTaoTabDlg.lua
-- Created by liuhb Jan/27/2016
-- 刷道标签页面

local TabDlg = require('dlg/TabDlg')
local GetTaoTabDlg = Singleton("GetTaoTabDlg", TabDlg)

GetTaoTabDlg.dlgs = {
    GetTaoTabDlgCheckBox        = "GetTaoDlg",
    GetTaoPointTabDlgCheckBox   = "GetTaoPointDlg",
    GetTaoTrusteeshipTabDlgCheckBox   = "GetTaoTrusteeshipDlg",
    OfflineGetTaoTabDlgCheckBox = "GetTaoOfflineDlg",
}

function GetTaoTabDlg:getOpenDefaultDlg()
    return TabDlg.getOpenDefaultDlg(self) or "GetTaoDlg"
end


function GetTaoTabDlg:cleanup()
    if GetTaoMgr.scoreData then
        GetTaoMgr:MSG_SHUADAO_SCORE_ITEMS(GetTaoMgr.scoreData)
    end
    
    if GetTaoMgr:isHasOfflineBonus() then        
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "ShuadaoButton")
        RedDotMgr:insertOneRedDot("GetTaoTabDlg", "OfflineGetTaoTabDlgCheckBox")
        RedDotMgr:insertOneRedDot("GetTaoOfflineDlg", "RewardButton")
    end
end

return GetTaoTabDlg
