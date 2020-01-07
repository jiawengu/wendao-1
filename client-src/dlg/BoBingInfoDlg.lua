-- BoBingInfoDlg.lua
-- Created by sujl, Aug/25/2016
-- 博饼奖励规则界面

local BoBingInfoDlg = Singleton("BoBingInfoDlg", Dialog)
function BoBingInfoDlg:init ()
    self:bindListener("ClosePanel", self.onCloseButton)
    self:bindListener("CloseButton", self.onCloseButton)
end

return BoBingInfoDlg
