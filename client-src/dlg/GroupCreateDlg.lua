-- GroupCreateDlg.lua
-- Created by zhengjh Aug/03/2016
-- 创建分组

local GroupCreateDlg = Singleton("GroupCreateDlg", Dialog)

function GroupCreateDlg:init()
    self:bindListener("DelAllButton", self.onDelAllButton)
    self:bindListener("ReNameButton", self.onReNameButton)
    self:bindListener("CancleButton", self.onCancleButton)
    self:bindListener("ConfrimButton", self.onConfrimButton)
    
    self.limit = 12
    
    self.newNameEdit = self:createEditBox("InputPanel", nil, nil, function(sender, type) 
        if type == "end" then
        elseif type == "changed" then
            local newName = self.newNameEdit:getText()
            if gf:getTextLength(newName) > self.limit then
                newName = gf:subString(newName, self.limit)
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

    self.newNameEdit:setPlaceholderFont(CHS[3003597], 20)
    self.newNameEdit:setFont(CHS[3003597], 20)
    self.newNameEdit:setFontColor(cc.c3b(139, 69, 19))
    self.newNameEdit:setText("")
    self.data = {}
end


function GroupCreateDlg:setData(data)
    self.type = data.type
    self.data = data
    self:setUiInfo(data)
end

function GroupCreateDlg:setUiInfo(data)
    local panel = self:getControl("SurplusPanel")
    if self.type == "friendGroup" then
        self:setCtrlVisible("FlockPanel", true)
        self:setCtrlVisible("GroupPanel", false)
        self:setCtrlVisible("RemarksPanel", false)
        self:setCtrlVisible("SurplusPanel", true)
        self:setCtrlVisible("RemarksPromptPanel", false)
        panel:setVisible(true)
        self:setLabelText("NumLabel", data.left or 0, panel)
        self.newNameEdit:setText(FriendMgr:getDefaultCreateGroupName())
    elseif self.type == "chatGroup" then
        self:setCtrlVisible("FlockPanel", false)
        self:setCtrlVisible("GroupPanel", true) 
        self:setCtrlVisible("RemarksPanel", false)
        self:setCtrlVisible("SurplusPanel", false)
        self:setCtrlVisible("GroupSurplusPanel", true)
        self:setCtrlVisible("RemarksPromptPanel", false)
        panel = self:getControl("GroupSurplusPanel")
        self:setLabelText("GroupNumLabel", data.left or 0, panel)
        self.newNameEdit:setText(FriendMgr:getDefaultCreateChatGroupName())
    elseif self.type == "remark" then
        self:setCtrlVisible("FlockPanel", false)
        self:setCtrlVisible("GroupPanel", false) 
        self:setCtrlVisible("RemarksPanel", true)
        self:setCtrlVisible("SurplusPanel", false)
        self:setCtrlVisible("RemarksPromptPanel", true)
        panel:setVisible(false)  
        self.limit = 40
        local ramark = FriendMgr:getMemoByGid(self.data.gid)
        self.newNameEdit:setText(ramark)
        local remarkPanel = self:getControl("RemarksPanel")
        self:setLabelText("NameLabel", self.data.name, remarkPanel)
        
        if not ramark or ramark == "" then
            self:setCtrlVisible("DelAllButton", false)
        end
    end

end

function GroupCreateDlg:onCancleButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
end

function GroupCreateDlg:onDelAllButton(sender, eventType)
    self:setCtrlVisible("DelAllButton", false)
    self.newNameEdit:setText("")
end


function GroupCreateDlg:onConfrimButton(sender, eventType)
    local newName = self.newNameEdit:getText()
    
    if  gf:getTextLength(newName) == 0 and self.type ~= "remark" then
        gf:ShowSmallTips(CHS[6000408])
        return 
    end

    local newName, fitStr = gf:filtText(newName)
    if fitStr then
        return
    end
    
    if self.type == "friendGroup" then
        gf:CmdToServer("CMD_ADD_FRIEND_GROUP", {name = newName})  
    elseif self.type == "chatGroup" then
        gf:CmdToServer("CMD_ADD_CHAT_GROUP", {name = newName})  
    elseif self.type == "remark" then
        gf:CmdToServer("CMD_MODIFY_FRIEND_MEMO", {gid = self.data.gid, memo = newName})  
    end
    
    DlgMgr:closeDlg(self.name)  
end

return GroupCreateDlg
