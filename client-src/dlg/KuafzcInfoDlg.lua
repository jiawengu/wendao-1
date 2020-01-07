-- KuafzcInfoDlg.lua
-- Created by songcw Aug/7/2017
-- 跨服战场，战斗中信息

local KuafzcInfoDlg = Singleton("KuafzcInfoDlg", Dialog)

local margin_precent = 4.4

function KuafzcInfoDlg:init()
    self:bindListener("KuafsdaoButton", self.onKuafsdaoButton)
    self:bindListener("CloseButton", self.onCloseButton_1)

    -- self:onCloseButton_1()
    self.data = nil

    self:setFullScreen()
    self.root:setPositionY(self.root:getPositionY() - self:getWinSize().height  * margin_precent / 100)

    KuafzcMgr:queryLiveScore()

    self:setLastOperTime("lastRequestTime", gfGetTickCount())

    self:hookMsg("MSG_CSL_LIVE_SCORE")
end

function KuafzcInfoDlg:onKuafsdaoButton(sender, eventType)
    self:setCtrlVisible("KuafsdaoButton", false)
    self:setCtrlVisible("MainPanel", true)
end

function KuafzcInfoDlg:onCloseButton_1(sender, eventType)
    self:setCtrlVisible("KuafsdaoButton", true)
    self:setCtrlVisible("MainPanel", false)
end

function KuafzcInfoDlg:getCurState(data)
    if gf:getServerTime() > data.end_time then
        return 3    -- 超时
    end

    if gf:getServerTime() >= data.start_time and gf:getServerTime() <= data.end_time then
        return 1     -- 开始
    end

    return 0        -- 准备
end

local time = 0
function KuafzcInfoDlg:MSG_CSL_LIVE_SCORE(data)
    if not data then
        return
    end

    self.data = data
    self:setLabelText("DistLabel_1", string.format("%s:%d", data.our_dist, data.our_score))
    self:setLabelText("DistLabel_2", string.format("%s:%d", data.other_dist, data.other_score))
    self:setLabelText("ScoreLabel", string.format(CHS[4100723], data.score))
    self:setLabelText("PKTimesLabel", string.format(CHS[4100724], data.contrib))


    local isRunning = self:getCurState(data)
    self:setCtrlVisible("TitleImage_3", isRunning == 0)
    self:setCtrlVisible("TitleImage_4", isRunning ~= 0)
    if isRunning == 0 then
        time = data.start_time - gf:getServerTime()
    elseif isRunning == 1 then
        time = data.end_time - gf:getServerTime()
    end

    if not self.schedulId then
        if time <= 0 and isRunning == 0 then
            KuafzcMgr:queryLiveScore()
            return
        end

        self.schedulId = gf:Schedule(function()
            time = time - 1
            local isRunning = self:getCurState(data)
            self:setCtrlVisible("TitleImage_3", isRunning == 0)
            self:setCtrlVisible("TitleImage_4", isRunning ~= 0)
            if isRunning == 0 then
                time = data.start_time - gf:getServerTime()
            elseif isRunning == 1 then
                time = data.end_time - gf:getServerTime()
            end

            if self:isOutLimitTime("lastRequestTime", 10000)
                and (isRunning == 1 or isRunning == 0) then
                self:setLastOperTime("lastRequestTime", gfGetTickCount())
                KuafzcMgr:queryLiveScore()
            end

            if time > 0 then
                self:setTime(time)
            else
                self:stopSchedule()
            end
        end, 1)
    end
end

function KuafzcInfoDlg:setTime()
    local time = 0
    local isRunning = self:getCurState(self.data)
    self:setCtrlVisible("TitleImage_3", isRunning == 0)
    self:setCtrlVisible("TitleImage_4", isRunning ~= 0)
    if isRunning == 0 then
        time = self.data.start_time - gf:getServerTime()
    elseif isRunning == 1 then
        time = self.data.end_time - gf:getServerTime()
    end
    local hour = math.floor(time / 3600) % 24
    local min = math.floor(time / 60) % 60
    local sec = time % 60
    local timeStr = string.format("%02d:%02d:%02d", hour, min, sec)
    self:setLabelText("LeftTimeLabel_1", timeStr)
    self:setLabelText("LeftTimeLabel_2", timeStr)
end

function KuafzcInfoDlg:stopSchedule()
    if self.schedulId then
        gf:Unschedule(self.schedulId)
        self.schedulId = nil
    end
end

function KuafzcInfoDlg:cleanup()
    self:stopSchedule()
end

return KuafzcInfoDlg
