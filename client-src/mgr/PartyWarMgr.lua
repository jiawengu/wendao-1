-- PartyMgr.lua
-- Created by liuhb Apr/7/2015
-- 帮战管理器

PartyWarMgr = Singleton()
PartyWarMgr.endTime = 0
PartyWarMgr.signUpList = {}     -- 帮战申请列表
PartyWarMgr.scheduleInfo = {}   -- 帮战赛程信息
PartyWarMgr.historyList = {}    -- 帮战历届信息

PartyWarMgr.DLGTYPE = {
    BID         = "bid",
    FIXTURES    = "fixtures",
    HISTORY     = "history",
}

-- 打开帮战系统
function PartyWarMgr:openPartyWar()
    local lastDlg = DlgMgr:getLastDlgByTabDlg("PartyWarTabDlg") or "PartyWarSignUpDlg"
    DlgMgr:openDlg(lastDlg)
end

-- 切换请求标签界面信息
function PartyWarMgr:requestDlgInfo(type)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_PARTY_WAR_INFO, type, nil)
end

-- 清楚数据
function PartyWarMgr:clear()
    PartyWarMgr.signUpList = {}     -- 帮战申请列表
    PartyWarMgr.scheduleInfo = {}   -- 帮战赛程信息
    PartyWarMgr.historyList = {}    -- 帮战历届信息
end

-- 获取报名列表
function PartyWarMgr:getSignUpList(start, limit)
    if not start then
    -- 如果没有开始索引，返回全部
        return PartyWarMgr.signUpList
    end

    local retValue = {}
    local count = 0

    for i = 1, PartyWarMgr.signUpList.count do
        if i >= start and count < limit then
            table.insert(retValue, PartyWarMgr.signUpList.signList[i])
            count = count + 1
        end
    end

    return retValue
end

-- 报名操作
function PartyWarMgr:signUpOper()
    gf:CmdToServer("CMD_BID_PARTY_WAR", {})
end

-- 追加操作
function PartyWarMgr:assignCashOper(cash)
    gf:CmdToServer("CMD_ADD_PARTY_WAR_MONEY", {cash = cash})
end

-- 刷新报名列表操作
function PartyWarMgr:refreshSignUpList()
    gf:CmdToServer("CMD_REFRESH_PARTY_WAR_BID", {})
end

-- 获取开放赛区列表
function PartyWarMgr:getZoneList()
    local keys = {}
    for k, v in pairs(PartyWarMgr.scheduleInfo) do
        if v[PARTY_TYPE.SCORE_INFO_TYPE_EX] then
            table.insert(keys, k)
        end
    end

    return keys
end

-- 获取出线帮派
function PartyWarMgr:getOutletParty(zone)
    local winParty = {}
    local warParty = PartyWarMgr:getKnockoutInfo(zone)
    if not warParty then return end

    -- 新帮主后，淘汰赛可能由于参赛名额关系，只有一轮
    for i = 1, #warParty do
        table.insert(winParty, warParty[i].attacker)
        table.insert(winParty, warParty[i].defenser)
    end


    return winParty
end

-- 根据赛区及小组赛别获取比赛信息
function PartyWarMgr:getCompetitionInfo(zone, group)
    local server = ""
    local partysInfo = {}
    local competitionList = {}

    repeat
        -- 首先获取服务器信息
        server = self:getLineInfo(zone, group)
        if nil == server then break end

        -- 帮派积分信息
        -- 具体胜利失败场次未添加
        partysInfo = self:getPartysInfo(zone, group)
        if nil == partysInfo then break end

        -- 小组赛程
        competitionList = self:getCompetitionList(zone, group)
        if nil == competitionList then break end
    until true

    return {
        lineInfo = server,
        partysInfo = partysInfo,
        competitionList = competitionList,
    }
end

-- 获取服务器信息
function PartyWarMgr:getLineInfo(zone, group)
    local zoneInfo = PartyWarMgr.scheduleInfo[zone]
    if nil == zoneInfo then return end

    local server = zoneInfo[PARTY_TYPE.WAR_SERVER].server
    if nil == server then return end

    return server
end

