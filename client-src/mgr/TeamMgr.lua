-- TeamMgr.lua
-- Created by chenyq Nov/14/2014
-- 组队管理器

TeamMgr = Singleton("TeamMgr")
TeamMgr.members = {}
TeamMgr.members_ex = {}
TeamMgr.requesters = {}
TeamMgr.inviters = {}
TeamMgr.captainGuards = {}

-- 当前选中的队员
TeamMgr.selectMember = nil

local oneActiveAdjustList = {
    CHS[5000152],
    CHS[5000153], -- 巡逻
    CHS[5000159], -- 除暴
    CHS[5000154], -- 刷道
    CHS[5000155], -- 修炼
    CHS[5000156], -- 副本
    CHS[5000157], -- 限时活动
    CHS[5000158], -- 天罡地煞
}

local twoActiveAdjustListMap = {
    [CHS[5000152]] = {
    },
    [CHS[5000153]] = {-- 巡逻
    },
    [CHS[5000159]] = {-- 除暴
    },
    [CHS[5000154]] = {-- 刷道
        CHS[5000160],-- 降妖
        CHS[5000161],-- 伏魔
        CHS[4000444], -- 飞仙渡邪
    },
    [CHS[5000155]] = {-- 修炼
--        CHS[5000162],
        CHS[4100325], -- "十绝阵"
        CHS[5000163],-- 修行
    },
    [CHS[5000156]] = {-- 副本
        CHS[5000164], -- 黑风洞
        CHS[5000166], -- 兰若寺
        CHS[5000165], -- 烈火涧
        CHS[4100554], -- 飘渺仙府
    },
    [CHS[5000157]] = { -- 限时活动
        CHS[5000167], -- 镖行万里
        CHS[5000168], -- 海盗入侵
        CHS[4000362], -- 悬赏
    },
    [CHS[5000158]] = { -- 天罡地煞
        CHS[5000169], -- 36天罡星
        CHS[5000170], -- 72地煞星
    },
    [CHS[5400334]] = {}, -- 跨服竞技3V3
    [CHS[5400343]] = {}, -- 跨服竞技5V5
}

-- 匹配活动到具体活动的映射
local adjustListToActivity = {
    [CHS[5000159]] = CHS[3000270], -- 除暴
    [CHS[5000160]] = CHS[3000287], -- 降妖
    [CHS[5000161]] = CHS[3000287], -- 伏魔
    [CHS[4100325]] = CHS[4100328], -- 十绝阵
    [CHS[5000163]] = CHS[4100328], -- 修行
    [CHS[5000164]] = CHS[3000299], -- 黑风洞
    [CHS[5000166]] = CHS[3000299], -- 兰若寺
    [CHS[5000165]] = CHS[3000299], -- 烈火涧
    [CHS[4100554]] = CHS[3000299], -- 飘渺仙府
    [CHS[5000167]] = CHS[3000713], -- 镖行万里
    [CHS[5000168]] = CHS[3000693], -- 海盗入侵
    [CHS[4000362]] = CHS[3000734], -- 悬赏
    [CHS[5000169]] = CHS[3000704], -- 36天罡星
    [CHS[5000170]] = CHS[3000709], -- 72地煞星
}


local activeLevelMap = {
    [CHS[5000152]] = { level = 1 },
    [CHS[5000153]] = { level = 20 },
    [CHS[5000159]] = { level = 20 },
    [CHS[5000154]] = { level = 45 },
    [CHS[5000160]] = { level = 45, parent = CHS[5000154] },
    [CHS[5000161]] = { level = 80, parent = CHS[5000154] },
    [CHS[4000444]] = { level = 120, parent = CHS[5000154] },
    [CHS[5000155]] = { level = 30 },
 --   [CHS[5000162]] = { level = 20, parent = CHS[5000155] },
    [CHS[5000163]] = { level = 30, parent = CHS[5000155] },
    [CHS[4100325]] = { level = 100, parent = CHS[5000155] },
    [CHS[5000156]] = { level = 30 },
    [CHS[5000164]] = { level = 30, parent = CHS[5000156] }, -- 黑风洞
    [CHS[5000165]] = { level = 90, parent = CHS[5000156] },
    [CHS[5000166]] = { level = 75, parent = CHS[5000156] },
    [CHS[4100554]] = { level = 110, parent = CHS[5000156] },
    [CHS[5000157]] = { level = 30 },
    [CHS[5000167]] = { level = 30 },
    [CHS[5000168]] = { level = 40 },
    [CHS[4000362]] = { level = 30 },
    [CHS[5000158]] = { level = 25 },
    [CHS[5000169]] = { level = 25 },
    [CHS[5000170]] = { level = 55 },
    [CHS[5400334]] = { level = 100, onlyShowServer = Const.KFJJDH_SERVER_TYPE},  -- 跨服竞技3V3
    [CHS[5400343]] = { level = 100, onlyShowServer = Const.KFJJDH_SERVER_TYPE},  -- 跨服竞技5V5
}

