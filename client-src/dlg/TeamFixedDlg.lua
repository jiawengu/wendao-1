-- TeamFixedDlg.lua
-- Created by sujl, Oct/12/2018
-- 固定队界面

local TeamFixedDlg = Singleton("TeamFixedDlg", Dialog)

local FUNCTIONS = {
    { need_level = 1, icon = ResMgr.ui.team_fixed_func1, key = "ft_dun_yb", desc = CHS[2100252]},
    { need_level = 2, icon = ResMgr.ui.team_fixed_func2, key = "ft_change_look", desc = CHS[2100253]},
    { need_level = 3, icon = ResMgr.ui.team_fixed_func3, key = "ft_req_team", desc = CHS[2100254]},
    { need_level = 3, icon = ResMgr.ui.team_fixed_func4, key = "ft_inv_team", desc = CHS[2100255]},
    { need_level = 3, icon = ResMgr.ui.team_fixed_func5, key = "ft_recruit", desc = CHS[2100256]},
    { need_level = 4, icon = ResMgr.ui.team_fixed_func6, key = "ft_lead_team", desc = CHS[2100257]},
    { need_level = 5, icon = ResMgr.ui.team_fixed_func7, key = "ft_use_item", desc = CHS[2100258]},
    { need_level = 5, icon = ResMgr.ui.team_fixed_func8, key = "ft_change_team_seq", desc = CHS[2200158]},
}

function TeamFixedDlg:init()
    self:bindListener("InfoButton", self.onInfo1Button, "TeamPlayerPanel")
    self:bindListener("InfoButton", self.onInfo2Button, "TeamFunctionPanel")
    self:bindListener("AllInTeamButton", self.onAllTeamButton, "TeamPlayerPanel")
    self:bindListener("AllOpenButton", self.onAllOpenButton, "TeamFunctionPanel")
    self:bindListener("TeamPlayerButton", self.onTeamPlayerButton, "UpperPanel")
    self:bindListener("TeamFunctionButton", self.onTeamFunctionButton, "UpperPanel")

    self:bindFloatPanelListener(self:getControl("RulePanel", nil, "TeamPlayerPanel"))
    self:bindFloatPanelListener(self:getControl("RulePanel", nil, "TeamFunctionPanel"))
    self:setCtrlVisible("RulePanel", false, "TeamFunctionPanel")

    self.playerUnitPanel = self:retainCtrl("PlayerUnitPanel", "TeamPlayerPanel")
    self:bindListener("GoTeamButton", self.onGoTeamButton, self.playerUnitPanel)
    self:bindListener("MoreButton", self.onMoreButton, self.playerUnitPanel)

    self:onTeamPlayerButton(self:getControl("TeamPlayerButton", nil, "UpperPanel"))

    self.functionUnitPanel = self:retainCtrl("FuncitionUnitPanel1", "TeamFunctionPanel")

    -- 请求刷新信息
    gf:CmdToServer("CMD_FIXED_TEAM_REQUEST_DATA")

    self:hookMsg("MSG_FIXED_TEAM_DATA")
    self:hookMsg("MSG_SET_SETTING")
    self:hookMsg("MSG_FIXED_TEAM_OPEN_SUPPLY_DLG")
    self:hookMsg("MSG_UPDATE_TEAM_LIST_EX")
end

function TeamFixedDlg:cleanup()
    self.queryAction = nil
end

function TeamFixedDlg:checkButton(sender)
    if not sender then return end
    local btn = self:getControl("TeamPlayerButton")
    self:setCtrlVisible("SelectedImage", false, btn)
    btn = self:getControl("TeamFunctionButton")
    self:setCtrlVisible("SelectedImage", false, btn)

    self:setCtrlVisible("SelectedImage", true, sender)
end

