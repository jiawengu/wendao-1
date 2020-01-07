-- HomeShowDlg.lua
-- Created by sujl, Jun/23/2017
-- 居所展示界面


local HomeShowDlg = require('dlg/HomeShowDlg')
local HomeShowEXDlg = Singleton("HomeShowEXDlg", HomeShowDlg)

function HomeShowEXDlg:getCfgFileName()
    return ResMgr:getDlgCfg("HomeShowDlg")
end


return HomeShowEXDlg