-- KuafjjMgr.lua
-- created by huangzz Jan/02/2018
-- 跨服竞技管理器

KuafjjMgr = Singleton()

local TITLE_INFO = {
    [7] = {name = CHS[5400369], icon = ResMgr.ui.kuafjj_title_zhisheng},
    [6] = {name = CHS[5400370], icon = ResMgr.ui.kuafjj_title_zhizun},
    [5] = {name = CHS[5400371], icon = ResMgr.ui.kuafjj_title_mingwang},
    [4] = {name = CHS[5400372], icon = ResMgr.ui.kuafjj_title_shanjun},
    [3] = {name = CHS[5400373], icon = ResMgr.ui.kuafjj_title_zhengren},
    [2] = {name = CHS[5400374], icon = ResMgr.ui.kuafjj_title_jushi},
    [1] = {name = CHS[5400384], icon = ResMgr.ui.kuafjj_title_daotong},
}

-- 每个段位对应的起始积分
local STAGE_SCORE = {
    20300,
    19600,
    18900,
    18100,
    17300,
    16500,
    15600,
    14700,
    13800,
    12800,
    11800,
    10800,
    9700,
    8600,
    7500,
    6300,
    5100,
    3900,
    2600,
    1300,
    0,
}

local MIN_TAO = 3 * math.floor(Formula:getStdTao(100) / Const.ONE_YEAR_TAO) -- 以 MSG_CSC_TEAM_MATCH_MIN_TAO 中刷的最小道行为准
local MAX_TAO = 50000

function KuafjjMgr:getDefaultLevel()
    local minLevel, maxLevel = KuafjjMgr:getLimitLevel()
    local level = Me:getLevel()
    return math.max(minLevel, level - 5), math.min(maxLevel, level + 5)
end

function KuafjjMgr:getDefaultTao()
    local tao = Me:queryInt("tao")
    local yearTao = math.min(MAX_TAO, math.floor(tao / Const.ONE_YEAR_TAO))

    return math.max(MIN_TAO, yearTao), math.min(MAX_TAO, yearTao + 10000)
end

function KuafjjMgr:getTeamActiveName()
    if self.curCombatMode and self.curCombatMode ~= "1V1" then
        return CHS[5400341] .. self.curCombatMode
    else
        return CHS[3003734]
    end
end

function KuafjjMgr:getLimitLevel()
    local myLevel = Me:getLevel() or 0
    return math.max(100, myLevel - 9), math.min(Const.PLAYER_MAX_LEVEL, myLevel + 9)
end

function KuafjjMgr:getLimitTao()
    return MIN_TAO, MAX_TAO
end

function KuafjjMgr:isKFJJJournalist()
    local journaTask = TaskMgr:getTaskByName(CHS[5400342] .. CHS[5400420])
    if journaTask then
        return true
    end

    return false
end

function KuafjjMgr:requestZoneRankData(season, zone)
    if DistMgr:isInKFJJServer() then
        gf:CmdToServer("CMD_CSC_RANK_DATA_TOP_COMPETE", {})
    else
        if self.kuafjjSeasonData then
            -- 可能求的是本届数据
            season = season or self.kuafjjSeasonData.last_season_no
            zone = zone or self.kuafjjSeasonData.my_dist_in_zone
        end
        
        gf:CmdToServer("CMD_CSC_RANK_DATA_TOP", {season = season, zone = zone})
    end
end

function KuafjjMgr:requestStageRankData(season, zone)
    if DistMgr:isInKFJJServer() then
        gf:CmdToServer("CMD_CSC_RANK_DATA_STAGE_COMPETE", {})
    else
        if self.kuafjjSeasonData then
            -- 可能求的是本届数据
            season = season or self.kuafjjSeasonData.last_season_no
            zone = zone or self.kuafjjSeasonData.my_dist_in_zone
        end
        
        gf:CmdToServer("CMD_CSC_RANK_DATA_STAGE", {season = season, zone = zone})
    end
end

function KuafjjMgr:requestSeasonData()
    gf:CmdToServer("CMD_CSC_SEASON_DATA", {})
end

