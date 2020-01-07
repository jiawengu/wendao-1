-- TeamSortOrderDlg.lua
-- Created by sujl, Oct/12/2018
-- 固定队结交界面

local TeamFixedMakeBaseDlg = require("dlg/TeamFixedMakeBaseDlg")
local TeamSortOrderDlg = Singleton("TeamSortOrderDlg", TeamFixedMakeBaseDlg)

-- 人数上限
local PORTRAIT_NUM = 5

function TeamSortOrderDlg:init(param)
    TeamFixedMakeBaseDlg.init(self)

    self:bindListener("ConfirmButton", self.onConfirmButton)

    self:refreshStates(param)

    self:hookMsg("MSG_FIXED_TEAM_START_DATA")
    self:hookMsg("MSG_CANCEL_BUILD_FIXED_TEAM")
    self:hookMsg("MSG_FIXED_TEAM_APPELLATION")
end

function TeamSortOrderDlg:setTeamMember(index, data)
    local ctlName
    ctlName = string.format("PortraitPanel_%d", index)
    self:setImage("PortraitImage", ResMgr:getCirclePortraitPathByIcon(data.org_icon), ctlName)
    self:setLabelText("NameLabel", data.name, ctlName)
end

function TeamSortOrderDlg:getPortraitFrameImage(index)
    local ctlName
    ctlName = string.format("PortraitPanel_%d", index)
    return self:getControl("PortraitFrameImage", nil, ctlName)
end

-- 根据结拜人数初始化头像位置
function TeamSortOrderDlg:initPortraitPos(num)
    if self.initPortraitPosFinished then
        return
    end

    -- 根据人数隐藏“空头像”
    for i = 1, PORTRAIT_NUM do
        if i <= num then
            self:setCtrlVisible("PortraitPanel_" .. i, true)
        else
            self:setCtrlVisible("PortraitPanel_" .. i, false)
        end
    end

    -- 将显示状态的头像整体居中

    -- 计算需要移动的距离
    local portraitPanelWidth = self:getControl("PortraitPanel_1"):getContentSize().width
    local firstPanelPosX = self:getControl("PortraitPanel_1"):getPositionX()
    local lastPanelPosX = self:getControl("PortraitPanel_" .. num):getPositionX()
    local mainPanel = self:getControl("PortraitPanel")
    local offset = mainPanel:getContentSize().width / 2 - ((firstPanelPosX + lastPanelPosX + portraitPanelWidth) / 2)

    -- 移动显示状态的头像
    for i = 1, num  do
        local portraitPanel = self:getControl("PortraitPanel_" .. i)
        portraitPanel:setPositionX(portraitPanel:getPositionX() + offset)
    end

    self.initPortraitPosFinished = true
end

function TeamSortOrderDlg:refreshStates(data)
    for i = 1, 5 do
        self:setCtrlVisible("StatusLabel", false, string.format("PortraitPanel_%d", i))
    end

    self:setCtrlVisible("ConfirmButton", Me:isTeamLeader())
end

function TeamSortOrderDlg:onConfirmButton()
    gf:CmdToServer("CMD_CONFIRM_START_BUILD_FIXED_TEAM")
end

function TeamSortOrderDlg:onCloseButton()
    gf:confirm(CHS[2100241], function()
        gf:CmdToServer("CMD_STOP_BUILD_FIXED_TEAM")
        Dialog.onCloseButton(self)
    end)
end

function TeamSortOrderDlg:MSG_FIXED_TEAM_START_DATA(data)
    self:refreshStates(data)
end

function TeamSortOrderDlg:MSG_CANCEL_BUILD_FIXED_TEAM(data)
    Dialog.onCloseButton(self)
end

function TeamSortOrderDlg:MSG_FIXED_TEAM_APPELLATION(data)
    Dialog.onCloseButton(self)
end

return TeamSortOrderDlg

-- DlgMgr:openDlg("TeamSortOrderDlg")