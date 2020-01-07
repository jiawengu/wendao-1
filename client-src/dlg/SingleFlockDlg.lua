-- SingleFlockDlg.lua
-- Created by zhengjh Aug/02/2016
-- 分组菜单

local SingleFlockDlg = Singleton("SingleFlockDlg", Dialog)

function SingleFlockDlg:init()
    self:bindListener("MenuButton1", self.onMenuButton1)
    self:bindListener("MenuButton2", self.onMenuButton2)
    self:bindListener("MenuButton3", self.onMenuButton3)
end

function SingleFlockDlg:setGroup(group)
    self.group = group
end

function SingleFlockDlg:onMenuButton1(sender, eventType)
    local dlg = DlgMgr:openDlg("GroupRenameDlg")
    dlg:setData(self.group)
    DlgMgr:closeDlg(self.name)
end

function SingleFlockDlg:onMenuButton2(sender, eventType)
    local dlg = DlgMgr:openDlg("FlockMoveDlg")
    dlg:initGroup(self.group )
    DlgMgr:closeDlg(self.name)
end

function SingleFlockDlg:onMenuButton3(sender, eventType)
    local gorupId = self.group.groupId
    gf:confirm(CHS[6000437], function ()
        gf:CmdToServer("CMD_REMOVE_FRIEND_GROUP", {groupId = gorupId})
    end, nil) 
    DlgMgr:closeDlg(self.name)   
end

return SingleFlockDlg
