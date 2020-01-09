-- InnRenameDlg.lua
-- Created by 
-- 客栈改名界面

local WORD_LIMIT = 8

local InnRenameDlg = Singleton("InnRenameDlg", Dialog)

function InnRenameDlg:init()
    self:bindListener("DelAllButton", self.onDelAllButton)
    self:bindListener("DefaultButton", self.onDefaultButton)
    self:bindListener("CancleButton", self.onCancleButton)
    self:bindListener("ConfrimButton", self.onConfrimButton)

    self.newNameEdit = self:createEditBox("InputPanel", nil, nil, function(sender, type) 
            if type == "end" then
            elseif type == "changed" then
                local newName = self.newNameEdit:getText()
                if gf:getTextLength(newName) > WORD_LIMIT then
                    newName = gf:subString(newName, WORD_LIMIT)
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

    self.orgName = InnMgr:getCurrentInnName()
    self.newNameEdit:setText(self.orgName)

    self:hookMsg("MSG_ENTER_ROOM")
end

function InnRenameDlg:onDefaultButton(sender, eventType)
    if not self.orgName then return end
    self.newNameEdit:setText(self.orgName)
    self:setCtrlVisible("DelAllButton", true)
end

function InnRenameDlg:onConfrimButton(sender, eventType)
    if not self.orgName then return end
    local newName = self.newNameEdit:getText()

    -- 与当前名字相同
    if newName == self.orgName then
        gf:ShowSmallTips(string.format(CHS[7120080], newName))
        return
    end

    -- 战斗中不可进行此操作
    if Me:isInCombat() then 
        gf:ShowSmallTips(CHS[3003598])
        return
    end

    -- 名字需要在1-4个汉字长度之间
    local len = gf:getTextLength(newName)
    if len > WORD_LIMIT or len < 2 then
        gf:ShowSmallTips(CHS[7120081])
        return 
    end

    -- 名字只能由英文字母、汉字、阿拉伯数字组成
    if not gf:checkIsGBK(newName) then
        gf:ShowSmallTips(CHS[7150018])
        return
    end

    -- 敏感词过滤
    local newName, fitStr = gf:filtText(newName)
    if fitStr then
        return
    end

    -- 确认改名
    gf:CmdToServer("CMD_INN_CHANGE_NAME", { name = newName})
end

function InnRenameDlg:onCancleButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
end

function InnRenameDlg:onDelAllButton(sender, eventType)
    self:setCtrlVisible("DelAllButton", false)
    self.newNameEdit:setText("")
end

function InnRenameDlg:MSG_ENTER_ROOM()
    DlgMgr:closeDlg(self.name)
end

return InnRenameDlg