-- RenameHomeMaidDlg.lua
-- Created by sujl, Sept/7/2017
-- 丫鬟改名

local RenameHomeMaidDlg = Singleton("RenameHomeMaidDlg", Dialog)
local WORD_LIMIT = 12

function RenameHomeMaidDlg:init()
    self:bindListener("ConfrimButton", self.onConfirmButton)
    self:bindListener("CancleButton", self.onCancelButton)
    self:bindListener("DefaultButton", self.onDefaultButton)
    self:bindListener("DelAllButton", self.onDelAllButton, "InputPanel")

    self.newNameEdit = self:createEditBox("InputPanel", nil, nil, function(sender, type)
        if type == "end" then
        elseif type == "changed" then
            local newName = self.newNameEdit:getText()
            if gf:getTextLength(newName) > WORD_LIMIT then
                newName = gf:subString(newName, WORD_LIMIT)
                self.newNameEdit:setText(newName)
                gf:ShowSmallTips(CHS[2000419])
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
    self:setCtrlVisible("DelAllButton", false)
end

function RenameHomeMaidDlg:resetDefaultName()
    local maidName = self:getDefaultName()
    self.newNameEdit:setText(maidName)
    self:setCtrlVisible("DelAllButton", not string.isNilOrEmpty(maidName))
end

function RenameHomeMaidDlg:getDefaultName()
    local maid = HomeMgr:getMaidByType(self.curYhType)
    local maidName
    if maid then
        if string.isNilOrEmpty(maid.name) then
            local info = HomeMgr:getMaidInfoByType(self.curYhType)
            if info then
                maidName = info.name
            end
        else
            maidName = maid.name
        end
    end

    return maidName
end

function RenameHomeMaidDlg:onDlgOpened(list, dlgParma)
    self.curYhType = dlgParma
    self:resetDefaultName()
end

function RenameHomeMaidDlg:onDelAllButton(sender, eventType)
    self:setCtrlVisible("DelAllButton", false)
    self.newNameEdit:setText("")
end

function RenameHomeMaidDlg:onConfirmButton(sender, eventType)
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[2000281])
        return
    end

    local newName = self.newNameEdit:getText()
    local len = gf:getTextLength(newName)
    if len > WORD_LIMIT or len < 2 then
        gf:ShowSmallTips(CHS[2100116])
        return
    end

    if not gf:checkIsGBK(newName) then
        gf:ShowSmallTips(CHS[2000423])
        return
    end

    local newName, fitStr = gf:filtText(newName)
    if fitStr then
        return
    end

    gf:CmdToServer("CMD_HOUSE_CHANGE_YH_NAME", {yh_type = self.curYhType, new_name = newName})
end

function RenameHomeMaidDlg:onCancelButton(sender, eventType)
    self:onCloseButton()
end

function RenameHomeMaidDlg:onDefaultButton(sender, eventType)
    self:resetDefaultName()
end

return RenameHomeMaidDlg