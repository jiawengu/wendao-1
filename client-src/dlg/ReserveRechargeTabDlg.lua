-- ReserveRechargeTabDlg.lua
-- Created by lixh2 Mar/08/2019
-- 预充值页签界面

local TabDlg = require('dlg/TabDlg')
local ReserveRechargeTabDlg = Singleton("ReserveRechargeTabDlg", TabDlg)

ReserveRechargeTabDlg.orderList = {
    ['AnnouncementDlgCheckBox']   = 1,
    ['ReservationDlgCheckBox']     = 2,
}

ReserveRechargeTabDlg.dlgs = {
    AnnouncementDlgCheckBox   = 'CreateCharDescExDlg',
    ReservationDlgCheckBox     = 'ReserveRechargeExDlg',
}

ReserveRechargeTabDlg.defDlg = "ReserveRechargeExDlg"

return ReserveRechargeTabDlg