-- 获取帮派积分
function PartyWarMgr:getPartysInfo(zone, group)
    local zoneInfo = PartyWarMgr.scheduleInfo[zone]
    if nil == zoneInfo then return end

    if nil == zoneInfo[PARTY_TYPE.SCORE_INFO_TYPE_EX] then return end
    local partysInfo = {}
    for i = 1, #zoneInfo[PARTY_TYPE.SCORE_INFO_TYPE_EX] do
        if group == zoneInfo[PARTY_TYPE.SCORE_INFO_TYPE_EX][i].group then
            local result = self:getPartyWLDInfo(zoneInfo[PARTY_TYPE.SCORE_INFO_TYPE_EX][i].party_name, zone, group)
            table.insert(partysInfo, {
                partyName   = zoneInfo[PARTY_TYPE.SCORE_INFO_TYPE_EX][i].party_name,
                warScore    = zoneInfo[PARTY_TYPE.SCORE_INFO_TYPE_EX][i].war_score,
                win         = result.win,
                lose        = result.lose,
                draw        = result.draw})
        end
    end

    return partysInfo
end

function PartyWarMgr:getPartyWLDInfo(partyName, zone, group)
    local win = 0
    local lose = 0
    local draw = 0
    repeat
        local zoneInfo = PartyWarMgr.scheduleInfo[zone]
        if nil == zoneInfo then break end

        -- 遍历赛程
        if nil == zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX] then break end
        for i = 1, #zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX] do
            if group == zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].group then
                if partyName == zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].attacker then
                    local time = zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].time
                    if time ~= "" and gf:getServerTime() >= tonumber(time) then
                        -- 为攻击方
                        if PARTY_COMPETITION_RESULT.ATTACKER_WIN == zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].result then
                            win = win + 1
                        elseif PARTY_COMPETITION_RESULT.DRAW == zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].result then
                            draw = draw + 1
                        elseif PARTY_COMPETITION_RESULT.DEFENSER_WIN == zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].result then
                            lose = lose + 1
                        elseif PARTY_COMPETITION_RESULT.LUNKONG == zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].result then
                            if partyName ~= "" and zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].defenser == "" then
                                win = win + 1
                            elseif partyName == "" and zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].defenser ~= "" then
                                lose = lose + 1
                            end
                        end
                    end
                end

                if partyName == zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].defenser then
                    local time = zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].time
                    if time ~= "" and gf:getServerTime() >= tonumber(time) then
                        -- 为防守方
                        if PARTY_COMPETITION_RESULT.DEFENSER_WIN == zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].result then
                            win = win + 1
                        elseif PARTY_COMPETITION_RESULT.DRAW == zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].result then
                            draw = draw + 1
                        elseif PARTY_COMPETITION_RESULT.ATTACKER_WIN == zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].result then
                            lose = lose + 1
                        elseif PARTY_COMPETITION_RESULT.LUNKONG == zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].result then
                            if partyName ~= "" and zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].attacker == "" then
                                win = win + 1
                            elseif partyName == "" and zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].attacker ~= "" then
                                lose = lose + 1
                            end
                        end
                    end
                end
            end
        end
    until true

    return {win = win, lose = lose, draw = draw}
end

-- 获取帮战赛程
function PartyWarMgr:getCompetitionList(zone, group)
    local zoneInfo = PartyWarMgr.scheduleInfo[zone]
    if nil == zoneInfo then return end

    if nil == zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX] then return end
    local competitionList = {}
    for i = 1, #zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX] do
        if COMP_STAGE.GROUP_STAGE   == zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].stage
            and group               == zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].group then
            table.insert(competitionList, {
                time        = zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].time,
                defenser    = zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].defenser,
                attacker    = zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].attacker,
                result      = zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].result
            })
        end
    end

    return competitionList
end

-- 根据赛区获取淘汰赛比赛信息
function PartyWarMgr:getKnockoutInfo(zone)
    local zoneInfo = PartyWarMgr.scheduleInfo[zone]
    if nil == zoneInfo then return end
    if not zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX] then return end

    -- 淘汰赛程
    local knockOutList = {}
    for i = 1, #zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX] do
        if     COMP_STAGE.KNOCKOUT_1 == zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].stage
            or COMP_STAGE.KNOCKOUT_2 == zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].stage
            or COMP_STAGE.KNOCKOUT_3 == zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].stage
            or COMP_STAGE.KNOCKOUT_4 == zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].stage then

            table.insert(knockOutList, {
                stage       = zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].stage,
                time        = zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].time,
                defenser    = zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].defenser,
                attacker    = zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].attacker,
                result      = zoneInfo[PARTY_TYPE.SCHEDULE_INFO_TYPE_EX][i].result
            })
        end
    end

    return knockOutList