local teamTypeMap = {
    [CHS[5000152]]    = TEAM_MATCH_TYPE.TEAM_TYPE_ALL,
    [CHS[5000153]]    = TEAM_MATCH_TYPE.TEAM_TYPE_LIANGONG,
    [CHS[5000159]]    = TEAM_MATCH_TYPE.TEAM_TYPE_CHUBAO,
    [CHS[5000160]]    = TEAM_MATCH_TYPE.TEAM_TYPE_XIANGYAO,
    [CHS[5000161]]    = TEAM_MATCH_TYPE.TEAM_TYPE_FUMO,
 --   [CHS[5000162]]    = TEAM_MATCH_TYPE.TEAM_TYPE_XIANRZL,
    [CHS[5000163]]    = TEAM_MATCH_TYPE.TEAM_TYPE_XIUXING,
    [CHS[5000164]]    = TEAM_MATCH_TYPE.TEAM_TYPE_HEIFD,
    [CHS[5000165]]    = TEAM_MATCH_TYPE.TEAM_TYPE_LIEHJ,
    [CHS[5000166]]    = TEAM_MATCH_TYPE.TEAM_TYPE_LANRS,
    [CHS[5000167]]    = TEAM_MATCH_TYPE.TEAM_TYPE_BAINXWL,
    [CHS[5000168]]    = TEAM_MATCH_TYPE.TEAM_TYPE_HAIDRQ,
    [CHS[5000169]]    = TEAM_MATCH_TYPE.TEAM_TYPE_TIANGX,
    [CHS[5000170]]    = TEAM_MATCH_TYPE.TEAM_TYPE_DISX,
    [CHS[4000362]]    = TEAM_MATCH_TYPE.TEAM_TYPE_XUANS,
    [CHS[4100325]]    = TEAM_MATCH_TYPE.TEAM_TYPE_SHIJUEZHEN,
    [CHS[4100554]]    = TEAM_MATCH_TYPE.TEAM_TYPE_PIAOMXF,
    [CHS[4000444]]    = TEAM_MATCH_TYPE.TEAM_TYPE_FXDX,
    [CHS[5400334]]    = TEAM_MATCH_TYPE.TEAM_TYPE_KFJJC_3V3,
    [CHS[5400343]]    = TEAM_MATCH_TYPE.TEAM_TYPE_KFJJC_5V5,

    [TEAM_MATCH_TYPE.TEAM_TYPE_SHIJUEZHEN]         = CHS[4100325],
    [TEAM_MATCH_TYPE.TEAM_TYPE_ALL]         = CHS[5000152],
    [TEAM_MATCH_TYPE.TEAM_TYPE_LIANGONG]    = CHS[5000153],
    [TEAM_MATCH_TYPE.TEAM_TYPE_CHUBAO]      = CHS[5000159],
    [TEAM_MATCH_TYPE.TEAM_TYPE_XIANGYAO]    = CHS[5000160],
    [TEAM_MATCH_TYPE.TEAM_TYPE_FUMO]        = CHS[5000161],
--    [TEAM_MATCH_TYPE.TEAM_TYPE_XIANRZL]     = CHS[5000162],
    [TEAM_MATCH_TYPE.TEAM_TYPE_XIUXING]     = CHS[5000163],
    [TEAM_MATCH_TYPE.TEAM_TYPE_HEIFD]       = CHS[5000164],
    [TEAM_MATCH_TYPE.TEAM_TYPE_LIEHJ]       = CHS[5000165],
    [TEAM_MATCH_TYPE.TEAM_TYPE_LANRS]       = CHS[5000166],
    [TEAM_MATCH_TYPE.TEAM_TYPE_BAINXWL]     = CHS[5000167],
    [TEAM_MATCH_TYPE.TEAM_TYPE_HAIDRQ]      = CHS[5000168],
    [TEAM_MATCH_TYPE.TEAM_TYPE_TIANGX]      = CHS[5000169],
    [TEAM_MATCH_TYPE.TEAM_TYPE_DISX]        = CHS[5000170],
    [TEAM_MATCH_TYPE.TEAM_TYPE_XUANS]        = CHS[4000362],
    [TEAM_MATCH_TYPE.TEAM_TYPE_PIAOMXF]        = CHS[4100554],

    [TEAM_MATCH_TYPE.TEAM_TYPE_FXDX]    = CHS[4000444],

    [TEAM_MATCH_TYPE.TEAM_TYPE_KFJJC_3V3] = CHS[5400334],
    [TEAM_MATCH_TYPE.TEAM_TYPE_KFJJC_5V5] = CHS[5400343],
}

local ALLOW_ACTIVE = {
    [CHS[5000153]] = 1,     -- 巡逻
    [CHS[5000159]] = 1,     -- 除暴
    [CHS[5000160]] = 1,     -- 降妖
    [CHS[5000161]] = 1,     -- 伏魔
    [CHS[5000162]] = 1,     -- 仙人指路
    [CHS[5000163]] = 1,     -- 修行
    [CHS[5000164]] = 1,     -- 黑风洞
    [CHS[5000165]] = 1,     -- 烈火涧
    [CHS[5000166]] = 1,     -- 兰若寺
    [CHS[5000167]] = 1,     -- 镖行万里
    [CHS[5000168]] = 1,     -- 海盗入侵
    [CHS[4000362]] = 1,     -- 悬赏
    [CHS[5000169]] = 1,     -- 36天罡星
    [CHS[5000170]] = 1,     -- 72地煞星
    [CHS[4100325]] = 1,     -- 十绝阵
    [CHS[4100554]] = 1,     -- 飘渺仙府
    [CHS[4000444]] = 1,     -- 飞仙渡邪
    [CHS[5400334]] = 1,     -- 跨服竞技3V3
    [CHS[5400343]] = 1,     -- 跨服竞技5V5
}

