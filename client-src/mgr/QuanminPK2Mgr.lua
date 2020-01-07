-- QuanminPK2Mgr.lua
-- created by lixh Jul/16/2018
-- 全民PK第2版管理器

QuanminPK2Mgr = Singleton()

-- 决赛，半决赛状态
local FINAL_MATCH_ID = {
    HALF_FINAL_ONE = 1, -- 半决赛第一场
    HALF_FINAL_TWO = 2, -- 半决赛第二场
    FINAL_BEFORE = 3,   -- 季殿军比赛
    FINAL = 4,          -- 冠亚军比赛
}

-- 比赛名称
local SIGN_TO_MATCH_NAME = {
    ["1"]          = CHS[7100327], -- 半决赛
    ["2"]          = CHS[7100327], -- 半决赛
    ["3"]          = CHS[7100317], -- 季殿军之战
    ["4"]          = CHS[7100318], -- 冠亚军之战
    ["default"]    = CHS[7100320], -- 热身赛 其他热身赛
    ["score"]      = CHS[7100321], -- 积分赛
    ["kickout_64"] = CHS[7100322], -- 128进64淘汰赛
    ["kickout_32"] = CHS[7100323], -- 64进32淘汰赛
    ["kickout_16"] = CHS[7100324], -- 32进16淘汰赛
    ["kickout_8"]  = CHS[7100325], -- 16进8淘汰赛
    ["kickout_4"]  = CHS[7100326], -- 8进4淘汰赛
}

-- 获取决赛id配置
function QuanminPK2Mgr:getFinalMatchIdCfg()
    return FINAL_MATCH_ID
end

-- 根据比赛标示获取比赛名称
function QuanminPK2Mgr:getMatchNameBySign(status, macthId, cob)
    if string.match(status, "score") then
        -- 积分赛
        return SIGN_TO_MATCH_NAME["score"]
    elseif string.match(status, "kickout") then
        -- 淘汰赛
        return SIGN_TO_MATCH_NAME[macthId]
    elseif string.match(status, "final") then
        -- 决赛
        if QuanminPKMgr:isQMJournalist() or GMMgr:isGM() then
            -- 记者与GM直接返回总决赛
            return CHS[7150080]
        else
            return SIGN_TO_MATCH_NAME[tostring(cob)]
        end
    else
        -- 其他 返回默认热身赛
        return SIGN_TO_MATCH_NAME["default"]
    end
end

-- 是否已经报名
function QuanminPK2Mgr:isMeSignUp()
    local myData = QuanminPK2Mgr:getMyData()
    if myData and myData.isSignUp == 1 then
        return true
    end

    return false
end

-- 是否已经确认阵容
function QuanminPK2Mgr:isMeEnsureTeam()
    local myData = QuanminPK2Mgr:getMyData()
    if myData and myData.teamId ~= "" then
        return true
    end

    return false
end

-- 是否是城市赛队伍
function QuanminPK2Mgr:isMeCityTeam()
    local myData = QuanminPK2Mgr:getMyData()
    if myData and myData.isCitySignUp == 1 then
        return true
    end

    return false
end

-- 是否已经有128强数据
function QuanminPK2Mgr:haveScData()
    return self:getScData() ~= nil
end

-- 是否已经有8强数据
function QuanminPK2Mgr:haveScFinalData()
    return self.haveFinalData
end

-- 是否开始积分赛
function QuanminPK2Mgr:isStartScoreCompet()
    local myData = QuanminPK2Mgr:getMyData()
    if myData and myData.zone ~= "" then
        return true
    end

    return false
end

-- 是否开始淘汰赛
function QuanminPK2Mgr:isStartTaotaiCompet()
    local myData = QuanminPK2Mgr:getMyData()
    if myData and myData.taotaiStartTime < gf:getServerTime() then
        return true
    end

    return false
end

-- 是否需要显示全民PK的info界面
function QuanminPK2Mgr:needShowQuanmpkInfo()
    if DistMgr:isInQMPKServer() and
        (QuanminPK2Mgr:isInDayPrepareTime() or QuanminPK2Mgr:isInDayCompeteTime()) then
        return true
    end

    return false
end

-- 是否处于入场准备阶段
function QuanminPK2Mgr:isInDayPrepareTime()
    local curTime = tonumber(gf:getServerDate("%H", gf:getServerTime()))
    local timeData = QuanminPK2Mgr:getScTimeData()
    if not timeData then return false end
    return curTime >= timeData.dayPrepareTime and curTime <= timeData.dayCompeteTime
end

-- 是否处于正式比赛阶段
function QuanminPK2Mgr:isInDayCompeteTime()
    local curTime = tonumber(gf:getServerDate("%H", gf:getServerTime()))
    local timeData = QuanminPK2Mgr:getScTimeData()
    if not timeData then return false end
    return curTime >= timeData.dayCompeteTime and curTime <= timeData.dayEndTime
end

