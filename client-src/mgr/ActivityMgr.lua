-- ActivityMgr.lua
-- created by zhengjh Mar/16/2015
-- 活动任务管理器

ActivityMgr = Singleton()

local DailyActivity = require("cfg/DailyActivity")
local LimitActivity = require("cfg/LimitActivity")
local ActivityReward = require("cfg/ActivityReward")
local FestivalActivity = require("cfg/FestivalActivity")
local OtherActivity = require('cfg/OtherActivity')
local WelfareActivity = require("cfg/WelfareActivity")
local PushActivity = require("cfg/PushActivity")

local ComingActivity = {}

local CONST_DATA =
    {
        [0] = CHS[6000110], -- 每天
        [1] = CHS[5000240], -- 日
        [2] = CHS[6000055], -- 一
        [3] = CHS[6000056], -- 二
        [4] = CHS[6000057], -- 三
        [5] = CHS[6000058], -- 四
        [6] = CHS[6000059], -- 五
        [7] = CHS[6000060], -- 六
        [8] = CHS[3000266], -- 全天开启
    }

-- 36星星怪物分布等级信息表
local STARS_36_INFO =
{
    [1] = {name = CHS[3003852], level = 30, place = CHS[3003853]},
    [2] = {name = CHS[3003854], level = 35, place = CHS[3003855]},
    [3] = {name = CHS[3003856], level = 40, place = CHS[3003857]},
    [4] = {name = CHS[3003858], level = 45, place = CHS[3003859]},
    [5] = {name = CHS[3003860], level = 50, place = CHS[3003861]},
    [6] = {name = CHS[3003862], level = 55, place = CHS[3003863]},
    [7] = {name = CHS[3003864], level = 60, place = CHS[3003865]},
    [8] = {name = CHS[3003866], level = 64, place = CHS[3003867]},
    [9] = {name = CHS[3003868], level = 68, place = CHS[3003869]},
    [10] = {name = CHS[3003870], level = 72, place = CHS[3003871]},
    [11] = {name = CHS[3003872], level = 76, place = CHS[3003873]},
    [12] = {name = CHS[3003874], level = 80, place = CHS[3003875]},
    [13] = {name = CHS[3003876], level = 84, place = CHS[3003877]},
}

-- 72地煞星星怪物分布表
local EARTH_72_INFO =
{
        [1] = {name = CHS[3003878], level = 60, place = CHS[3003879]},
        [2] = {name = CHS[3003880], level = 63, place = CHS[3003879]},
        [3] = {name = CHS[3003881], level = 66, place = CHS[3003879]},
        [4] = {name = CHS[3003882], level = 69, place = CHS[3003879]},
        [5] = {name = CHS[3003883], level = 72, place = CHS[3003879]},
        [6] = {name = CHS[3003884], level = 75, place = CHS[3003885]},
        [7] = {name = CHS[3003886], level = 78, place = CHS[3003877]},
        [8] = {name = CHS[3003887], level = 81, place = CHS[3003888]},
        [9] = {name = CHS[3003889], level = 84, place = CHS[3003890]},
}

-- 妖王怪物分布  lich  巫妖
local LICH_INFO =
{
    [1] = {name = CHS[3003891], level = 20, place = CHS[3003892], icon = 06215},
    [2] = {name = CHS[3003893], level = 30, place = CHS[3003894], icon = 06214},
    [3] = {name = CHS[3003895], level = 40, place = CHS[3003896], icon = 06203},
    [4] = {name = CHS[3003897], level = 50, place = CHS[3003898], icon = 06209},
    [5] = {name = CHS[3003899], level = 60, place = CHS[3003900], icon = 06210},
    [6] = {name = CHS[3003901], level = 70, place = CHS[3003902], icon = 06208},
    [7] = {name = CHS[3003903], level = 80, place = CHS[3003904], icon = 06207},
    [8] = {name = CHS[3003905], level = 90, place = CHS[3003906], icon = 06241},
    [9] = {name = CHS[6000381], level = 100, place = CHS[6000383], icon = 06259},
    [10] = {name = CHS[6000382], level = 110, place = CHS[6000384], icon = 06277},
    [11] = {name = CHS[7002278], level = 120, place = CHS[7002279], icon = 06278},
    [12] = {name = CHS[7190101], level = 130, place = CHS[7190102], icon = 06280},
}

-- 帮派任务总次数加成
ActivityMgr.partyTaskAdd = 0

-- 双倍经验加成的活动
ActivityMgr.doubleActvies = {
    -- 双倍经验
    [CHS[5400523]] = {
        [CHS[6000106]] = true, -- 师门任务
        [CHS[4100328]] = true, -- 【修炼】修行
        [CHS[4100329]] = true, -- 【修炼】十绝阵
        [CHS[4200287]] = true, -- 除暴任务
        [CHS[2200010]] = true, -- 通天塔
        [CHS[2200009]] = true, -- 副本
        [CHS[2200011]] = true, -- 助人为乐
        [CHS[4200285]] = true, -- 悬赏任务
    },

    -- 随机经验翻倍
    [CHS[4100285]] = {} -- 由服务端通知双倍的活动
}

-- 活动额外数据
local activityExtraInfo = {}

function ActivityMgr:init()
    self:preProcessActivityData(0, DailyActivity)
    self:preProcessActivityData(100, LimitActivity)
    self:preProcessActivityData(200, OtherActivity)
    self:preProcessActivityData(400, FestivalActivity)
    self:preProcessActivityData(500, WelfareActivity)
end

function ActivityMgr:preProcessActivityData(sIndex, activityData)
    for i = 1, #activityData do
        activityData[i].index = sIndex + i
    end
end

function ActivityMgr:getStarsActivityInfo(type)
    if type == CHS[6000108] then
        return STARS_36_INFO
    elseif type == CHS[6000109] then
        return EARTH_72_INFO
    elseif type == CHS[3003907] then
        return LICH_INFO
    end
end

-- 活动奖励类型是否包含 rewardType
function ActivityMgr:isRewardMeetCondition(reward, rewardType)
    if not rewardType then
        -- 未指定奖励类型，默认满足条件
        return true
    elseif ACTIVITY_REWARD_TYPE.EXP == rewardType and string.find(reward, CHS[7120160]) then
        -- 经验
        return true
    elseif ACTIVITY_REWARD_TYPE.TAO_AND_MARTIAL == rewardType
        and (string.find(reward, CHS[7120161]) or string.find(reward, CHS[7120162])
        or string.find(reward, CHS[7120166])) then
        -- 道行/武学/道武
        return true
    elseif ACTIVITY_REWARD_TYPE.ITEM == rewardType and string.find(reward, CHS[7120163]) then
        -- 道具
        return true
    elseif ACTIVITY_REWARD_TYPE.EQUIP == rewardType
        and (string.find(reward, CHS[7120164]) or string.find(reward, CHS[7120165])) then
        -- 道具
        return true
    end
end

function ActivityMgr:getDailyActivity(rewardType)
    local dailyActivity = {}

    for i, act in pairs(DailyActivity) do
        if act["level"] <= Me:queryBasicInt("level")
            and self:isRewardMeetCondition(act["reward"], rewardType) then
            table.insert(dailyActivity, act)
        end
    end

    self:sortDailyActivity(dailyActivity)
    return dailyActivity
end

function ActivityMgr:checkLimitActCanShow(limitAct, getAllLimitActivity, isGetByPush, isMonthTao)
        if getAllLimitActivity or (Me:queryBasicInt("level") ~=0 and limitAct["level"] <= Me:queryBasicInt("level")) then
            if limitAct["endTime"] or limitAct["startTime"] then
                local curTime = gf:getServerDate(CHS[7190180], gf:getServerTime())
                if DistMgr:curIsTestDist() and (limitAct["testEndTime"] or limitAct["testStartTime"]) then
                    if (limitAct["testEndTime"] and limitAct["testEndTime"] < curTime)
                        or (limitAct["testStartTime"] and limitAct["testStartTime"] > curTime) then
                        return false
                    end
                else
                    if (limitAct["endTime"] and limitAct["endTime"] < curTime)
                        or (limitAct["startTime"] and limitAct["startTime"] > curTime) then
                        return false
                    end
                end
            end

            if (isMonthTao and limitAct["name"] == CHS[5450332])
                or (not isMonthTao and limitAct["name"] == CHS[5450336]) then
                --  试道大会与月道行试道大会只能开一个
                return
            end

            -- WDSY-30594 修改 dateFromServer
            if not limitAct["dateFromServer"] then
                if limitAct["actitiveDate"] == "10" then -- 活动进行某个时间段
                    if self:isFestivalStart(limitAct["activityOpenTime"]) or getAllLimitActivity then
                        return true
                    end
                elseif limitAct["actitiveDate"] == "12" then -- 活动进行某个时间段
                    local startTime = self:getActivityStartTimeByMainType(limitAct["mainType"])
                    if startTime and not isGetByPush then
                        return true
                    end
                else
                    return true
                end
            else
                -- 没有配置actitiveData，代表由服务器决定活动开启时间
                -- 目前没有配置actitiveData的活动都是周活动
                local weekActInfo = self:getWeekActivityInfo()

                limitAct.activityTime[1][1] = limitAct.activityTime[1]["cache"] or limitAct.activityTime[1][1] -- WDSY-30594 修改
                if weekActInfo and limitAct.mainType then
                    local dateList = self:getWeekActivityDate(limitAct.mainType)
                    local dateStr = ""
                    local dateStrInCh = ""
                    for i = 1, #dateList do
                        local date = dateList[i]
                        if i == #dateList then
                            dateStr = dateStr .. date
                            dateStrInCh = dateStrInCh .. CHS[6000112] .. CONST_DATA[date]
                        else
                            dateStr = dateStr .. date .. ","
                            dateStrInCh = dateStrInCh .. CHS[6000112] .. CONST_DATA[date] .. CHS[7002070]
                        end
                    end

                    if dateStr ~= "" and dateStrInCh ~= "" then
                        -- 这周本活动开启了
                        limitAct.actitiveDate = dateStr
                        limitAct.activityTime[1]["cache"] = limitAct.activityTime[1]["cache"] or limitAct.activityTime[1][1]
                        limitAct.activityTime[1][1] = dateStrInCh .. limitAct.activityTime[1][1]
                        return true
                    end
                end
            end
        end
end

-- 区别于 getLimitActivity 没有排序和复制表
function ActivityMgr:getLimitActivityEx(getAllLimitActivity, isGetByPush)
        -- getAllLimitActivity:获取所有限时活动，不包括本周没有开启的周活动
    local limitActivity = {}

    local isMonthTao = ShiDaoMgr:isMonthTaoShiDao()
    for i, act in pairs(LimitActivity) do
        if self:checkLimitActCanShow(act, getAllLimitActivity, isGetByPush, isMonthTao) then
            table.insert(limitActivity, act)
        end
    end

    return limitActivity
