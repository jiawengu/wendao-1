-- DivorceDlg.lua
-- Created by zhengjh Jun/13/2016
-- 离婚界面

local DugeonVoteDlg = require('dlg/DugeonVoteDlg')
local DivorceDlg = Singleton("DivorceDlg", DugeonVoteDlg)

function DivorceDlg:getCfgFileName()
    return ResMgr:getDlgCfg("DivorceDlg")
end

function DivorceDlg:setUiInfo()
end

function DivorceDlg:sendTimeoutCmd()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_TEAM_ASK_REFUSE)
end

return DivorceDlg