local ACTIVE_LIMIT = {
    [CHS[3004385]] = CHS[3004386], -- 降妖
    [CHS[3004387]] = CHS[3004386], -- 伏魔
    [CHS[3004388]] = CHS[3004386], -- 修行
    [CHS[3004389]] = CHS[3004386], -- 黑风洞
    [CHS[3004390]] = CHS[3004386], -- 烈火涧
    [CHS[3004391]] = CHS[3004386], -- 兰若寺
    [CHS[3004392]] = CHS[3004386], -- 镖行万里
    [CHS[3004393]] = CHS[3004386], -- 海盗入侵
    [CHS[4100325]] = CHS[3004386], -- 十绝阵
    [CHS[4100554]] = CHS[3004386], -- 飘渺仙府
    [CHS[4000444]] = CHS[3004386], -- 飞仙渡邪
}

local matchInfo = {
    state = MATCH_STATE.NORMAL,
    name = "",
    minLevel = 0,
    maxLevel = 0,
    polars = {},
    minTao = 0,
    maxTao = 0
}

-- 获取活动最大等级
function TeamMgr:getMaxLevelActive(actName)
    return math.min(Const.PLAYER_MAX_LEVEL, Me:getLevel() + 9)
end

-- 获取活动最小等级
function TeamMgr:getMinLevelActive(actName)
    local def = activeLevelMap[actName].level
    return math.max(def, Me:getLevel() - 9)
end

-- 获取活动默认等级
function TeamMgr:getActiveRange(name)

    local min = math.max(Me:getLevel() - 5, activeLevelMap[name].level)
    local max = math.min(Me:getLevel() + 5, Const.PLAYER_MAX_LEVEL)
    return min, max
end

-- 活动限制
function TeamMgr:getActiveLimit(activeName)
    if nil == ACTIVE_LIMIT[activeName] then
        return CHS[3004394]
    end

    return ACTIVE_LIMIT[activeName]
end

-- 清空
function TeamMgr:clearData(isLoginOrSwithLine)
    TeamMgr.members = {}
    TeamMgr.members_ex = {}

    self.fixedTeam = nil

    if not DistMgr:getIsSwichServer() then
        TeamMgr.requesters = {}
        TeamMgr.inviters = {}
    end

    TeamMgr.captainGuards = {}
    matchInfo = {
        state = MATCH_STATE.NORMAL,
        name = "",
        minLevel = 0,
        maxLevel = 0,
        polars = {},
        minTao = 0,
        maxTao = 0,
    }

    if not isLoginOrSwithLine then
        self.teamEnlistMsg = nil
    end

    DlgMgr:sendMsg("MissionDlg", "displayType")
end

-- 获取当前匹配信息
function TeamMgr:getCurMatchInfo()
    return matchInfo
end

-- 请求队伍列表（队员请求）
function TeamMgr:requestTeamList(name)
    if nil ~= teamTypeMap[name] then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_MATCH_TEAM_LIST, teamTypeMap[name])
    end
end

-- 请求组队信息（队长请求）
function TeamMgr:requestMatchMember(name, minLevel, maxLevel, polars, minTao, maxTao, noTip)
    if minLevel > maxLevel then
        local temp = minLevel
        minLevel = maxLevel
        maxLevel = temp
    end

    if not MapMgr:checkCanMatch() then
        if not noTip then
            gf:ShowSmallTips(CHS[2100057])
        end
        return
    end

    if nil ~= teamTypeMap[name] then
        if DistMgr:isInKFJJServer() then
            if not activeLevelMap[name] or activeLevelMap[name].onlyShowServer ~= Const.KFJJDH_SERVER_TYPE then
                return
            end

            if not minTao or minTao < 0 or not  maxTao or maxTao < 0 then
                minTao, maxTao = KuafjjMgr:getDefaultTao()
            end

            if not polars or not next(polars) then
                polars = {1, 2, 3, 4, 5}
            end

            gf:CmdToServer("CMD_START_MATCH_TEAM_LEADER_KFJJC", {type = teamTypeMap[name], minLevel = minLevel, maxLevel = maxLevel, polars = polars, minTao = minTao, maxTao = maxTao})
        else
            gf:CmdToServer("CMD_START_MATCH_TEAM_LEADER", {type = teamTypeMap[name], minLevel = minLevel, maxLevel = maxLevel})
        end

        -- 记录匹配信息
        TeamMgr:setCurMatchState(name, minLevel, maxLevel, polars, minTao, maxTao)
    end
end

-- 设置当前的匹配状态
function TeamMgr:setCurMatchState(name, minLevel, maxLevel, polars, minTao, maxTao)
    matchInfo.name = name
    matchInfo.minLevel = minLevel
    matchInfo.maxLevel = maxLevel
    matchInfo.polars = polars
    matchInfo.minTao = minTao
    matchInfo.maxTao = maxTao
end

-- 清除匹配信息
function TeamMgr:clearCurMatchState()
    matchInfo.state = MATCH_STATE.NORMAL
    matchInfo.name = ""
    matchInfo.minLevel = 0
    matchInfo.maxLevel = 0
    matchInfo.polars = {}
    matchInfo.minTao = 0
    matchInfo.maxTao = 0
end

-- 获取名称对应的显示名字
function TeamMgr:getShowName(name)
    local parent = nil

    -- 找到一级菜单
    for k, v in pairs(twoActiveAdjustListMap) do
        for i = 1, #v do
            if v[i] == name then
                parent = k
            end
        end
    end

    if nil == parent then
        return name
    end

    return string.format("%s-%s", parent, name)
