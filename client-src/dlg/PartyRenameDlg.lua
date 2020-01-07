-- PartyRenameDlg.lua
-- Created by zhengjh Jul/02/2016
-- 帮派重命名

local PartyRenameDlg = Singleton("PartyRenameDlg", Dialog)

function PartyRenameDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("CancelButton", self.onCancelButton)
    
    self.newNameEdit = self:createEditBox("NameInputPanel", nil, nil, function(sender, type)
        if type == "end" then

        elseif type == "changed" then
            local newName = self.newNameEdit:getText()
            if gf:getTextLength(newName) > 12 or gf:getTextLength(newName) < 3 then
                newName = gf:subString(newName, 12)
                self.newNameEdit:setText(newName)
                gf:ShowSmallTips(CHS[5400041])
            end
        end
    end)
end

function PartyRenameDlg:onConfirmButton(sender, eventType)
    if not PartyMgr:isPartyLeader() then
        gf:ShowSmallTips(CHS[6400079])
        return
    end
    
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end
    
    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003796])
        return
    elseif Me:isLookOn() then
        gf:ShowSmallTips(CHS[3003797])
        return
    end
    
    local name = self.newNameEdit:getText()
    
    gf:CmdToServer("CMD_PARTY_RENAME", {name = name, type = 1})
    DlgMgr:closeDlg(self.name)
end

function PartyRenameDlg:onCancelButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
end

return PartyRenameDlg