end

function ActivityMgr:getLimitActivity(getAllLimitActivity, isGetByPush, rewardType)
    -- getAllLimitActivity:获取所有限时活动，不包括本周没有开启的周活动
    local limitActivity = {}

    local isMonthTao = ShiDaoMgr:isMonthTaoShiDao()
    for i, act in pairs(LimitActivity) do
        local limitAct = gf:deepCopy(act)
        if self:checkLimitActCanShow(limitAct, getAllLimitActivity, isGetByPush, isMonthTao)
            and self:isRewardMeetCondition(limitAct["reward"], rewardType)  then

            if limitAct["mainType"] == "good_voice" then
                local startTime = self:getActivityStartTimeByMainType(limitAct["mainType"])
                if startTime then
                    -- 这边转换是兼容以前的格式
                    limitAct["activityTime"][1][1] = self:getFullTimeStr(startTime["startTime"]) .. "-" .. self:getFullTimeStr(startTime["endTime"])
                end
            end

            table.insert(limitActivity, limitAct)
        end
    end

    self:sortLimitActivity(limitActivity)
    return limitActivity
end

-- 获取某个限时活动的数据
function ActivityMgr:getLimitActivityDataByName(name, notCopy)
    local data = nil
    local limitActivity
    if notCopy then
        limitActivity = LimitActivity
    else
        limitActivity = self:getLimitActivity(true)
    end

    for i, act in pairs(limitActivity) do
        if act["name"] == name then
            data = act
        end
    end

    return data
end

function ActivityMgr:isQQLinkOpen()
    -- 未配置跳转链接或是评审区组，则不开放
    if gf:isNullOrEmpty(self.qqLinkAddr) or GameMgr.isIOSReview or not gf:isIos() then return end

    if self:getStartTimeList() then
        local startTime = self:getActivityStartTimeByMainType("qq_cooperation")
        if startTime then
            -- 这边转换是兼容以前的格式
            local activityTime = self:getFullTimeStr(startTime["startTime"]) .. "-" .. self:getFullTimeStr(startTime["endTime"])
            if self:isFestivalStart(activityTime) then
                return true
            end
        end
    end
end

function ActivityMgr:getOtherActivityDataByName(name)
    local data = nil
    for i, act in pairs(OtherActivity) do
        if act["name"] == name then
            data = act
        end
    end

    return data
end

function ActivityMgr:getSpcialActiveCondiction(act)
    -- 特殊
    if act["name"] == CHS[4200709] and HomeChildMgr:getChildenCount() <= 0 then
        return false
    end

    return true
end

function ActivityMgr:getOhterActivityData(rewardType)
    local otherActivity = {}

    for i, act in pairs(OtherActivity) do
        if Me:queryBasicInt("level") ~=0 and act["level"] <= Me:queryBasicInt("level")
            and ((CHS[2200018] == act["name"] and self:isQQLinkOpen()) or CHS[2200018] ~= act["name"])
            and (act["name"] ~= CHS[7190182] or InnMgr:isInnActivityOpen())
            and (not act["isLimitActivity"] or (act["mainType"] and self:setOtherActivityTime(act)))
            and self:isRewardMeetCondition(act["reward"], rewardType)
            and ActivityMgr:getSpcialActiveCondiction(act) then

            if act.isOnlyTest and not DistMgr:curIsTestDist() then
            else
                table.insert(otherActivity, act)
            end

        end

        if self:isFinishActivity(act) then
            act.order = 1
        elseif act.times == 0 then
            act.order = 2
        else
            act.order = 3
    end

    end

    self:sortOtherActivity(otherActivity)
    return otherActivity
end


function ActivityMgr:sortOtherActivity(dailyActivity)
    local function dailyActivySort(a, b)
        local lOrder = a.order
        local rOrder = b.order
        if lOrder > rOrder then return true end
        if lOrder < rOrder then return false end
        return a["index"] < b["index"]
    end

    table.sort(dailyActivity, dailyActivySort)
end

function ActivityMgr:getPushActivity()
    local activity =  self:getLimitActivity(nil, true)
    local OtherActivity = self:getOhterActivityData()
    for i = 1, #OtherActivity do
        table.insert(activity, OtherActivity[i])
    end

    local act
    for i = 1, #PushActivity do
        act = PushActivity[i]
        if Me:queryBasicInt("level") ~=0 and act["level"] <= Me:queryBasicInt("level") then
            table.insert(activity, act)
        end
    end

    return activity
end

function ActivityMgr:initComingActivityData(rewardType)
    ComingActivity = {}
    local meLevel = Me:queryBasicInt("level")
    local maxActivityLevel = math.max(50, meLevel + 10)

    for i, act in pairs(DailyActivity) do
        local actLevel = act["level"]
        if actLevel > meLevel and actLevel <= maxActivityLevel
            and self:isRewardMeetCondition(act["reward"], rewardType) then
            table.insert(ComingActivity, act)
        end
    end

    local limitActivity = self:getLimitActivity(true)
    for i, act in pairs(limitActivity) do
        local actLevel = act["level"]
        if actLevel > meLevel and actLevel <= maxActivityLevel
            and self:isRewardMeetCondition(act["reward"], rewardType) then
            table.insert(ComingActivity, act)
        end
    end

    for i, act in pairs(OtherActivity) do
        local actLevel = act["level"]
        if (act["name"] ~= CHS[7190182] or InnMgr:isInnActivityOpen()) and actLevel > meLevel and actLevel <= maxActivityLevel
            and (not act["isLimitActivity"] or (act["mainType"] and self:setOtherActivityTime(act)))
            and self:isRewardMeetCondition(act["reward"], rewardType) then
            table.insert(ComingActivity, act)
        end
    end
end

function ActivityMgr:getComingActivity(rewardType)
    self:initComingActivityData(rewardType)

    table.sort(ComingActivity, function(a, b)
        if a["level"] == b["level"]  then
            return  a["index"] < b["index"]
        else
            return  a["level"] < b["level"]
        end
      end)
    return ComingActivity
end

function ActivityMgr:sortDailyActivity(dailyActivity)
    local function dailyActivySort(a, b)
        if self:isFinishActivity(a) == self:isFinishActivity(b) then
            -- 由于要将十绝阵与修行任务并列，因此排序方法需要特殊处理

            return a["index"] < b["index"]
        else
            return self:isFinishActivity(b)
        end
    end

    table.sort(dailyActivity, dailyActivySort)
end


function ActivityMgr:getFestivalActivity(onlyStart, rewardType)
    local festivalActivity = {}

    if self:getStartTimeList() then
        for i, act in pairs(FestivalActivity) do
            local startTime = self:getActivityStartTimeByMainType(act["mainType"])
            if startTime then
                -- 这边转换是兼容以前的格式
                act["activityTime"][1][1] = self:getFullTimeStr(startTime["startTime"]) .. "-" .. self:getFullTimeStr(startTime["endTime"])
                local seconds = self:getBeforeStartTime(act["beforeStartTime"])
                act["activityOpenTime"] = self:getFullTimeStr(startTime["startTime"] - seconds) .. "-" .. self:getFullTimeStr(startTime["endTime"])

                if onlyStart then
                    -- 只获取已开启的活动
                    local curTime = gf:getServerTime()
                    if curTime >= startTime["startTime"] and curTime < startTime["endTime"]
                        and self:isRewardMeetCondition(act["reward"], rewardType) then
                        table.insert(festivalActivity, act)
                    end
                elseif self:isFestivalStart(act["activityOpenTime"])
                    and self:isRewardMeetCondition(act["reward"], rewardType) then
                    table.insert(festivalActivity, act)
                end
            end
        end
    end

    self:sortDailyActivity(festivalActivity)
    return festivalActivity
end

function ActivityMgr:getWelfareActivity(rewardType)
    local welfareActivity = {}

    if self:getStartTimeList() then
        for i, act in pairs(WelfareActivity) do
            local startTime = self:getActivityStartTimeByMainType(act["mainType"])
            if startTime then
                -- 这边转换是兼容以前的格式
                act["activityTime"][1][1] = self:getFullTimeStr(startTime["startTime"]) .. "-" .. self:getFullTimeStr(startTime["endTime"])
                local seconds = self:getBeforeStartTime(act["beforeStartTime"])
                act["activityOpenTime"] = self:getFullTimeStr(startTime["startTime"] - seconds) .. "-" .. self:getFullTimeStr(startTime["endTime"])
                if self:isFestivalStart(act["activityOpenTime"])
                    and self:isRewardMeetCondition(act["reward"], rewardType) then
                    table.insert(welfareActivity, act)
                end
            end
        end
    end

    self:sortDailyActivity(welfareActivity)
    return welfareActivity
end

function ActivityMgr:getBeforeStartTime(timeStr)
    local timeList = gf:split(timeStr, ":")
    local hours = tonumber(timeList[1])
    local minute = tonumber(timeList[2])
    if hours and minute then
        return (hours * 60 + minute) * 60
    end
end

-- 时间文本格式如（2016年04月28日11:00:00）
function ActivityMgr:getFullTimeStr(time)
    local yearStr = gf:getServerDate("*t", time)["year"] .. CHS[4000161]
    local fullTiemStr = yearStr .. gf:getServerDate(CHS[6000234], time)
    return fullTiemStr
end

function ActivityMgr:getActivityStartTimeByMainType(mainType)
    local startTimeList = self:getStartTimeList()
    if not startTimeList then return end
    return  startTimeList["activityList"][mainType]
end

-- 获取节日开启的时间列表
function ActivityMgr:getStartTimeList()
    return self.activtyStartTimeList
end

-- 节日列表的开启和结束时间信息
function ActivityMgr:MSG_ACTIVITY_LIST(data)
    -- 如果之前有2019寒假任务 赏雪吟诗，之后结束了，需要去除地图下雪效果
    if self.activtyStartTimeList and self.activtyStartTimeList.activityList and self.activtyStartTimeList.activityList["winter_day_2019_sxys"] then
        if not data.activityList["winter_day_2019_sxys"] or gf:getServerTime() < data.activityList["winter_day_2019_sxys"].startTime then
            WeatherMgr:clearMapWeatherById(18000)
            WeatherMgr:clearMapWeatherById(19000)
            WeatherMgr:clearMapWeatherById(1000)

            if MapMgr:isInMapById(18000) or MapMgr:isInMapById(19000) or MapMgr:isInMapById(1000) then
                WeatherMgr:removeWeather()
            end

            self.winter_day_2019_sxys = false
        end
    end

    self.activtyStartTimeList = data

    -- 2019寒假活动，部分地图要下雪
    if data.activityList and data.activityList["winter_day_2019_sxys"] then
        -- 防止时间误差，加上10s
        if gf:getServerTime() + 10 > data.activityList["winter_day_2019_sxys"].startTime and gf:getServerTime() < data.activityList["winter_day_2019_sxys"].endTime then
            if not self.winter_day_2019_sxys then
                WeatherMgr:addMapWeatherById(18000, "xue", true)  -- 东昆仑
                WeatherMgr:addMapWeatherById(19000, "xue", true)  -- 碧游宫
                WeatherMgr:addMapWeatherById(1000, "xue", true)   -- 揽仙镇
                WeatherMgr:addMapWeatherById(19002, "xue", true)   -- 雪域冰原
                self.winter_day_2019_sxys = true
            end
        end
    end