function KuafjjMgr:requestAutoMatch(enable)
    local combatMode, needNum = self:getCurCombatMode()
    local num = TeamMgr:getTeamTotalNum()
    if enable == 0 then
        if Me:isTeamMember() then
            gf:ShowSmallTips(CHS[5410220])
            return
        end
    
        gf:confirm(CHS[5400396], function() 
            gf:CmdToServer("CMD_CSC_SET_AUTO_MATCH", {enable = enable})
        end)
    else
        if not combatMode then
            gf:ShowSmallTips(CHS[5410217])
            return
        end

        if needNum > 1 and num ~= needNum then
            gf:ShowSmallTips(CHS[5400397])
            return
        end

        if num ~= TeamMgr:getTeamNum() then
            gf:ShowSmallTips(CHS[5400399])
            return
        end
        
        gf:CmdToServer("CMD_CSC_SET_AUTO_MATCH", {enable = enable})
    end
end

function KuafjjMgr:requestCombatMode(combat_mode)
    if KuafjjMgr:checkKuafjjIsEnd() then
        return
    end
    
    if GMMgr:isGM() or KuafjjMgr:isKFJJJournalist() then
        gf:ShowSmallTips(CHS[5400393])
        return
    end

    gf:CmdToServer("CMD_CSC_SET_COMBAT_MODE", {combat_mode = combat_mode})
end

-- 判断我的区组是否有参赛资格
function KuafjjMgr:myDistHasJoin()
    return self.kuafjjSeasonData and self.kuafjjSeasonData.my_dist_in_zone > 0
end

-- 获取已开启的赛季总数
function KuafjjMgr:getSeasonTotalNum()
    return self.seasonTotalNum or 0
end

function KuafjjMgr:getTitleInfo()
    return TITLE_INFO
end

-- 获取积分对应的小段位
function KuafjjMgr:getStageStrByScore(Score)
    if not Score then
        return
    end
    
    local cou = #STAGE_SCORE
    for i = 1, cou do
        if Score >= STAGE_SCORE[i] then
            local stageNum = cou - i + 1
            local bigStage = TITLE_INFO[math.ceil(stageNum / 3)].name
            local smallSatge = stageNum % 3
            if smallSatge == 0 then
                smallSatge = 3
            end
             
            return bigStage .. gf:changeNumber(smallSatge) .. CHS[5400385]
        end
    end
    
    return
end

-- 获取该赛季的区组列表数据
function KuafjjMgr:getSeasonData()
    return self.kuafjjSeasonData
end

-- 获取我的区组分配数据
function KuafjjMgr:getMyDistData()
    return self.myDistData
end

-- 获取本届竞技我的积分排行数据
function KuafjjMgr:getMyRankDataThisSeason()
    return self.myRankInfoThisSeason
end

function KuafjjMgr:setMyRankDataThisSeason(data)
    self.myRankInfoThisSeason = data
end

-- 获取某一届的赛区数量
function KuafjjMgr:getZoneCount(season)
    if not self.kuafjjSeasonData then
        return
    end

    season = season or self.kuafjjSeasonData.last_season_no
    if not season then
        return
    end
    
    return self.kuafjjSeasonData and self.kuafjjSeasonData.seasons[season]
end

-- 通知客户端当前赛季简要信息
function KuafjjMgr:MSG_CSC_SEASON_DATA(data)
    self.kuafjjSeasonData = data
    
    -- 获取已结束的跨服竞技届数
    if data.season_end == 1 then
        self.seasonTotalNum = data.last_season_no
    else
        self.seasonTotalNum = data.last_season_no - 1
    end
    
    -- 获取赛区分配中我的区组数据
    self.myDistData = nil
    if data.my_dist_in_zone > 0 and data[data.my_dist_in_zone] then
        local distsData = data[data.my_dist_in_zone]
        local myDist = GameMgr:getDistName()
        for i = 1, #distsData do
            if myDist == distsData[i].dist_name then
                self.myDistData = distsData[i]
                self.myDistData.zone = data.my_dist_in_zone
                break
            end
        end
    end
    
    -- 获取本届竞技玩家自己的数据
    self.myRankInfoThisSeason = {
        dist_name = GameMgr:getDistName() or "",
        gid = Me:queryBasic("gid"),          -- 玩家 gid
        name = Me:queryBasic("name"),        -- 玩家名称
        level = Me:getLevel(),               -- 玩家等级
        contrib = data.myRankInfo.contrib,   -- 玩家积分
        combat = data.myRankInfo.combat,     -- 战斗次数
        win = data.myRankInfo.win,           -- 战斗胜利次数
        polar = Me:queryBasicInt("polar"),   -- 玩家相性
    }
    
    DlgMgr:openDlg("KuafjjscDlg")
end

-- 跨服界面领奖分享界面
function KuafjjMgr:MSG_CSC_FETCH_BONUS(data)
    local dlg = DlgMgr:openDlg("KuafjjjlDlg")
    dlg:setData(data)
