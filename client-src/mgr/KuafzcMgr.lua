-- KuafzcMgr.lua
-- Created by songcw Aug/7/2017
-- 跨服战场管理器

KuafzcMgr = Singleton()


-- 客户端请求战场实时数据
function KuafzcMgr:queryLiveScore()
    gf:CmdToServer('CMD_CSL_LIVE_SCORE', {})
end

-- 客户端请求比赛时间
function KuafzcMgr:queryRoundTime()
    gf:CmdToServer('CMD_CSL_ROUND_TIME', {})
end

-- 客户端请求比赛时间
function KuafzcMgr:queryAllSimple()
    gf:CmdToServer('CMD_CSL_ALL_SIMPLE', {})
end

-- 客户端请求积分界面简要信息
function KuafzcMgr:queryMatchScoreSimple()
    gf:CmdToServer('CMD_CSL_MATCH_SIMPLE', {})
end

-- 通知比赛积分榜
function KuafzcMgr:queryJfRankByLvAndName(level, name)
    gf:CmdToServer('CMD_CSL_MATCH_DATA', {level = level, match_name = name})
end

-- 通知个人总积分榜
function KuafzcMgr:queryJfRankTotalPlayers(level)
    gf:CmdToServer('CMD_CSL_CONTRIB_TOP_DATA', {level = level})
end

-- 客户端请求具体赛区的数据
function KuafzcMgr:queryLeagueData(season, level, area)
    gf:CmdToServer('CMD_CSL_LEAGUE_DATA', {season_no = season, level_section = level, league_no = area})
end


function KuafzcMgr:getTimeData()
    return self.timeData
end

function KuafzcMgr:MSG_CSL_ROUND_TIME(data)
    local taotai_round = data.total_round - data.group_round

    local ret = {count = data.ti_count}
    local time = gf:getServerDate(CHS[4300031], data[1])
    local temp = {title = CHS[4100716], timeStr = string.format(CHS[4100717], time)}
    table.insert(ret, temp)

    for i = 1, data.group_round do
        local numStr = gf:changeNumber(i)
        local ti1 = gf:getServerDate(CHS[4300158], data[i + 1])
        local ti2 = gf:getServerDate(CHS[4100718], data[i + 1] + data.match_duration)
        local temp = {title = string.format(CHS[4100719], numStr ), timeStr = string.format("%s - %s", ti1, ti2)}
        table.insert(ret, temp)
    end

    if taotai_round == 1 then
        local ti1 = gf:getServerDate(CHS[4300158], data[data.ti_count])
        local ti2 = gf:getServerDate("%H:%M", data[data.ti_count] + data.match_duration)
        local temp = {title = CHS[4100720], timeStr = string.format("%s - %s", ti1, ti2)}
        table.insert(ret, temp)
    else
        local ti1 = gf:getServerDate(CHS[4300158], data[data.ti_count - 1])
        local ti2 = gf:getServerDate("%H:%M", data[data.ti_count - 1] + data.match_duration)
        local temp = {title = CHS[4100721], timeStr = string.format("%s - %s", ti1, ti2)}
        table.insert(ret, temp)

        local ti1 = gf:getServerDate(CHS[4300158], data[data.ti_count])
        local ti2 = gf:getServerDate("%H:%M", data[data.ti_count] + data.match_duration)
        local temp = {title = CHS[4100720], timeStr = string.format("%s - %s", ti1, ti2)}
        table.insert(ret, temp)
    end

    local dlg = DlgMgr:openDlg("KuafzcsjDlg")
    dlg:setData(ret)
    self.timeData = ret
end

function KuafzcMgr:getAllSimpleDara()
    return self.allSimpleData
end

function KuafzcMgr:MSG_CSL_ALL_SIMPLE(data)
    self.allSimpleData = data
end

function KuafzcMgr:getKeyStr(season, level, area)
    return string.format("%d|%d|%d", season, level, area)
end

function KuafzcMgr:getLeagueDataByKey(key)
    if self.scLeagueData and self.scLeagueData[key] then
        return self.scLeagueData[key]
    end
end

function KuafzcMgr:MSG_CSL_LEAGUE_DATA(data)
    self.scLeagueData = self.scLeagueData or {}
    self.scLeagueData[data.ret.key] = data.ret
end

function KuafzcMgr:cleanupForJFData()
    self.jfKnckoutData = nil
    self.jfGroupData = nil

end