end

function ActivityMgr:CMD_ACTIVITY_LIST()
    gf:CmdToServer("CMD_ACTIVITY_LIST")
end


-- 是否有指定节日活动在进行
function ActivityMgr:isHaveFestivalStartByName(actName)
    local list = self:getFestivalActivity()
    for i = 1, #list do
        local timeStr = list[i]["activityTime"][1][1]
        if  self:isFestivalStart(timeStr) and list[i].name == actName then
            return true
        end
    end

    return false
end

-- 是否有节日活动在进行
function ActivityMgr:isHaveFestivalStart()
    local list = self:getFestivalActivity()
    for i = 1, #list do
        local timeStr = list[i]["activityTime"][1][1]
        if  self:isFestivalStart(timeStr) then
            return true
        end
    end

    return false
end

-- 是否有福利活动在进行
function ActivityMgr:isHaveWelfareStart()
    local list = self:getWelfareActivity()
    for i = 1, #list do
        local timeStr = list[i]["activityTime"][1][1]
        if  self:isFestivalStart(timeStr) then
            return true
        end
    end

    return false
end

function ActivityMgr:isFestivalStart(timeStr)
	local time = gf:getServerTime()
    local timeList = gf:split(timeStr, "-")

    local startTime = self:spliteTimeData(timeList[1])
    local endTime = self:spliteTimeData(timeList[2])

    if startTime.year and endTime.year then
       if os.time(startTime) <= time and os.time(endTime) >= time then
            return true
       end
    end

    return false
end

function ActivityMgr:spliteTimeData(timeStr)
    local data = {}
    data.year, data.month, data.day, data.hour, data.min, data.sec = string.match(timeStr, CHS[3004437])
    return data
end

function ActivityMgr:getDailyActivityWight(activity)
    local wight = 0
end

-- 获取活动本周最多可活动奖励天数
function ActivityMgr:getActivityWeekCanRewardDays(name)
    local activityCfg = self:getActivityByName(name)
    if activityCfg and activityCfg["weekCanRewardDays"] then
        return activityCfg["weekCanRewardDays"]
    end
end

-- 本周是否完成某活动，处理配置有weekCanRewardDays字段的活动
-- 当前已完成天数，大于可获得奖励天数，则认为该活动已完成
function ActivityMgr:isCompleteThisWeek(data)
    local weekCanRewardDays = ActivityMgr:getActivityWeekCanRewardDays(data["name"])
    if weekCanRewardDays and ActivityMgr:getActivityCurDayTimes(data["name"]) >= weekCanRewardDays then
        return true
    end

    return false
end

function ActivityMgr:isFinishActivity(data)
    local isFinshed = false

    if data["name"] == CHS[3000713] then
        -- 镖行万里一周之内可以完成三次
        -- 每天只要完成一次就算完成
        -- 在完成第三天的第一次时每周的完成次数就是 3，所以按理说客户端就会认为是完成
        -- 但是策划要求在第三天完成第一次时，不能认为是完成
        -- 所以需要特殊判断：如果今天是第三天，并且今天已经完成过一次任务，并且今天活动时间已经过了，则认为完成
    if ActivityMgr:isCompleteThisWeek(data) then
            if ActivityMgr:getActivityCurDayTimes(data["name"]) == ActivityMgr:getActivityWeekCanRewardDays(data["name"]) and
                self:getActivityCurTimes(data["name"]) > 0 then
                local curAct = ActivityMgr:isCurActivity(data)
                if curAct[1] == false then
                    -- 不在活动中
        isFinshed = true
                else
                    if self:getActivityCurTimes(data["name"]) >= data["times"] then
                        -- 在活动中，并且已经达到今日上限
                        isFinshed = true
                    else
                        isFinshed = false
                    end
                end
            else
                isFinshed = true
            end
        else
            if self:getActivityCurTimes(data["name"]) >= data["times"] then
                isFinshed = true
            else
                isFinshed = false
            end
        end
    elseif ActivityMgr:isCompleteThisWeek(data) then
        isFinshed = true
    elseif self:getActivityCurTimes(data["name"]) >= data["times"] and data["times"] == 0 then
        isFinshed = false
    elseif self:getActivityCurTimes(data["name"]) >= data["times"] and data["times"] ~= -1 then
        isFinshed = true
    elseif self.doubleActvies[data["name"]] then
        -- 双倍活动
        isFinshed = true
        for act, _ in pairs(self.doubleActvies[data["name"]]) do
            local actData = self:getActivityByName(act)
            if actData and not self:isFinishActivity(actData) then
                isFinshed = false
                break
            end
        end
    end

    return isFinshed
end

function ActivityMgr:sortLimitActivity(limitActivity)
    local activityState = {}
    local todayActivity = {}
    local function limitActivitysort(a, b)
        local aIsFinish = self:isFinishActivity(a)
        local bIsFinish = self:isFinishActivity(b)
        if aIsFinish ~= bIsFinish then return bIsFinish end

        if not aIsFinish then
        if activityState[a.name][1] ~= activityState[b.name][1] then return activityState[a.name][1] end

        if not activityState[a.name][1] and todayActivity[a.name] ~= todayActivity[b.name] then return todayActivity[a.name] end
        end

        if a["level"] < b["level"] then return true end
        if a["level"] > b["level"] then return false end

        if a["index"] < b["index"] then return true end
        if a["index"] > b["index"] then return false end

        return false
                end

    -- 先计算好活动的开启状态，避免因为实时计算导致排序异常
    local activity
    for i = 1, #limitActivity do
        activity = limitActivity[i]
        activityState[activity.name] = self:isCurActivity(activity)
        todayActivity[activity.name] = self:isActivityToday(activity)
    end

    table.sort(limitActivity,limitActivitysort)

end

-- 周几 格式  2,3   1是代表星期天
function ActivityMgr:isActivityToday(data)
   local isToday = false
   local time = gf:getServerTime()
   local weekDayList = gf:split(data["actitiveDate"], ",")
   local curWeek = gf:getServerDate("*t",time)["wday"]

   for i = 1,#weekDayList do
        if curWeek == tonumber(weekDayList[i]) then  -- 星期几
            isToday = true
            break
        elseif tonumber(weekDayList[i]) == 12 then     -- 服务器通知，肯定是开启了
            isToday = true
            break
        elseif tonumber(weekDayList[i]) == 0 or tonumber(weekDayList[i]) == 8  or tonumber(weekDayList[i]) ==  9 or tonumber(weekDayList[i]) == 10 then     --每天，全天,每小时
            isToday = true
            break
       end
   end

   return isToday
end

function ActivityMgr:setOtherActivityTime(data)
    local startTime = self:getActivityStartTimeByMainType(data.mainType)
    if startTime then
        data["activityTime"][1][1] = self:getFullTimeStr(startTime["startTime"])
            .. "-" .. self:getFullTimeStr(startTime["endTime"])

        local curTime = gf:getServerTime()
        return (curTime < startTime["endTime"]) and (curTime > startTime["startTime"])
    end

    return false
end

function ActivityMgr:isOpenActivity(data)
    if self.activtyStartTimeList and self.activtyStartTimeList.activityList and self.activtyStartTimeList.activityList[data.mainType] then
        local actData = self.activtyStartTimeList.activityList[data.mainType]

        if data.mainType == "cs_mon_league" then
            -- 月跨服提前半小时显示前往
            return (gf:getServerTime() < actData.endTime) and (gf:getServerTime() > actData.startTime - 60 * 30)
        else
            return (gf:getServerTime() < actData.endTime) and (gf:getServerTime() > actData.startTime)
        end


    end
end

-- 时间段格式 如20:00-22:00,16:00-18:00
function ActivityMgr:isCurActivity(data)
    local iSCurTime = false
    local time = gf:getServerTime()
    local hoursList = data["activityTime"]
    local index = 1
    local startM, endM = self:getActivityNewTime(data["name"])

    if self:isActivityToday(data) then
        if data["actitiveDate"] == "8" or data["actitiveDate"] == "10" then        -- 全天
            iSCurTime =true
        elseif data["actitiveDate"] == "9" then  -- 每小时
            if not startM or not endM then
                startM, endM = string.match(hoursList[1][1], "(%d+)-(%d+)")
            end

            local curMin = gf:getServerDate("*t", time)["min"]
            if startM and curMin >= tonumber(startM) and curMin < tonumber(endM) then
                iSCurTime = true
            end
        elseif data["actitiveDate"] == "12" then
      --      if gf:getServerTime()
            iSCurTime = ActivityMgr:isOpenActivity(data)
        else
            iSCurTime, index = self:getActivityIsCurTime(hoursList, startM, endM)
        end
    end

    return {iSCurTime, index}
end

-- 获取从服务端获取的活动的最新的开始与结束时间（分钟）
function ActivityMgr:getActivityNewTime(name)
    local startM, endM
    if type(self.activityStatus) == "table" and type(self.activityStatus[name]) == "table" then
        local startTime = self.activityStatus[name].startTime
        local endTime = self.activityStatus[name].endTime
        if startTime and endTime then
            startM = gf:getServerDate("*t", startTime)["hour"] * 60 + gf:getServerDate("*t", startTime)["min"]
            endM = gf:getServerDate("*t", endTime)["hour"] * 60 + gf:getServerDate("*t", endTime)["min"]
        end
    end

    return startM, endM
end

-- 当前时间是否处于活动开启的某个时间段
function ActivityMgr:getActivityIsCurTime(hoursList, startMin, endMin)
    local iSCurTime = false
    local index = 1
    local time = gf:getServerTime()

    for i = 1,#hoursList do
        local startH, startM, startS, endH, endM, endS = string.match(hoursList[i][1], "(%d+):(%d+):*(%d*)-(%d+):(%d+):*(%d*)")
        if startH ~= nil then
            if startS == "" then startS = 0 end
            if endS == "" then endS = 0 end

            -- 本地配置的时间
            local startMinLocal = tonumber(startH) * 60 + tonumber(startM) + tonumber(startS) / 60
            local endMinLocal = tonumber(endH) * 60 + tonumber(endM) + tonumber(endS) / 60

            if  not startMin or not endMin or not (startMin >= startMinLocal and endMin <= endMinLocal) then
                startMin = startMinLocal
                endMin = endMinLocal
            end

            local dateInfo = gf:getServerDate("*t", time)
            local curMin = dateInfo["hour"] * 60 + dateInfo["min"] + dateInfo["sec"] / 60
            if curMin >= startMin and curMin < endMin then
                index = i
                iSCurTime = true
                break
            end
    end
    end

    return iSCurTime, index
