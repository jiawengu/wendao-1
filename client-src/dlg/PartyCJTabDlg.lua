-- PartyCJTabDlg.lua
-- Created by songcw Feb/2/2015
-- 帮派标签界面

local TabDlg = require('dlg/TabDlg')
local PartyCJTabDlg = Singleton("PartyCJTabDlg", TabDlg)

PartyCJTabDlg.dlgs = {
    JoinPartyDlgCheckBox = "JoinPartyDlg",
    CreatePartyDlgCheckBox = "CreatePartyDlg",
    
}

function PartyCJTabDlg:cleanup()
    self.lastDlg = nil
end

return PartyCJTabDlg
