-- MissionDlg.lua
-- Created by cheny Dec/05/2014
-- 任务/组队界面

local RadioGroup = require("ctrl/RadioGroup")
local MissionDlg = Singleton("MissionDlg", Dialog)
local ITEM_HEIGHT = 43
local ITEM_MARGIN = 3
local TEAM_MEMBER_HEIGHT = 64
local TEAM_MEMBER_MARGIN = 3
local FONT_HEIGHT = 19

local fast_level       = 19     --快速飞升跨度
local rapid_level      = 9      --极速

local FAST_COST        = 100        -- 元宝
local RAPID_COST       = 100000     -- 金钱

local displayTask   = 1
local displayTongtianta = 2
local displayTeam   = 3
local displayPartyWar = 4
local displayCityWar = 6
local displayBaxin = 7
local displayFuben = 8
local displayQMPK = 9
local displayKFJJ = 10
local displayMRZB = 11
local displayKFSD = 12  -- 跨服试道
local displaySDDH = 13
local displayTTTTD = 14  -- 通天塔塔顶
local displayKFZC2019 = 15 -- 跨服战场2019
local displayQcld = 16 -- 青城论道

local zoneHasNoTeamList = require("cfg/ZoneHasNoTeam")
local BUTTON_STATE = {
    BUTTTON_STATE_HIDE  = 0,
    BUTTON_STATE_SHOW = 1,
}

function MissionDlg:init()
    self:setFullScreen()
    self:bindListener("TongtiantaButton", self.onTongtiantaButton)
    self:bindListener("RefreshButton", self.updatePartyWarInfo)
    self:bindListener("RefreshButton", self.updatePartyWarInfo, "NewPartyWarPanel")
    self:bindListener("OpenMissionButton", self.onOpenMissionButton)
    self:bindListener("ShowTeamButton", self.onShowTeamButton)
    self:bindListener("OpenTeamButton", self.onOpenTeamButton)
    self:bindListener("AFKButton", self.onAFKButton)
    self:bindListener("LeaveTeamButton", self.onLeaveTeamButton)
    self:bindListViewListener("MissionListView", self.onSelectMissionListView)

    self:bindListViewListener("TeamListView", self.onSelectTeamListView)
    self:bindListener("ShowDialogButton", self.onShowDialogButton)

    -- 新帮战
    self:bindListener("RuleButton", self.onNewPWRuleButton, "NewPartyWarPanel")
    self:bindListener("LeaveButton", self.onNewPWLeaveButton, "NewPartyWarPanel")
    self:bindListener("ChallengePanel", self.onNewPWChakkengeButton, "NewPartyWarPanel")
    self:bindListener("RuleButton", self.onNewPWRuleButton, "NewPartyWar2Panel")
    self:bindListener("LeaveButton", self.onNewPWLeaveButton, "NewPartyWar2Panel")
    self:bindListener("ChallengePanel", self.onNewPWChakkengeButton, "NewPartyWar2Panel")
    self:bindListener("CCJBPanel", self.onCCJBPanel, "NewPartyWar2Panel")

    -- 通天塔按钮
   -- self:bindListener("ChallengePanel", self.onChallengeButton)
    self:bindListener("NextLevelButton", self.onChallengeButton)
    self:bindListener("ReChallengeButton", self.onChallengeButton)
    self:bindListener("FlyButton", self.onFlyButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("LeaveButton", self.onLeaveButton, "TongtiantaPanel")
    self:bindListener("LeaveButton", self.onTTTTOPLeaveButton, "TongtiantaTopPanel")
    self:bindListener("FlyButton", self.onTTTTOPFlyButton, "TongtiantaTopPanel")
    self:bindListener("InfoButton", self.onTTTTOPInfoButton, "TongtiantaTopPanel")
        self:bindListener("TargetPanel", self.onChallengeTopButton)
   -- self:bindListener("EscalatorPanel", self.onAutoChallenge)

    self:bindListener("ExitMatchButton", self.onExitMatchButton)

    self:bindTongtiantaButtons()

    -- 八仙梦境
    self:bindListener("LeaveButton", self.onLeaveBaxianButton, "EightImmortalsPanel")
    self:bindListener("RuleButton", self.onBaxianRuleButton, "EightImmortalsPanel")
    self:bindBaxianPanel()

    -- 副本
    self:bindListener("LeaveButton", self.onLeaveFubenButton, "DugeonPanel")
    self:bindListener("RuleButton", self.onDugeonRuleButton, "DugeonPanel")
    self:bindDugeonPanel()

    -- 须弥秘境（绑定控件使得点击响应仍然走副本的逻辑）
    self:bindListener("LeaveButton", self.onLeaveFubenButton, "MijingPanel")
    self:bindListener("RuleButton", self.onDugeonRuleButton, "MijingPanel")

    -- 粽仙试炼
    self:bindListener("LeaveButton", self.onLeaveFubenButton, "ZongXianPanel")
    self:bindListener("RuleButton", self.onDugeonRuleButton, "ZongXianPanel")
    self:bindZongXianPanel()
    self.zongXianSoaringPanelOriginPosY = self:getControl("SoaringPanel", nil, "ZongXianPanel"):getPositionY()

    -- 万妖窟
    self:bindListener("LeaveButton", self.onLeaveFubenButton, "WanYaoPanel")
    self:bindListener("RuleButton", self.onDugeonRuleButton, "WanYaoPanel")
    self:bindWanYaoPanel()

    -- 矿石大战（绑定控件使得点击响应仍然走副本的逻辑）
    self:bindListener("LeaveButton", self.onLeaveFubenButton, "OreWarsPanel")
    self:bindListener("RuleButton", self.onDugeonRuleButton, "OreWarsPanel")

    -- 全民PK
    self:bindListener("LeaveButton", self.onLeaveQMPKButton, "QuanmPKPanel")
    self:bindListener("RuleButton", self.onQMPKRuleButton, "QuanmPKPanel")
    self:bindQMPKPanel()

    -- 跨服竞技
    self:bindListener("CombatButton", self.onCombatButton, "KuafjjPanel")
    self:bindListener("NoteButton", self.onNoteButton, "KuafjjPanel")

    -- 跨服试道
    self:bindListener("LeaveButton", self.onLeaveKuafsdButton, "KuafsdPanel")
    self:bindListener("RuleButton", self.onKuafsdRuleButton, "KuafsdPanel")
    self:bindKFSDPanel()

    -- 异族入侵
    self:bindListener("LeaveButton", self.onLeaveFubenButton, "InvadePanel")
    self:bindListener("RuleButton", self.onDugeonRuleButton, "InvadePanel")
    self:bindInvadePanel()

    -- 众仙塔
    self:bindListener("LeaveButton", self.onLeaveFubenButton, "ZhongXianPanel")
    self:bindListener("RuleButton", self.onDugeonRuleButton, "ZhongXianPanel")
    self:bindZhongXianPanel()

    -- 【圣诞】巧收雪精
    self:bindListener("LeaveButton", self.onLeaveFubenButton, "XueJingPanel")
    self:bindListener("RuleButton", self.onDugeonRuleButton, "XueJingPanel")
    self:bindXueJingPanel()

    -- 【劳动节】锄强扶弱
    self:bindListener("LeaveButton", self.onLeaveFubenButton, "LaoDongPanel")
    self:bindListener("RuleButton", self.onDugeonRuleButton, "LaoDongPanel")

    -- 【探案】人口失踪
    self:bindListener("LeaveButton", self.onLeaveFubenButton, "TanAnRkszPanel")
    self:bindListener("RuleButton", self.onTanAnRkszRuleButton, "TanAnRkszPanel")

    self:bindListener("LeaveButton", self.onLeaveFubenButton, "DuanWuPanel")
    self:bindListener("RuleButton", self.onDugeonRuleButton, "DuanWuPanel")

    -- 青城论道
    self:bindListener("LeaveButton", self.onLeaveQingChengLunDaoButton, "QingChengLunDaoPanel")
    self:bindListener("RuleButton", self.onQingChengLunDaoRuleButton, "QingChengLunDaoPanel")
    self:bindQingChengLunDaoPanel()

    self:bindChuqiangfuruoPanel()
    self:bindTanAnRkszPanel()

    self.isHide = false
    self:bindListener("HideDialogButton", self.onShowMissionButton)
    self:bindListener("CityWarButton", self.onCityWarButton)

    self:bindListener("EmptyPanel", self.onEmptyPanel)
    self:bindListener("TaskEmptyPanel", self.onTaskEmptyPanel)

    self:setCtrlVisible("DuanWuPanel", false)

    -- 克隆
    -- singleMemberPanel    Me是队员，显示其他队伍成员信息panel
    -- singleTaskPanel      任务信息
    local singleMemberPanel = self:getControl("SingleMemberPanel", Const.UIPanel)

    if singleMemberPanel ~= nil then
        self.singleMemberPanel = singleMemberPanel:clone()
        self.singleMemberPanel:retain()
        singleMemberPanel:removeFromParent()
    end

    -- 帮战中队伍or个人panel
    local warSingleMemberPanel = self:getControl("WarSingleMemberPanel", Const.UIPanel)
    if warSingleMemberPanel ~= nil then
        self.warSingleMemberPanel = warSingleMemberPanel
        self.warSingleMemberPanel:retain()
        self.warSingleMemberPanel:removeFromParent()

        self.warSingleEff = self:getControl("ChosenEffectImage", nil, self.warSingleMemberPanel)
        self.warSingleEff:retain()
        self.warSingleEff:removeFromParent()
    end

    local singleTaskPanel = self:getControl("OneMissionPanel", Const.UIPanel)
    if singleTaskPanel ~= nil then
        self.singleTaskPanel = singleTaskPanel:clone()
        self:setCtrlVisible("SuggestImage", false, self.singleTaskPanel)
        self.singleTaskPanel:retain()
        singleTaskPanel:removeFromParent()
    end
    local infoPanel = self:getControl("CurrentNotePanel", nil, self.singleTaskPanel)
    self.infoPanelSize = self.infoPanelSize or infoPanel:getContentSize()
    self.singleTaskPanelSize = self.singleTaskPanelSize or  self.singleTaskPanel:getContentSize()

    local laodCurrentPanel = self:getControl("CurrentPanel", nil, "LaoDongPanel")
    self.laodCurrentPanelSize = self.laodCurrentPanelSize or laodCurrentPanel:getContentSize()

    self.titleGroup = RadioGroup.new()
    self.titleGroup:setItemsCanReClick(self, { "MissionCheckBox", "TeamCheckBox" }, function(self, sender)
        if sender:getName() == "MissionCheckBox" then
            self:onMissionButton(sender)
        elseif sender:getName() == "TeamCheckBox" then
            self:onTeamButton(sender)
        end
    end)
    self.titleGroup:selectRadio(1, true)

    self:initMissionList()

    local type = displayTask
    if MapMgr:isInBaXian() then
        type = displayBaxin
    elseif MapMgr:isInDugeon() then
        type = displayFuben
    end

    self:displayType(type)

    self:getControl("ShowDialogButton"):setVisible(false)

    -- 初始化帮战界面
    self:initPartyWarViewControl()

    self:hookMsg("MSG_PARTY_WAR_SCORE")
    self:hookMsg("MSG_CLEAN_REQUEST")
    self:hookMsg("MSG_DIALOG")
--
    self:hookMsg("MSG_UPDATE_TEAM_LIST_EX")
    self:hookMsg("MSG_TONGTIANTA_INFO")
    self:hookMsg("MSG_TONGTIANTADING_XINGJUN_LIST")

    self:hookMsg("MSG_CITY_WAR_SCORE")
    self:hookMsg("MSG_MATCH_TEAM_STATE")

    self:hookMsg("MSG_TONGTIANTA_JUMP")
    self:hookMsg("MSG_TONGTIANTA_JUMP_CANCEL")
    self:hookMsg("MSG_OPEN_FEISHENG_DLG")
    self:hookMsg("MSG_TONGTIANTA_BONUS_DLG")
    self:hookMsg("MSG_BAXIAN_LEFT_TIMES")
    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:hookMsg("MSG_ZNQ_2017_XMMJ")
    self:hookMsg("MSG_MY_KSDZ_INFO")
    self:hookMsg("MSG_YONGCWYK_INFO")
    self:hookMsg("MSG_YISHI_PLAYER_STATUS")
    self:hookMsg("MSG_ZHONGXIANTA_INFO")

    self:hookMsg("MSG_CSC_NOTIFY_COMBAT_MODE")
    self:hookMsg("MSG_CSC_NOTIFY_AUTO_MATCH")

    self:hookMsg("MSG_CSB_MATCH_TIME_INFO")
    self:hookMsg("MSG_NEW_PW_COMBAT_INFO")
    self:hookMsg("MSG_CS_SHIDAO_TASK_INFO")
    self:hookMsg("MSG_SHIDAO_TASK_INFO")

    self.lastState = nil

    self.tongtianInfoSize = self:getControl("LevelInfoPanel"):getContentSize()

    EventDispatcher:addEventListener("ENTER_BACKGROUND", self.onEnterBackground, self)
end

function MissionDlg:cleanup()
    self.autoChallengeTtd = nil
    self.fubenTip = nil
    self.wanyaoTip = nil
    self.qmpkTip = nil
    self.zongXianSoaringPanelOriginPosY = nil
    self:releaseCloneCtrl("singleMemberPanel")
    self:releaseCloneCtrl("singleTaskPanel")
    self:releaseCloneCtrl("warSingleMemberPanel")
    self:releaseCloneCtrl("warSingleEff")
end

function MissionDlg:onInfoButton(sender, eventType)
    gf:showTipInfo(CHS[3003118]
        .. CHS[3003119]
        .. CHS[3003120]
        .. CHS[3003121]
        .. CHS[3003122]
        .. CHS[3003123]
        .. CHS[3003124],
        sender)
end

function MissionDlg:onMissionButton(sender, eventType)
    if GameMgr:isInPartyWar() then
        if self.curDisplayType == displayPartyWar or self.curDisplayType == displayTask then
            DlgMgr:openDlg("TaskDlg")
        else
            self:displayType(displayPartyWar)
        end
        return
    end

    if self.curDisplayType == displayTask or self.curDisplayType == displayTongtianta
         or self.curDisplayType == displayTTTTD or displayKFZC2019 == self.curDisplayType
         or self.curDisplayType == displayBaxin or self.curDisplayType == displayFuben
         or self.curDisplayType == displayQMPK or self.curDisplayType == displayKFJJ
        or self.curDisplayType == displayMRZB or self.curDisplayType == displayKFSD
        or self.curDisplayType == displaySDDH or self.curDisplayType == displayQcld then
        DlgMgr:openDlg("TaskDlg")
        return
    end

    if MapMgr.mapData and (MapMgr.mapData.map_name == CHS[3003126] or MapMgr.mapData.map_name == "神秘房间") then
        -- 如果是通天塔，则点击任务切换通天塔界面
        self:displayType(displayTongtianta)
        return
    end

    if MapMgr.mapData and MapMgr.mapData.map_name == CHS[4101274] then
        -- 如果是通天塔，则点击任务切换通天塔界面
        self:displayType(displayTTTTD)
        return
    end

    if MapMgr:isInBaXian() then
        self:displayType(displayBaxin)
        return
    elseif MapMgr:isInDugeon() then
        self:displayType(displayFuben)
        return
    elseif DistMgr:isInQMPKServer() then
        self:displayType(displayQMPK)
        return
    elseif DistMgr:isInKFJJServer() then
        self:displayType(displayKFJJ)
        return
    elseif DistMgr:isInKFSDServer() then
        self:displayType(displayKFSD)
        return
    elseif MapMgr:isInShiDao() then
        self:displayType(displaySDDH)
        return
    elseif MapMgr:isInMRZB() then
        self:displayType(displayMRZB)
        return
    elseif KuafzcMgr:isInKuafzc2019() then
        self:displayType(displayKFZC2019)
        return
    elseif DistMgr:isInQcldServer() then
        self:displayType(displayQcld)
        return
    end

    self:displayType(displayTask)
end

function MissionDlg:onTongtiantaButton(sender, eventType)
    self:displayType(displayTongtianta)
end

function MissionDlg:onTeamButton(sender, eventType)
    -- 如果处于不可组队场景则，弹出不可组队提示
    local map_name = MapMgr:getCurrentMapName()
    if self.curDisplayType == displayTeam then
        -- 当前标签页是队伍，打开队伍界面
        DlgMgr:openDlg("TeamDlg")
        return
    end

    if not TeamMgr:inTeamEx(Me:getId()) then
        -- 单人的时候打开队伍
        DlgMgr:openDlg("TeamDlg")
    else
        if Me:isTeamLeader() and #TeamMgr.requesters ~= 0 then
            -- 我是队长并且有申请列表打开
            DlgMgr:openDlg("TeamDlg")
        end
    end
    self:displayType(displayTeam)
end

function MissionDlg:onShowMissionButton(sender, eventType)
    self.lastState = BUTTON_STATE.BUTTTON_STATE_HIDE
    self:hide(true)
end

function MissionDlg:onOpenMissionButton(sender, eventType)
    DlgMgr:openDlg("TaskDlg")
end

function MissionDlg:onShowTeamButton(sender, eventType)
    self:hide(true)
end

function MissionDlg:onExitMatchButton(sender, eventType)
    TeamMgr:stopMatchTeam()
    TeamMgr:stopMatchMember()
    self:updateTeamInfo()
end

function MissionDlg:onAFKButton(sender, eventType)
end

function MissionDlg:onLeaveTeamButton(sender, eventType)
end

function MissionDlg:onSelectMissionListView(sender, eventType)
end

function MissionDlg:onSelectTeamListView(sender, eventType)
end

function MissionDlg:onNewPWRuleButton(sender, eventType)
    if DistMgr:isInKFZC2019Server() then
        DlgMgr:openDlg("NewKuafzcInfoDlg")
    else
        DlgMgr:openDlg("NewPartyWarInstructionDlg")
    end

end

function MissionDlg:onNewPWLeaveButton(sender, eventType)
    if DistMgr:isInKFZC2019Server() then
        gf:CmdToServer("CMD_CSML_LEAVE_ZHANCHANG")
    else
        gf:CmdToServer("CMD_LEAVE_NEW_PW")
    end
end

function MissionDlg:onNewPWChakkengeButton(sender, eventType)
    local newData = PartyWarMgr:getNewPartyWarData()
    local securityPanel = self:getControl("NewPartyWar2Panel")

    -- 安全区处理
    if newData and newData.is_security == 1 then
        if gf:getServerTime() > newData.start_time then
            -- 是否处于保护时间
            if gf:getServerTime() > newData.rest_time then
                if MapMgr.mapData.map_name == CHS[4000414] then
                    AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4000415]))
                else
                    AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4000416]))
                end
            end
        end
    end
end


function MissionDlg:onShowDialogButton()
    self.lastState = BUTTON_STATE.BUTTON_STATE_SHOW
    self:hide(false)
end

function MissionDlg:bindTongtiantaButtons()
    local function resFunc(sender, eventType)
        self:getControl("ChallengePanel", nil, "TongtiantaPanel"):setScale(1)
        self:getControl("EscalatorPanel", nil, "TongtiantaPanel"):setScale(1)
    end

    self:blindLongPressTakView(self:getControl("ChallengePanel", nil, "TongtiantaPanel"), nil, self.onChallengeButton, resFunc)
    self:blindLongPressTakView(self:getControl("EscalatorPanel", nil, "TongtiantaPanel"), nil, self.onAutoChallenge, resFunc)
end