function TeamFixedDlg:refreshTeamInfo()
    local data = TeamMgr.fixedTeam

    if data and not string.isNilOrEmpty(data.name) then
        self:setLabelText("NameLabel", string.format(CHS[2100282], data.name, "UpperPanel"), "UpperPanel")
    else
        self:setLabelText("NameLabel", "", "UpperPanel")
    end
    self:setLabelText("LevelLabel", string.format(CHS[2100259], data and data.level or 0), "UpperPanel")
    if data and data.max_intimacy > 0 then
        self:setLabelText("ExpLabel", string.format(CHS[2100260], data and data.intimacy or 0, data.max_intimacy), "UpperPanel")
    else
        self:setLabelText("ExpLabel", string.format(CHS[2100261], data and data.intimacy or 0), "UpperPanel")
    end

    self:refreshPlayerList(data and data.members)
    self:refreshButtonState()   -- 刷新按钮状态
end

function TeamFixedDlg:setItemData(item, data)
    item:setName(data.gid)
    self:setLabelText("NameLabel", data.name, item)
    self:setLabelText("PartyLabel", string.format(CHS[2100262], data.level), item)
    self:setLabelText("PotLabel", string.format(CHS[2100263], gf:getTaoStr(data.tao, 0)), item)
    self:setLabelText("OnlineTimeLabel", string.format(CHS[2100264], 0 == data.last_logout_time and CHS[2100265] or gf:getElapseTimeStr(gf:getServerTime() - data.last_logout_time)), item)

    self:setImage("BackImage2", ResMgr:getSmallPortrait(data.icon), self:getControl("PortraitPanel1", nil, item))
    self:setCtrlVisible("NewImage", data.join_time > 0 and gf:getServerTime() - data.join_time < 3 * 24 * 60 * 60, item)
    self:setCtrlVisible("SelfImage", Me:queryBasic("gid") == data.gid, item)
    self:setCtrlVisible("InTeamImage", Me:queryBasic("gid") ~= data.gid and TeamMgr:inTeamExByGid(data.gid), item)
    self:setCtrlVisible("GoTeamButton", Me:queryBasic("gid") ~= data.gid and not TeamMgr:inTeamExByGid(data.gid), item)
    self:setCtrlEnabled("GoTeamButton", data.last_logout_time == 0, item)
end

function TeamFixedDlg:refreshTeamMembers()
    local data = TeamMgr.fixedTeam
    if not data then return end

    local members = data and data.members
    local list = self:getControl("PlayerListView", nil, "PlayerListPanel")
    local item
    for i = 1, #members do
        item = self:getControl(members[i].gid, nil, list)
        if item then
            self:setItemData(item, members[i])
        end
    end
end

