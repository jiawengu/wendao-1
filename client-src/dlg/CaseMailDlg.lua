-- CaseMailDlg.lua
-- Created by lixh May/25/2018
-- 探案-小纸条界面

local CaseMailDlg = Singleton("CaseMailDlg", Dialog)

function CaseMailDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
end

function CaseMailDlg:setData(data)
    self.pos = data.pos
    local des1 = string.format(CHS[7190234], data.name)
    local des2 = string.format(CHS[7190235], data.timeStr, data.timeStr)
    local des3 = CHS[7190236]

    self:setColorText(des1, "TextPanel1", nil, nil, nil, COLOR3.ORANGE, 21, false, true)
    self:setColorText(des2, "TextPanel2", nil, nil, nil, COLOR3.ORANGE, 21, false, true)
    self:setColorText(des3, "TextPanel3", nil, nil, nil, COLOR3.ORANGE, 21, false, true)
    self:getControl("MainPanel"):requestDoLayout()
end

function CaseMailDlg:onConfirmButton(sender, eventType)
    gf:CmdToServer("CMD_RKSZ_READ_PAPER_MESSAGE", {})
    self:onCloseButton()
end

function CaseMailDlg:cleanup()
    self.pos = nil
end

return CaseMailDlg