end

-- 获取总共有多少届信息
function PartyWarMgr:getPartyWarInfoNum()
    return #self:getPartyWarInfo()
end

-- 获取历届帮战信息列表
function PartyWarMgr:getPartyWarInfo(start, pageCount)
    local ret = {}

    for i = 1, #PartyWarMgr.historyList do
        if start <= i and (start + pageCount) >= i then
            table.insert(ret, PartyWarMgr.historyList[i])
        end
    end

    return ret
end

-- 根据届数及赛区请求历届帮战信息
function PartyWarMgr:requestPartyWarInfo(period, zone)
    if not period or not zone then return end
    gf:CmdToServer("CMD_VIEW_PARTY_WAR_HISTORY", {no = tonumber(period), zone = tonumber(zone)})
end

-- 请求帮战敌我双方信息
function PartyWarMgr:requesetPartyWarActiveInfo()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_PARTY_WAR_SCORE)
end

-- 帮战报名消息
function PartyWarMgr:MSG_PARTY_WAR_BID_INFO(data)
    PartyWarMgr.endTime = data.end_time
 --   PartyWarMgr.signUpList = data.info
    local signUpList = data.info
    local list = {}
    local count = data.count
    for i = 1, count do
        table.insert(list, {partyName = signUpList[i].party_name, cash = signUpList[i].cash})
    end

    PartyWarMgr.signUpList = {forbidTime = PartyWarMgr.endTime,
        count = count,
        signList = list,}

    if gf:getServerTime() < data.end_time then
        DlgMgr:openDlg("PartyWarSignUpDlg")
    end
end

-- 帮战赛程信息
function PartyWarMgr:MSG_PARTY_WAR_INFO(data)
    -- 判断区组，按照区组进行存储数据
    if nil == data.info or 0 == #data.info then return end -- 没有具体消息，丢弃

    local type = data.type

    -- 如果是本届帮派赛程界面消息
    if  PARTY_TYPE.SCHEDULE_INFO_TYPE_EX == type or PARTY_TYPE.SCORE_INFO_TYPE_EX == type or PARTY_TYPE.WAR_SERVER == type then
        if PARTY_TYPE.WAR_SERVER == type then
            for k, v in pairs(data.info) do
                local group = v.comp_area
                if nil ~= group then
                    if nil == PartyWarMgr.scheduleInfo[group] then
                        -- 数据不存在，新建
                        PartyWarMgr.scheduleInfo[group] = {}
                    end

                    PartyWarMgr.scheduleInfo[group][type] = v
                end
            end
        else
            local group = data.info[1].comp_area
            if nil == group then return end -- 没有赛区信息，信息不完整，丢弃

            -- 存储并更新数据
            -- 按赛区进行存储数据
            if nil == PartyWarMgr.scheduleInfo[group] then
                -- 数据不存在，新建
                PartyWarMgr.scheduleInfo[group] = {}
            end

            PartyWarMgr.scheduleInfo[group][data.type] = data.info
        end

        if PARTY_TYPE.SCHEDULE_INFO_TYPE_EX == type then

            --[[
        -- 帮战进度信息（新帮战中使用）
        DlgMgr:openDlg("PartyWarScheduleDlg")
            local dlg = DlgMgr:getDlgByName("PartyWarScheduleDlg")
            if data.isOpenDlg == 1 then
                dlg = DlgMgr:openDlg("PartyWarScheduleDlg")
            end
            if dlg then
                local selectInfo = dlg:getCurrentSelect()
                if selectInfo.zone == data.info[1].comp_area and selectInfo.group == data.info[1].group then
                    dlg:setDetalInfo(selectInfo.zone, selectInfo.group)
                end
            end
            --]]
        elseif PARTY_TYPE.SCORE_INFO_TYPE_EX == type then