-- 获取赛程表数据
function QuanminPK2Mgr:getScData()
    return self.scData
end

-- 获取赛程时间数据
function QuanminPK2Mgr:getScTimeData()
    return self.timeData
end

-- 获取积分排行榜数据
function QuanminPK2Mgr:getScoreRankData()
    return self.scoreData
end

-- 获取我的数据
function QuanminPK2Mgr:getMyData()
    return self.myData
end

-- 获取副本中界面数据
function QuanminPK2Mgr:getFubenData()
    return self.fubenInfo
end

-- 是否可以切磋
function QuanminPK2Mgr:isCanFightInQuanmpk()
    local curMapName = MapMgr:getCurrentMapName()
    if curMapName and (CHS[7002184] == curMapName or CHS[7120148] == curMapName) then
        -- 城市赛场，全民热身赛程可以切磋
        return true
    end

    return false
end

-- 是否可以打开副本信息界面
function QuanminPK2Mgr:isCanOpenInfoDlg()
    local curMapName = MapMgr:getCurrentMapName()
    if curMapName == CHS[7002185] or curMapName == CHS[7002186] then
        -- 全民楼兰城, 全民赛场
        return true
    end

    return false
end

-- 所有比赛的时间节点
function QuanminPK2Mgr:MSG_CSQ_ALL_TIME(data)
    self.timeData = data
    DlgMgr:sendMsg("QuanmPK2sjDlg", "initTimePanel")
end

-- 积分排行榜数据
function QuanminPK2Mgr:MSG_CSQ_SCORE_RANK(data)
    self.scoreData = data
    DlgMgr:sendMsg("QuanmPK2jfDlg", "setData")
end

-- 自己的全民PK数据
function QuanminPK2Mgr:MSG_CSQ_MY_DATA(data)
    self.myData = data
    DlgMgr:sendMsg("QuanmPK2jfDlg", "setMyRank")
    DlgMgr:sendMsg("QuanmPK2fxDlg", "setData")
end

-- 赛程表队伍数据
function QuanminPK2Mgr:MSG_CSQ_KICKOUT_ALL_TEAM_DATA(data)
    local teamMap = data.teamMap
    local teamMatchMap = data.matchMap
    local data128 = teamMatchMap["kickout_64"]  -- 128
    local data64  = teamMatchMap["kickout_32"]  -- 64
    local data32  = teamMatchMap["kickout_16"]  -- 32
    local data16  = teamMatchMap["kickout_8"]   -- 16
    local data8   = teamMatchMap["kickout_4"]    -- 8
    local data4   = teamMatchMap["kickout_2"]    -- 4
    local data2   = teamMatchMap["kickout_1"]    -- 2
    local data1   = teamMatchMap["final_1"]    -- 冠军
    local data0   = teamMatchMap["final_2"]    -- 季军

    if data8 then
        -- 如果有8强数据，更新一下标记
        self.haveFinalData = true
    end

    local myData = {}
    for i = 1, 128 do
        if data128 and data128.teamList[i] and teamMap[data128.teamList[i]] then
            local info = teamMap[data128.teamList[i]]
            local tmpData = {teamId = info.teamId, name = info.name, rank = info.rank}
            table.insert(myData, tmpData)
        else
            table.insert(myData, {teamId = "", name = "", rank = ""})
        end
    end

    local hasNo64Result = true
    for i = 1, 64 do
        if data64 and data64.teamList[i] and teamMap[data64.teamList[i]] then
            local info = teamMap[data64.teamList[i]]
            local tmpData = {teamId = info.teamId, name = info.name, rank = info.rank}
            table.insert(myData, tmpData)
            hasNo64Result = false
        else
            table.insert(myData, {teamId = "", name = "", rank = ""})
        end
    end

    for i = 129, 192 do
        myData[i].noResult = hasNo64Result
    end

    for i = 1, 32 do
        if data32 and data32.teamList[i] and teamMap[data32.teamList[i]] then
            local info = teamMap[data32.teamList[i]]
            local tmpData = {teamId = info.teamId, name = info.name, rank = info.rank}
            table.insert(myData, tmpData)
        else
            table.insert(myData, {teamId = "", name = "", rank = ""})
        end
    end

    for i = 1, 16 do
        if data16 and data16.teamList[i] and teamMap[data16.teamList[i]] then
            local info = teamMap[data16.teamList[i]]
            local tmpData = {teamId = info.teamId, name = info.name, rank = info.rank}
            table.insert(myData, tmpData)
        else
            table.insert(myData, {teamId = "", name = "", rank = ""})
        end
    end

    for i = 1, 8 do
        if data8 and data8.teamList[i] and teamMap[data8.teamList[i]] then
            local info = teamMap[data8.teamList[i]]
            local tmpData = {teamId = info.teamId, name = info.name, rank = info.rank}
            table.insert(myData, tmpData)
        else
            table.insert(myData, {teamId = "", name = "", rank = ""})
        end
    end

    local hasNo4Result = true
    for i = 1, 4 do
        if data4 and data4.teamList[i] and teamMap[data4.teamList[i]] then
            local info = teamMap[data4.teamList[i]]
            local tmpData = {teamId = info.teamId, name = info.name, rank = info.rank}
            table.insert(myData, tmpData)
            hasNo4Result = false
        else
            table.insert(myData, {teamId = "", name = "", rank = ""})
        end
    end

    for i = 249, 252 do
        myData[i].noResult = hasNo4Result
    end

    for i = 1, 2 do
        if data2 and data2.teamList[i] and teamMap[data2.teamList[i]] then
            local info = teamMap[data2.teamList[i]]
            local tmpData = {teamId = info.teamId, name = info.name, rank = info.rank}
            table.insert(myData, tmpData)
        else
            table.insert(myData, {teamId = "", name = "", rank = ""})
        end
    end

    if data1 and data1.teamList[1] and teamMap[data1.teamList[1]] then
        local info = teamMap[data1.teamList[1]]
        local tmpData = {teamId = info.teamId, name = info.name, rank = info.rank}
        table.insert(myData, tmpData)
    else
        table.insert(myData, {teamId = "", name = "", rank = ""})
    end

    if data0 and data0.teamList[1] and teamMap[data0.teamList[1]] then
        local info = teamMap[data0.teamList[1]]
        local tmpData = {teamId = info.teamId, name = info.name, rank = info.rank}
        table.insert(myData, tmpData)
    else
        table.insert(myData, {teamId = "", name = "", rank = ""})
    end

    self.scData = myData
    local dlg = DlgMgr:openDlg("QuanmPK2scDlg")
    dlg:setData()
    if QuanminPK2Mgr:haveScFinalData() then
        -- 如果有8强数据，增加选择总决赛
        dlg:chooseMenu(2)
    end