end

-- 根据类型获取名字
function TeamMgr:getNameByType(type)
    return teamTypeMap[type]
end

-- 队员开始匹配
function TeamMgr:requstMatchTeam(name)
    if not MapMgr:checkCanMatch() then
        gf:ShowSmallTips(CHS[2100057])
        return
    end

    if nil ~= teamTypeMap[name] then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_START_MATCH_MEMBER, teamTypeMap[name])
    end
end

-- 队员取消匹配
function TeamMgr:stopMatchTeam()
    TeamMgr:clearCurMatchState();

    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_CANCEL_MATCH_MEMBER)
end

-- 队长取消匹配
function TeamMgr:stopMatchMember()
    TeamMgr:clearCurMatchState();

    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_CANCEL_MATCH_LEADER)
end

function TeamMgr:getOneActiveAdjustList()
    if DistMgr:isInKFJJServer() then
        return {
            CHS[5000152],
            CHS[5400334], -- 跨服竞技3V3
            CHS[5400343], -- 跨服竞技5V5
        }
    else
        return oneActiveAdjustList
    end
end

function TeamMgr:getTwoActiveAdjustListMap()
    return twoActiveAdjustListMap
end

function TeamMgr:getActiveLevelMap()
    return activeLevelMap
end

function TeamMgr:isAllowActive(activeName)
    if DistMgr:isInKFJJServer()
        and (not activeLevelMap[activeName] or activeLevelMap[activeName].onlyShowServer ~= Const.KFJJDH_SERVER_TYPE) then
        return
    end

    if ALLOW_ACTIVE[activeName] then
        return true
    end

    return false
end

function TeamMgr:getLeaderId()
    local members = self.members_ex
    if nil ~= members then
        local member = members[1]
        if nil ~= member then
            return member.id
        end
    end
    return 0
end

function TeamMgr:getLeader()
    local members = self.members_ex
    if nil ~= members then
        local member = members[1]
        return member
    end
    return
end

function TeamMgr:inTeam(charId)
    local members = self.members
    for k, v in ipairs(members) do
        if v.id == charId then
            return true
        end
    end
    return false
end

function TeamMgr:inTeamByGid(gid)
    local members = self.members
    for k, v in ipairs(members) do
        if v.gid == gid then
            return true
        end
    end
    return false
end

function TeamMgr:coupleIsInTeam()
    local members = self.members
    local gid = Me:queryBasic("marriage/couple_gid")
    for k, v in ipairs(members) do
        if v.gid == gid then
            return true
        end
    end

    return false
end

-- 队员不包括队长
function TeamMgr:isTeamMeber(char)
	if self:getLeaderId() ~= char:getId() and TeamMgr:inTeam(char:getId()) then
	   return true
	end

	return false
end


function TeamMgr:inTeamEx(charId)
    local members = self.members_ex
    for k, v in ipairs(members) do
        if v.id == charId then
            return true
        end
    end
    return false
end

function TeamMgr:inTeamExByGid(gid)
    local members = self.members_ex
    for k, v in ipairs(members) do
        if v.gid == gid then
            return true
        end
    end
    return false
end

function TeamMgr:coupleIsInTeamEx()
    local members = self.members_ex
    local gid = Me:queryBasic("marriage/couple_gid")
    for k, v in ipairs(members) do
        if v.gid == gid then
            return true
        end
    end

    return false
end

function TeamMgr:isOverlineLeaveTemp(id)
    local members = self.members_ex
    for k, v in ipairs(members) do
        if v.id == id then
            return v.team_status == 3
        end
    end
    return false
end

function TeamMgr:isLeaveTemp(id)
    local members = self.members_ex
    for k, v in ipairs(members) do
        if v.id == id then
            return v.team_status == 2
        end
    end
    return false
end

function TeamMgr:getOrderById(id)
    if self.idToOrder then
        return self.idToOrder[id] or -1
    end
    return -1
end

-- 生成队员的队伍顺序映射表
function TeamMgr:makeMemberOrder()
    self.idToOrder = {}
    local members = self.members
    local index = 1
    local char
    for _, v in ipairs(members) do
        char = CharMgr:getCharById(v.id)
        if not char or not (char:isGather() and char:isShowRidePet()) then
            self.idToOrder[v.id] = index
            index = index + 1
        else
            self.idToOrder[v.id] = -1
        end
    end
end

function TeamMgr:MSG_UPDATE_TEAM_LIST(data)
    if data[1] and self.members and self.members[1] and data[1].id ~= self.members[1].id then
        -- 队长发生变更，通知相关界面
        TeamMgr:clearCurMatchState()
        DlgMgr:sendMsg("TeamDlg", "displayTeamInfo")
    end


    self.members = data

    -- 生成队员的队伍顺序映射表
    self:makeMemberOrder()

    -- 当处于巡逻状态接受组队邀请，则停止巡逻状态
    if self.members[1] and self.members[1].id ~= Me:queryBasicInt("id") and Me:isRandomWalk() then
        AutoWalkMgr:endRandomWalk()
    end

    -- 当处于自动寻路状态接受组队邀请，则停止自动寻路状态
    if self.members[1] and self.members[1].id ~= Me:queryBasicInt("id") then
        AutoWalkMgr:stopAutoWalk()
    end

    -- 通知聊天框语音图标
    ChatMgr:noticeVoiceBtn()
end

