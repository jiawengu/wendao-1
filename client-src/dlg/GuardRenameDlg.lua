-- GuardRenameDlg.lua
-- Created by liuhb Jan/30/2015
-- 守护改名界面

local GuardRenameDlg = Singleton("GuardRenameDlg", Dialog)

function GuardRenameDlg:getCfgFileName()
    return ResMgr:getDlgCfg("RenamePetDlg");
end

function GuardRenameDlg:init()
    -- 修改输入提示
    self:setLabelText("RenameNoteLabel", CHS[3002803])  
     
    self:bindListener("DefaultButton", self.onDefaultButton)
    self:bindListener("ConfrimButton", self.onConfrimButton)
    self:bindListener("CancleButton", self.onCancleButton)
    self:bindListener("DelAllButton", self.onDelAllButton)
    self.guard = nil
    self.newNameEdit = self:createEditBox("InputPanel", nil, nil, function(sender, type) 

            if type == "end" then

            elseif type == "changed" then
                local newName = self.newNameEdit:getText()
                if gf:getTextLength(newName) > 12 then
                    newName = gf:subString(newName, 12)
                    self.newNameEdit:setText(newName)
                    gf:ShowSmallTips(CHS[5400041])
                end    
            end
    end)
    self.newNameEdit:setLocalZOrder(1)
    self.newNameEdit:setPlaceholderFont(CHS[3002804], 20)
    self.newNameEdit:setFont(CHS[3002804], 20)
    self.newNameEdit:setFontColor(cc.c3b(139, 69, 19))
    self.newNameEdit:setText("")
end

function GuardRenameDlg:setGuard(guard)
    self.guard = guard
    self.newNameEdit:setText(self.guard:queryBasic("name"))
end

function GuardRenameDlg:onDefaultButton(sender, eventType)
    local rawName = self.guard:queryBasic("raw_name")
    if nil == rawName then return end

    self.newNameEdit:setText(rawName)
end

function GuardRenameDlg:onConfrimButton(sender, eventType)
    local newName = self.newNameEdit:getText()
    if "" ~= newName then
        gf:CmdToServer("CMD_GUARDS_CHANGE_NAME", {
            guard_id = self.guard:queryBasicInt("id"),
            name = newName
        })
    end
    
    self:close()
end

function GuardRenameDlg:onCancleButton(sender, eventType)
    self:close()
end

function GuardRenameDlg:onDelAllButton(sender, eventType)
    self.newNameEdit:setText("")
end

return GuardRenameDlg
