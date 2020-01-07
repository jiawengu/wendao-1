-- XiangXinDlg.lua
-- Created by lixh Api/28/2018
-- 推荐相性加点界面

local XiangXinDlg = Singleton("XiangXinDlg", Dialog)

function XiangXinDlg:init()
    self:bindListener("TouchPanel", self.onCloseButton)
end

return XiangXinDlg
