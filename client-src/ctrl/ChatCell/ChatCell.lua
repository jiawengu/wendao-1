-- ChatCell.lua
-- Created by sujl, Dec/8/2016
-- 聊天交互控件基类

local ChatCell = class("ChatCell", function()
    return ccui.Layout:create()
end)

function ChatCell:getTimeStr(time)
    local timeStr = ""
    local timeTabel = os.date("*t",time)
    local curtimeTabel = os.date("*t",gf:getServerTime())
    local difDay = curtimeTabel["yday"] - timeTabel["yday"]

    if difDay == 0 then
        timeStr = string.format("%02d:%02d", timeTabel["hour"], timeTabel["min"])
    else
        if difDay == 1 then
            timeStr = string.format("%s  %02d:%02d", CHS[6000134], timeTabel["hour"], timeTabel["min"])
        elseif difDay <= 7 and difDay >1 then
            timeStr = string.format("%s%s  %02d:%02d", CHS[6000135], CONST_WDAY[timeTabel["wday"]], timeTabel["hour"], timeTabel["min"])
        elseif difDay > 7 then
            timeStr = string.format("%d-%02d-%02d  %02d:%02d", timeTabel["year"], timeTabel["month"], timeTabel["day"], timeTabel["hour"], timeTabel["min"])
        end
    end

    return timeStr
end

return ChatCell