function TeamFixedDlg:refreshPlayerList(data)
    local list = self:resetListView("PlayerListView", nil, nil, "PlayerListPanel")
    self:setCtrlVisible("PlayerListView", data and #data > 0, "PlayerListPanel")
    self:setCtrlVisible("NoticePanel", not data or #data <= 0 , "PlayerListPanel")

    if not data or #data <= 0 then return end

    local item
    for i = 1, #data do
        item = self.playerUnitPanel:clone()
        self:setItemData(item, data[i])
        list:pushBackCustomItem(item)
    end
end

-- 刷新按钮状态
function TeamFixedDlg:refreshButtonState()
    local data = TeamMgr.fixedTeam and TeamMgr.fixedTeam.members or {}
    local isAllInTeam = true
    for i = 1, #data do
        if not TeamMgr:inTeamExByGid(data[i].gid) then
            isAllInTeam = false
            break
        end
    end

    self:setCtrlEnabled("AllInTeamButton", not isAllInTeam and not self.queryAction, "TeamPlayerPanel")
    self:setCtrlEnabled("AllOpenButton", #data > 0, "TeamFunctionPanel")
end

-- 刷新规则信息
function TeamFixedDlg:refreshFunction()
    local data = TeamMgr.fixedTeam
    self:setCtrlVisible("FunctionListView", true, "FunctionListPanel")
    self:setCtrlVisible("NoticePanel", false, "FunctionListPanel")

    local list = self:resetListView("FunctionListView", nil, nil, "FunctionListPanel")
    local level = data and data.level or 0

    local item
    for i = 1, #FUNCTIONS do
        item = self.functionUnitPanel:clone()
        item:setName(FUNCTIONS[i].key)
        if level >= FUNCTIONS[i].need_level then
            self:setLabelText("FunctionNameLabel", string.format(CHS[2100266], i), item)
            self:setCtrlEnabled("BackImage", true, item)
            self:setCtrlEnabled("OpenStatePanel", true, item)
        else
            self:setLabelText("FunctionNameLabel", string.format(CHS[2100267], i, FUNCTIONS[i].need_level), item)
            self:setCtrlEnabled("BackImage", false, item)
            self:setCtrlEnabled("OpenStatePanel", false, item, true)
        end

        self:setImage("BackImage2", FUNCTIONS[i].icon, self:getControl("PortraitPanel1", nil, item))

        local statePanel = self:getControl("OpenStatePanel", nil, item)

        local boolValue = 1 == SystemSettingMgr:getSettingStatus(FUNCTIONS[i].key, false) and level >= FUNCTIONS[i].need_level

        self:createSwichButton(statePanel, boolValue, self.onSwich, i, self.onLimitSiwtch)

        local nw, ow = self:setColorText(FUNCTIONS[i].desc, "InfoPanel", item, nil, nil, nil, 19)
        if nw > ow then
            local size = item:getContentSize()
            item:setContentSize(size.width, size.height + (nw - ow))
            self:setCtrlContentSize("BackImage", size.width, size.height + (nw - ow), item)
        end
        list:pushBackCustomItem(item)
    end
end

function TeamFixedDlg:refreshFunctionStatus()
    local list = self:getControl("FunctionListView", nil, "FunctionListPanel")
    local data = TeamMgr.fixedTeam
    local level = data and data.level or 0
    local item
    for i = 1, #FUNCTIONS do
        item = self:getControl(FUNCTIONS[i].key, nil, list)
        if item then
            self:switchButtonStatus(self:getControl("OpenStatePanel", nil, item), 1 == SystemSettingMgr:getSettingStatus(FUNCTIONS[i].key) and level >= FUNCTIONS[i].need_level)
        end
    end
end

function TeamFixedDlg:isOtherMemberForReserve(sender)
    local panel = sender:getParent()
    if not panel then return end
    local data = TeamMgr:getFixedTeamMember(panel:getName())
    if not data then return end

    return data.gid ~= Me:queryBasic("gid") and data.level >= 5
end

function TeamFixedDlg:isOtherMemberForCommunicate(sender)
    local panel = sender:getParent()
    if not panel then return end
    local data = TeamMgr:getFixedTeamMember(panel:getName())
    if not data then return end

    return data.gid ~= Me:queryBasic("gid")
end

function TeamFixedDlg:doViewProp(param)
    if string.isNilOrEmpty(param) then return end
    local data = TeamMgr:getFixedTeamMember(param)
    if not data then return end

    ChatMgr:sendUserCardInfo(data.gid)
end

function TeamFixedDlg:doReserve(param)
    if string.isNilOrEmpty(param) then return end
    local data = TeamMgr:getFixedTeamMember(param)
    if not data then return end

    gf:CmdToServer("CMD_FIXED_TEAM_OPEN_SUPPLY_DLG", { gid = data.gid })
end

function TeamFixedDlg:doCommunicate(param)
    if string.isNilOrEmpty(param) then return end
    local data = TeamMgr:getFixedTeamMember(param)
    if not data then return end

    if FriendMgr:isBlackByGId(data.gid) then
        gf:ShowSmallTips(CHS[2000532])
        return
    end

    FriendMgr:communicat(data.name, data.gid, data.icon, data.level, true, data.user_dist or GameMgr:getDistName())
end

function TeamFixedDlg:doViewBlog(param)
    if string.isNilOrEmpty(param) then return end
    local data = TeamMgr:getFixedTeamMember(param)
    if not data then return end

    BlogMgr:openBlog(data.gid)
end

function TeamFixedDlg:onLimitSiwtch(isOn, i)
    local data = TeamMgr.fixedTeam
    local level = data and data.level or 0

    local list = self:getControl("PlayerListView", nil, "PlayerListPanel")
    if level < FUNCTIONS[i].need_level then
        local list = self:getControl("PlayerListView", nil, "PlayerListPanel")
        local item = self:getControl(FUNCTIONS[i].key, nil, list)
        if item then
            self:switchButtonStatus(self:getControl("OpenStatePanel", nil, item), false)
        end
        gf:ShowSmallTips(string.format(CHS[2100279], FUNCTIONS[i].need_level))
        return true
    end
end

function TeamFixedDlg:onSwich(isOn, i)
    SystemSettingMgr:sendSeting(FUNCTIONS[i].key, isOn and 1 or 0)
end

-- 规则说明
function TeamFixedDlg:onInfo1Button()
    self:setCtrlVisible("RulePanel", true, "TeamPlayerPanel")
end

-- 规则说明
function TeamFixedDlg:onInfo2Button()
    self:setCtrlVisible("RulePanel", true, "TeamFunctionPanel")
end

-- 一键组队
function TeamFixedDlg:onAllTeamButton()
    self:setCtrlEnabled("AllInTeamButton", false, "TeamPlayerPanel")
    local countTime = 30 -- 30s倒计时
    gf:CmdToServer("CMD_FIXED_TEAM_ONE_KEY", {})
    local btn = self:getControl("AllInTeamButton", nil, "TeamPlayerPanel")
    self:setLabelText("Label1", string.format("%dS", countTime), btn)
    self:setLabelText("Label2", string.format("%dS", countTime), btn)
    self.queryAction = schedule(btn, function()
        countTime = countTime - 1
        self:setLabelText("Label1", string.format("%dS", countTime), btn)
        self:setLabelText("Label2", string.format("%dS", countTime), btn)
        if countTime <= 0 then
            self:setLabelText("Label1", CHS[2100280], btn)
            self:setLabelText("Label2", CHS[2100280], btn)
            btn:stopAction(self.queryAction)
            self.queryAction = nil
            self:refreshButtonState()
        end
    end, 1)
end

function TeamFixedDlg:onAllOpenButton()
    local opens = {}
    local func
    local data = TeamMgr.fixedTeam
    local level = data and data.level or 0
    for i = 1, #FUNCTIONS do
        func = FUNCTIONS[i]
        if level >= func.need_level and 0 == SystemSettingMgr:getSettingStatus(func.key, false) then
            table.insert(opens, func.key)
        end
    end

    if #opens <= 0 then
        gf:ShowSmallTips(CHS[2100268])
        return
    end

    gf:CmdToServer("CMD_FIXED_TEAM_OPEN_ALL_SETTING")
end

-- 固定队员
function TeamFixedDlg:onTeamPlayerButton(sender)
    self:setCtrlVisible("TeamPlayerPanel", true)
    self:setCtrlVisible("TeamFunctionPanel", false)
    self:refreshTeamInfo()
    self:checkButton(sender)
end

-- 功能设置
function TeamFixedDlg:onTeamFunctionButton(sender)
    self:setCtrlVisible("TeamPlayerPanel", false)
    self:setCtrlVisible("TeamFunctionPanel", true)
    self:checkButton(sender)
    self:refreshFunction()
end

-- 组队
function TeamFixedDlg:onGoTeamButton(sender)
    local panel = sender:getParent()
    if not panel then return end
    local data = TeamMgr:getFixedTeamMember(panel:getName())
    if not data then return end

    gf:CmdToServer("CMD_FIXED_TEAM_ONE_KEY", { gid = data.gid })
end

-- 更多
function TeamFixedDlg:onMoreButton(sender)
    local panel = sender:getParent()
    if not panel then return end
    local panelName = panel:getName()

    local dlg = BlogMgr:showButtonList(self, sender, "teamFixedMore", self.name, panelName)
    local curX, curY = dlg.root:getPosition()
    dlg.root:setPosition(cc.p(curX + 160, curY))
end

function TeamFixedDlg:MSG_FIXED_TEAM_DATA(data)
    self:refreshTeamInfo()
    self:refreshFunction()
    self:refreshFunctionStatus()
end

function TeamFixedDlg:MSG_SET_SETTING(data)
    self:refreshFunctionStatus()
end

function TeamFixedDlg:MSG_FIXED_TEAM_OPEN_SUPPLY_DLG(data)
    DlgMgr:openDlgEx("TeamReserveDlg", data)
end

function TeamFixedDlg:MSG_UPDATE_TEAM_LIST_EX(data)
    self:refreshTeamMembers()
    self:refreshButtonState()
end

return TeamFixedDlg