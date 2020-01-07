-- DaySelectPanel.lua
-- Created by sujl, Apr/11/2018
-- 日期选择界面

local DaySelectPanel = class(DaySelectPanel)

local YEAR_MIN_COUNT = 100
local YEAR_MAX_COUNT = 100
local MONTH_COUNT = 12

-- 单个数字panel的高度，生日滚轮处用，代码中根据实际高度会再次赋值
local UNIT_NUMBER_HEIGHT = 36

-- 滚动结束后，自动滚动到目标值时间
local AUTO_SCROLL_TIME = 0.2

local MONTH_DAY_MAP = {
--      1   2   3   4   5   6   7   8   9   10  11  12
        31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31,
}

function DaySelectPanel:ctor(dlg, panel, callback, confirmButtonName, maxYear, minYear)
    self.maxYear = maxYear or YEAR_MAX_COUNT
    self.minYear = minYear or YEAR_MIN_COUNT
    self.dlg = dlg
    self.panel = panel
    self.callback = callback
    confirmButtonName = confirmButtonName or "ConfirmButton"
    self.numPanel = self.dlg:retainCtrl("UnitNumPanel", panel)

    local confirmButton = self.dlg:getControl(confirmButtonName, nil, self.panel)
    -- 事件监听
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:onConfirmButton(sender, eventType)
        end
    end

    confirmButton:addTouchEventListener(listener)
end

function DaySelectPanel:showPanel(value)
    self:initPanel(value)
    self.panel:setVisible(true)
end

function DaySelectPanel:initPanel(value)
    value = value or gf:getServerTime()
    local panel = self.panel

    local year = gf:getServerDate("*t", value)["year"]
    local month = gf:getServerDate("*t", value)["month"]
    local day = gf:getServerDate("*t", value)["day"]
    local minYear = year - self.minYear + 1

    UNIT_NUMBER_HEIGHT = self.numPanel:getContentSize().height

    local yList = self.dlg:resetListView("YearListView", nil, nil, panel)
    self:initDayListView(yList, (self.maxYear + self.minYear), minYear, year)
    local mList = self.dlg:resetListView("MonthListView", nil, nil, panel)
    self:initDayListView(mList, 12, 1, month)
    local dList = self.dlg:resetListView("DayListView", nil, nil, panel)
    self:initDayListView(dList, 31, 1, day)
end

function DaySelectPanel:initDayListView(list, defCount, minValue, defValu)
    for i = 1, defCount + 4 do
        local uPanel = self.numPanel:clone()
        uPanel:setContentSize(list:getContentSize().width, UNIT_NUMBER_HEIGHT)
        if i <= 2 then
            self.dlg:setLabelText("NumberLabel", "", uPanel)
        elseif i >= defCount + 3 then
            self.dlg:setLabelText("NumberLabel", "", uPanel)
        else
            self.dlg:setLabelText("NumberLabel", minValue + i - 2 - 1, uPanel)
        end
        list:pushBackCustomItem(uPanel)
    end

    list.minValue = minValue
    list.maxValue = minValue + defCount - 1
    self:updateList(list)
    list:refreshView()
    if defValu then
        self:setListByValue(list, defValu)
    end
end

function DaySelectPanel:setListByValue(listView, value)
    local ret = value - listView.minValue
    local retHeight = ret * UNIT_NUMBER_HEIGHT
    local height = listView:getInnerContainer():getContentSize().height
    local percent = retHeight / (height - listView:getContentSize().height)

    listView:getInnerContainer():setPositionY(listView:getContentSize().height - height + retHeight)
end


