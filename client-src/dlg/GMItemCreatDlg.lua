-- GMItemCreatDlg.lua
-- Created by 
-- 

local GMItemCreatDlg = Singleton("GMItemCreatDlg", Dialog)

GMItemCreatDlg.VALUE_RANGE = {
    ["NumPanel"] = {MIN = 1, MAX = 2 * math.pow(10, 9), DEF = 1, notNeedChanegColor = true},
}

function GMItemCreatDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("CancelButton", self.onCancelButton)
    
    
    GMMgr:bindEditBoxForGM(self, "NumPanel")
    
    self.newNameEdit = self:createEditBox("NamePanel")
    
    self.newNameEdit:setPlaceholderFont(CHS[3003794], 23)
    self.newNameEdit:setFont(CHS[3003794], 23)
    self.newNameEdit:setPlaceHolder(CHS[4200247])
    self.newNameEdit:setPlaceholderFontColor(cc.c3b(102, 102, 102))
end

function GMItemCreatDlg:onConfirmButton(sender, eventType)
    local itemName = self.newNameEdit:getText()
    local amount = tonumber(GMMgr:getEditBoxValue(self, "NumPanel"))
    
    if not amount then
        gf:ShowSmallTips(CHS[4100484])
        return
    end
    
    
    GMMgr:setAdminMakeItem(itemName, amount)
end

function GMItemCreatDlg:onCancelButton(sender, eventType)
    self:onCloseButton()
end

return GMItemCreatDlg
