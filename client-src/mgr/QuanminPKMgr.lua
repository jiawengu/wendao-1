-- QuanminPKMgr.lua
-- created by songcw Mar/23/2017
-- 全民PK管理器

QuanminPKMgr = Singleton()

local MATCH_STAGE =
{
    ["64X32"] = 1,
    ["32X16"] = 2,
    ["16X8"] = 3,
    ["8X4"] = 4,
    ["4X2"] = 5,
    ["2X1"] = 6,
    ["match_end"] = 7,
}

local MATCH_TIME_STAGE =
{
    "warmup",
    "signup",
    "group1",
    "group2",
    "64X32",
    "32X16",
    "16X8",
    "8X4",
    "4X2",
    "2X1",
}

-- 重置属性
function QuanminPKMgr:cmdResetPoint(id)
    gf:CmdToServer("CMD_PKM_RESET_POINT", {id = id})
end

-- 玩家仙魔转换
function QuanminPKMgr:cmdChangeUpgrade()
    gf:CmdToServer("CMD_PKM_UPGRADE_CHANGE", {})
end

-- 生成装备
function QuanminPKMgr:cmdGenEquipment(name, blue, pink, yellow, green, black, gongming)
    gf:CmdToServer("CMD_PKM_GEN_EQUIPMENT", {name = name, blue = blue, pink = pink, yellow = yellow, green = green, black = black, gongming = gongming})
end

-- 生成宠物
function QuanminPKMgr:cmdGenPet(name)
    gf:CmdToServer("CMD_PKM_GEN_PET", {name = name})
end

-- 修改顿悟技能
function QuanminPKMgr:cmdSetDunwSkill(id, skill)
    gf:CmdToServer("CMD_PKM_SET_DUNWU_SKILL", {id = id, skill = skill})
end

-- 领取物资
function QuanminPKMgr:cmdFetchItem(itemName, count)
    gf:CmdToServer("CMD_PKM_FETCH_ITEM", {itemName = itemName, count = count})
end

-- 回收物品
function QuanminPKMgr:cmdRecycleItem(id)
    gf:CmdToServer("CMD_PKM_RECYCLE_ITEM", {id = id})
end

-- 全民PK64进16队伍信息
function QuanminPKMgr:getTo16Data()
    if not self.qmpkMatchData then
        return
    end

    local qmpkMatchData = self.qmpkMatchData

    -- 各队伍的名次
    local teamLevel = {}
    local stages = {"64X32", "32X16", "16X8"}
    for i = 1, #stages do
        local data = qmpkMatchData[MATCH_STAGE[stages[i]]] or {}
        for j = 1, #data do
            local info = data[j]
            if info and info.gid and info.gid ~= "" then
                teamLevel[info.gid] = i
            end
        end
    end

    -- 整理数据
    local result = {}
    local team64 = qmpkMatchData[MATCH_STAGE["64X32"]] or {}
    for i = 1, #team64 do
        local info = team64[i]
        table.insert(result, {no = info.id, gid = info.gid, name = self:getLeaderName(info.gid) or "", level = teamLevel[info.gid] or 0})
    end

    table.sort(result, function(l, r)
        if l.no < r.no then return true end
        if l.no > r.no then return false end
    end)

    return result
end

-- 全民PK总决赛队伍信息
function QuanminPKMgr:getFinalData()
    if not self.qmpkMatchData then
        return
    end

    local qmpkMatchData = self.qmpkMatchData

    -- 各队伍的名次
    local teamLevel = {}
    local stages = {"16X8", "8X4", "4X2", "2X1", "match_end"}

    for i = 1, #stages do
        local data = qmpkMatchData[MATCH_STAGE[stages[i]]] or {}
        for j = 1, #data do
            local info = data[j]
            if info and info.gid and info.gid ~= "" then
                teamLevel[info.gid] = i
            end
        end
    end

    -- 整理数据
    local result = {}
    local team16 = qmpkMatchData[MATCH_STAGE["16X8"]] or {}
    for i = 1, #team16 do
        local info = team16[i]
        table.insert(result, {no = info.id, gid = info.gid, name = self:getLeaderName(info.gid) or "", level = teamLevel[info.gid] or 0})
    end

    table.sort(result, function(l, r)
        if l.no < r.no then return true end
        if l.no > r.no then return false end
    end)

    return result
