-- LocalNotificationMgr.lua
-- created by zhengjh Oct/20/2015
-- 本地推送管理器

LocalNotificationMgr = Singleton()
local platform = cc.Application:getInstance():getTargetPlatform()

local NEED_PUSH_LIST =
{
    [CHS[3004146]] = CHS[3004146], -- 镖行万里
    [CHS[3004147]] = CHS[3004147], -- 海盗入侵
    [CHS[3004148]] = CHS[3004148], -- 铲除妖王
    [CHS[3004149]] = CHS[3004149], -- 试道大会
    [CHS[5450336]] = CHS[5450336], -- 月道行试道大会
    [CHS[3004150]] = CHS[3004150], -- 刷道全局双倍
    [CHS[6000483]] = CHS[6000483], -- 超级大BOSS
    [CHS[5400428]] = CHS[5400428], -- 世界BOSS
    [CHS[2200032]] = CHS[2200032], -- 周活动
}

local PUSH_KEY =
{
    [CHS[3004146]] = "push_biaoxing_wanli",
    [CHS[3004147]] = "push_haidao_ruqin",
    [CHS[3004148]] = "push_chanchu_yaowang",
    [CHS[3004149]] = "push_shidao_dahui",
    [CHS[5450336]] = "push_shidao_dahui",
    [CHS[3004150]] = "push_shuadao_double",
    [CHS[6000483]] = "push_super_boss",
    [CHS[5400428]] = "push_world_boss",
    [CHS[2200032]] = "push_week_act",
}

function LocalNotificationMgr:getNotificationList()
    local needPushList = {}
    local activityList = ActivityMgr:getPushActivity()
    local settingTable = SystemSettingMgr:getSettingStatus()

    for i = 1, #activityList do
        local name = activityList[i]["name"]
        local key = PUSH_KEY[name]
        if NEED_PUSH_LIST[name] and key and settingTable[key] == 1 then
            local hoursList = activityList[i]["pushTime"]
            for j = 1, #hoursList do
                local startH, startM = string.match(hoursList[j], "(%d+):(%d+)")
                local fnts = self:getFirstNotificationTime(hoursList[j], activityList[i]["actitiveDate"])
                local content = string.match(hoursList[j], ".*|mapStr=(.*)") or ""
                for k = 1, #fnts do
                    local pushItem = {}
                    pushItem["pushTime"] = fnts[k].time
                    pushItem["title"] = string.format(activityList[i]["pushContent"], content)
                    if fnts[k].aday == "0" then
                        pushItem["repeatUnit"] = "day"
                    elseif fnts[k].aday ~= "8" then
                        pushItem["repeatUnit"] = "week"
                    end

                    table.insert(needPushList, pushItem)
                end
            end
        end
    end

    return needPushList
end


function LocalNotificationMgr:addLocalNotification(oneNofication)
    local fun = 'addLocalNotification'
    local v = fun .. ":nil"
    if gf:isAndroid() then
        local luaj = require('luaj')
        local className = 'org/cocos2dx/lua/AppActivity'
        local sig = "(Ljava/lang/String;II)V"
        local args = {}
        args[1] = oneNofication["title"]
        args[2] = self:getPushInterval(oneNofication["repeatUnit"])
        args[3] = oneNofication["pushTime"]
        local ok = luaj.callStaticMethod(className, fun, args, sig)
        v = tostring(ok)
    elseif gf:isIos() then
        local luaoc = require('luaoc')
        local args = oneNofication
        local ok = luaoc.callStaticMethod('AppController', fun, args)
         v = tostring(ok)
    end

    Log:I('fun: ' .. fun .. ' result: ' ..  v )
end

function LocalNotificationMgr:getPushInterval(repeatUnit)
    local interval = 0

    if "day" == repeatUnit then
        interval = 60 * 60 * 24
    elseif "week" == repeatUnit then
        interval = 60 * 60 * 24 * 7
    end

    return interval