function MissionDlg:bindDugeonPanel()
    local function resFunc(sender, eventType)
        self:getControl("ChallengePanel", nil, "DugeonPanel"):setScale(1)
    end

    local function callFunc()

        -- GM处于监听状态下
        if GMMgr:isStaticMode() then
            gf:ShowSmallTips(CHS[3003130])
            return
        end

        local task = TaskMgr:getFuBenTaskData()
        if task then
            -- 百兽之王/野兽之体提示
            if MapMgr:isInBeastsKing() and (task.task_type == CHS[2200036] or task.task_type == CHS[7002132]) then
                gf:ShowSmallTips(CHS[7002133])
                return
            end

            local autoWalkInfo = gf:findDest(task.task_prompt)
            if autoWalkInfo then
                autoWalkInfo.curTaskWalkPath = {}
                autoWalkInfo.curTaskWalkPath.task_type = task.task_type
                autoWalkInfo.curTaskWalkPath.task_prompt = task.task_prompt
                AutoWalkMgr:beginAutoWalk(autoWalkInfo)
            elseif string.match(task.task_prompt, "#C.-|.+#C") then
                local csParam = string.match(task.task_prompt, "#C.-|(.+)#C")
                local tip = string.match(csParam, "Tipnow=(.+)")
                if tip then
                    gf:ShowSmallTips(tip)
                else
                    ChatMgr:sendCurChannelMsg(csParam)
                end
            else
                -- 解析打开对话框
                local tempStr = string.match(task.task_prompt, "#@.+#@")
                if tempStr then
                    -- 解析#@道具名|FastUseItemDlg=道具名
                    tempStr = string.match(tempStr, "|.+=.+")
                end
                if tempStr then
                    tempStr = string.sub(tempStr, 2)
                    tempStr = string.sub(tempStr, 1, -3)
                    DlgMgr:openDlgWithParam(tempStr)
                end
            end
        end
    end

    self:blindLongPressTakView(self:getControl("ChallengePanel", nil, "DugeonPanel"), nil, callFunc, resFunc)
end

function MissionDlg:bindWanYaoPanel()
    local function resFunc(sender, eventType)
        self:getControl("ChallengePanel2", nil, "WanYaoPanel"):setScale(1)
    end

    local function callFunc()

        -- GM处于监听状态下
        if GMMgr:isStaticMode() then
            gf:ShowSmallTips(CHS[3003130])
            return
        end

        if self.wanyaoTip then
            gf:onCGAColorText(self.wanyaoTip, self:getControl("ChallengePane2", nil, "WanYaoPanel"))
        end
    end

    self:blindLongPressTakView(self:getControl("ChallengePanel2", nil, "WanYaoPanel"), nil, callFunc, resFunc)
end

function MissionDlg:bindBaxianPanel()
    local function resFunc(sender, eventType)
        self:getControl("ChallengePanel", nil, "EightImmortalsPanel"):setScale(1)
    end

    local function callFunc()

        -- GM处于监听状态下
        if GMMgr:isStaticMode() then
            gf:ShowSmallTips(CHS[3003130])
            return
        end

        local task = TaskMgr:getBaxianTask()
        if task then
            local autoWalkInfo = gf:findDest(task.task_prompt)
            autoWalkInfo.curTaskWalkPath = {}
            autoWalkInfo.curTaskWalkPath.task_type = task.task_type
            autoWalkInfo.curTaskWalkPath.task_prompt = task.task_prompt
            AutoWalkMgr:beginAutoWalk(autoWalkInfo)
        end
    end

    self:blindLongPressTakView(self:getControl("ChallengePanel", nil, "EightImmortalsPanel"), nil, callFunc, resFunc)
end

function MissionDlg:bindZongXianPanel()
    self:getControl("ChallengePanel4", nil, "ZongXianPanel"):setAnchorPoint(0.5, 0.5)

    local function resFunc(sender, eventType)
        self:getControl("ChallengePanel4", nil, "ZongXianPanel"):setScale(1)
    end

    local function callFunc()

        -- GM处于监听状态下
        if GMMgr:isStaticMode() then
            gf:ShowSmallTips(CHS[3003130])
            return
        end

        local autoWalkTip = TaskMgr:getZongXianAutoWalkTip()
        if autoWalkTip then
            AutoWalkMgr:beginAutoWalk(gf:findDest(autoWalkTip))
        end
    end

    self:blindLongPressTakView(self:getControl("ChallengePanel4", nil, "ZongXianPanel"), nil, callFunc, resFunc)
end

function MissionDlg:bindQMPKPanel()
    self:getControl("ChallengePanel2", nil, "QuanmPKPanel"):setAnchorPoint(0.5, 0.5)

    local function resFunc(sender, eventType)
        self:getControl("ChallengePanel2", nil, "QuanmPKPanel"):setScale(1)
    end

    local function callFunc()

        -- GM处于监听状态下
        if GMMgr:isStaticMode() then
            gf:ShowSmallTips(CHS[3003130])
            return
        end

        if self.curDisplayType == displayMRZB then

            if TaskMgr:isMRZBJournalist() or GMMgr:isGM() or GMMgr:isWarAdmin(CHS[4300465]) then
                -- 记者、GM点击无响应
                return
            end

            if self.mrzbInfo.result > 0 then
                if self.mrzbInfo.warClass == MINGREN_ZHENGBA_CLASS.JUESAI then
                    -- 有结果，点击返回  返回#P无名小镇|赛场接引人#P   此时只会在楼兰城，如果不在楼兰城，有问题
                    AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4101046]))
                    return
                end

                -- 如果有结果，代表比赛结束
                AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4101048]))
				return
            end

            if self.mrzbInfo.warClass == MINGREN_ZHENGBA_CLASS.JUESAI then
                -- 策划要求，没有结果，如果在楼兰争霸城，点击寻路
                if MapMgr:isInMapByName(CHS[4200505]) then
                    AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4101035]))
                else
                    -- 战场不响应
                end
                return
            end

            if gf:getServerTime() < self.mrzbInfo.enterWarPlace then
                AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4101035]))
            elseif gf:getServerTime() < self.mrzbInfo.startTime and MapMgr.mapData and MapMgr.mapData.map_id == 38020 then
                AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4101035]))
            end
        else
            local text = self:getColorText("LabelPanel", "QuanmPKPanel")
            if text then
                AutoWalkMgr:beginAutoWalk(gf:findDest(text))
            end
        end
    end

    self:blindLongPressTakView(self:getControl("ChallengePanel2", nil, "QuanmPKPanel"), nil, callFunc, resFunc)
end

function MissionDlg:bindKFSDPanel()
    self:getControl("ChallengePanel2", nil, "KuafsdPanel"):setAnchorPoint(0.5, 0.5)
    local function resFunc(sender, eventType)
        self:getControl("ChallengePanel2", nil, "KuafsdPanel"):setScale(1)
    end

    local function callFunc()
        -- GM处于监听状态下
        if GMMgr:isStaticMode() then
            gf:ShowSmallTips(CHS[3003130])
            return
        end

        if MapMgr:isInShiDao() then
            return
        end

        local info = ShiDaoMgr:getKuafsdInfo()
        local curTime = gf:getServerTime()
        local str
        if GMMgr:isGM() or ShiDaoMgr:isKFSDJournalist() then
            return
        elseif not info.start_time or (info.is_running == 0 and curTime < info.start_time + 10) then
            str = CHS[5400763]
        elseif info.is_running == 1 and curTime < info.end_time then
            if not MapMgr:isInKuafsdzc() then
                if ShiDaoMgr:isMonthTaoKFSD() then
                    if info.oust_time == 0 then
                        -- 数据还未刷新
                        str = string.format(CHS[5400770], 5)
                    else
                        str = string.format(CHS[5400770], math.max(1, math.min(5, math.ceil((info.oust_time - curTime) / 60))))
                    end
                else
                    str = CHS[5400765]
                end
            end
        else
            str = CHS[5400766]
        end

        if str then
            if ShiDaoMgr:isMonthTaoKFSD() then
                str = string.gsub(str, CHS[5400029], CHS[5400786])
                str = string.gsub(str, CHS[5400038], CHS[5400785])
            end

            AutoWalkMgr:beginAutoWalk(gf:findDest(str))
        end
    end

    self:blindLongPressTakView(self:getControl("ChallengePanel2", nil, "KuafsdPanel"), nil, callFunc, resFunc)
end

function MissionDlg:bindInvadePanel()
    local function resFunc(sender, eventType)
        self:getControl("SneakPanel_0", nil, "InvadePanel"):setScale(1)
    end

    local function callFunc()

        -- GM处于监听状态下
        if GMMgr:isStaticMode() then
            gf:ShowSmallTips(CHS[3003130])
            return
        end

        local task = TaskMgr:getFuBenTaskData()
        if task then
            -- 百兽之王/野兽之体提示
            if MapMgr:isInBeastsKing() and (task.task_type == CHS[2200036] or task.task_type == CHS[7002132]) then
                gf:ShowSmallTips(CHS[7002133])
                return
            end

            local autoWalkInfo = gf:findDest(task.task_prompt)
            if autoWalkInfo then
                autoWalkInfo.curTaskWalkPath = {}
                autoWalkInfo.curTaskWalkPath.task_type = task.task_type
                autoWalkInfo.curTaskWalkPath.task_prompt = task.task_prompt
                AutoWalkMgr:beginAutoWalk(autoWalkInfo)
            else
                -- 解析打开对话框
                local tempStr = string.match(task.task_prompt, "#@.+#@")
                if tempStr then
                    -- 解析#@道具名|FastUseItemDlg=道具名
                    tempStr = string.match(tempStr, "|.+=.+")
                end
                if tempStr then
                    tempStr = string.sub(tempStr, 2)
                    tempStr = string.sub(tempStr, 1, -3)
                    DlgMgr:openDlgWithParam(tempStr)
                end
            end
        end
    end

    self:blindLongPressTakView(self:getControl("ChallengePanel", nil, "InvadePanel"), nil, callFunc, resFunc)

    local function callFunc1()
        YiShiMgr:switchStatus()
    end

    self:getControl("SneakPanel_0", nil, "InvadePanel"):setAnchorPoint(0.5, 0.5)
    self:blindLongPressTakView(self:getControl("SneakPanel_0", nil, "InvadePanel"), nil, callFunc1, resFunc)
end

function MissionDlg:bindZhongXianPanel()
    local function resFunc(sender, eventType)
        self:getControl("ChallengePanel", nil, "ZhongXianPanel"):setScale(1)
    end

    local function callFunc()

        -- GM处于监听状态下
        if GMMgr:isStaticMode() then
            gf:ShowSmallTips(CHS[3003130])
            return
        end

        local task = TaskMgr:getBaxianTask()
        if task then
            local autoWalkInfo = gf:findDest(task.task_prompt)
            autoWalkInfo.curTaskWalkPath = {}
            autoWalkInfo.curTaskWalkPath.task_type = task.task_type
            autoWalkInfo.curTaskWalkPath.task_prompt = task.task_prompt
            AutoWalkMgr:beginAutoWalk(autoWalkInfo)
        end
    end

    self:blindLongPressTakView(self:getControl("ChallengePanel", nil, "ZhongXianPanel"), nil, callFunc, resFunc)
end

function MissionDlg:bindXueJingPanel()
    self:getControl("ChallengePanel", nil, "XueJingPanel"):setAnchorPoint(0.5, 0.5)

    local function resFunc(sender, eventType)
        self:getControl("ChallengePanel", nil, "XueJingPanel"):setScale(1)
    end

    local function callFunc()

        -- GM处于监听状态下
        if GMMgr:isStaticMode() then
            gf:ShowSmallTips(CHS[3003130])
            return
        end

        local task = TaskMgr:getFuBenTaskData()
        if task then
            local textCtrl = CGAColorTextList:create()
            textCtrl:setString(task.task_prompt)
            gf:onCGAColorText(textCtrl, nil, {task_type = task.task_type, task_prompt = task.task_prompt})
        end
    end

    self:blindLongPressTakView(self:getControl("ChallengePanel", nil, "XueJingPanel"), nil, callFunc, resFunc)
end

function MissionDlg:bindQingChengLunDaoPanel()
    self:getControl("ChallengePanel", nil, "QingChengLunDaoPanel"):setAnchorPoint(0.5, 0.5)

    local function resFunc(sender, eventType)
        self:getControl("ChallengePanel", nil, "QingChengLunDaoPanel"):setScale(1)
    end

    local function callFunc()
        -- GM处于监听状态下
        if GMMgr:isStaticMode() then
            gf:ShowSmallTips(CHS[3003130])
            return
        end

        AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[7150138]))
    end

    self:blindLongPressTakView(self:getControl("ChallengePanel", nil, "QingChengLunDaoPanel"), nil, callFunc, resFunc)
end

function MissionDlg:bindChuqiangfuruoPanel()
    self:getControl("ChallengePanel", nil, "LaoDongPanel"):setAnchorPoint(0.5, 0.5)
    self:getControl("ChallengePanel", nil, "DuanWuPanel"):setAnchorPoint(0.5, 0.5)

    local function resFunc(sender, eventType)
        self:getControl("ChallengePanel", nil, "LaoDongPanel"):setScale(1)
        self:getControl("ChallengePanel", nil, "DuanWuPanel"):setScale(1)
    end

    local function callFunc()

        -- GM处于监听状态下
        if GMMgr:isStaticMode() then
            gf:ShowSmallTips(CHS[3003130])
            return
        end

        if MapMgr:isInMapByName(CHS[4010025]) then
            -- 2018端午复用该panel
            local task = TaskMgr:getTaskByName(CHS[4010021])
            if task then
                local textCtrl = CGAColorTextList:create()
                textCtrl:setString(task.task_prompt)
                gf:onCGAColorText(textCtrl, nil, {task_type = task.task_type, task_prompt = task.task_prompt})
            end
        else
            local task = TaskMgr:getFuBenTaskData()
        if task then
            local textCtrl = CGAColorTextList:create()
            textCtrl:setString(task.task_prompt)
            gf:onCGAColorText(textCtrl, nil, {task_type = task.task_type, task_prompt = task.task_prompt})
        end
    end
    end

    self:blindLongPressTakView(self:getControl("ChallengePanel", nil, "LaoDongPanel"), nil, callFunc, resFunc)
    self:blindLongPressTakView(self:getControl("ChallengePanel", nil, "DuanWuPanel"), nil, callFunc, resFunc)
end

-- 探案-人口失踪
function MissionDlg:bindTanAnRkszPanel()
    self:getControl("ChallengePanel", nil, "TanAnRkszPanel"):setAnchorPoint(0.5, 0.5)

    local function resFunc(sender, eventType)
        self:getControl("ChallengePanel", nil, "TanAnRkszPanel"):setScale(1)
    end

    local function callFunc()
        -- GM处于监听状态下
        if GMMgr:isStaticMode() then
            gf:ShowSmallTips(CHS[3003130])
            return
        end

        local task = TaskMgr:getFuBenTaskData()
        if task then
            local textCtrl = CGAColorTextList:create()
            textCtrl:setString(task.task_prompt)
            gf:onCGAColorText(textCtrl, nil, {task_type = task.task_type, task_prompt = task.task_prompt})
        end
    end

    self:blindLongPressTakView(self:getControl("ChallengePanel", nil, "TanAnRkszPanel"), nil, callFunc, resFunc)
end

function MissionDlg:clearAutoChallengeTongtian(panel)
    if not panel then
        panel = self:getControl("EscalatorPanel")
    end

    TaskMgr:setIsAutoChallengeTongtian(false)
    self:setLabelText("InfoLabel", CHS[6200042], panel)
end

function MissionDlg:onChallengeTopButton(sender, eventType)
    local task_prompt = TaskMgr:getTongtianTowerTopTask()
    if task_prompt then
        AutoWalkMgr:beginAutoWalk(gf:findDest(task_prompt))
    end
end

-- 开始挑战 aug
function MissionDlg:onChallengeButton(sender, eventType)
    if not self.info then return end

    --[[
    if TeamMgr:isTeamMeber(Me) then
        gf:ShowSmallTips(CHS[3003127])
        return
    end

    if self.info.curType == 1 or self.info.curType == 3 then
        AutoWalkMgr:beginAutoWalk(gf:findDest("#P" .. self.info.npc .. CHS[3003128]))
        return
    elseif self.info.curType == 2 then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_TTT_GO_NEXT_LAYER)
    end
    --]]

    -- 现在点击任务指引模块可以开始自动扫塔流程
    TaskMgr:setIsAutoChallengeTongtian(true)
    if self.info.curType == 2 then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_TTT_GO_NEXT_LAYER)
    else
        local task = TaskMgr:getTongtianTowerTaskInfo()
        if task and task.task_prompt then
            if MapMgr:isInMapByName(CHS[4010293]) and self.info and self.info.hasNotCompletedSmfj ~= 1 then
                AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4101291]))	-- 应策划要求特殊处理
            elseif MapMgr:isInMapByName(CHS[4010293]) then
                local beidouNpc = CharMgr:getCharByName(CHS[4200636])
                if beidouNpc and not beidouNpc.visible and CharMgr:getCharByName(CHS[4010302]) then
                    AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4200637]))
            else
                AutoWalkMgr:beginAutoWalk(gf:findDest(task.task_prompt))
        end
            else
                AutoWalkMgr:beginAutoWalk(gf:findDest(task.task_prompt))
    end
    end
    end
end


-- 自动挑战
function MissionDlg:onAutoChallenge()
    local panel = self:getControl("EscalatorPanel")
    if not TaskMgr:getIsAutoChallengeTongtian() then
        TaskMgr:setIsAutoChallengeTongtian(true)
        self:setLabelText("InfoLabel", CHS[6200043], panel)

        local task_prompt = TaskMgr:getTongtianTowerTask()
        if task_prompt then
            AutoWalkMgr:beginAutoWalk(gf:findDest(task_prompt))
        end
    else
        self:clearAutoChallengeTongtian(panel)
        AutoWalkMgr:cleanup()
        Me:setAct(Const.FA_STAND)
    end
end

-- 规则
function MissionDlg:onInfoButton(sender, eventType)
    local dlg = DlgMgr:openDlg("TongtiantaRuleDlg")
    dlg:setRuleType("MissionDlg")
end

-- 飞升
function MissionDlg:onFlyButton(sender, eventType)
    if self:isInMMFJ() then
        gf:ShowSmallTips(CHS[4010292]) -- "通天塔神秘房间中无法进行飞升。"
        return
    end

    if not self.info then return end
    if TeamMgr:isTeamMeber(Me) then
        gf:ShowSmallTips(CHS[3003127])
        return
    end

    if self.info.curType ~= 2 then
        gf:ShowSmallTips(CHS[3003129])
        return
    end
    local dlg = DlgMgr:openDlg("TongtiantaFlyDlg")
    dlg:setData(self.info)
end

-- 通天塔塔顶的离开
function MissionDlg:onTTTTOPInfoButton(sender, eventType)
    local dlg = DlgMgr:openDlg("DugeonRuleDlg")
    dlg:setType("ttttop")
end

-- 通天塔塔顶的离开
function MissionDlg:onTTTTOPFlyButton(sender, eventType)
    if not Me:isTeamLeader() and TeamMgr:isTeamMeber(Me) then
        gf:ShowSmallTips(CHS[4101269])
        return
    end

    gf:CmdToServer("CMD_OPEN_TTLP_DLG")
end

-- 通天塔塔顶的离开
function MissionDlg:onTTTTOPLeaveButton(sender, eventType)
    if not Me:isTeamLeader() and TeamMgr:isTeamMeber(Me) then
        gf:ShowSmallTips(CHS[4101269])
        return
    end

    gf:confirm(CHS[4101270], function ()
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_TTTD_LEAVE_TOWER)
    end)
end


-- 传送离开
function MissionDlg:onLeaveButton(sender, eventType)
    if TeamMgr:isTeamMeber(Me) then
        gf:ShowSmallTips(CHS[3003127])
        return
    end

    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_TTT_LEAVE_TOWER)
end


-- 隐藏/显示界面
function MissionDlg:hide(bHide)
    local size = self.root:getContentSize()
    local move = nil
    local winSize = self:getWinSize()
    if bHide == true then
        local action1 = cc.MoveTo:create(0.25, cc.p(Const.WINSIZE.width / 2 / Const.UI_SCALE + self.missionListSize.width + 10 + winSize.x, Const.WINSIZE.height/2 / Const.UI_SCALE + winSize.y))
        local action2 = cc.CallFunc:create(function()
            self:getControl("HideDialogButton"):setVisible(false)
            self:getControl("ShowDialogButton"):setVisible(true)
            self:setCtrlVisible("InfoPanel", false)
        end)
        move = cc.Sequence:create(action1,action2)
    else
        local action1 = cc.CallFunc:create(function()
            self:getControl("HideDialogButton"):setVisible(true)
            self:getControl("ShowDialogButton"):setVisible(false)
            self:setCtrlVisible("InfoPanel", true)
        end)
        local action2 = cc.MoveTo:create(0.25, cc.p(Const.WINSIZE.width / 2 / Const.UI_SCALE + winSize.x, Const.WINSIZE.height/ 2 / Const.UI_SCALE + winSize.y))
        move = cc.Sequence:create(action1,action2)
    end
    self.root:stopAllActions()
    self.root:runAction(move)
    self.isHide = bHide