end

-- 奖励信息
function QuanminPK2Mgr:MSG_CSQ_BONUS_INFO(data)
    local meGid = Me:queryBasic("gid")
    local meInfo
    local otherInfo = {}
    for i = 1, data.count do
        local info = data[i]
        if info.gid == meGid then
            meInfo = info
        else
            table.insert(otherInfo, info)
        end
    end

    local dlg = DlgMgr:openDlgEx("ShidaowzjlDlg", SHARE_FLAG.QUANMINPKJL)
    dlg:setTitle(2, data)
    dlg:initView(meInfo, otherInfo, data.count)
end

-- 请求当前比赛信息
function QuanminPK2Mgr:requestQmpkInfo()
    gf:CmdToServer("CMD_CSQ_MATCH_INFO", {})
end

-- 请求赛程表数据信息
function QuanminPK2Mgr:requestQmpkScInfo()
    gf:CmdToServer("CMD_CSQ_KICKOUT_DATA", {})
end

-- 请求积分排行榜信息
function QuanminPK2Mgr:requestQmpkJfInfo()
    gf:CmdToServer("CMD_CSQ_SCORE_RANK", {})
end

-- 请求我的数据
function QuanminPK2Mgr:requestQmpkMyData()
    gf:CmdToServer("CMD_CSQ_MY_DATA", {})
end

-- 请求时间数据
function QuanminPK2Mgr:requestQmpkTimeData()
    gf:CmdToServer("CMD_CSQ_ALL_TIME", {})
end

-- 比赛时间信息
function QuanminPK2Mgr:MSG_CSQ_MATCH_TIME_INFO(data)
    self.fubenInfo = data
    DlgMgr:sendMsg("QuanmPK2InfoDlg", "refreshInfo")
    DlgMgr:sendMsg("MissionDlg", "refreshQMPKPanel")
end

-- 进入城市赛场，服务器可能不发比赛数据，主动刷新任务界面信息
function QuanminPK2Mgr:MSG_ENTER_ROOM(data)
    if MapMgr:isInMapByName(CHS[7120148]) then
        DlgMgr:sendMsg("MissionDlg", "refreshQMPKPanel")
    end
end

MessageMgr:regist("MSG_CSQ_ALL_TIME", QuanminPK2Mgr)
MessageMgr:regist("MSG_CSQ_SCORE_RANK", QuanminPK2Mgr)
MessageMgr:regist("MSG_CSQ_KICKOUT_ALL_TEAM_DATA", QuanminPK2Mgr)
MessageMgr:regist("MSG_CSQ_MY_DATA", QuanminPK2Mgr)
MessageMgr:regist("MSG_CSQ_KICKOUT_TEAM_DATA", QuanminPK2Mgr)
MessageMgr:regist("MSG_CSQ_BONUS_INFO", QuanminPK2Mgr)
MessageMgr:regist("MSG_CSQ_MATCH_TIME_INFO", QuanminPK2Mgr)
MessageMgr:hook("MSG_ENTER_ROOM", QuanminPK2Mgr, "QuanminPK2Mgr")
