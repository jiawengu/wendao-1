-- TeamDlg.lua
-- Created by songcw June/11/2015
-- 队伍界面

local TeamDlg = Singleton("TeamDlg", Dialog)

local MutexGroup = require "ctrl/MutexGroup"

local flagGuard     = 0     -- 守护
local flagNomor     = 1     -- 正常不显示
local flagZanli     = 2     -- 暂离
local flagOverLineZanli     = 3     -- 暂离
local flagCaptain   = 4     -- 队长

local PER_PAGE_COUNT                 = 10

local TeamStateFlag = {
    [flagGuard] = ResMgr.ui.team_state_guard,
    [flagNomor] = "",
    [flagZanli] = ResMgr.ui.team_state_zanli,
    [flagCaptain] = ResMgr.ui.team_state_captain,
}

local TASK_LAOJUN_FANU = CHS[6000562]
local TASK_FUMO        = CHS[6000563]
local TASK_XIANGYAO    = CHS[6000564]

local TEAM_MEMBER_MAX_NUM = 5

-- 喊话时间限制
local PROPAGANDA_LIMIT_TIME = 60

-- 战斗指挥选择框单行高度
local COMMAND_PANEL_ROW_HEIGHT = 80

function TeamDlg:init()
    self:bindListener("GuardButton", self.onGuardButton)
    self:bindListener("PlayerAroundButton", self.onPlayerAroundButton)
    self:bindListener("TeamAroundButton", self.onTeamAroundButton)
    self:bindListener("ApplyListButton", self.onApplyListButton)
    self:bindListener("PropagandaButton", self.onPropagandaButton)
    self:bindListener("InviteListButton", self.onInviteListButton)
    self:bindListener("StartButton", self.onStartButton)

    self:bindListener("CreateTeamButton", self.onCreateTeamButton)
    self:bindListener("LeaveTeamButton", self.onLeaveTeamButton)
    self:bindListener("TeamQuickButton", self.onTeamQuickButton)
    self:bindListener("AFKButton", self.onAFKButton)
    self:bindListener("ReturnButton", self.onReturnButton)

    self:bindListener("MyTeamButton", self.onMyTeamButton)
    self:bindListener("RefreshButton", self.onRefreshButton)
    self:bindListener("EmptyButton", self.onEmptyButton)
    self:bindListener("TeamInfoPanel", self.onSettingButton)
    self:bindListener("CommandButton", self.onCommandButton)
    self:setCtrlVisible("CommandButton", FightCommanderCmdMgr:isCommanderFuncOpen())
    self:bindFloatPanelListener("CommandPanel")
    self:bindListener("EditButton", self.onEditCommandButton, "CommandPanel")
    self:bindListener("AppointmentButton", self.onSetCommanderButton, "CommandPanel")
    self:bindTouchCommandPanel()
    for i = 2, TEAM_MEMBER_MAX_NUM do
        self:getControl("GiveBackImage", nil, "TeamPlayerPanel" .. i).index = i
        self:bindListener("GiveBackImage", self.onSelectCommander, "TeamPlayerPanel" .. i)
    end

    if DistMgr:isInKFJJServer() then
        -- 跨服竞技特殊处理
        local levelLabel = self:getControl("LevelLabel")
        levelLabel:setFontSize(17)
        local activeLabel = self:getControl("ActiveLabel")
        activeLabel:setFontSize(17)
        local activeLabel = self:getControl("ActiveTextLabel")
        activeLabel:setFontSize(17)
    end

    self.applyListButtonPos = {}
    self.applyListButtonPos.x, self.applyListButtonPos.y = self:getControl("ApplyListButton"):getPosition()

    -- 周围玩家的panel
    self.aroundPlayerUnitPanel = self:getControl("AroundPlayerUnitPanel")
    self.aroundPlayerUnitPanel:retain()
    self.aroundPlayerUnitPanel:removeFromParent()

    -- 周围队伍的panel
    self.aroundTeamUnitPanel = self:getControl("AroundTeamUnitPanel")
    self.aroundTeamUnitPanel:retain()
    self.aroundTeamUnitPanel:removeFromParent()

    -- 邀请和申请列表的panel
    self.applyUnitPanel = self:getControl("ApplyUnitPanel")
    self.applyUnitPanel:retain()
    self.applyUnitPanel:removeFromParent()

    -- 右上角在线匹配人数
    self:setCtrlVisible("WaitingLabel", false)
    self:setLabelText("WaitingLabel", string.format(CHS[3003731], 0, 0))

    self.start = 1

    self:cleanDlg()
    self:ButtonInit()
    self:displayTeamInfo()
    self:initMemberList()

    self:bindListViewByPageLoad("AroundListView", "TouchPanel", function(dlg, percent)
        if percent > 100 and (self.listType == "zhouweiwanjia" or self.listType == "zhouweiduiwu") then
            -- 下拉获取下一页
            local playersList = self:getPlayersList(self.start,PER_PAGE_COUNT)
            if not next(playersList) then return end
            self:pushData(playersList)
        end
    end)

    self:onMyTeamButton(self:getControl("MyTeamButton"))

    self:hookMsg("MSG_UPDATE_APPEARANCE")
    self:hookMsg("MSG_UPDATE_TEAM_LIST_EX")
    self:hookMsg("MSG_LEADER_COMBAT_GUARD")
    self:hookMsg("MSG_MATCH_SIZE")
    self:hookMsg("MSG_MATCH_TEAM_STATE")
    self:hookMsg("MSG_CLEAN_REQUEST")
    self:hookMsg("MSG_DIALOG")
    self:hookMsg("MSG_REQUEST_LIST")
    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:hookMsg("MSG_CLEAN_ALL_REQUEST")

    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_REQUEST_MATCH_SIZE)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_QUERY_TEAM_EX_INFO)

    if Me:isTeamLeader() then
        -- 队长，刷新申请信息
    gf:CmdToServer("CMD_REFRESH_REQUEST_INFO", {ask_type = "request_join"})
    elseif not Me:isInTeam() then
        -- 不在队伍中，刷新邀请信息
        gf:CmdToServer("CMD_REFRESH_REQUEST_INFO", {ask_type = "invite_join"})
    end

    -- UI拖动有可能无法获取到鼠标松开的情况
    EventDispatcher:addEventListener("EVENT_DO_DRAG", self.onDragEvent, self)
end

function TeamDlg:cleanup()
--    self:releaseCloneCtrl("aroundPanel")
    self:releaseCloneCtrl("aroundPlayerUnitPanel")
    self:releaseCloneCtrl("aroundTeamUnitPanel")
    self:releaseCloneCtrl("applyUnitPanel")

    self:putDown()

    self.onCharInfo = nil
    self.dragging = nil
    self.inCommanderEditMode = nil
    FriendMgr:unrequestCharMenuInfo(self.name)
    EventDispatcher:removeEventListener("EVENT_DO_DRAG", self.onDragEvent, self)
end

function TeamDlg:ButtonInit()

    self.activeName = self.activeName or CHS[5000152]
    self.minValue = self.minValue or 1
    self.maxValue =    self.maxValue or 80

    -- 初始化下方按钮
    self:setCtrlVisible("CreateTeamButton", false)
    self:setCtrlVisible("LeaveTeamButton", false)
    self:setCtrlVisible("TeamQuickButton", false)
    self:setCtrlVisible("GuardButton", false)
    self:setCtrlVisible("AFKButton", false)
    self:setCtrlVisible("ReturnButton", false)

    -- 匹配相关
    self:setCtrlVisible("SettingButton", false)
    self:setCtrlVisible("StartButton", false)


    -- 显示邀请列表还是申请列表
    self:setCtrlVisible("ApplyListButton", false)
    self:setCtrlVisible("InviteListButton", false)

    -- 一键喊话
    self:setCtrlVisible("PropagandaButton", false)
    if Me:isTeamLeader() then
        self:setCtrlVisible("ApplyListButton", true)
        self:setCtrlVisible("PropagandaButton", true)
        local destPos = {}
        destPos.x , destPos.y = self:getControl("TeamAroundButton"):getPosition()
        self:getControl("ApplyListButton"):setPosition(cc.p(destPos.x , destPos.y))
    elseif not Me:isInTeam() then
        self:setCtrlVisible("InviteListButton", true)
    else
        self:setCtrlVisible("ApplyListButton", false)
        self:setCtrlVisible("PropagandaButton", false)
        self:getControl("ApplyListButton"):setPosition(cc.p(self.applyListButtonPos.x , self.applyListButtonPos.y))
    end

    -- 右上角在线匹配人数
    self:setCtrlVisible("WaitingLabel", true)

    self:setCtrlVisible("StartButton", true)

    -- 下方按钮
    if Me:isTeamLeader() then
        -- 我是队长
        self:setCtrlVisible("LeaveTeamButton", true)
        self:setCtrlVisible("GuardButton", true)


    elseif TeamMgr:isTeamMeber(Me) then
        -- 我是队员（不包括暂离）
        self:setCtrlVisible("LeaveTeamButton", true)
        self:setCtrlVisible("AFKButton", true)


    else
        -- 不在队伍（包括暂离）
        if TeamMgr:isLeaveTemp(Me:getId()) or TeamMgr:isOverlineLeaveTemp(Me:getId()) then
            self:setCtrlVisible("LeaveTeamButton", true)
            self:setCtrlVisible("ReturnButton", true)

        else
            self:setCtrlVisible("CreateTeamButton", true)
            self:setCtrlVisible("TeamQuickButton", true)
        end
    end
