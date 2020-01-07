-- ShiDaoMgr.lua
-- Created by liuhb Apr/13/2015
-- 试道管理器

ShiDaoMgr = Singleton()
ShiDaoMgr.historyInfo = {}
local shidwzInfo = {}
local shidTaskInfo = nil
local kuafsdInfo = {}
local STAGE = {
    [1] = CHS[5000106],
    [2] = CHS[5000107],
}

local ROLE_INDEX =
    {
        [POLAR.METAL..GENDER_TYPE.MALE]  = 1,
        [POLAR.METAL..GENDER_TYPE.FEMALE] = 2,
        [POLAR.WOOD..GENDER_TYPE.MALE] = 3,
        [POLAR.WOOD..GENDER_TYPE.FEMALE] = 4,
        [POLAR.WATER..GENDER_TYPE.MALE] = 5,
        [POLAR.WATER..GENDER_TYPE.FEMALE] = 6,
        [POLAR.FIRE..GENDER_TYPE.MALE] = 7,
        [POLAR.FIRE..GENDER_TYPE.FEMALE] = 8,
        [POLAR.EARTH..GENDER_TYPE.MALE] = 9,
        [POLAR.EARTH..GENDER_TYPE.FEMALE] = 10,
    }


-- 根据id获取场次名字
function ShiDaoMgr:getStageNameById(id)
    return STAGE[id]
end

-- 根据事件获取详细数据
function ShiDaoMgr:getDetalByTime(time)
    if nil == ShiDaoMgr.historyInfo then
        return
    end

    return ShiDaoMgr.historyInfo[time]
end

function ShiDaoMgr:isSDJournalist()
    local journaTask = TaskMgr:getTaskByName(CHS[5400694])
    if journaTask then
        return true
    end

    return false
end

function ShiDaoMgr:MSG_SHIDAO_GLORY_HISTORY(data)
    -- 服务器发送类别   等级－时间－队伍  转化成    时间 － 等级 － 队伍


    local levelList = {}
    for i = 1, data.levelCount do
        table.insert(levelList, { level = data.levelList[i].levelBuff, timeList = {}})
    end

    local timeList = {}

    local teamInfo = {}
    -- 获取时间段
    for i = 1, data.levelCount do
        for j = 1, data.levelList[i].timeCount do
            local str = gf:getServerDate("%Y-%m-%d", data.levelList[i].timeInfo[j].time)
            table.insert(levelList[i].timeList, {timestr = str,  time = data.levelList[i].timeInfo[j].time, isMonth = data.levelList[i].timeInfo[j].isMonth})
        end
    end

    -- 等级排序
    table.sort(levelList, function(l, r)
        if l.level > r.level then return true end
        if l.level < r.level then return false end
    end)


    -- 时间段排序，最近的在第一个
    for i = 1, #levelList do
        table.sort(levelList[i].timeList, function(l, r)
            if l.time > r.time then return true end
            if l.time < r.time then return false end
        end)
    end

    -- 获取王者队伍信息
    -- 获取等级段
    local teamInfos = {}
    for i = 1, data.levelCount do
        local level = data.levelList[i].levelBuff
        for j = 1, data.levelList[i].timeCount do
            -- local str = gf:getServerDate("%Y-%m-%d", data.levelList[i].timeInfo[j].time)
            if not teamInfos[level] then teamInfos[level] = {} end
            teamInfos[level][data.levelList[i].timeInfo[j].time] = data.levelList[i].timeInfo[j]
        end
    end

    local dlg = DlgMgr:openDlg("ShidwzDlg")
    dlg:updateShidList(levelList, teamInfos)
end

-- 每单数月第二个周三的前一个周日为月道行试道
function ShiDaoMgr:isMonthTaoShiDao()
    local curTime = gf:getServerTime() - 18000 -- 5:00
    local m = tonumber(gf:getServerDate("%m", curTime))
    local w = tonumber(gf:getServerDate("%w", curTime))
    local d = tonumber(gf:getServerDate("%d", curTime))
    if w == 0 then w = 7 end

    local mDay =  gf:getThisMonthDays(curTime)
    local lastDay =  mDay - d
    if lastDay <= 2 then
        -- 下个月的第一周有周三
        return (w <= 3 - lastDay) and (m + 1) % 2 == 1
    end

    if d <= 7 and w - d <= 2 and w >= d then
        -- 第一周有周三
        return m % 2 == 1
    end

    if d > w and d - w <= 4 then
        -- 当前第二周，第一周没有周三
        return m % 2 == 1
    end

    return false
end

function ShiDaoMgr:getShiDaoTaskInfo()
    return shidTaskInfo
end

function ShiDaoMgr:MSG_SHIDAO_TASK_INFO(data)
    local dlg = DlgMgr:getDlgByName("ShidaoInfoDlg")

    if data.stageId and MapMgr:getCurrentMapName() == CHS[3004311] then
        if dlg then
            dlg:refreshInfo(data)
        else
            dlg = DlgMgr:openDlg("ShidaoInfoDlg")
            dlg:setInfo(data)
        end
    else
        -- 传递出去要关闭界面
        if dlg then
            DlgMgr:closeDlg("ShidaoInfoDlg")
        end
    end

    shidTaskInfo = data