end

function MissionDlg:stopAllActions()
    local winSize = self:getWinSize()
    if self.isHide then
        self.root:setPosition(cc.p(Const.WINSIZE.width / Const.UI_SCALE / 2 + self.missionListSize.width + 10 + winSize.x, Const.WINSIZE.height / Const.UI_SCALE / 2 + winSize.y))
        self:getControl("HideDialogButton"):setVisible(false)
        self:getControl("ShowDialogButton"):setVisible(true)
    else
        self.root:setPosition(cc.p(Const.WINSIZE.width / Const.UI_SCALE / 2, Const.WINSIZE.height / Const.UI_SCALE / 2 + winSize.y))
        self:getControl("HideDialogButton"):setVisible(true)
        self:getControl("ShowDialogButton"):setVisible(false)
    end
    self:setCtrlVisible("InfoPanel", not self.isHide)
    self.root:stopAllActions()
end

-- 同一的函数名方便调用
function MissionDlg:onHideButton()
    self:hide(true)
end

function MissionDlg:onShowButton()
   self:hide(false)
end

function MissionDlg:getOrderTask(tasks)
    local orderTasks = {}
    for name,task in pairs(tasks) do
        if not TaskMgr.hiddenTasks[task.task_type] then
        table.insert(orderTasks, task)
    end
    end

    table.sort(orderTasks, function(l, r)
        if l.taskType < r.taskType then return true end
        if l.taskType > r.taskType then return false end
        if l.timeTemp > r.timeTemp then return true end
        if l.timeTemp < r.timeTemp then return false end
    end)

    if #orderTasks == 0 then return end
    return orderTasks
end

function MissionDlg:initMissionList()
    local x,y = self:getControl("MissionListView", Const.UIListView):getPosition()
    local list, size = self:resetListView("MissionListView", ITEM_MARGIN)
    self.missionListSize = size
    local tasks = self:getOrderTask(TaskMgr.tasks) -- 已经排除隐藏的任务
    self:setCtrlVisible("TaskEmptyPanel", tasks == nil)
    self:setCtrlVisible("MissionListView", tasks ~= nil)
    if not tasks then return end
    local count = 0
    local height = 0
    local displayY = 0
    for k, v in pairs(tasks) do
            -- 增加项
            local singleTaskPanel = self.singleTaskPanel:clone()
            singleTaskPanel:stopAllActions()
            self:setTaskPanel(v, singleTaskPanel)

            list:pushBackCustomItem(singleTaskPanel)
            height = height + singleTaskPanel:getContentSize().height + ITEM_MARGIN
            count = count + 1

            if count == 1 then
                local rect = self:getBoundingBoxInWorldSpace(singleTaskPanel)
                self.rect = rect
            end
        end

    if count > 0 then
        if height > self:getControl("MissionPanel"):getContentSize().height then
            height = self:getControl("MissionPanel"):getContentSize().height
        end
    end

    self:setCtrlVisible("TaskEmptyPanel", #list:getItems() == 0)

    performWithDelay(self.root, function ()
        list:setContentSize(size.width, height)
        self:updateLayout("MissionPanel")
    end, 0)
end

function MissionDlg:updateTeamInfo()
    local teamPanel = self:getControl("TeamPanel")
    local list, size = self:resetListView("TeamListView", TEAM_MEMBER_MARGIN, nil, teamPanel)
    list:setBounceEnabled(false)
    self.teamListSize = size
    local members = TeamMgr.members_ex

    list:setAnchorPoint(0, 1)

    local state = TeamMgr:getCurMatchInfo().state
    if state == MATCH_STATE.NORMAL then
        self:setCtrlVisible("MatchPanel", false, teamPanel)
        self:getControl("MatchPanel"):setEnabled(false)
        self:setCtrlVisible("TeamListPanel", true, teamPanel)
        self:setCtrlVisible("EmptyPanel", true, teamPanel)
    elseif state == MATCH_STATE.LEADER then
        self:setCtrlVisible("MatchPanel", false, teamPanel)
        self:setCtrlVisible("TeamListPanel", true, teamPanel)
    else
        self:setCtrlVisible("MatchPanel", true, teamPanel)
        self:getControl("MatchPanel"):setEnabled(true)
        self:setCtrlVisible("TeamListPanel", false, teamPanel)
        self:setCtrlVisible("EmptyPanel", false, teamPanel)
        self:setLabelText("MatchLabel", TeamMgr:getCurMatchInfo().name)
    end

    list:setContentSize(size.width, 0)
    if nil == members or members.count == nil or members.count == 0 then
        -- 常规状态下
        self:setCtrlVisible("TeamListPanel", false, teamPanel)
        -- self:setCtrlVisible("EmptyPanel", true, teamPanel)
    else
        self:setCtrlVisible("TeamListPanel", true, teamPanel)
        self:setCtrlVisible("EmptyPanel", false, teamPanel)
        -- 组队状态下，显示队伍成员
        for i, v in ipairs(members) do
            local memberPanel = self.singleMemberPanel:clone()
            self:setMembers(v, memberPanel)
            memberPanel:setTag(i)
            list:pushBackCustomItem(memberPanel)
            memberPanel:setTouchEnabled(true)

            self:blindLongPress(memberPanel, self.longPressFun, self.chooseMember)
            end
        local height = members.count * self.singleMemberPanel:getContentSize().height + (members.count - 1) * TEAM_MEMBER_MARGIN
        list:setContentSize(size.width, height)

        -- WDSY-28104 容错
        if state == MATCH_STATE.MEMBER then
            self:setCtrlVisible("MatchPanel", false, teamPanel)
            TeamMgr:stopMatchMember()
        end
    end

    self:updateLayout("TeamPanel")
end

-- 设置邀请加入队伍列表
function MissionDlg:setInviters(member, panel)
    self:setImage("ShapeImage", ResMgr:getSmallPortrait(member.portrait), panel)
    self:setItemImageSize("ShapeImage", panel)
    self:setLabelText("LevelLabel", member.level, panel)
    self:setLabelText("MemberNameLabel", gf:getRealName(member.name), panel)
    self:setLabelText("CurrentNoteLabel", string.format("(%d/5)", member.membersNum or 1), panel)
    local button = self:getControl("OperateButton", nil, panel)
    button:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            gf:CmdToServer("CMD_ACCEPT", {
                peer_name = member.name,
                ask_type = Const.INVITE_JOIN_TEAM,
            })
        end
    end)
end

-- 设置申请加入队伍列表
function MissionDlg:setRequesters(member, panel)
    self:setImage("ShapeImage", ResMgr:getSmallPortrait(member.portrait), panel)
    self:setItemImageSize("ShapeImage", panel)
    self:setLabelText("LevelLabel", member.level, panel)
    self:setLabelText("MemberNameLabel", gf:getRealName(member.name), panel)
    local button = self:getControl("OperateButton", nil, panel)
    button:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            gf:CmdToServer("CMD_ACCEPT", {
                peer_name = member.name,
                ask_type = Const.REQUEST_JOIN_TEAM,
            })
        end
    end)
end

-- 设置队伍其他成员信息       panel，是否暂离
function MissionDlg:setMembers(member, panel)
    self:setImage("ShapeImage", ResMgr:getSmallPortrait(member.org_icon), panel)
    self:setItemImageSize("ShapeImage", panel)
    -- self:setLabelText("MemberLevelLabel", member.level, panel)
    local level = member.level

    -- 人物等级使用带描边的数字图片显示
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, level, false, LOCATE_POSITION.LEFT_TOP, 19, panel)

    self:setLabelText("MemberNameLabel", gf:getRealName(member.name), panel)
    self:setCtrlVisible("Zanli", false, panel)
    self:setCtrlVisible("OverlineStatusImage", false, panel)
    -- 如果暂离状态
    if member.team_status == 2 then
        self:setCtrlVisible("Zanli", true, panel)
        self:setCtrlEnabled("ShapeImage", false, panel)
    elseif member.team_status == 3 then
        self:setCtrlVisible("OverlineStatusImage", true, panel)
        self:setCtrlEnabled("ShapeImage", false, panel)
    end
end

-- 控件长按
function MissionDlg:blindLongPress(panel, OneSecondLaterFunc, func)
    if not panel then
        Log:W("Dialog:bindListViewListener no control " .. name)
        return
    end

    self:blindLongPressWithCtrl(panel, OneSecondLaterFunc, func, true)

    --[[local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            local callFunc = cc.CallFunc:create(function()
                OneSecondLaterFunc(self, sender, eventType)
                self.root:stopAction(self.longPress)
                self.longPress = nil
            end)

            self.longPress = cc.Sequence:create(cc.DelayTime:create(GameMgr:getLongPressTime()),callFunc)
            self.root:runAction(self.longPress)
        elseif eventType == ccui.TouchEventType.moved then
            if self.longPress ~= nil then
                self.root:stopAction(self.longPress)
                self.longPress = nil
            end


        elseif eventType == ccui.TouchEventType.ended then
            if self.longPress ~= nil then
                self.root:stopAction(self.longPress)
                self.longPress = nil
                func(self, sender, eventType)
            end
        end
    end

    panel:addTouchEventListener(listener)]]
end

function MissionDlg:longPressFun(sender, eventType)
    --[[local members = TeamMgr.members_ex
    local tag = sender:getTag()
    if Me:queryBasic("gid") == members[tag].gid then return end
    local dlg = DlgMgr:openDlg("CharMenuContentDlg")
    dlg:setting(members[tag].gid, false)]]
end

function MissionDlg:chooseMember(sender, eventType)
    local myId = Me:getId()

    local pos = self:getBoundingBoxInWorldSpace(sender)
    local tag = sender:getTag()
    local members = TeamMgr.members_ex

    if not members[tag] then
        return
    end

    TeamMgr.selectMember = members[tag]

    if members[tag].name ~= Me:queryBasic("name") then
        if members[tag].type == OBJECT_TYPE.MONSTER or members[tag].type == OBJECT_TYPE.NPC or members[tag].type == OBJECT_TYPE.FOLLOW_NPC then
            gf:ShowSmallTips(CHS[4000395])
            return
        end

        local rect = self:getBoundingBoxInWorldSpace(sender)
        local dlg = DlgMgr:openDlg("FloatingMenuDlg")
        dlg:setData(members[tag])

        if TeamMgr:getLeaderId() == myId then
            local panel = sender:getParent()
            local item = panel:getChildByTag(1)

            if item then
                dlg:adjustPos(rect, self:getBoundingBoxInWorldSpace(item))
            else
                dlg:adjustPos(rect, rect)
            end

        else
            dlg:adjustPos(rect, rect)
        end

        return
    end


    -- me是暂离队员
    if TeamMgr:inTeamEx(myId) and not TeamMgr:inTeam(myId) and TeamMgr:getLeaderId() ~= myId and members[tag].name == Me:queryBasic("name") then
        local dlg = DlgMgr:openDlg("TeamOPMenuDlg")
        dlg:setDlgDisplayType(3, nil, pos)
        return
    end

    -- me是在职队员
    if TeamMgr:inTeam(myId) and TeamMgr:getLeaderId() ~= myId and members[tag].name == Me:queryBasic("name") then
        local dlg = DlgMgr:openDlg("TeamOPMenuDlg")
        dlg:setDlgDisplayType(4, nil, pos)
        return
    end

    -- me是队长，点击其他队员
    if TeamMgr:getLeaderId() == myId and members[tag].name ~= Me:queryBasic("name") then
        local dlg = DlgMgr:openDlg("TeamOPMenuDlg")
        dlg:setDlgDisplayType(2, members[tag], pos)
        return
    end

    -- me是队长，点击自己
    if TeamMgr:getLeaderId() == myId and members[tag].name == Me:queryBasic("name") then
        local dlg = DlgMgr:openDlg("TeamOPMenuDlg")
        dlg:setDlgDisplayType(1, nil, pos)
        return
    end
end

function MissionDlg:specialToDo(task)


    if task.task_type == CHS[4200442]  then   -- 【指引】居所生产
        if task.task_extra_para == "1" then
            DlgMgr:sendMsg("GameFunctionDlg", "addEffectByButtonName", "FishButton")
        elseif task.task_extra_para == "3" then
            DlgMgr:sendMsg("GameFunctionDlg", "addEffectByButtonName", "PlantButton")
        elseif task.task_extra_para == "7" then
            if MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
                DlgMgr:sendMsg("GameFunctionDlg", "onHomeManageButton")
            end
        end
    elseif task.task_type == CHS[4010168] then
        if task.task_extra_para == "1" then
            -- 桃柳林、官道南、官道北、北海沙滩、揽仙镇外和卧龙坡
            if MapMgr:isInMapByName(CHS[6000605]) or MapMgr:isInMapByName(CHS[3000807]) or MapMgr:isInMapByName(CHS[3000813])
                or MapMgr:isInMapByName(CHS[3000875]) or MapMgr:isInMapByName(CHS[3001301]) or MapMgr:isInMapByName(CHS[3001387]) then

                gf:ShowSmallTips(CHS[4010172]) -- 该地图有许多单身青年，快去帮他们寻找姻缘吧。
            else
                gf:ShowSmallTips(CHS[4010173])    -- 前往#R桃柳林、官道南、官道北、北海沙滩、揽仙镇外和卧龙坡#n为单身男女寻找姻缘吧。
            end
        end
    elseif task.task_type == CHS[4101158] then
        if task.task_extra_para == "1" then
            -- 桃柳林、官道南、官道北、北海沙滩、揽仙镇外和卧龙坡
            if MapMgr:isInMapByName(CHS[6000605]) or MapMgr:isInMapByName(CHS[3001301]) or MapMgr:isInMapByName(CHS[3001387]) then

                gf:ShowSmallTips(CHS[4101162]) -- 该地图有许多北极熊，快去找它们玩耍吧。
            else
                gf:ShowSmallTips(CHS[4101163])    -- 快前往#R桃柳林、揽仙镇外和卧龙坡#n找北极熊玩耍吧。
            end
        end
    elseif task.task_type == CHS[4101168] then
        if task.task_extra_para == "1" then
            -- 桃柳林、官道南、官道北、北海沙滩、揽仙镇外和卧龙坡
            if MapMgr:isInMapByName(CHS[6000317]) or MapMgr:isInMapByName(CHS[6000334]) or MapMgr:isInMapByName(CHS[7002263]) or MapMgr:isInMapByName(CHS[7190212])  then

                gf:ShowSmallTips(CHS[4101172]) -- 该地图有许多诗人正在赏雪吟诗，快去找他们吧。
            else
                gf:ShowSmallTips(CHS[4101173])    -- 前往#R东昆仑、碧游宫、雪域冰原和揽仙镇#n与诗人赏雪吟诗。
            end
        end
    end
end

function MissionDlg:setTaskPanel(task, panel)
    if not panel or not task then return end
    local infoPanel = self:getControl("CurrentNotePanel", nil, panel)
    infoPanel:removeAllChildren()
    infoPanel:setContentSize(self.infoPanelSize)
    self:getControl("OneRowMissionPanel_1", nil, panel):setContentSize(self.singleTaskPanelSize)
    panel:setContentSize(self.singleTaskPanelSize)

    local panelSize = panel:getContentSize()
    panel.task_type = task.task_type
    -- 任务名字
    self:setLabelText("MissionNameLabel", task.show_name, panel)

    local str = ""
    local timeTemp = gfGetTickCount()

    if string.match(task.task_prompt, "TIME_LEFT") then
        local leftTime = TaskMgr:getTaskTimeStr(task)
        str = string.gsub(task.task_prompt, "TIME_LEFT", leftTime)


        local leftTimeInt = math.max(0, task.task_end_time - gf:getServerTime())
        panel:stopAllActions()
        if leftTimeInt > 0 then
            performWithDelay(panel, function ()
                self:setTaskPanel(task, panel)
            end, TaskMgr:getTaskDelayTime(task))
        end
    else
        str = task.task_prompt
        panel:stopAllActions()
    end

    -- 任务信息
    local infoSize = infoPanel:getContentSize()
    local tip = CGAColorTextList:create()
    tip:setFontSize(FONT_HEIGHT)
    tip:setString(str)
    tip:setContentSize(infoSize.width, 0)
    tip:updateNow()

    local textW, textH = tip:getRealSize()

    -- 大小设置  如果超过两行，增加23像素
    if textH > FONT_HEIGHT * 1.5 then
        infoPanel:setContentSize(infoSize.width, infoSize.height + 23)
        self:getControl("OneRowMissionPanel_1", nil, panel):setContentSize(panelSize.width, panelSize.height + 23)
        panel:setContentSize(panelSize.width, panelSize.height + 23)
    else
        infoPanel:setContentSize(infoSize)
        self:getControl("OneRowMissionPanel_1", nil, panel):setContentSize(self.singleTaskPanelSize)
        panel:setContentSize(self.singleTaskPanelSize)
    end

    infoSize = infoPanel:getContentSize()
    tip:setPosition(0, (infoSize.height - textH) * 0.5)
    local colorLayer = tolua.cast(tip, "cc.LayerColor")
    colorLayer:setAnchorPoint(0,0)
    infoPanel:addChild(colorLayer)
    infoPanel:setEnabled(false)

    -- 光效
    if task.isMagic then
        self:removeMagic(panel, Const.ARMATURE_MAGIC_TAG)
        -- 大小设置  如果超过两行，增加23像素
        if textH > FONT_HEIGHT * 1.5 then
            -- lixh2 WDSY-21401 帧光效修改为粒子光效：任务栏环绕光效二行
            gf:createArmatureMagic(ResMgr.ArmatureMagic.main_ui_task2, panel, Const.ARMATURE_MAGIC_TAG)
        else
            -- lixh2 WDSY-21401 帧光效修改为粒子光效：任务栏环绕光效一行
            gf:createArmatureMagic(ResMgr.ArmatureMagic.main_ui_tast1, panel, Const.ARMATURE_MAGIC_TAG)
        end
       
    end
    panel:requestDoLayout()
    panelSize = panel:getContentSize()
    local function callFunc()

        -- GM处于监听状态下
        if GMMgr:isStaticMode() then
            gf:ShowSmallTips(CHS[3003130])
            return
        end

        -- 移除任务面板的光效
        task.isMagic = false
        self:removeMagic(panel, Const.ARMATURE_MAGIC_TAG)

        local ret = TaskMgr:checkCanGotoTask(tip, task)
        if ret.result then
            -- 验证通过
            if ret.succ_type == TaskMgr.CHEKC_TASK.NOT_TYPE_NPC_ZONE then
                gf:onCGAColorText(tip, panel, task)
                if tip:getCsType() ~= CONST_DATA.CS_TYPE_DLG
                    and tip:getCsType() ~= CONST_DATA.CS_TYPE_CALL
                    and not task.name == CHS[4010130] then
                    local dlg = DlgMgr:openDlg("TaskDlg")
                    dlg:chooseTaskItemByTask(task)
                end
            elseif ret.succ_type == TaskMgr.CHEKC_TASK.SHOW_SMALL_TIPS then
                gf:ShowSmallTips(ret.autoWalkInfo.tipText)
            else
                AutoWalkMgr:beginAutoWalk(ret.autoWalkInfo)
            end

            -- 分发点击事件
            EventDispatcher:dispatchEvent(EVENT.TOUCH_TASK_LOG, { taskData = task })
        end

        -- CG外挂
        if task.task_type == CHS[5000161] then
            RecordLogMgr:isMeetCGPluginCondition("MissionDlg")
        end

        -- 刷道自动开始
        StateShudMgr:tryChangeToShuad(task.task_type)


        self:specialToDo(task)
    end

    local function resFunc()
        self:removeMagic(panel, Const.ARMATURE_MAGIC_TAG)
        local listView = self:getControl("MissionListView")
        local itemsPanels = listView:getItems()
        for _,panel in pairs(itemsPanels) do
            self:getControl("OneRowMissionPanel_1", nil, panel):setScale(1)
        end
    end

    -- 点击任务信息
    self:blindLongPressTakView(self:getControl("OneRowMissionPanel_1", nil, panel), nil, callFunc, resFunc)

    if task.autoClick then
        performWithDelay(self.root, function()
            panel:setScale(0.95)
            performWithDelay(self.root, function()
                task.autoClick = nil
                callFunc()
                self:getControl("OneRowMissionPanel_1", nil, panel):setScale(1)
            end, 0.5)
        end, 0.5)
    end