end

-- 当返回 nil， true 时，可以增加小红点，所以当按钮被选中时，必须返回false
function TeamDlg:onCheckAddRedDot(ctrlName)
    local btn = self:getControl(ctrlName)

    if btn then
        return not self:getCtrlVisible("SelectedImage", btn)
    end
end

function TeamDlg:checkButton(sender)
    if not sender then return end
    local btn = self:getControl("MyTeamButton")
    self:setCtrlVisible("SelectedImage", false, btn)
    btn = self:getControl("PlayerAroundButton")
    self:setCtrlVisible("SelectedImage", false, btn)
    btn = self:getControl("TeamAroundButton")
    self:setCtrlVisible("SelectedImage", false, btn)
    btn = self:getControl("ApplyListButton")
    self:setCtrlVisible("SelectedImage", false, btn)
    btn = self:getControl("InviteListButton")
    self:setCtrlVisible("SelectedImage", false, btn)

    self:setCtrlVisible("SelectedImage", true, sender)
end

function TeamDlg:cleanDlg()
    -- 5个位置初始化
    for i = 1, 5 do
        local panel = self:getControl("TeamPlayerPanel" .. i)
        self:setPlayerInfo(panel)
    end
end

-- 初始化队伍成员
function TeamDlg:initMemberList()
    local members = TeamMgr.members_ex
    self:clearCtrlMagic()

    if #members == 0 then
        -- Me单人没有队伍
        self:displayNoTeam()
    else
        self:displayTeamMembers()
    end

    -- 刷新指挥选择
    self:refreshCommanderSelectPanel()

    -- 刷新指挥标记
    self:refreshCommanderIcon()
end

-- 清除队伍界面仙魔光效
function TeamDlg:clearCtrlMagic()
    for i = 1, TEAM_MEMBER_MAX_NUM do
        self:removeUpgradeMagicToCtrl("PortraitPanel1", "TeamPlayerPanel" .. i)
    end
end

function TeamDlg:checkTeamPlayerPanelIntersect(curPanel)
    if not curPanel then return end

    local members = TeamMgr.members_ex
    local rect1 = self:getBoundingBoxInWorldSpace(curPanel)
    local parentCtrl = curPanel.cloneParent
    for i = 2, #members do
            local panel = self:getControl("TeamPlayerPanel" .. i)
        if panel ~= parentCtrl then
                local rect2 = self:getBoundingBoxInWorldSpace(panel)
                local rect3 = cc.rectIntersection(rect1, rect2)
                if rect3.width > rect1.width * 0.7 and rect3.height > rect1.height * 0.7 and members[i].type == OBJECT_TYPE.CHAR and TeamMgr:inTeam(members[i].id) then
                    return i
                end
            end
        end
end

-- 拿起成员条目
function TeamDlg:takeUp()
    if self.cloneCell then
        self.cloneCell:removeFromParent()
        self.cloneCell = nil
    end

    if not self.dragging then
        return
    end

    local panel = self.dragging[1]
    local dlg = DlgMgr:getDlgByName("TeamTabDlg")
    if dlg then
        local cell = panel:clone()
        panel:getParent():addChild(cell)
        self.cloneCell = cell
        self.cloneCell.cloneParent = panel
        panel:setVisible(false)
        self:moveToOtherParent(cell, dlg.blank)

        self:setMemberInfo(cell, self.dragging[5])
        else
        -- 拿起失败
        self.dragging = nil
        end
end

-- 放下成员条目
function TeamDlg:putDown(needMove)
    if self.cloneCell then
        self.cloneCell:removeFromParent()
        self.cloneCell = nil
    end

    if not self.dragging then
        return
    end

    local panel = self.dragging[1]
    if not needMove then
        -- 不需要换位直接显示，需要换位要等收到服务器数据再显示
        panel:setVisible(true)
    end

    self.dragging = nil

    return true
end

function TeamDlg:setMemberInfo(panel, info)
    local status = self:getMembersStatus(info.id)
    local portrait = info.org_icon
    local weapon = 0
    local cardIcon = InventoryMgr:getIconByName(info.card_name)

        -- 显示变身头像
    if info.suit_icon ~= 0 and gf:isShowSuit() then
        portrait = info.suit_icon
        end

        -- 显示武器头像
        if gf:isShowWeapon() then
        weapon = info.weapon_icon
        end
    self:setPlayerInfo(panel, portrait, weapon, info.org_icon, info.name, info.level, info.polar, status, cardIcon, info["party/name"] or "", info["upgrade/type"], info["light_effect"], info.part_index, info.part_color_index)

    self:setCtrlVisible("BackPlayerImage", info.comeback_flag == 1, panel)
end

function TeamDlg:canDragMember()
    if Me:isTeamLeader() then return true end

    local leader = TeamMgr:getLeader()
    if not TeamMgr:getFixedTeamMember(leader.gid) then return end

    local count = 0
    local m
    for i = 1, #TeamMgr.members_ex do
        m = TeamMgr.members_ex[i]
        if TeamMgr:getFixedTeamMember(m.gid) then
            count = count + 1
        end
    end

    if count < 3 then return end
    local data = TeamMgr.fixedTeam
    if not data then return end
    local level = data.level or 0
    if level < 5 then return end
    return true
end

