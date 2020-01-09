-- QuanmPK2sjDlg.lua
-- Created by lixh Jul/16/2018
-- 全民PK赛第2版 时间表与规则界面

local QuanmPK2sjDlg = Singleton("QuanmPK2sjDlg", Dialog)

-- 记录菜单选择的时间
local RECORD_MENU_TIME = 150

local MENU_TYPE = {
    TIME = 1,   -- 时间
    RULE = 2,   -- 规则
}

function QuanmPK2sjDlg:init()
    self:bindListener("MatchButton", self.onTimeButton)
    self:bindListener("FinalsButton", self.onRuleButton)
    self:bindListViewListener("GongceListView", self.onSelectGongceListView)
    self:bindListViewListener("NeiceListView", self.onSelectNeiceListView)

    if DistMgr:curIsTestDist() then
        -- 总决赛
        self:setLabelText("StageLabel", CHS[7120154], "StagePanel_10")
    else
        -- 线下总决赛
        self:setLabelText("StageLabel", CHS[7120155], "StagePanel_10")
    end

    if not self.chooseRecord then
        -- 没有记录过选择时，默认选择时间选项
        self:chooseMenu(MENU_TYPE.TIME)
    else
        local meGid = Me:queryBasic("gid")
        local type, time = string.match(self.chooseRecord, "(.+)" .. meGid .. "(.+)")
        if not type or not time then
            -- 不匹配，可能更换了账号
            self:chooseMenu(MENU_TYPE.TIME)
        else
            type = tonumber(type)
            time = tonumber(time)
            if gf:getServerTime() - time > RECORD_MENU_TIME then
                -- 记录时间超时，默认选择时间选项
                self:chooseMenu(MENU_TYPE.TIME)
            else
                self:chooseMenu(type)
            end
        end
    end

    QuanminPK2Mgr:requestQmpkTimeData()
    QuanminPK2Mgr:requestQmpkMyData()
end

-- 初始化时间
function QuanmPK2sjDlg:initTimePanel()
    local data = QuanminPK2Mgr:getScTimeData()
    if not data then return end

    -- 热身赛
    local timeStr = gf:getServerDate(CHS[7100288], data.warmupStartTime)
    timeStr = timeStr.. " - " .. gf:getServerDate(CHS[7100288], data.warmupEndTime)
    self:setLabelText("TimeLabel", timeStr, "StagePanel_1")

    -- 报名
    local timeStr = gf:getServerDate(CHS[7100288], data.signupStartTime)
    timeStr = timeStr.. " - " .. gf:getServerDate(CHS[7100288], data.signupEndTime)
    self:setLabelText("TimeLabel", timeStr, "StagePanel_2")

    -- A赛区
    local timeStr = self:getScoreTimeStr(data.zoneList[1])
    self:setLabelText("TimeLabel", timeStr, "StagePanel_3")

    -- B赛区
    local timeStr = self:getScoreTimeStr(data.zoneList[2])
    self:setLabelText("TimeLabel", timeStr, "StagePanel_4")

    -- 淘汰赛
    for i = 1, data.kickoutNum do
        local info = data.kickoutList[i]
        if info then
            local timeStr = gf:getServerDate(CHS[7100288], info.startTime)
            self:setLabelText("TimeLabel", timeStr, "StagePanel_" .. (4 + i))
        end
    end

    -- 总决赛
    local timeStr = gf:getServerDate(CHS[7100288], data.finalStartTime)
    self:setLabelText("TimeLabel", timeStr, "StagePanel_10")
end

-- 获取积分赛时间节点字符串
function QuanmPK2sjDlg:getScoreTimeStr(list)
    if not list then return "" end
    local timeList = list.timeList
    local count = list.num
    local retStr = ""
    if count <= 0 then return retStr end
    local timeStr = gf:getServerDate(CHS[7100310], timeList[1].startTime)
    retStr = timeStr
    local month = gf:getServerDate(CHS[7100311], timeList[1].startTime)
    local day = gf:getServerDate(CHS[7100312], timeList[1].startTime)
    for i = 2, count do
        local tmpTimeStr = gf:getServerDate(CHS[7100310], timeList[i].startTime)
        local tmpMonth = gf:getServerDate(CHS[7100311], timeList[i].startTime)
        local tmpDay = gf:getServerDate(CHS[7100312], timeList[i].startTime)
        if tmpTimeStr ~= timeStr then
            if tmpMonth ~= month then
                -- 跨月份，直接追加整个串
                retStr = retStr .. "、" ..  tmpTimeStr
            elseif tmpDay ~= day then
                -- 天数不同，只追加天数
                retStr = retStr .. "、".. tmpDay
            end
        end
    end

    retStr = retStr .. gf:getServerDate("%H:%M", timeList[1].startTime)
    return retStr
end

-- 选择菜单
function QuanmPK2sjDlg:chooseMenu(type)
    local isTime = type == MENU_TYPE.TIME
    self:setCtrlVisible("MatchImage", isTime)
    self:setCtrlVisible("FinalsImage", not isTime)
    self:setCtrlVisible("TimePanel", isTime)
    self:setCtrlVisible("RulePanel", not isTime)

    if not isTime then
        local isTestDist = DistMgr:curIsTestDist()
        self:setCtrlVisible("GongceListView", not isTestDist)
        self:setCtrlVisible("NeiceListView", isTestDist)
    end

    local meGid = Me:queryBasic("gid")
    self.chooseRecord = type .. meGid .. gf:getServerTime()
end

function QuanmPK2sjDlg:onTimeButton(sender, eventType)
    self:chooseMenu(MENU_TYPE.TIME)
end

function QuanmPK2sjDlg:onRuleButton(sender, eventType)
    self:chooseMenu(MENU_TYPE.RULE)
end

function QuanmPK2sjDlg:onSelectGongceListView(sender, eventType)
end

function QuanmPK2sjDlg:onSelectNeiceListView(sender, eventType)
end

return QuanmPK2sjDlg
