-- LongZHDMgr.lua
-- Created by songcw Dec/2/2016
-- 龙争虎斗管理器

LongZHDMgr = Singleton()

-- 时间数据
local timeDate = nil

-- 赛程数据
local warSchedule = {}

-- 预测积分信息
local preScoreData = {}

-- 竞猜信息
local guessData = {}

LongZHDMgr.RACE_INDEX = {
    SCORE = "score_race",   -- 积分淘汰赛
    FINAL = "final_race",   -- 决赛
}

LongZHDMgr.WAR_RET = {
    NONE = "none",   -- 没有结果
    QL_WIN = "win_ql",   -- 青龙阵营胜利
    BH_WIN = "win_bh",   -- 白虎阵营胜利
    DRAW = "draw",   -- 平局
}

LongZHDMgr.CAMP = {
    QL = "camp_qinglong",   -- 青龙阵营
    BH = "camp_baihu",   -- 白虎阵营

}

-- 查询时间
function LongZHDMgr:queryTimeInfo(last_ti)
    gf:CmdToServer("CMD_LH_GUESS_RACE_INFO", {last_ti = last_ti or 0})
end

-- 查询对阵信息
function LongZHDMgr:queryWarPlans(race_name, race_index, day, last_ti)
    gf:CmdToServer("CMD_LH_GUESS_PLANS", {race_name = race_name, race_index = race_index, day = day, last_ti = last_ti or 0})
end

-- 查询队伍信息
function LongZHDMgr:queryTeamInfo(race_name, camp_type, camp_index)
    gf:CmdToServer("CMD_LH_GUESS_TEAM_INFO", {race_name = race_name, camp_type = camp_type, camp_index = camp_index, last_ti = 0})
end

-- 查询阵营信息
function LongZHDMgr:queryCampInfo(race_name)
    gf:CmdToServer("CMD_LH_GUESS_CAMP_SCORE", {race_name = race_name})
end

-- 查询竞猜信息
function LongZHDMgr:queryGuess(race_name, race_index)
    if race_index then
        gf:CmdToServer("CMD_LH_GUESS_INFO", {race_name = race_name, race_index = race_index})
    else
        gf:CmdToServer("CMD_LH_GUESS_INFO", {race_name = race_name, race_index = LongZHDMgr.RACE_INDEX.SCORE})
        gf:CmdToServer("CMD_LH_GUESS_INFO", {race_name = race_name, race_index = LongZHDMgr.RACE_INDEX.FINAL})
    end
end

-- 竞猜某阵营赢
function LongZHDMgr:guessCamp(race_name, race_index, camp_type)
    gf:CmdToServer("CMD_LH_MODIFY_GUESS", {race_name = race_name, race_index = race_index, camp_type = camp_type})
end

-- 获取编号丢的图片
function LongZHDMgr:getIndexRes(index)
    if index == 1 then
        return ResMgr.ui.lzhd_no1
    elseif index == 2 then
        return ResMgr.ui.lzhd_no2
    elseif index == 3 then
        return ResMgr.ui.lzhd_no3
    elseif index == 4 then
        return ResMgr.ui.lzhd_no4
    elseif index == 5 then
        return ResMgr.ui.lzhd_no5
    elseif index == 6 then
        return ResMgr.ui.lzhd_no6
    elseif index == 7 then
        return ResMgr.ui.lzhd_no7
    elseif index == 8 then
        return ResMgr.ui.lzhd_no8
    else
    end
end

-- 获取时间数据
function LongZHDMgr:getTimeData()
    return timeDate
end

function LongZHDMgr:getWarScheduleDataByKey(key)
    if not key then return warSchedule end

    return warSchedule[key]
end

function LongZHDMgr:MSG_LH_GUESS_RACE_INFO(data)
    timeDate = data
end

function LongZHDMgr:MSG_LH_GUESS_PLANS(data)
    local key = data.race_name .. data.race_index .. data.day
    warSchedule[key] = data
end

function LongZHDMgr:getScoreDatabyKey(key)
    if not key then return preScoreData end
    return preScoreData[key]
end

function LongZHDMgr:MSG_LH_GUESS_CAMP_SCORE(data)
    preScoreData[data.race_name] = data
end

-- 获取预测时间服务器下发
function LongZHDMgr:getguessDataByKey(key)
    if not key then return guessData end
    return guessData[key]
end

-- 获取预测默认时间
function LongZHDMgr:getguessDataByKeyDef(race_index)
    local curTime = gf:getServerTime()
    
    local yearS, monthS, dayS, hourS, minS, secS    -- 开始时间
    local yearE, monthE, dayE, hourE, minE, secE    -- 结束时间
    
    local yearC = tonumber(gf:getServerDate("%Y", curTime))
    
    -- 当前是否1月8日前
    if curTime < os.time({year = yearC, month = 1, day = 8, hour = 5}) then
        yearS = yearC - 1
    else
        yearS = yearC 
    end
    
    if race_index == LongZHDMgr.RACE_INDEX.SCORE then
        -- 积分赛
        
        monthS = 12;        dayS = 17;      hourS = 05;     minS = 0;       secS = 0
        
        yearE = yearS
        monthE = 12;        dayE = 23;      hourE = 04;     minE = 59;       secE = 59
    else
        -- 决赛
        monthS = 12;        dayS = 31;      hourS = 05;     minS = 0;       secS = 0

        yearE = yearS + 1
        monthE = 1;        dayE = 8;      hourE = 04;     minE = 59;       secE = 59
    end
    
    local data = {}
    data.start_ti = os.time({year = yearS, month = monthS, day = dayS, hour = hourS, min = minS, sec = secS})
    data.end_ti = os.time({year = yearE, month = monthE, day = dayE, hour = hourE, min = minE, sec = secE})
    return data
end

function LongZHDMgr:MSG_LH_GUESS_INFO(data)
    guessData[data.race_name .. data.race_index] = data
end

function LongZHDMgr:MSG_LONGHU_INFO(data)
    if data.is_open == 1 then
        local dlg = DlgMgr:openDlg("LonghzbInfoDlg")
        dlg:setData(data)
    else
        DlgMgr:closeDlg("LonghzbInfoDlg")
    end
end

MessageMgr:regist("MSG_LONGHU_INFO", LongZHDMgr)
MessageMgr:regist("MSG_LH_GUESS_RACE_INFO", LongZHDMgr)
MessageMgr:regist("MSG_LH_GUESS_PLANS", LongZHDMgr)
MessageMgr:regist("MSG_LH_GUESS_CAMP_SCORE", LongZHDMgr)
MessageMgr:regist("MSG_LH_GUESS_INFO", LongZHDMgr)

return LongZHDMgr