function TeamMgr:MSG_UPDATE_TEAM_LIST_EX(data)


    -- 进入队伍时，关闭NPC界面 WDSY-29413
    -- 由非组队变为组队
    if not next(self.members_ex) and data.count > 0 then
        --DlgMgr:closeDlg("NpcDlg")
        EventDispatcher:dispatchEvent("EVENT_JOIN_TEAM")
    end
    if next(self.members_ex) and self.members_ex.count <= 0 and data.count > 0 then
        --DlgMgr:closeDlg("NpcDlg")
        EventDispatcher:dispatchEvent("EVENT_JOIN_TEAM")
    end
    -- 暂离变为在队伍中
    if TeamMgr:getExMemberById(Me:getId()) and TeamMgr:getExMemberById(Me:getId()).team_status ~= 1 then
        for i = 1, data.count do
            if Me:getId() == data[i].id and data[i].team_status == 1 then
                DlgMgr:closeDlg("NpcDlg")
            end
        end
    end

    -- 队长发生变化
    if next(self.members_ex) and self.members_ex[1] and data[1] and self.members_ex[1].gid ~= data[1].gid then
        DlgMgr:closeDlg("TongTianDlg")
    end


    -- 队长发生变化，清空小红点
    if (next(self.members_ex) and self.members_ex.count <= 0 and data.count > 0)    -- 由非组队变为组队
        or (next(self.members_ex) and self.members_ex.count > 0 and data.count <= 0) -- 由组队变为非组队
        or (next(self.members_ex) and self.members_ex[1] and data[1] and self.members_ex[1].gid ~= data[1].gid) then -- 队长发生变化


        RedDotMgr:removeOneRedDot("MissionDlg", "TeamCheckBox")
        RedDotMgr:removeOneRedDot("TeamDlg", "InviteListButton")
        RedDotMgr:removeOneRedDot("TeamDlg", "ApplyListButton")
        RedDotMgr:removeOneRedDot("TeamTabDlg", "TeamDlgCheckBox")
    end

    if data.count == 0 or (data[1].gid == Me:queryBasic("gid") and self.members_ex and next(self.members_ex) and self.members_ex.count ~= 0 and self.members_ex[1].gid ~= Me:queryBasic("gid") ) then
        -- count == 0,即解散队伍
        -- data[1].gid == Me:queryBasic("gid") and self.members_ex and next(self.members_ex) and self.members_ex.count ~= 0 and self.members_ex[1].gid ~= Me:queryBasic("gid") 如果之前不是队长，变更信息后，我被提升为队长，则关闭
        DlgMgr:closeDlg("TeamOPMenuDlg")

        -- 分发消息
        EventDispatcher:dispatchEvent(EVENT.TEAM_DISMISS, {  })
    end

    if #self.members_ex == 0 and data.count > 0 and GuideMgr:isRunning() then
        -- 如果由单人状态变更为组队状态，则停止新手指引
        GuideMgr:closeCurrentGuide()
    end

    -- 如果当前队伍为0，并且自动匹配状态为0，则清空自动匹配信息
    if data.count == 0 and TeamMgr:getCurMatchInfo() and TeamMgr:getCurMatchInfo().state == MATCH_STATE.NORMAL then
        self:clearCurMatchState()
    end

    self.members_ex = data
    if data.count == 0 then TeamMgr.captainGuards = {} end
    -- 通知聊天框语音图标
    ChatMgr:noticeVoiceBtn()
end


function TeamMgr:isExsitByName(tab, name)
    for _, v in ipairs(tab) do
        if v.name == name then
            return true, _
        end
    end

    return false
end

function TeamMgr:MSG_REQUEST_LIST(data)
    if data.ask_type == Const.REQUEST_JOIN_TEAM then
        local isExsit
        for _, value in ipairs(data) do
            isExsit = TeamMgr:isExsitByName(TeamMgr.requesters, value.peer_name)
            if not isExsit then
                RedDotMgr:insertOneRedDot("TeamTabDlg", "TeamDlgCheckBox")
                RedDotMgr:insertOneRedDot("TeamDlg", "ApplyListButton")
                RedDotMgr:insertOneRedDot("MissionDlg", "TeamCheckBox")
                FriendMgr:playMessageSound()
                break
            end
        end

        TeamMgr.requesters= {}
        tmp = TeamMgr.requesters
    elseif data.ask_type == Const.INVITE_JOIN_TEAM then
        local isExsit
        for _, value in ipairs(data) do
            isExsit = TeamMgr:isExsitByName(TeamMgr.inviters, value.peer_name)
            if not isExsit then
                RedDotMgr:insertOneRedDot("TeamTabDlg", "TeamDlgCheckBox")
                RedDotMgr:insertOneRedDot("TeamDlg", "InviteListButton")
                RedDotMgr:insertOneRedDot("MissionDlg", "TeamCheckBox")
                FriendMgr:playMessageSound()
                break
            end
        end

        TeamMgr.inviters = {}
        tmp = TeamMgr.inviters
    end

    for _, value in ipairs(data) do
        for _, v in ipairs(value) do -- 第二层循环只有一个数据，此处只是配合服务端发送的格式
            table.insert(tmp, v)
        end
    end
end

