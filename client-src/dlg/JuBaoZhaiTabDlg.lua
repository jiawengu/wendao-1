-- JuBaoZhaiTabDlg.lua
-- Created by
--

local TabDlg = require('dlg/TabDlg')
local JuBaoZhaiTabDlg = Singleton("JuBaoZhaiTabDlg", TabDlg)

-- 按钮与对话框的映射表
JuBaoZhaiTabDlg.dlgs = {
    JuBaoZhaiNoteDlgCheckBox = "JuBaoZhaiNoteDlg",
    JuBaoZhaiSellDlgCheckBox = "JuBaoZhaiSellDlg",
    JuBaoZhaiVendueDlgCheckBox = "JuBaoZhaiVendueDlg",
    JuBaoZhaiStorageDlgCheckBox = "JuBaoZhaiStorageDlg",
}

JuBaoZhaiTabDlg.defDlg = "JuBaoZhaiNoteDlg"

return JuBaoZhaiTabDlg