end

-- 本周的某周活动是否已经结束的状态（目前仅用于周活动，按照本周此周活动的最后一场计算）
function ActivityMgr:isWeekActivityFinish(data)
    local nowTime = gf:getServerTime()
    local weekActivityFinishTime = ActivityMgr:getWeekActivityFinishTime(data)
    local weekFinishTime = PartyMgr:nextMondayFive(nowTime)
    if nowTime > weekActivityFinishTime and nowTime < weekFinishTime then
        return true
    end
end

-- 获取本周的某周活动结束时间（按照最后一场计算）
function ActivityMgr:getWeekActivityFinishTime(data)
    local time = gf:getServerTime()
    local weekDayList = gf:split(data["actitiveDate"], ",")
    local timeList = gf:getServerDate("*t", time)
    local lastDay = 0
    for i = 1, #weekDayList do
        if tonumber(weekDayList[i]) > lastDay then
            lastDay = tonumber(weekDayList[i])
        end
    end

    local hourList = data.activityTime[1][1]
    local startH, startM, endH, endM = string.match(hourList, "(%d+):(%d+)-(%d+):(%d+)")

    -- 计算一下周活动结束是在几号
    local today = timeList["wday"]
    if (today == 1) or (today == 2 and timeList["hour"] < 5) then
        -- 这周的周天         /  下一周的周一05:00之前（仍然算作这周）
        today = today + 7
    end

    timeList.day = timeList.day + lastDay -  today
    timeList.wday = lastDay
    timeList.hour = endH
    timeList.min = endM
    timeList.sec = 0

    return gf:getTimeByServerZone(timeList)
end

function ActivityMgr:getDayText(data)
    local text = CHS[6000112]
    local weekDayList = gf:split(data["actitiveDate"], ",")
    local time = gf:getServerTime()
    local weekDay = gf:getServerDate("*t", time)["wday"]
    for i = 1,#weekDayList do
        if weekDayList[i] == "0" then         -- 每天
            text = CONST_DATA[0]
        elseif weekDayList[i] == "8" then     -- 全天
            text = CONST_DATA[8]
        elseif weekDayList[i] == "9" then    -- 每小时
            text = CHS[3003908]
        elseif weekDayList[i] == "12" then    -- 今天
            local timeList = self:getStartTimeList()
            if timeList.activityList[data.mainType] then
                text = CHS[4300283]	-- 今日
            end
        else
            -- 获取显示时间的天数
            if weekDay == tonumber(weekDayList[i]) then  -- 今天
                if self:isCurActivity(data)[1] == false and self:getNearlyTime(data) ~= ""
                    or self:isCurActivity(data)[1] then
                    text = CHS[7100214]
                end

                break
            end
        end
    end

    -- 如果都没找到找最近的时间
    if text == CHS[6000112] then
        local nearDay = tonumber(self:getNearlyWDay(data))
        if nearDay == weekDay then
            text = CHS[7100214]
        else
            text = text .. CONST_DATA[nearDay]
        end
    end

    return text
end

function ActivityMgr:getNearlyWDay(data)
    local time = gf:getServerTime()
    local curDay = gf:getServerDate("*t",time)["wday"]
    local weekDayList = gf:split(data["actitiveDate"], ",")
    for i = 1, 6 do
        for j = 1, #weekDayList do
            local wday = (curDay + i ) % 7
            if wday == 0 then
                wday = 7
            end
            if wday == tonumber(weekDayList[j]) then
                return wday
            end
        end
    end

    return curDay
end

function ActivityMgr:getLeftMin(data)
    local time = gf:getServerTime()
    local min = 0

    if string.match(data[1], "(%d+):(%d+)-(%d+):(%d+)") then  -- 每天
        local startH, startM, endH, endM = string.match(data[1], "(%d+):(%d+)-(%d+):(%d+)")
        if startH ~= nil then
            local startMin = startH * 60 + startM
            local endMin = endH * 60 + endM
            local curMin = gf:getServerDate("*t",time)["hour"] * 60 + gf:getServerDate("*t",time)["min"]
            min = endMin - curMin
        end
    else -- 每小时
        local startM, endM = string.match(data[1], "(%d+)-(%d+)")
        if startM then
            local curMin = gf:getServerDate("*t",time)["min"]
            min = tonumber(endM) - curMin
        end
    end

    return min
end

-- 获取当前即将开启的时间
function ActivityMgr:getDuringTime(data)
    local text = ""
    if data["activityTime"] then
        for i = 1, #data["activityTime"] do
            text = text .. data["activityTime"][i][1]
            text = text .. "\n"
        end
    end

    return text
end

function ActivityMgr:getNearlyTime(data)
    local hoursList = data["activityTime"]
    local time = gf:getServerTime()
    local text = ""
    for i = 1,#hoursList do
        local startH, startM, endH, endM = string.match(hoursList[i][1], "(%d+):(%d+)-(%d+):(%d+)")
        if startH then
            local startMin = startH * 60 + startM
            local endMin = endH * 60 + endM
            local curMin = gf:getServerDate("*t",time)["hour"] * 60 + gf:getServerDate("*t",time)["min"]
            if curMin < startMin then
                text =  string.match(hoursList[i][1], "(%d+:%d+)-(%d+):(%d+)")
                break
            end
        end
    end

    return text
end

-- 获取当前即将开启的时间
function ActivityMgr:getTimeText(data)
    local text = ""
    local hoursList = data["activityTime"]
    local time = gf:getServerTime()
    if self:isActivityToday(data) then
        text = self:getNearlyTime(data)

        if text == "" then
            text =  string.match(hoursList[1][1], "(%d+:%d+)-(%d+):(%d+)") or ""
        end
    else
        for i = 1,#hoursList do
            local startH, startM, endH, endM = string.match(hoursList[i][1], "(%d+):(%d+)-(%d+):(%d+)")
            if startH then
                text = string.match(hoursList[i][1], "(%d+:%d+)-(%d+):(%d+)")
                break
            end
        end

    end

   --[[ for i = 1,#hoursList do
        text = text..hoursList[i][1]
        if #hoursList ~= i then
            text = text..CHS[6000084]
        end
    end]]

    return text
end

function ActivityMgr:getActivityReward()
    return ActivityReward
end

-- 获取活跃度的信息
function ActivityMgr:getReward(key)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_LIVENESS_BONUS, key)
end

-- 领取奖励
function ActivityMgr:getActiviInfo()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_GET_LIVENESS_INFO)
end

-- 获取活动的额外数据
function ActivityMgr:getActivityExtraInfo(actName)
    if not activityExtraInfo.extraInfo then
        return nil
    end

    return activityExtraInfo.extraInfo[actName]
end

-- 活动界面信息
function ActivityMgr:MSG_LIVENESS_INFO(data)
	self.activityCurTimes = {}
	self.rewardStatus = {}
	self.activityStatus = {}
	self.allActivity = 0

	for i = 1, data["activityCount"] do
        self.activityCurTimes[data[i]["name"]] = data[i]

                if string.match(data[i]["name"], "十绝阵") then
            -- 十绝阵和修行共用一个活跃度，所以不用加
        else
            self.allActivity = self.allActivity + data[i]["activeValue"]
        end

        -- 服务器修改开启时间显示
        if data[i].timeStr ~= "" then
            local actInfo = json.decode(data[i].timeStr)
            if actInfo.type == "limit" then
                for _, act in pairs(LimitActivity) do
                    if act.mainType == data[i].name then
                        if actInfo.duration then
                            act.activityTime[1][1] = actInfo.duration
	end

                        if actInfo.desc then
                            act.desc = actInfo.desc
                        end

                        if actInfo.auto_walk then
                            act.activityTime[1][3] = actInfo.auto_walk
                        end
                    end
                end
            end
        end
	end

	for i = data["activityCount"] + 1 , data["activityCount"] + data["activityRewardCount"] do
	   self.rewardStatus[data[i]["activity"]] = data[i]
	end

    for i = data["activityCount"] + data["activityRewardCount"] + 1, data["activityCount"] + data["activityRewardCount"] + data["count"] do
        self.activityStatus[data[i]["name"]] = data[i]
    end

    -- WDSY-28860 添加
    if ActivityMgr:startNewActivity() then
        local data = self:getLimitActivityDataByName(CHS[3000713], true)
        if data and data["activityTime"][1][1] == CHS[5410231] then
            -- 还是旧数据刷新一下
            data["activityTime"][1][1] = CHS[3000714]
            data["actitiveDate"] = "0"
        end
    end
end

-- 活跃度领取奖励行为，刷新mgr信息
function ActivityMgr:MSG_LIVENESS_REWARDS(data)
    self.rewardStatus = {}

    for i = 1, data.activityRewardCount do
        self.rewardStatus[data[i]["activity"]] = data[i]
    end
end

-- 只更新部分活动信息
function ActivityMgr:MSG_LIVENESS_INFO_EX(data)
    -- 如果未初始化过
    if not self.activityCurTimes then
        self.activityCurTimes = {}
    end

    for i = 1, data["activityCount"] do
        self.activityCurTimes[data[i]["name"]] = data[i]

        -- 服务器修改开启时间显示
        if data[i].timeStr ~= "" then
            local actInfo = json.decode(data[i].timeStr)
            if actInfo.type == "limit" then
                for _, act in pairs(LimitActivity) do
                    if act.mainType == data[i].name then
                        if actInfo.duration then
                            act.activityTime[1][1] = actInfo.duration
    end

                        if actInfo.desc then
                            act.desc = actInfo.desc
                        end

                        if actInfo.auto_walk then
                            act.activityTime[1][3] = actInfo.auto_walk
                        end
                    end
                end
            end
        end
    end

    if GameMgr.initDataDone then
        -- 该位置只在完成某活动时刷新小红点，登录、换线刷数据时不刷新
        RedDotMgr:updateLimitActivities()
        RedDotMgr:updateFestivalActivities()
    end

    -- WDSY-28860 添加
    if ActivityMgr:startNewActivity() then
        local data = self:getLimitActivityDataByName(CHS[3000713], true)
        if data and data["activityTime"][1][1] == CHS[5410231] then
            -- 还是旧数据刷新一下
            data["activityTime"][1][1] = CHS[3000714]
            data["actitiveDate"] = "0"

            DlgMgr:sendMsg("ActivitiesDlg", "MSG_LIVENESS_INFO")
            DlgMgr:closeDlg("ActivitiesInfoFFDlg")
        end
    end

end

function ActivityMgr:startNewActivity()
    local time
    if DistMgr:curIsTestDist() then
        time = os.time{year = 2018, month = 04, day = 30, hour = 05, min = 00, sec = 00}
    else
        time = os.time{year = 2018, month = 05, day = 07, hour = 05, min = 00, sec = 00}
    end

    local curTime = gf:getServerTime()
    if curTime >= time - 10 then
        return true
    end
