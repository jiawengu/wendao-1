-- KuafsdInfoDlg.lua
-- Created by huangzz Feb/17/2017
-- 跨服试道信息界面

local KuafsdInfoDlg = Singleton("KuafsdInfoDlg", Dialog)

local margin_precent = 4.4
local time = 0
local isRunning = 0

function KuafsdInfoDlg:init()
    self:bindListener("KuafsdaoButton", self.onKuafsdaoButton)
    self:bindListener("CloseButton", self.onCloseButton_1)

    self:onKuafsdaoButton()

    self:setFullScreen()
    self.root:setPositionY(self.root:getPositionY() - self:getWinSize().height  * margin_precent / 100)

    self:MSG_CS_SHIDAO_TASK_INFO(ShiDaoMgr:getKuafsdInfo())

    self:hookMsg("MSG_CS_SHIDAO_TASK_INFO")
end

function KuafsdInfoDlg:onKuafsdaoButton(sender, eventType)
    self:setCtrlVisible("KuafsdaoButton", false)
    self:setCtrlVisible("MainPanel", true)
end

function KuafsdInfoDlg:onCloseButton_1(sender, eventType)
    self:setCtrlVisible("KuafsdaoButton", true)
    self:setCtrlVisible("MainPanel", false)
end

function KuafsdInfoDlg:MSG_CS_SHIDAO_TASK_INFO(data)
    if not data or not next(data) then
        return
    end

    if ShiDaoMgr:isMonthTaoKFSD() then
        self:setImage("TitleImage_3", ResMgr.ui.month_tao_kuafsd_tip1)
        self:setImage("TitleImage_4", ResMgr.ui.month_tao_kuafsd_tip2)
    end

    self:setLabelText("LevelLabel", string.format(CHS[6000026], data.levelRange))
    self:setLabelText("TotalScoreLabel", CHS[5400035] .. data.team_score)
    self:setLabelText("PKTimesLabel", CHS[5400036] .. data.pk_num)

    if ShiDaoMgr:isMonthTaoKFSD() then
        -- 月道行试道不显示赛区
        self:setLabelText("ZoneLabel", CHS[5400661] .. data.area)
    else
        self:setLabelText("ZoneLabel", data.area .. CHS[5400027])
    end

    isRunning = data.is_running
    if isRunning == 0 then
        time = data.start_time - gf:getServerTime()
        self:setCtrlVisible("TitleImage_3", true)
        self:setCtrlVisible("TitleImage_4", false)
        self:setLabelText("CurrentOrderLabel", CHS[5400034] .. CHS[3001763])
    elseif isRunning == 1 then
        time = data.end_time - gf:getServerTime()
        self:setCtrlVisible("TitleImage_3", false)
        self:setCtrlVisible("TitleImage_4", true)

        if ShiDaoMgr:isMonthTaoKFSD() and data.rank > 50 then
            self:setLabelText("CurrentOrderLabel", CHS[5400034] .. string.format(CHS[5400761], 50))
        elseif not ShiDaoMgr:isMonthTaoKFSD() and data.rank > 10 then
            self:setLabelText("CurrentOrderLabel", CHS[5400034] .. string.format(CHS[5400761], 10))
        else
            self:setLabelText("CurrentOrderLabel", CHS[5400034] .. string.format(CHS[7002270], data.rank))
        end
    end

    self.lastRequestTime = time

    if not self.schedulId then
        if time <= 0 then
            return
        end

        self.schedulId = gf:Schedule(function()
            time = time - 1
            if (isRunning == 1 and self.lastRequestTime - time >= 10)
                or (isRunning == 0 and self.lastRequestTime - time >= 60) then
                self.lastRequestTime = time
                gf:CmdToServer("CMD_REFRESH_CS_SHIDAO_INFO", {type = data.type or 1})
            end

            if time >= 0 then
                self:setTime(time)
            else
                self:stopSchedule()
            end
        end, 1)
    end
end

function KuafsdInfoDlg:setTime(time)
    local hour = math.floor(time / 3600) % 24
    local min = math.floor(time / 60) % 60
    local sec = time % 60
    local timeStr = string.format("%02d:%02d:%02d", hour, min, sec)
    self:setLabelText("LeftTimeLabel_1", timeStr)
    self:setLabelText("LeftTimeLabel_2", timeStr)
end

function KuafsdInfoDlg:stopSchedule()
    if self.schedulId then
        gf:Unschedule(self.schedulId)
        self.schedulId = nil
    end
end

function KuafsdInfoDlg:cleanup()
    self:stopSchedule()
end

return KuafsdInfoDlg
