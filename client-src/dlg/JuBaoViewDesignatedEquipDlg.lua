-- JuBaoViewDesignatedEquipDlg.lua
-- Created by
--

local JuBaoViewEquipDlg = require('dlg/JuBaoViewEquipDlg')
local JuBaoViewDesignatedEquipDlg = Singleton("JuBaoViewDesignatedEquipDlg", JuBaoViewEquipDlg)

function JuBaoViewDesignatedEquipDlg:init()
    JuBaoViewEquipDlg.init(self)
    self:bindListener("NoteButton", self.onNoteButton)
    self:bindListener("BuyButton", self.onBuyButton)
end

function JuBaoViewDesignatedEquipDlg:onNoteButton(sender, eventType)
    gf:showTipInfo(CHS[4100945], sender)
end

return JuBaoViewDesignatedEquipDlg
