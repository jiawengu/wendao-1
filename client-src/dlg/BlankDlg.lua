-- BlankDlg.lua
-- Created by songcw Jan/16/2015
-- 空白对话框 覆盖全屏，点击关闭并且关闭一般性对话框

local BlankDlg = Singleton("BlankDlg", Dialog)
--local BlankDlg = class("BlankDlg", Dialog)

function BlankDlg:init()
    self.root:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)
    self:align(ccui.RelativeAlign.centerInParent)
    self:bindListener("BlankDlg", self.dlgButton)
end

function BlankDlg:dlgButton()
    if nil == self.dlg then return end
    
    -- 关闭关联窗口
    DlgMgr:closeDlg(self.dlg.name)
end

function BlankDlg:setChildDlg(dlg)
    self.dlg = dlg
end

return BlankDlg