end

-- 控件长按
function MissionDlg:blindLongPressTakView(widget, OneSecondLaterFunc, func, resFunc)
    if not widget then
        return
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            local callFunc = cc.CallFunc:create(function()
                if OneSecondLaterFunc then
                    OneSecondLaterFunc(self, sender, eventType)
                end
                widget:stopAction(self.longPress)
                self.longPress = nil
            end)
            widget:setScale(0.95)
            self.longPress = cc.Sequence:create(cc.DelayTime:create(1),callFunc)
            widget:runAction(self.longPress)
        elseif eventType == ccui.TouchEventType.ended then
            if self.longPress ~= nil then
                self.root:stopAction(self.longPress)
                self.longPress = nil
                func(self, sender, eventType)
            end
            widget:setScale(1)
        elseif eventType == ccui.TouchEventType.moved then
            local list = self:getControl("MissionListView", Const.UIListView)
            Log:D("innerY:" .. list:getInnerContainer():getPositionY())
            Log:D("innerHeight:" .. list:getInnerContainer():getContentSize().height)
        else
            if resFunc then
                resFunc(self, sender, eventType)
            end
            end
        end

    widget:addTouchEventListener(listener)
end

function MissionDlg:removeTask(task)
    local list = self:getControl("MissionListView", Const.UIListView)
    local items = list:getItems()
    local totalHeight = list:getInnerContainerSize().height
    local pos = nil
    for i, panel in pairs(items) do
        if panel.task_type and panel.task_type == task.task_type then
            pos = i
        else
            totalHeight = totalHeight - panel:getContentSize().height - ITEM_MARGIN
        end
    end
    if pos then list:removeItem(pos - 1) end

    self:setCtrlVisible("TaskEmptyPanel", #list:getItems() == 0)

    -- 删除某一项后，从新计算list的contentSize，高，直接通过接口获取有问题
    local items = list:getItems()
    local listHeight = 0
    for i, panel in pairs(items) do
        listHeight = listHeight + panel:getContentSize().height + ITEM_MARGIN
    end

    local missionPanelSize = self:getControl("MissionPanel"):getContentSize()
    if listHeight < missionPanelSize.height then
        list:setContentSize(list:getContentSize().width, listHeight)
    else
        list:setContentSize(list:getContentSize().width, missionPanelSize.height)
    end
    list:getInnerContainer():setContentSize(list:getInnerContainerSize().width, totalHeight)

    performWithDelay(self.root, function ()
        list:requestDoLayout()
        self:updateLayout("MissionPanel")
    end, 0)
end

function MissionDlg:resetTask(task)
    local list = self:getControl("MissionListView", Const.UIListView)
    local items = list:getItems()
    local totalHeight = 0
    local isNeedRefresh = true
    for i, panel in pairs(items) do
        if panel.task_type and panel.task_type == task.task_type then
            panel:stopAllActions()
            self:setTaskPanel(task, panel)
            isNeedRefresh = false
        end
        totalHeight = panel:getContentSize().height + totalHeight
    end

    -- 八仙、副本地图需要刷新，需要放在 isNeedRefresh条件判断前，否则进入该分支被return
    if MapMgr:isInBaXian() then
        self:refreshBaxianPanel()
    elseif MapMgr:isInDugeon() then
        self:refreshFubenPanel()
    end

    if isNeedRefresh then
        TaskMgr:setTheFitstDisplayTask(task.task_type)
        self:MSG_TASK_PROMPT()
        return
    end

    local missionPanel = self:getControl("MissionPanel")
    if #items > 0 then totalHeight = totalHeight + (#items - 1) * ITEM_MARGIN end
    -- 设置list大小
    if totalHeight < missionPanel:getContentSize().height then
        list:setContentSize(list:getContentSize().width, totalHeight)
    else
        if list:getContentSize().height ~= missionPanel:getContentSize().height then
            list:setContentSize(list:getContentSize().width, missionPanel:getContentSize().height)
        end
    end

    -- 设置list:getInnerContainer大小（子panel修改高度，不会自动修改，手动修改）
    local disMargin = totalHeight - list:getInnerContainerSize().height
    list:getInnerContainer():setContentSize(list:getInnerContainerSize().width, totalHeight)
    list:getInnerContainer():setPositionY(list:getInnerContainer():getPositionY() - disMargin)

    -- 刷新
    performWithDelay(self.root, function ()
        self:updateLayout("MissionPanel")
    end, 0)
end

function MissionDlg:taskTop()
    performWithDelay(self.root, function ()
    local list = self:getControl("MissionListView", Const.UIListView)
    local items = list:getItems()
    local height = 0
    for k, panel in pairs(items) do
        height = height + panel:getContentSize().height
    end

    height = height + (#items - 1) * ITEM_MARGIN
    if height <= list:getContentSize().height then return end
        list:getInnerContainer():setPositionY(list:getContentSize().height - height)
        self:updateLayout("MissionPanel")
    end, 0)
end

function MissionDlg:updateCCJB(data)
    if not data then return end
    for k, v in ipairs(data) do
        if v.task_type == CHS[4100781] then
            self:setColorText(v.task_prompt, "CCJBPanel")
        end
    end
end

function MissionDlg:MSG_TASK_PROMPT(data)
  --  self:updateCCJB(data)

    self:stopAllActions()
    self:initMissionList()
    local tasks = self:getOrderTask(TaskMgr.tasks)
    if not tasks  then return end

    if DistMgr:isInQcldServer() then
        -- 青城论道需要在接到记者任务时刷新任务面板
        for k, v in pairs(TaskMgr.tasks) do
            if k == CHS[7150140] then
                self:updateQingChengLunDaoInfo()
            end
        end
    end

    local list = self:getControl("MissionListView", Const.UIListView)
    if TaskMgr:getTheFitstDisplayTask() == "" then
        performWithDelay(self.root, function ()
            list:getInnerContainer():setPositionY(0)
        end, 0)

        if MapMgr:isInBaXian() then
            self:refreshBaxianPanel()
        elseif MapMgr:isInDugeon() then
            self:refreshFubenPanel()
        end
        return
    end
    local height = 0
    local off = true
    local items = list:getItems()
    for k, panel in pairs(items) do
        if tasks[k].task_type == TaskMgr:getTheFitstDisplayTask() then
            off = false
            if self:getControl("MissionPanel"):getContentSize().height == list:getContentSize().height then
                performWithDelay(self.root, function ()
                    height = list:getInnerContainer():getContentSize().height - list:getContentSize().height - height
                    list:getInnerContainer():setPositionY(-height + ITEM_MARGIN)
                    self:updateLayout("MissionPanel")
                end, 0)
            end
        end
        if off then height = height + panel:getContentSize().height + ITEM_MARGIN end
    end
end

function MissionDlg:MSG_CLEAN_REQUEST(data)
    if data.ask_type == Const.REQUEST_JOIN_TEAM then
        self:updateTeamInfo()
    end
end

function MissionDlg:MSG_DIALOG(data)
    if data.ask_type == Const.REQUEST_JOIN_TEAM or data.ask_type == Const.INVITE_JOIN_TEAM then
        self:updateTeamInfo()
    elseif data.ask_type == Const.PWAR_AROUND_TEAM or data.ask_type == Const.PWAR_AROUND_PLAYER
     or data.ask_type == Const.KFZC2019_AROUND_TEAM or data.ask_type == Const.KFZC2019_AROUND_PLAYER then

        self:pushWarPlayer(data)
    end
end

function MissionDlg:MSG_UPDATE_TEAM_LIST_EX(data)

    self:updateTeamInfo()

    if DistMgr:isInKFJJServer() then
        self:refreshKFJJPanel()
    end
end

function MissionDlg:setDisplayType(type)
    self.curDisplayType = type
end

-- 显示类型  1为任务   2为通天塔  3组队
function MissionDlg:displayType(type)
    if type ~= nil and type ~= displayPartyWar and type ~= displayCityWar then
        self.enterRoomDisplayType = type
    end

    if type == nil then
        -- type == nil为过图后，不存在通天塔模式
        self:setCtrlVisible("MissionButton", true)
        self:setCtrlVisible("TongtiantaButton", false)
        self:setCtrlVisible("PartyWarPanel", false)
        self:setCtrlVisible("NewPartyWarPanel", false)
        self:setCtrlVisible("NewPartyWar2Panel", false)
        local partyWarPanel = self:getControl("PartyWarPanel")
        partyWarPanel:stopAllActions()
        type = self.enterRoomDisplayType or displayTask
        if type == displayTongtianta or
            type == displayTTTTD or
           type == displayBaxin or
           type == displayFuben or
           type == displayKFJJ or
            type == displayMRZB or
           type == displayQMPK or
           type == displayKFSD or
            type == displayKFZC2019 or
           type == displaySDDH or
           type == displayQcld then
            type = displayTask
        end

        if MapMgr:isInBaXian() then
            type = displayBaxin
            self:setCheck("MissionCheckBox", true)
            self:setCheck("TeamCheckBox", false)
            self:onShowDialogButton()
        elseif MapMgr:isInDugeon() then
            type = displayFuben
            self:setCheck("MissionCheckBox", true)
            self:setCheck("TeamCheckBox", false)
            self:onShowDialogButton()
        elseif DistMgr:isInQMPKServer() then
            type = displayQMPK
            self:setCheck("MissionCheckBox", true)
            self:setCheck("TeamCheckBox", false)
            self:onShowDialogButton()
        elseif MapMgr:isInMRZB() then
            type = displayMRZB
            self:setCheck("MissionCheckBox", true)
            self:setCheck("TeamCheckBox", false)
            self:onShowDialogButton()
        elseif GameMgr:isInPartyWar() then
            type = displayPartyWar
            self:setCheck("MissionCheckBox", true)
            self:setCheck("TeamCheckBox", false)
            self:onShowDialogButton()
        elseif DistMgr:isInKFJJServer() then
            type = displayKFJJ
            self:setCheck("MissionCheckBox", true)
            self:setCheck("TeamCheckBox", false)
            self:onShowDialogButton()
        elseif DistMgr:isInKFSDServer() then
            type = displayKFSD
            self:setCheck("MissionCheckBox", true)
            self:setCheck("TeamCheckBox", false)
            self:onShowDialogButton()
        elseif MapMgr:isInShiDao() then
            type = displaySDDH
            self:setCheck("MissionCheckBox", true)
            self:setCheck("TeamCheckBox", false)
            self:onShowDialogButton()
        elseif KuafzcMgr:isInKuafzc2019() then
            type = displayKFZC2019
            self:setCheck("MissionCheckBox", true)
            self:setCheck("TeamCheckBox", false)
       --     self:onShowDialogButton()
        elseif MapMgr:isInQingcld() then
            type = displayQcld
            self:setCheck("MissionCheckBox", true)
            self:setCheck("TeamCheckBox", false)
            self:onShowDialogButton()
        end
    end

    if self.curDisplayType ~= type then
        if self.curDisplayType == displayPartyWar then
            -- 关闭帮派大战的界面
            DlgMgr:closeDlg("PartyWarEnemyMenuDlg")
        end
    end

    self.curDisplayType = type

    self:getControl("MissionPanel"):setEnabled(false)
    self:getControl("TeamPanel"):setEnabled(false)
    self:getControl("TongtiantaPanel"):setEnabled(false)

    self:setCtrlVisible("MissionPanel", false)

    self:setCtrlVisible("TeamPanel", false)
    self:setCtrlVisible("TongtiantaPanel", false)
    self:setCtrlVisible("TongtiantaTopPanel", false)
    self:setCtrlVisible("EightImmortalsPanel", false)
    self:setCtrlVisible("DugeonPanel", false)
    self:setCtrlVisible("PartyWarPanel", false)
    self:setCtrlVisible("NewPartyWarPanel", false)
    self:setCtrlVisible("NewPartyWar2Panel", false)
    self:setCtrlVisible("XueJingPanel", false)
    self:setCtrlVisible("KuafjjPanel", false)
    self:setCtrlVisible("KuafsdPanel", false)
    self:setCtrlVisible("LaoDongPanel", false)
    self:setCtrlVisible("DuanWuPanel", false)
    self:setCtrlVisible("TanAnRkszPanel", false)
    self:setCtrlVisible("QingChengLunDaoPanel", false)

    self:getControl("KuafsdPanel"):stopAllActions()

    if type == displayTask then
        self:getControl("MissionPanel"):setEnabled(true)
        self:setCtrlVisible("MissionPanel", true)
        self:setCtrlVisible("MijingPanel", false)
        self:setCtrlVisible("ZongXianPanel", false)
        self:setCtrlVisible("QuanmPKPanel", false)
        self:setCtrlVisible("OreWarsPanel", false)
        self:setCtrlVisible("WanYaoPanel", false)
        self:setCtrlVisible("InvadePanel", false)
        self:setCtrlVisible("ZhongXianPanel", false)
    elseif type == displayTongtianta or displayTTTTD == type then
        self:setCheck("MissionCheckBox", true)
        self:setCheck("TeamCheckBox", false)

        if type == displayTongtianta then
            self:getControl("TongtiantaPanel"):setEnabled(true)
            self:setCtrlVisible("TongtiantaPanel", true)
            self:setCtrlVisible("RewardPanel", true)
            self:setCtrlVisible("JumpPanel", true)
        else
            self:setCtrlVisible("TongtiantaTopPanel", true)
        end

        self:setCtrlVisible("ResetPanel", false)
        self:setCtrlVisible("GetRewardPanel", false)
        self:setCtrlVisible("MijingPanel", false)
        self:setCtrlVisible("ZongXianPanel", false)
        self:setCtrlVisible("QuanmPKPanel", false)
        self:setCtrlVisible("OreWarsPanel", false)
        self:setCtrlVisible("WanYaoPanel", false)
        self:setCtrlVisible("InvadePanel", false)
        self:setCtrlVisible("ZhongXianPanel", false)
        if self:getControl("ShowDialogButton"):isVisible() then
            self:hide(false)
        end

        local panel = self:getControl("EscalatorPanel")
        local infoPanel = self:getControl("LevelInfoPanel")
        local tongtianPanel = self:getControl("TongtiantaPanel")
        local changePanel = self:getControl("ChallengePanel", nil, tongtianPanel)
        panel:setAnchorPoint(0.5, 0.5)
        changePanel:setAnchorPoint(0.5, 0.5)

        self:setCtrlVisible("EscalatorPanel", false)
        infoPanel:setContentSize(self.tongtianInfoSize.width, self.tongtianInfoSize.height - panel:getContentSize().height)
        tongtianPanel:setContentSize(infoPanel:getContentSize())

        self:updateLayout("EscalatorPanel")
        self:updateLayout("ChallengePanel")
        self:updateLayout("LevelInfoPanel")
        self:updateLayout("TongtiantaPanel")
        self:updateLayout("InfoPanel")
    elseif type == displayBaxin then
        self:setCtrlVisible("EightImmortalsPanel", true)

        self:setCtrlVisible("MijingPanel", false)
        self:setCtrlVisible("ZongXianPanel", false)
        self:setCtrlVisible("QuanmPKPanel", false)
        self:setCtrlVisible("OreWarsPanel", false)
        self:setCtrlVisible("WanYaoPanel", false)
        self:setCtrlVisible("InvadePanel", false)
        self:setCtrlVisible("ZhongXianPanel", false)
        self:refreshBaxianPanel()
    elseif type == displayFuben then
        self:setCtrlVisible("DugeonPanel", true)
        self:setCtrlVisible("MijingPanel", false)
        self:setCtrlVisible("ZongXianPanel", false)
        self:setCtrlVisible("QuanmPKPanel", false)
        self:setCtrlVisible("OreWarsPanel", false)
        self:setCtrlVisible("WanYaoPanel", false)
        self:setCtrlVisible("InvadePanel", false)
        self:setCtrlVisible("ZhongXianPanel", false)
        self:refreshFubenPanel()
    elseif type == displayTeam then
        self:getControl("TeamPanel"):setEnabled(true)

        self:setCtrlVisible("TeamPanel", true)
        self:setCtrlVisible("MijingPanel", false)
        self:setCtrlVisible("ZongXianPanel", false)
        self:setCtrlVisible("QuanmPKPanel", false)
        self:setCtrlVisible("OreWarsPanel", false)
        self:setCtrlVisible("WanYaoPanel", false)
        self:setCtrlVisible("InvadePanel", false)
        self:setCtrlVisible("ZhongXianPanel", false)
        self:setCheck("MissionCheckBox", false)
        self:setCheck("TeamCheckBox", true)
        self:updateTeamInfo()
    elseif type == displayPartyWar then
        self:setCtrlVisible("MijingPanel", false)
        self:setCtrlVisible("ZongXianPanel", false)
        self:setCtrlVisible("OreWarsPanel", false)
        self:setCtrlVisible("WanYaoPanel", false)
        self:setCtrlVisible("QuanmPKPanel", false)
        self:setCtrlVisible("InvadePanel", false)
        self:setCtrlVisible("ZhongXianPanel", false)

        self:setCtrlVisible("NewPartyWarPanel", false)
        self:setCtrlVisible("NewPartyWar2Panel",false)
        self:setCtrlVisible("PartyWarPanel", false)
        local newData = PartyWarMgr:getNewPartyWarData()
        if newData then
            self:setCtrlVisible("NewPartyWarPanel", newData.is_security == 0)
            self:setCtrlVisible("NewPartyWar2Panel", newData.is_security == 1)
        end

        if Me:getTitle() == CHS[4300269] then
            self:setCtrlVisible("NewPartyWarPanel", false)
            self:setCtrlVisible("NewPartyWar2Panel", true)
        end
    elseif type == displayQMPK or type == displayMRZB then
        self:setCtrlVisible("MijingPanel", false)
        self:setCtrlVisible("ZongXianPanel", false)
        self:setCtrlVisible("QuanmPKPanel", true)
        self:setCtrlVisible("InvadePanel", false)
        self:setCtrlVisible("ZhongXianPanel", false)
        if type == displayQMPK then
            QuanminPK2Mgr:requestQmpkInfo()
        end
    elseif type == displayKFJJ then
        self:setCtrlVisible("MijingPanel", false)
        self:setCtrlVisible("ZongXianPanel", false)
        self:setCtrlVisible("QuanmPKPanel", false)
        self:setCtrlVisible("InvadePanel", false)
        self:setCtrlVisible("ZhongXianPanel", false)
        self:setCtrlVisible("KuafjjPanel", true)
        self:refreshKFJJPanel()
    elseif type == displayKFSD then
        self:setCtrlVisible("MijingPanel", false)
        self:setCtrlVisible("ZongXianPanel", false)
        self:setCtrlVisible("QuanmPKPanel", false)
        self:setCtrlVisible("InvadePanel", false)
        self:setCtrlVisible("ZhongXianPanel", false)
        self:setCtrlVisible("KuafsdPanel", true)
        self:refreshKFSDPanel()
    elseif type == displaySDDH then
        self:setCtrlVisible("MijingPanel", false)
        self:setCtrlVisible("ZongXianPanel", false)
        self:setCtrlVisible("QuanmPKPanel", false)
        self:setCtrlVisible("InvadePanel", false)
        self:setCtrlVisible("ZhongXianPanel", false)
        self:setCtrlVisible("KuafsdPanel", true)
        self:refreshSDDHPanel()
    elseif type == displayKFZC2019 then
        self:setCtrlVisible("NewPartyWarPanel", true)
        self:updatePartyWarInfo()
    elseif type == displayQcld then
        self:setCtrlVisible("QingChengLunDaoPanel", true)
        self:updateQingChengLunDaoInfo()
    end

    if type ~= displayTongtianta then
        if TaskMgr:getIsAutoChallengeTongtian() and type == displayTeam then
            -- 自动扫塔中，切换到组队界面，不清除通天塔自动信息
            return
        end

        -- 非通天塔模式，清除通天塔自动信息
        self:clearAutoChallengeTongtian()
    end
end

function MissionDlg:refreshBaxianPanel()
    local changePanel = self:getControl("ChallengePanel", nil, "EightImmortalsPanel")
    changePanel:setAnchorPoint(0.5, 0.5)

    local task = TaskMgr:getBaxianTask()
    if task then
        self:setLabelText("NameLabel", task.show_name, "EightImmortalsPanel")

        -- 任务信息
        local infoPanel =  self:getControl("CurrentPanel", nil, "EightImmortalsPanel")
        infoPanel:removeAllChildren()
        local infoSize = infoPanel:getContentSize()
        local tip = CGAColorTextList:create()
        tip:setFontSize(FONT_HEIGHT)
        tip:setString(task.task_prompt)
        tip:setContentSize(infoSize.width, 0)
        tip:updateNow()

        local textW, textH = tip:getRealSize()
        tip:setPosition(0, (infoSize.height - textH) * 0.5)
        local colorLayer = tolua.cast(tip, "cc.LayerColor")
        colorLayer:setAnchorPoint(0,0)
        infoPanel:addChild(colorLayer)
        infoPanel:setEnabled(false)

        self:updateLayout("EightImmortalsPanel")
    end
end

function MissionDlg:refreshFubenPanel()
    if displayFuben ~= self.curDisplayType then return end

    -- 须弥秘境/矿石大战/粽仙试炼/万妖/异族入侵的任务面板不再依附于DuegonPanel，
    -- 但刷新逻辑/规则与离开按钮响应仍然保持与一般副本一致

    -- 重置界面时需要停止这些不从属于DugeonPanel的panel的计划事件
    local oreWarsPanel = self:getControl("OreWarsPanel")
    oreWarsPanel:stopAllActions()

    -- 重置所有不依附于DuegonPanel的PANEL显示/隐藏状态
    self:setCtrlVisible("DugeonPanel", false)
    self:setCtrlVisible("MijingPanel", false)
    self:setCtrlVisible("WanYaoPanel", false)
    self:setCtrlVisible("InvadePanel", false)
    self:setCtrlVisible("ZongXianPanel", false)
    self:setCtrlVisible("OreWarsPanel", false)
    self:setCtrlVisible("ZhongXianPanel", false)

    if MapMgr:isInMiJing() then
        self:setCtrlVisible("MijingPanel", true)

        local mijingInfo = TaskMgr:getMiJingInfo()
        if not mijingInfo then
            return
        end

        local floorStr = string.format(CHS[7003036], mijingInfo.floor)
        local strengthStr = string.format(CHS[7002199], mijingInfo.strength)
        local guardStr = string.format(CHS[7003037], mijingInfo.guard)
        local bookStr = string.format(CHS[7003038], mijingInfo.book)
        self:setLabelText("NameLabel", floorStr, "MijingPanel")
        self:setLabelText("Label2", strengthStr, "MijingPanel")
        self:setLabelText("Label3", guardStr, "MijingPanel")
        self:setLabelText("Label4", bookStr, "MijingPanel")
        return
    elseif MapMgr:isInOreWars() then
        self:setCtrlVisible("OreWarsPanel", true)

        local function oreFunc()
            local timeInfo = TaskMgr:getOreWarsTimeInfo() or {}
            local startTime = timeInfo.start_time
            local endTime = timeInfo.end_time
            local nowTime = gf:getServerTime()
            if not startTime or nowTime <= startTime then
                -- 活动尚未开始的默认界面
                -- 阵营总矿石
                self:setLabelText("OreLabel_1", 0, oreWarsPanel)
                self:setLabelText("OreLabel_3", 0, oreWarsPanel)

                -- 排名
                self:setLabelText("RankLabel", CHS[7002255], oreWarsPanel)

                -- 个人的矿石
                local selfOreLabel = self:getControl("OreNumLabel", nil, oreWarsPanel)
                selfOreLabel:setColor(TaskMgr:getOreWarsCampColor())
                selfOreLabel:setText(0)

                -- 距离活动开始还有多久
                self:setLabelText("TimeLabel", CHS[7002253], oreWarsPanel)
                if startTime then
                    local leftTime = startTime - nowTime
                    local leftMin = math.floor(leftTime / 60)
                    local leftSec = leftTime - leftMin * 60
                    local str = string.format(CHS[7002256], leftMin, leftSec)
                    self:setLabelText("LeftTimeLabel", str, oreWarsPanel)
               end
            else
                -- 活动已经开始
                local oreWarsInfo = TaskMgr:getOreWarsInfo()
                if not oreWarsInfo then
                    return
                end

                -- 阵营总矿石
                self:setLabelText("OreLabel_1", oreWarsInfo.lmjs, oreWarsPanel)
                self:setLabelText("OreLabel_3", oreWarsInfo.cylm, oreWarsPanel)

                -- 排名
                local rankStr
                local rank = oreWarsInfo.rank or 0
                if rank > 20 then
                    rankStr = CHS[7002271]
                elseif rank > 0 then
                    rankStr = string.format(CHS[7002270], rank)
                else
                    rankStr = CHS[7002255]
                end

                self:setLabelText("RankLabel", rankStr, oreWarsPanel)

                -- 个人的矿石
                local selfOreLabel = self:getControl("OreNumLabel", nil, oreWarsPanel)
                selfOreLabel:setColor(TaskMgr:getOreWarsCampColor())

                local score = oreWarsInfo.score or 0
                if score == 0 then
                    selfOreLabel:setText(CHS[7002255])
                else
                    selfOreLabel:setText(oreWarsInfo.score)
                end

                -- 距离活动结束还有多久
                self:setLabelText("TimeLabel", CHS[7002254], oreWarsPanel)
                if endTime then
                    local leftTime = endTime - nowTime
                    local leftMin = math.floor(leftTime / 60)
                    local leftSec = leftTime - leftMin * 60
                    local str = string.format(CHS[7002256], leftMin, leftSec)
                    self:setLabelText("LeftTimeLabel", str, oreWarsPanel)
                end
            end
        end

        schedule(oreWarsPanel, oreFunc, 1)
        oreFunc()
        return
    elseif MapMgr:isInZongXianLou() then
        -- 粽仙楼
        self:setCtrlVisible("ZongXianPanel", true)
        local zongXianInfo = TaskMgr:getZongXianInfo()
        local floor = MapMgr:getZongXianLouFloor()
        if not zongXianInfo or not floor then
            return
        end

        local data = zongXianInfo
        local tip = TaskMgr:getZongXianAutoWalkTip()
        local needAdjustSoaringPanelPos = true

        -- 初始化
        self:setCtrlVisible("ChallengePanel1", false, "ZongXianPanel")
        self:setCtrlVisible("ChallengePanel2", false, "ZongXianPanel")
        self:setCtrlVisible("ChallengePanel3", false, "ZongXianPanel")
        self:setCtrlVisible("ChallengePanel4", false, "ZongXianPanel")
        self:setLabelText("NameLabel", string.format(CHS[7003059], floor), "ZongXianPanel")

        if tip then
            -- 当前处于已经通关第一/二层等待进入下一层的状态
            self:setCtrlVisible("ChallengePanel4", true, "ZongXianPanel")
            self:setColorText(tip, "LabelPanel", "ZongXianPanel", 0, 0, COLOR3.WHITE, 17, true)
        else
            if floor == 1 then
                local root = self:getControl("ChallengePanel1", nil, "ZongXianPanel")
                root:setVisible(true)
                self:setLabelText("Label1", string.format(CHS[7003060], data.qinglong), root)
                self:setLabelText("Label2", string.format(CHS[7003061], data.baihu), root)
                self:setLabelText("Label3", string.format(CHS[7003062], data.zhuque), root)
                self:setLabelText("Label4", string.format(CHS[7003063], data.xuanwu), root)
                needAdjustSoaringPanelPos = false
            elseif floor == 2 then
                local root = self:getControl("ChallengePanel2", nil, "ZongXianPanel")
                root:setVisible(true)
                self:setLabelText("Label1", string.format(CHS[7003064], data.zuoHF), root)
                self:setLabelText("Label2", string.format(CHS[7003065], data.youHF), root)
            elseif floor == 3 then
                local root = self:getControl("ChallengePanel3", nil, "ZongXianPanel")
                root:setVisible(true)
                self:setLabelText("Label1", string.format(CHS[7003066], data.huanying), root)
            end
        end

        local soaringPanel = self:getControl("SoaringPanel", nil, "ZongXianPanel")
        if self.zongXianSoaringPanelOriginPosY then
            -- 由于不同情况下ChallengePanel大小不同，需要调整SoaringPanel的位置
            if needAdjustSoaringPanelPos then
                local challengePanel1 = self:getControl("ChallengePanel1", nil, "ZongXianPanel")
                local challengePanel2 = self:getControl("ChallengePanel2", nil, "ZongXianPanel")
                local offset = challengePanel1:getContentSize().height - challengePanel2:getContentSize().height
                soaringPanel:setPositionY(self.zongXianSoaringPanelOriginPosY + offset)
            else
                soaringPanel:setPositionY(self.zongXianSoaringPanelOriginPosY)
            end
        end

        return
    elseif MapMgr:isInZhongXian() then
        self:setCtrlVisible("ZhongXianPanel", true)
        local taskInfo = TaskMgr:getZhongXianInfo()
        if not taskInfo then return end
        self:setLabelText("NameLabel", string.format(CHS[2000344], taskInfo.layer, taskInfo.max_layer), "ZhongXianPanel")
        self:setLabelText("Label1", CHS[2000345], "ZhongXianPanel")
        self:setColorText(string.format(CHS[2000346], taskInfo.feature), "TextPanel", "ZhongXianPanel", nil, nil, COLOR3.WHITE, 19, true)
        return
    elseif MapMgr:isInXueJingShengdi()  then
        -- 【圣诞】巧收雪精
        self:setCtrlVisible("XueJingPanel", true)
        local task = TaskMgr:getFuBenTaskData()
        if task then
            local desc = task.task_prompt
            self:setLabelText("NameLabel", CHS[5450063], "XueJingPanel")
            self:setColorText(desc, "CurrentPanel", "XueJingPanel", nil, 20, COLOR3.WHITE, 19, true)
            if string.match(task.task_prompt, "#C") then
                self:setCtrlVisible("InfoLabel", false, "XueJingPanel")
            else
                self:setCtrlVisible("InfoLabel", true, "XueJingPanel")
            end
        end

        return
    elseif MapMgr:isInShanZei() or MapMgr:isInTanAnMxza() then
        -- 【劳动节】锄强扶弱,【探案】迷仙镇案
        local taskName = CHS[7190144]
        local taskRoot = "LaoDongPanel"
        if TaskMgr:getTaskByName(CHS[7190231]) then
            -- 【探案】人口失踪
            taskName = CHS[7190231]
            taskRoot = "TanAnRkszPanel"
        elseif TaskMgr:getTaskByName(CHS[7190287]) then
            -- 【探案】迷仙镇案
            taskName = CHS[7190287]
            taskRoot = "TanAnRkszPanel"
        end

        self:setCtrlVisible("LaoDongPanel", false)
        self:setCtrlVisible("TanAnRkszPanel", false)
        self:setCtrlVisible(taskRoot, true)
        local task = TaskMgr:getFuBenTaskData()
        if task then
            local desc = task.task_prompt
            self:setLabelText("NameLabel", taskName, taskRoot)
            self:setColorText(desc, "CurrentPanel", taskRoot, nil, 20, COLOR3.WHITE, 19, true)
            if string.match(task.task_prompt, "#C") or TaskMgr:getTaskByName(CHS[7190231])
                or TaskMgr:getTaskByName(CHS[7190287]) then
                self:setCtrlVisible("InfoLabel", false, taskRoot)
            else
                self:setCtrlVisible("InfoLabel", true, taskRoot)
            end
        end

        return

    elseif MapMgr:isInMapByName(CHS[4010025]) or MapMgr:isInMapByName(CHS[4101241]) then
        -- 端午-采集仙粽
        self:setCtrlVisible("DuanWuPanel", true)

        self:setCtrlContentSize("CurrentPanel", self.laodCurrentPanelSize.width, self.laodCurrentPanelSize.height, "DuanWuPanel")
        self:setCtrlVisible("InfoLabel", false, "DuanWuPanel")
        local task = TaskMgr:getFuBenTaskData()
        if task then

            if MapMgr:isInMapByName(CHS[4101241]) then
                self:setLabelText("NameLabel", CHS[4101241], "DuanWuPanel")
            else
                self:setLabelText("NameLabel", CHS[4010021], "DuanWuPanel")
            end


            if string.match(task.task_prompt, "TIME_LEFT") then
                local leftTime = math.max(0, task.task_end_time - gf:getServerTime())
                local leftTimeStr = TaskMgr:getLeftTimeWithMinAndSec(leftTime)
                local str = string.gsub(task.task_prompt, "TIME_LEFT", leftTimeStr)
                self:setColorText(str, "CurrentPanel", "DuanWuPanel", nil, 20, COLOR3.WHITE, 19, true)

                local panel = self:getControl("DuanWuPanel")
                panel:stopAllActions()
                if leftTime <= 0 then

                else
                    performWithDelay(panel, function ()
                        self:refreshFubenPanel()
                    end, 0.5)
                end
            else
                local desc = task.task_prompt
         --       self:setLabelText("NameLabel", task.task_type, "DuanWuPanel")
                self:setColorText(desc, "CurrentPanel", "DuanWuPanel", nil, 20, COLOR3.WHITE, 19, true)
            end

            local panel = self:getControl("DuanWuPanel")
            self:getControl("CurrentPanel", nil, panel):requestDoLayout()
            self:getControl("CurrentPanel", nil, panel):getParent():requestDoLayout()
            panel:requestDoLayout()
        end

        return
    end

    -- 万妖窟
    if MapMgr:isInWyk() then
        self:setCtrlVisible("WanYaoPanel", true)

        local panel = self:getControl("ChallengePanel2", nil, "WanYaoPanel")
        local function checkActivityStart()
            local timeInfo = TaskMgr:getWykInfo()
            local nowTime = gf:getServerTime()
            local isActivityStart = false
            if timeInfo and timeInfo.start_time and timeInfo.end_time then
                if nowTime >= timeInfo.start_time and nowTime <= timeInfo.end_time then
                    return true
                end
            end
        end

        local function modifyButtonPos()
            local cp1 = self:getControl("ChallengePanel1", Const.UIPanel, "WanYaoPanel")
            local cp2 = self:getControl("ChallengePanel2", Const.UIPanel, "WanYaoPanel")
            local buttonPanel = self:getControl("SoaringPanel", Const.UIPanel, "WanYaoPanel")
            if cp1 and cp1:isVisible() then
                local x, y = cp1:getPosition()
                local size = buttonPanel:getContentSize()
                buttonPanel:setPosition(cc.p(x, y - size.height - 2))
            else
                local x, y = cp2:getPosition()
                local size = buttonPanel:getContentSize()
                buttonPanel:setPosition(cc.p(x, y - size.height - 2))
            end
        end

        local function showInfo(desc)
            self:setCtrlVisible("ChallengePanel1", false, "WanYaoPanel")
            self:setCtrlVisible("ChallengePanel2", true, "WanYaoPanel")
            self:setCtrlVisible("CurrentPanel", true, self:getControl("ChallengePanel2", nil, "WanYaoPanel"))
            self:setCtrlVisible("ContentPanel", false, self:getControl("ChallengePanel2", nil, "WanYaoPanel"))

            local infoPanel =  self:getControl("CurrentPanel", nil, self:getControl("ChallengePanel2", nil, "WanYaoPanel"))
            infoPanel:setTouchEnabled(false)
            infoPanel:removeAllChildren()
            self.wanyaoTip = nil

            local infoSize = infoPanel:getContentSize()
            self.wanyaoTip = CGAColorTextList:create()

            local tip = self.wanyaoTip
            tip:setFontSize(FONT_HEIGHT)
            tip:setString(desc)
            tip:setContentSize(infoSize.width, 0)
            tip:updateNow()

            local textW, textH = tip:getRealSize()
            tip:setPosition(0, (infoSize.height - textH) * 0.5)
            local colorLayer = tolua.cast(tip, "cc.LayerColor")
            colorLayer:setAnchorPoint(0, 0)
            infoPanel:addChild(colorLayer)
        end

        local function showPanel()
            -- 【周活动】勇闯万妖窟
            local dugeonTaskName = ActivityMgr:getActivityByName(CHS[2100059]).dugeonTaskName
            self:setLabelText("NameLabel", dugeonTaskName, "WanYaoPanel")
            local isActivityStart = checkActivityStart()
            if isActivityStart then
                -- 活动已经开始
                local wykInfo = TaskMgr:getWykInfo()
                if wykInfo.layer == 5 then
                    showInfo(CHS[2100044])
                elseif 0 == wykInfo.is_finish then
                    self:setCtrlVisible("ChallengePanel1", true, "WanYaoPanel")
                    self:setCtrlVisible("ChallengePanel2", false, "WanYaoPanel")
                    local infoPanel = self:getControl("ContentPanel", Const.UIPanel, self:getControl("ChallengePanel1", nil, "WanYaoPanel"))
                    self:setLabelText("Label2", string.format(CHS[2100045], wykInfo.xiaoy_count, wykInfo.xiaoy_need), infoPanel)
                    self:setLabelText("Label3", string.format(CHS[2100046], wykInfo.toum_count, wykInfo.toum_need), infoPanel)
                    self:setLabelText("Label4", string.format(CHS[2100047], wykInfo.shouw_count, wykInfo.shouw_need), infoPanel)

                    self.wanyaoTip = nil
                else
                    showInfo(string.format(CHS[2100048], wykInfo.layer))
                end
            else
                -- 活动还未开始
                self:setCtrlVisible("ChallengePanel1", false, "WanYaoPanel")
                self:setCtrlVisible("ChallengePanel2", true, "WanYaoPanel")
                self:setCtrlVisible("CurrentPanel", false, self:getControl("ChallengePanel2", nil, "WanYaoPanel"))
                self:setCtrlVisible("ContentPanel", true, self:getControl("ChallengePanel2", nil, "WanYaoPanel"))

                local timeInfo = TaskMgr:getWykInfo()
                if timeInfo and timeInfo.start_time then
                    -- 现在离活动正式开始还有多长时间
                    local nowTime = gf:getServerTime()
                    local startTime = timeInfo.start_time
                    local leftMin = math.ceil((startTime - nowTime) / 60)
                    self:setLabelText("Label1", string.format(CHS[2100050], leftMin), self:getControl("ChallengePanel2", Const.UIPanel, "WanYaoPanel"))
                end
            end

            modifyButtonPos()
        end

        panel:stopAllActions()
        if checkActivityStart() then
            showPanel()
        else
            schedule(panel, function()
                showPanel()
            end, 1)
        end

        return
    end

    if MapMgr:isInYzrq() then
        -- 【周活动】异族入侵
        local dugeonTaskName = ActivityMgr:getActivityByName(CHS[2200027]).dugeonTaskName
        self:setLabelText("NameLabel", dugeonTaskName, "InvadePanel")
        self:setCtrlVisible("InvadePanel", true)

        self:setCtrlVisible("WaitingPanel", false, "InvadePanel")
        self:setCtrlVisible("Label", false, "InvadePanel")
        self:setCtrlVisible("InfoLabel", false, "InvadePanel")
        self:setCtrlVisible("CurrentPanel", false, "InvadePanel")

        local changePanel = self:getControl("ChallengePanel", nil, "InvadePanel")
        changePanel:setAnchorPoint(0.5, 0.5)
        changePanel:stopAllActions()

        local function func(showName, desc)
            -- 任务信息
            local infoPanel =  self:getControl("CurrentPanel", nil, "InvadePanel")
            infoPanel:removeAllChildren()
            self.fubenTip = nil

            local infoSize = infoPanel:getContentSize()
            self.fubenTip = CGAColorTextList:create()

            local tip = self.fubenTip
            tip:setFontSize(FONT_HEIGHT)
            tip:setString(desc)
            tip:setContentSize(infoSize.width, 0)
            tip:updateNow()

            local textW, textH = tip:getRealSize()
            tip:setPosition(0, (infoSize.height - textH) * 0.5)
            local colorLayer = tolua.cast(tip, "cc.LayerColor")
            colorLayer:setAnchorPoint(0, 0)
            infoPanel:addChild(colorLayer)
            infoPanel:setEnabled(false)
        end

        -- 由任务状态驱动界面更新的副本
        local task = TaskMgr:getFuBenTaskData()
        if task then
            local showName = task.show_name
            local desc = task.task_prompt
            func(showName, desc)
            self:setCtrlVisible("InfoLabel", true, "InvadePanel")
            self:setCtrlVisible("CurrentPanel", true, "InvadePanel")
            self:setCtrlVisible("SneakPanel_0", true, "InvadePanel")
            local soaringPanel = self:getControl("SoaringPanel", nil, "InvadePanel")
            if soaringPanel then
                local layoutP = soaringPanel:getLayoutParameter()
                local margin = layoutP:getMargin()
                margin.top = 0
                layoutP:setMargin(margin)
                soaringPanel:getParent():requestDoLayout()
            end
            local sneakPanel = self:getControl("SneakPanel_0", nil, "InvadePanel")
            self:setCtrlVisible("SneakPanel", YiShiMgr:getPlayerStatus() == 1, sneakPanel)
            self:setCtrlVisible("AttackPanel", YiShiMgr:getPlayerStatus() == 0, sneakPanel)
        else
            self:setCtrlVisible("WaitingPanel", true, "InvadePanel")
            self:setCtrlVisible("SneakPanel_0", false, "InvadePanel")

            -- 调整位置
            local sneakPanel = self:getControl("SneakPanel_0", nil, "InvadePanel")
            local soaringPanel = self:getControl("SoaringPanel", nil, "InvadePanel")
            if sneakPanel and soaringPanel then
                local layoutP = soaringPanel:getLayoutParameter()
                local margin = layoutP:getMargin()
                margin.top = -sneakPanel:getContentSize().height
                layoutP:setMargin(margin)
                soaringPanel:getParent():requestDoLayout()
            end

            local waitPanel = self:getControl("WaitingPanel", nil, "InvadePanel")
            self:setLabelText("Label1", CHS[7003031], waitPanel)
            schedule(changePanel, function()
                local timeInfo = TaskMgr:getYzrqTimeInfo()
                if timeInfo then
                    -- 现在离活动开始还有多长时间
                    local nowTime = gf:getServerTime()
                    local startTime = timeInfo.startTime
                    local leftMin = math.ceil((startTime - nowTime) / 60)
                    self:setLabelText("Label2", string.format(CHS[7003030], leftMin), waitPanel)
                end
            end, 1)
        end
        return
    end

    -- 依附于DugeonPanel的任务面板显示
    local changePanel = self:getControl("ChallengePanel", nil, "DugeonPanel")
    changePanel:setAnchorPoint(0.5, 0.5)
    changePanel:stopAllActions()

    local function func(showName, desc)
        if showName == CHS[3001743] or showName == CHS[3001747]
            or showName == CHS[3001750] or showName == CHS[4100554] then
            -- 策划要求黑风洞，兰若寺，烈火涧，飘渺仙府副本，前增加显示"副本-"
            showName = string.format(CHS[7150063], showName)
        elseif showName == CHS[2200036] then
            -- 百兽之王在副本中任务名称使用配置中的名称
            showName = ActivityMgr:getActivityByName(CHS[7002122]).dugeonTaskName
        end

        self:setLabelText("NameLabel", showName, "DugeonPanel")

        -- 任务信息
        local infoPanel =  self:getControl("CurrentPanel", nil, "DugeonPanel")
        infoPanel:removeAllChildren()
        self.fubenTip = nil

        local infoSize = infoPanel:getContentSize()
        self.fubenTip = CGAColorTextList:create()

        local tip = self.fubenTip
        tip:setFontSize(FONT_HEIGHT)
        tip:setString(desc)
        tip:setContentSize(infoSize.width, 0)
        tip:updateNow()

        local textW, textH = tip:getRealSize()
        tip:setPosition(0, (infoSize.height - textH) * 0.5)
        local colorLayer = tolua.cast(tip, "cc.LayerColor")
        colorLayer:setAnchorPoint(0, 0)
        infoPanel:addChild(colorLayer)
        infoPanel:setEnabled(false)
    end

    -- 重置控件的显示/隐藏状态（之后的逻辑处理“依附于DugeonPanel的面板显示”）
    self:setCtrlVisible("MijingPanel", false)
    self:setCtrlVisible("OreWarsPanel", false)
    self:setCtrlVisible("WanYaoPanel", false)
    self:setCtrlVisible("DugeonPanel", true)
    self:setCtrlVisible("InvadePanel", false)
    self:setCtrlVisible("ZongXianPanel", false)
    self:setCtrlVisible("WaitingPanel", false, "DugeonPanel")
    self:setCtrlVisible("Label", false, "DugeonPanel")
    self:setCtrlVisible("InfoLabel", false, "DugeonPanel")
    self:setCtrlVisible("CurrentPanel", false, "DugeonPanel")

    -- 不由任务状态去驱动界面更新的副本（目前处理化妆舞会/须弥秘境相关）
    if MapMgr:isInMasquerade() then
        local panel = self:getControl("ChallengePanel", nil, "DugeonPanel")
        local timeInfo = TaskMgr:getMasqueradeTimeInfo()
        local nowTime = gf:getServerTime()
        local isActivityStart = false
        if timeInfo and timeInfo.startTime and timeInfo.endTime
              and nowTime >= timeInfo.startTime and nowTime <= timeInfo.endTime then
            isActivityStart = true
        end

        if isActivityStart then
            -- 活动已经开始
            func(CHS[7002106], CHS[7002115])
            self:setCtrlVisible("CurrentPanel", true, "DugeonPanel")
            self:setCtrlVisible("WaitingPanel", false, "DugeonPanel")
        else
            -- 活动尚未开始
            self:setCtrlVisible("WaitingPanel", true, "DugeonPanel")
            self:setLabelText("NameLabel", CHS[7002106], "DugeonPanel")
            self:setLabelText("Label1", CHS[7003032], "WaitingPanel")
            if timeInfo and timeInfo.startTime then
                -- 现在离活动正式开始还有多长时间
                local nowTime = gf:getServerTime()
                local startTime = timeInfo.startTime
                local leftMin = math.ceil((startTime - nowTime) / 60)
                self:setLabelText("Label2", string.format(CHS[7003030], leftMin), "WaitingPanel")
            end
        end

        schedule(panel, function()
            local timeInfo = TaskMgr:getMasqueradeTimeInfo()
            local nowTime = gf:getServerTime()
            local isActivityStart = false
            if timeInfo and timeInfo.startTime and timeInfo.endTime then
                if nowTime >= timeInfo.startTime and nowTime <= timeInfo.endTime then
                    isActivityStart = true
                end
            end

            if isActivityStart then
                -- 活动已经开始
                if self.fubenTip then
                    -- schedule中创建CGAColorTextList会有warning，故需要获取控件去setString()
                    local textW, textH = self.fubenTip:getRealSize()
                    local infoPanel =  self:getControl("CurrentPanel", nil, "DugeonPanel")
                    local infoSize = infoPanel:getContentSize()
                    self.fubenTip:setPosition(0, (infoSize.height - textH) * 0.5)
                    self.fubenTip:setString(CHS[7002115])
                    self.fubenTip:updateNow()
                else
                    func(CHS[7002106], CHS[7002115])
                end

                self:setCtrlVisible("WaitingPanel", false, "DugeonPanel")
                self:setCtrlVisible("CurrentPanel", true, "DugeonPanel")
            else
                -- 活动尚未开始
                self:setCtrlVisible("WaitingPanel", true, "DugeonPanel")
                self:setCtrlVisible("CurrentPanel", false, "DugeonPanel")
                if timeInfo and timeInfo.startTime then
                    -- 现在离活动正式开始还有多长时间
                    local nowTime = gf:getServerTime()
                    local startTime = timeInfo.startTime
                    local leftMin = math.ceil((startTime - nowTime) / 60)
                    self:setLabelText("Label2", string.format(CHS[7003030], leftMin), "WaitingPanel")
                end
            end
        end, 1)
        return
    end

    -- 由任务状态驱动界面更新的副本
    local task = TaskMgr:getFuBenTaskData()
    if task then
        local showName = task.show_name
        local desc = task.task_prompt
        func(showName, desc)
        if task["task_type"] == CHS[5400073] then
            -- 【七夕节】千里相会
            self:setCtrlVisible("InfoLabel", false, "DugeonPanel")
        else
            self:setCtrlVisible("InfoLabel", true, "DugeonPanel")
        end

        self:setCtrlVisible("CurrentPanel", true, "DugeonPanel")
    else
        -- 暂时没有任务的情况

        -- 百兽战场中，尚未开始活动时，给出默认显示界面
        if MapMgr:isInBeastsKing() then
            self:setLabelText("NameLabel", CHS[7002130], "DugeonPanel")
            self:setCtrlVisible("WaitingPanel", true, "DugeonPanel")
            self:setLabelText("Label1", CHS[7003031], "WaitingPanel")
            schedule(changePanel, function()
                local timeInfo = TaskMgr:getBeastsKingTimeInfo()
                if timeInfo then
                    -- 现在离活动开始还有多长时间
                    local nowTime = gf:getServerTime()
                    local startTime = timeInfo.startTime
                    local leftMin = math.ceil((startTime - nowTime) / 60)
                    self:setLabelText("Label2", string.format(CHS[7003030], leftMin), "WaitingPanel")
                end
            end, 1)
                end
        end
end

function MissionDlg:setKuafjjCombatButton(str)
    local combatButton = self:getControl("CombatButton", nil, "KuafjjPanel")
    self:setLabelText("Label_1", str, combatButton)
    self:setLabelText("Label_2", str, combatButton)
end

function MissionDlg:onCombatButton()
    if KuafjjMgr:checkKuafjjIsEnd(true) then
        AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[5410223]))
        return
    end

    local isInKuafjjzc = MapMgr:isInKuafjjzc()
    local combatMode, needNum = KuafjjMgr:getCurCombatMode()
    local num = TeamMgr:getTeamTotalNum()
    if isInKuafjjzc then
        if KuafjjMgr:getCurAutoMatchEnable() then
            -- 取消匹配
            KuafjjMgr:requestAutoMatch(0)
        else
            -- 开始匹配
            KuafjjMgr:requestAutoMatch(1)
        end
    else
        -- 进入战场
        if not (GMMgr:isGM() or KuafjjMgr:isKFJJJournalist()) then
            if not combatMode then
                gf:ShowSmallTips(CHS[5410217])
                return
            end
        end

        if needNum > 1 and num ~= needNum then
            gf:ShowSmallTips(CHS[5400397])
            return
        end

        if num ~= TeamMgr:getTeamNum() then
            gf:ShowSmallTips(CHS[5400398])
            return
        end

        AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[5400392]))
    end
