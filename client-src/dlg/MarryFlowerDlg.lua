-- MarryFlowerDlg.lua
-- Created by zhengjh Jul/01/2016
-- 全屏花

local MarryFlowerDlg = Singleton("MarryFlowerDlg", Dialog)

function MarryFlowerDlg:init()
    --self.root:setContentSize(Const.WINSIZE)
    self:setFullScreen()
    local panel = self:getControl("Panel")
    panel:setContentSize(cc.size(self:getWinSize().width / Const.UI_SCALE, self:getWinSize().height / Const.UI_SCALE))
    self:updateLayout("panel")
    self:setDlgZOrder(-3)
end

return MarryFlowerDlg
