-- RenameHomeDlg.lua
-- Created by yangym Jul/12/2017
-- 居所重命名界面

local RenameHomeDlg = Singleton("RenameHomeDlg", Dialog)

local WORD_LIMIT = 2 * 4

function RenameHomeDlg:init()
    self:bindListener("DefaultButton", self.onDefaultButton)
    self:bindListener("ConfrimButton", self.onConfrimButton)
    self:bindListener("CancleButton", self.onCancleButton)
    self:bindListener("DelAllButton", self.onDelAllButton)

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

    self:hookMsg("MSG_HOUSE_DATA")

    HomeMgr:requestData()
    self:doInit()
end

function RenameHomeDlg:doInit()
    -- 居所类型
    local homeTypeCHS = HomeMgr:getHomeTypeCHS()
    self:setLabelText("TypeLabel", homeTypeCHS)

    -- 初始化输入框
    self:onDefaultButton()
end

function RenameHomeDlg:onDefaultButton(sender, eventType)
    local houseName = self:getOriginalHouseName()
    if houseName and houseName ~= "" then
        self.newNameEdit:setText(houseName)
        self:setCtrlVisible("DelAllButton", true)
    else
        self.newNameEdit:setText("")
        self:setCtrlVisible("DelAllButton", false)
    end
end

function RenameHomeDlg:onConfrimButton(sender, eventType)

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003598])
        return
    end

    local newName = self.newNameEdit:getText()

    if not gf:checkIsGBK(newName) then
        gf:ShowSmallTips(CHS[2200061])
        return
    end

    if gf:getTextLength(newName) > WORD_LIMIT then
        return
    end

    local newName, fitStr = gf:filtText(newName)
    if fitStr then
        return
    end

    if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
        gf:ShowSmallTips(CHS[5410117])
        return
    end

    gf:CmdToServer("CMD_HOUSE_RENAME", {name = newName})

    self:close()
end

function RenameHomeDlg:onCancleButton(sender, eventType)
    self:close()
end

-- 获取自己居所的名称前缀
function RenameHomeDlg:getOriginalHouseName()
    return HomeMgr:getMyHomePrefix()
end

function RenameHomeDlg:onDelAllButton(sender, eventType)
    self:setCtrlVisible("DelAllButton", false)
    self.newNameEdit:setText("")
end

function RenameHomeDlg:MSG_HOUSE_DATA()
    self:doInit()
end

return RenameHomeDlg