-- 队伍成员信息
function TeamDlg:displayTeamMembers()
    local members = TeamMgr.members_ex
    for i, v in ipairs(members) do
        local panel = self:getControl("TeamPlayerPanel" .. i)
        panel:setVisible(true)

        self:setMemberInfo(panel, v)

        local dragAction
        local lastTouchPos
        local curIndex = i
        local selectIndex
        local lastPosX, lastPosY = panel:getPosition()
        panel:setTouchEnabled(true)
        panel.oldParent = panel:getParent()
        panel:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.began then
                lastTouchPos = nil
                if self.dragging then return end
                self.dragging = nil

                if curIndex ~= 1 and TeamMgr:inTeam(members[i].id) and members[i].type == OBJECT_TYPE.CHAR then
                    -- 队长不可移动
                    dragAction = performWithDelay(panel, function()
                        dragAction = nil
                        if self.dragging then return end

                        local touchPos = GameMgr.curTouchPos
                        local rect = self:getBoundingBoxInWorldSpace(panel)
                        if cc.rectContainsPoint(rect, touchPos) and self:canDragMember() then
                            -- 拿起
                            lastTouchPos = GameMgr.curTouchPos
                            self.dragging = { panel, lastPosX, lastPosY, panel:getLocalZOrder(), v}
                            self:takeUp()
                        end
                    end, 0.1)
                end
            elseif eventType == ccui.TouchEventType.moved then
                if not lastTouchPos then return end
                if not self.dragging then
                    lastTouchPos = nil
                    return
                end
                if self.dragging and self.dragging[1] ~= panel then return end
                if not self.cloneCell then return end

                local touchPos = GameMgr.curTouchPos
                local offsetX, offsetY = touchPos.x - lastTouchPos.x, touchPos.y - lastTouchPos.y
                local curX, curY = self.cloneCell:getPosition()
                self.cloneCell:setPosition(curX + offsetX, curY + offsetY)
                lastTouchPos = touchPos
            elseif eventType == ccui.TouchEventType.ended
                   or eventType == ccui.TouchEventType.canceled then
                if self.dragging and panel ~= self.dragging[1] then return end
                lastTouchPos = nil
                if dragAction then
                    panel:stopAction(dragAction)
                    dragAction = nil
                end

                -- 拖动后续处理
                if self.dragging then
                    selectIndex = self:checkTeamPlayerPanelIntersect(self.cloneCell)
                    if selectIndex then
                        local fromId = members[curIndex].id
                        local toId = members[selectIndex].id
                        gf:CmdToServer("CMD_TEAM_CHANGE_SEQUENCE", { old_id = fromId, new_id = toId, old_pos = math.max(0, curIndex - 1), new_pos = math.max(0, selectIndex - 1) })
                        -- 先不能放下，等收到消息再放下
                        -- 清除数据防止 cancelDragging 中弹出提示
                        self.dragging = nil
                    else
                        self:putDown()
                    end
                    return
                end

                if v == nil then return end
                if eventType ~= ccui.TouchEventType.ended then return end

                if v.gid == Me:queryBasic("gid") then
                    -- 如果为自己，且自己是队长，则会弹出菜单（目前仅包括一键召集）
                    if Me:isTeamLeader() then
                        local dlg = DlgMgr:openDlg("FloatingMenuDlg")
                        dlg:setData(v)
                        dlg:setIndex(i, self:getBoundingBoxInWorldSpace(panel))
                    end

                    return
                end
                if v.type == OBJECT_TYPE.MONSTER or v.type == OBJECT_TYPE.NPC or v.type == OBJECT_TYPE.FOLLOW_NPC then
                    gf:ShowSmallTips(CHS[4000395])
                    return
                end
                TeamMgr.selectMember = v
                local dlg = DlgMgr:openDlg("FloatingMenuDlg")
                dlg:setData(v)
                dlg:setIndex(i, self:getBoundingBoxInWorldSpace(panel))
            end
        end)
    end

    if #members >= 5 then return end
    local guardPos = 1
    for i = #members + 1,5 do
        local panel = self:getControl("TeamPlayerPanel" .. i)
        local v = TeamMgr.captainGuards[guardPos] or nil
        if v then
            self:setPlayerInfo(panel, v.guardIcon, v.weapon_icon, v.org_icon, v.guardName, v.guardLevel, nil, flagGuard, nil, "", v["upgrade/type"], v["light_effect"], v.part_index, v.part_color_index)
        else
            self:setPlayerInfo(panel, nil)
        end

        self:setCtrlVisible("BackPlayerImage", false, panel)

        guardPos = guardPos + 1
        panel:setTouchEnabled(true)
        panel:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if Me:isTeamLeader() then
                    if v then
                        local dlg = DlgMgr:openDlg("TeamGuardMenuDlg")
                        dlg:setSelectGuardId(v.guardId)
                        dlg:setIndex(i, self:getBoundingBoxInWorldSpace(panel))
                    else
                        if not self:isHaveRestGuard() then
                            gf:ShowSmallTips(CHS[3003732])
                        else
                            local dlg = DlgMgr:openDlg("TeamGuardMenuDlg")
                            dlg:setSelectGuardId(0)
                            dlg:setIndex(i, self:getBoundingBoxInWorldSpace(panel))
                        end
                    end
                else
                    gf:ShowSmallTips(CHS[3003733])
                end
            end
        end)
    end
end

function TeamDlg:cancelDragging(notShowTip)
    if self:putDown() and not notShowTip then
        gf:ShowSmallTips(CHS[2200094])
    end
end

-- 获取队伍成员状态
function TeamDlg:isHaveRestGuard()

    for _, v in pairs(GuardMgr.objs) do
        if v:queryInt("combat_guard") == 0 then
            return true
        end
    end

    return false
end

-- 获取队伍成员状态
function TeamDlg:getMembersStatus(id)
    if id == TeamMgr:getLeaderId() then
        return flagCaptain
    end

    if TeamMgr:isLeaveTemp(id) then
        return flagZanli
    end

    if TeamMgr:isOverlineLeaveTemp(id) then
        return flagOverLineZanli
    end

    return flagNomor
end

-- 队伍信息
function TeamDlg:displayTeamInfo(activeName, minLevel, maxLevel, polars, minTao, maxTao)
    self.activeName = activeName or TeamMgr:getCurMatchInfo().name
    self.minValue = minLevel or TeamMgr:getCurMatchInfo().minLevel
    self.maxValue = maxLevel or TeamMgr:getCurMatchInfo().maxLevel
    self.polars = polars or TeamMgr:getCurMatchInfo().polars
    self.minTao = minTao or TeamMgr:getCurMatchInfo().minTao
    self.maxTao = maxTao or TeamMgr:getCurMatchInfo().maxTao

    if (not self.minValue or self.minValue == 0) and self.activeName ~= ""then
        self.minValue, self.maxValue = TeamMgr:getActiveRange(self.activeName)
    end

    if self.activeName == "" then
        if DistMgr:isInKFJJServer() then
            -- 跨服竞技
            self.activeName = KuafjjMgr:getTeamActiveName()
            self.minValue, self.maxValue = KuafjjMgr:getDefaultLevel()
        else
            self.activeName = CHS[3003734]
            self.minValue = TeamMgr:getMinLevelActive(self.activeName)
            self.maxValue = TeamMgr:getMaxLevelActive(self.activeName)
        end
    end

    local teamInfoPanel = self:getControl("TeamInfoPanel")
    if TeamMgr:getCurMatchInfo().state == 0 then
        -- 不在匹配队伍中
        self:setCtrlVisible("ActiveLabel", true, teamInfoPanel)
        self:setCtrlVisible("LevelLabel", true, teamInfoPanel)
        self:setLabelText("ActiveTextLabel", CHS[3003735], teamInfoPanel)
        self:setLabelText("ActiveLabel", self.activeName, teamInfoPanel)
        -- self:setLabelText("LevelLabel", string.format("(%d - %d)", self.minValue or 0, self.maxValue or 0), teamInfoPanel)
        self:setMatchCondition(self.minValue or 0, self.maxValue or 0, self.polars, self.minTao,  self.maxTao)
        self:updateLayout("TeamInfoPanel")
        if #TeamMgr.members_ex == 0 then
            self:setLabelText("LevelLabel", "")
        end

        local stButton = self:getControl("StartButton")
        self:setLabelText("Label1", CHS[3003736], stButton)
        self:setLabelText("Label2", CHS[3003736], stButton)
    else
        if #TeamMgr.members_ex == 0 then
            self:setLabelText("ActiveLabel", self.activeName, teamInfoPanel)
            self:setLabelText("LevelLabel", "", teamInfoPanel)
            self:setLabelText("ActiveTextLabel", CHS[3003735])
            local stButton = self:getControl("StartButton")
            stButton:setVisible(true)
            self:setLabelText("Label1", CHS[3003737], stButton)
            self:setLabelText("Label2", CHS[3003737], stButton)
        else
            self:setCtrlVisible("ActiveLabel", true, teamInfoPanel)
            self:setCtrlVisible("LevelLabel", true, teamInfoPanel)
            self:setLabelText("ActiveTextLabel", CHS[3003735], teamInfoPanel)
            self:setLabelText("ActiveLabel", self.activeName, teamInfoPanel)
            -- self:setLabelText("LevelLabel", string.format("(%d - %d)", self.minValue or 0, self.maxValue or 0), teamInfoPanel)
            self:setMatchCondition(self.minValue or 0, self.maxValue or 0, self.polars, self.minTao,  self.maxTao)

            local stButton = self:getControl("StartButton")
            self:setLabelText("Label1", CHS[3003737], stButton)
            self:setLabelText("Label2", CHS[3003737], stButton)
            self:updateLayout("TeamInfoPanel")
        end
    end

    self:updateLayout("TeamInfoPanel")
end

