-- GroupRenameDlg.lua
-- Created by zhengjh Aug/03/2016
-- 分组重名

local GroupRenameDlg = Singleton("GroupRenameDlg", Dialog)

function GroupRenameDlg:init()
    self:bindListener("DelAllButton", self.onDelAllButton)
    self:bindListener("CancleButton", self.onCancleButton)
    self:bindListener("DefaultButton", self.onDefaultButton)
    self:bindListener("ConfrimButton", self.onConfrimButton)
    
    self.newNameEdit = self:createEditBox("InputPanel", nil, nil, function(sender, type) 
        if type == "end" then
        elseif type == "changed" then
            local newName = self.newNameEdit:getText()
            if gf:getTextLength(newName) > 12 then
                newName = gf:subString(newName, 12)
                self.newNameEdit:setText(newName)
                gf:ShowSmallTips(CHS[5400041])
            end    

            if gf:getTextLength(newName) == 0 then
                self:setCtrlVisible("DelAllButton", false)
            else
                self:setCtrlVisible("DelAllButton", true)
            end  

        end
    end)
    
    self.newNameEdit:setLocalZOrder(1)
    self.newNameEdit:setPlaceholderFont(CHS[3003597], 20)
    self.newNameEdit:setFont(CHS[3003597], 20)
    self.newNameEdit:setFontColor(cc.c3b(139, 69, 19))
    self.newNameEdit:setText("")
end

function GroupRenameDlg:setData(group)
    self.group = group
    self.newNameEdit:setText(group.name)
    
    self:setCtrlVisible("FlockRenamePanel", true)
    self:setCtrlVisible("GroupRenamePanel", false)
end

function GroupRenameDlg:onDelAllButton(sender, eventType)
    self:setCtrlVisible("DelAllButton", false)
    self.newNameEdit:setText("")
end

function GroupRenameDlg:onCancleButton(sender, eventType)
    self:close()
end

function GroupRenameDlg:onDefaultButton(sender, eventType)
    self.newNameEdit:setText(self.group.name)
    self:setCtrlVisible("DelAllButton", true)
end

function GroupRenameDlg:onConfrimButton(sender, eventType)
    local newName = self.newNameEdit:getText()
    
    if  gf:getTextLength(newName) == 0 then
        gf:ShowSmallTips(CHS[6000408])
        return 
    end
    
    local newName, fitStr = gf:filtText(newName)
    if fitStr then
        return
    end
    
    gf:CmdToServer("CMD_MODIFY_FRIEND_GROUP", {groupId = self.group.groupId, newName = newName})
    self:close()
end

return GroupRenameDlg
