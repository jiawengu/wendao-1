-- BatteryAndWifiMgr.lua
-- created by songcw Sep/22/2016
-- 擂台小霸王管理器

RingMgr = Singleton()

local ringData = nil            -- 擂台界面数据
local chanllengeData = nil      -- 挑战
local lastSeasonData = nil      -- 上一赛季数据
local tenWinnersData = nil
local seasonTitleData = nil

local NEW_RULE_TIME = 1483200000 -- "2017年01月01日00小时0000"

local JOB_INFO = {
    [1] = {[1] = CHS[4100373], [2] = CHS[4100374], [3] = CHS[4100375], icon = ResMgr.ui.arena_one, color = cc.c3b(255, 255, 255)},
    [2] = {[1] = CHS[4100376], [2] = CHS[4100377], [3] = CHS[4100378], icon = ResMgr.ui.arena_two, color = cc.c3b(51, 221, 255)},
    [3] = {[1] = CHS[4100379], [2] = CHS[4100380], [3] = CHS[4100381], icon = ResMgr.ui.arena_three, color = cc.c3b(51, 221, 255)},
    [4] = {[1] = CHS[4100382], [2] = CHS[4100383], [3] = CHS[4100384], icon = ResMgr.ui.arena_four, color = cc.c3b(204, 153, 255)},
    [5] = {[1] = CHS[4100385], icon = ResMgr.ui.arena_five, color = cc.c3b(255, 255, 0)},
}

-- 获取擂台数据
function RingMgr:getRingData()
    return ringData
end

function RingMgr:getChanllengeData()    
    return chanllengeData
end

function RingMgr:getSeasonTitleData()    
    return seasonTitleData
end

-- 默认的  等段和等级、下一个分数段
function RingMgr:getStepAndLevelByScoreDef(score)    
    if score >= 13000 then
        return 5, 1, score
    elseif score >= 10500 then
        return 4, 3, 13000
    elseif score >= 8500 then
        return 4, 2, 13000
    elseif score >= 7000 then
        return 4, 1, 8500
    elseif score >= 6000 then
        return 3, 3, 7000
    elseif score >= 5000 then
        return 3, 2, 6000
    elseif score >= 4000 then
        return 3, 1, 5000
    elseif score >= 3000 then
        return 2, 3, 4000
    elseif score >= 2500 then
        return 2, 2, 3000
    elseif score >= 2000 then
        return 2, 1, 2500
    elseif score >= 1000 then
        return 1, 3, 2000
    elseif score >= 500 then
        return 1, 2, 1000
    else
        return 1, 1, 500
    end
end

-- 指定赛季前  等段和等级、下一个分数段
function RingMgr:getStepAndLevelByScoreOld(score)    
    if score >= 33150 then
        return 5, 1, score
    elseif score >= 29850 then
        return 4, 3, 33150
    elseif score >= 26550 then
        return 4, 2, 29850
    elseif score >= 23250 then
        return 4, 1, 26550
    elseif score >= 18250 then
        return 3, 3, 23250
    elseif score >= 14500 then
        return 3, 2, 18250
    elseif score >= 12000 then
        return 3, 1, 14500
    elseif score >= 9000 then
        return 2, 3, 12000
    elseif score >= 6000 then
        return 2, 2, 9000
    elseif score >= 4000 then
        return 2, 1, 6000
    elseif score >= 2500 then
        return 1, 3, 4000
    elseif score >= 1000 then
        return 1, 2, 2500
    else
        return 1, 1, 1000
    end
end

-- 通过积分获取 等段和等级、下一个分数段
function RingMgr:getStepAndLevelByScore(score)
    if RingMgr:isNewRule() then
        return RingMgr:getStepAndLevelByScoreDef(score)
    else
        return RingMgr:getStepAndLevelByScoreOld(score)
    end
end

-- 是否使用新赛制
function RingMgr:isNewRule()
    if gf:getServerTime() < NEW_RULE_TIME then
        return false
    else
        return true
    end
end

-- 获取对应阶段等级的文字
function RingMgr:getJobChs(step, level)
    if JOB_INFO[step] and JOB_INFO[step][level] then return JOB_INFO[step][level] end
    return ""
end

-- 获取对应阶段等级的icon
function RingMgr:getResIcon(step)
    if JOB_INFO[step] and JOB_INFO[step]["icon"] then return JOB_INFO[step]["icon"] end
    return ""
end

-- 获取对应阶段等级的颜色
function RingMgr:getColor(step)
    if JOB_INFO[step] and JOB_INFO[step]["color"] then return JOB_INFO[step]["color"] end
    return nil
end

function RingMgr:MSG_COMPETE_TOURNAMENT_INFO(data)
    ringData = data
    DlgMgr:openDlg("RingHegemonyDlg")
end

function RingMgr:MSG_COMPETE_TOURNAMENT_TARGETS(data)
    chanllengeData = data
    local dlg = DlgMgr:getDlgByName("ArenaDekaronListDlg")
    if dlg then
        dlg:setData()
    else
        local dlg = DlgMgr:openDlg("ArenaDekaronListDlg")
        dlg:setData()
    end
end

function RingMgr:questTenWinner(season)
    gf:CmdToServer("CMD_COMPETE_TOURNAMENT_TOP_USER_INFO", {name = season})
end

function RingMgr:questLastSeason()
    gf:CmdToServer("CMD_COMPETE_TOURNAMENT_PREVIOUS_INFO", {})
end

function RingMgr:refreashChanllengeList()
    gf:CmdToServer("CMD_SEARCH_COMPETE_TOURNAMENT_TARGETS", {})
end

function RingMgr:chanllengePlayerByGid(gid)
    gf:CmdToServer("CMD_KILL_COMPETE_TOURNAMENT_TARGET", {gid = gid})
end

function RingMgr:getLastSeasonData()
    return lastSeasonData
end

function RingMgr:getTenWinnerData()
    return tenWinnersData
end

function RingMgr:MSG_COMPETE_TOURNAMENT_PREVIOUS_INFO(data)
    lastSeasonData = data
end

-- 10强
function RingMgr:MSG_COMPETE_TOURNAMENT_TOP_USER_INFO(data)
    tenWinnersData = {}
    tenWinnersData[data.season] = data.winners
end

function RingMgr:MSG_COMPETE_TOURNAMENT_TOP_CATALOG(data)   
    seasonTitleData = {}
    seasonTitleData.startYear = 0
    seasonTitleData.endYear = 0
    for i = 1, data.count do    
        local str = data.content[i]
        local year = tonumber(string.sub(str, 1, 4))
        if i == 1 then seasonTitleData.startYear = year end
        if i == data.count then seasonTitleData.endYear = year end

        if not seasonTitleData[year] then seasonTitleData[year] = {} end
        table.insert(seasonTitleData[year], { month = string.sub(str, 6, 7), day = string.sub(str, 9, 10), seasonData = str})
    end

    DlgMgr:openDlg("ArenaTopTenDlg")
end

MessageMgr:regist("MSG_COMPETE_TOURNAMENT_TOP_CATALOG", RingMgr)
MessageMgr:regist("MSG_COMPETE_TOURNAMENT_TOP_USER_INFO", RingMgr)
MessageMgr:regist("MSG_COMPETE_TOURNAMENT_PREVIOUS_INFO", RingMgr)
MessageMgr:regist("MSG_COMPETE_TOURNAMENT_INFO", RingMgr)
MessageMgr:regist("MSG_COMPETE_TOURNAMENT_TARGETS", RingMgr)