-- Me没有队伍状态
function TeamDlg:displayNoTeam()
--    if TeamMgr:getCurMatchInfo().state == 0 or TeamMgr:getCurMatchInfo().state == 1 then
        local panel = self:getControl("TeamPlayerPanel1")
        -- 第一个位置设置Me
    self:setPlayerInfo(panel, Me:getDlgIcon(true, true), Me:getDlgWeaponIcon(true, true), Me:queryBasicInt('icon'), Me:getName(),
        Me:queryBasicInt("level"), Me:queryBasicInt("polar"), flagNomor, nil, Me:queryBasic('party/name'), Me:queryBasicInt("upgrade/type"), Me:queryBasic("light_effect"), Me:getDlgPartIndex(true), Me:getDlgPartColorIndex(true))

        panel:setTouchEnabled(false)

        -- 参战守护
        local fightGuard = {}
        if #TeamMgr.captainGuards == 0 then
            fightGuard = GuardMgr:getGuardListByFight(true)
        else
            for i = 1, #TeamMgr.captainGuards do
                fightGuard[i] = {}
                fightGuard[i].icon = TeamMgr.captainGuards[i].guardIcon
                fightGuard[i].name = TeamMgr.captainGuards[i].guardName
                fightGuard[i].level = TeamMgr.captainGuards[i].guardLevel
                fightGuard[i].polar = GuardMgr:getGuardPolar(fightGuard[i].name)
                fightGuard[i].id = TeamMgr.captainGuards[i].guardId
            end
        end
        self:setCtrlVisible("BackPlayerImage", false, panel)

        if #fightGuard == 0 then fightGuard = GuardMgr:getGuardListByFight(true) end
        for i = 2, 5 do
            local panel = self:getControl("TeamPlayerPanel" .. i)
            if fightGuard[i - 1] then
                self:setPlayerInfo(panel, fightGuard[i - 1].icon, nil, nil, fightGuard[i - 1].name, fightGuard[i - 1].level, fightGuard[i - 1].polar, flagGuard, nil, "")
            else
                self:setPlayerInfo(panel, nil)
            end

            self:setCtrlVisible("BackPlayerImage", false, panel)

            panel:setTouchEnabled(true)
            panel:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    if fightGuard[i - 1] == nil then
                        if self:isHaveRestGuard() then
                            local dlg = DlgMgr:openDlg("TeamGuardMenuDlg")
                            dlg:setSelectGuardId(0)
                            dlg:setIndex(i, self:getBoundingBoxInWorldSpace(panel))
                        else
                            gf:ShowSmallTips(CHS[3003732])
                        end
                        return
                    end
                    local dlg = DlgMgr:openDlg("TeamGuardMenuDlg")
                    dlg:setSelectGuardId(fightGuard[i - 1].id)
                    dlg:setIndex(i, self:getBoundingBoxInWorldSpace(panel))
                end
            end)
        end
--    end
end

-- 获取参战中的守护
function TeamDlg:getFightGuard()
    local guards = GuardMgr.objs
    local fightArr = {}
    for k, v in pairs(guards) do
        if v:queryBasicInt("combat_guard") == 1 then
            table.insert(fightArr, {id = v:queryBasicInt("id"), combat_guard = v:queryBasicInt("combat_guard"), name = v:queryBasic("name"), level = v:queryBasicInt("level"),
                icon = v:queryBasic("icon"), rank = v:queryBasicInt("rank"), polar = v:queryBasic("polar"), use_skill_d = v:queryBasicInt("use_skill_d")})
        end
    end

    -- 排序规则
    local function sort(l, r)
        return self:sortFunc(l, r)
    end

    -- 分别对参战与休息状态的守护进行排序
    table.sort(fightArr, sort)

    return fightArr
end

-- 参战和辅助状态的守护在列表最上方，之下为休息状态的守护
-- 各状态内部按照长老、弟子、童子的阶位顺序从上往下排列
-- 各阶位内部按照金木水火土的顺序由上往下排列
function TeamDlg:sortFunc(l, r)
    if l.use_skill_d > r.use_skill_d then return true
    elseif l.use_skill_d < r.use_skill_d then return false
    end

    if l.rank > r.rank then return true
    elseif l.rank < r.rank then return false
    end

    if l.polar < r.polar then return true
    else return false
    end
end

-- 守护 status:0

function TeamDlg:setPlayerInfo(panel, icon, weapon, orgIcon, name, level, polar, status, cardIcon, partyName, upgradeState, lightEffects, partIndexs, partColorIndexs)
    if icon == nil then
        self:removePortrait("PortraitPanel1", panel)
        self:setLabelText("PartyLabel", "", panel)
        self:setLabelText("NameLabel", "", panel)
        self:setLabelText("LevelLabel", "", panel)
        self:setCtrlVisible("StatusImage", false, panel)
        self:setCtrlVisible("BlackImage", false, panel)
        self:setCtrlVisible("OverlineStatusImage", false, panel)
        self:setCtrlVisible("AFKBackImage", false, panel)
        self:setCtrlVisible("CardImage", false, panel)
        self:setCtrlVisible("CommandImage", false, panel)
        self:setCtrlVisible("GiveBackImage", false, panel)

        self:getControl("BackImage1", nil, panel):setVisible(false)
        return
    end

    local realName, flagName = gf:getRealNameAndFlag(name)
    local char = self:setPortrait("PortraitPanel1", icon, weapon, panel, nil, nil, nil, cc.p(6, -46), orgIcon, nil, nil, nil, nil, partIndexs, partColorIndexs)
    -- 仙魔光效
    if upgradeState then
        self:addUpgradeMagicToCtrl("PortraitPanel1", upgradeState, panel, true)
    end

    if flagName then
        self:setLabelText("PartyLabel", flagName, panel)
    else
        self:setLabelText("PartyLabel", partyName, panel)
    end

    self:setLabelText("NameLabel", realName, panel)
    self:setLabelText("LevelLabel", "LV." .. level, panel)

    -- 设置变身卡图片
    if cardIcon then
        self:setCtrlVisible("CardImage", true, panel)
        self:setImage("CardImage", ResMgr:getItemIconPath(cardIcon), panel)
        self:setItemImageSize("CardImage", panel)
    else
        self:setCtrlVisible("CardImage", false, panel)
    end

    -- 盘子
    self:getControl("BackImage1", nil, panel):setVisible(true)

    -- 不需要根据相性显示不同的底盘
    --[[self:setImage("BackImage1", plateColor[1], panel)
    if polar == nil then
        self:setImage("BackImage1", plateColor[1], panel)
    else
        self:setImage("BackImage1", plateColor[polar], panel)
    end]]

    self:setStatus(status, panel)
end

-- 设置队长or守护标识，以及光效
function TeamDlg:setStatus(flag, panel)
    self:setCtrlVisible("StatusImage", false, panel)
    self:setCtrlVisible("BlackImage", false, panel)
    self:setCtrlVisible("AFKBackImage", false, panel)
    self:setCtrlVisible("OverlineStatusImage", false, panel)
    if flag == flagNomor then
    elseif flag == flagCaptain then
        self:setCtrlVisible("StatusImage", true, panel)
        self:setCtrlVisible("StatusImage", true, panel)
    elseif flag == flagGuard then
        -- 守护
        self:setCtrlVisible("StatusImage", true, panel)
        self:setCtrlVisible("BlackImage", true, panel)
    else
        if flag == flagZanli then
            self:setCtrlVisible("AFKBackImage", true, panel)
            self:setCtrlVisible("StatusImage", true, panel)
        elseif flag == flagOverLineZanli then
            self:setCtrlVisible("AFKBackImage", true, panel)
            self:setCtrlVisible("OverlineStatusImage", true, panel)
        end
        self:setCtrlVisible("BlackImage", true, panel)
    end

    self:setImage("StatusImage", TeamStateFlag[flag], panel)
end

function TeamDlg:onGuardButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if not GuideMgr:isIconExist(5) then
        gf:ShowSmallTips(CHS[3003738])
        return
    end

    local last = DlgMgr:getLastDlgByTabDlg('GuardTabDlg') or 'GuardAttribDlg'
    DlgMgr:openDlg(last)
end

-- 获取周围玩家（单人）
function TeamDlg:getAroundPlayers()
    local chars = CharMgr.chars
    local order = {}
    for k, v in pairs(chars) do
        if v:getType() == "Player" and
            not v:isInTeam() and
            v:getId() ~= Me:getId() and
            not TeamMgr:inTeamEx(v:getId()) then
            table.insert(order, v)
        end
    end

    return order
end