-- 获取积分界面简要信息
function KuafzcMgr:getJfSimpleData()
    return self.jfSimpleData
end

function KuafzcMgr:getJfSecondMenu(key)
    if key == CHS[4100711] then
        return self.jfKnckoutData
    else
        return self.jfGroupData
    end
end

-- 我的区组是否参赛
function KuafzcMgr:isJoinMyDist()
    if not self.jfSimpleData then return end
    for i = 1, self.jfSimpleData.level_section_count  do
        local dt = self.jfSimpleData.levelRangeInfo[i]
        if dt.league_no ~= 0 and dt.group_no ~= 0 then
            return true
        end
    end
end

-- 通知积分界面简要信息
function KuafzcMgr:MSG_CSL_MATCH_SIMPLE(data)
    self.jfSimpleData = data
    self.jfGroupData = {}
    self.jfKnckoutData = {}
    for i = 1, data.level_section_count do
        local levelRangeInfo = data.levelRangeInfo[i]
        local key = levelRangeInfo.level_min .. "|" .. CHS[4100710]
        if not self.jfGroupData[key] then
            self.jfGroupData[key] = {group_end = levelRangeInfo.group_end, count = levelRangeInfo.group_match_count}
        end

        local key2 = levelRangeInfo.level_min .. "|" .. CHS[4100711]
        if not self.jfKnckoutData[key2] then
            self.jfKnckoutData[key2] = {group_end = levelRangeInfo.group_end, count = levelRangeInfo.knockout_match_count}
        end


        for j = 1, levelRangeInfo.group_match_count do
            local tempData = levelRangeInfo.groupMatchData[j]
            local distArr = gf:split(tempData.match_name, " VS ")
            local scoreArr = gf:split(tempData.score, ":")
            local pointArr = gf:split(tempData.point, ":")
            local title = ""
            local myDist, opDist
            local myScore, opScore
            local myRet = 0
            if GameMgr:getDistName() == distArr[1] then
                title = string.format(CHS[4100722], distArr[2])
                myDist = distArr[1]
                opDist = distArr[2]
                myScore = tonumber(scoreArr[1])
                opScore = tonumber(scoreArr[2])
                if tempData.point ~= "" then
                    if tonumber(pointArr[1]) > tonumber(pointArr[2]) then
                        myRet = 1
                    elseif tonumber(pointArr[1]) < tonumber(pointArr[2]) then
                        myRet = 2
                    elseif tonumber(pointArr[1]) == tonumber(pointArr[2]) then
                        myRet = 3
                    end
                else
                    myRet = 0
                end
            else
                title = string.format(CHS[4100722], distArr[1])
                myDist = distArr[2]
                opDist = distArr[1]
                myScore = tonumber(scoreArr[2])
                opScore = tonumber(scoreArr[1])
                if tempData.point ~= "" then
                    if tonumber(pointArr[1]) > tonumber(pointArr[2]) then
                        myRet = 2
                    elseif tonumber(pointArr[1]) < tonumber(pointArr[2]) then
                        myRet = 1
                    elseif tonumber(pointArr[1]) == tonumber(pointArr[2]) then
                        myRet = 3
                    end
                else
                    myRet = 0
                end
            end

            local ret = {title = title, match_name = tempData.match_name, myDist = myDist, opDist = opDist,
                myScore = myScore, opScore = opScore, start_time = tempData.start_time, myRet = myRet}
            table.insert(self.jfGroupData[key], ret)
        end

        for j = 1, levelRangeInfo.knockout_match_count do
            local tempData = levelRangeInfo.knockoutInfo[j]
            local distArr = gf:split(tempData.match_name, " VS ")
            local scoreArr = gf:split(tempData.score, ":")
            local title = ""
            local myDist, opDist
            local myScore, opScore
            if GameMgr:getDistName() == distArr[1] then
                title = string.format(CHS[4100722], distArr[2])
                myDist = distArr[1]
                opDist = distArr[2]
                myScore = tonumber(scoreArr[1])
                opScore = tonumber(scoreArr[2])
            else
                title = string.format(CHS[4100722], distArr[1])
                myDist = distArr[2]
                opDist = distArr[1]
                myScore = tonumber(scoreArr[2])
                opScore = tonumber(scoreArr[1])
            end

            local ret = {title = title, match_name = tempData.match_name, myDist = myDist, opDist = opDist,
                myScore = myScore, opScore = opScore, start_time = tempData.start_time}
            table.insert(self.jfKnckoutData[key2], ret)
        end
    end