function TeamMgr:MSG_DIALOG(data)
    local tmp = {}
    if data.ask_type == Const.REQUEST_JOIN_TEAM then
        tmp = TeamMgr.requesters

        local isExsit = TeamMgr:isExsitByName(tmp, data.peer_name)
        if not isExsit then
            RedDotMgr:insertOneRedDot("TeamTabDlg", "TeamDlgCheckBox")
            RedDotMgr:insertOneRedDot("TeamDlg", "ApplyListButton")
            RedDotMgr:insertOneRedDot("MissionDlg", "TeamCheckBox")
            FriendMgr:playMessageSound()
        end
    elseif data.ask_type == Const.INVITE_JOIN_TEAM then
        tmp = TeamMgr.inviters

        local isExsit = TeamMgr:isExsitByName(tmp, data.peer_name)
        if not isExsit then
            RedDotMgr:insertOneRedDot("TeamTabDlg", "TeamDlgCheckBox")
            RedDotMgr:insertOneRedDot("TeamDlg", "InviteListButton")
            RedDotMgr:insertOneRedDot("MissionDlg", "TeamCheckBox")
            FriendMgr:playMessageSound()
        end
    elseif data.ask_type == Const.REQUEST_TEAM_LEADER then -- 申请带队
        -- 改为由服务器自己弹框
        return
    else
        return
    end

    for _, v in ipairs(data) do
        v.captionGid = data.captionGid

        local isExsit, key = TeamMgr:isExsitByName(tmp, v.name)
        if not isExsit then
            table.insert(tmp, v)
        else
            tmp[key] = v
        end

        if data.ask_type == Const.INVITE_JOIN_TEAM then
            tmp[#tmp].membersNum = data.flag
        end
    end
end

function TeamMgr:MSG_CLEAN_ALL_REQUEST(data)
    if Const.REQUEST_JOIN_TEAM == data.ask_type then
        TeamMgr.requesters = {}
    elseif Const.INVITE_JOIN_TEAM  == data.ask_type then
        TeamMgr.inviters = {}
    else
        return
    end
end

function TeamMgr:cmdAccept(name, type)
	    gf:CmdToServer("CMD_ACCEPT", {
        peer_name = name,
        ask_type = type,
    })
end

function TeamMgr:cmdReject(name, type)
    gf:CmdToServer("CMD_REJECT", {
        peer_name = name,
        ask_type = type,
    })
end

function TeamMgr:MSG_CLEAN_REQUEST(data)
    local tmp = {}
    if data.ask_type == Const.REQUEST_JOIN_TEAM then
        tmp = TeamMgr.requesters
    elseif data.ask_type == Const.INVITE_JOIN_TEAM then
        tmp = TeamMgr.inviters
    else
        return
    end

    for _, name in ipairs(data) do
        local delete = nil
        for k, v in ipairs(tmp) do
            if name == v.name then
                delete = k
            end
        end
        if delete ~= nil then
            table.remove(tmp, delete)
        end
    end
end

function TeamMgr:MSG_TELEPORT_EX(data)
    local function onConfirm()
        gf:CmdToServer("CMD_OPER_TELEPORT_ITEM", {oper = data.type})
    end

    gf:confirm(data.tip, onConfirm)
end

function TeamMgr:MSG_TEAM_MOVED(data)
    local members = TeamMgr.members_ex
    for k, v in ipairs(members) do
        if v.id == data.id then
            v.m_map_id = data.map_id
            v.pos_x = data.x
            v.pos_y = data.y
        end
    end
end

-- 返回队伍人数(不包含暂离)
function TeamMgr:getTeamNum()
    return #self.members
end

-- 根据 id 获取队员信息（不包含暂离）
function TeamMgr:getMemberById(id)
    for i = 1, #self.members do
        if self.members[i].id == id then
            return self.members[i]
        end
    end
end

-- 返回队伍人数(包含暂离)
function TeamMgr:getTeamTotalNum()
    return #self.members_ex
end

-- 根据 id 获取队员信息（包含暂离）
function TeamMgr:getExMemberById(id)
    for i = 1, #self.members_ex do
        if self.members_ex[i].id == id then
            return self.members_ex[i]
        end
    end
end

function TeamMgr:MSG_MATCH_TEAM_STATE(data)
    if  data.state == -1 then
        self:clearCurMatchState()
        return
    end

    matchInfo.state = data.state
    if nil == data.type then
        if not self.members_ex.count or self.members_ex.count <= 0 then
            -- 若没有匹配，并且为单人，则清空匹配信息
            self:clearCurMatchState()
        end
        return
    end

    matchInfo.name = TeamMgr:getNameByType(data.type)
    matchInfo.minLevel = data.minLevel
    matchInfo.maxLevel = data.maxLevel
    matchInfo.minTao = data.minTao
    matchInfo.maxTao = data.maxTao
    matchInfo.polars = data.polars
end

function TeamMgr:MSG_LEADER_COMBAT_GUARD(data)
    TeamMgr.captainGuards = data.guardList
end

function TeamMgr:MSG_MEMBER_QUIT_TEAM(data)
    -- 每次当有队员离队时（队员被踢出队伍也算。队长离队不算，队长离队会解散队伍），则进行如下判断

    local function doRequestMatchMember(noTip)
        TeamMgr:requestMatchMember(matchInfo.name, matchInfo.minLevel or activeLevelMap[matchInfo.name].level,
            matchInfo.maxLevel or 85, matchInfo.polars, matchInfo.minTao, matchInfo.maxTao, noTip)
    end

    if DistMgr:isInKFJJServer() then
        if MapMgr:isInKuafjjzc() or KuafjjMgr:checkKuafjjIsEnd(true) then
            -- 跨服竞技战场不能自动匹配
            return
        end

        local combatMode, needNum = KuafjjMgr:getCurCombatMode()
        local num = TeamMgr:getTeamTotalNum()
        if num >= needNum then
            return
        end
    end

    local matchInfo = TeamMgr:getCurMatchInfo()

    local isShuadao = matchInfo.name == CHS[2200090] or matchInfo.name == CHS[2200086] or matchInfo.name == CHS[2200087]

    if isShuadao and (not GetTaoMgr:getRuYiZHLState() or not GetTaoMgr:getRuYiZHLAMTState()) then
        return
    end


    if matchInfo and matchInfo.name and "" ~= matchInfo.name and 0 ~= teamTypeMap[matchInfo.name] and matchInfo.state == 0 and not TaskMgr:getFuBenTask() then
        local reason = data.reason
        if "request_quit" == reason then
            -- 如果匹配信息的活动今日已完成
            local actData = ActivityMgr:getActivityByName(adjustListToActivity[matchInfo.name])
            if actData and ActivityMgr:isFinishActivity(actData) then

                return
            end

            -- 如果匹配信息为副本，但已有副本奖励任务
            if TaskMgr:isExistTaskByName(CHS[5200003]) then
                -- 取副本列表
                local fubenAct = twoActiveAdjustListMap[CHS[5000156]]
                for i = 1, #fubenAct do
                    -- 如果匹配的是副本任务
                    if fubenAct[i] == matchInfo.name then

                        return
                    end
                end
            end

            -- 如果匹配信息为限时活动，但该活动未开启
            local limitAct = twoActiveAdjustListMap[CHS[5000157]]
            for i = 1, #limitAct do
                -- 如果是限时活动
                if limitAct[i] == matchInfo.name then
                    local actData = ActivityMgr:getLimitActivityDataByName(adjustListToActivity[limitAct[i]])

                    -- 如果活动未开启
                    if actData and not ActivityMgr:isCurActivity(actData)[1] then
                        return
                    end
                end
            end

            -- 队员主动离队
            doRequestMatchMember(true)
        elseif "kickout" == reason then
            -- 如果此时队长不在匹配队列，且队伍有匹配信息（未使用过匹配队列的队伍是没有匹配信息的。），则弹出如下确认框
            gf:confirm(string.format(CHS[3004396], matchInfo.name, matchInfo.minLevel or activeLevelMap[matchInfo.name].level, matchInfo.maxLevel or Const.PLAYER_MAX_LEVEL), function()
                -- 点击确认则根据队伍的匹配信息加入匹配队列。
                doRequestMatchMember(false)
            end, nil, nil, 30)
        end
    end
end

function TeamMgr:acceptTeamByType(name, type)
    if not name or not type then return end
    if type == Const.INVITE_JOIN_TEAM then
        if TeamMgr:inTeamEx(Me:getId()) and not Me:isTeamLeader() then
            gf:ShowSmallTips(CHS[3004397])
            return false
        end
    end

    gf:CmdToServer("CMD_ACCEPT", {
        peer_name = name,
        ask_type = type,
    })

    return true
end

function TeamMgr:denyTeamByType(name, type)
    if not name or not type then return end
    if type == Const.INVITE_JOIN_TEAM then
        if TeamMgr:inTeamEx(Me:getId()) and not Me:isTeamLeader() then
            gf:ShowSmallTips(CHS[3004397])
            return false
        end
    end

    gf:CmdToServer("CMD_REJECT", {
        peer_name = name,
        ask_type = type,
    })
    return true
end
--
function TeamMgr:requestJionTeam(name, type)
    if not name or name == "" then return end
    if Me:isTeamLeader() then
        gf:CmdToServer("CMD_REQUEST_JOIN", {
            peer_name = name,
            ask_type = Const.INVITE_JOIN_TEAM,
        })
        return true
    end

    -- 如果我是队员，发送的又是邀请信息，则提示  "只有队长才可以邀请其他玩家加入队伍。"
    if self:inTeamEx(Me:getId()) then
        if type == Const.INVITE_JOIN_TEAM then
            gf:ShowSmallTips(CHS[3004398])
            return false
        else
            gf:ShowSmallTips(CHS[3004399])
            return false
        end
    end

    gf:CmdToServer("CMD_REQUEST_JOIN", {
        peer_name = name,
        ask_type = type,
    })

    return true
end

function TeamMgr:changeTeamLeader(id, type)
    gf:CmdToServer("CMD_CHANGE_TEAM_LEADER", {
        id = id,
        type = type,
    })
end

function TeamMgr:getFixedTeamMember(gid)
    if not self.fixedTeam or not self.fixedTeam.members then return end

    local members = self.fixedTeam.members
    for i = 1, #members do
        if members[i].gid == gid then
            return members[i]
        end
    end
end

function TeamMgr:MSG_DEMAND_WANTED_TASK(data)
    local dlg = DlgMgr:openDlg("RewardInquireDlg")
    dlg:setTeamInfo(data)
end

-- 一键召集所有暂离队友
function TeamMgr:callAll()
    gf:confirm(CHS[7002088], function()
        local members = TeamMgr.members_ex
        local needToCallMembers = {}
        for k, v in ipairs(members) do
            -- ２为暂离，３为跨线暂离
            if v.team_status == 2 or v.team_status == 3 then
                table.insert(needToCallMembers, v)
            end
        end

        if #needToCallMembers == 0 then
            gf:ShowSmallTips(CHS[7003019])
        else
            gf:CmdToServer("CMD_OPER_TELEPORT_ITEM", {oper = Const.TRY_RECRUIT, id = 0})

            if not MapMgr:isInZhongXian() then  -- 在众仙塔中不需要该提示
                gf:ShowSmallTips(CHS[7003020])
            end
        end
    end)
end

function TeamMgr:MSG_APPEAR(data)
    if not self.idToOrder or not self.idToOrder[data.id] then return end
    self:makeMemberOrder()
end

function TeamMgr:MSG_UPDATE_APPEARANCE(data)
    if not self.idToOrder or not self.idToOrder[data.id] then return end
    self:makeMemberOrder()
end

function TeamMgr:MSG_FIXED_TEAM_START_DATA(data)
    if not DlgMgr:isDlgOpened("TeamSortOrderDlg") then
        DlgMgr:openDlgEx("TeamSortOrderDlg", data)
    end
end

function TeamMgr:MSG_FIXED_TEAM_APPELLATION(data)
    if not DlgMgr:isDlgOpened("TeamSetTitleDlg") then
        DlgMgr:openDlgEx("TeamSetTitleDlg", { openType = data.type })
    end
end

function TeamMgr:MSG_FIXED_TEAM_CHECK_DATA(data)
    if not DlgMgr:isDlgOpened("TeamVoteDlg") then
        DlgMgr:openDlg("TeamVoteDlg")
        DlgMgr:sendMsg("TeamVoteDlg", "setInfo", data)
    end
end

function TeamMgr:MSG_FIXED_TEAM_DATA(data)
    if not DlgMgr:isDlgOpened("TeamVoteDlg") then
        DlgMgr:openDlg("TeamVoteDlg")
        DlgMgr:sendMsg("TeamVoteDlg", "setInfo", data, true)
    end
end

function TeamMgr:MSG_CANCEL_BUILD_FIXED_TEAM(data)
end

function TeamMgr:MSG_FIXED_TEAM_DATA(data)
    self.fixedTeam = data
    if data and data.members then
        table.sort(data.members, function(l, r)
            if l.gid == Me:queryBasic("gid") then return true end
            if r.gid == Me:queryBasic("gid") then return false end

            if l.last_logout_time <= 0 and r.last_logout_time > 0 then return true end
            if l.last_logout_time > 0 and r.last_logout_time <= 0 then return false end

            local ls = FriendMgr:getFriendScore(l.gid) or 0
            local rs = FriendMgr:getFriendScore(r.gid) or 0

            return ls > rs
        end)
    end
end

function TeamMgr:MSG_FIXED_TEAM_OPEN_SUPPLY_DLG(data)
end

function TeamMgr:getTeamEnlistMsg(key)
    return self.teamEnlistMsg and self.teamEnlistMsg[key]
end

function TeamMgr:setTeamEnlistMsg(key, msg)
    if not self.teamEnlistMsg then self.teamEnlistMsg = {} end
    self.teamEnlistMsg[key] = msg
end

function TeamMgr:checkHasFixedTeam()
    return self.hasFixedTeam == 1
end

function TeamMgr:MSG_FIXED_TEAM_CHECK(data)
    self.hasFixedTeam = data.has_fixed_team
    DlgMgr:openDlg("TeamEnlistDlg")
end

MessageMgr:regist("MSG_FIXED_TEAM_CHECK", TeamMgr)
MessageMgr:regist("MSG_UPDATE_TEAM_LIST", TeamMgr)
MessageMgr:regist("MSG_UPDATE_TEAM_LIST_EX", TeamMgr)
MessageMgr:regist("MSG_DIALOG", TeamMgr)
MessageMgr:regist("MSG_REQUEST_LIST", TeamMgr)
MessageMgr:regist("MSG_CLEAN_REQUEST", TeamMgr)
MessageMgr:regist("MSG_TELEPORT_EX", TeamMgr)
MessageMgr:regist("MSG_TEAM_MOVED", TeamMgr)
MessageMgr:regist("MSG_MATCH_TEAM_STATE", TeamMgr)
MessageMgr:regist("MSG_LEADER_COMBAT_GUARD", TeamMgr)
MessageMgr:regist("MSG_MEMBER_QUIT_TEAM", TeamMgr)
MessageMgr:regist("MSG_DEMAND_WANTED_TASK", TeamMgr)
MessageMgr:regist("MSG_CLEAN_ALL_REQUEST", TeamMgr)
MessageMgr:hook("MSG_APPEAR", TeamMgr, "TeamMgr")
MessageMgr:hook("MSG_UPDATE_APPEARANCE", TeamMgr, "TeamMgr")
MessageMgr:regist("MSG_FIXED_TEAM_START_DATA", TeamMgr, "TeamMgr")
MessageMgr:regist("MSG_FIXED_TEAM_APPELLATION", TeamMgr, "TeamMgr")
MessageMgr:regist("MSG_FIXED_TEAM_CHECK_DATA", TeamMgr, "TeamMgr")
MessageMgr:regist("MSG_FIXED_TEAM_DATA", TeamMgr, "TeamMgr")
MessageMgr:regist("MSG_CANCEL_BUILD_FIXED_TEAM", TeamMgr, "TeamMgr")
MessageMgr:regist("MSG_FIXED_TEAM_OPEN_SUPPLY_DLG", TeamMgr, "TeamMgr")
