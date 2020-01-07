-- TeamVoteDlg.lua
-- Created by sujl, Oct/12/2018
-- 固定队界面

local TeamVoteDlg = Singleton("TeamVoteDlg", Dialog)

local PORTRAIT_NUM = 5

function TeamVoteDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)

    -- 初始化显示状态
    self.panelPos = {}
    for i = 1, PORTRAIT_NUM do
        local fingerImage = self:getControl("PortraitPanel_" .. i)
        fingerImage:setColor(COLOR3.WHITE)
        self.panelPos[i] = fingerImage:getPositionX()
    end

    -- 创建分享按钮
    self:createShareButton(self:getControl("ShareButton"), SHARE_FLAG.FIXTEAM)

    -- 初始显示确认结拜按钮
    self:setCtrlVisible("ConfirmPanel", true)
    self:setCtrlVisible("SharePanel", false)

    self:setCloseDlgWhenRefreshUserData(true)

    self:hookMsg("MSG_FIXED_TEAM_CHECK_DATA")
    self:hookMsg("MSG_CANCEL_BUILD_FIXED_TEAM")
    self:hookMsg("MSG_FIXED_TEAM_FINISH_DATA")
end

-- 根据结拜人数初始化头像位置
function TeamVoteDlg:initPortraitPos(num)
    if self.lastNum == num then
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
    local firstPanelPosX = self.panelPos[1]
    local lastPanelPosX = self.panelPos[num]
    local mainPanel = self:getControl("PortraitPanel")
    local offset = mainPanel:getContentSize().width / 2 - ((firstPanelPosX + lastPanelPosX + portraitPanelWidth) / 2)

    -- 移动显示状态的头像
    for i = 1, num  do
        local portraitPanel = self:getControl("PortraitPanel_" .. i)
        portraitPanel:setPositionX(self.panelPos[i] + offset)
    end

    self.lastNum = num
end

function TeamVoteDlg:setInfo(data, isShowRelation)
    if not data then
        return
    end

    self:initPortraitPos(#data.members)

    self.isShowRelation = isShowRelation
    self.action = data.action

    local meInfo

    -- 设置每个角色信息
    for i = 1, PORTRAIT_NUM do
        local info = data.members[i]
        if info then
            if info.gid == Me:queryBasic("gid") then
                meInfo = info
            end

            local name = info.name
            local iconPath = ResMgr:getCirclePortraitPathByIcon(info.icon)
            self:setImage("PortraitImage", iconPath, "PortraitPanel_" .. i)
            self:setLabelText("NameLabel", name, "PortraitPanel_" .. i)
            self:setCtrlVisible("FingerPrintImage", true, "PortraitPanel_" .. i)

            -- 确认手印状态
            if info.has_confirm == 1 or isShowRelation then
                local fingerImage = self:getControl("FingerPrintImage", nil, "PortraitPanel_" .. i)
                fingerImage:setColor(COLOR3.RED)

                if info.gid == Me:queryBasic("gid") then
                   local confirmButton = self:getControl("ConfirmButton", nil, "ConfirmPanel")
                   confirmButton:setColor(COLOR3.RED)
                   confirmButton:setTouchEnabled(false)
                end

                self:setCtrlVisible("StatusLabel", false, "PortraitPanel_" .. i)
            else
                local fingerImage = self:getControl("FingerPrintImage", nil, "PortraitPanel_" .. i)
                fingerImage:setColor(COLOR3.WHITE)

                if info.gid == Me:queryBasic("gid") then
                   local confirmButton = self:getControl("ConfirmButton", nil, "ConfirmPanel")
                   confirmButton:setColor(COLOR3.WHITE)
                   confirmButton:setTouchEnabled(true)
                end

                self:setCtrlVisible("StatusLabel", true, "PortraitPanel_" .. i)
            end
        else
            self:setCtrlVisible("FingerPrintImage", false, "PortraitPanel_" .. i)
        end
    end

    -- 设置自己的相关信息
    if meInfo then
        local meIconPath = ResMgr:getBigPortrait(meInfo.icon)
        self:setImage("UserImage", meIconPath, "SelfPortraitPanel")
        self:setLabelText("TitleLabel", data.team_name, "SelfTitlePanel")
        self:setLabelText("NameLabel", gf:getRealName(meInfo.name), "SelfTitlePanel")
    end

    -- 当前界面显示结拜成功后的结拜关系，确认按钮替换为分享按钮
    self:setCtrlVisible("ConfirmPanel", not isShowRelation)
    self:setCtrlVisible("SharePanel", isShowRelation)
end

function TeamVoteDlg:onConfirmButton()
    gf:CmdToServer("CMD_FINISH_BUILD_FIXED_TEAM")
end

-- 关闭按钮响应
function TeamVoteDlg:onCloseButton()
    if self.isShowRelation or GameMgr.canRefreshUserData then
        self:close()
        return
    end

    local tips = 1 == self.action and CHS[2100249] or CHS[2100250]
    gf:confirm(tips, function()
        gf:CmdToServer("CMD_STOP_BUILD_FIXED_TEAM")
        Dialog.onCloseButton(self)
    end)
end

function TeamVoteDlg:cleanup()
    self.lastNum = nil
    self.panelPos = nil
end

function TeamVoteDlg:MSG_FIXED_TEAM_CHECK_DATA(data)
    self:setInfo(data)
end

function TeamVoteDlg:MSG_CANCEL_BUILD_FIXED_TEAM(data)
    Dialog.onCloseButton(self)
end

function TeamVoteDlg:MSG_FIXED_TEAM_FINISH_DATA(data)
    self:setInfo(data, true)
end

return TeamVoteDlg
