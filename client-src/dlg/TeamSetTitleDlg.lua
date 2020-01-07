-- TeamSetTitleDlg.lua
-- Created by sujl, Oct/12/2018
-- 固定队设定界面

local TeamFixedMakeBaseDlg = require("dlg/TeamFixedMakeBaseDlg")
local TeamSetTitleDlg = Singleton("TeamSetTitleDlg", TeamFixedMakeBaseDlg)

local NAME_LIMIT = 5 * 2

function TeamSetTitleDlg:init(param)
    TeamFixedMakeBaseDlg.init(self)

    self.param = param

    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("QianzPanel_0", self.onClickNameLabel, "InputPanel")

    ChatMgr:blindSpeakBtn(self:getControl("TeamRecordButton"), self)

    -- 创建输入框
    self:createEditBoxes()

    -- 更新确认按钮状态
    self:refreshConfirmButtonState()

    -- 更新提示
    self:refreshTips()

    self:hookMsg("MSG_FIXED_TEAM_APPELLATION")
    self:hookMsg("MSG_CANCEL_BUILD_FIXED_TEAM")
    self:hookMsg("MSG_FIXED_TEAM_CHECK_DATA")
    self:hookMsg("MSG_FIXED_TEAM_DATA")
end

function TeamSetTitleDlg:createEditBoxes()

        -- 前缀输入框
    self.nameBox = self:createEditBox("QianzPanel", nil, nil, function(sender, type)
        if type == "began" then
            self:setCtrlVisible("NameLabel", false, "InputPanel")
        elseif type == "changed" then
            if not Me:isTeamLeader() then
                gf:ShowSmallTips(CHS[2100242])
                return
            end
            local name = self.nameBox:getText()
            if gf:getTextLength(name) > NAME_LIMIT then
                name = gf:subString(name, NAME_LIMIT)
                self.nameBox:setText(name)
                gf:ShowSmallTips(CHS[4000224])
            end

            self:setLabelText("NameLabel", self.nameBox:getText(), "InputPanel")

            self:sendInput()
            self:refreshConfirmButtonState()
        elseif type == "ended" then
            self:setCtrlVisible("NameLabel", true, "InputPanel")
        end
    end)

    self.nameBox:setFont(CHS[3003794], 21)
    self.nameBox:setPlaceHolder("")
    self.nameBox:setPlaceholderFontColor(COLOR3.GRAY)
    self.nameBox:setFontColor(COLOR3.BROWN)

    if Me:isTeamLeader() then
        -- 队长可以输入内容
        self.nameBox:setEnabled(true)
    else
        -- 队员不可输入内容，并给予提示
        self.nameBox:setEnabled(false)
    end
end

function TeamSetTitleDlg:getPortraitFrameImage(index)
    local portraitPanel = self:getControl("PortraitPanel_" .. index)
    return self:getControl("PortraitFrameImage", nil, portraitPanel)
end

function TeamSetTitleDlg:refreshTips()
    self:setLabelText("TipsLabel", "")
    if Me:isTeamLeader() then
        self:setLabelText("TitleLabel", CHS[2100243], "InputPanel")
    else
        self:setLabelText("TitleLabel", CHS[2100244], "InputPanel")
    end
end

function TeamSetTitleDlg:refreshConfirmButtonState()
    self:setCtrlVisible("ConfirmButton", Me:isTeamLeader())
    self:setCtrlEnabled("ConfirmButton", not string.isNilOrEmpty(self.nameBox:getText()) and Me:isTeamLeader())
end

function TeamSetTitleDlg:sendInput()
    gf:CmdToServer("CMD_SET_FIXED_TEAM_APPELLATION", { name = self.nameBox:getText() })
end

function TeamSetTitleDlg:checkAllChinses(text)
    local index = 1
    local byteValue = string.byte(text, index)
    local len = string.len(text)
    local changeLength = 0

    while len >= index do
        local byteValue = string.byte(text, index)
        local len = gf:getUTF8Bytes(byteValue)
        if len <= 1 then
            return false
        end

        index = index + len

        if len > 2 then
            changeLength = changeLength + 2
        else
            changeLength = changeLength + len
        end
    end

    return true
end

function TeamSetTitleDlg:onConfirmButton()
    if not Me:isTeamLeader() then return end

    local name = self.nameBox:getText()

    gf:confirm(string.format(CHS[2100245], name), function()
        local len = gf:getTextLength(name)
        if len < 2 * 2 or len > 5 * 2 then
            gf:ShowSmallTips(CHS[2100246])
            return
        end

        if not self:checkAllChinses(name) then
            gf:ShowSmallTips(CHS[2100247])
            return
        end

        -- 过滤敏感词
        local name, fitStr = gf:filtText(name)
        if fitStr then
            return
        end

        name, fitStr = gf:filtText(name .. CHS[2100248])
        if fitStr then
            return
        end

        gf:CmdToServer("CMD_CONFIRM_FIXED_TEAM_APPELLATION")
    end)
end

function TeamSetTitleDlg:onClickNameLabel(sender)
    if not self.nameBox then return end

    if not Me:isTeamLeader() then
        gf:ShowSmallTips(CHS[2100242])
        return
    end

    self.nameBox:openKeyboard()
end

function TeamSetTitleDlg:onCloseButton()
    local tip = 1 == self.param.openType and CHS[2100281] or CHS[2100241]
    gf:confirm(tip, function()
        gf:CmdToServer("CMD_STOP_BUILD_FIXED_TEAM")
        Dialog.onCloseButton(self)
    end)
end

function TeamSetTitleDlg:MSG_FIXED_TEAM_APPELLATION(data)
    self:setLabelText("NameLabel", data.team_name, "InputPanel")
    self.nameBox:setText(data.team_name)
    self:refreshConfirmButtonState()
end

function TeamSetTitleDlg:MSG_CANCEL_BUILD_FIXED_TEAM(data)
    Dialog.onCloseButton(self)
end

function TeamSetTitleDlg:MSG_FIXED_TEAM_CHECK_DATA(data)
    Dialog.onCloseButton(self)
end

function TeamSetTitleDlg:MSG_FIXED_TEAM_DATA(data)
    Dialog.onCloseButton(self)
end

return TeamSetTitleDlg