end


-- 获取各个活动的进行次数
function ActivityMgr:getActivityCurTimes(key)
    if key == CHS[4300244] then
        -- 实名认证，次数在 MSG_ACTIVITY_LIST中发送
        local actTimeData = self.activityInfoEx
        if actTimeData and actTimeData.activityList["realname_gift"] then
            return tonumber(actTimeData.activityList["realname_gift"].para)
        end
    end

    if self.activityCurTimes and self.activityCurTimes[key]  then
        if key == CHS[3000713] then
            -- 镖行万里活动次数需要 % 1000
        return  math.floor(self.activityCurTimes[key]["count"] % 1000)
    else
            return  self.activityCurTimes[key]["count"]
        end
    else
        return 0
    end
end

-- 获取各个活动的每周已完成天数      (当前只有镖行万里活动用到)
-- 如果其他活动有此需求，请服务器按WDSY-29944中约定格式下发数据
function ActivityMgr:getActivityCurDayTimes(key)
    if self.activityCurTimes and self.activityCurTimes[key]  then
        return  math.floor(self.activityCurTimes[key]["count"] / 1000)
    else
        return 0
    end
end

-- 获取各个活动的每次活跃度值
function ActivityMgr:getActivityValue(key)
    if self.activityCurTimes and self.activityCurTimes[key] then
        return math.floor(self.activityCurTimes[key]["activeValue"] / 100 )
    else
        return 0
    end
end

-- 获取领取奖励状态
function ActivityMgr:getRewardStatus()
    return self.rewardStatus
end

-- 获取总的活跃度
function ActivityMgr:getAllActivity()
    if not self.allActivity then
        return 0
    end

    return math.floor(self.allActivity / 100)
end

-- 根据名字获取任务信息
function ActivityMgr:getActivityByName(name)
    for k, v in pairs(DailyActivity) do
        if v.name == name then
            return v
        end
    end


    for k, v in pairs(LimitActivity) do
        if v.name == name then
            return v
        end
    end

    for k, v in pairs(OtherActivity) do
        if v.name == name then
            return v
        end
    end
end

-- 活动次数是否收到加成
function ActivityMgr:MSG_ADD_TASK_ROUND(data)
    if data.type == "party_task" then
        self.partyTaskAdd = data.addRound
    end
end

function ActivityMgr:MSG_SHENGJI_KUANGHUAN_RATE(data)
    self.reward_rate = data.reward_rate
end

 -- 升级狂欢(等级对应经验加成的百分比)
function ActivityMgr:get_level_add_exp_precent()
    return self.reward_rate or 0
end

-- 某节日活动是否开启
function ActivityMgr:isFestivalActivityBegin(activityName)
    local list = self:getFestivalActivity()
    for i = 1, #list do
        local timeStr = list[i]["activityTime"][1][1]
        if  self:isFestivalStart(timeStr) and list[i].name == activityName then
            return true
        end
    end

    return false
end

-- 某福利活动是否开启
function ActivityMgr:isWelfareActivityBegin(activityName)
    local list = self:getWelfareActivity()
    for i = 1, #list do
        local timeStr = list[i]["activityTime"][1][1]
        if  self:isFestivalStart(timeStr) and list[i].name == activityName then
            return true
        end
    end

    return false
end

-- 是否是双倍中的活动
function ActivityMgr:isDoubleActive(data)
    for fAct, list in pairs(ActivityMgr.doubleActvies) do
        if list[data["name"]] and self:isWelfareActivityBegin(fAct) then
            return true
        end
    end

    return false
end

function ActivityMgr:MSG_SUIJI_RICHANGE_FANBEI(data)
    ActivityMgr.doubleActvies[CHS[4100285]] = {}

    local function getActiveChs(act_field)
    	if act_field == "xiux" then
            return CHS[4100328] -- 修行
    	elseif act_field == "chub" then
            return CHS[3000270] -- 除暴任务
    	elseif act_field == "shimrw" then
            return CHS[3001724] -- 师门任务
    	elseif act_field == "tongtt" then
            return CHS[3002131] -- 通天塔
    	elseif act_field == "fub" then
            return CHS[5000156] -- 副本
    	elseif act_field == "zhurwl" then
            return CHS[3000295]
    	elseif act_field == "xuansrw" then
            return CHS[3000734] -- 悬赏任务
        elseif act_field == "shijz" then
            return CHS[4100329] -- 十绝阵
    	end
    end


    for i = 1, data.count do
        local key = getActiveChs(data.doubleAct[i])
        if key then ActivityMgr.doubleActvies[CHS[4100285]][key] = true end
    end
end

-- 是否是双倍中的活动
function ActivityMgr:MSG_NEW_ACTIVITY_INFO(data)
    local actInfos = {}

    if pcall(function() actInfos = loadstring(data.actInfo)() end) then
    end

    if type(actInfos) ~= "table" then return end

    local activiesInfo
    if data.actType == "日常活动" then
        activiesInfo = DailyActivity
    elseif data.actType == "限时活动" then
        activiesInfo = LimitActivity
    elseif data.actType == "节日活动" then
        activiesInfo = FestivalActivity
    elseif data.actType == "其他活动" then
        activiesInfo = OtherActivity
    else
        return
    end

    for actName, newAct in pairs(actInfos) do
        if newAct == "" then
            activiesInfo[actName] = nil
        else
            activiesInfo[actName] = newAct
        end
    end
end

-- qq跳转功能链接地址
function ActivityMgr:MSG_QQ_LINK_ADDRESS(data)
    self.qqLinkAddr = data.addr
end

-- 打开qq链接并上报
function ActivityMgr:openQQLink()
    local function logReport(url, method, data)
        -- 构建请求
        local xhr = cc.XMLHttpRequest:new()
        xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
        xhr:open(method, url, false)

        local function onReadyStateChange()
            Log:I('HTTP_RESPONSE' .. xhr.statusText .. ' ' .. xhr.response)
        end

        xhr:registerScriptHandler(onReadyStateChange)
        if data then
            xhr:send(data)
        else
            xhr:send()
        end
    end

    -- 上报平台

    local gid = Me:queryBasic("gid")
    local distId = string.sub(gid, 9, 12)
    local accountId = string.sub(gid, 5, 10) .. string.sub(gid, 13, 16) .. string.sub(gid, 17, 20) .. string.sub(gid, 1, 4) .. string.sub(gid, 11, 12)

    -- 上报平台
    local game = 'wd'
    local account = Client:getAccount()
    local channelNo = DeviceMgr:getChannelNO()
    local gameZone = GameMgr:getDistName()
    local role = Me:queryBasic("gid")
    local roleName = Me:getName()
    local key = "#lt_gift_sign_key#"
    local sign = string.lower(gfGetMd5(string.format("%s%s%s%s", game, account, role, key)))
    local data = string.format("game=%s&account=%s&role=%s&roleName=%s&gameZone=%s&sign=%s&channelNo=%s", game, account, role, roleName, gameZone, sign, channelNo)
    logReport("http://gift.leiting.com/qqApi/clickReport.do?", 'POST', data)

    -- 打开充值的外部链接
    -- local appId = "1105040429"
    local addr, appId = string.match(ActivityMgr.qqLinkAddr, "(.*)?appid=(.*)")
    local dsid = distId
    local drid = gf:getShowId(Me:queryBasic("gid"))
    local uid = accountId
    local infos = string.format("appid=%s&drid=%s&dsid=%s&uid=%s", appId, drid, dsid, uid)
    local signature = string.lower(gfGetMd5(infos))
    local url = string.format("%s?%s&signature=%s", addr, infos, signature)
    DeviceMgr:openUrl(url)
end

-- 客户端通知点击了QQ会员礼包相关按钮
function ActivityMgr:cmdClickQQGiftButton(type)
    gf:CmdToServer("CMD_CLICK_QQ_GIFT_BTN", {type = type})
end

function ActivityMgr:MSG_WEEK_ACTIVITY_INFO(data)
    self.weekActivityInfo = data
end

function ActivityMgr:getWeekActivityInfo()
    return self.weekActivityInfo
end

function ActivityMgr:getWeekActivityDate(mainType)
    local dateList = {}
    local data = self:getWeekActivityInfo()
    if not data then
        return dateList
    end

    for i = 1, data.count do
        -- 与服务器约定规则，数组的序号为几，则代表为周几的数据
        local alias = data.activities[i]
        if mainType == alias then
            -- +1原因详见LimitActivity.lua中actitiveDate字段数值的含义（例如2代表周一）
            table.insert(dateList, i + 1)
        end
    end

    return dateList
end

function ActivityMgr:isInLimitPurchase()
    -- 在限时特惠中
    if not ActivityMgr:getStartTimeList() then
        return
    end

    -- 由于通信过程需要时间，导致 gf:getServerTime() 得到的时间有可能比服务器真实的时间小一些
    -- 此处增加一个 3 秒的容错
    local TOLERANCE_TIME = 3
    local activityTime = ActivityMgr:getActivityStartTimeByMainType("limit_purchase")
    if activityTime then
        local curTime = gf:getServerTime() + TOLERANCE_TIME
        local startTime = activityTime["startTime"]
        local endTime = activityTime["endTime"]
        local isInXianShiTeHui = false
        if curTime >= startTime and curTime <= endTime then
            return true
        end
    end

    return false
end

function ActivityMgr:isChantingStauts()
    return 1 == self.chantingStauts
end

-- 2017年儿童节
function ActivityMgr:MSG_CHILD_DAY_2017_START(data)
    DlgMgr:openDlgEx("ChildrenDayDlg", data)
end

function ActivityMgr:MSG_CHILD_DAY_2017_END(data)
end

function ActivityMgr:MSG_CHILD_DAY_2017_POKE(data)
end

function ActivityMgr:MSG_CHILD_DAY_2017_QUIT(data)
end

function ActivityMgr:MSG_CHILD_DAY_2017_REMOVE(data)
end

-- 2017年中秋接月饼
function ActivityMgr:MSG_AUTUMN_2017_START(data)
    DlgMgr:openDlgEx("MidAutumnDlg", data)
end


-- 活动数据，2017:05:19当前用于实名认证完成次数
function ActivityMgr:MSG_ACTIVITY_DATA_LIST(data)
    self.activityInfoEx = data
end

function ActivityMgr:MSG_CHANTING_NOW(data)
    self.chantingStauts = data.status
    if 1 == data.status then
        self.curHideAllUI = GameMgr:isHideAllUI()
        local function checkDramaDlgVisible()
            if DlgMgr:isDlgOpened("DramaDlg") then
                performWithDelay(gf:getUILayer(), checkDramaDlgVisible, 0)
    else
                if not self.curHideAllUI then
                    GameMgr:hideAllUI(0)
    end
                DlgMgr:setAllDlgVisible(false)
            end
        end
        checkDramaDlgVisible()
    else
        if not self.curHideAllUI then
            GameMgr:showAllUI(0.1)
        end
        DlgMgr:showDlgWhenNoramlDlgClose()
        DlgMgr:setAllDlgVisible(true)
    end