function TeamDlg:setButtonContent(btn, content, panel)
    btn = self:getControl(btn, nil, panel)
    self:setLabelText("Label1", content, btn)
    self:setLabelText("Label2", content, btn)
end

function TeamDlg:setUnitByPanel(char, panel, displayType)
    if not char then
        panel:setVisible(false)
        return
    end

    panel.charName = char.name

    -- 设置信息
    local icon = char.org_icon
    self:setImage("BackImage2", ResMgr:getSmallPortrait(icon), panel)
    self:setItemImageSize("BackImage2", panel)

    local portraitPanel = self:getControl("PortraitPanel1", nil, panel)
    portraitPanel:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            FriendMgr:requestCharMenuInfo(char.gid, self.name)
            local rect = self:getBoundingBoxInWorldSpace(sender)

            self.onCharInfo = function(self, gid)
            local dlg = DlgMgr:openDlg("CharMenuContentDlg")
                if dlg then
                    dlg:setting(gid)
            dlg:setFloatingFramePos(rect)
        end
            end
        end
    end)

    self:setNumImgForPanel("BackImage2", ART_FONT_COLOR.NORMAL_TEXT, char.level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)
    self:setLabelText("NameLabel", gf:getRealName(char.name), panel)

    if DistMgr:isInKFZCServer() then
        self:setLabelText("PartyLabel", string.match(char.name, "(.+)-") or "", panel)
    elseif char.stageStr and char.stageStr ~= "" then
        self:setLabelText("PartyLabel", char["stageStr"], panel)
    else
        self:setLabelText("PartyLabel", char["party/name"], panel)
    end

    -- 跨服战场的匹配模式
    if char.combat_mode then
        local str = char.combat_mode
        if str == "" then
            str = CHS[5400418]
        end

        self:setLabelText("SellStateValueLabel_1", str, panel)
        self:setLabelText("SellStateValueLabel_2", str, panel)
        self:setCtrlVisible("TypePanel", true, panel)
    else
        self:setCtrlVisible("TypePanel", false, panel)
    end

    -- 根据类型隐藏、显示控件
    self:setCtrlVisible("BackPlayerImage", char.comeback_flag == 1, panel)

    self:setCtrlVisible("InviteButton", false, panel)
    self:setCtrlVisible("InvitedButton", false, panel)
    self:setCtrlVisible("ApplyButton", false, panel)
    self:setCtrlVisible("AppliedButton", false, panel)
    self:setCtrlVisible("NumPanel", false, panel)
    self:setCtrlVisible("AgreeButton", false, panel)
    self:setCtrlVisible("DenyButton", false, panel)

    if displayType == "zhouweiwanjia" then
        local btn = self:getControl("InviteButton", nil, panel)
        btn:setVisible(true)
        btn:addTouchEventListener(function(sender, eventType)

            if Me:isInPrison() then
                gf:ShowSmallTips(CHS[7000071])
                return
            end

            if eventType == ccui.TouchEventType.ended then
                local panel = sender:getParent()
                if TeamMgr:requestJionTeam(panel.charName, Const.INVITE_JOIN_TEAM) then
                    self:setButtonContent("InviteButton", CHS[3003739], panel)
                    self:setCtrlEnabled("InviteButton", false, panel)

                end
            end
        end)
    elseif displayType == "zhouweiduiwu" then
        local btn = self:getControl("ApplyButton", nil, panel)
        btn:setVisible(true)
        btn:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local panel = sender:getParent()
                if TeamMgr:requestJionTeam(panel.charName, Const.REQUEST_JOIN_TEAM) then
                    self:setButtonContent("ApplyButton", CHS[3003749], panel)
                    self:setCtrlEnabled("ApplyButton", false, panel)
                end
            end
        end)

        local numPanel = self:getControl("NumPanel", nil, panel)
        numPanel:setVisible(true)
        for i = 1, 5 do
            -- 队伍个数
            self:setCtrlVisible("Image_" .. i, i <= char.teamMembersCount, numPanel)
        end
    elseif displayType == "zuduiyaoqing" or displayType == "zuduishenqing" then
        local agreeButton = self:getControl("AgreeButton", nil, panel)
        local denyButton = self:getControl("DenyButton", nil, panel)

        agreeButton:setVisible(true)
        denyButton:setVisible(true)

        if displayType == "zuduiyaoqing" then
            panel.askType = Const.INVITE_JOIN_TEAM
        else
            panel.askType = Const.REQUEST_JOIN_TEAM
        end
        -- 绑定点击
        agreeButton:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local panel = sender:getParent()
                TeamMgr:acceptTeamByType(panel.charName, panel.askType)
            end
        end)

        denyButton:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local panel = sender:getParent()
                TeamMgr:denyTeamByType(panel.charName, panel.askType)
            end
        end)
    end
end

function TeamDlg:setListInfo(displayType, playerList)
    if not displayType then return end
    if not self:getCtrlVisible("TeamAroundPanel") then return end

    self.listType = displayType
    if displayType == "zhouweiwanjia" then
        playerList = playerList or TeamDlg:getAroundPlayers()
    elseif displayType == "zhouweiduiwu" then
        playerList = playerList or TeamDlg:getAroundTeams()
    elseif displayType == "zuduiyaoqing" then
        playerList = TeamMgr.inviters
    elseif displayType == "zuduishenqing" then
        playerList = TeamMgr.requesters
    end

    if next(playerList) == nil then
        -- 如果列表为空
        self:setCtrlVisible("AroundListView", false)
        local noticePanel = self:getControl("NoticePanel")
        noticePanel:setVisible(true)
        self:setCtrlVisible("InfoPanel1", false)
        self:setCtrlVisible("InfoPanel2", false)
        self:setCtrlVisible("InfoPanel3", false)
        self:setCtrlVisible("InfoPanel4", false)
        if displayType == "zhouweiwanjia" then
            self:setCtrlVisible("InfoPanel1", true)
        elseif displayType == "zhouweiduiwu" then
            self:setCtrlVisible("InfoPanel2", true)
        elseif displayType == "zuduiyaoqing" then
            self:setCtrlVisible("InfoPanel3", true)
        elseif displayType == "zuduishenqing" then
            self:setCtrlVisible("InfoPanel4", true)
        end
        return
    end
    self:setCtrlVisible("NoticePanel", false)
    self:setCtrlVisible("AroundListView", true)
    local line = math.floor(#playerList / 2) + #playerList % 2

    local arountListView = self:resetListView("AroundListView", 0, ccui.ListViewGravity.centerVertical)
    arountListView:getInnerContainer():setPosition(cc.p(0,0))
    for i = 1, line do
        local panel = self:getListUnitPanel()
        local player1 = playerList[(i - 1) * 2 + 1]
        self:setUnitByPanel(player1, self:getControl("UnitPanel1", nil, panel), displayType)

        local player2 = playerList[(i - 1) * 2 + 2]
        self:setUnitByPanel(player2, self:getControl("UnitPanel2", nil, panel), displayType)
        arountListView:pushBackCustomItem(panel)
    end
 --   ccui.ListView:jumpToTop()
    arountListView:jumpToTop()
end

function TeamDlg:showMyTeam(isShowMyTeam)
    self:setCtrlVisible("TeamPlayerPanel", isShowMyTeam)
    self:setCtrlVisible("TeamAroundPanel", isShowMyTeam == false)

    self:setCtrlVisible("MyTeamDownPanel", isShowMyTeam)
    self:setCtrlVisible("AroundTeamDownPanel", isShowMyTeam == false)
    if isShowMyTeam then return end
    local panel = self:getControl("AroundTeamDownPanel")
    local emptyBtn = self:getControl("EmptyButton", nil, panel)
    local refreshBtn = self:getControl("RefreshButton", nil, panel)

    emptyBtn:setVisible(false)
    refreshBtn:setVisible(false)
    if self.listType == "zuduiyaoqing" or self.listType == "zuduishenqing" then
        emptyBtn:setVisible(true)
    else
        refreshBtn:setVisible(true)
    end
end

function TeamDlg:onMyTeamButton(sender, eventType)
    self:getControl("AroundListView"):removeAllItems()
    self:checkButton(sender)
    self:showMyTeam(true)
end

function TeamDlg:onRefreshButton(sender, eventType)
    if self.listType == "zhouweiwanjia" then
        self:onPlayerAroundButton()
    elseif self.listType == "zhouweiduiwu" then
       self:onTeamAroundButton()
    elseif self.listType == "zuduiyaoqing" then
        self:onInviteListButton()
    elseif self.listType == "zuduishenqing" then
        self:onApplyListButton()
    end
end

function TeamDlg:onEmptyButton(sender, eventType)
    if self.listType == "zuduiyaoqing" then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_REMOVE_ALL_INVITE)
    elseif self.listType == "zuduishenqing" then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_REMOVE_ALL_JOIN)
    end