function DaySelectPanel:setDestPercent(listView, lastPercent)
    local height = listView:getInnerContainer():getContentSize().height
    local curPosX = listView:getInnerContainer():getPositionY()
    local disHeight = (curPosX + (height - listView:getContentSize().height))
    if disHeight <= 0 or disHeight >= (height - listView:getContentSize().height) then return end

    local floatHeight = disHeight % UNIT_NUMBER_HEIGHT
    if floatHeight > UNIT_NUMBER_HEIGHT * 0.5 then
        disHeight = disHeight - floatHeight + UNIT_NUMBER_HEIGHT
    else
        disHeight = disHeight - floatHeight
    end

    local percent = disHeight / (height - listView:getContentSize().height)

    if lastPercent and math.abs(lastPercent - percent) < 0.001 then
        listView.scrolling = false
        return
    end

    listView:scrollToPercentVertical(percent * 100, AUTO_SCROLL_TIME, false)
end


function DaySelectPanel:getListView(listView)
    if listView.scrolling then return end
    local height = listView:getInnerContainer():getContentSize().height
    local curPosX = listView:getInnerContainer():getPositionY()
    local disHeight = (curPosX + (height - listView:getContentSize().height))

    disHeight = disHeight + 5 -- 加上5像素误差
    local value = listView.minValue + math.floor(disHeight / UNIT_NUMBER_HEIGHT)
    return value
end


function DaySelectPanel:checkBirthValidity()
    local yList = self.dlg:getControl("YearListView")
    local mList = self.dlg:getControl("MonthListView")
    local dList = self.dlg:getControl("DayListView")

    if yList.scrolling or mList.scrolling or dList.scrolling then
        -- 如果有还在滚动，则return
        return
    end

    local year = self:getListView(yList)
    local month = self:getListView(mList)
    local day = self:getListView(dList)

    local dayMax = MONTH_DAY_MAP[month]
    if month == 2 and year % 4 == 0 then
        -- 如果是2月闰年，29天
        dayMax = 29
    end

    if dList.maxValue ~= dayMax then
        local dList = self.dlg:resetListView("DayListView")
        local def = day > dayMax and 1 or day
        if day > dayMax then
            gf:ShowSmallTips(CHS[4300329])
        end

        self:initDayListView(dList, dayMax, 1, def)
    end
end


-- 获取当前ListView滚动百分比
function DaySelectPanel:getCurScrollPercent(listView)
    local height = listView:getInnerContainer():getContentSize().height
    local curPosX = listView:getInnerContainer():getPositionY()
    local disHeight = (curPosX + (height - listView:getContentSize().height))
    local percent = disHeight / (height - listView:getContentSize().height)
    return percent
end

-- 更新右侧信息
function DaySelectPanel:updateList(list)
    local lastPercent
    local  function scrollListener(sender , eventType)
        if eventType == ccui.ScrollviewEventType.scrolling then
            local delay = cc.DelayTime:create(0.1)
            local func = cc.CallFunc:create(function()
                local percent = self:getCurScrollPercent(sender)
                if percent <= 0 or percent >= 100 then return end

                self:setDestPercent(sender, lastPercent)
                lastPercent = self:getCurScrollPercent(sender)
            end)

            local func2 = cc.CallFunc:create(function()
                 -- 如果是年、月的listView，滚动结束后们需要重置日的滚轮
                sender.scrolling = false

                self:checkBirthValidity()
            end)

            sender:stopAllActions()
            sender.scrolling = true
            sender:runAction(cc.Sequence:create(delay, func, cc.DelayTime:create(AUTO_SCROLL_TIME), func2))
        end
    end

    list:addScrollViewEventListener(scrollListener)
end

function DaySelectPanel:onConfirmButton(sender, eventType)
    local yList = self.dlg:getControl("YearListView", nil, self.panel)
    local mList = self.dlg:getControl("MonthListView", nil, self.panel)
    local dList = self.dlg:getControl("DayListView", nil, self.panel)

    if yList.scrolling or mList.scrolling or dList.scrolling then
        -- 如果有还在滚动，则return
        gf:ShowSmallTips(CHS[4300328])  -- 当前有数字处于未选中状态，请稍后再试。
        return
    end


    local year = self:getListView(yList)
    local month = self:getListView(mList)
    local day = self:getListView(dList)

    if 'function' == type(self.callback) then
        self.callback(self.dlg, year, month, day)
    end

    self.panel:setVisible(false)
end

return DaySelectPanel