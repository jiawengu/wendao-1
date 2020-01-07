-- RenameHomeManagerDlg.lua
-- Created by sujl, Sept/9/2017
-- 管家改名界面

local RenameHomeManagerDlg = Singleton("RenameHomeManagerDlg", Dialog)
local WORD_LIMIT = 12

function RenameHomeManagerDlg:init()
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
    local gjData = HomeMgr:getGjData()
    if gjData then
        self.curGjType = gjData.cur_select_gj_type
        self.newNameEdit:setText(self:getDefaultName())
        self:setCtrlVisible("DelAllButton", true)
    else
        self.newNameEdit:setText("")
        self:setCtrlVisible("DelAllButton", false)
    end
end

function RenameHomeManagerDlg:cleanup()
    self.curGjType = nil
end

function RenameHomeManagerDlg:getDefaultName()
    local gjData = HomeMgr:getGjData()
    if gjData and gjData.gjs[self.curGjType] and not string.isNilOrEmpty(gjData.gjs[self.curGjType].gj_name) then
        return gjData.gjs[self.curGjType].gj_name
    else
        return CHS[2000418]
    end
end

-- 清除输入框
function RenameHomeManagerDlg:onDelAllButton(sender, eventType)
    self:setCtrlVisible("DelAllButton", false)
    self.newNameEdit:setText("")
end

-- 确认
function RenameHomeManagerDlg:onConfirmButton(sender, eventType)
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[2000281])
        return
    end

    local newName = self.newNameEdit:getText()
    local textLength = gf:getTextLength(newName)
    if textLength > WORD_LIMIT or textLength < 2 then
        gf:ShowSmallTips(CHS[2000415])
        return
    end

    if not gf:checkIsGBK(newName) then
        gf:ShowSmallTips(CHS[2000416])
        return
    end

    local newName, fitStr = gf:filtText(newName)
    if fitStr then
        return
    end

    gf:CmdToServer("CMD_HOUSE_CHANGE_GUANJIA_NAME", {gj_type = self.curGjType, new_name = newName})
    --[[
    gf:confirm(string.format(CHS[2000417], newName), function()
        gf:CmdToServer("CMD_HOUSE_CHANGE_GUANJIA_NAME", {gj_type = self.curGjType, new_name = newName})
    end)
    ]]
end

function RenameHomeManagerDlg:onCancelButton(sender, eventType)
    self:onCloseButton()
end

-- 默认
function RenameHomeManagerDlg:onDefaultButton(sender, eventType)
    self.newNameEdit:setText(self:getDefaultName())
    self:setCtrlVisible("DelAllButton", true)
end

return RenameHomeManagerDlg