end

-- 绑定选择指挥区域的事件
function TeamDlg:bindTouchCommandPanel()
    local panel = self:getControl("TouchCommandPanel")
    local commandImageList = {}
    for i = 2, TEAM_MEMBER_MAX_NUM do
        table.insert(commandImageList, self:getControl("GiveBackImage", nil, "TeamPlayerPanel" .. i))
    end

    local function onTouchBegan(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        local notTouchedCommandImage = true
        for i = 1, #commandImageList do
            local pos = commandImageList[i]:getParent():convertToNodeSpace(touchPos)
            local box = commandImageList[i]:getBoundingBox()
            if commandImageList[i]:isVisible() and box and cc.rectContainsPoint(box, pos) then
                -- 点击到了显示的指挥选择图片
                notTouchedCommandImage = false
            end
        end

        if notTouchedCommandImage then
            self.inCommanderEditMode = false
            self:refreshCommanderSelectPanel()
        end

        return false
    end

    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)

    -- 添加监听
    local dispatcher = panel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

-- 选择指挥，分配权限
function TeamDlg:onSelectCommander(sender, eventType)
    local index = sender.index
    if TeamMgr.members[index] then
        FightCommanderCmdMgr:requestSetCommander(TeamMgr.members[index].gid, 1)
    end

    self.inCommanderEditMode = false
end

-- 点击战斗指挥按钮
function TeamDlg:onCommandButton(sender, eventType)
    local panel = self:getControl("CommandPanel")
    if panel:isVisible() then
        panel:setVisible(false)
    else
        local sz = panel:getContentSize()
        if Me:isTeamLeader() then
            self:setCtrlVisible("AppointmentButton", true, panel)
            sz.height = COMMAND_PANEL_ROW_HEIGHT + 64
        else
            self:setCtrlVisible("AppointmentButton", false, panel)
            sz.height = COMMAND_PANEL_ROW_HEIGHT
        end

        panel:setContentSize(sz)
        panel:setVisible(true)
        panel:requestDoLayout()
    end
end

function TeamDlg:onEditCommandButton(sender, eventType)
    self:getControl("CommandPanel"):setVisible(false)
    DlgMgr:openDlg("FightCommanderCmdEditDlg")
end

function TeamDlg:onSetCommanderButton(sender, eventType)
    self:getControl("CommandPanel"):setVisible(false)

    local teamMembers = FightCommanderCmdMgr:getTeamMembers()

    if not teamMembers.count or teamMembers.count < 2 then
        -- 单人队伍
        gf:ShowSmallTips(CHS[7190420])
        return
    end

    if teamMembers.count == 2 and FightCommanderCmdMgr:isCommander(teamMembers[2].gid) then
        -- 2人队伍，且队员已经是指挥
        gf:ShowSmallTips(CHS[7190421])
        return
    end

    -- 进入指挥选择模式
    self:setEditCommanderMode()
end

-- 进入指挥选择模式
function TeamDlg:setEditCommanderMode()
    self.inCommanderEditMode = true
    self:refreshCommanderSelectPanel()
end

-- 刷新指挥选择控件
function TeamDlg:refreshCommanderSelectPanel()
    for i = 2, TEAM_MEMBER_MAX_NUM do
        local panel = self:getControl("TeamPlayerPanel" .. i)
        if self.inCommanderEditMode and FightCommanderCmdMgr:checkCanGiveCommander(i) then
            self:setCtrlVisible("GiveBackImage", true, panel)
        else
            self:setCtrlVisible("GiveBackImage", false, panel)
        end
    end
end

-- 刷新指挥图标
function TeamDlg:refreshCommanderIcon()
    for i = 2, TEAM_MEMBER_MAX_NUM do
        local panel = self:getControl("TeamPlayerPanel" .. i)
        if TeamMgr.members[i] and FightCommanderCmdMgr:isCommander(TeamMgr.members[i].gid) then
            self:setCtrlVisible("CommandImage", true, panel)
        else
            self:setCtrlVisible("CommandImage", false, panel)
        end
    end
end

function TeamDlg:onPlayerAroundButton(sender, eventType)
    -- 隐藏队伍列表，显示周围列表
    -- 请求周围玩家列表
    self.listType = "zhouweiwanjia"
    self:getControl("AroundListView"):removeAllItems()
    self:showMyTeam(false)
    self:checkButton(sender)
    if DistMgr:isInKFJJServer() then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_QUERY_TEAM_INFO, Const.CSC_AROUND_PLAYER)
    else
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_QUERY_TEAM_INFO, Const.AROUND_PLAYER)
    end
end

function TeamDlg:getAroundTeams()
    local chars = CharMgr.chars
    local order = {}
    for _, v in pairs(chars) do
        if v:getType() == "Player" and
            v:isTeamLeader() and
            v:getId() ~= Me:getId() then
            table.insert(order, v)
        end
    end

    return order
end

function TeamDlg:onTeamAroundButton(sender, eventType)
    -- 隐藏队伍列表，显示周围列表
    -- 请求周围玩家列表
    self.listType = "zhouweiduiwu"
    self:getControl("AroundListView"):removeAllItems()
    self:showMyTeam(false)
    self:checkButton(sender)

    if DistMgr:isInKFJJServer() then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_QUERY_TEAM_INFO, Const.CSC_AROUND_TEAM)
    else
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_QUERY_TEAM_INFO, Const.AROUND_TEAM)
    end
end

function TeamDlg:onPropagandaButton(sender, eventType)
    if DistMgr:isInQMPKServer() then
        gf:ShowSmallTips(CHS[5400422])
        return
    end

    if self.activeName == nil or self.activeName == CHS[3003734] or self.activeName == "" then
        gf:ShowSmallTips(CHS[3003740])
        return
    end

    -- 有老君发怒时不能匹配刷道活动
    if TaskMgr:isExistTaskByName(TASK_LAOJUN_FANU) then
        if self.activeName == TASK_FUMO or self.activeName == TASK_XIANGYAO then
            gf:ShowSmallTips(CHS[6000561])
            return
        end
    end

    if DistMgr:isInKFJJServer()
        and not (self.minTao and self.minTao > 0 and self.maxTao and self.maxTao > 0) then
        gf:ShowSmallTips(CHS[5410216])
        return
    end

    self.lastPropaganda = self.lastPropaganda or 0
    local goTime = gf:getServerTime() - self.lastPropaganda
    if goTime < PROPAGANDA_LIMIT_TIME then
        gf:ShowSmallTips(string.format(CHS[3003741], PROPAGANDA_LIMIT_TIME - goTime))
        return
    end

    self.lastPropaganda = gf:getServerTime()

    local teamStr = self:getPropagandaStr()

    -- 转义一下名片字符串
    teamStr = ChatMgr:filtCardStr(teamStr)

    local data = { compress=0, channel= CHAT_CHANNEL.TEAM_INFO, orgLength=string.len(teamStr), msg=teamStr,  }
    gf:CmdToServer("CMD_CHAT_EX", data)
end

function TeamDlg:getPropagandaStr()
    local str = "[" .. (self.activeName or "") .. "]"
    if self.polars and next(self.polars) then
        -- \29 用于 gf:onCGAColorText(textCtrl, sender, bindTask) 中的解析
        str = str .. "[\29" .. self:getPolarsStr(self.polars) .. "\29]"
    end

    str = str .. "[" .. string.format(CHS[5400366], self.minValue or 0, self.maxValue or 0) .. "]"

    if self.minTao and self.minTao > 0 and self.maxTao and self.maxTao > 0 then
        str = str .. "[" .. string.format(CHS[5400367], self.minTao, self.maxTao) .. "]"
    end

    return str .. string.format(CHS[3003742], Me:queryBasic("name"), Me:queryBasic("gid"))
end

