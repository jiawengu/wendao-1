-- RenamePetDlg.lua
-- Created by liuhb Jan/30/2015
-- 宠物重命名界面

local RenamePetDlg = Singleton("RenamePetDlg", Dialog)

local WORD_LIMIT = 12

function RenamePetDlg:init()
    self:bindListener("DefaultButton", self.onDefaultButton)
    self:bindListener("ConfrimButton", self.onConfrimButton)
    self:bindListener("CancleButton", self.onCancleButton)
    self:bindListener("DelAllButton", self.onDelAllButton)
    
    self.pet = nil
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

function RenamePetDlg:setPet(pet)
    self.pet = pet
    self.newNameEdit:setText(self.pet:getShowName())
end

function RenamePetDlg:onDefaultButton(sender, eventType)
    local rawName = self.pet:queryBasic("raw_name")
    if nil == rawName then return end
    self.newNameEdit:setText(rawName)
    self:setCtrlVisible("DelAllButton", true)
end

function RenamePetDlg:onConfrimButton(sender, eventType)
    
    -- 若在战斗中直接返回
    if Me:isInCombat() then 
        gf:ShowSmallTips(CHS[3003598])
        return
    end
        
    local newName = self.newNameEdit:getText()
    local len = gf:getTextLength(newName)
    if len > WORD_LIMIT or len < 2 then
        gf:ShowSmallTips(CHS[2100116])
        return 
    end
    
    if not gf:checkIsGBK(newName) then
        gf:ShowSmallTips(CHS[7150018])
        return
    end
    
    local newName, fitStr = gf:filtText(newName)
    if fitStr then
        return
    end

    if "" ~= newName then
        gf:CmdToServer("CMD_SET_PET_NAME", {
            no = self.pet:queryBasic("no"),
            name = newName,
        })
    end

    self:close()
end

function RenamePetDlg:onCancleButton(sender, eventType)
    self:close()
end

function RenamePetDlg:onDelAllButton(sender, eventType)
    self:setCtrlVisible("DelAllButton", false)
    self.newNameEdit:setText("")
end

return RenamePetDlg
