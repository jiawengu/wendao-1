-- TeamOPMenuDlg.lua
-- Created by
--

local TeamOPMenuDlg = Singleton("TeamOPMenuDlg", Dialog)

local meLeaderCM    =   1   -- me是队长，点击自己
local meLeaderCO    =   2   -- me是队长点击成员
local meEXInTeam    =   3   -- me是暂离队员
local meInTeam      =   4   -- me是队员，未暂离

function TeamOPMenuDlg:init()

    -- me是队长点击成员绑定
    local leaderOPMemberPanel = self:getControl("LeaderOPMemberPanel")
    self:bindListener("CallButton", self.onLeaderOPMemberPanelCallButton, leaderOPMemberPanel)
    self:bindListener("FireButton", self.onLeaderOPMemberPanelFireButton, leaderOPMemberPanel)
    self:bindListener("Tisheng", self.onLeaderOPMemberPanelTishengButton, leaderOPMemberPanel)

    -- me是暂离队员
    local exMemberPanel = self:getControl("EXMemberPanel")
    self:bindListener("GuiduiButton", self.onExMemberPanelGuiduiButton, exMemberPanel)
    self:bindListener("LiduiButton", self.onExMemberPanelLiduiButton, exMemberPanel)

    -- me是队员，未暂离
    local memberPanel = self:getControl("MemberPanel")
    self:bindListener("ZanliButton", self.onMemberPanelZanliButton, memberPanel)
    self:bindListener("LiduiButton", self.onMemberPanelLiduiButton, memberPanel)

    -- me是队长，点击自己
    local leaderOPSelf = self:getControl("LeaderOPSelf")
    self:bindListener("LiduiButton", self.onLeaderOPSelfLiduiButton, leaderOPSelf)
    self:bindListener("CallAllButton", self.onLeaderOPSelfCallAllButton, leaderOPSelf)


    self.pickMember = nil
end

function TeamOPMenuDlg:setDlgDisplayType(type, member, rect)
    self.pickMember = member
    local dlgSize = self.root:getContentSize()
    local rootBoundingBox = self:getBoundingBoxInWorldSpace(self.root)
    if type == meLeaderCM then
    -- me是队长，点击自己
        local panel = self:getControl("LeaderOPSelf")
        local panelSize = panel:getContentSize()
        panel:setVisible(true)
        -- panel:setBackGroundImage(ResMgr:getBubblesFile())
        local sp = cc.Sprite:create(ResMgr:getBubblesArrowFile())
        local spSize = sp:getContentSize()
        sp:setPosition(panelSize.width, panelSize.height * 0.5)
        panel:addChild(sp)
        local pos = cc.p(rect.x - rootBoundingBox.width * 0.5, rect.y - rootBoundingBox.height * 0.25 + rect.height * 0.5)
        self.root:setPosition(self.root:getParent():convertToNodeSpace(pos))
        self:setCtrlVisible("MemberPanel", false)
        self:setCtrlVisible("EXMemberPanel", false)
        self:setCtrlVisible("LeaderOPMemberPanel", false)
    elseif type == meLeaderCO then
    -- me是队长点击成员
        if TeamMgr:inTeamEx(member.id) and not TeamMgr:inTeam(member.id) then
            self:setCtrlVisible("CallButton", true)
            self:setCtrlVisible("Tisheng", false)
        else
            self:setCtrlVisible("CallButton", false)
            self:setCtrlVisible("Tisheng", true)
        end
        local panel = self:getControl("LeaderOPMemberPanel")
        panel:setVisible(true)
        -- panel:setBackGroundImage(ResMgr:getBubblesFile())
        local sp = cc.Sprite:create(ResMgr:getBubblesArrowFile())
        local spSize = sp:getContentSize()
        sp:setPosition(dlgSize.width, dlgSize.height * 0.75)
        panel:addChild(sp)
        local pos = cc.p(rect.x - rootBoundingBox.width * 0.5, rect.y - rootBoundingBox.height * 0.25 + rect.height * 0.5)
        self.root:setPosition(self.root:getParent():convertToNodeSpace(pos))
        self:setCtrlVisible("EXMemberPanel", false)
        self:setCtrlVisible("MemberPanel", false)
        self:setCtrlVisible("LeaderOPSelf", false)

    elseif type == meEXInTeam then
    -- me是暂离队员
        local panel = self:getControl("EXMemberPanel")
        panel:setVisible(true)
        -- panel:setBackGroundImage(ResMgr:getBubblesFile())
        local sp = cc.Sprite:create(ResMgr:getBubblesArrowFile())
        local spSize = sp:getContentSize()
        sp:setPosition(dlgSize.width, dlgSize.height * 0.75)
        panel:addChild(sp)
        local pos = cc.p(rect.x - rootBoundingBox.width * 0.5, rect.y - rootBoundingBox.height * 0.25 + rect.height * 0.5)
        self.root:setPosition(self.root:getParent():convertToNodeSpace(pos))
        self:setCtrlVisible("LeaderOPSelf", false)
        self:setCtrlVisible("MemberPanel", false)
        self:setCtrlVisible("LeaderOPMemberPanel", false)
    elseif type == meInTeam then
    -- me是队员，未暂离
        local panel = self:getControl("MemberPanel")
        panel:setVisible(true)
        -- panel:setBackGroundImage(ResMgr:getBubblesFile())
        local sp = cc.Sprite:create(ResMgr:getBubblesArrowFile())
        local spSize = sp:getContentSize()
        sp:setPosition(dlgSize.width, dlgSize.height * 0.75)
        panel:addChild(sp)
        local pos = cc.p(rect.x - rootBoundingBox.width * 0.5, rect.y - rootBoundingBox.height * 0.25 + rect.height * 0.5)
        self.root:setPosition(self.root:getParent():convertToNodeSpace(pos))
        self:setCtrlVisible("LeaderOPSelf", false)
        self:setCtrlVisible("EXMemberPanel", false)
        self:setCtrlVisible("LeaderOPMemberPanel", false)
    end