function TeamDlg:onApplyListButton(sender, eventType, data, isRedDotRemoved)
    self.listType = "zuduishenqing"
    self:getControl("AroundListView"):removeAllItems()
    self:showMyTeam(false)
    self:checkButton(sender)
    self:setListInfo("zuduishenqing")

    if isRedDotRemoved and not next(TeamMgr.requesters) then
        -- 如有过删除过小红点，并且当前没有申请信息（申请信息失效），则给予提示
        gf:ShowSmallTips(CHS[4400003])
    end
end

function TeamDlg:onInviteListButton(sender, eventType, data, isRedDotRemoved)
    self.listType = "zuduiyaoqing"
    self:getControl("AroundListView"):removeAllItems()
    self:showMyTeam(false)
    self:checkButton(sender)
    self:setListInfo("zuduiyaoqing")

    if isRedDotRemoved and not next(TeamMgr.inviters) then
        -- 如有过删除过小红点，则判断当前是否还有邀请，没有则给予提示
        gf:ShowSmallTips(CHS[4400004])
    end
end

function TeamDlg:onStartButton(sender, eventType)
    if DistMgr:isInKFJJServer() then
        if KuafjjMgr:checkKuafjjIsEnd() then
            return
        end

        -- 跨服竞技
        if MapMgr:isInKuafjjzc() then
            gf:ShowSmallTips(CHS[5400422])
            return
        end

        if KuafjjMgr:isKFJJJournalist() then
        	gf:ShowSmallTips(CHS[5400421])
            return
        end
    end

    if Me:isInPrison() then
        gf:ShowSmallTips(CHS[7000071])
        return
    end

    if TaskMgr:isInTaskBKTX() then
        gf:ShowSmallTips(CHS[4010224])
        return
    end

    -- 单人情况
    if #TeamMgr.members_ex == 0 then
        if TeamMgr:getCurMatchInfo().state == 0 then
            -- 八仙梦境/矿石大战副本中不能匹配
            if MapMgr:isInBaXian() or MapMgr:isInOreWars() then
                gf:ShowSmallTips(CHS[3003743])
                return
            end

            if Me:queryBasicInt("level") < 20 then
                gf:ShowSmallTips(CHS[3003745])
                return
            end

            -- 单人不在匹配中
            if not TeamMgr:isAllowActive(self.activeName) then
                gf:ShowSmallTips(CHS[3003740])
                return
            end

            -- 有老君发怒时不能匹配刷道活动
            if TaskMgr:isExistTaskByName(TASK_LAOJUN_FANU) then
                if self.activeName == TASK_FUMO or self.activeName == TASK_XIANGYAO then
                    gf:ShowSmallTips(CHS[6000561])
                    return
                end
            end

            TeamMgr:requstMatchTeam(self.activeName)
            return
        else
            TeamMgr:stopMatchTeam()
            return
        end
    end

    -- 队伍中
    if not Me:isTeamLeader() then
        gf:ShowSmallTips(CHS[3003744])
        return
    end

    if Me:queryBasicInt("level") < 20 then
        gf:ShowSmallTips(CHS[3003745])
        return
    end

    local matchInfo = TeamMgr:getCurMatchInfo()
    if 0 == matchInfo.state then
        -- 八仙梦境/矿石大战副本中不能匹配
        if MapMgr:isInBaXian() or MapMgr:isInOreWars()then
            gf:ShowSmallTips(CHS[3003743])
            return
        end

        if DistMgr:isInKFJJServer() then
            -- 跨服竞技
            local combatMode, needNum = KuafjjMgr:getCurCombatMode()
            local num = TeamMgr:getTeamTotalNum()
            if not combatMode then
                gf:ShowSmallTips(CHS[5400408])
                return
            elseif needNum == 1 then
                gf:ShowSmallTips(CHS[5400409])
                return
            elseif num >= needNum then
                gf:ShowSmallTips(CHS[5400426])
                return
            elseif not self.polars or not self.minTao or self.minTao <= 0 or not self.maxTao or self.maxTao <= 0 or not TeamMgr:isAllowActive(self.activeName) then
                DlgMgr:openDlg("KuafjjsxDlg")
                return
            end
        end

        if not TeamMgr:isAllowActive(self.activeName) then
            DlgMgr:openDlg("TeamAdjustmentDlg")
            gf:ShowSmallTips(CHS[3003740])
            return
        end

        -- 有老君发怒时不能匹配刷道活动
        if TaskMgr:isExistTaskByName(TASK_LAOJUN_FANU) then
            if self.activeName == TASK_FUMO or self.activeName == TASK_XIANGYAO then
                gf:ShowSmallTips(CHS[6000561])
                return
            end
        end

        TeamMgr:requestMatchMember(self.activeName, self.minValue, self.maxValue, self.polars, self.minTao, self.maxTao)
    elseif 1 == matchInfo.state then
        TeamMgr:stopMatchTeam()
    elseif 2 == matchInfo.state then
        TeamMgr:stopMatchMember()
    end
end

function TeamDlg:onSettingButton(sender, eventType)
    if DistMgr:isInKFJJServer() then
        -- 跨服竞技
        if MapMgr:isInKuafjjzc() then
            gf:ShowSmallTips(CHS[5400410])
            return
        end

        if KuafjjMgr:checkKuafjjIsEnd() then
            return
        end

        if KuafjjMgr:isKFJJJournalist() then
            gf:ShowSmallTips(CHS[5400421])
            return
        end
    end

    if Me:queryBasicInt("level") < 20 then
        gf:ShowSmallTips(CHS[3003745])
        return
    end

    if Me:isTeamLeader() then
        if DistMgr:isInKFJJServer() then
            -- 跨服竞技
            local combatMode, needNum = KuafjjMgr:getCurCombatMode()
            if not combatMode then
                gf:ShowSmallTips(CHS[5400408])
            elseif needNum == 1 then
                gf:ShowSmallTips(CHS[5400409])
            else
                DlgMgr:openDlg("KuafjjsxDlg")
            end
        else
            local dlg = DlgMgr:openDlg("TeamAdjustmentDlg")
            dlg:selectItemInit(self.activeName)
        end
    end

    if not TeamMgr:inTeamEx(Me:getId()) then
        local dlg = DlgMgr:openDlg("TeamQuickDlg")
        dlg:selectItemInit(self.activeName)
    end
end

function TeamDlg:onCreateTeamButton(sender, eventType)
    if DistMgr:isInKFJJServer() then
        -- 跨服竞技
        if MapMgr:isInKuafjjzc() then
            gf:ShowSmallTips(CHS[5400423])
            return
        end

        if KuafjjMgr:isKFJJJournalist() then
            gf:ShowSmallTips(CHS[5400421])
            return
        end
    end

    if Me:isInPrison() then
        gf:ShowSmallTips(CHS[7000071])
        return
    end

    if MapMgr:isInOreWars() then
        -- 矿石大战中无法创建队伍
        gf:ShowSmallTips(CHS[7003048])
        return
    end

    TeamMgr:setCurMatchState("")
    local isLeader = Me:isTeamLeader()
    local inTeam = TeamMgr:inTeamEx(Me:getId())

    if inTeam then
        gf:ShowSmallTips(CHS[6000182])
    else
        gf:CmdToServer("CMD_REQUEST_JOIN", {
            peer_name = Me:getName(),
            id = Me:getId(),
            ask_type = Const.REQUEST_JOIN_TEAM,
        })
    end
end

function TeamDlg:onLeaveTeamButton(sender, eventType)
    if MapMgr:isInKuafjjzc() then
        gf:ShowSmallTips(CHS[5400424])
        return
    end

    if Me:isPassiveMode() or not TeamMgr:inTeamEx(Me:getId()) then self:onCloseButton() return end
    local tips = CHS[6000560]

    -- 【七夕节】千里相会提示
    if not TaskMgr:qianLXHIsCanLeaveTeam() then
        if Me:isTeamLeader() then
            tips = CHS[5400084]
        else
            tips = CHS[5400081]
        end
    end

    if TaskMgr:isInTaskBKTX() then
        if Me:isTeamLeader() then
            tips = CHS[4010225]
        else
            tips = CHS[4010226]
        end
    end

    tips = TaskMgr:getGiveUpTisByName(CHS[4010122], tips)

    gf:confirm(tips, function()
        gf:CmdToServer("CMD_QUIT_TEAM", {})
    end)
