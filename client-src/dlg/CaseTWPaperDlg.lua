-- CaseTWPaperDlg.lua
-- Created by huangzz Jun/06/2018
-- 探案天外之谜-纸条界面

local CaseTWPaperDlg = Singleton("CaseTWPaperDlg", Dialog)

function CaseTWPaperDlg:init(param)
    self:setFullScreen()

    self:setLabelText("Label1", param, "MainPanel")
    self:setLabelText("Label2", param, "MainPanel")
end

return CaseTWPaperDlg
