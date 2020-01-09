-- InviteJoinPartyDlg.lua
-- Created by songcw Aug/20/2016
-- 邀请入帮界面

local InviteJoinPartyDlg = Singleton("InviteJoinPartyDlg", Dialog)

function InviteJoinPartyDlg:init()

    self:bindListener("EmptyButton", self.onEmptyButton)
    self:bindListener("RefreshButton", self.onRefreshButton)

    self:setCtrlVisible("RefreshButton", false)

    self.unitPanel = self:getControl("OneRowPartyPanel", Const.UIPanel)
    self.unitPanel:retain()
    self.unitPanel:removeFromParent()

    self:setDlgInfo()
end

function InviteJoinPartyDlg:cleanup()
    self:releaseCloneCtrl("unitPanel")
end

function InviteJoinPartyDlg:setDlgInfo()
    local inviteData = PartyMgr:getInviteList()
    local list, size = self:resetListView("PartyListView")
    for _, inviteInfo in pairs(inviteData) do
        local panel = self.unitPanel:clone()
        self:setUnitPanel(inviteInfo, panel, _)
        list:pushBackCustomItem(panel)
    end
end

function InviteJoinPartyDlg:setUnitPanel(inviteInfo, panel, index)
    self:setLabelText("NameLabel", inviteInfo.partyName, panel)

    local levelStr = PartyMgr:getCHSLevelAndPeopleMax(inviteInfo.partyLevel)
    self:setLabelText("LevelLabel", levelStr, panel)

    self:setLabelText("ConstructionLabel", inviteInfo.partyConstruction, panel)

    self:setLabelText("MemberNumLabel", inviteInfo.partyPopulation, panel)

    self:setCtrlVisible("BackImage_2", index % 2 == 0, panel)

    panel.inviteInfo = inviteInfo
    self:bindListener("AgreeButton", self.onAgreeButton, panel)
    self:bindListener("RefuseButton", self.onRefuseButton, panel)
end

function InviteJoinPartyDlg:onAgreeButton(sender, eventType)
    local intiveInfo = sender:getParent().inviteInfo
    PartyMgr:responseInviteParty(true, intiveInfo.inviteName)
    self:onCloseButton()
end

function InviteJoinPartyDlg:onRefuseButton(sender, eventType)
    local intiveInfo = sender:getParent().inviteInfo
    PartyMgr:responseInviteParty(false, intiveInfo.inviteName)
    self:setDlgInfo()
end

function InviteJoinPartyDlg:onEmptyButton(sender, eventType)
    PartyMgr:cleanInviteJoinList()
    self:onCloseButton()
end

function InviteJoinPartyDlg:onRefreshButton(sender, eventType)
end

return InviteJoinPartyDlg