end

-- 活动的额外数据
function ActivityMgr:MSG_ACTIVITY_EXTRA_DATA(data)
    activityExtraInfo = data
end

-- 判断水岚之缘-剧情是否有未完成的任务
function ActivityMgr:hasNewTaskShuilanzy(level)
    if not self.shiulzyTaskData then
        return
    end

    local data = self.shiulzyTaskData
    local myLevel = level or Me:getLevel()
    local curTime = gf:getServerTime()
    for i = 1, data.count do
        if data[i].status == 0
              and myLevel >= data[i].level
              and curTime >= data[i].start_time
              and curTime < data[i].end_time then
            return i
        end
    end
end

function ActivityMgr:clearData()
    -- 2018暑假活动-行云布雨  清除下雨天气、水洼特效
    self:clearXybyMapEffect()

    self.winter_day_2019_sxys = false
end

function ActivityMgr:clearDataWhenEnterRoom()
    self.meIsObserverInQiXi = nil
end

-- 水岚之缘-剧情数据
function ActivityMgr:MSG_TASK_SHUILZY_DIALOG(data)
    self.shiulzyTaskData = data

    RedDotMgr:checkShuilanzyRedDot()
end


-- 愚人节-走火入魔 NPC 动作
function ActivityMgr:MSG_FOOLS_2018_ACTION(data)
    local char = CharMgr:getChar(data.npc_id)
    if not char then
        return
    end

    char:setBasic("isFixDir", 1)
    local no = tonumber(string.match(data.npc_action, CHS[5450094] .. "(.+)"))
    if no == 2 then
        -- 物理攻击
        if char.faAct ~= Const.FA_DIED then
            char:setAct(Const.FA_DIED)
        end
    elseif no == 3 or no == 4 then
        char:setAct(Const.FA_PHYSICAL_ATTACK_LOOP)
    elseif no == 5 then
        if char.faAct ~= Const.FA_DEFENSE_END then
            char:setAct(Const.FA_DEFENSE_END)
        end
    elseif no == 7 then
        if char.faAct ~= Const.FA_ACTION_CAST_MAGIC_END then
            char:setAct(Const.FA_ACTION_CAST_MAGIC_END)
        end
    elseif no == 8 then
        char:setAct(Const.FA_STAND)

        CharMgr:MSG_PLAY_LIGHT_EFFECT({effectIcon = ResMgr.magic.frozen, charId = data.npc_id})
    end
end

-- 愚人节 玩家走火入魔表现
function ActivityMgr:MSG_XIAOLIN_GUANGJI(data)
    local layer = Me.middleLayer

    if not layer then
        return
    end

    if self.xiaolinData then
        -- 先停止上一动作
        if self.xiaolinData.func then
            layer:stopAction(self.xiaolinData.action)
            self.xiaolinData.func()
        end
    end

    gf:frozenScreen(0)
    DlgMgr:closeDlg("BagDlg")
    DlgMgr:closeDlg("ItemInfoDlg")

    if data.type == 1 then
        -- 3s 巡逻
        local curMapName = MapMgr:getCurrentMapName()
        local x, y = gf:convertToMapSpace(Me.curX, Me.curY)
        local autoWalkStr = string.format("#Z%s|%s(%d,%d)|$1#Z", curMapName, curMapName, x, y)
        AutoWalkMgr:beginAutoWalk(gf:findDest(autoWalkStr))
        local function func()
            gf:unfrozenScreen()
            AutoWalkMgr:endRandomWalk()
            self.xiaolinData = nil
        end

        self.xiaolinData = {}
        self.xiaolinData.func = func
        self.xiaolinData.action = performWithDelay(layer, func, data.duration)
    else
        -- 3s 冰冻
        CharMgr:MSG_PLAY_LIGHT_EFFECT({effectIcon = ResMgr.magic.frozen, charId = Me:getId()})

        if Me.faAct ~= Const.FA_STAND then
            Me:setAct(Const.FA_STAND)
        end

        AutoWalkMgr:cleanup()
        local function func()
            self.xiaolinData = nil
            gf:unfrozenScreen()
            Me:deleteMagic(ResMgr.magic.frozen)
        end

        self.xiaolinData = {}
        self.xiaolinData.func = func
        self.xiaolinData.action = performWithDelay(layer, func, data.duration)
    end
end

-- 儿童节-烹饪美食 食物中毒
function ActivityMgr:MSG_CHILD_2018_ACTION(data)
    local char = CharMgr:getChar(data.npc_id)
    if not char then
        return
    end


    if data.action == 1 then
        if char.faAct ~= Const.FA_DIED then
            char:setAct(Const.FA_DIED)
        end
    else
        char:setAct(Const.FA_STAND)
    end
end

function ActivityMgr:MSG_SHOW_INSIDER_GIFT(data)
    DlgMgr:openDlgEx("ServiceGiftDlg", data)
end

-- 释放 噬仙从有效点击后冻屏事件
function ActivityMgr:releaseForSXC()
    if ActivityMgr.sxcAction then
        ActivityMgr.sxcAction = nil
        self.isTouchSXCtime = 0
        Me.canMove = true
        gf:unfrozenScreen()
    end
end

function ActivityMgr:setSXCTouchEff(delayTime)

    if ActivityMgr.sxcAction then
        gf:getUILayer():stopAction(ActivityMgr.sxcAction)
    end

    ActivityMgr.sxcAction =  performWithDelay(gf:getUILayer(), function ()
        ActivityMgr:releaseForSXC()
    end, delayTime )
end


function ActivityMgr:MSG_DUANWU_2018_COLLISION(data)

    if data.ret ~= 1 then return end

    local layer = Me.middleLayer

    if not layer then
        return
    end

    Me:setAct(Const.FA_STAND)
    Me.canMove = false
    gf:frozenScreen()
    self.isTouchSXCtime = gfGetTickCount()

    ActivityMgr:setSXCTouchEff(5)
    AutoWalkMgr:cleanup()
end

function ActivityMgr:getShijiebeiData()
    return self.shijiebeiData
end

function ActivityMgr:MSG_WORLD_CUP_2018_PLAY_TABLE_GROUP(data)
    self.shijiebeiData = data
    DlgMgr:openDlg("ShiJieBeiDlg")
end

function ActivityMgr:MSG_WORLD_CUP_2018_PLAY_TABLE_KNOCKOUT(data)
    self.shijiebeiData = data
    DlgMgr:openDlg("ShiJieBeiDlg")
end

function ActivityMgr:MSG_WORLD_CUP_2018_BONUS_INFO(data)
    DlgMgr:openDlgEx("ShiJieBeiRewardDlg", data)
end



function ActivityMgr:MSG_SUMMER_2018_HQZM_START(data)
    AutoWalkMgr:cleanup()
    DlgMgr:openDlgEx("ControlDlg", data)
end


function ActivityMgr:MSG_SUMMER_2018_ACTION(data)
    local char = CharMgr:getChar(data.npc_id)
    if not char then
        return
    end

    if data.flag == 1 then
        -- 物理攻击
        if char.faAct ~= Const.FA_DIED then
            char:setAct(Const.FA_DIED)
        end
    else
        char:setAct(Const.FA_STAND)
    end
end

-- 证道殿护法
function ActivityMgr:MSG_OVERCOME_NPC_INFO(data)
    local dlg = DlgMgr:openDlg("ZhengDaoHuFaDlg")

    data.titleContent = CHS[4010113]
    data.titleMsg = CHS[4010114]
    data.dlgType = "zhengdao"

    dlg:setLeaderInfo(data)
end

-- 2018暑假活动-行云布雨 拼图游戏
function ActivityMgr:MSG_SUMMER_2018_PUZZLE(data)
        local dlg = DlgMgr:openDlg("JigsawPuzzleDlg")
        dlg:setData(data)
end

-- 2018暑假活动-行云布雨  清除下雨天气、水洼特效
function ActivityMgr:clearXybyMapEffect()
    -- 清除下雨天气
    if self.xybyWeatherData then
        local mapInfo = MapMgr:getMapInfoByName(self.xybyWeatherData.mapName)
        WeatherMgr:clearMapWeatherById(mapInfo.map_id)
        WeatherMgr:removeWeather()
        self.xybyWeatherData = nil
    end

    -- 清除水洼
    if self.posSchedule then
        gf:Unschedule(self.posSchedule)
        self.posSchedule = nil
    end

    self.lastMePos = nil
end

-- 2018暑假活动-行云布雨 下雨特效信息
function ActivityMgr:MSG_SUMMER_2018_WEATHER(data)
    self.xybyWeatherData = data
    if data and data.rainStartTime < data.rainEndTime and data.rainEndTime > gf:getServerTime() then
        -- 天气特效
        local mapInfo = MapMgr:getMapInfoByName(data.mapName)
        WeatherMgr:addMapWeatherById(mapInfo.map_id, "yu", true)

        -- 水洼特效
        if not self.posSchedule then
            self.posSchedule = gf:Schedule(function()
                if data.rainEndTime <= gf:getServerTime() then
                    ActivityMgr:clearXybyMapEffect()
                    return
                end

                local curMapName = MapMgr:getCurrentMapName()
                if not curMapName or data.mapName ~= curMapName then return end
                if self.lastMePos then
                    local lastX, lastY = self.lastMePos.x, self.lastMePos.y
                    local mapX, mapY = gf:convertToMapSpace(lastX, lastY)
                    local map = GameMgr.scene.map

                    -- 移动距离大于10，且满足播放动画的位置非地图阴影位置
                    if gf:distance(lastX, lastY, Me.curX, Me.curY) > 10 and not map:isShelter(mapX, mapY) then
                        MapMagicMgr:playArmatureByPos(ResMgr.ArmatureMagic.summer_xyby, lastX, lastY, ResMgr.ArmatureMagic.summer_xyby.name)
                    end
                end

                self.lastMePos = cc.p(Me.curX, Me.curY)
            end, 0.2)
        end
    else
        ActivityMgr:clearXybyMapEffect()
    end
end

-- MSG_HEISHI_KANJIA_INFO
function ActivityMgr:MSG_HEISHI_KANJIA_INFO(data)
    if data.isStart == 0 then
        -- 游戏未开始则打开界面
        DlgMgr:openDlg("InnEventDlg")
    end
end

