-- ReserveRechargeExDlg.lua
-- Created by lixh2 Mar/08/2019
-- 预充值界面,带页签,复用 ReserveRechargeDlg

local ReserveRechargeDlg = require('dlg/ReserveRechargeDlg')
local ReserveRechargeExDlg = Singleton("ReserveRechargeExDlg", ReserveRechargeDlg)

function ReserveRechargeExDlg:init()
    ReserveRechargeDlg.init(self)

    NoticeMgr:showNewDistPreChargeDlg(true)
end

function ReserveRechargeExDlg:getCfgFileName()
    return ResMgr:getDlgCfg("ReserveRechargeDlg")
end

return ReserveRechargeExDlg