end

function MissionDlg:onNoteButton(sender)
    gf:showTipInfo(CHS[5400401], sender)
end

function MissionDlg:onKuafsdRuleButton(sender)
    if MapMgr:isInShiDao() then
        DlgMgr:openDlg("ShiDaoDlg")
    else
    DlgMgr:openDlg("KuaFuShiDaoRuleDlg")
    end
end

function MissionDlg:onLeaveKuafsdButton(sender)
    if MapMgr:isInShiDao() then
        AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[5430025]))
    else
    local str
    if MapMgr:isInKuafsdzc() then
        str = CHS[5400769]
    else
        str = CHS[5400768]
    end

    if ShiDaoMgr:isMonthTaoKFSD() then
        str = string.gsub(str, CHS[5400029], CHS[5400786])
        str = string.gsub(str, CHS[5400038], CHS[5400785])
    end

    AutoWalkMgr:beginAutoWalk(gf:findDest(str))
    end
end

function MissionDlg:MSG_CSC_NOTIFY_COMBAT_MODE(data)
    self:refreshKFJJPanel()
end

function MissionDlg:MSG_CSC_NOTIFY_AUTO_MATCH(data)
    self:refreshKFJJPanel()
end

function MissionDlg:refreshKFJJPanel()
    local isInKuafjjzc = MapMgr:isInKuafjjzc()
    local combatMode, needNum = KuafjjMgr:getCurCombatMode()
    local num = TeamMgr:getTeamNum()
    local matchEnable = KuafjjMgr:getCurAutoMatchEnable()
    num = num == 0 and 1 or num

    if KuafjjMgr:checkKuafjjIsEnd(true) then
        self:setColorText(CHS[5410222], "CurrentNotePanel", "KuafjjPanel", nil, 5, COLOR3.WHITE, 19)
    elseif not combatMode then
        self:setColorText(CHS[5400389], "CurrentNotePanel", "KuafjjPanel", nil, 5, COLOR3.WHITE, 19)
    elseif needNum == num then
        if isInKuafjjzc then
            if matchEnable then
                self:setColorText(CHS[5410221], "CurrentNotePanel", "KuafjjPanel", nil, 5, COLOR3.WHITE, 19)
            else
            self:setColorText(CHS[5400394], "CurrentNotePanel", "KuafjjPanel", nil, 5, COLOR3.WHITE, 19)
            end
        else
            self:setColorText(CHS[5400390], "CurrentNotePanel", "KuafjjPanel", nil, 5, COLOR3.WHITE, 19)
        end
    else
        self:setColorText(string.format(CHS[5400348], num, needNum), "CurrentNotePanel", "KuafjjPanel", nil, 5, COLOR3.WHITE, 19)
    end

    if isInKuafjjzc then
        if matchEnable then
            self:setKuafjjCombatButton(CHS[5400395])
	    else
            self:setKuafjjCombatButton(CHS[5400349])
	    end
    elseif KuafjjMgr:checkKuafjjIsEnd(true) then
        self:setKuafjjCombatButton(CHS[5410218])
	else
	    self:setKuafjjCombatButton(CHS[5400360])
	end
