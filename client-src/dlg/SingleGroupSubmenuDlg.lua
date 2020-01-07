-- SingleGroupSubmenuDlg.lua
-- Created by zhengjh Aug/04/2016
-- 群信息菜单

local SingleGroupSubmenuDlg = Singleton("SingleGroupSubmenuDlg", Dialog)

function SingleGroupSubmenuDlg:init()
    self:bindListener("MenuButton1", self.onMenuButton1)
    self:bindListener("MenuButton2", self.onMenuButton2)
    self:bindListener("MenuButton3", self.onMenuButton3)
    self:bindListener("MenuButton4", self.onMenuButton4)
    self:bindListener("MenuButton5", self.onMenuButton5)
end

function SingleGroupSubmenuDlg:setData(group)
    self.group = group
end

function SingleGroupSubmenuDlg:onMenuButton1(sender, eventType)
    local dlg = DlgMgr:openDlg("GroupRenameDlg")
    dlg:setData(self.group.name, "group")
    DlgMgr:closeDlg(self.name)
end

function SingleGroupSubmenuDlg:onMenuButton2(sender, eventType)
    DlgMgr:openDlg("GroupInformationDlg")
end

function SingleGroupSubmenuDlg:onMenuButton3(sender, eventType)
end

function SingleGroupSubmenuDlg:onMenuButton4(sender, eventType)
end

function SingleGroupSubmenuDlg:onMenuButton5(sender, eventType)
end

return SingleGroupSubmenuDlg