end

function TeamOPMenuDlg:onLeaderOPMemberPanelCallButton(sender, eventType)
    if TeamMgr:getLeaderId() ~= Me:getId() then self:onCloseButton() return end
    if not TeamMgr.selectMember then self:onCloseButton() return end

    local member = TeamMgr.selectMember
    gf:CmdToServer("CMD_OPER_TELEPORT_ITEM", {oper = Const.TRY_RECRUIT, id = member.id})
    self:onCloseButton()
end

function TeamOPMenuDlg:onLeaderOPMemberPanelTishengButton(sender, eventType)

    local function onConfirm()
        -- 发送升为队长命令给服务器
        gf:CmdToServer("CMD_CHANGE_TEAM_LEADER", {
            new_leader_id = self.pickMember.id,
        })
    end
    local tip = string.format(CHS[1003780], self.pickMember.name)
    gf:confirm(tip,onConfirm)
end

function TeamOPMenuDlg:onLeaderOPMemberPanelFireButton(sender, eventType)
    if Me:isPassiveMode() or
        TeamMgr:getLeaderId() ~= Me:getId() then
        self:onCloseButton()
        return
    end

    -- 自己是队长
    if self.pickMember.name == Me:getName() then return end

    -- 发送剔除命令给服务器
    gf:CmdToServer("CMD_KICKOUT", {
        peer_name = self.pickMember.name,
    })
    self:onCloseButton()
end

function TeamOPMenuDlg:onExMemberPanelGuiduiButton(sender, eventType)
    if Me:isRemoteStore() then
        self:onCloseButton()
        return
    end
    gf:CmdToServer("CMD_RETURN_TEAM", {})
    self:onCloseButton()
end

function TeamOPMenuDlg:onExMemberPanelLiduiButton(sender, eventType)
    if Me:isPassiveMode() or not TeamMgr:inTeamEx(Me:getId()) then self:onCloseButton() return end
    local tips = CHS[6000560]

    -- 【七夕节】千里相会提示
    if not TaskMgr:qianLXHIsCanLeaveTeam() then
        tips = CHS[5400081]
    end

    tips = TaskMgr:getGiveUpTisByName(CHS[4010122], tips)

    if TaskMgr:isInTaskBKTX() then
        if Me:isTeamLeader() then
            tips = CHS[4010225]
        else
            tips = CHS[4010226]
        end
    end


    gf:confirm((tips), function()
        gf:CmdToServer("CMD_QUIT_TEAM", {})
    end)

    self:onCloseButton()
end

function TeamOPMenuDlg:onMemberPanelZanliButton(sender, eventType)
    if not Me:isInTeam() or Me:isTeamLeader() then self:onCloseButton() return end
    gf:CmdToServer("CMD_LEAVE_TEMP_TEAM", {})
    self:onCloseButton()
end

function TeamOPMenuDlg:onMemberPanelLiduiButton(sender, eventType)
    if Me:isPassiveMode() or not TeamMgr:inTeamEx(Me:getId()) then self:onCloseButton() return end
    local tips = CHS[6000560]

    -- 【七夕节】千里相会提示
    if not TaskMgr:qianLXHIsCanLeaveTeam() then
        tips = CHS[5400081]
    end

    tips = TaskMgr:getGiveUpTisByName(CHS[4010122], tips)

    if TaskMgr:isInTaskBKTX() then
        if Me:isTeamLeader() then
            tips = CHS[4010225]
        else
            tips = CHS[4010226]
        end
    end

    gf:confirm((tips), function()
        gf:CmdToServer("CMD_QUIT_TEAM", {})
    end)

    self:onCloseButton()
end

function TeamOPMenuDlg:onLeaderOPSelfLiduiButton(sender, eventType)
    if Me:isPassiveMode() or not TeamMgr:inTeamEx(Me:getId()) then self:onCloseButton() return end
    local tips = CHS[6000560]

    -- 【七夕节】千里相会提示
    if not TaskMgr:qianLXHIsCanLeaveTeam() then
        tips = CHS[5400084]
    end

    tips = TaskMgr:getGiveUpTisByName(CHS[4010122], tips)

    if TaskMgr:isInTaskBKTX() then
        if Me:isTeamLeader() then
            tips = CHS[4010225]
        else
            tips = CHS[4010226]
        end
    end

    gf:confirm((tips), function()
        gf:CmdToServer("CMD_QUIT_TEAM", {})
    end)

    self:onCloseButton()
end

function TeamOPMenuDlg:onLeaderOPSelfCallAllButton(sender, eventType)
    TeamMgr:callAll()
    self:onCloseButton()
end

return TeamOPMenuDlg