end

function MissionDlg:refreshKFSDPanel()
    local panel = self:getControl("KuafsdPanel")
    panel:stopAllActions()

    if ShiDaoMgr:isMonthTaoKFSD() then
        self:setLabelText("NameLabel", CHS[5400788], panel)
    else
        self:setLabelText("NameLabel", CHS[4100452], panel)
    end

    local function func()
        local info = ShiDaoMgr:getKuafsdInfo()
        local curTime = gf:getServerTime()
        local str

        if GMMgr:isGM() or ShiDaoMgr:isKFSDJournalist() then
            str = CHS[5400767]
        elseif not info.start_time or (info.is_running == 0 and curTime < info.start_time + 10) then
            str = CHS[5400763]
        elseif info.is_running == 1 and curTime < info.end_time then
            if MapMgr:isInKuafsdzc() then
                str = CHS[5400764]
            else
                if ShiDaoMgr:isMonthTaoKFSD() then
                    if info.oust_time == 0 then
                        -- 数据还未刷新
                        str = string.format(CHS[5400770], 5)
                    else
                        str = string.format(CHS[5400770], math.max(1, math.min(5, math.ceil((info.oust_time - curTime) / 60))))
                    end
                else
                    str = CHS[5400765]
                end
            end
        else
            str = CHS[5400766]
        end

        self:setColorText(str, "LabelPanel", "KuafsdPanel", nil, 5, COLOR3.WHITE, 19)

        self:getControl("ContentPanel", nil, panel):requestDoLayout()
    end

    func()

    schedule(panel, func, 3)
end

function MissionDlg:updateQingChengLunDaoInfo()
    if TaskMgr:isQCLDJournalist() then
        self:setColorText(CHS[7150141], "LabelPanel", "QingChengLunDaoPanel", nil, 5, COLOR3.WHITE, 19)
    else
        self:setColorText(CHS[7150138], "LabelPanel", "QingChengLunDaoPanel", nil, 5, COLOR3.WHITE, 19)
    end
end

function MissionDlg:refreshSDDHPanel()
    local panel = self:getControl("KuafsdPanel")
    panel:stopAllActions()

    if ShiDaoMgr:isMonthTaoShiDao() then
        self:setLabelText("NameLabel", CHS[5450336], panel)
    else
        self:setLabelText("NameLabel", CHS[5450332], panel)
    end

    local info = ShiDaoMgr:getShiDaoTaskInfo() or {}
    local str
    if GMMgr:isGM() or ShiDaoMgr:isSDJournalist() then
        str = CHS[5430026]
    elseif info.stageId == 0 then -- 准备阶段
        str = CHS[5430022]
    elseif info.stageId == 1 then -- 挑战元魔
        str = CHS[5430023]
    elseif info.stageId == 2 then -- 巅峰对决
        str = CHS[5430024]
    end

    self:setColorText(str, "LabelPanel", "KuafsdPanel", nil, 5, COLOR3.WHITE, 19)

    self:getControl("ContentPanel", nil, panel):requestDoLayout()
end


-- 获取通天塔类型  修炼，突破、挑战
function MissionDlg:getTowerType(data)
    if data.curLayer < data.breakLayer then
        return CHS[3003134]
    elseif data.curLayer == data.breakLayer then
        if data.curType == 2 then
            return CHS[3003135]
        else
            return CHS[3003134]
        end
    else
        return CHS[3003135]
    end
end

-- 设置通天塔塔顶相关信息
function MissionDlg:setTTTTDInfo(data)

    local panel = self:getControl("TargetPanel")
    for i = 1, 5 do
        local name = ""
        if data[i] then
            name = data[i].name
        end
        self:setLabelText("NameLabel_" .. i, name, panel)
    end

    self:setCtrlVisible("InfoLabel", false, panel)
    self:setCtrlVisible("InfoLabel_0", false, panel)
    if data.xingJunCount == 1 and data[1].name == CHS[3000987] then
        panel:setContentSize(panel:getContentSize().width, 117)
        self:setCtrlVisible("InfoLabel_0", true, panel)
    else
        panel:setContentSize(panel:getContentSize().width, 227)
        self:setCtrlVisible("InfoLabel", true, panel)
    end

    self:setLabelText("InfoLabel", string.format(CHS[4101284], data.leftTime), panel) -- "点击前往（剩余%d次）
    self:setLabelText("InfoLabel_0", string.format(CHS[4101284], data.leftTime), panel)
    panel:getParent():requestDoLayout()
end

-- 是否在神秘房间
function MissionDlg:isInMMFJ()
    return MapMgr:isInMapByName(CHS[4010293])   -- 神秘房间
end


-- 通天塔显示类型
function MissionDlg:displayTongtianta(data)
    local towerPanel = self:getControl("LevelInfoPanel")


    if self:isInMMFJ() then
        self:setLabelText("BreachLevelLabel", CHS[4010293], towerPanel)

        if data.hasNotCompletedSmfj == 1 then
            self:setLabelText("CurrentLabel", CHS[4010294], towerPanel)
        else
            self:setLabelText("CurrentLabel", CHS[4101287], towerPanel)
        end
    else
        -- 类型and层数
        local towerType = self:getTowerType(data)
        local towerLevelStr = towerType .. " " .. data.curLayer .. "/" .. data.breakLayer
        self:setLabelText("BreachLevelLabel", towerLevelStr, towerPanel)

        -- 挑战XXX
        self:setLabelText("CurrentLabel", CHS[3003136] .. data.npc, towerPanel)
    end

    -- 按钮
    if data.curType == 1 then
        -- 开始挑战
        self:setCtrlVisible("ChallengeButton", true)
        self:setCtrlVisible("ReChallengeButton", false)
        self:setCtrlVisible("NextLevelButton", false)

    elseif data.curType == 3 then
        -- 继续挑战
        self:setCtrlVisible("ChallengeButton", false)
        self:setCtrlVisible("ReChallengeButton", true)
        self:setCtrlVisible("NextLevelButton", false)

        -- 剩余挑战次数
        self:setLabelText("CurrentLabel", string.format(CHS[3003137], data.npc, data.challengeCount), towerPanel)
    else
        -- 挑战下层
        self:setCtrlVisible("ChallengeButton", false)
        self:setCtrlVisible("ReChallengeButton", false)
        self:setCtrlVisible("NextLevelButton", true)

        -- 挑战XXX
        self:setLabelText("CurrentLabel", CHS[3003138], towerPanel)
    end

    -- 奖励类型
    if data.bonusType == "exp" then
        self:setLabelText("NameLabel", CHS[4300081], towerPanel)
    elseif data.bonusType == "tao" then
        self:setLabelText("NameLabel", CHS[4300082], towerPanel)
    end

    towerPanel:requestDoLayout()