function ActivityMgr:checkDisInQixi(char, lastPos)
    if char.qixiMbhcData then
         local x, y = gf:convertToMapSpace(char.curX, char.curY)
         local info = char.qixiMbhcData
         local cx = math.abs(x - info.carpet_x)
         local cy = math.abs(y - info.carpet_y)
         Log:D(string.format("%d %d   %d %d", x, y, info.carpet_x, info.carpet_y))
         if (cx < info.radius and cy < info.radius)
             or cx > math.abs(lastPos.x - info.carpet_x)
             or cy > math.abs(lastPos.y - info.carpet_y)  then
             -- 到达播动画范围或远离该范围，直接播放动画
             char:playQixiAction(info)
             char.qixiMbhcData = nil
             char.playQixiAction = nil

             char:setNeedDisMoveEvent(false)
             EventDispatcher:removeEventListener("CHAR_UPDATE_POS", self.checkDisInQixi, self)
         end
    else
        char:setNeedDisMoveEvent(false)
        EventDispatcher:removeEventListener("CHAR_UPDATE_POS", self.checkDisInQixi, self)
    end
end

-- 客户端收到此消息时，播放动作
function ActivityMgr:MSG_QIXI_2018_EFFECT(data)
    local char = CharMgr:getCharById(data.char_id)
    if not char then
        return
    end

    local function playQixiAction(char, data)
        if data.flag == 1 then
            if data.char_id == Me:getId() then
                gf:frozenScreen(2000)
                local x, y = gf:convertToClientSpace(data.carpet_x, data.carpet_y)
                MapMagicMgr:playOnceMagic({icon = ResMgr.magic.red_circle}, x, y)
            end

            char:setCanMove(false)
            char:setAct(Const.FA_STAND)

            -- 播放水系B3特效
            char:addMagicOnFoot(ResMgr.magic.wood_skill_B3, false, false, nil, nil, function(node)
                gf:unfrozenScreen()
                char:setCanMove(true)
                node:removeFromParent()
            end)

            -- 播放受击
            local function callBack()
                if char.faAct == Const.FA_DEFENSE_START and char.charAction then
                    performWithDelay(char.charAction, function()
                        char:setActAndCB(Const.FA_DEFENSE_END, callBack)
                    end, 0.1)
                elseif char.faAct == Const.FA_DEFENSE_END and char.charAction then
                    char:setActAndCB(Const.FA_DIE_NOW, callBack)
                else
                    if not char.charAction then
                        -- 动作创建失败（坐骑、婚服没有该动作）
                        performWithDelay(char.topLayer, function()
                            char:setAct(Const.FA_STAND)
                        end, 0)
                    else
                        char:setAct(Const.FA_STAND)
                    end
                end
            end

            char:setActAndCB(Const.FA_DEFENSE_START, callBack)

            if not string.isNilOrEmpty(data.msg) then
                gf:ShowSmallTips(data.msg)
            end
        else
            if data.char_id == Me:getId() then
                local x, y = gf:convertToClientSpace(data.carpet_x, data.carpet_y)
                MapMagicMgr:playOnceMagic({icon = ResMgr.magic.yellow_circle}, x, y)
            end

            if not string.isNilOrEmpty(data.msg) then
                gf:ShowSmallTips(data.msg)
            end
        end
    end

    if data.char_id == Me:getId() then
        playQixiAction(char, data)
    else
        if char.qixiMbhcData then
            char:playQixiAction(char.qixiMbhcData)
        end

        char.qixiMbhcData = data

        char.playQixiAction = playQixiAction

        char:setNeedDisMoveEvent(true)
        EventDispatcher:addEventListener("CHAR_UPDATE_POS", self.checkDisInQixi, self)
    end
end

function ActivityMgr:canShowItemInQixi()
    if self.meIsObserverInQiXi then
        return true
    end
end

-- 客户端收到此消息时，判断是否显示“百花丛中”地图上的圈圈
function ActivityMgr:MSG_QIXI_2018_ACTOR(data)
    if data.actor == 1 then
        self.meIsObserverInQiXi = false
        if MapMgr:isInBaiHuaCongzhong() then
            DroppedItemMgr:setVisible(false)
        end
    elseif data.actor == 2 then
        -- 圈圈可能在该条消息前已加载了
        self.meIsObserverInQiXi = true
        if MapMgr:isInBaiHuaCongzhong() then
            DroppedItemMgr:setVisible(true)
        end
    end
end

-- 英雄殿护法
function ActivityMgr:MSG_HERO_NPC_INFO(data)
    local dlg = DlgMgr:openDlg("ZhengDaoHuFaDlg")

    data.titleContent = CHS[4010080]
    data.titleMsg = CHS[4010081]
    data.dlgType = "hero"

    dlg:setLeaderInfo(data)
end

-- 2018中元节打开乾坤图
function ActivityMgr:MSG_GHOST_2018_QIANKT(data)
    if DlgMgr:getDlgByName("QianktDlg") then
        -- 乾坤图已开启
        gf:ShowSmallTips(CHS[7100265])
    else
    local dlg = DlgMgr:openDlg("QianktDlg")
    dlg:setData(data.mapName, data.index)
    end
end

-- 2018中元节打开天机仪
function ActivityMgr:MSG_GHOST_2018_TIANJY(data)
    local dlg = DlgMgr:getDlgByName("SouxlpSmallDlg")
    if not dlg then
        -- 战斗中切后台，服务器会刷新此消息，此时不能打开天机仪界面
        if Me:isInCombat() then return end

        DlgMgr:openDlgEx("SouxlpSmallDlg", {
            mapId = nil,
            x = data.monsterX,
            y = data.monsterY,
            needAction = data.actionFlag,
        })
    else
        -- 天机仪已开启
        gf:ShowSmallTips(CHS[7100266])

        -- 天机仪已打开，尝试切换系统状态按钮，显示天机仪
        local systemDlg = DlgMgr:getDlgByName("SystemFunctionDlg")
        if systemDlg then
            systemDlg:onStatusButton2()
        end
    end
end

function ActivityMgr:checkSameNameActivity()
    if not ATM_IS_DEBUG_VER or not gf:isWindows() then
        return
    end

   local activities = {
        DailyActivity,
        LimitActivity,
        FestivalActivity,
        OtherActivity,
        WelfareActivity
    }

    local map = {}
    for i = 1, #activities do
        for j = 1, #activities[i] do
            if map[activities[i][j].name] then
                local str = "存在同名活动：" .. activities[i][j].name
                gf:ShowSmallTips(str)
                Log:D(str)
            else
                map[activities[i][j].name] = true
            end
        end
    end
end


-- 2018教师节答题
function ActivityMgr:MSG_TEACHER_2018_GAME_S6(data)
    local dlg = DlgMgr:openDlg("JiaoSx1Dlg")
    dlg:setData(data)
end

function ActivityMgr:MSG_TEACHER_2018_GAME_S2(data)
    local dlg = DlgMgr:openDlg("JiaoSxDlg")
    dlg:setData(data)
end

function ActivityMgr:MSG_TEACHER_2018_CHANNEL(data)
    DlgMgr:openDlgWithParam(string.format("ChannelDlg=%d", data.channel))

    if data.channel ~= CHAT_CHANNEL.FRIEND then return end
    local before = string.match(data.msg, CHS[4200541])
    local endStr = string.match(data.msg, "=teacher_2018=(.+)}")
    local copyInfo = string.gsub(data.msg, "\9", "")
    copyInfo = before .. CHS[4200542]

    local showInfo = before .. string.format("{\29%s\29}", CHS[4200543] .. endStr )
    local sendInfo = before .. string.format("{\t%s}", CHS[4200543] .. endStr )

    gf:ShowSmallTips(CHS[4200544])  -- "鲜花位置信息已复制，可利用系统自带粘贴功能粘贴。"
    gf:copyTextToClipboardEx(copyInfo, {copyInfo = copyInfo, showInfo = showInfo, sendInfo = sendInfo})
end

MessageMgr:regist("MSG_TEACHER_2018_CHANNEL", ActivityMgr)

function ActivityMgr:MSG_NATIONAL_2018_SFQJ(data)
    DlgMgr:openDlgEx("SifqjDlg", data)
end

function ActivityMgr:MSG_JIUTIAN_ZHENJUN(data)
    if data.is_open == 1 then
        DlgMgr:openDlgEx("JiuTianDlg", data)
    end
end

function ActivityMgr:MSG_CHONGYANG_2018_GAME_START(data)
    DlgMgr:openDlgEx("ChangyjjDlg", data)

    DlgMgr:closeDlg("JiucDlg")
end

function ActivityMgr:MSG_CHONGYANG_2018_GAME_BOOK(data)
    DlgMgr:openDlgEx("JiucDlg", data)
end

function ActivityMgr:MSG_FOOLS_DAY_2019_START_GAME(data)
    data.type = "fool"
    DlgMgr:openDlgEx("ChangyjjDlg", data)
end

function ActivityMgr:MSG_QYGD_INFO_2018(data)
    local dlg = DlgMgr:openDlg("QingYuanDlg")
    dlg:setData(data)
end

function ActivityMgr:MSG_SXYS_QUESTION_INFO_2019(data)
    DlgMgr:openDlgEx("ShangxysDlg", data)
end

function ActivityMgr:MSG_SXYS_HIDE_DLG_2019(data)
    if data.flag ~= 0 then
        -- 隐藏主界面，同时冻屏
        EnterRoomEffectMgr:setMainDlgVisible(false)
        gf:frozenScreen(-1)
        performWithDelay(gf:getUILayer(), function ()
            if not DlgMgr:getDlgByName("DramaDlg") then
                -- body
                EnterRoomEffectMgr:setMainDlgVisible(true)
            end
            gf:unfrozenScreen()
        end, 10)

        self.sxys2019NpcId = data.flag
    else
        if not DlgMgr:getDlgByName("DramaDlg") then
            -- body
            EnterRoomEffectMgr:setMainDlgVisible(true)
        end
        gf:unfrozenScreen()

        self.sxys2019NpcId = false
    end

end


function ActivityMgr:MSG_WINTER_2019_BX21D_ENTER(data)

    if not data then
        DlgMgr:closeDlg("Vacation21Dlg")
    else
        DlgMgr:openDlg("Vacation21Dlg")
    end

    local map = gf:deepCopy(MapMgr.mapData)
    local mapX, mapY = gf:convertToMapSpace(Me.curX, Me.curY)
    map.x = mapX
    map.y = mapY
    MapMgr:MSG_ENTER_ROOM(map, true)
end

function ActivityMgr:MSG_CXK_START_GAME_2019(data)
    if data.flag == 0 then
        DlgMgr:openDlgEx("VacationWhiteDlg", data)
    end
end

function ActivityMgr:MSG_TTT_NEW_XING(data)
    if data.result == 0 then return end

    if not DlgMgr:getDlgByName("TongTianDlg") then
        DlgMgr:openDlgEx("TongTianDlg", data)
    end
end

function ActivityMgr:MSG_COUNTDOWN(data)
    -- 当前只在万花谷用到，容错
    if not MapMgr:isInMapByName(CHS[4101241]) then return end
    if data.end_time < gf:getServerTime() then return end


    DlgMgr:openDlgEx("MeiGuiTimeDlg", data)
end