end

function KuafzcMgr:isKFZCJournalist()
    local journaTask = TaskMgr:getTaskByName(CHS[4100738])
    if journaTask then
        return true
    end

    return false
end

function KuafzcMgr:cleanup()
    self.jfSimpleData = nil
    self.scLeagueData = nil
    self.allSimpleData = nil
    self.timeData = nil

    self.kfzcTimeData2019 = nil
    self.kfzcAllSimpleData2019 = nil
    self.scLeagueData2019 = nil
    self.jfSimpleData = nil
    self.jfGroupData = nil
    self.jfKnckoutData = nil
    self.kuafJFMenuData = nil
end

function KuafzcMgr:MSG_CSL_FETCH_BONUS(data)
    if data.title == "" then return end
    local dlg = DlgMgr:openDlg("KuafzcjlDlg")
    dlg:setData(data)
end

function KuafzcMgr:MSG_CSL_MATCH_DATA_COMPETE(data)
    local dlg = DlgMgr:openDlgEx("KuafzcjfDlg", true, nil, nil, true)
    dlg:setData(data)
end

MessageMgr:regist("MSG_CSL_MATCH_DATA_COMPETE", KuafzcMgr)
MessageMgr:regist("MSG_CSL_FETCH_BONUS", KuafzcMgr)
MessageMgr:regist("MSG_CSL_MATCH_SIMPLE", KuafzcMgr)
MessageMgr:regist("MSG_CSL_ROUND_TIME", KuafzcMgr)
MessageMgr:regist("MSG_CSL_ALL_SIMPLE", KuafzcMgr)
MessageMgr:regist("MSG_CSL_LEAGUE_DATA", KuafzcMgr)

--==============================--
--desc: 下面是新跨服，2018年12月
--time:2018-12-29 07:40:56
--@return
--==============================--

-- 请求时间信息
function KuafzcMgr:queryTimeData2019()
    gf:CmdToServer('CMD_CSML_ROUND_TIME', {})
end

-- 请求届数
function KuafzcMgr:queryAllSimpleData2019()
    gf:CmdToServer('CMD_CSML_ALL_SIMPLE', {})
end


function KuafzcMgr:queryLeagueData2019(season)
    gf:CmdToServer('CMD_CSML_LEAGUE_DATA', {season_no = season})
end

function KuafzcMgr:queryMatchScoreSimple2019()
    gf:CmdToServer('CMD_CSML_MATCH_SIMPLE')
end

-- 客户端请求积分界面简要信息
function KuafzcMgr:queryJfRankTotalPlayers2019()
    gf:CmdToServer('CMD_CSML_CONTRIB_TOP_DATA', {})
end

-- 通知比赛积分榜
function KuafzcMgr:queryJfRankByName(name)
    gf:CmdToServer('CMD_CSML_MATCH_DATA', {match_name = name})
end


function KuafzcMgr:getKuafzcTimeDesc(count, isChs)

    local ret = {}
    for i = count, 1, -1 do
     --   gf:ShowSmallTips(i)
        local f = math.pow(2, i)
        if f == 2 then
            table.insert( ret, "跨服战巅峰总决赛")
        else
            if isChs then
                table.insert( ret, string.format("晋级赛%s进%s", gf:changeNumToChinese(f), gf:changeNumToChinese(math.floor( f * 0.5 ))))
            else
                table.insert( ret, string.format("%d进%d", f, math.floor( f * 0.5 )))
            end
        end
    end

    return ret
end

-- 服务器下发数据需要转换下
function KuafzcMgr:getNewKuafzcsjDlgData()
    if not self.kfzcTimeData2019 then return end
    local ret = {}

    -- 公布时间
    local data = {}
    data.startTime = self.kfzcTimeData2019.group_ti
    data.endTime = 0
    data.desc = "参赛区组名单公布"
    table.insert(ret, data)

    local jinjisCount = self.kfzcTimeData2019.total_round - self.kfzcTimeData2019.group_round

    local jinjisDescMap = KuafzcMgr:getKuafzcTimeDesc(jinjisCount, true)

    for i = 1, self.kfzcTimeData2019.round_size do
        local data = {}
        data.startTime = self.kfzcTimeData2019.round_ti_info[i]
        data.endTime = data.startTime + self.kfzcTimeData2019.match_duration

        if self.kfzcTimeData2019.group_round >= i then
            data.desc = string.format("第%s场循环赛", gf:changeNumber(i))
        else
            data.desc = jinjisDescMap[i - self.kfzcTimeData2019.group_round]
        end
        table.insert(ret, data)
    end

    return ret