end

-- 打开试道王者界面
function ShiDaoMgr:MSG_OPEN_SHIDWZDLG(data)
    self:setShidwzInfo(data)
    local dlg = DlgMgr:openDlgEx("ShidaowzjlDlg", SHARE_FLAG.SHIDAOWZJL)
    dlg:setTitle()
end

-- 设置试道王者数据
function ShiDaoMgr:setShidwzInfo(data)
    shidwzInfo = data
end

-- 获取试道王者数据
function ShiDaoMgr:getShidwzInfo()
    return shidwzInfo
end

-- 获取试道王者数据的人数
function ShiDaoMgr:getShidwzInfoCount()
    return shidwzInfo.count or 0
end

function ShiDaoMgr:getMRZBInfoCount()
    return self.mrzbData.count or 0
end

-- 获取试道王者数据中自己的数据
function ShiDaoMgr:getMeShidwzInfo()
    local info = self:getShidwzInfo()
    if not info or not next(info) then return end
    local meGid = Me:queryBasic("gid")
    for i = 1, info.count do
        if info[i].gid == meGid then
            return info[i]
        end
    end
end

-- 名人争霸没有自己的管理器，放在这
function ShiDaoMgr:getMeMRZBInfo()
    local info = self.mrzbData
    local meGid = Me:queryBasic("gid")
    for i = 1, info.count do
        if info[i].gid == meGid then
            return info[i]
        end
    end
end

-- 名人争霸没有自己的管理器
function ShiDaoMgr:getOtherMRZBInfo()
    local info = self.mrzbData
    local meGid = Me:queryBasic("gid")
    local arr = {}
    for i = 1, info.count do
        if info[i].gid ~= meGid then
            table.insert(arr, info[i])
        end
    end

    table.sort(arr, function(l, r)
        local lGender = gf:getGenderByIcon(l.icon)
        local rGender = gf:getGenderByIcon(r.icon)
        return ROLE_INDEX[l.polar..lGender] <  ROLE_INDEX[r.polar..rGender]
    end)

    return arr
end

-- 获取试道王者数据中别人的数据
function ShiDaoMgr:getOtherShidwzInfo()
    local info = self:getShidwzInfo()
    if not info or not next(info) then return end
    local meGid = Me:queryBasic("gid")
    local arr = {}
    for i = 1, info.count do
        if info[i].gid ~= meGid then
            table.insert(arr, info[i])
        end
    end

    table.sort(arr, function(l, r)
        local lGender = gf:getGenderByIcon(l.icon)
        local rGender = gf:getGenderByIcon(r.icon)
        return ROLE_INDEX[l.polar..lGender] <  ROLE_INDEX[r.polar..rGender]
    end)

    return arr
end

-- 是否月道行跨服试道
function ShiDaoMgr:isMonthTaoKFSD()
    return kuafsdInfo.type == KFSD_TYPE.MONTH
end

-- 打开跨服试道信息界面
function ShiDaoMgr:MSG_CS_SHIDAO_TASK_INFO(data)
    kuafsdInfo = data
    if MapMgr:isInKuafsdzc() then
        local dlg = DlgMgr:openDlg("KuafsdInfoDlg")
        if Me:isInCombat() then
            dlg:setVisible(false)
        end
    end
end

-- 打开跨服试道王者界面
function ShiDaoMgr:MSG_OPEN_CS_SHIDWZDLG(data)
    self:setShidwzInfo(data)
    local dlg = DlgMgr:openDlgEx("ShidaowzjlDlg", SHARE_FLAG.KFSDJL)
    dlg:setTitle(1, data)
end

function ShiDaoMgr:getKuafsdInfo()
    return kuafsdInfo
end

function ShiDaoMgr:isKFSDJournalist()
    local journaTask = TaskMgr:getTaskByName(CHS[7001048])
    if journaTask then
        return true
    end

    return false
end

function ShiDaoMgr:MSG_CSB_BONUS_INFO(data)
    self.mrzbData = data
    local dlg = DlgMgr:openDlgEx("ShidaowzjlDlg", SHARE_FLAG.MRZBJL)
    dlg:setTitle(3, data)
end

MessageMgr:regist("MSG_CSB_BONUS_INFO", ShiDaoMgr)  -- 名人争霸奖励
MessageMgr:regist("MSG_SHIDAO_TASK_INFO", ShiDaoMgr)
MessageMgr:regist("MSG_SHIDAO_GLORY_HISTORY", ShiDaoMgr)
MessageMgr:regist("MSG_OPEN_SHIDWZDLG", ShiDaoMgr)
MessageMgr:regist("MSG_CS_SHIDAO_TASK_INFO", ShiDaoMgr)
MessageMgr:regist("MSG_OPEN_CS_SHIDWZDLG", ShiDaoMgr)