--[[
            -- 积分排名信息（新帮战中使用）
            local dlg = DlgMgr:getDlgByName("PartyWarScheduleDlg")
            if data.isOpenDlg == 1 then
                dlg = DlgMgr:openDlg("PartyWarScheduleDlg")
            end


            if dlg then
                local selectInfo = dlg:getCurrentSelect()
                if selectInfo.zone == data.info[1].comp_area and selectInfo.group == data.info[1].group then
                    dlg:setDetalInfo(selectInfo.zone, selectInfo.group)
                end
                dlg:setZoneEnable()
            end
        --]]
        elseif PARTY_TYPE.WAR_SERVER == type then

--[[
        -- 举行帮战的服务器
        local dlg = DlgMgr:getDlgByName("PartyWarScheduleDlg")
            if data.isOpenDlg == 1 then
                dlg = DlgMgr:openDlg("PartyWarScheduleDlg")
            end

            if dlg then
                local selectInfo = dlg:getCurrentSelect()
                if selectInfo.zone == data.info[1].comp_area then
                    dlg:setDetalInfo(selectInfo.zone, selectInfo.group)
                end
            end
            --]]
        end

        return
    end

    if PARTY_TYPE.PARTY_HISTORY_PAGE_TYPE == type then
        PartyWarMgr.historyList = {}
    end

    -- 历届帮战消息
    if PARTY_TYPE.HISTORY_INFO_TYPE == type then
        for i = 1, #data.info do
            table.insert(PartyWarMgr.historyList, {no = tonumber(data.info[i].no),
                startTime  = data.info[i].start_time,
                finishTime = data.info[i].finish_time,
                champion   = data.info[i].champion})
        end
--[[
        local dlg = DlgMgr:getDlgByName("PartyWarHistoryDlg")
        if data.isOpenDlg == 1 then
            dlg = DlgMgr:openDlg("PartyWarHistoryDlg")
        end
        --]]
    end

    if PARTY_TYPE.HISTORY_DETAL_SCHEDULE_EX == type then
    --[[
        local dlg = DlgMgr:getDlgByName("PartyWarHistoryDlg")
        if data.isOpenDlg == 1 then
            dlg = DlgMgr:openDlg("PartyWarHistoryDlg")
        end
        local hisInfo = {}
        for i = 1, #data.info do
            table.insert(hisInfo, {
                stage       = data.info[i].stage,
                time        = data.info[i].time,
                defenser    = data.info[i].defenser,
                attacker    = data.info[i].attacker,
                result      = data.info[i].result})
        end
        if dlg then
            dlg:setKnockOutInfo(hisInfo)
        end
        --]]
    end
end

function PartyWarMgr:MSG_PARTY_WAR_SCORE(data)

end


function PartyWarMgr:getNewPartyWarData()
    return self.newPartyWarData
end

function PartyWarMgr:MSG_NEW_PW_COMBAT_INFO(data)
    self.newPartyWarData = data
end

function PartyWarMgr:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_PW_OPEN_WINDOW == data.notify  then
    --[[
        for _, dlgName in pairs(PartyWarTabDlg.dlgs) do
            -- 不知道为什么这边要关闭对话框，但是报名界面点刷新，关闭对话框又打开界面会闪，所以报名界面不关闭
            if dlgName == "PartyWarSignUpDlg" and data.para == "1" then

            else
                DlgMgr:closeThisDlgOnly(dlgName)
            end
        end
--]]
        if data.para == "1" then
            DlgMgr:openDlg("PartyWarSignUpDlg")

        elseif data.para == "2" then
            local dlg = DlgMgr:openDlg("PartyWarScheduleDlg")

            dlg:defaultSelect()


        elseif data.para == "3" then
            DlgMgr:openDlg("PartyWarHistoryDlg")

        end
    end
end

MessageMgr:hook("MSG_GENERAL_NOTIFY", PartyWarMgr, "PartyWarMgr")

MessageMgr:regist("MSG_NEW_PW_COMBAT_INFO", PartyWarMgr)
MessageMgr:regist("MSG_PARTY_WAR_BID_INFO", PartyWarMgr)
MessageMgr:regist("MSG_PARTY_WAR_INFO", PartyWarMgr)
MessageMgr:regist("MSG_PARTY_WAR_SCORE", PartyWarMgr)