end

function MissionDlg:initPartyWarViewControl()
    -- 绑定监听更新数据
    self:bindListener("ActiveCompareProgressBar", self.onRequestUpdateData)    -- 进度条
    self:bindListener("FightImage", self.onRequestUpdateData)    -- 中间图标
    self:bindListener("PartyWarButton", self.onPartyWarButton)
end

function MissionDlg:onPartyWarButton(sender, eventType)
    self:displayType(displayPartyWar)
end

-- 设置帮战中玩家
function MissionDlg:pushWarPlayer(data)

    -- 如果是本帮成员，不显示
    if data.count == 0 then return end
    local warPanel = self:getControl("NewPartyWarPanel")
    local list = self:getControl("TeamListView", nil, warPanel)

    -- 检测该项是否已经加入
    local function checkIsAdd(name)
        local items = list:getItems()
        for _, panel in pairs(items) do
            if name == panel:getName() then
                return true
            end
        end

        return false
    end

    for i = 1, data.count do

        local isAdd = false
        if DistMgr:isInKFZC2019Server() then
            if Me:queryBasic("title") ~= string.match( data[i].name, "(.+)-" ) then
                isAdd = true
            end
        else
            isAdd = data[i]["party/name"] ~= Me:queryBasic("party/name") and not checkIsAdd(data[i].name)
        end

        if isAdd then

            -- 显示非本帮成员
            local panel = self.warSingleMemberPanel:clone()
            self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data[i].level, false, LOCATE_POSITION.LEFT_TOP, 19, panel)
            self:setImage("ShapeImage", ResMgr:getSmallPortrait(data[i].org_icon), panel)
            self:setItemImageSize("ShapeImage", panel)

            panel:setName(data[i].name)

            if data.ask_type == Const.AROUND_TEAM_REAL_MEMBERS or data.ask_type == Const.PWAR_AROUND_TEAM or data.ask_type == Const.KFZC2019_AROUND_TEAM then
                -- 如果是队长 CHS[3003293]
                self:setLabelText("NameLabel_1", CHS[3003293], panel)
                self:setCtrlVisible("TeamImage", true, panel)
                self:setLabelText("NameLabel_2", gf:getRealName(data[i].name), panel)
            else
                -- 单人
                self:setCtrlVisible("TeamImage", false, panel)
                self:setLabelText("NameLabel_1", CHS[3003139], panel)
                self:setLabelText("NameLabel_2", gf:getRealName(data[i].name), panel)
            end

            for j = 1,5 do
                self:setCtrlVisible("Image_" .. j, j <= data[i].teamMembersCount, panel)
            end

            -- 暂离玩家为teamMembersCount == 0
            self:setCtrlVisible("Image_" .. 1, true, panel)

            -- 监听点击事件
            self:bindTouchEndEventListener(panel, function ()
                self.warSingleEff:removeFromParent()
                panel:addChild(self.warSingleEff)

                if Me:isNearByGid(data[i].gid) then
                    local dlg = DlgMgr:openDlg("PartyWarEnemyMenuDlg")
                    dlg:queryTeam(data[i].gid)
                else
                    gf:ShowSmallTips(CHS[3003140])
                    self:updatePartyWarInfo()
                end
            end)

            list:pushBackCustomItem(panel)
        end
    end
end

-- 设置数据  isNoLimit可能是sender，可能是刷新限制标记
function MissionDlg:updatePartyWarInfo(isNoLimit)
    if isNoLimit ~= true and not self:isOutLimitTime("lastTime",  3 * 1000) then
        gf:ShowSmallTips(CHS[3003200])
        return
    end

    self:setLastOperTime("lastTime", gfGetTickCount())
    local warPanel = self:getControl("NewPartyWarPanel")

    local list = self:getControl("TeamListView", nil, warPanel)
    list:removeAllItems()

    if DistMgr:isInKFZC2019Server() then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_QUERY_TEAM_INFO, Const.KFZC2019_AROUND_TEAM)
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_QUERY_TEAM_INFO, Const.KFZC2019_AROUND_PLAYER)
    else
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_QUERY_TEAM_INFO, Const.PWAR_AROUND_TEAM)
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_QUERY_TEAM_INFO, Const.PWAR_AROUND_PLAYER)
    end

    -- 请求周边玩家，队长

end

-- 获取更新数据
function MissionDlg:onRequestUpdateData(sender, eventType)
    PartyWarMgr:requesetPartyWarActiveInfo()
end

-- 帮派攻城战
function MissionDlg:onCityWarButton(sender, eventType)
    self:displayType(displayCityWar)
end

-- 打开组队界面
function MissionDlg:onEmptyPanel(sender, eventType)
    DlgMgr:openDlg("TeamDlg")
end

function MissionDlg:onTaskEmptyPanel(sender, eventType)
    DlgMgr:openDlg("TaskDlg")
end

-- 设置帮派攻城战数据
function MissionDlg:updateCityWarInfo(data)
    if 1 == data.stage then
        self:setCtrlVisible("CityWarStagePanel_1", true)
        self:setCtrlVisible("CityWarStagePanel_2", false)
        self:setLabelText("StaminaValueLabel_1", string.format(CHS[3003141], data.cw_action_point))
        self:setProgressBar("MonsterLifeProgressBar_1", data.npc1_life, data.npc1_max_life)
        self:setProgressBar("MonsterLifeProgressBar_2", data.npc2_life, data.npc2_max_life)
        self:setProgressBar("BangpzjtLifeProgressBar", data.npc3_life, data.npc3_max_life)
    elseif 2 == data.stage then
        self:setCtrlVisible("CityWarStagePanel_1", false)
        self:setCtrlVisible("CityWarStagePanel_2", true)
        self:setLabelText("StaminaValueLabel_2", string.format(CHS[3003141], data.cw_action_point))
        self:setProgressBar("BangpzgLifeProgressBar", data.npc1_life, data.npc1_max_life)
    end
end


function MissionDlg:MSG_TONGTIANTADING_XINGJUN_LIST(data)
    -- 通天塔模式
    self:setCtrlVisible("MissionButton", false)
    self:setCtrlVisible("TongtiantaButton", true)
    self.info = data
    self:displayType(displayTTTTD)

    self:setTTTTDInfo(data)

    Me.lastPaths = nil
end


function MissionDlg:MSG_TONGTIANTA_INFO(data)
    -- 通天塔模式
    self:setCtrlVisible("MissionButton", false)
    self:setCtrlVisible("TongtiantaButton", true)
    self.info = data
    self:displayType(displayTongtianta)
    self:displayTongtianta(data)

    Me.lastPaths = nil
end

-- 打开帮战界面
function MissionDlg:MSG_PARTY_WAR_SCORE(data)
    self:updatePartyWarInfo(true)
    -- 模拟点击任务
    self.curDisplayType = -1
    self:setCheck("MissionCheckBox", true)
    self:setCheck("TeamCheckBox", false)
    self:onShowDialogButton()
    self:onMissionButton()
end

-- 打开帮派攻城界面
function MissionDlg:MSG_CITY_WAR_SCORE(data)
    self:setCtrlVisible("PartyWarButton", false)
    self:setCtrlVisible("MissionButton", false)
    self:setCtrlVisible("TongtiantaButton", false)
    self:setCtrlVisible("CityWarButton", true)

    self:updateCityWarInfo(data)
    self:displayType(displayCityWar)
end

function MissionDlg:MSG_MATCH_TEAM_STATE(data)
    self:updateTeamInfo()
end

-- 新手指引点击第一个任务
function MissionDlg:getSelectItemBox(param)
    if param == "firstTask" and self.rect then
        local ctrl = self:getControl("MissionListView", Const.UIListView)
        local item = ctrl:getItem(0)
        local rect = self:getBoundingBoxInWorldSpace(item)
        return rect
    end
end

function MissionDlg:youMustGiveMeOneNotify(param)
    if param == "firstTask" then
        -- 延迟一点通知指引管理器
        performWithDelay(self.root, function()
            if GuideMgr:isRunning() then
                GuideMgr:youCanDoIt(self.name, "firstTask")
            end
        end, 0.5)
    end
end

function MissionDlg:MSG_TONGTIANTA_JUMP(data)
    local function accept()
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_TTT_JUMP_ASSURE, data.costType)
    end

    local function cancel()
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_TTT_JUMP_CANCEL, data.costType)
    end

    local cashStr = gf:getMoneyDesc(data.costCount)
    local contentStr = string.format(CHS[3003142], cashStr, self.info.curLayer + data.jumpCount)
    if data.costType == 1 then
        cashStr = gf:getMoneyDesc(data.costCount, true)
        contentStr = string.format(CHS[3003143], cashStr, self.info.curLayer + data.jumpCount)
    end

    gf:confirm(contentStr, accept, cancel, nil, 30, NOTIFY.NOTIFY_TTT_JUMP_CANCEL)
end

function MissionDlg:MSG_TONGTIANTA_JUMP_CANCEL(data)
    local dlg = DlgMgr.dlgs["ConfirmDlg"]
    if not dlg then return end
    if dlg.root:getTag() == NOTIFY.NOTIFY_TTT_JUMP_CANCEL then
        DlgMgr:closeDlg("ConfirmDlg")
    end
end

function MissionDlg:MSG_TONGTIANTA_BONUS_DLG(data)
    local dlg = DlgMgr:openDlg("GetRewardDlg")
    dlg:switchFightBtnStatues(data.dlgType)
    dlg:setBonus(data)
end

function MissionDlg:MSG_OPEN_FEISHENG_DLG(data)
    local dlg = DlgMgr:openDlg("TongtiantaFlyDlg")
    dlg:setData(self.info)
end

function MissionDlg:onLeaveBaxianButton()
    -- 清除自动寻路等标志信息
    AutoWalkMgr:stopAutoWalk()

    -- 点击地图时必须移除焦点人物的光效
    if Me.selectTarget then
        Me.selectTarget:removeFocusMagic()
    end

    gf:confirm(CHS[4300142], function ()
        gf:CmdToServer("CMD_LEAVE_BAXIAN")
    end)
end

function MissionDlg:onLeaveFubenButton()
    -- 清除自动寻路等标志信息
    AutoWalkMgr:stopAutoWalk()

    -- 点击地图时必须移除焦点人物的光效
    if Me.selectTarget then
        Me.selectTarget:removeFocusMagic()
    end

    local hasMemberNotLeaveTmp = false
    local members = TeamMgr.members_ex
    for k, v in ipairs(members) do
        if v.team_status ~= 2 then
            hasMemberNotLeaveTmp = true
            break
        end
    end

    if MapMgr:isInMasquerade() then
        -- 化妆舞会特殊处理
            gf:CmdToServer("CMD_LEAVE_HZWH")
        return
    elseif MapMgr:isInBeastsKing() then
        -- 百兽之王特殊处理
        gf:CmdToServer("CMD_LEAVE_BAISZW")
        return
    elseif MapMgr:isInMiJing() then
        local mijingInfo = TaskMgr:getMiJingInfo()
        if not mijingInfo then
            return
        end

        gf:CmdToServer("CMD_LEAVE_ROOM", {type = mijingInfo.alias, extra = ""})
        return
    elseif MapMgr:isInOreWars() then
        gf:CmdToServer("CMD_LEAVE_KSDZ")
        return
    elseif MapMgr:isInWyk() then
        local wykInfo = TaskMgr:getWykInfo()
        if not wykInfo then return end
        gf:CmdToServer("CMD_LEAVE_ROOM", {type = wykInfo.act_alias, extra = ""})
        return
    elseif MapMgr:isInYzrq() then
        gf:confirm(string.format(CHS[2000243], MapMgr:getCurrentMapName()), function()
            gf:CmdToServer("CMD_YISHI_LEAVE_ROOM")
        end)
        return
    elseif MapMgr:isInZongXianLou() then
        -- 粽仙楼
        gf:CmdToServer("CMD_LEAVE_ROOM", {type = "duanwu_day_2017", extra = ""})
        return
    elseif MapMgr:isInZhongXian() then
        gf:confirm(CHS[2000347], function()
            gf:CmdToServer("CMD_LEAVE_ROOM", {type = "teacher_day_2017", extra = ""})
        end)
        return
    elseif MapMgr:isInXueJingShengdi() then
        -- 【圣诞】巧收雪精
        gf:confirm(CHS[5450062], function ()
            gf:CmdToServer("CMD_LEAVE_ROOM", {type = "christmas_2018_qsxj", extra = ""})
        end)
        return
    elseif MapMgr:isInShanZei() then
        gf:confirm(string.format(CHS[7190150], MapMgr:getCurrentMapName()), function ()
            if TaskMgr:getTaskByName(CHS[7190231]) then
                -- 【探案】人口失踪
                gf:CmdToServer("CMD_LEAVE_ROOM", {type = CHS[7190231], extra = ""})
            else
                -- 【劳动节】锄强扶弱
                gf:CmdToServer("CMD_LEAVE_ROOM", {type = "labor_day_2018", extra = ""})
            end
        end)
        return
    elseif MapMgr:isInMapByName(CHS[4010025]) then
        -- 端午2018
        gf:confirm(string.format(CHS[7190150], MapMgr:getCurrentMapName()), function ()
            gf:CmdToServer("CMD_LEAVE_ROOM", {type = "duanwu_day_2018_zlsj", extra = ""})
        end)
        return
    end

    if TeamMgr:inTeam(Me:getId()) and TeamMgr:getLeaderId() ~= Me:getId() then return gf:ShowSmallTips(CHS[3002659]) end

    if MapMgr:isInWangMuQinGong() then
        -- 【七夕节】千里相会
        local task = TaskMgr:getFuBenTaskData()
        if task then
            gf:confirm(string.format(CHS[5400080], CHS[5400077]), function ()
                gf:CmdToServer("CMD_LEAVE_ROOM", {type = "qixi_day_2017", extra = ""})
            end)
        else
            gf:CmdToServer("CMD_LEAVE_ROOM", {type = "qixi_day_2017", extra = ""})
        end

        return
    elseif MapMgr:isInBaiHuaCongzhong() then
        gf:confirm(string.format(CHS[5450220], CHS[5450190]), function ()
            gf:CmdToServer("CMD_LEAVE_ROOM", {type = "qixi_2018_mbhc"})
        end)
        return
    elseif MapMgr:isInQMJH() then
        gf:confirm(string.format(CHS[5450220] .. CHS[5450347], CHS[5450345]), function ()
            gf:CmdToServer("CMD_LEAVE_ROOM", {type = "fools_2019_qmjh"})
        end)
        return
    elseif MapMgr:isInTanAnJhll() then
        gf:confirm(string.format(CHS[7190150], MapMgr:getCurrentMapName()), function ()
            -- 【探案】江湖绿林
            gf:CmdToServer("CMD_LEAVE_ROOM", {type = CHS[7190256], extra = ""})
        end)
        return
    elseif MapMgr:isInTanAnMxza() then
        gf:confirm(string.format(CHS[7190150], CHS[7190282]), function ()
            -- 【探案】迷仙镇案
            gf:CmdToServer("CMD_LEAVE_ROOM", {type = CHS[7190282], extra = ""})
        end)
        return

    elseif MapMgr:isInMapByName(CHS[4101241]) then

        local task = TaskMgr:getTaskByName(CHS[4101237])
        local tips = CHS[4101260]
        if task.task_extra_para ~= "3" then
            tips = tips .. "\n" .. CHS[4101242]
        end

        gf:confirm(tips, function ()
            -- 【【情人节】采集玫瑰
            gf:CmdToServer("CMD_LEAVE_ROOM", {type = "valentine_2019_cjmg", extra = ""})
        end)
        return
    end

    local task = TaskMgr:getFuBenTaskData()
    if task then
        gf:confirm(string.format(CHS[4300143], task.show_name), function ()
            gf:CmdToServer("CMD_LEAVE_DUNGEON")
        end)
    end
end

function MissionDlg:onBaxianRuleButton()
    local dlg = DlgMgr:openDlg("DugeonRuleDlg")
    dlg:setType("baxian")
end

function MissionDlg:onLeaveQingChengLunDaoButton()
    AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[7150137]))
end

function MissionDlg:onQingChengLunDaoRuleButton()
    if TaskMgr:isQCLDJournalist() then
        gf:ShowSmallTips(CHS[7150141])
    else
        gf:ShowSmallTips(CHS[7150136])
    end
end

-- 探案人口失踪副本与锄强扶弱副本地图相同，所以不走onDugeonRuleButton逻辑
function MissionDlg:onTanAnRkszRuleButton()
    local dlg = DlgMgr:openDlg("DugeonRuleDlg")
    if MapMgr:isInTanAnMxza() then
        -- 【探案】迷仙镇案与 【探案】人口失踪 共用一个Panel
        dlg:setType("TanAnMxza")
    else
        dlg:setType("TanAnRksz")
    end
end

function MissionDlg:onDugeonRuleButton()
    local dlg = DlgMgr:openDlg("DugeonRuleDlg")
    if MapMgr:isInZhiShuJieDugeon() then
        dlg:setType("zhishujiefuben")
    elseif MapMgr:isInMasquerade() then
        dlg:setType("masquerade")
    elseif MapMgr:isInBeastsKing() then
        dlg:setType("beastsking")
    elseif MapMgr:isInMiJing() then
        dlg:setType("mijing")
    elseif MapMgr:isInOreWars() then
        dlg:setType("orewars")
    elseif MapMgr:isInYzrq() then
        dlg:setType("yizuruqin")
    elseif MapMgr:isInWyk() then
        dlg:setType("wyk")
    elseif MapMgr:isInZongXianLou() then
        dlg:setType("zongxian")
    elseif MapMgr:isInWangMuQinGong() then
        -- 【七夕节】千里相会
        dlg:setType("qianlxh")
    elseif MapMgr:isInBaiHuaCongzhong() then
        -- 【七夕】漫步花丛
        dlg:setType("manbuhuacong")
    elseif MapMgr:isInXueJingShengdi() then
        -- 【圣诞】巧收雪精
        dlg:setType("qiaosxj")
    elseif MapMgr:isInZhongXian() then
        dlg:setType("zhongxian")
    elseif MapMgr:isInShanZei() then
        dlg:setType("shanzeiyingwai")
    elseif MapMgr:isInMapByName(CHS[4010025]) then
        dlg:setType("ZongLiao")
    elseif MapMgr:isInTanAnJhll() then
        dlg:setType("TanAnJhll")
    elseif MapMgr:isInMapByName(CHS[4101241]) then
        dlg:setType("valentine_2019_cjmg")
    elseif MapMgr:isInQMJH() then
        dlg:setType("qmjh")
    else
        dlg:setType("fuben")
    end
end