function ActivityMgr:MSG_SPRING_2019_XTCL_START_GAME(data)

    if not DlgMgr:getDlgByName("XitclDlg") then
        DlgMgr:openDlgEx("XitclDlg", data)
    else
        local dlg = DlgMgr:getDlgByName("XitclDlg")
        dlg:resetData(data)
    end

end

function ActivityMgr:MSG_BJTX_FIND_FRIEND(data)
    if data.flag == 1 then
        if DlgMgr:getDlgByName("SeekFriendDlg") then
            DlgMgr:getDlgByName("SeekFriendDlg"):setFriend(data)
        else

            DlgMgr:openDlg("SeekFriendDlg")
        end

    else
        DlgMgr:closeDlg("SeekFriendDlg")
    end

end

function ActivityMgr:MSG_ZHISJJUMCL_ROOM_EFFECT(data)
    if MapMgr:getCurrentMapName() == data.room_name then
        MapMagicMgr:setMapMagicType(1 == data.has_effect and "on" or "off")
        GameMgr.scene.map:removeMapMagic()
        GameMgr.scene.map:addMapMagic()
    end
end

function ActivityMgr:MSG_SMDG_START_GAME(data)
    local dlg = DlgMgr:openDlg("ShenmdgDlg")
    if Me:isInCombat() or Me:isLookOn() then
        dlg:setVisible(false)
    end
end

function ActivityMgr:getMyAct2019kwdzLogData()
    if self.active2019cwtxLog and self.active2019cwtxLog[Me:queryBasic("gid")] then
        return self.active2019cwtxLog[Me:queryBasic("gid")]
    end

    return
end


-- 2019周年庆-秘境探险log记录
function ActivityMgr:MSG_2019ZNQ_CWTX_ACT_LOG(data)

    if not self.active2019cwtxLog then self.active2019cwtxLog = {} end
    if not self.active2019cwtxLog[Me:queryBasic("gid")] then self.active2019cwtxLog[Me:queryBasic("gid")] = {} end

    local lastCount = #self.active2019cwtxLog[Me:queryBasic("gid")]
    if lastCount <= 0 or self.active2019cwtxLog[Me:queryBasic("gid")][lastCount].layer ~= data.layer then
        data.isAddLayrt = true

    end

    table.insert( self.active2019cwtxLog[Me:queryBasic("gid")], {log = data.log, ti = data.ti, isAddLayrt = data.isAddLayrt, layer = data.layer} )
end

function ActivityMgr:MSG_DW_2019_ZDBC_DATA(data)
    if data.type == "start" then
        DlgMgr:openDlg("ZhidbcDlg")
    elseif data.type == "stop" then
        DlgMgr:closeDlg("ZhidbcDlg")
    end
end

function ActivityMgr:MSG_OPEN_TTLP_DLG(data)
    DlgMgr:openDlgEx("TongTianTopTargetDlg", data)
end


function ActivityMgr:MSG_SUMMER_2019_SMSZ_SMHJ(data)
    self.smszData = data
end

function ActivityMgr:MSG_SUMMER_2019_SMSZ_SMBH(data)
    DlgMgr:openDlg("ShenmbhDlg")
end

function ActivityMgr:MSG_SUMMER_2019_SSWG_ENTER(data)
    DlgMgr:showLoadingDlgAction(seconds)
    DlgMgr:openDlg("ShiswgDlg")
end

function ActivityMgr:MSG_SUMMER_2019_SXDJ_ENTER(data)
    local dlg = DlgMgr:getDlgByName("ShengxdjDlg")
    if dlg then
        dlg:cleanupChar()
    else
        DlgMgr:openDlg("ShengxdjDlg")
    end

end


function ActivityMgr:MSG_SUMMER_2019_XZJS_DATA(data)
    DlgMgr:openDlg("XiaozjsDlg")
end

function ActivityMgr:MSG_START_COMMON_PROGRESS(data)
    local startTime = gfGetTickCount()
    self.timerForProgress = gf:Schedule(function ( )
        if gfGetTickCount() - startTime >= data.process_time * 1000 then
            gf:CmdToServer("CMD_STOP_COMMON_PROGRESS", {process_type = data.type})
            gf:Unschedule(self.timerForProgress)
        end
    end, 0.1)

    if string.match( data.para, "KidProgressDlg=" ) then

        local tab = gf:split(data.para, "=")

        local dlg = DlgMgr:openDlg("KidProgressDlg")
        dlg:setInfo({op_type = tonumber(tab[3]), result = tonumber(tab[2]), ti = data.process_time})
    end
end


MessageMgr:regist("MSG_START_COMMON_PROGRESS", ActivityMgr)
MessageMgr:regist("MSG_OPEN_TTLP_DLG", ActivityMgr)
MessageMgr:regist("MSG_SUMMER_2019_SXDJ_ENTER", ActivityMgr)
MessageMgr:regist("MSG_SUMMER_2019_XZJS_DATA", ActivityMgr)
MessageMgr:regist("MSG_SUMMER_2019_SSWG_ENTER", ActivityMgr)
MessageMgr:regist("MSG_DW_2019_ZDBC_DATA", ActivityMgr)
MessageMgr:regist("MSG_2019ZNQ_CWTX_ACT_LOG", ActivityMgr)

MessageMgr:regist("MSG_SMDG_START_GAME", ActivityMgr)
MessageMgr:regist("MSG_BJTX_FIND_FRIEND", ActivityMgr)
MessageMgr:regist("MSG_TTT_NEW_XING", ActivityMgr)
MessageMgr:regist("MSG_SPRING_2019_XTCL_START_GAME", ActivityMgr)
MessageMgr:regist("MSG_COUNTDOWN", ActivityMgr)
MessageMgr:regist("MSG_CXK_START_GAME_2019", ActivityMgr)
MessageMgr:regist("MSG_WINTER_2019_BX21D_ENTER", ActivityMgr)
MessageMgr:regist("MSG_SXYS_HIDE_DLG_2019", ActivityMgr)
MessageMgr:regist("MSG_SXYS_QUESTION_INFO_2019", ActivityMgr)
MessageMgr:regist("MSG_QYGD_INFO_2018", ActivityMgr)

MessageMgr:regist("MSG_CHONGYANG_2018_GAME_START", ActivityMgr)
MessageMgr:regist("MSG_FOOLS_DAY_2019_START_GAME", ActivityMgr)
MessageMgr:regist("MSG_CHONGYANG_2018_GAME_BOOK", ActivityMgr)
MessageMgr:regist("MSG_JIUTIAN_ZHENJUN", ActivityMgr)
MessageMgr:regist("MSG_NATIONAL_2018_SFQJ", ActivityMgr)

MessageMgr:regist("MSG_TEACHER_2018_GAME_S2", ActivityMgr)
MessageMgr:regist("MSG_TEACHER_2018_GAME_S6", ActivityMgr)
MessageMgr:regist("MSG_GHOST_2018_QIANKT", ActivityMgr)
MessageMgr:regist("MSG_GHOST_2018_TIANJY", ActivityMgr)
MessageMgr:regist("MSG_HERO_NPC_INFO", ActivityMgr)
MessageMgr:regist("MSG_QIXI_2018_ACTOR", ActivityMgr)
MessageMgr:regist("MSG_QIXI_2018_EFFECT", ActivityMgr)
MessageMgr:regist("MSG_WORLD_CUP_2018_BONUS_INFO", ActivityMgr)
MessageMgr:regist("MSG_WORLD_CUP_2018_PLAY_TABLE_KNOCKOUT", ActivityMgr)
MessageMgr:regist("MSG_WORLD_CUP_2018_PLAY_TABLE_GROUP", ActivityMgr)
MessageMgr:regist("MSG_HEISHI_KANJIA_INFO", ActivityMgr)
MessageMgr:regist("MSG_SUMMER_2018_WEATHER", ActivityMgr)
MessageMgr:regist("MSG_SUMMER_2018_PUZZLE", ActivityMgr)
MessageMgr:regist("MSG_SUMMER_2018_ACTION", ActivityMgr)
MessageMgr:regist("MSG_SUMMER_2018_HQZM_START", ActivityMgr)
MessageMgr:regist("MSG_SHOW_INSIDER_GIFT", ActivityMgr)
MessageMgr:regist("MSG_DUANWU_2018_COLLISION", ActivityMgr)
MessageMgr:regist("MSG_TASK_SHUILZY_DIALOG", ActivityMgr)
MessageMgr:regist("MSG_OVERCOME_NPC_INFO", ActivityMgr)
MessageMgr:regist("MSG_CHILD_2018_ACTION", ActivityMgr)
MessageMgr:regist("MSG_FOOLS_2018_ACTION", ActivityMgr)
MessageMgr:regist("MSG_XIAOLIN_GUANGJI", ActivityMgr)
MessageMgr:regist("MSG_ACTIVITY_EXTRA_DATA", ActivityMgr)
MessageMgr:regist("MSG_ACTIVITY_DATA_LIST", ActivityMgr)
MessageMgr:regist("MSG_NEW_ACTIVITY_INFO", ActivityMgr)
MessageMgr:regist("MSG_SUIJI_RICHANGE_FANBEI", ActivityMgr)
MessageMgr:regist("MSG_LIVENESS_INFO", ActivityMgr)
MessageMgr:regist("MSG_LIVENESS_INFO_EX", ActivityMgr)
MessageMgr:regist("MSG_LIVENESS_REWARDS", ActivityMgr)
MessageMgr:regist("MSG_ADD_TASK_ROUND", ActivityMgr)
MessageMgr:regist("MSG_ACTIVITY_LIST", ActivityMgr)
MessageMgr:regist("MSG_SHENGJI_KUANGHUAN_RATE", ActivityMgr)
MessageMgr:regist("MSG_QQ_LINK_ADDRESS", ActivityMgr)
MessageMgr:regist("MSG_WEEK_ACTIVITY_INFO", ActivityMgr)
MessageMgr:regist("MSG_CHILD_DAY_2017_START", ActivityMgr)
MessageMgr:regist("MSG_CHILD_DAY_2017_END", ActivityMgr)
MessageMgr:regist("MSG_CHILD_DAY_2017_POKE", ActivityMgr)
MessageMgr:regist("MSG_CHILD_DAY_2017_QUIT", ActivityMgr)
MessageMgr:regist("MSG_CHILD_DAY_2017_REMOVE", ActivityMgr)
MessageMgr:regist("MSG_CHANTING_NOW", ActivityMgr)
MessageMgr:regist("MSG_AUTUMN_2017_START", ActivityMgr)
MessageMgr:regist("MSG_ZHISJJUMCL_ROOM_EFFECT", ActivityMgr)
MessageMgr:regist("MSG_SUMMER_2019_SMSZ_SMHJ", ActivityMgr)
MessageMgr:regist("MSG_SUMMER_2019_SMSZ_SMBH", ActivityMgr)
ActivityMgr:init()

return ActivityMgr

