-- RenameKidDlg.lua
-- Created by
--

local RenameKidDlg = Singleton("RenameKidDlg", Dialog)

local WORD_LIMIT = 12

function RenameKidDlg:init(data)
    self:bindListener("DelAllButton", self.onDelAllButton)
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


    self:setData(data)

    self:onDefaultButton()
end

function RenameKidDlg:setData(data)
    self.data = data
    self:setCtrlVisible("NoticeLabel2", data.isRenamed == 0)
    self:setCtrlVisible("NoticeLabel3", data.isRenamed == 1)
    self:setCtrlVisible("MoneyImage", data.isRenamed == 1)
end

function RenameKidDlg:onDelAllButton(sender, eventType)
    self:setCtrlVisible("DelAllButton", false)
    self.newNameEdit:setText("")
end

function RenameKidDlg:onDefaultButton(sender, eventType)
    local rawName = self.data.name
    if nil == rawName then return end
    self.newNameEdit:setText(rawName)
    self:setCtrlVisible("DelAllButton", true)
end

function RenameKidDlg:onConfrimButton(sender, eventType)
    -- 安全锁判断
    if self:checkSafeLockRelease("onConfrimButton") then
        return
    end

    local newName = self.newNameEdit:getText()
    if newName == self.data.name then
        gf:ShowSmallTips(string.format(CHS[4101450], newName))
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003598])
        return
    end


    local len = gf:getTextLength(newName)
    if len > WORD_LIMIT or len < 2 then
        gf:ShowSmallTips(CHS[4101451])
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

    gf:CmdToServer("CMD_CHILD_RENAME", {
        id = self.data.id,
        new_name = newName,
        isFirst = self.data.isRenamed == 0 and 1 or 0,
    })
end

return RenameKidDlg