end

function QuanminPKMgr:getLeaderName(gid)
    if not self.qmpkTeamLeaderData then
        return
    end

    for i = 1, #self.qmpkTeamLeaderData do
        local data = self.qmpkTeamLeaderData[i]
        if gid == data.gid then
            return gf:getRealName(data.name)
        end
    end
end

-- 64进16强是否已经结束
function QuanminPKMgr:isTo16MatchFinish()
    if not self.qmpkTeamLeaderData then
        return false
    end

    local data = self.qmpkMatchData[MATCH_STAGE["16X8"]] or {}
    if #data >= 16 then
        return true
    else
        return false
    end
end

-- 64进16强是否已经开始
function QuanminPKMgr:isTo16MatchBegin()
    if not self.qmpkMatchTimeInfo then
        return
    end

    if self.qmpkMatchTimeInfo.is_match_begin == 1 then
        return true
    else
        return false
    end
end

function QuanminPKMgr:getQMPKMatchData()
    return self.qmpkMatchData
end

function QuanminPKMgr:getQMPKLeaderData()
    return self.qmpkTeamLeaderData
end

function QuanminPKMgr:getQMPKMatchTimeInfo()
    return self.qmpkMatchTimeInfo
end

function QuanminPKMgr:getMatchTimeStage()
    return MATCH_TIME_STAGE
end

function QuanminPKMgr:getTimeInfoByStage(stage)
    if not self.qmpkMatchTimeInfo then
        return
    end

    for i = 1, #self.qmpkMatchTimeInfo do
        local data = self.qmpkMatchTimeInfo[i]
        if data.stage == stage then
            return data
        end
    end
end

-- 全民PK比赛信息
function QuanminPKMgr:MSG_QMPK_MATCH_PLAN_INFO(data)
    local result = {}
    for i = 1, #data do
        local stage = data[i].stage
        result[MATCH_STAGE[stage]] = data[i]
    end

    self.qmpkMatchData = result
end

-- 全民PK参赛队长相关信息
function QuanminPKMgr:MSG_QMPK_MATCH_LEADER_INFO(data)
    self.qmpkTeamLeaderData = data
end

function QuanminPKMgr:MSG_QMPK_MATCH_TIME_INFO(data)
    self.qmpkMatchTimeInfo = data
end

function QuanminPKMgr:MSG_OPEN_QMPK_BONUS_DLG(data)
    ShiDaoMgr:setShidwzInfo(data)
    local dlg = DlgMgr:openDlgEx("ShidaowzjlDlg", SHARE_FLAG.QUANMINPKJL)
    dlg:setTitle(2, data)
end

-- 是否为全民PK赛记者（是否拥有任务（全民PK赛记者 城市PK赛记者））
function QuanminPKMgr:isQMJournalist()
    local journaTask = TaskMgr:getTaskByName(CHS[7003044])
    local cityJournaTask = TaskMgr:getTaskByName(CHS[7120158])
    if journaTask or cityJournaTask then
        return true
    end

    return false
end


MessageMgr:regist("MSG_OPEN_QMPK_BONUS_DLG", QuanminPKMgr)
MessageMgr:regist("MSG_QMPK_MATCH_PLAN_INFO", QuanminPKMgr)
MessageMgr:regist("MSG_QMPK_MATCH_LEADER_INFO", QuanminPKMgr)
MessageMgr:regist("MSG_QMPK_MATCH_TIME_INFO", QuanminPKMgr)
--MessageMgr:regist("", QuanminPKMgr)