end

function TeamDlg:onTeamQuickButton(sender, eventType)
    if DistMgr:isInKFJJServer() then
        -- 跨服竞技
        if MapMgr:isInKuafjjzc() then
            gf:ShowSmallTips(CHS[5400410])
            return
        end

        if KuafjjMgr:checkKuafjjIsEnd() then
            return
        end

        if KuafjjMgr:isKFJJJournalist() then
            gf:ShowSmallTips(CHS[5400421])
            return
        end
    end

    if Me:queryBasicInt("level") < 20 then
        gf:ShowSmallTips(CHS[3003745])
        return
    end

    local dlg = DlgMgr:openDlg("TeamQuickDlg")
    dlg:selectItemInit(self.activeName)
end

function TeamDlg:onDragEvent(eventCode)
    if eventCode == cc.EventCode.ENDED and self.dragging then
        local dragPannel = self.dragging[1]
        performWithDelay(dragPannel, function()
            if self.dragging and dragPannel == self.dragging[1] then
                self:cancelDragging(true)
            end
        end, 0)
    end
end

function TeamDlg:onAFKButton(sender, eventType)
    if not Me:isInTeam() or Me:isTeamLeader() then return end
    gf:CmdToServer("CMD_LEAVE_TEMP_TEAM", {})
end

function TeamDlg:onReturnButton(sender, eventType)
    if Me:isRemoteStore() then return end
    gf:CmdToServer("CMD_RETURN_TEAM", {})
end

function TeamDlg:MSG_UPDATE_APPEARANCE(data)
    if data.id == Me:getId() then
        self:MSG_UPDATE_TEAM_LIST_EX()
    end
end

function TeamDlg:MSG_UPDATE_TEAM_LIST_EX(data)
    self:cleanDlg()
    self:displayTeamInfo()
    self:ButtonInit()
    self:initMemberList()
    if not Me:isTeamLeader() then
        self:onMyTeamButton(self:getControl("MyTeamButton"))
    end
    self:cancelDragging()
end

function TeamDlg:getPlayersList(start, onePageCount)
    self.playerLisr = self.playerLisr or {}
    local playersList = {}
    if not next(self.playerLisr) then return playersList end
    for i = 1, #self.playerLisr do
        if i >= start and i < start + onePageCount then
            table.insert(playersList, self.playerLisr[i])
        end
    end

    return playersList
end

function TeamDlg:getListUnitPanel()
    local panel = nil
    if self.listType == "zhouweiwanjia" then
        panel = self.aroundPlayerUnitPanel:clone()
    elseif self.listType == "zhouweiduiwu" then
        panel = self.aroundTeamUnitPanel:clone()
    elseif self.listType == "zuduiyaoqing" or self.listType == "zuduishenqing" then
        panel = self.applyUnitPanel:clone()
    end

    panel:setVisible(true)
    return panel
end

function TeamDlg:pushData(playersList)
    if not playersList or not next(playersList) then
        return
    end

    local arountListView = self:getControl("AroundListView")
    local line = math.floor(#playersList / 2) + #playersList % 2
    for i = 1, line do
        local panel = self:getListUnitPanel()
        local player1 = playersList[(i - 1) * 2 + 1]
        self:setUnitByPanel(player1, self:getControl("UnitPanel1", nil, panel), self.listType)

        local player2 = playersList[(i - 1) * 2 + 2]
        self:setUnitByPanel(player2, self:getControl("UnitPanel2", nil, panel), self.listType)
        arountListView:pushBackCustomItem(panel)
    end

    local addCount = #arountListView:getItems()
    local innerContainer = arountListView:getInnerContainerSize()
    innerContainer.height = addCount * self.applyUnitPanel:getContentSize().height
    arountListView:setInnerContainerSize(innerContainer)
    self.start = self.start + #playersList
    arountListView:requestRefreshView()
end

function TeamDlg:MSG_DIALOG(data)
    if (self.listType == "zhouweiwanjia" and data.ask_type == Const.AROUND_PLAYER or data.ask_type == Const.CSC_AROUND_PLAYER)
        or (self.listType == "zhouweiduiwu" and data.ask_type == Const.AROUND_TEAM or data.ask_type == Const.CSC_AROUND_TEAM) then
        self.playerLisr = {}
        self.start = 1
        for i = 1,data.count do
            self.playerLisr[i] = data[i]
        end

        local list = self:getPlayersList(self.start,PER_PAGE_COUNT)
        self.start = self.start + PER_PAGE_COUNT
        self:setListInfo(self.listType, list)
    end

    if (self.listType == "zuduiyaoqing" and data.ask_type == Const.INVITE_JOIN_TEAM )
        or (self.listType == "zuduishenqing" and data.ask_type == Const.REQUEST_JOIN_TEAM) then
            self:setListInfo(self.listType)
    end
end

function TeamDlg:MSG_REQUEST_LIST(data)
    if (self.listType == "zuduiyaoqing" and data.ask_type == Const.INVITE_JOIN_TEAM )
        or (self.listType == "zuduishenqing" and data.ask_type == Const.REQUEST_JOIN_TEAM) then
        self:setListInfo(self.listType)
    end
end

function TeamDlg:MSG_LEADER_COMBAT_GUARD(data)
    self:initMemberList()
end

function TeamDlg:MSG_MATCH_SIZE(data)
    -- 更新右上角人数
    self:setLabelText("WaitingLabel", string.format(CHS[3003731], data.teams, data.members))
end

function TeamDlg:MSG_MATCH_TEAM_STATE(data)
    if TeamMgr:getCurMatchInfo().name == CHS[5000167] and data.state == 0 then return end
    TeamDlg:displayTeamInfo(TeamMgr:getNameByType(data.type), data.minLevel, data.maxLevel, data.polars, data.minTao, data.maxTao)
end

function TeamDlg:MSG_CLEAN_REQUEST(data)
    if (self.listType == "zuduiyaoqing" and data.ask_type == Const.INVITE_JOIN_TEAM )
        or (self.listType == "zuduishenqing" and data.ask_type == Const.REQUEST_JOIN_TEAM) then
        self:setListInfo(self.listType)
    end
end

function TeamDlg:MSG_CLEAN_ALL_REQUEST(data)
    self:MSG_CLEAN_REQUEST(data)
end

function TeamDlg:setMatchInfo(activeName, minValue, maxValue, polars, minTao, maxTao)
    self.activeName = activeName
    self.minValue = minValue
    self.maxValue = maxValue
    self.polars = polars
    self.minTao = minTao
    self.maxTao = maxTao

    -- 更新匹配队伍
    local panel = self:getControl("TeamInfoPanel")
    self:setCtrlVisible("ActiveTextLabel", true, panel)
    self:setCtrlVisible("ActiveLabel", true, panel)
    self:setCtrlVisible("LevelLabel", true, panel)

    self:setLabelText("ActiveTextLabel", CHS[3003735], panel)
    self:setLabelText("ActiveLabel", activeName, panel)
    -- self:setLabelText("LevelLabel", string.format("(%d - %d)", minValue, maxValue), panel)
    self:setMatchCondition(minValue, maxValue, polars, minTao, maxTao)

    self:updateLayout("TeamInfoPanel")
end

function TeamDlg:getPolarsStr(polars)
    if not polars or not next(polars) then
        return ""
    end

    local str = ""
    local cou = #polars
    if cou == 5 then
        str = str .. CHS[5400368]  -- 相性不限
    else
        for i = 1, cou do
            str = str .. gf:getPolar(polars[i])

            if i < cou then
                str = str .. "、"
            end
        end
    end

    return str
end

function TeamDlg:setMatchCondition(minValue, maxValue, polars, minTao, maxTao)
    local str = self:getPolarsStr(polars)

    if minValue and maxValue then
        if str == "" then
            str = str .. string.format("%d - %d", minValue, maxValue)
        else
            str = str .. "，"
            str = str .. string.format(CHS[5400366], minValue, maxValue)
        end
    end

    if minTao and minTao > 0 and maxTao and maxTao > 0 then
        str = str .. "，" .. string.format(CHS[5400367], minTao, maxTao)
    end

    self:setLabelText("LevelLabel", string.format("(%s)", str), "TeamInfoPanel")
end

return TeamDlg