end

function KuafzcMgr:getKfzcSjData()
    return self.kfzcTimeData2019
end

function KuafzcMgr:getKfzcAllSimple2019Data()


    return self.kfzcAllSimpleData2019
end

function KuafzcMgr:getLeagueDataBySeason(season)
    if self.scLeagueData2019 and self.scLeagueData2019[season] then
        return self.scLeagueData2019[season]
    end
end

--=========goon
function KuafzcMgr:parsingMatchSimpleData(data)
    local jfMenuData = {}
    jfMenuData[CHS[4010318]] = {}
    jfMenuData[CHS[4010314]] = {}
    jfMenuData[CHS[4010315]] = {}
    self.jfSimpleData = data
    self.jfGroupData = {}
    self.jfKnckoutData = {}


    self.jfGroupData = {group_end = data.group_end, count = data.group_match_count}

    self.jfKnckoutData = {group_end = data.group_end, count = data.knockout_match_count}


    for j = 1, data.group_match_count do
        local tempData = data.groupMatchData[j]
        local distArr = gf:split(tempData.match_name, " VS ")
        local scoreArr = gf:split(tempData.score, ":")
        local pointArr = gf:split(tempData.point, ":")
        local title = ""
        local myDist, opDist
        local myScore, opScore
        local myRet = 0
        if GameMgr:getDistName() == distArr[1] then
            title = string.format(CHS[4100722], distArr[2])
            myDist = distArr[1]
            opDist = distArr[2]
            myScore = tonumber(scoreArr[1])
            opScore = tonumber(scoreArr[2])
            if tempData.point ~= "" then
                if tonumber(pointArr[1]) > tonumber(pointArr[2]) then
                    myRet = 1
                elseif tonumber(pointArr[1]) < tonumber(pointArr[2]) then
                    myRet = 2
                elseif tonumber(pointArr[1]) == tonumber(pointArr[2]) then
                    myRet = 3
                end
            else
                myRet = 0
            end
        else
            title = string.format(CHS[4100722], distArr[1])
            myDist = distArr[2]
            opDist = distArr[1]
            myScore = tonumber(scoreArr[2])
            opScore = tonumber(scoreArr[1])
            if tempData.point ~= "" then
                if tonumber(pointArr[1]) > tonumber(pointArr[2]) then
                    myRet = 2
                elseif tonumber(pointArr[1]) < tonumber(pointArr[2]) then
                    myRet = 1
                elseif tonumber(pointArr[1]) == tonumber(pointArr[2]) then
                    myRet = 3
                end
            else
                myRet = 0
            end
        end


        table.insert(jfMenuData[CHS[4010318]], title)

        local ret = {title = title, match_name = tempData.match_name, myDist = myDist, opDist = opDist,
            myScore = myScore, opScore = opScore, start_time = tempData.start_time, myRet = myRet}
        table.insert(self.jfGroupData, ret)
    end

    for j = 1, data.knockout_match_count do
        local tempData = data.knockoutInfo[j]
        local distArr = gf:split(tempData.match_name, " VS ")
        local scoreArr = gf:split(tempData.score, ":")
        local title = ""
        local myRet
        local myDist, opDist
        local myScore, opScore
        if GameMgr:getDistName() == distArr[1] then
            title = string.format(CHS[4100722], distArr[2])
            myDist = distArr[1]
            opDist = distArr[2]
            myScore = tonumber(scoreArr[1])
            opScore = tonumber(scoreArr[2])

            if tempData.score ~= "" then
                if myScore > opScore then
                    myRet = 1
                elseif myScore < opScore then
                    myRet = 2
                elseif myScore == opScore then
                    myRet = 3
                end
            else
                myRet = 0
            end
        else
            title = string.format(CHS[4100722], distArr[1])
            myDist = distArr[2]
            opDist = distArr[1]
            myScore = tonumber(scoreArr[2])
            opScore = tonumber(scoreArr[1])

            if tempData.score ~= "" then
                if myScore > opScore then
                    myRet = 1
                elseif myScore < opScore then
                    myRet = 2
                elseif myScore == opScore then
                    myRet = 3
                end
            else
                myRet = 0
            end
        end

        -- 判断是淘汰赛
        if j == data.knockout_match_count and data.total_round - data.group_round == data.knockout_match_count then
            table.insert(jfMenuData[CHS[4010315]], title)
        else
            table.insert(jfMenuData[CHS[4010314]], title)
        end

        local ret = {title = title, match_name = tempData.match_name, myDist = myDist, opDist = opDist,
            myScore = myScore, opScore = opScore, start_time = tempData.start_time, myRet = myRet}
        table.insert(self.jfKnckoutData, ret)
    end

    if not next(jfMenuData[CHS[4010315]]) then jfMenuData[CHS[4010315]] = nil end
    if not next(jfMenuData[CHS[4010314]]) then jfMenuData[CHS[4010314]] = nil end
    if not next(jfMenuData[CHS[4010318]]) then jfMenuData[CHS[4010318]] = nil end

    self.kuafJFMenuData = jfMenuData
