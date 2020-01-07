-- RenameHomeGardenerDlg.lua
-- Created by sujl, Sept/9/2017
-- 园丁改名界面

local RenameHomeGardenerDlg = Singleton("RenameHomeGardenerDlg", Dialog)
local WORD_LIMIT = 12

function RenameHomeGardenerDlg:init()
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
    self.newNameEdit:setText(self:getDefaultName())
    self:setCtrlVisible("DelAllButton", true)
end

function RenameHomeGardenerDlg:cleanup()
    self.curGjType = nil
end

function RenameHomeGardenerDlg:getDefaultName()
    local ydData = HomeMgr:getYdData()
    if ydData and not string.isNilOrEmpty(ydData.yd_name) then
        return ydData.yd_name
    else
        return "园丁"
    end
end

-- 清除输入框
function RenameHomeGardenerDlg:onDelAllButton(sender, eventType)
    self:setCtrlVisible("DelAllButton", false)
    self.newNameEdit:setText("")
end

-- 确认
function RenameHomeGardenerDlg:onConfirmButton(sender, eventType)
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

    gf:CmdToServer("CMD_HOUSE_CHANGE_YD_NAME", {yd_type = "yuanding", new_name = newName})
end

function RenameHomeGardenerDlg:onCancelButton(sender, eventType)
    self:onCloseButton()
end

-- 默认
function RenameHomeGardenerDlg:onDefaultButton(sender, eventType)
    self.newNameEdit:setText(self:getDefaultName())
    self:setCtrlVisible("DelAllButton", true)
end

return RenameHomeGardenerDlg