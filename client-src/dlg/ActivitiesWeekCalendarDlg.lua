-- ActivitiesWeekCalendarDlg.lua
-- Created by yangym Mar/15/2017
-- 限时活动周历
local ActivitiesWeekCalendarDlg = Singleton("ActivitiesWeekCalendarDlg", Dialog)

local DAY_LIST =
{
    [0] = "EverydayListPanel",
    [1] = "Day7ListPanel",
    [2] = "Day1ListPanel",
    [3] = "Day2ListPanel",
    [4] = "Day3ListPanel",
    [5] = "Day4ListPanel",
    [6] = "Day5ListPanel",
    [7] = "Day6ListPanel",
}

function ActivitiesWeekCalendarDlg:init()
    self.cell = self:getControl("ListUnitMidPanel"):clone()
    self.cell:retain()

    -- 设置选中光效
    self:setSelectEffect()

    -- 设置每日列表内容
    self:setEveryDayList()

    -- 设置周一至周日的列表内容
    self:setWeekDayList()
end

function ActivitiesWeekCalendarDlg:setSelectEffect()
    local time = gf:getServerTime()
    local day = gf:getServerDate("*t", time)["wday"]
    self:setCtrlVisible("FrameImage1", false, DAY_LIST[day])
    self:setCtrlVisible("FrameImage2", true, DAY_LIST[day])

    self:setCtrlVisible("SelectedImage", true, "Day" .. (day - 1) .. "Panel")
end

function ActivitiesWeekCalendarDlg:sortData(data)
    table.sort(data, function(l, r)
        local lHour, lMin = string.match(l.activityTime[1][1], "(%d+):(%d+)-%d+:%d+")
        local rHour, rMin = string.match(r.activityTime[1][1], "(%d+):(%d+)-%d+:%d+")
        if lHour < rHour then return false end
        if lHour > rHour then return true end

        if lMin < rMin then return false end
        if lMin > rMin then return true end
    end)
end

function ActivitiesWeekCalendarDlg:setEveryDayList()
    local everyDayLimitActivity = {}
    local limitActivity = ActivityMgr:getLimitActivity(true)
    for k, v in pairs(limitActivity) do
        if v.actitiveDate == "0" then
            local activityTime = v.activityTime
            for i = 1, #activityTime do
                table.insert(everyDayLimitActivity, {name = v.name, show_name = v.short_name or v.name, activityTime = {v.activityTime[i]}, order = v.index})
            end
        end
    end

    self:sortData(everyDayLimitActivity)
    self:setListView(everyDayLimitActivity, "EverydayListPanel")
end

function ActivitiesWeekCalendarDlg:setWeekDayList()
    for i = 1, 7 do
        local wdayData = {}
        local limitActivity = ActivityMgr:getLimitActivity(true)
        for k, v in pairs(limitActivity) do
            if self:isWdayActivity(i, v) then
                local activityTime = v.activityTime
                for j = 1, #activityTime do
                    table.insert(wdayData, {name = v.name, show_name = v.short_name or v.name, activityTime = {v.activityTime[j]}, order = v.index})
                end
            end
        end

        self:sortData(wdayData)
        self:setListView(wdayData, DAY_LIST[i])
    end
end

function ActivitiesWeekCalendarDlg:setListView(data, panel)
    local listPanel = self:getControl("ListScrollView", nil, panel)
    listPanel:removeAllChildren()
    local contentLayer = ccui.Layout:create()

    for i = 1, #data do
        local cell = self.cell:clone()
        local cellData = data[i]

        -- 活动名称
        self:setLabelText("NameLabel", cellData.show_name, cell)

        -- 活动时间
        local num = #cellData.activityTime
        local timePanelName = num .. "TimesPanel"
        self:setCtrlVisible(timePanelName, true, cell)
        for j = 1, num do
            local timeStr = string.match(cellData.activityTime[j][1], "(%d+:%d+-%d+:%d+)")
            self:setLabelText("TimeLabel" .. j, timeStr, self:getControl(timePanelName, nil, cell))
        end

        -- 控件位置
        cell:setPosition(0, (i - 1) * cell:getContentSize().height)
        cell:setTag(i)

        -- 绑定点击事件
        local touchPanel = self:getControl("BackImage", nil, cell)
        touchPanel:setTouchEnabled(true)
        local function touch(sender, eventType)
            if ccui.TouchEventType.ended == eventType then
                local dlg = DlgMgr:openDlg("ActivitiesInfoFFDlg")
                local info = ActivityMgr:getLimitActivityDataByName(cellData.name)
                dlg:setData(info, false)
            end
        end
        touchPanel:addTouchEventListener(touch)

        contentLayer:addChild(cell)
    end

    local totalHeight = #data * self.cell:getContentSize().height
    contentLayer:setContentSize(listPanel:getContentSize().width, totalHeight)
    listPanel:setTouchEnabled(true)
    listPanel:setClippingEnabled(true)
    listPanel:setBounceEnabled(true)
    listPanel:addChild(contentLayer)
    listPanel:setInnerContainerSize(contentLayer:getContentSize())
end

-- 是否是对应wday的活动（不包括每天都有的活动）
function ActivitiesWeekCalendarDlg:isWdayActivity(wday, data)
   local isWdayActivity = false
    local weekDayList = gf:split(data["actitiveDate"], ",")
   for i = 1,#weekDayList do
        if  wday == tonumber(weekDayList[i]) then  -- 星期几
            isWdayActivity = true
            break
       end
   end

   return isWdayActivity
end

function ActivitiesWeekCalendarDlg:cleanup()
    self:releaseCloneCtrl("cell")
end

return ActivitiesWeekCalendarDlg