end

-- 推送
function LocalNotificationMgr:addAllNotification()
   -- 推送之前清除一下推送
   self:clearAllNotification()

   -- 添加推送
   local list = LocalNotificationMgr:getNotificationList()

   for i = 1, #list do
        self:addLocalNotification(list[i])
   end
end

-- 清除推送
function LocalNotificationMgr:clearAllNotification()
    local fun = 'removeNotification'
    local v = fun .. ":nil"
    if platform == cc.PLATFORM_OS_ANDROID then
        local luaj = require('luaj')
        local className = 'org/cocos2dx/lua/AppActivity'
        local sig = "()V"
        local args = {}
        local ok = luaj.callStaticMethod(className, fun, args, sig)
        v = tostring(ok)
    elseif platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_IPHONE then
        local luaoc = require('luaoc')
        local ok = luaoc.callStaticMethod('AppController', fun)
        v = tostring(ok)
    end

    Log:I('fun: ' .. fun .. ' result: ' ..  v )
end

-- 计算首次推送的时间点
-- ourStr时间段 12:00
-- dayStr哪天 如 0 每天  1 周天
function LocalNotificationMgr:getFirstNotificationTime(ourStr, dayStrTable, isComThisDay, isComThisWeek)
    local firstNotificationTime = 10
    local time = gf:getServerTime()
    local dateInfo = gf:getServerDate("*t", time)
    local startH, startM = string.match(ourStr, "(%d+):(%d+)")
    local dayStrs = gf:split(dayStrTable, ",")
    local dayStr
    local fnts = {}
    if startH and startM then
        for i = 1, #dayStrs do
            dayStr = dayStrs[i]
            firstNotificationTime = {}
            firstNotificationTime.aday = dayStr
            if 1 <= tonumber(dayStr) and tonumber(dayStr) <= 7  then -- 周一到周天
                local curTolalMin = self:getTotolMin(dateInfo["wday"], dateInfo["hour"], dateInfo["min"])
                 local pushMin = self:getTotolMin(tonumber(dayStr), startH, startM)
                 if curTolalMin > pushMin then
                    firstNotificationTime.time = 60 * 24 * 7 + pushMin - curTolalMin
                 else
                    if isComThisWeek then
                        -- 这周推送已完成，生成下周的推送
                        firstNotificationTime.time = 60 * 24 * 7 + pushMin - curTolalMin
                    elseif isComThisDay and tonumber(dayStr) == dateInfo["wday"] then
                        -- 今天活动已完成，生成下周的推送
                        firstNotificationTime.time = 60 * 24 * 7 + pushMin - curTolalMin
                    else
                        firstNotificationTime.time = pushMin - curTolalMin
                    end
                 end
             elseif tonumber(dayStr) == 0 then -- 每天
                local curTolalMin = tonumber(dateInfo["hour"]) * 60 +  tonumber(dateInfo["min"])
                local pushMin = tonumber(startH) * 60 + tonumber(startM)

                if curTolalMin > pushMin then
                    firstNotificationTime.time = 60 * 24 + pushMin - curTolalMin
                else
                    if isComThisWeek then
                        -- 这周推送已完成，生成下周一的推送
                        firstNotificationTime.time = 60 * 24 * (7 - (dateInfo["wday"] - 2 + 7) % 7) + pushMin - curTolalMin
                    elseif isComThisDay then
                        -- 今天活动已完成，生成下一天的推送
                        firstNotificationTime.time = 60 * 24 + pushMin - curTolalMin
                    else
                        firstNotificationTime.time = pushMin - curTolalMin
                    end
                end
             end
             table.insert(fnts, firstNotificationTime)
        end
    end

    return fnts
end

-- 获取分钟数
function LocalNotificationMgr:getTotolMin(day, our , min)
	return (tonumber(day) - 1) * 60 * 24 + tonumber(our) * 60 + tonumber(min)
end

return LocalNotificationMgr