end

-- 根据菜单的名字获取对应比赛名字
function KuafzcMgr:getMatchNameByTitle(title, matchType)
    local tempData

    if matchType == CHS[4010318] then
        tempData = gf:deepCopy(self.jfGroupData)
    else
        tempData = gf:deepCopy(self.jfKnckoutData)
    end

    for _, info in pairs(tempData) do
        if type(info) == "table" and title == info.title then
            return info.match_name
        end
    end
end

function KuafzcMgr:isInKuafzc2019()
    if MapMgr:isInMapByName(CHS[4010330]) or MapMgr:isInMapByName(CHS[4010331]) or MapMgr:isInMapByName(CHS[4010332])
        or MapMgr:isInMapByName(CHS[4010333]) or MapMgr:isInMapByName(CHS[4010334]) then

        return true
    end
end

function KuafzcMgr:isMyDomain()

    if Me:queryBasicInt("act_camp") == 1 and MapMgr:isInMapByName(CHS[4010334]) then
        return true
    elseif Me:queryBasicInt("act_camp") == 2 and MapMgr:isInMapByName(CHS[4010332]) then
        return true
    end
end

function KuafzcMgr:getMatchInfoByTitle(title, matchType)
    local tempData

    if matchType == CHS[4010318] then
        tempData = gf:deepCopy(self.jfGroupData)
    else
        tempData = gf:deepCopy(self.jfKnckoutData)
    end

    for _, info in pairs(tempData) do
        if type(info) == "table" and title == info.title then
            return info
        end
    end
end

-- 我的区组是否参赛
function KuafzcMgr:isJoinMyDist2019()
    if not self.jfSimpleData then return end
    return self.jfSimpleData.group_no ~= 0
end

function KuafzcMgr:getFJMenuData2019()
    return self.kuafJFMenuData
end

function KuafzcMgr:MSG_CSML_ROUND_TIME(data)
    self.kfzcTimeData2019 = data
    DlgMgr:openDlg("NewKuafzcsjDlg")
end

function KuafzcMgr:MSG_CSML_ALL_SIMPLE(data)
    self.kfzcAllSimpleData2019 = data
end

function KuafzcMgr:MSG_CSML_LEAGUE_DATA(data)
    self.scLeagueData2019 = self.scLeagueData2019 or {}
    self.scLeagueData2019[data.ret.key] = data
end

function KuafzcMgr:MSG_CSML_MATCH_SIMPLE(data)
    KuafzcMgr:parsingMatchSimpleData(data)
end

function KuafzcMgr:MSG_CSML_MATCH_DATA_COMPETE(data)
    local dlg = DlgMgr:openDlgEx("NewKuafzcjfDlg", true, nil, nil, true)
    dlg:setData(data)
end

function KuafzcMgr:MSG_CSML_FETCH_BONUS(data)
    if data.title == "" then return end
    local dlg = DlgMgr:openDlg("NewKuafzcjlDlg")
    dlg:setData(data)
end

MessageMgr:regist("MSG_CSML_FETCH_BONUS", KuafzcMgr)
MessageMgr:regist("MSG_CSML_MATCH_DATA_COMPETE", KuafzcMgr)
MessageMgr:regist("MSG_CSML_MATCH_SIMPLE", KuafzcMgr)
MessageMgr:regist("MSG_CSML_LEAGUE_DATA", KuafzcMgr)
MessageMgr:regist("MSG_CSML_ROUND_TIME", KuafzcMgr)
MessageMgr:regist("MSG_CSML_ALL_SIMPLE", KuafzcMgr)