function MissionDlg:onLeaveQMPKButton()
    if MapMgr:isInQMReShen() then
        local dest = CHS[7001025]
        AutoWalkMgr:beginAutoWalk(gf:findDest(dest))
    elseif MapMgr:isInQMLoulan() then
        local dest = CHS[7001026]
        AutoWalkMgr:beginAutoWalk(gf:findDest(dest))
    elseif MapMgr:isInQMSaiChang() then
        local dest = CHS[5000268]
        AutoWalkMgr:beginAutoWalk(gf:findDest(dest))
    elseif MapMgr:isInQMCitySaiChang() then
        local dest = CHS[7120153]
        AutoWalkMgr:beginAutoWalk(gf:findDest(dest))
    elseif MapMgr:isInMRZB() then
        if MapMgr.mapData and MapMgr.mapData.map_id == 38020 then
            local dest = CHS[4101036]
            AutoWalkMgr:beginAutoWalk(gf:findDest(dest))
        elseif MapMgr.mapData and MapMgr.mapData.map_id == 38021 then
            local dest = CHS[4101037]
            AutoWalkMgr:beginAutoWalk(gf:findDest(dest))
        end
    end
end

function MissionDlg:onQMPKRuleButton(sender)
    if self.curDisplayType == displayMRZB then
        if not self.mrzbInfo then return end
        local dlg = DlgMgr:openDlg("MingrzbRuleDlg")
        dlg:showRulePanel(self.mrzbInfo.warClass)
    else
        local dlg = DlgMgr:openDlg("QuanmPKRuleDlg")
        dlg:displayStage()
    end
end

function MissionDlg:MSG_BAXIAN_LEFT_TIMES(data)
    self:setLabelText("BreachLevelLabel", string.format(CHS[6000477], data.left_time or 1), "EightImmortalsPanel")
end

function MissionDlg:onEnterBackground()
    self.autoChallengeTtd = TaskMgr:getIsAutoChallengeTongtian()
end

function MissionDlg:MSG_GENERAL_NOTIFY(data)
    local notify = data.notify
    if NOTIFY.NOTIFY_SEND_INIT_DATA_DONE == notify and self.autoChallengeTtd then

        if MapMgr:getCurrentMapName() ~= CHS[3003126] then
            return
        end

        if TaskMgr:isCanChallengeTongtian() then
            -- 此时刷新的数据仍然可以继续自动挑战，则继续
        if Me:isInCombat() then
            TaskMgr:setIsAutoChallengeTongtian(self.autoChallengeTtd)
        else
            self:onAutoChallenge()
        end
        end

        self.autoChallengeTtd = nil
    end
end

function MissionDlg:MSG_ZNQ_2017_XMMJ()
    if MapMgr:isInMiJing() then
        self:refreshFubenPanel()
    end
end

function MissionDlg:MSG_MY_KSDZ_INFO()
    if MapMgr:isInOreWars() then
        self:refreshFubenPanel()
    end
end

function MissionDlg:MSG_YONGCWYK_INFO()
    if MapMgr:isInWyk() then
        self:refreshFubenPanel()
    end
end

function MissionDlg:MSG_ZHONGXIANTA_INFO()
    if MapMgr:isInZhongXian() then
        self:refreshFubenPanel()
    end
end

function MissionDlg:MSG_YISHI_PLAYER_STATUS()
    local sneakPanel = self:getControl("SneakPanel_0", nil, "InvadePanel")
    self:setCtrlVisible("SneakPanel", YiShiMgr:getPlayerStatus() == 1, sneakPanel)
    self:setCtrlVisible("AttackPanel", YiShiMgr:getPlayerStatus() == 0, sneakPanel)
end

function MissionDlg:MSG_NEW_PW_COMBAT_INFO(data)
    if GameMgr:isInPartyWar() then
        if self.curDisplayType == displayPartyWar then
            self:displayType(displayPartyWar)
            self:updatePartyWarInfo(true)
        end
    end
end

function MissionDlg:onUpdate()
    if GameMgr:isInPartyWar() then
        local newData = PartyWarMgr:getNewPartyWarData()
        local securityPanel = self:getControl("NewPartyWar2Panel")

        -- 安全区处理
        if newData and newData.is_security == 1 then
            local waitingPanel = self:getControl("WaitingPanel", nil, securityPanel)
            local porPanel = self:getControl("ProtectPanel", nil, securityPanel)
            local curPanel = self:getControl("CurrentPanel", nil, securityPanel)
            local taskPanel = self:getControl("CCJBPanel", nil, securityPanel)
            local jizhePanel = self:getControl("JizhePanel", nil, securityPanel)
            waitingPanel:setVisible(false)
            porPanel:setVisible(false)
            curPanel:setVisible(false)
            taskPanel:setVisible(false)
            jizhePanel:setVisible(false)
            if gf:getServerTime() < newData.start_time then
                -- 未开始
                waitingPanel:setVisible(true)
                local mi = math.ceil((newData.start_time - gf:getServerTime()) / 60)
                self:setLabelText("Label2", string.format(CHS[4300223], mi), waitingPanel)
            else
                -- 已经开始

                -- 开始后，记者号显示特别
                if Me:getTitle() == CHS[4300269] then
                    jizhePanel:setVisible(true)
                else
                    -- 是否处于保护时间
                    if gf:getServerTime() < newData.rest_time then
                        local se = math.ceil((newData.rest_time - gf:getServerTime()) % 60)
                        self:setLabelText("Label4", string.format(CHS[4000412], se), porPanel)
                        self:setLabelText("Label1", CHS[4000413], porPanel)
                        porPanel:setVisible(true)
                    else
                        local task = TaskMgr:getTaskByName(CHS[4100781])
                        if task then
                            taskPanel:setVisible(true)

                            if task.task_prompt ~= taskPanel.task_prompt then
                                self:setPartyColorText(task.task_prompt, taskPanel)
                                taskPanel.task_prompt = task.task_prompt
                                securityPanel:requestDoLayout()
                            end
                        else
                            curPanel:setVisible(true)
                            self:setCtrlVisible("CurrentLabel", false, curPanel)
                            if not curPanel.task_prompt then
                                self:setPartyColorText(CHS[4100783], curPanel)
                                curPanel.task_prompt = CHS[4100783]         -- "与#P帮战使者|E=出寨杀敌#P对话"
                            end
                        end
                    end
            end
        end
    end
    end
end

function MissionDlg:onCCJBPanel(sender, eventType)

    AutoWalkMgr:beginAutoWalk(gf:findDest(sender.task_prompt))
end

function MissionDlg:setPartyColorText(task_prompt, cell)
    cell:removeAllChildren()
    local content = cell:getContentSize()
    local lableText = CGAColorTextList:create(true)
    lableText:setFontSize(20)
    lableText:setString(task_prompt)
    lableText:setContentSize(content.width, 0)
    lableText:setDefaultColor(COLOR3.WHITE.r, COLOR3.WHITE.g, COLOR3.WHITE.b)
    lableText:updateNow()
    local labelW, labelH = lableText:getRealSize()
    local layerColor = tolua.cast(lableText, "cc.LayerColor")
    cell:addChild(layerColor)
    layerColor:setAnchorPoint(0.5, 0.5)
    layerColor:setPosition(content.width / 2, content.height / 2)
end


function MissionDlg:MSG_CSB_MATCH_TIME_INFO(data)
    self.mrzbInfo = data
 --   self:displayType(displayMRZB)
    self:refreshMRZBPanel(data)
end

-- 全民PK面板
function MissionDlg:refreshMRZBPanel(data)
    if not MapMgr:isInMRZB() then
        return
    end


    local warFlag = string.match(data.round_id, ("kickout_(.+)_"))
    -- round_id 对应 见任务 WDSY-27352
    local warName = ""
    if data.is_yuxuan == 1 then
        warName = CHS[4101038]
    else
        if warFlag == "2" then
            warName = CHS[4101039]
        elseif warFlag == "1" then
            warName = CHS[4101040]
        else
            warName = string.format(CHS[4101041], tonumber(warFlag) * 2)
        end
    end

    -- 当前处于的阶段
    self:setLabelText("NameLabel", warName, "QuanmPKPanel")

    -- 当前提示
    self:setCtrlVisible("LabelPanel", true, "QuanmPKPanel")

    -- 记者和GM特殊处理
    if TaskMgr:isMRZBJournalist() or GMMgr:isGM() or GMMgr:isWarAdmin(CHS[4300465]) then
        self:setColorText(CHS[4101050], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
        DlgMgr:closeDlg("MingrzbInfoDlg") -- 进地图的时候可能没有任务，需要再次关闭
        return
    end


    if data.warClass == MINGREN_ZHENGBA_CLASS.YUXUAN then
        if gf:getServerTime() < data.startTime then
            self:setColorText(CHS[4101035], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
        else
            if data.result == 0 then
                if MapMgr:isInMapByName(CHS[4200505]) then
                    -- 等待比赛结果
                    self:setColorText(CHS[4200504], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
                else
                    -- 等待系统匹配对手
                    self:setColorText(CHS[4101042], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
                end
            elseif data.result == 1 then
                -- 已晋级
                self:setColorText(CHS[4101043], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
            else
                -- 4101044
                self:setColorText(CHS[4101044], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
            end
        end
    else
        -- 名人争霸，决赛，如果结果未出现，都显示
        if data.result == 0 and data.warClass == MINGREN_ZHENGBA_CLASS.JUESAI then
            self:setColorText(CHS[4300365], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
            return
        end


        if gf:getServerTime() < data.startTime then
            self:setColorText(CHS[4101035], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
        else
            if data.result == 0 then
                if MapMgr:isInMapByName(CHS[4200505]) then
                    self:setColorText(CHS[4200504], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
                    return
                end


                if gf:getServerTime() < data.pair_time then
                    local leftTime = math.min(math.ceil((data.pair_time - gf:getServerTime()) / 60), 5)
                    leftTime = math.max(1, leftTime)
                    self:setColorText(string.format(CHS[4101045], leftTime), "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
                    return
                end

                local leftTime = math.min(math.ceil((data.rest_time - gf:getServerTime()) / 60), 5)
                leftTime = math.max(1, leftTime)
                self:setColorText(string.format(CHS[4101045], leftTime), "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
            elseif data.result == 1 then
                if data.warClass == MINGREN_ZHENGBA_CLASS.JUESAI then
                    -- 恭喜获得名人争霸赛总冠军
                    self:setColorText(CHS[4101046], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
                else
                    -- 恭喜你成功晋级
                    self:setColorText(CHS[4101047], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
                end
            else
                -- 很遗憾，你已被淘汰"
                self:setColorText(CHS[4101048], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
            end
        end
    end
end

-- 全民PK面板
function MissionDlg:refreshQMPKPanel()
    if not DistMgr:isInQMPKServer() then
        return
    end

    if MapMgr:getCurrentMapName() == CHS[7120148] then
        -- 城市赛场 直接显示固定内容，与比赛数据无关
        self:setColorText(CHS[7120149], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
        self:setLabelText("NameLabel", CHS[7100286], "QuanmPKPanel")
        return
    end

    local qmpkInfo = QuanminPK2Mgr:getFubenData()
    if not qmpkInfo then return end

    local curTime = gf:getServerTime()

    -- 当前处于的阶段
    local stageStr = QuanminPK2Mgr:getMatchNameBySign(qmpkInfo.status, qmpkInfo.matchId, qmpkInfo.cobId)
    self:setLabelText("NameLabel", stageStr, "QuanmPKPanel")

    if QuanminPKMgr:isQMJournalist() or GMMgr:isGM() or GMMgr:isWarAdmin(CHS[4300464]) then
        -- 记者与GM
        local addStr = ""
        if string.match(qmpkInfo.status, "score") and qmpkInfo.leftCobNum > 0 then
            -- 积分赛 在 大于startTime 小于pairTime或restTime 时，需要追加显示剩余战斗数量
            addStr = string.format(CHS[7150081], qmpkInfo.leftCobNum)
        end

        self:setColorText(CHS[7120130] .. addStr, "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
        return
    end

    -- 如果正在倒计时，先停止倒计时
    local schePanel = self:getControl("ContentPanel", nil, "QuanmPKPanel")
    schePanel:stopAllActions()

    -- 当前提示
    local curMap = MapMgr:getCurrentMapName()
    local timeStr = gf:getServerDate(CHS[7100353], qmpkInfo.startTime)
    self:setCtrlVisible("LabelPanel", true, "QuanmPKPanel")

    -- 战斗轮次
    local suffix = string.format(CHS[7150077], string.len(qmpkInfo.cobFlag) + 1, qmpkInfo.cobNum)

    if string.match(qmpkInfo.status, "score") then -- 积分赛
        suffix = string.format(CHS[7150077], qmpkInfo.scoreMatchRound + 1, qmpkInfo.cobNum)

        if qmpkInfo.isCompetEnd == 1 then
            self:setColorText(CHS[7100334], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
        elseif curTime < qmpkInfo.startTime then
            -- time7之前
            local text = ""
            if curMap == CHS[7100352] then
                -- 在 全民楼兰城 中
                text = string.format(CHS[7100329], timeStr)
            elseif curMap == CHS[7100351] then
                -- 在 全民赛场 中
                text = string.format(CHS[7100330], timeStr)
            end

            self:setColorText(text, "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
        elseif curTime >= qmpkInfo.startTime and curTime < qmpkInfo.pairTime and curMap == CHS[7100351] then
            -- time7之后，time8之前,在 全民赛场 中
            local waitTime = qmpkInfo.pairTime - curTime
            self:setQmpkCountDown(waitTime, CHS[7120151], suffix)
        elseif curTime < qmpkInfo.restTime and curMap == CHS[7100351] then
            -- 战斗休息倒计时 在 全民赛场 中
            local waitTime = qmpkInfo.restTime - curTime
            self:setQmpkCountDown(waitTime, CHS[7120151], suffix)
        elseif curMap == CHS[7100352] then
                -- 战斗未结束，在全民楼兰城中
                self:setColorText(CHS[7100333], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
        elseif qmpkInfo.notInFight == 1 then
            -- 没有进入战斗，只在每次挑选进入战斗时刷新
            local str = string.format(CHS[7120157], qmpkInfo.leftCobNum)
            self:setColorText(str, "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
        elseif curMap == CHS[7100351] then
            -- 战斗未结束，在 全民赛场 中
            self:setColorText(CHS[7120150], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
            end
    elseif string.match(qmpkInfo.status, "kickout") then -- 淘汰赛
        if qmpkInfo.matchFlag == 1 then
            -- 已晋级
            self:setColorText(CHS[7100338], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
        elseif qmpkInfo.matchFlag == 2 then
            -- 已淘汰
            self:setColorText(CHS[7100339], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
        elseif curTime < qmpkInfo.startTime then
            -- time7之前
            local text = ""
            if curMap == CHS[7100352] then
                -- 在 全民楼兰城 中
                text = string.format(CHS[7100329], timeStr)
            elseif curMap == CHS[7100351] then
                -- 在 全民赛场 中
                text = string.format(CHS[7100330], timeStr)
            end

            self:setColorText(text, "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
        elseif curTime >= qmpkInfo.startTime and curMap == CHS[7100352] then
            -- time7之后在全民楼兰城中，且未晋级或淘汰
            self:setColorText(CHS[7120135], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
        elseif curTime >= qmpkInfo.startTime and curTime < qmpkInfo.pairTime and curMap == CHS[7100351] then
            -- time7之后，time8之前 在 全民赛场 中
            local waitTime = qmpkInfo.pairTime - curTime
            self:setQmpkCountDown(waitTime, CHS[7120152], suffix)
        elseif curTime < qmpkInfo.restTime and curMap == CHS[7100351] then
            -- 战斗休息倒计时 在 全民赛场 中
            local waitTime = qmpkInfo.restTime - curTime
            self:setQmpkCountDown(waitTime, CHS[7120152], suffix)
        end
    elseif string.match(qmpkInfo.status, "final") then -- 总决赛
        if qmpkInfo.finalResult == 1 then -- 恭喜获得冠军
            self:setColorText(CHS[7100342], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
        elseif qmpkInfo.finalResult == 2 then -- 恭喜获得亚军
            self:setColorText(CHS[7100343], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
        elseif qmpkInfo.finalResult == 3 then -- 恭喜获得季军
            self:setColorText(CHS[7100344], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
        elseif qmpkInfo.finalResult == 4 then -- 恭喜获得殿军
            self:setColorText(CHS[7100345], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
        else
            -- 比赛结果还没出来
            if DistMgr:curIsTestDist() then
                -- 测试区组
                if (qmpkInfo.cobId == 3 or qmpkInfo.cobId == 4) and qmpkInfo.otherName == "" then
                    -- 季殿军之战， 冠亚军之战
                    local text = string.format(CHS[7120159], CHS[7100317])
                    if qmpkInfo.cobId == 4 then
                        -- 冠亚军之战
                        text = string.format(CHS[7120159], CHS[7100318])
                    end

                    self:setColorText(text, "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
                elseif curTime < qmpkInfo.startTime then
                    -- time7之前
                    if curMap == CHS[7100352] then
                        -- 在 全民楼兰城 中
                        self:setColorText(string.format(CHS[7100329], timeStr), "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
                    elseif curMap == CHS[7100351] then
                        -- 在 全民赛场 中
                        self:setColorText(string.format(CHS[7100330], timeStr), "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
                    end
                elseif curTime >= qmpkInfo.startTime and curMap == CHS[7100352] then
                    -- time7之后在全民楼兰城
                    self:setColorText(CHS[7120135], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
                elseif qmpkInfo.hasConfirmCob == 1 then
                    -- 存在未确认的比赛
                    self:setColorText(CHS[7150079], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
                elseif curTime >= qmpkInfo.startTime and curTime < qmpkInfo.pairTime then
                    -- time7之后，time8之前
                    local waitTime = qmpkInfo.pairTime - curTime
                    self:setQmpkCountDown(waitTime, CHS[7120152], suffix)
                elseif curTime >= qmpkInfo.pairTime then
                    if curTime < qmpkInfo.restTime then
                    -- 战斗休息倒计时
                    local waitTime = qmpkInfo.restTime - curTime
                        self:setQmpkCountDown(waitTime, CHS[7120152], suffix)
                    else
                        -- 等待工作人员开始战斗
                        self:setColorText(CHS[7150078], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
                end
                end
            else
                -- 公测区组
                if curMap == CHS[7100352] then
                    self:setColorText(CHS[7100340], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
                else
                    self:setColorText(CHS[7100341], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
                end
            end
        end
    else -- 热身赛
        self:setColorText(CHS[7100328], "LabelPanel", "QuanmPKPanel", 0, 0, COLOR3.WHITE, 17, true)
    end
end

-- 全民PK面板倒计时
function MissionDlg:setQmpkCountDown(leftTime, prefixStr, suffixStr)
    if leftTime <= 0 then return end
    local schePanel = self:getControl("ContentPanel", nil, "QuanmPKPanel")
    schePanel:stopAllActions()

    local MAX_COUNT_MINUTE = 5
    local curTime = gf:getServerTime()
    local labelPanel = self:getControl("LabelPanel", nil, "QuanmPKPanel")
    local infoSize = labelPanel:getContentSize()
    labelPanel:removeAllChildren()

    self.qmpkTip = CGAColorTextList:create()
    local tip = self.qmpkTip
    tip:setFontSize(17)
    tip:setString(string.format(prefixStr .. CHS[7001034],
        math.min(math.ceil(leftTime / 60), MAX_COUNT_MINUTE)) .. suffixStr)
    tip:setContentSize(infoSize.width, 0)
    tip:updateNow()

    local textW, textH = tip:getRealSize()
    tip:setPosition(0, infoSize.height - textH)
    local colorLayer = tolua.cast(tip, "cc.LayerColor")
    colorLayer:setAnchorPoint(0,0)
    labelPanel:addChild(colorLayer)

    local function func()
        local leftMin = math.ceil(leftTime / 60)
        if leftMin <= 0 then
            schePanel:stopAllActions()
        else
            local str = string.format(prefixStr .. CHS[7001034], math.min(leftMin, MAX_COUNT_MINUTE)) .. suffixStr
            if self.qmpkTip then
                self.qmpkTip:setString(str)
                self.qmpkTip:updateNow()
            end
        end

        leftTime = leftTime - 1
    end

    schedule(schePanel, func, 1)
end

function MissionDlg:MSG_CS_SHIDAO_TASK_INFO()
    self:refreshKFSDPanel()
end

function MissionDlg:MSG_SHIDAO_TASK_INFO()
    self:refreshSDDHPanel()
end

return MissionDlg