end

function KuafjjMgr:clearData()
    self.kuafjjSeasonData = nil
    self.seasonTotalNum = nil
    self.curCombatMode = nil
    self.curAutoMatchEnable = nil
end

-- 通知客户端跨服竞技信息界面数据
function KuafjjMgr:MSG_CSC_PLAYER_CONTEST_DATA(data)
    DlgMgr:openDlg("KuafjjInfoDlg")
end

function KuafjjMgr:getCurCombatMode()
    local needNum = 1
    if self.curCombatMode == '5V5' then
        needNum = 5
    elseif self.curCombatMode == '3V3' then
        needNum = 3
    end
    
    return self.curCombatMode, needNum
end

-- 通知客户端匹配模式
function KuafjjMgr:MSG_CSC_NOTIFY_COMBAT_MODE(data)
    local matchInfo = TeamMgr:getCurMatchInfo()
    local mode
    if matchInfo and matchInfo.name then
        mode = string.match(matchInfo.name, CHS[5400341] .. "(.+)")
    end
    
    if mode == data.combat_mode then
        -- 匹配数据与战斗模式相同不做处理
        self.curCombatMode = mode
        return
    end
    
    if data.combat_mode == "" then
        self.curCombatMode = nil
        TeamMgr:clearCurMatchState()
    else
        self.curCombatMode = data.combat_mode
        if data.combat_mode ~= "1V1" then
            local minLevel, maxLevel = KuafjjMgr:getDefaultLevel()
            -- local minTao, maxTao = KuafjjMgr:getDefaultTao()
            
            TeamMgr:setCurMatchState(CHS[5400341] .. data.combat_mode, minLevel, maxLevel)
            
            DlgMgr:sendMsg("TeamDlg", "setMatchInfo", CHS[5400341] .. data.combat_mode, minLevel, maxLevel)
        else
            TeamMgr:clearCurMatchState()
        end
    end
end

-- 当前是否开启匹配
function KuafjjMgr:getCurAutoMatchEnable()
    return self.curAutoMatchEnable
end

-- 通知客户端自动匹配状态
function KuafjjMgr:MSG_CSC_NOTIFY_AUTO_MATCH(data)
    self.curAutoMatchEnable = data.enable == 1
end

-- 跨服竞技场战斗结束
function KuafjjMgr:MSG_CSC_COMBAT_END(data)
    local dlg = DlgMgr:openDlg("KuafjjjsDlg")
    dlg:setData(data)
end

-- 获取最小道行
function KuafjjMgr:MSG_CSC_TEAM_MATCH_MIN_TAO(data)
    MIN_TAO = data.min_tao
end

-- 匹配的保护时间
function KuafjjMgr:MSG_CSC_PROTECT_TIME(data)
    self.protectTime = data.protect_time
end

-- 比赛时间信息
function KuafjjMgr:MSG_CSC_MATCHDAY_DATA(data)
    self.matchTimeData = data
end

-- 比赛结束时间段内
function KuafjjMgr:checkKuafjjIsEnd(notTips)
    if DistMgr:isInKFJJServer() then
        local times = self.matchTimeData or {}
        local endTime = times.matchday_end_time or 0
        local curTime = gf:getServerTime()
        if curTime >= endTime then
            if not notTips then
                gf:ShowSmallTips(CHS[5400427])
            end
            
            return true
        end
    end
end

MessageMgr:regist("MSG_CSC_TEAM_MATCH_MIN_TAO", KuafjjMgr)
MessageMgr:regist("MSG_CSC_FETCH_BONUS", KuafjjMgr)
MessageMgr:regist("MSG_CSC_PROTECT_TIME", KuafjjMgr)
MessageMgr:regist("MSG_CSC_MATCHDAY_DATA", KuafjjMgr)
MessageMgr:regist("MSG_CSC_COMBAT_END", KuafjjMgr)
MessageMgr:regist("MSG_CSC_PLAYER_CONTEST_DATA", KuafjjMgr)
MessageMgr:regist("MSG_CSC_NOTIFY_COMBAT_MODE", KuafjjMgr)
MessageMgr:regist("MSG_CSC_NOTIFY_AUTO_MATCH", KuafjjMgr)
MessageMgr:regist("MSG_CSC_RANK_DATA_STAGE", KuafjjMgr)
MessageMgr:regist("MSG_CSC_SEASON_DATA", KuafjjMgr)
return KuafjjMgr